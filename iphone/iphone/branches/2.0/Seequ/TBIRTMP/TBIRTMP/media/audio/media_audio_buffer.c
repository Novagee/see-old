//
//  media_audio_buffer.c
//  ios-ngn-stack
//
//  Created by Administrator on 10/10/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#include "media_audio_buffer.h"
#include "TBIRTMP.h"
#include "TBI_common.h"
#include "TBI_time.h"
#include "TBI_debug.h"
#include "TBI_thread.h"
#include "TBI_safeobj.h"
#include "SoundTouchWraper.h"

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <memory.h>
#include <time.h>
#include <unistd.h>

#include <libkern/OSAtomic.h>

#define DROPING_DELAY           40

#define DEFAULT_UNIT_TIME           24.f    //ms
#define DEFAULT_UNIT_MAXCNT         10

#define DEFAULT_OVERLAP_TIME        8       //ms
#define DEFAULT_BUFEND_TIME         DEFAULT_OVERLAP_TIME
//#define DEFAULT_BUFEND_SIZE(R)      (R / 1000 * 2 * DEFAULT_BUFEND_TIME)

#define DEFAULT_DELAY_PERIOD        5000
#define DEFAULT_DELAY_COUNT         2
#define DEFAULT_INCREASE_COUNT      3
#define DEFAULT_DECREASE_COUNT      2

#define DEFAULT_RECVSIZE_COIFF      31

#define LOWPASS_BUFFER_TIME         100

void media_audio_buffer_checkInteraptions(media_audio_buffer_t* audio_buffer, uint64_t current_time, uint32_t deltaTime);
uint32_t media_audio_buffer_getIncreaseSizeByInteraptions(media_audio_buffer_t* audio_buffer);

void reset_statistics(media_audio_buffer_t* audio_buffer);
void print_statistics(media_audio_buffer_t* audio_buffer);
void print_calls_interval(media_audio_buffer_t* audio_buffer);

audio_recv_data_t* create_audio_recv_data();
void destoy_audio_recv_data(audio_recv_data_t** data);
int push_back_audio_recv_data(media_audio_buffer_t* audio_buffer, const uint8_t* buffer, int size, tbi_bool_t bIsSilenced);
int pop_first_audio_recv_data(media_audio_buffer_t* audio_buffer, uint8_t* buffer, int size);
int erase_front_audio_recv_data(media_audio_buffer_t* audio_buffer, int count);
int audio_recv_data_get_size(media_audio_buffer_t* audio_buffer);

int calculateUnitSize(int unitSize, int bufSize, int sbufSize, int addSize);

void overlapMonoUp(short *pOutput, const short *pInput, int overlapLength);
void overlapMonoDown(short *pOutput, const short *pInput, int overlapLength);

//low pass filter =========================================================
void low_pass_filter_push_back(media_audio_buffer_t* audio_buffer, uint8_t* data, int size);
int low_pass_filter_pop_front(media_audio_buffer_t* audio_buffer, uint8_t* data, int size);

//audio_recv_data_list_t ==================================================
void audio_recv_data_list_pop_front(audio_recv_data_list_t* list, audio_recv_data_t* data);
void audio_recv_data_list_push_back(audio_recv_data_list_t* list, const audio_recv_data_t* data);
void audio_recv_data_list_clear(audio_recv_data_list_t* list);

//interraption checker ====================================================
typedef struct media_audio_interraption_s
{
	TBI_DECLARE_OBJECT;
    uint32_t delayedTime;
    uint64_t timestamp;
	TBI_DECLARE_SAFEOBJ;
} media_audio_interraption_t;
extern const TBI_object_def_t *media_audio_interraption_def_t;

int timeMS2BufferSize(float time, int rate, int channel, int sempleByte)
{
    return ((float)rate/1000.f) * sempleByte * channel * time;
}

float bufferSize2TimeMS(int size, int rate, int channel, int sempleByte)
{
    return ((float)size * 1000.f)/(float)(rate * sempleByte) * (float)channel;
}

//==================================
void* process_lowpass(void* param)
{
    media_audio_buffer_t* audio_buffer = (media_audio_buffer_t*)param;
    if(!audio_buffer)
        return 0;
    
    uint8_t* data = 0;
    int dataMaxSize = 0, size;
    
    while (audio_buffer->bIsLowPassStarted)
    {
        TBI_semaphore_decrement(audio_buffer->lowPassBuffer.sem);
        if(!audio_buffer->bIsLowPassStarted)
            break;
        
//        fprintf(stderr, "lowpass event hendler started == %d\n", audio_buffer->dataSize);
        usleep(18000);
        if(audio_buffer->dataSize == 0)
        {
//            fprintf(stderr, "lowpass processing ==== %d\n", audio_buffer->lowPassBuffer.nRead);
            size = low_pass_filter_pop_front(audio_buffer, data, dataMaxSize);
        }
    }
    
    if(data) free(data);
    return 0;
}

// media_audio_buffer
media_audio_buffer_t* open_audio_buffer(uint32_t rate, TBI_size_t chunckSize, int pTime, uint32_t frameCnt)
{
    media_audio_buffer_t* audio_buffer = (media_audio_buffer_t*)calloc(1, sizeof(media_audio_buffer_t));
    
    audio_buffer->chunckSize = chunckSize;
    audio_buffer->pTime = pTime;
    audio_buffer->rate = rate;
    audio_buffer->frameCnt = frameCnt;
    
    audio_buffer->startDroping = 0;
    
    reset_statistics(audio_buffer);

#if IS_SOUND_STRETCHING_ON
    audio_buffer->soundEffect = open_SoundTouchWraper(rate, 1);
    audio_buffer->compressData = 0;
    audio_buffer->compressDataMaxSize = 0;
    audio_buffer->bIsFlushed = tbi_true;
#endif //IS_SOUND_STRETCHING_ON
    
    audio_buffer->startTime = 0;
    
    audio_buffer->dataSize = 0;
    audio_buffer->bIsSilenced = 0;
    audio_buffer->seq = 0;
    
    audio_buffer->lastCheckCnt = 0;
    audio_buffer->nFlushedCnt = 5;
    
    audio_buffer->stabBuffer.sBuffer = 0;
    audio_buffer->stabBuffer.sBufferMaxSize = 0;
    audio_buffer->stabBuffer.sBufferSize = 0;
    
    audio_buffer->adaptationSettings.delayTimes.first = 0;
    audio_buffer->adaptationSettings.delayTimes.last = 0;
    audio_buffer->adaptationSettings.delayTimes.count = 0;

    audio_buffer->adaptationSettings.delayCnt = 0;
    audio_buffer->adaptationSettings.defaultUnitSize = timeMS2BufferSize(DEFAULT_UNIT_TIME, rate, 1, 2);
    audio_buffer->adaptationSettings.currentUnitSize = frameCnt * audio_buffer->adaptationSettings.defaultUnitSize;
    audio_buffer->adaptationSettings.time = 0;

    audio_buffer->lowPassBuffer.size = (LOWPASS_BUFFER_TIME * chunckSize)/pTime;
    audio_buffer->lowPassBuffer.buffer = malloc(audio_buffer->lowPassBuffer.size);
    audio_buffer->lowPassBuffer.writePos = 0;

    audio_buffer->lowPassBuffer.locker = 0;
    audio_buffer->lowPassBuffer.lowPassBuf = 0;
    audio_buffer->lowPassBuffer.lowPassBufMaxSize = 0;
    audio_buffer->lowPassBuffer.lowPassBufReadPos = 0;
    audio_buffer->lowPassBuffer.nRead = 0;
    audio_buffer->lowPassBuffer.nReadBufSize = audio_buffer->lowPassBuffer.size;
    audio_buffer->bIsAfterLowPass = tbi_false;
    audio_buffer->bIsLowPassStarted = tbi_true;
    audio_buffer->lowPassBuffer.sem = TBI_semaphore_create();
//    TBI_thread_create(&audio_buffer->lowPassBuffer.tid, process_lowpass, audio_buffer);
    
    audio_buffer->interraptionChecker.interraptions = TBI_list_create();
    audio_buffer->interraptionChecker.rangeLow120 = 0;
    audio_buffer->interraptionChecker.range120_180 = 0;
    audio_buffer->interraptionChecker.range180_240 = 0;
    audio_buffer->interraptionChecker.range240_300 = 0;
    audio_buffer->interraptionChecker.range300_400 = 0;
    audio_buffer->interraptionChecker.range400_700 = 0;

    return audio_buffer;
}

