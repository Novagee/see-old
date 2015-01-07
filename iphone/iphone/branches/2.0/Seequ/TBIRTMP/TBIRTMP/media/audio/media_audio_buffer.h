//
//  tdav_audio_buffer.h
//  ios-ngn-stack
//
//  Created by Administrator on 10/10/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#ifndef ios_ngn_stack_media_audio_buffer_h
#define ios_ngn_stack_media_audio_buffer_h

#include "tbi_config.h"
#include "types.h"
#include "TBI_mutex.h"
#include "TBI_list.h"
#include "TBI_semaphore.h"
#include "SoundTouch/SoundTouchWraper.h"

#define IS_SOUND_STRETCHING_ON      1

TBI_BEGIN_DECLS

typedef struct audio_recv_data_s
{
    uint8_t* buffer;
    int size;
    int readPos;
    uint8_t* bufferEnd;
    uint8_t* bufferEndCorrected;
    int bufferEndCorrectedMaxSize;
    int endReadPos;
    int endSize;
    
    uint64_t time;
    int seq;
    
    tbi_bool_t bIsStartSilenced;
    
    volatile int32_t bIsLocked;
    struct audio_recv_data_s* next;

} audio_recv_data_t;

typedef struct audio_recv_data_list_s
{
    audio_recv_data_t* audio_recv_data_first;
    audio_recv_data_t* audio_recv_data_last;

}audio_recv_data_list_t;

typedef struct Time_s
{
    uint64_t time;
    struct Time_s* next;
} Time_t;

typedef struct TimeArray_s
{
    Time_t* first;
    Time_t* last;
    int count;
    
} TimeArray_t;

typedef struct tdav_audio_buffer_s
{
    TBI_size_t  chunckSize;
    int         pTime;
    uint32_t    rate;
    uint32_t    frameCnt;
//    TBI_mutex_handle_t* mutex;
    
    struct
    {
        float fullTime;
        float bufferTime;
        float silenceTime;
        float silenceTimePerSecond;

        uint64_t startTime;

    } statistics;
    
    struct
    {
        uint8_t* sBuffer;
        int sBufferMaxSize;
        int sBufferSize;

    } stabBuffer;

    struct
    {
        uint8_t* buffer;
        int size;
        int writePos;
        
        uint8_t* lowPassBuf;
        int lowPassBufMaxSize;
        int lowPassBufSize;
        int lowPassBufReadPos;
        int nReadBufSize;
        int nRead;
        void* sem;
        void* tid;
        volatile uint32_t locker;
    } lowPassBuffer;
    
    tbi_bool_t bIsAfterLowPass;
    tbi_bool_t bIsLowPassStarted;
    
    uint32_t startDroping;
    uint32_t dropingDelay;
    long long lastPaskage;
    
#if IS_SOUND_STRETCHING_ON
    SoundEffect_t* soundEffect;
    uint8_t* compressData;
    int compressDataMaxSize;
    tbi_bool_t bIsFlushed;
#endif //IS_SOUND_STRETCHING_ON
    
    uint64_t startTime;
    
    audio_recv_data_list_t audio_data_list;
    
    volatile int32_t dataSize;
    volatile int32_t bIsSilenced;
    
    int seq;
    int lastCheckCnt;
    int nFlushedCnt;
    
    struct
    {
        TimeArray_t delayTimes;
        int delayCnt;
        
        int defaultUnitSize;
        int currentUnitSize;
        uint64_t time;
        
    } adaptationSettings;
    
    struct
    {
        uint32_t rangeLow120;
        uint32_t range120_180;
        uint32_t range180_240;
        uint32_t range240_300;
        uint32_t range300_400;
        uint32_t range400_700;
        
        TBI_list_t* interraptions;
    } interraptionChecker;
    uint64_t lastPutTime;
    
} media_audio_buffer_t;

media_audio_buffer_t* open_audio_buffer(uint32_t rate, TBI_size_t chunckSize, int pTime, uint32_t frameCnt);
void close_audio_buffer(media_audio_buffer_t* audio_buffer);
int put_audio_buffer(media_audio_buffer_t* audio_buffer, uint8_t* data, int size, int recvSize);
int pop_audio_buffer(media_audio_buffer_t* audio_buffer, uint8_t* data, int size);

TBI_END_DECLS

#endif