void close_audio_buffer(media_audio_buffer_t* audio_buffer)
{
    if (audio_buffer)
    {
        audio_buffer->bIsLowPassStarted = tbi_false;
        if(audio_buffer->lowPassBuffer.tid)
        {
            TBI_semaphore_increment(audio_buffer->lowPassBuffer.sem);
            TBI_thread_join(&audio_buffer->lowPassBuffer.tid);
        }
        if(audio_buffer->lowPassBuffer.sem)
            TBI_semaphore_destroy(&audio_buffer->lowPassBuffer.sem);

#if IS_SOUND_STRETCHING_ON
        if(audio_buffer->compressData)
            free(audio_buffer->compressData);

        close_SoundTouchWraper(&audio_buffer->soundEffect);
#endif //IS_SOUND_STRETCHING_ON

        audio_recv_data_list_clear(&audio_buffer->audio_data_list);

        if(audio_buffer->stabBuffer.sBuffer)
        {
            free(audio_buffer->stabBuffer.sBuffer);
            audio_buffer->stabBuffer.sBuffer = 0;
            audio_buffer->stabBuffer.sBufferMaxSize = 0;
            audio_buffer->stabBuffer.sBufferSize = 0;
        }
        
        TBI_OBJECT_SAFE_FREE(audio_buffer->interraptionChecker.interraptions);

        free(audio_buffer);
    }
}

int correct_cut(short y0, short y1, short* buf, int size)
{
    int k = y1 - y0;
    float deltaT = 1000.f/8000.f;
    float tg_alfa = (float)(y1 - y0)/deltaT;
    int n = 0;
    
    printf("size = %d | tg_alfa = %.2f\n", size, tg_alfa);
    short y2 = tg_alfa * deltaT + y1;
    
    printf("y0 = %d y1 = %d y2 = %d\n", y0, y1, y2);
    for (int i = 0; i < size; i++)
    {
        printf("%d ", buf[i]);
        if(k > 0)
        {
            if((buf[i] > y1) && (buf[i] < (y2 + 100)))
            {
                n = i + 1;
                break;
            }
        }
        else if (k < 0)
        {
            if((buf[i] < y1) && (buf[i] > (y2 - 100)))
            {
                n = i + 1;
                break;
            }
        }
    }
    printf("\n");
    return n;
}

void calculateAdaptiveUnitSize(media_audio_buffer_t* audio_buffer, int recvSize)
{
    if(!audio_buffer)
        return;
    
    if(recvSize > 3 * audio_buffer->chunckSize + DEFAULT_RECVSIZE_COIFF)
    {
        if(audio_buffer->adaptationSettings.currentUnitSize < (DEFAULT_UNIT_MAXCNT * audio_buffer->adaptationSettings.defaultUnitSize))
        {
            if(recvSize > 7 * audio_buffer->chunckSize + DEFAULT_RECVSIZE_COIFF)
            {
                audio_buffer->adaptationSettings.currentUnitSize +=
                                (DEFAULT_UNIT_MAXCNT * audio_buffer->adaptationSettings.defaultUnitSize - audio_buffer->adaptationSettings.currentUnitSize > audio_buffer->adaptationSettings.defaultUnitSize)
                                ? 2 * audio_buffer->adaptationSettings.defaultUnitSize
                                : audio_buffer->adaptationSettings.defaultUnitSize;
            }
            else
            {
                audio_buffer->adaptationSettings.currentUnitSize += audio_buffer->adaptationSettings.defaultUnitSize;
            }
            audio_buffer->adaptationSettings.time = TBI_time_epoch();
        }
    }
    else if((TBI_time_epoch() - audio_buffer->adaptationSettings.time) > 4000)
    {
        if(audio_buffer->adaptationSettings.currentUnitSize > audio_buffer->adaptationSettings.defaultUnitSize)
        {
            audio_buffer->adaptationSettings.currentUnitSize -= audio_buffer->adaptationSettings.defaultUnitSize;
            audio_buffer->adaptationSettings.time = TBI_time_epoch();
        }
    }
}

void calculateAdaptiveUnitSize1(media_audio_buffer_t* audio_buffer, int recvSize)
{
    if(!audio_buffer)
        return;
    
    long long time = TBI_time_epoch();
    if(audio_buffer->adaptationSettings.time == 0)
        audio_buffer->adaptationSettings.time = time;
    
    if(recvSize > 3 * audio_buffer->chunckSize + DEFAULT_RECVSIZE_COIFF)
    {
        if(!audio_buffer->adaptationSettings.delayTimes.first || time - audio_buffer->adaptationSettings.delayTimes.first->time <= DEFAULT_DELAY_PERIOD)
        {
            if(!audio_buffer->adaptationSettings.delayTimes.first)
            {
                audio_buffer->adaptationSettings.delayTimes.first = malloc(sizeof(Time_t));
                audio_buffer->adaptationSettings.delayTimes.first->time = time;
                audio_buffer->adaptationSettings.delayTimes.last = audio_buffer->adaptationSettings.delayTimes.first;
            }
            else
            {
                audio_buffer->adaptationSettings.delayTimes.last->next = malloc(sizeof(Time_t));
                audio_buffer->adaptationSettings.delayTimes.last = audio_buffer->adaptationSettings.delayTimes.last->next;
                audio_buffer->adaptationSettings.delayTimes.last->time = time;
            }
            
            audio_buffer->adaptationSettings.delayTimes.count++;
            if(audio_buffer->adaptationSettings.delayTimes.count >= DEFAULT_DELAY_COUNT)
            {
                Time_t *time = audio_buffer->adaptationSettings.delayTimes.first;
                audio_buffer->adaptationSettings.delayTimes.first = audio_buffer->adaptationSettings.delayTimes.first->next;
                audio_buffer->adaptationSettings.delayTimes.count--;
                free(time);
            }
            
            audio_buffer->adaptationSettings.delayCnt++;
            if(audio_buffer->adaptationSettings.delayCnt >= DEFAULT_DELAY_COUNT)
            {
                if(audio_buffer->adaptationSettings.currentUnitSize < (DEFAULT_UNIT_MAXCNT * audio_buffer->adaptationSettings.defaultUnitSize))
                {
                    audio_buffer->adaptationSettings.currentUnitSize +=
                            (DEFAULT_UNIT_MAXCNT * audio_buffer->adaptationSettings.defaultUnitSize - audio_buffer->adaptationSettings.currentUnitSize > DEFAULT_INCREASE_COUNT * audio_buffer->adaptationSettings.defaultUnitSize)
                            ? DEFAULT_INCREASE_COUNT * audio_buffer->adaptationSettings.defaultUnitSize
                            : audio_buffer->adaptationSettings.defaultUnitSize;
                    fprintf(stderr, "calculateAdaptiveUnitSize1: INCREASE delayCnt = %d unitSize = %d\n", audio_buffer->adaptationSettings.delayCnt, audio_buffer->adaptationSettings.currentUnitSize/audio_buffer->adaptationSettings.defaultUnitSize);
                }
            }
        }
        else
        {
            audio_buffer->adaptationSettings.delayTimes.first = 0;
            audio_buffer->adaptationSettings.delayTimes.last = 0;
            audio_buffer->adaptationSettings.delayTimes.count = 0;
            audio_buffer->adaptationSettings.delayCnt = 0;
        }

        audio_buffer->adaptationSettings.time = time;
    }
    else if((time - audio_buffer->adaptationSettings.time) > 5000)
    {
        if(audio_buffer->adaptationSettings.currentUnitSize > DEFAULT_DECREASE_COUNT * audio_buffer->adaptationSettings.defaultUnitSize)
        {
            audio_buffer->adaptationSettings.currentUnitSize -= DEFAULT_DECREASE_COUNT * audio_buffer->adaptationSettings.defaultUnitSize;
            audio_buffer->adaptationSettings.time = time;

            fprintf(stderr, "calculateAdaptiveUnitSize1: DECREASE delayCnt = %d unitSize = %d\n", audio_buffer->adaptationSettings.delayCnt, audio_buffer->adaptationSettings.currentUnitSize/audio_buffer->adaptationSettings.defaultUnitSize);
        }
    }
}

int counter = 0, strcounter=0, strcounter1 = 0, flushed = 0;
int put_audio_buffer(media_audio_buffer_t* audio_buffer, uint8_t* data, int size, int recvSize)
{
    int bufSize, rv = 0, compressDataSize;
    
    if (!audio_buffer)
        return -1;
    
    bufSize = audio_buffer->dataSize;
    
    uint64_t current_time = TBI_time_epoch();
    if(audio_buffer->lastPutTime == 0)
        audio_buffer->lastPutTime = current_time;
    
    media_audio_buffer_checkInteraptions(audio_buffer, current_time, current_time - audio_buffer->lastPutTime);
    audio_buffer->lastPutTime = current_time;
    
    low_pass_filter_push_back(audio_buffer, data, size);
    
    float fTime = (float)bufSize/(float)audio_buffer->chunckSize * (float)audio_buffer->pTime;

#if IS_SOUND_STRETCHING_ON
///////////////////////////////////////////////////
    int dataSize = 0;
    if(fTime > 1000)
    {
        fprintf (stderr, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
        rv = erase_front_audio_recv_data(audio_buffer, 10);
        OSAtomicAdd32(0 - rv, &audio_buffer->dataSize);
    }

//    calculateAdaptiveUnitSize1(audio_buffer, recvSize);
    
    int endSize = timeMS2BufferSize(DEFAULT_BUFEND_TIME, audio_buffer->rate, 1, 2);
    int unitSize = calculateUnitSize(audio_buffer->adaptationSettings.defaultUnitSize, bufSize, audio_buffer->stabBuffer.sBufferSize, size - endSize);
    float unitTime = bufferSize2TimeMS(unitSize, audio_buffer->rate, 1, 2);
    float unitMaxTime = media_audio_buffer_getIncreaseSizeByInteraptions(audio_buffer) * DEFAULT_UNIT_TIME + bufferSize2TimeMS(audio_buffer->adaptationSettings.currentUnitSize, audio_buffer->rate, 1, 2) + 4;

    tbi_bool_t bIsLesser = (recvSize  < 3 * audio_buffer->chunckSize + DEFAULT_RECVSIZE_COIFF);
    if((unitTime > unitMaxTime) &&  bIsLesser)
    {
        if(audio_buffer->lastCheckCnt >= 7)
        {
            float fTempo = 0;
            if(bIsLesser)
                fTempo = (unitTime > 350) ? 20.f : 15.f;
            
            compressDataSize = process_SoundTouchWraper(audio_buffer->soundEffect, data, size, &audio_buffer->compressData, &audio_buffer->compressDataMaxSize, fTempo);

            dataSize += compressDataSize;
            rv = push_back_audio_recv_data(audio_buffer, audio_buffer->compressData, compressDataSize, audio_buffer->bIsFlushed);
            audio_buffer->bIsFlushed = tbi_false;
            audio_buffer->nFlushedCnt = 0;
            strcounter++;
        }
        else
        {
            dataSize = push_back_audio_recv_data(audio_buffer, data, size, tbi_false);
            counter++;
            audio_buffer->lastCheckCnt++;
        }
    }
    else
    {
        if(!audio_buffer->bIsFlushed || audio_buffer->nFlushedCnt < 1)
        {
            compressDataSize = process_with_flush_SoundTouchWraper1(audio_buffer->soundEffect, data, size, &audio_buffer->compressData, &audio_buffer->compressDataMaxSize, 0);
            dataSize = push_back_audio_recv_data(audio_buffer, audio_buffer->compressData, compressDataSize, tbi_false);
            audio_buffer->bIsFlushed = tbi_true;
            audio_buffer->nFlushedCnt++;
            flushed++;
        }
        else
        {
            dataSize = push_back_audio_recv_data(audio_buffer, data, size, tbi_false);
            counter++;
        }
        
        audio_buffer->lastCheckCnt = 0;
    }
//    fprintf(stderr, "count = %d pressed = %d flused = %d | buffer = %.3f (%d) sb = %d\n", counter, strcounter, flushed, fTime, bufSize, audio_buffer->stabBuffer.sBufferSize);
#else
    rv = audio_buffer_write(audio_buffer, data, size, tbi_true);
#endif //IS_SOUND_STRETCHING_ON

    return rv;
}

int put_audio_buffer1(media_audio_buffer_t* audio_buffer, uint8_t* data, int size, int recvSize)
{
    int bufSize, rv = 0, compressDataSize;
    
    if (!audio_buffer)
        return -1;
    
    if(audio_buffer->startDroping){
        
        long long currentdelay = TBI_time_epoch() - audio_buffer->lastPaskage;
        printf("----- %lli",currentdelay);
        if(audio_buffer->startDroping>1){
            if(currentdelay > DROPING_DELAY){
                audio_buffer->startDroping = 0;
                return 0;
            }
        }
        printf(" ----- DROP \n");
        audio_buffer->lastPaskage = TBI_time_epoch();
        audio_buffer->startDroping++;
        return 0;
    }
    
    bufSize = audio_buffer->dataSize;
    
    uint64_t current_time = TBI_time_epoch();
    if(audio_buffer->lastPutTime == 0)
        audio_buffer->lastPutTime = current_time;
    
    media_audio_buffer_checkInteraptions(audio_buffer, current_time, current_time - audio_buffer->lastPutTime);
    audio_buffer->lastPutTime = current_time;
    
//    low_pass_filter_push_back(audio_buffer, data, size);
    
    float fTime = (float)bufSize/(float)audio_buffer->chunckSize * (float)audio_buffer->pTime;
    
#if IS_SOUND_STRETCHING_ON
    ///////////////////////////////////////////////////
    int dataSize = 0;
    if(fTime > 1000)
    {
        fprintf (stderr, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
        rv = erase_front_audio_recv_data(audio_buffer, 10);
        OSAtomicAdd32(0 - rv, &audio_buffer->dataSize);
    }
    
    calculateAdaptiveUnitSize1(audio_buffer, recvSize);
    
    int endSize = timeMS2BufferSize(DEFAULT_BUFEND_TIME, audio_buffer->rate, 1, 2);
    int unitSize = calculateUnitSize(audio_buffer->adaptationSettings.currentUnitSize, bufSize, audio_buffer->stabBuffer.sBufferSize, size - endSize);
    float unitTime = bufferSize2TimeMS(unitSize, audio_buffer->rate, 1, 2);
    float unitMaxTime = (audio_buffer->frameCnt + 1) * bufferSize2TimeMS(audio_buffer->adaptationSettings.currentUnitSize, audio_buffer->rate, 1, 2) + 4;
    
    tbi_bool_t bIsLesser = (recvSize  < 3 * audio_buffer->chunckSize + DEFAULT_RECVSIZE_COIFF);
    if( (unitTime > unitMaxTime) &&  bIsLesser)
    {
        if(audio_buffer->lastCheckCnt >= 7)
        {
            float fTempo = 0;
            if(bIsLesser)
                fTempo = (unitTime > 350) ? 20.f : 15.f;
            
            compressDataSize = process_SoundTouchWraper(audio_buffer->soundEffect, data, size, &audio_buffer->compressData, &audio_buffer->compressDataMaxSize, fTempo);
            
            dataSize += compressDataSize;
            rv = push_back_audio_recv_data(audio_buffer, audio_buffer->compressData, compressDataSize, audio_buffer->bIsFlushed);
            audio_buffer->bIsFlushed = tbi_false;
            audio_buffer->nFlushedCnt = 0;
            strcounter++;
        }
        else
        {
            dataSize = push_back_audio_recv_data(audio_buffer, data, size, tbi_false);
            counter++;
            audio_buffer->lastCheckCnt++;
        }
    }
    else
    {
        if(!audio_buffer->bIsFlushed || audio_buffer->nFlushedCnt < 1)
        {
            compressDataSize = process_with_flush_SoundTouchWraper1(audio_buffer->soundEffect, data, size, &audio_buffer->compressData, &audio_buffer->compressDataMaxSize, 0);
            dataSize = push_back_audio_recv_data(audio_buffer, audio_buffer->compressData, compressDataSize, tbi_false);
            audio_buffer->bIsFlushed = tbi_true;
            audio_buffer->nFlushedCnt++;
            flushed++;
        }
        else
        {
            dataSize = push_back_audio_recv_data(audio_buffer, data, size, tbi_false);
            counter++;
        }
        
        audio_buffer->lastCheckCnt = 0;
    }
//    fprintf(stderr, "count = %d pressed = %d flused = %d | buffer = %.3f (%d) sb = %d\n", counter, strcounter, flushed, fTime, bufSize, audio_buffer->stabBuffer.sBufferSize);
#else
    rv = audio_buffer_write(audio_buffer, data, size, tbi_true);
#endif //IS_SOUND_STRETCHING_ON
    
    return rv;
}

int pop_audio_buffer(media_audio_buffer_t* audio_buffer, uint8_t* data, int size)
{
    if (!audio_buffer)
        return 0;
    
    memset(data, 0, size);
    int rvSize = pop_first_audio_recv_data(audio_buffer, data, size);
    OSAtomicAdd32(0 - rvSize, &audio_buffer->dataSize);
    
    if( rvSize < size )
    {
//        printf("silence ==== %d sb ==== %d\n", size - rvSize, audio_buffer->stabBuffer.sBufferSize);
//        TBI_semaphore_increment(audio_buffer->lowPassBuffer.sem);
    }

//    int bufSize = audio_buffer->dataSize;
//    int sbSize = audio_buffer->stabBuffer.sBufferSize;
    
//    float fTime = (float)bufSize/(float)audio_buffer->chunckSize * (float)audio_buffer->pTime;
//    float sTime = (float)sbSize/(float)audio_buffer->chunckSize * (float)audio_buffer->pTime;
    
//    fprintf(stderr, "bufTime %.3f full time %.3f\n", fTime, fTime + sTime);
//    fprintf(stderr, "buffer time = %.3f (%d) sb = %.3f (%d) full time %.3f\n", fTime, bufSize, sTime, audio_buffer->stabBuffer.sBufferSize, fTime + sTime);
    
    return size;
}

void media_audio_buffer_checkInteraptions(media_audio_buffer_t* audio_buffer, uint64_t current_time, uint32_t deltaTime)
{
//    media_audio_interraption_t* firstInt = 0;
    static int gr700 = 0;

    if(deltaTime > 60 + 70)
    {
        media_audio_interraption_t* interrupt = TBI_object_new(media_audio_interraption_def_t);
        interrupt->delayedTime = deltaTime - 60;
        interrupt->timestamp = current_time;
        
        if(interrupt->delayedTime <= 700)
        {
            TBI_list_push_back_data(audio_buffer->interraptionChecker.interraptions, (void**)&interrupt);
        }
        else
        {
            gr700++;
        }
    }

    TBI_list_item_t* item = audio_buffer->interraptionChecker.interraptions ? audio_buffer->interraptionChecker.interraptions->head : TBI_null;
    if(item && item->next)
    {
        audio_buffer->interraptionChecker.rangeLow120 = 0;
        audio_buffer->interraptionChecker.range120_180 = 0;
        audio_buffer->interraptionChecker.range180_240 = 0;
        audio_buffer->interraptionChecker.range240_300 = 0;
        audio_buffer->interraptionChecker.range300_400 = 0;
        audio_buffer->interraptionChecker.range400_700 = 0;
        
        while( item )
        {
            if(item->data)
            {
                media_audio_interraption_t* pInt = (media_audio_interraption_t*)item->data;
                if(current_time - pInt->timestamp >= 10000)
                {
                    TBI_list_remove_item(audio_buffer->interraptionChecker.interraptions, item);
                    item = audio_buffer->interraptionChecker.interraptions->head;
                }
                else
                {
                    if(pInt->delayedTime <= 120)
                        audio_buffer->interraptionChecker.rangeLow120++;
                    else if (pInt->delayedTime > 120 && pInt->delayedTime <= 180)
                        audio_buffer->interraptionChecker.range120_180++;
                    else if (pInt->delayedTime > 180 && pInt->delayedTime <= 240)
                        audio_buffer->interraptionChecker.range180_240++;
                    else if (pInt->delayedTime > 240 && pInt->delayedTime <= 300)
                        audio_buffer->interraptionChecker.range240_300++;
                    else if (pInt->delayedTime > 300 && pInt->delayedTime <= 400)
                        audio_buffer->interraptionChecker.range300_400++;
                    else if (pInt->delayedTime > 400 && pInt->delayedTime <= 700)
                        audio_buffer->interraptionChecker.range400_700++;

                    item = item->next;
                }
            }
        }
    }
    
//    native_debug_function("< 120 = %d | 120 - 180 = %d | 180 - 240 = %d | 240 - 300 = %d | 300 - 400 = %d | 400 - 700 = %d | > 700 = %d",
//                          audio_buffer->interraptionChecker.rangeLow120,
//                          audio_buffer->interraptionChecker.range120_180,
//                          audio_buffer->interraptionChecker.range180_240,
//                          audio_buffer->interraptionChecker.range240_300,
//                          audio_buffer->interraptionChecker.range300_400,
//                          audio_buffer->interraptionChecker.range400_700,
//                          gr700
//                          );
}

uint32_t media_audio_buffer_getIncreaseSizeByInteraptions(media_audio_buffer_t* audio_buffer)
{
    if(!audio_buffer)
        return 1;
    
    if(audio_buffer->interraptionChecker.range400_700 > 1)
        return 11;//13;
    else if(audio_buffer->interraptionChecker.range300_400 > 1 ||
            (audio_buffer->interraptionChecker.range300_400 > 0 &&
             audio_buffer->interraptionChecker.range400_700 > 0))
        return 8;//9;
    else if(audio_buffer->interraptionChecker.range240_300 > 1 ||
            (audio_buffer->interraptionChecker.range240_300 > 0 &&
             (audio_buffer->interraptionChecker.range300_400 > 0 ||
              audio_buffer->interraptionChecker.range400_700 > 0)))
        return 6;//7;
    else if(audio_buffer->interraptionChecker.range180_240 > 1 ||
            (audio_buffer->interraptionChecker.range180_240 > 0 &&
             (audio_buffer->interraptionChecker.range240_300 > 0 ||
              audio_buffer->interraptionChecker.range300_400 > 0 ||
              audio_buffer->interraptionChecker.range400_700 > 0)))
        return 4;//5;
    else if(audio_buffer->interraptionChecker.range120_180 > 1 ||
            (audio_buffer->interraptionChecker.range120_180 > 0 &&
             (audio_buffer->interraptionChecker.range180_240 > 0 ||
              audio_buffer->interraptionChecker.range240_300 > 0 ||
              audio_buffer->interraptionChecker.range300_400 > 0 ||
              audio_buffer->interraptionChecker.range400_700 > 0)))
        return 3;//4;
    else if(audio_buffer->interraptionChecker.rangeLow120 > 1 ||
            (audio_buffer->interraptionChecker.rangeLow120 > 0 &&
             (audio_buffer->interraptionChecker.range120_180 > 0 ||
              audio_buffer->interraptionChecker.range180_240 > 0 ||
              audio_buffer->interraptionChecker.range240_300 > 0 ||
              audio_buffer->interraptionChecker.range300_400 > 0 ||
              audio_buffer->interraptionChecker.range400_700 > 0)))
        return 1;//2;
    
    return 1;
}

void reset_statistics(media_audio_buffer_t* audio_buffer)
{
    audio_buffer->statistics.fullTime = 0;
    audio_buffer->statistics.bufferTime = 0;
    audio_buffer->statistics.silenceTime = 0;
    audio_buffer->statistics.silenceTimePerSecond = 0;
    audio_buffer->statistics.startTime = 0;
}

void print_statistics(media_audio_buffer_t* audio_buffer)
{
    if(audio_buffer)
    {
        TBI_DEBUG_AUDIO("Statistics: =================\n");
        TBI_DEBUG_AUDIO("Full time:               %f msec\n", audio_buffer->statistics.fullTime);
        TBI_DEBUG_AUDIO("Buffer time:             %f msec\n", audio_buffer->statistics.bufferTime);
        TBI_DEBUG_AUDIO("Silence time:            %f msec\n", audio_buffer->statistics.silenceTime );
        TBI_DEBUG_AUDIO("Silence time per second: %f msec\n", audio_buffer->statistics.silenceTimePerSecond );
        TBI_DEBUG_AUDIO("Default bottom:          %f msec\n", audio_buffer->def_bottom );
        TBI_DEBUG_AUDIO("=============================\n");
    }
}

void print_calls_interval(media_audio_buffer_t* audio_buffer)
{
    if(audio_buffer)
    {
        long curTime = TBI_time_epoch();
        if(audio_buffer->startTime == 0)
            audio_buffer->startTime = curTime;
        
        fprintf(stderr, "Interval between calls: %lld\n", curTime - audio_buffer->startTime);
        audio_buffer->startTime = curTime;
    }
}


//audio_recv_data_t ==============================================================================================
audio_recv_data_t* create_audio_recv_data()
{
    audio_recv_data_t* data = (audio_recv_data_t*)malloc(sizeof(audio_recv_data_t));

    data->buffer = 0;
    data->size = 0;
    data->readPos = 0;

    data->bufferEnd = 0;

    data->bufferEndCorrected = 0;
    data->bufferEndCorrectedMaxSize = 0;

    data->endReadPos = 0;
    data->endSize = 0;

    data->bIsLocked = 0;
    data->next = 0;
    
    data->bIsStartSilenced = tbi_false;
    
    data->time = TBI_time_epoch();

    return data;
}

void destoy_audio_recv_data(audio_recv_data_t** data)
{
    if(!data || !(*data))
        return;
    
    if((*data)->buffer)
    {
        free((*data)->buffer);
        (*data)->buffer = 0;
    }
    (*data)->size = 0;

    if((*data)->bufferEnd)
    {
        free((*data)->bufferEnd);
        (*data)->bufferEnd = 0;
    }
    
    if((*data)->bufferEndCorrected)
    {
        free((*data)->bufferEndCorrected);
        (*data)->bufferEndCorrected = 0;
    }
    
    (*data)->endSize = 0;
    free(*data);
    *data = 0;
}

int calculateUnitSize(int unitSize, int bufSize, int sbufSize, int addSize)
{
    int unitCnt = (bufSize + sbufSize + addSize)/unitSize;
    return unitCnt * unitSize;
}

int push_back_audio_recv_data(media_audio_buffer_t* audio_buffer, const uint8_t* buffer, int size, tbi_bool_t bIsSilenced)
{
    int endSize = timeMS2BufferSize(DEFAULT_BUFEND_TIME, audio_buffer->rate, 1, 2);
    int bufSize = audio_buffer->dataSize;
    int tmpSize = 0;
    int dS, tS;

    int unitSize = calculateUnitSize(audio_buffer->adaptationSettings.defaultUnitSize, bufSize, audio_buffer->stabBuffer.sBufferSize, size - endSize);
    int reqSize = unitSize - bufSize;

//    fprintf(stderr, "recv: %d buffer: %d data: %d end: %d SB: %d\n", size, bufSize, reqSize, endSize, audio_buffer->stabBuffer.sBufferSize);

    if(reqSize <= 0)
    {
        if(!audio_buffer->stabBuffer.sBuffer || (audio_buffer->stabBuffer.sBufferMaxSize < (audio_buffer->stabBuffer.sBufferSize + size)))
        {
            audio_buffer->stabBuffer.sBufferMaxSize = audio_buffer->stabBuffer.sBufferSize + size;
            audio_buffer->stabBuffer.sBuffer = realloc(audio_buffer->stabBuffer.sBuffer, audio_buffer->stabBuffer.sBufferMaxSize);
        }
        
        if(audio_buffer->stabBuffer.sBufferSize > 0 && bIsSilenced)
        {
            int overlapLen = timeMS2BufferSize(DEFAULT_OVERLAP_TIME, audio_buffer->rate, 1, 2);
            overlapLen = overlapLen < audio_buffer->stabBuffer.sBufferSize ? overlapLen : audio_buffer->stabBuffer.sBufferSize;
            overlapMonoDown((short*)(audio_buffer->stabBuffer.sBuffer + (audio_buffer->stabBuffer.sBufferSize - overlapLen)),
                            (const short*)(audio_buffer->stabBuffer.sBuffer + (audio_buffer->stabBuffer.sBufferSize - overlapLen)), overlapLen/sizeof(short));
        }
        
        memcpy(audio_buffer->stabBuffer.sBuffer + audio_buffer->stabBuffer.sBufferSize, buffer, size);
        audio_buffer->stabBuffer.sBufferSize += size;
        
        return size;
    }
    
    audio_recv_data_t* data = create_audio_recv_data();
    OSAtomicIncrement32(&data->bIsLocked);
    
    data->size = 0;
    dS = reqSize;
    tS = 0;
    data->buffer = malloc(reqSize);
    if(audio_buffer->stabBuffer.sBuffer && audio_buffer->stabBuffer.sBufferSize > 0)
    {
        data->size = (reqSize < audio_buffer->stabBuffer.sBufferSize) ? reqSize : audio_buffer->stabBuffer.sBufferSize;
        memcpy(data->buffer, audio_buffer->stabBuffer.sBuffer, data->size);
        tS = data->size;
        audio_buffer->stabBuffer.sBufferSize -= data->size;
        if(audio_buffer->stabBuffer.sBufferSize > 0)
            memmove(audio_buffer->stabBuffer.sBuffer, audio_buffer->stabBuffer.sBuffer + data->size, audio_buffer->stabBuffer.sBufferSize);
        
        reqSize -= data->size;
    }
    
    if(data->size > 0 && bIsSilenced)
    {
        int overlapLen = timeMS2BufferSize(DEFAULT_OVERLAP_TIME, audio_buffer->rate, 1, 2);
        overlapLen = overlapLen < data->size ? overlapLen : data->size;
        
        overlapMonoDown((short*)(data->buffer + (data->size - overlapLen)), (short*)(data->buffer + (data->size - overlapLen)), overlapLen/sizeof(short));
        bIsSilenced = tbi_false;
    }

    tmpSize = 0;
    if(reqSize > 0)
    {
        memcpy(data->buffer + data->size, buffer, reqSize);
        tS += reqSize;
        data->size += reqSize;
        tmpSize = reqSize;
        reqSize = 0;
    }

    if(tS > dS)
        fprintf(stderr, "data size = %d allocated size = %d\n", dS, tS);
    
    data->endSize = 0;
    if(endSize > 0)
    {
        data->bufferEnd = malloc(endSize);
        if(audio_buffer->stabBuffer.sBufferSize > 0)
        {
            data->endSize = endSize < audio_buffer->stabBuffer.sBufferSize ? endSize : audio_buffer->stabBuffer.sBufferSize;
            memcpy(data->bufferEnd, audio_buffer->stabBuffer.sBuffer, data->endSize);
            audio_buffer->stabBuffer.sBufferSize -= data->endSize;
            if(audio_buffer->stabBuffer.sBufferSize > 0)
                memmove(audio_buffer->stabBuffer.sBuffer, audio_buffer->stabBuffer.sBuffer + data->endSize, audio_buffer->stabBuffer.sBufferSize);
        }
        
        if(data->endSize < endSize)
        {
            memcpy(data->bufferEnd + data->endSize, buffer + tmpSize, endSize - data->endSize);
            tmpSize += endSize - data->endSize;
            data->endSize = endSize;
        }

        data->bufferEndCorrected = malloc(data->endSize);
        overlapMonoDown((short*)data->bufferEndCorrected, (short*)data->bufferEnd, data->endSize/sizeof(short));
    }

//    fprintf(stderr, "END: requier: %d size: %d\n", endSize, data->endSize);
    
    data->seq = audio_buffer->seq++;
    data->bIsStartSilenced = bIsSilenced;
    
    audio_recv_data_list_push_back(&audio_buffer->audio_data_list, data);

    OSAtomicAdd32(data->size + data->endSize, &audio_buffer->dataSize);
    OSAtomicDecrement32(&data->bIsLocked);

    if(tmpSize < size)
    {
        int n = size - tmpSize;
        if(!audio_buffer->stabBuffer.sBuffer || (audio_buffer->stabBuffer.sBufferMaxSize < (audio_buffer->stabBuffer.sBufferSize + n)))
        {
            audio_buffer->stabBuffer.sBufferMaxSize = audio_buffer->stabBuffer.sBufferSize + n;
            audio_buffer->stabBuffer.sBuffer = realloc(audio_buffer->stabBuffer.sBuffer, audio_buffer->stabBuffer.sBufferMaxSize);
        }
        
        memcpy(audio_buffer->stabBuffer.sBuffer + audio_buffer->stabBuffer.sBufferSize, buffer + tmpSize, n);
        audio_buffer->stabBuffer.sBufferSize += n;
    }

//    fprintf(stderr, "recv: %d buffer: %d data: %d end: %d SB: %d\n", size, audio_buffer->dataSize, data->size, data->endSize, audio_buffer->stabBuffer.sBufferSize);

    return size;
}

int pop_first_audio_recv_data(media_audio_buffer_t* audio_buffer, uint8_t* buffer, int size)
{
    audio_recv_data_t* data = audio_buffer->audio_data_list.audio_recv_data_first;
    if(!data || data->bIsLocked)
        return 0;
    
    int writePos = 0, tmpSize = 0;
    if( data->size + data->endSize >= size )
    {
        if(data->size >= size)
        {
            memcpy(buffer, data->buffer + data->readPos, size);
            data->size -= size;
            data->readPos += size;
            writePos += size;
        }
        else
        {
            memcpy(buffer, data->buffer + data->readPos, data->size);
            data->readPos += data->size;
            writePos += data->size;
            data->size = 0;

            tmpSize = size - writePos;
            tmpSize = data->endSize < tmpSize ? data->endSize : tmpSize;

            if (data->next && data->next->bIsStartSilenced)
            {
                memcpy(buffer + writePos, data->bufferEndCorrected, tmpSize);
                data->endReadPos += tmpSize;
                data->endSize -= tmpSize;
                writePos += tmpSize;
            }
            else
            {
                memcpy(buffer + writePos, data->bufferEnd, tmpSize);
                data->endReadPos += tmpSize;
                data->endSize -= tmpSize;
                writePos += tmpSize;
            }
        }
        
        if(audio_buffer->bIsSilenced)
        {
            if(!data->bIsStartSilenced)
            {
                int overlapLen = timeMS2BufferSize(DEFAULT_OVERLAP_TIME, audio_buffer->rate, 1, 2);
                overlapLen = overlapLen < writePos ? overlapLen : writePos;
                overlapMonoUp((short*)buffer, (short*)buffer, overlapLen/2);
            }
            OSAtomicDecrement32(&audio_buffer->bIsSilenced);
        }
    }
    else if(data->next && data->next->size > 0 && !data->next->bIsLocked)
    {
        if(data->size > 0)
        {
            memcpy(buffer, data->buffer + data->readPos, data->size);
            writePos += data->size;
            data->size = 0;
        }

        if(data->endSize > 0)
        {
            if(audio_buffer->bIsSilenced || (data->next && data->next->bIsStartSilenced))
            {
                memcpy(buffer + writePos, data->bufferEndCorrected + data->endReadPos, data->endSize);
                writePos += data->endSize;
                data->endSize = 0;
            }
            else
            {
                memcpy(buffer + writePos, data->bufferEnd + data->endReadPos, data->endSize);
                writePos += data->endSize;
                data->endSize = 0;
            }
        }
    
        audio_buffer->audio_data_list.audio_recv_data_first = data->next;
        destoy_audio_recv_data(&data);
        
        if(writePos < size)
        {
            writePos += pop_first_audio_recv_data(audio_buffer, buffer + writePos, size - writePos);
        }
    }
    else
    {
        if(data->size > 0)
        {
            memcpy(buffer, data->buffer + data->readPos, data->size);
            data->readPos += data->size;
            writePos += data->size;
            data->size = 0;
        }

        if(data->endSize > 0)
        {
            int tmpSize = size - writePos;
            tmpSize = tmpSize > data->endSize ? data->endSize : tmpSize;
            memcpy(buffer + writePos, data->bufferEndCorrected + data->endReadPos, tmpSize);
            data->endReadPos += tmpSize;
            writePos += data->endSize;
            data->endSize -= tmpSize;

            if(audio_buffer->bIsSilenced == 0)
                OSAtomicIncrement32(&audio_buffer->bIsSilenced);
        }
    }
    return writePos;
}

int erase_front_audio_recv_data(media_audio_buffer_t* audio_buffer, int count)
{
    int i = 0, size = 0;
    while (audio_buffer->audio_data_list.audio_recv_data_first && i < count)
    { 
        audio_recv_data_t* data = audio_buffer->audio_data_list.audio_recv_data_first;
        OSAtomicIncrement32(&data->bIsLocked);
        audio_buffer->audio_data_list.audio_recv_data_first = audio_buffer->audio_data_list.audio_recv_data_first->next;
        OSAtomicDecrement32(&data->bIsLocked);
        size += data->size + data->endSize;
        destoy_audio_recv_data(&data);
        i++;
    }
    
    if(!audio_buffer->audio_data_list.audio_recv_data_first)
        audio_buffer->audio_data_list.audio_recv_data_last = 0;
    
    return size;
}

//low pass filter =======================================
#include <math.h>

void overlapMonoUp(short *pOutput, const short *pInput, int overlapLength)
{
    int i;
    short m1;
    
    m1 = (short)0;
    
    for (i = 0; i < overlapLength ; i ++)
    {
        pOutput[i] = (pInput[i] * m1) / overlapLength;
        m1 += 1;
    }
}

void overlapMonoDown(short *pOutput, const short *pInput, int overlapLength)
{
    int i;
    short m1;
    
    m1 = (short)overlapLength;
    
    for (i = 0; i < overlapLength ; i ++)
    {
        pOutput[i] = (pInput[i] * m1) / overlapLength;
        m1 -= 1;
    }
}

void Filter (const float* in, float* out, int sizeIn)
{
    const int N = 20;
    long double Fd = 2000;
    long double Fs = 20;
    long double Fx = 50;
    
    long double H [N] = {0};
    long double H_id [N] = {0};
    long double W [N] = {0};
    
    double Fc = (Fs + Fx) / (2 * Fd);
    
    for (int i = 0; i < N; i++)
    {
        if (i == 0)
            H_id[i] = 2 * M_PI * Fc;
        else
            H_id[i] = sinl(2 * M_PI * Fc * i )/(M_PI * i);
        
        W [i] = 0.42 - 0.5 * cosl((2*M_PI*i) /( N-1)) + 0.08 * cosl((4*M_PI*i) /( N-1));
        H [i] = H_id[i] * W[i];
    }
    
    double SUM=0;
    for (int i = 0; i < N; i++)
        SUM += H[i];
    for (int i = 0; i < N; i++)
        H[i] /= SUM;
    
    for (int i = 0; i < sizeIn; i++)
    {
        out[i]=0.;
        for (int j = 0; j < N-1; j++)
        {
            out[i] += H[j] * in[i-j];
        }
    }
}

void smoothArray( float* in, int inSize, float* out, float *pf, float smoothing )
{
    int n = 0;
    float value;
    if(!pf)
    {
        value = out[0] = in[0];
        n = 1;
    }
    else
        value = *pf;
    
    for (int i = n; i < inSize - 640; ++i)
    {
        value += (in[i] - value) / smoothing;
        out[i] = value;
    }
    
    int j = 0;
    for (int i = inSize - 640; i < inSize; ++i, ++j)
    {
        if(j && !(j%32))
            smoothing--;
        
        if(!smoothing)
            printf("!smoothing");
        
        value += (in[i] - value) / smoothing;
        out[i] = value;
    }
}

float gf, *gpf = 0;

int lowPassFilterEx(uint8_t* in, int inSize, uint8_t** out, int* outMaxSize)
{
    float floatBuffer[16000];
    float floatOut[16000];
    int floatBufSize = 0;
    int wp = 0;
    int i, j;
    
    for (i = 0, j = 0; i < inSize; i+=2, j++)
    {
        floatBuffer[j] = short2float(*((short*)&in[i]));
    }
    floatBufSize = j;
    
//    Filter (floatBuffer, floatOut, floatBufSize);
    smoothArray( floatBuffer, floatBufSize, floatOut, gpf, 20);
    if(!(*out) || *outMaxSize < inSize)
    {
        *outMaxSize = inSize;
        *out = realloc(*out, *outMaxSize);
    }
    
    for (i = 0; i < floatBufSize; i++, wp += 2)
    {
        *((short*)(*out + wp)) = float2short(floatOut[i]);
    }
    
    if(!gpf)
        gpf = &gf;
    
    *gpf = floatOut[floatBufSize - 1];
    
    return inSize;
}

int lowPassFilterEx2(uint8_t* in, int inSize, uint8_t** out, int* outMaxSize, float k, int overlapLen)
{
    float floatBuffer[16000];
    float floatOut[16000];
    int pos = 0, sz = 0, wp = 0;
    int floatBufSize = 0;
    int i, j, n;
    int calcSz = 0, calcFSz = 0;
    
    for (i = 0, j = 0; i < inSize; i+=2, j++)
    {
        floatBuffer[j] = short2float(*((short*)&in[i]));
    }
    
    floatBufSize = j;
    calcSz = inSize;
    calcFSz = floatBufSize;
    
    Filter (floatBuffer, floatOut, floatBufSize);
    
    n = 0;
    while (n < 3)
    {
        sz += calcSz;
        if(!(*out) || *outMaxSize < sz)
        {
            *outMaxSize = sz;
            *out = realloc(*out, *outMaxSize);
        }
        
        for (i = pos; i < floatBufSize - pos; i++, wp += 2)
        {
            *((short*)(*out + wp)) = float2short(floatOut[i]);
        }
        
        calcSz = calcSz * k;
        calcFSz = calcFSz * k;
        pos = (floatBufSize - calcFSz);
        n++;
    }
    
    return sz;
}

int lowPassFilterEx1(short* in, int inSize, short** out, int* outMaxSize, float k, int overlapLen)
{
    int pos = 0, sz = 0, wp = 0;
    float time = (float)inSize/8;
    while (time > 20)
    {
        sz += time * 8;
        if(*outMaxSize < sz)
        {
            *outMaxSize = sz;
            *out = (short*)realloc(*out, *outMaxSize * sizeof(short));
        }
        
        for (int i = 0; i < inSize - pos; i++)
        {
            (*out + wp)[i] = (in + pos)[i];
        }
        
        overlapMonoUp(*out + wp, *out + wp, overlapLen);
        overlapMonoDown(*out + (sz - overlapLen), *out + (sz - overlapLen), overlapLen);
        
        time = time * k;
        pos = (inSize - time*8);
        wp = sz;
    }
    
    return sz;
}

void low_pass_filter_push_back(media_audio_buffer_t* audio_buffer, uint8_t* data, int size)
{
    if(!audio_buffer || !data || !size)
        return;
    
//    fprintf(stderr, "low_pass_filter_push_back: OSSpinLockLock\n");
//    while(audio_buffer->lowPassBuffer.locker&0x02)
//        usleep(5000);

//    OSAtomicOr32(0x01, &audio_buffer->lowPassBuffer.locker);
    
    if( audio_buffer->lowPassBuffer.nRead )
    {
        audio_buffer->lowPassBuffer.writePos = 0;
        audio_buffer->lowPassBuffer.lowPassBufReadPos = 0;
        audio_buffer->lowPassBuffer.lowPassBufSize = 0;
        audio_buffer->lowPassBuffer.nRead = 0;
        audio_buffer->lowPassBuffer.nReadBufSize = audio_buffer->lowPassBuffer.size;
    }

    int overflow = 0;
    if(audio_buffer->lowPassBuffer.writePos + size > audio_buffer->lowPassBuffer.size)
    {
        overflow = audio_buffer->lowPassBuffer.writePos + size - audio_buffer->lowPassBuffer.size;
        audio_buffer->lowPassBuffer.writePos -= overflow;
        memmove(audio_buffer->lowPassBuffer.buffer, audio_buffer->lowPassBuffer.buffer + overflow, audio_buffer->lowPassBuffer.writePos);
        if(audio_buffer->lowPassBuffer.lowPassBufReadPos > overflow)
            audio_buffer->lowPassBuffer.lowPassBufReadPos -= overflow;
        else
            audio_buffer->lowPassBuffer.lowPassBufReadPos = 0;
    }
    
    memcpy(audio_buffer->lowPassBuffer.buffer + audio_buffer->lowPassBuffer.writePos, data, size);
    audio_buffer->lowPassBuffer.writePos += size;
    audio_buffer->lowPassBuffer.lowPassBufSize = audio_buffer->lowPassBuffer.writePos;
    
//    if(audio_buffer->lowPassBuffer.writePos == audio_buffer->lowPassBuffer.size)
//    {
//        audio_buffer->lowPassBuffer.lowPassBufSize =
//            lowPassFilterEx(audio_buffer->lowPassBuffer.buffer, audio_buffer->lowPassBuffer.size,
//                            &audio_buffer->lowPassBuffer.lowPassBuf, &audio_buffer->lowPassBuffer.lowPassBufMaxSize, 0.6, 0);
//
//        audio_buffer->lowPassBuffer.lowPassBufReadPos = 0;
//   }
    
//    fprintf(stderr, "low_pass_filter_push_back: OSSpinLockUnlock\n");
//    OSAtomicAnd32(0xFFFFFFFE, &audio_buffer->lowPassBuffer.locker);
}

int low_pass_filter_pop_front(media_audio_buffer_t* audio_buffer, uint8_t* data, int size)
{
    if(!audio_buffer)
        return 0;
    
    int overlapLen = timeMS2BufferSize(DEFAULT_OVERLAP_TIME, audio_buffer->rate, 1, 2);
    
    //    OSAtomicOr32(0x02, &audio_buffer->lowPassBuffer.locker);
    if(audio_buffer->lowPassBuffer.writePos == audio_buffer->lowPassBuffer.size)
    {
        if(audio_buffer->lowPassBuffer.nRead == 0)
        {
            audio_buffer->lowPassBuffer.lowPassBufSize =
            lowPassFilterEx(audio_buffer->lowPassBuffer.buffer, audio_buffer->lowPassBuffer.size,
                            &audio_buffer->lowPassBuffer.lowPassBuf, &audio_buffer->lowPassBuffer.lowPassBufMaxSize);
            
            overlapMonoDown((short*)audio_buffer->lowPassBuffer.buffer + audio_buffer->lowPassBuffer.lowPassBufSize - overlapLen,
                            (const short*)audio_buffer->lowPassBuffer.buffer + audio_buffer->lowPassBuffer.lowPassBufSize - overlapLen, overlapLen/sizeof(short));
            
        }
        
        if(audio_buffer->lowPassBuffer.nRead < 3 && audio_buffer->lowPassBuffer.lowPassBuf && audio_buffer->lowPassBuffer.lowPassBufSize > 0 && audio_buffer->dataSize == 0)
        {
            uint8_t* p = audio_buffer->lowPassBuffer.lowPassBuf + audio_buffer->lowPassBuffer.lowPassBufReadPos;
            overlapMonoUp((short*)p, (const short*)p, overlapLen/sizeof(short));
            
            push_back_audio_recv_data(audio_buffer, p, audio_buffer->lowPassBuffer.lowPassBufSize, tbi_true);
            
            audio_buffer->lowPassBuffer.lowPassBufReadPos += audio_buffer->lowPassBuffer.lowPassBufSize * (1 - 0.6);
            audio_buffer->lowPassBuffer.lowPassBufSize = audio_buffer->lowPassBuffer.lowPassBufSize * 0.6;
            audio_buffer->lowPassBuffer.nRead++;
            audio_buffer->bIsAfterLowPass = tbi_true;
        }
    }

    //    OSAtomicAnd32(0xFFFFFFFD, &audio_buffer->lowPassBuffer.locker);
    return 0;
}

int low_pass_filter_pop_front2(media_audio_buffer_t* audio_buffer, uint8_t* data, int size)
{
    if(!audio_buffer || !data || !size)
        return 0;
    
    int overlapLen = timeMS2BufferSize(DEFAULT_OVERLAP_TIME, audio_buffer->rate, 1, 2);

//    OSAtomicOr32(0x02, &audio_buffer->lowPassBuffer.locker);
    if(audio_buffer->lowPassBuffer.writePos == audio_buffer->lowPassBuffer.size)
    {
        if(audio_buffer->lowPassBuffer.nRead == 0)
        {
            audio_buffer->lowPassBuffer.lowPassBufSize =
            lowPassFilterEx(audio_buffer->lowPassBuffer.buffer, audio_buffer->lowPassBuffer.size,
                            &audio_buffer->lowPassBuffer.lowPassBuf, &audio_buffer->lowPassBuffer.lowPassBufMaxSize);
            
            overlapMonoDown((short*)audio_buffer->lowPassBuffer.buffer + audio_buffer->lowPassBuffer.lowPassBufSize - overlapLen,
                            (const short*)audio_buffer->lowPassBuffer.buffer + audio_buffer->lowPassBuffer.lowPassBufSize - overlapLen, overlapLen/sizeof(short));
            
        }
    
        if(audio_buffer->lowPassBuffer.nRead < 3 && audio_buffer->lowPassBuffer.lowPassBuf && audio_buffer->lowPassBuffer.lowPassBufSize > 0)
        {
            uint8_t* p = audio_buffer->lowPassBuffer.lowPassBuf + audio_buffer->lowPassBuffer.lowPassBufReadPos;
            overlapMonoUp((short*)p, (const short*)p, overlapLen/sizeof(short));
            
            push_back_audio_recv_data(audio_buffer, p, audio_buffer->lowPassBuffer.lowPassBufSize, tbi_true);
            
            audio_buffer->lowPassBuffer.lowPassBufReadPos += audio_buffer->lowPassBuffer.lowPassBufSize * (1 - 0.6);
            audio_buffer->lowPassBuffer.lowPassBufSize = audio_buffer->lowPassBuffer.lowPassBufSize * 0.6;
            audio_buffer->lowPassBuffer.nRead++;
            audio_buffer->bIsAfterLowPass = tbi_true;
        }
    }
//    fprintf(stderr, "low_pass_filter_pop_front: OSSpinLockUnlock\n");
//    OSAtomicAnd32(0xFFFFFFFD, &audio_buffer->lowPassBuffer.locker);
    return 0;
}

int low_pass_filter_pop_front1(media_audio_buffer_t* audio_buffer, uint8_t* data, int size)
{
    if(!audio_buffer || !data || !size)
        return 0;
    
    OSAtomicOr32(0x02, &audio_buffer->lowPassBuffer.locker);
    
    int sz = 0;
    int sz1 = 0;
    if(audio_buffer->lowPassBuffer.nRead < 3 && audio_buffer->lowPassBuffer.lowPassBuf && audio_buffer->lowPassBuffer.lowPassBufSize >= audio_buffer->lowPassBuffer.nReadBufSize)
    {
        sz1 = audio_buffer->lowPassBuffer.nReadBufSize;
        
        if(audio_buffer->lowPassBuffer.lowPassBufSize >= (sz1 - sz))
        {
//            int overlapLen = timeMS2BufferSize(DEFAULT_OVERLAP_TIME, audio_buffer->rate, 1, 2);
            uint8_t* p = audio_buffer->lowPassBuffer.lowPassBuf + audio_buffer->lowPassBuffer.lowPassBufReadPos;
            
            //            overlapMonoUp((short*)p, (const short*)p, overlapLen/sizeof(short));
            //            overlapMonoDown((short*)(p + sz1 - sz - overlapLen), (const short*)(p + sz1 - sz - overlapLen), overlapLen/sizeof(short));
            
            push_back_audio_recv_data(audio_buffer, p, sz1 - sz, tbi_true);
            audio_buffer->lowPassBuffer.lowPassBufSize -= sz1 - sz;
            audio_buffer->lowPassBuffer.lowPassBufReadPos += sz1 - sz;
            audio_buffer->bIsAfterLowPass = tbi_true;
        }
        
        audio_buffer->lowPassBuffer.nRead++;
        audio_buffer->lowPassBuffer.nReadBufSize = audio_buffer->lowPassBuffer.nReadBufSize * 0.6;
    }
    
    //    fprintf(stderr, "low_pass_filter_pop_front: OSSpinLockUnlock\n");
    OSAtomicAnd32(0xFFFFFFFD, &audio_buffer->lowPassBuffer.locker);
    return sz;
}

//audio_recv_data_list ==================================
void audio_recv_data_list_pop_front(audio_recv_data_list_t* list, audio_recv_data_t* data)
{
    data = list->audio_recv_data_first;
    list->audio_recv_data_first = data->next;
}

void audio_recv_data_list_push_back(audio_recv_data_list_t* list, const audio_recv_data_t* data)
{
    if(list->audio_recv_data_last)
    {
        list->audio_recv_data_last->next = (audio_recv_data_t*)data;
        list->audio_recv_data_last = list->audio_recv_data_last->next;
    }
    else
    {
        list->audio_recv_data_last = (audio_recv_data_t*)data;
        if(!list->audio_recv_data_first)
            list->audio_recv_data_first = list->audio_recv_data_last;
    }
}

int audio_recv_data_list_get_size(audio_recv_data_list_t* list)
{
    audio_recv_data_t *data = list->audio_recv_data_first;
    int size = 0;
    while (data)
    {
        size += data->size + data->endSize;
        data = data->next;
    }
    
    return size;
}

void audio_recv_data_list_clear(audio_recv_data_list_t* list)
{
    audio_recv_data_t* data;
    while (list->audio_recv_data_first)
    {
        data = list->audio_recv_data_first;
        list->audio_recv_data_first = data->next;
        destoy_audio_recv_data(&data);
    }
}

//
//	Object definition for and media_video_frame instance
//
static TBI_object_t* media_audio_interraption_ctor(TBI_object_t * self, va_list * app)
{
	media_audio_interraption_t* inst = self;
	if(inst){
		TBI_safeobj_init(inst);
//        TBI_safeobj_lock(inst);
//        TBI_safeobj_unlock(inst);
	}
	return self;
}

static TBI_object_t* media_audio_interraption_dtor(TBI_object_t * self)
{
	media_audio_interraption_t* inst = self;
	if(inst){
//        TBI_safeobj_lock(inst);
//        TBI_safeobj_unlock(inst);
		TBI_safeobj_deinit(inst);
	}
	return self;
}

static const TBI_object_def_t media_audio_interraption_def_s =
{
	sizeof(media_audio_interraption_t),
	media_audio_interraption_ctor,
	media_audio_interraption_dtor,
	NULL,
};

const TBI_object_def_t *media_audio_interraption_def_t = &media_audio_interraption_def_s;















