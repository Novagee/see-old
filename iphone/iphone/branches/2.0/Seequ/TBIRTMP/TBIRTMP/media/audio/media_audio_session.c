//
//  media_video_session.c
//  TBIRTMP
//
//  Created by Grigori Jlavyan on 11/6/12.
//  Copyright (c) 2012 Grigori Jlavyan. All rights reserved.
//

#include <stdio.h>
#include "media_audio_session.h"
#include "media_codec_g711.h"
#include "media_codec_g729.h"
#include "media_codec_speex.h"
#include "media_codec_opus.h"
#include "media_codec_gsm.h"

#include "TBI_string.h"
#include "TBI_thread.h"
#include "TBIRTMP.h"

#include <mach/mach.h>
#include <mach/mach_time.h>
#include <unistd.h>

#define  AUDIO_PING_CHECKING_DELAY 2500

enum audio_rtmp_state{
    AUDIO_RTMP_STATE_UNKNOWN,
    AUDIO_RTMP_STATE_DISCONNECTED,
    AUDIO_RTMP_STATE_HANDSHAKEFINISH,
    AUDIO_RTMP_STATE_CONNECTING,
    AUDIO_RTMP_STATE_CONNECTED
};

#define kRingPacketCount	+10
#define kMaxPtimeBeforeUsingCondVars	+500 /* milliseconds */

#define AUDIO_TIME_COIFFICENT  370
#define AUDIO_LOST_CALC_TIME   2700

static void *__sender_thread_opus(void *param);
static void *__sender_thread_g729(void *param);
static void *__sender_thread(void *param);
void media_audio_session_status_cb(void* param, rtmp_event_t *event);

static void* media_audio_session_receiver(void * param)
{
    RTMPPacket* packet = 0;
    media_audio_session_t* self = (media_audio_session_t*)param;
    TBI_DEBUG_INFO("AUDIO: media_audio_session_receiver::media_audio_session_receiver dshncfjkdsh,fk ENTER");
    if(!self)
        return 0;
    
    int bHasMediaPacket = 0;

    self->lastPackageTime = 0;
    TBI_DEBUG_INFO("AUDIO: media_audio_session_receiver::ENTER");
    
    while(self->rtmp.bIsStarted && self->rtmp.state < AUDIO_RTMP_STATE_HANDSHAKEFINISH)
    {
        usleep(50000);
    }

    while (self->rtmp.bIsStarted)
    {
        if(!RTMP_IsConnected(self->rtmp.r))
            break;
        
        packet = TBI_object_new(RTMPPacket_def_t);
        
        if(self->media_audion_connection_status >0){
            self->media_audion_connection_received_package++;
        }
        
        if(RTMP_ReadPacket(self->rtmp.r, packet) && RTMPPacket_IsReady(packet))
        {
            bHasMediaPacket = RTMP_ClientPacket(self->rtmp.r, packet);
            if(bHasMediaPacket)
            {
                self->lastPackageTime = TBI_time_epoch();
            }
        }
        TBI_OBJECT_SAFE_FREE(packet);
    }
    
    TBI_DEBUG_INFO("AUDIO: media_audio_session_receiver::EXIT");
    return 0;
}

static void* media_audio_session_connect(void * param)
{
    media_audio_session_t *self = (media_audio_session_t*)param;
    int n;
    TBI_DEBUG_INFO("AUDIO: media_audio_session_connect::ENTER");
//    TBI_mutex_lock(self->rtmp.mutex);
    while (self->bStartConnect)
    {
#if RTMP_WITHOUT_HANDSHAKE
        if (!TBI_RTMP_ConnectWoHandshakNoReg(self->rtmp.r, NULL))
#else
        if (!RTMP_Connect(self->rtmp.r, NULL))
#endif //RTMP_WITHOUT_HANDSHAKE
        {
            usleep(50000);
            continue;
        }
        
        self->rtmp.state = AUDIO_RTMP_STATE_HANDSHAKEFINISH;
        n = 100;
        while (self->rtmp.state != AUDIO_RTMP_STATE_CONNECTED && --n)
        {
            if (!self->bStartConnect)
                goto exit_thread;

            usleep(100000);
        }
        
        if(self->rtmp.state == AUDIO_RTMP_STATE_CONNECTED)
        {
//            if(self->rtmp.bStartPlayPublish)
//            {
//                RTMP_SendCreateStream(self->rtmp.r);
//                RTMP_SendCreateStream(self->rtmp.r);
//                self->rtmp.bStartPlayPublish = tbi_false;
//            }
            break;
        }

        RTMP_Close(self->rtmp.r);
    }
//    TBI_mutex_unlock(self->rtmp.mutex);
exit_thread:
    TBI_DEBUG_INFO("AUDIO: media_audio_session_connect::EXIT");
    self->bStartConnect = tbi_false;
    return 0;
}

media_codec_t* getCodecByFormat(uint32_t codecFormat)
{
    switch (codecFormat) {
//        case MEDIA_CODEC_FORMAT_G729:
//            return pmedia_codec_g729ab;
        case MEDIA_CODEC_FORMAT_SPEEX_WB:
            return pmedia_codec_speex_wb_s;
        case MEDIA_CODEC_FORMAT_PCMA:
            return pmedia_codec_pcma;
        case MEDIA_CODEC_FORMAT_PCMU:
            return pmedia_codec_pcmu;
        case MEDIA_CODEC_FORMAT_OPUS:
            return pmedia_codec_opus;
        case MEDIA_CODEC_FORMAT_GSM:
            return pmedia_codec_gsm;
        case MEDIA_CODEC_FORMAT_OPUS8_8:
            return pmedia_codec_opus8_8;
        case MEDIA_CODEC_FORMAT_OPUS8_16:
            return pmedia_codec_opus8_16;
        case MEDIA_CODEC_FORMAT_OPUS8_32:
            return pmedia_codec_opus8_32;
        case MEDIA_CODEC_FORMAT_OPUS16_16:
            return pmedia_codec_opus16_16;
        case MEDIA_CODEC_FORMAT_OPUS16_32:
            return pmedia_codec_opus16_32;
        default:
            break;
    }
    return tbi_null;
}

int getCodecByString(const char* codecFormat)
{
    
    char *g729 = "g729";
    char *speex ="speex";
    char *pcmu = "pcmu";
    char *pcma = "pcma";
    char *gsm = "gsm";
    char *opus = "opus";
    char *opus8_8 = "opus8_8";
    char *opus8_16 = "opus8_16";
    char *opus8_32 = "opus8_32";
    char *opus16_16 = "opus16_16";
    char *opus16_32 = "opus16_32";
    
    if(!TBI_strcmp(g729,codecFormat))
        return MEDIA_CODEC_FORMAT_G729;
    if(!TBI_strcmp(speex, codecFormat))
        return MEDIA_CODEC_FORMAT_SPEEX_WB;
    if(!TBI_strcmp(pcmu,codecFormat))
        return MEDIA_CODEC_FORMAT_PCMU;
    if(!TBI_strcmp(pcma,codecFormat))
        return MEDIA_CODEC_FORMAT_PCMA;
    if(!TBI_strcmp(gsm,codecFormat))
        return MEDIA_CODEC_FORMAT_GSM;
    if(!TBI_strcmp(opus,codecFormat))
        return MEDIA_CODEC_FORMAT_OPUS;
    if(!TBI_strcmp(opus8_8,codecFormat))
        return MEDIA_CODEC_FORMAT_OPUS8_8;
    if(!TBI_strcmp(opus8_16,codecFormat))
        return MEDIA_CODEC_FORMAT_OPUS8_16;
    if(!TBI_strcmp(opus8_32,codecFormat))
        return MEDIA_CODEC_FORMAT_OPUS8_32;
    if(!TBI_strcmp(opus16_16,codecFormat))
        return MEDIA_CODEC_FORMAT_OPUS16_16;
    if(!TBI_strcmp(opus16_32,codecFormat))
        return MEDIA_CODEC_FORMAT_OPUS16_32;

    return 0;
}

media_audio_session_t* media_audio_session_restart(media_audio_session_t *self,char* url, media_audio_callback callback, void* callbackData)
{
    
    self->rtmp.r = RTMP_Alloc();
    if(!self->rtmp.r)
        return 0;
    
    RTMP_Init(self->rtmp.r, tbi_false, tbi_true, "AUDIO_R");
    TBI_RTMP_SetCallback(self->rtmp.r, media_audio_session_status_cb, self);
    RTMP_SetupURL(self->rtmp.r, url);
    self->lockForReconnect = 0;
    self->rtmp.state = RTMP_EVENT_TYPE_UNKNOWN;
    self->rtmp.bStartPlayPublish = tbi_false;
    
    self->callback = callback;
    self->callbackData = callbackData;
    
    self->rtmp.r->m_bPublishing = tbi_true;
    
    self->rtmp.bIsStarted = tbi_true;
//    TBI_thread_create(&self->rtmp.threadId[0], media_audio_session_receiver, (void*)self);
    
    self->bStartConnect = tbi_true;
    TBI_thread_create(&self->rtmp.threadId[1], media_audio_session_connect, (void*)self);
    
    //    self->st = 0;
    self->bitrate = 700;
    
    self->lastPacketTS = 0;
    self->packetTime = 0;
    
    return self;
}

int media_audio_session_create(media_audio_session_t **obj,char* url, media_audio_callback callback, receiveCallback statusCallback, void* callbackData,const char *uid)
{
    (*obj) = (media_audio_session_t*)calloc(1, sizeof(media_audio_session_t));
    media_audio_session_t *self = *obj;
    
    self->rtmp.bIsOwn = tbi_true;
    self->rtmp.r = RTMP_Alloc();
    if(!self->rtmp.r)
        return -1;
    
    self->lockForReconnect = 0;
    self->lastPackageTime = 0 ;
    RTMP_Init(self->rtmp.r, tbi_false, tbi_true, "AUDIO");
    TBI_RTMP_SetCallback(self->rtmp.r, media_audio_session_status_cb, self);
    RTMP_SetupURL(self->rtmp.r, url);
    self->rtmp.isReconnected = tbi_false;
    self->rtmp.state = RTMP_EVENT_TYPE_UNKNOWN;
    self->rtmp.bStartPlayPublish = tbi_false;
    self->producer.droping = tbi_false;
    
    self->callback = callback;
    self->statusCallback = statusCallback;
    self->callbackData = callbackData;
    self->uid = calloc(1,strlen(uid));
    
    memcpy(self->uid, uid, strlen(uid));

    self->media_audion_connection_status = 0;
    self->media_audion_connection_received_package = 0 ;
    self->rtmp.bIsStarted = tbi_true;
    TBI_thread_create(&self->rtmp.threadId[0], media_audio_session_receiver, (void*)self);

    self->bStartConnect = tbi_true;
    TBI_thread_create(&self->rtmp.threadId[1], media_audio_session_connect, (void*)self);
    
//    self->st = 0;
    self->bitrate = 700;
    
    self->lastPacketTS = 0;
    self->packetTime = 0;
    
    return 0;
}

void media_audio_session_DestroyRTMP(media_audio_session_t* self)
{
    if(self->rtmp.r)
    {
        self->rtmp.bIsStarted = tbi_false;
        RTMP_UserInterrupt(self->rtmp.r);
        RTMP_Close(self->rtmp.r);
        
        if(self->rtmp.threadId[0])
        {
            TBI_thread_join(&self->rtmp.threadId[0]);
        }
        
        self->bStartConnect = tbi_false;
        if(self->rtmp.threadId[1])
        {
            TBI_thread_join(&self->rtmp.threadId[1]);
        }
        
        RTMP_Free(self->rtmp.r);
        self->rtmp.r = 0;
    }
}

void media_audio_session_Destroy(media_audio_session_t** self)
{
    if(self)
    {
        if((*self)->rtmp.bIsOwn)
            media_audio_session_DestroyRTMP(*self);
        
        (*self)->producer.isRunning = tbi_false;
        if((*self)->producer.threadId){
            (*self)->producer.isRunning = TBI_false;
            TBI_semaphore_increment((*self)->producer.audioSender);
            TBI_semaphore_increment((*self)->producer.audioSender);
            TBI_semaphore_increment((*self)->producer.audioSender);
            TBI_thread_join(&(*self)->producer.threadId);
        }
        
        if((*self)->producer.audioSender){
            TBI_semaphore_destroy(&(*self)->producer.audioSender);
            (*self)->producer.audioSender = 0;
        }
        
        if((*self)->codec)
        {
            (*self)->codec->close((*self)->codec);
            (*self)->codec = 0;
        }
        
        if((*self)->decoder.decode_buffer)
        {
            free((*self)->decoder.decode_buffer);
            (*self)->decoder.decode_buffer = 0;
        }
        
        if((*self)->encode.encode_buffer)
        {
            free((*self)->encode.encode_buffer);
            (*self)->encode.encode_buffer = 0;
        }
        
        if((*self)->frameBuffer)
        {
            free((*self)->frameBuffer);
            (*self)->frameBuffer = 0;
            (*self)->startPos = 0;
            (*self)->frameBufSize = 0;
        }

        if((*self)->received_buffer)
        {
            close_audio_buffer((*self)->received_buffer);
            (*self)->received_buffer = 0;
            speex_buffer_destroy((*self)->SpeexReceived_buffer);
            (*self)->SpeexReceived_buffer = 0 ;
            
        }
        TBI_mutex_unlock((*self)->rtmp.mutex);
        
        TBI_DEBUG_INFO("media_audio_session_Destroy free");
        free(*self);
        *self = 0;
    }
}

int media_audion_session_connection_check(media_audio_session_t *self)
{
    int64_t diff = (TBI_time_epoch()-self->lastPackageTime);
    rtmp_event_t *event =  (rtmp_event_t*)TBI_object_new(rtmp_event_def_t);

    if( diff> AUDIO_PING_CHECKING_DELAY && self->lastPackageTime>0)
    {
        native_debug_function("[CALL][RECONNECT] audio packet diff - %i", diff);
        if(self->media_audion_connection_status > 0 )
        {
            if((TBI_time_epoch() - self->audioSignalingPingTime) > AUDIO_PING_CHECKING_DELAY)
            {
                native_debug_function("[CALL][RECONNECT] media_audion_connection_status - %i",self->media_audion_connection_status);
                switch (self->media_audion_connection_status)
                {
                    case 1:
                    {
                        native_debug_function("[CALL][RECONNECT][RTMP_STATUS_LOCAL_CONNECTION_CORRUPTED_INITIAL_STATE] %i",self->media_audion_connection_status);
                        event->messageType = TBI_strdup("Audio connection corrupted\n");
                        event->rtmp_call_event = RTMP_STATUS_LOCAL_CONNECTION_CORRUPTED_INITIAL_STATE;
                        self->media_audion_connection_status=5;
                    }
                        break;
                    case 3:
                    {
                        native_debug_function("[CALL][RECONNECT][RTMP_STATUS_LOCAL_CONNECTION_ALIVE_INITIAL_STATE] %i",self->media_audion_connection_status);
                        event->messageType = TBI_strdup("Audio connection alive\n");
                        event->rtmp_call_event = RTMP_STATUS_LOCAL_CONNECTION_ALIVE_INITIAL_STATE;
                        self->media_audion_connection_status=4;
                    }
                        break;
                    case 6:
                    {
                        native_debug_function("[CALL][RECONNECT][RTMP_STATUS_LOCAL_CONNECTION_ALIVE] %i",self->media_audion_connection_status);
                        event->messageType = TBI_strdup("Audio reduced\n");
                        event->rtmp_call_event = RTMP_STATUS_LOCAL_CONNECTION_ALIVE;
                        self->lastPackageTime = 0 ;
                        
                    }
                        break;
                    case 5:
                    case 4:
                    {
                        native_debug_function("[CALL][RECONNECT][RTMP_STATUS_LOCAL_CONNECTION_CORRUPTED] %i",self->media_audion_connection_status);
                        event->messageType = TBI_strdup("Audio reconnecting\n");
                        event->rtmp_call_event = RTMP_STATUS_LOCAL_CONNECTION_CORRUPTED;
                        self->lastPackageTime = 0 ;
                    }
                        break;
                    default:
                        break;
                }
                
                if(self->statusCallback && self->callbackData)
                    self->statusCallback(self->callbackData, (void*)event);
                
//                native_debug_function("{media_audion_session_connection_check}->media_audion_connection_status %i",self->media_audion_connection_status);
                
                if(self->uid){
                    
                    native_debug_function("[CALL][RECONNECT][CHECKNET] %i",self->media_audion_connection_status);
                    AVal uid;
                    uid.av_val = self->uid;
                    uid.av_len = strlen(self->uid);
                    //native_debug_function("#######&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& statuc %s",self->uid);
                    TBI_RTMP_SendChecknet(self->rtmp.r,&uid);
                    self->audioSignalingPingTime = TBI_time_epoch();
                }
            }
        }
        else
        {
            //      native_debug_function("&&&&&&&&&&&&&&&&&&&&&&&&&& %lu",self->audioSignalingPingTime);
            AVal uid;
            uid.av_val = self->uid;
            uid.av_len = strlen(self->uid);
            
            TBI_RTMP_SendChecknet(self->rtmp.r,&uid);
            self->audioSignalingPingTime = TBI_time_epoch();
            
            if(self->media_audion_connection_status == 0)
            {
                native_debug_function("[CALL][RECONNECT][FIRST CHECKNET] %i",self->media_audion_connection_status);
//                native_debug_function("####### statuc %i",self->media_audion_connection_status);
                event->messageType = TBI_strdup("Audio deslaying\n");
                event->rtmp_call_event = RTMP_STATUS_NO_AUDIO;
                self->last_audio_status = RTMP_STATUS_NO_AUDIO;
                if(self->statusCallback && self->callbackData)
                    self->statusCallback(self->callbackData, (void*)event);
                self->media_audion_connection_status = 1;
            }
        }
    }
    else if(self->media_audion_connection_status > 0)
    {
        if(self->media_audion_connection_received_package > 25){
            self->media_audion_connection_received_package = 0;
            self->media_audion_connection_status = 0 ;
        }else{
//                test->messageType = "Audio reconnected\n";
//                test->rtmp_call_event = RTMP_STATUS_AUDIO_RECONNECT;
//
//                if(self->statusCallback && self->callbackData)
//                    self->statusCallback(self->callbackData, (void*)test);
        }
    }
    TBI_OBJECT_SAFE_FREE(event);
    return 0;
}

int media_audio_session_send_wo_collect(media_audio_session_t* self, const void* buffer, int size)
{
    if(!self || !self->rtmp.bIsStarted)
        return -1;
    
    if(!RTMP_IsConnected(self->rtmp.r) || !self->rtmp.r->m_bPublishing)
        return 0;
    
    RTMPPacket* packet = (RTMPPacket*)TBI_object_new(RTMPPacket_def_t);
    packet->m_nChannel = 0x04;	/* source channel */
    packet->m_nInfoField2 = self->rtmp.r->m_publishstream_id;
    
    packet->m_packetType = RTMP_PACKET_TYPE_AUDIO;
    
    if((size + 1) > self->rtmp.r->m_outChunkSize)
        TBI_ChangeChunkSize(self->rtmp.r, size + 1);
    
//    uint64_t current_time = TBI_time_epoch();
    if(!self->rtmp.bIsFirstPacket)
    {
        self->rtmp.startTimeStamp = RTMP_GetTime() - self->rtmp.connectionTimeStamp;
//        self->rtmp.startTimeStamp = current_time - self->rtmp.connectionTimeStamp;
        packet->m_nTimeStamp = self->rtmp.startTimeStamp;
        packet->m_headerType = RTMP_PACKET_SIZE_LARGE;
        self->rtmp.bIsFirstPacket = tbi_true;
    }
    else
    {
        self->rtmp.startTimeStamp += self->codec->audio.pTime * self->publisherframesCount;
//        self->rtmp.startTimeStamp = current_time - self->rtmp.connectionTimeStamp;
        packet->m_nTimeStamp = self->rtmp.startTimeStamp;
        packet->m_headerType = RTMP_PACKET_SIZE_MEDIUM;
    }
    
    packet->m_nBodySize = size + 1;
    
    RTMPPacket_Alloc(packet, packet->m_nBodySize);
    
    packet->m_body[0] = self->codec->format;
    memcpy(packet->m_body + 1, buffer, size);
    
    if(!RTMP_SendPacket(self->rtmp.r, packet, 0)){
        TBI_DEBUG_ERROR("package send failed -- RTMP_SendPacket(manager->rtmp_media, packet, 0)\n");
    }

    if((RTMP_IsConnected(self->rtmp.r) || self->rtmp.r->m_bPublishing) && !self->isHold)
    {
        if(self->lockForReconnect==0)
            media_audion_session_connection_check(self);
    }

    TBI_OBJECT_SAFE_FREE(packet);
    
    return 0;
}

int media_audio_session_send_opus(media_audio_session_t* self, const void* buffer, int size)
{
    if(!self || !self->rtmp.bIsStarted)
        return -1;

    if(!RTMP_IsConnected(self->rtmp.r) || !self->rtmp.r->m_bPublishing)
        return 0;

    if(self->videoStartTime!=0)
        self->videoStartTime = TBI_time_epoch();
    
    RTMPPacket* packet = (RTMPPacket*)TBI_object_new(RTMPPacket_def_t);
    packet->m_nChannel = 0x04;	/* source channel */
    packet->m_nInfoField2 = self->rtmp.r->m_publishstream_id;
    packet->m_packetType = RTMP_PACKET_TYPE_AUDIO;
    if(!self->rtmp.bIsFirstPacket)
    {
        TBI_ChangeChunkSize(self->rtmp.r, size + 1);
        //        TBI_ChangeChunkSize(self->rtmp.r, self->frameBufSize + 1);
        
        self->rtmp.startTimeStamp = RTMP_GetTime() - self->rtmp.connectionTimeStamp;
        fprintf(stderr, "AUDIO: Current time = %d, connection time = %d, delta time = %d\n", RTMP_GetTime(), self->rtmp.connectionTimeStamp, self->rtmp.startTimeStamp);
        packet->m_nTimeStamp = self->rtmp.startTimeStamp;
        packet->m_headerType = RTMP_PACKET_SIZE_LARGE;
        self->rtmp.bIsFirstPacket = tbi_true;
    }
    else
    {
        self->rtmp.startTimeStamp += self->codec->audio.pTime * self->publisherframesCount;
        packet->m_nTimeStamp = self->rtmp.startTimeStamp;
        packet->m_headerType = RTMP_PACKET_SIZE_MEDIUM;
    }
    
    packet->m_nBodySize = size + 1;
    //    packet->m_nBodySize = self->frameBufSize + 1;
    
    RTMPPacket_Alloc(packet, packet->m_nBodySize);
    
    packet->m_body[0] = self->codec->format;
    //    memcpy(packet->m_body + 1, self->frameBuffer, self->frameBufSize);
    memcpy(packet->m_body + 1, buffer, size);
    
    if(!RTMP_SendPacket(self->rtmp.r, packet, 0)){
        TBI_DEBUG_ERROR("package send failed -- RTMP_SendPacket(manager->rtmp_media, packet, 0)\n");
    }
    
    if((RTMP_IsConnected(self->rtmp.r) || self->rtmp.r->m_bPublishing) && !self->isHold)
    {
        if(self->lockForReconnect==0)
            media_audion_session_connection_check(self);
    }

    TBI_OBJECT_SAFE_FREE(packet);
    
    self->startPos = self->frameBuffer;
    self->framesCount = 0;
    

    return 0;
}

int media_audio_session_reStart(media_audio_session_t* self, const char* playName, const char* publishName, const char* codecFormat, int playFrameCnt, int publishFrameCnt)
{
    if(!self || !playName    || playName[0]    == '\0'
       || !publishName || publishName[0] == '\0'
       || !codecFormat || codecFormat[0] == '\0')
        return -1;
    
    self->playerframesCount = playFrameCnt;
    self->publisherframesCount = publishFrameCnt;

    
    self->rettPacketCnt = 0;
    self->nonerettPacketCnt = 0;
    self->startTime = 0;
    self->packetTime = self->codec->audio.pTime * playFrameCnt;
    self->lastPercentage = 100.f;
    
    native_debug_function("AUDIO: playName = %s / publishName = %s", playName, publishName);
    
    self->rtmp.r->Link.publishpath.av_len = strlen(publishName);
    self->rtmp.r->Link.publishpath.av_val = calloc(1, self->rtmp.r->Link.publishpath.av_len);
    memcpy(self->rtmp.r->Link.publishpath.av_val, publishName, self->rtmp.r->Link.publishpath.av_len);
    self->rtmp.r->m_publishstream_id = 0;
    
    self->rtmp.r->Link.playpath.av_len = strlen(playName);
    self->rtmp.r->Link.playpath.av_val = calloc(1, self->rtmp.r->Link.playpath.av_len);
    memcpy(self->rtmp.r->Link.playpath.av_val, playName, self->rtmp.r->Link.playpath.av_len);
    self->rtmp.r->m_playstream_id = -1;
    
    self->rtmp.r->Link.lFlags |= RTMP_LF_LIVE;
    
    
    int bufferSize = self->codec->rate/1000 * self->codec->audio.pTime * 2; //PCM bit per sample = 2
    
    self->decoder.decode_buffer = calloc(1, bufferSize);
    self->encode.encode_buffer = calloc(1, bufferSize);
    
//    self->producer.audioQ_buffer = speex_buffer_init(kRingPacketCount * bufferSize);
//    self->producer.needUse = TRUE;
    
//    if(!self->received_buffer)
//        close_audio_buffer(self->received_buffer);
//    
//    self->received_buffer = open_audio_buffer(bufferSize, self->codec->audio.pTime);
    self->SpeexReceived_buffer = speex_buffer_init(10000);

    
    if(self->rtmp.state < AUDIO_RTMP_STATE_CONNECTED)
    {
        self->rtmp.bStartPlayPublish = tbi_true;
    }
    else
    {
//        RTMP_SendCreateStream(self->rtmp.r);
        RTMP_SendCreateStream(self->rtmp.r);
        self->rtmp.bStartPlayPublish = tbi_false;
    }
    self->rtmp.connectionTimeStamp = RTMP_GetTime();
    
    

    return 0;
}

int media_audio_session_reConnect(media_audio_session_t* self, const char* playName, const char* publishName, const char* codecFormat, int playFrameCnt, int publishFrameCnt)
{
    if(!self || !playName    || playName[0]    == '\0'
       || !publishName || publishName[0] == '\0'
       || !codecFormat || codecFormat[0] == '\0')
        return -1;
    
    self->last_audio_status = RTMP_STATUS_NO_AUDIO;
    self->playerframesCount = playFrameCnt;
    self->publisherframesCount = publishFrameCnt;
    self->videoStartTime = 0 ;
    
    
    native_debug_function("AUDIO: playName = %s / publishName = %s", playName, publishName);
    
    
//    self->rtmp.r->Link.publishpath.av_len = strlen(publishName);
//    self->rtmp.r->Link.publishpath.av_val = calloc(1, self->rtmp.r->Link.publishpath.av_len);
//    memcpy(self->rtmp.r->Link.publishpath.av_val, publishName, self->rtmp.r->Link.publishpath.av_len);
//    self->rtmp.r->m_publishstream_id = 0;
    
    self->rtmp.r->Link.playpath.av_len = strlen(playName);
    self->rtmp.r->Link.playpath.av_val = calloc(1, self->rtmp.r->Link.playpath.av_len);
    memcpy(self->rtmp.r->Link.playpath.av_val, playName, self->rtmp.r->Link.playpath.av_len);
    self->rtmp.r->m_playstream_id = -1;
    
    self->rtmp.r->Link.lFlags |= RTMP_LF_LIVE;
    
//    if(self->rtmp.state < AUDIO_RTMP_STATE_CONNECTED)
//    {
//        self->rtmp.bStartPlayPublish = tbi_true;
//    }
//    else
//    {
//        RTMP_SendCreateStream(self->rtmp.r);
        RTMP_SendCreateStream(self->rtmp.r);
        self->rtmp.bStartPlayPublish = tbi_false;
//    }
    return 0;
}

int media_audio_session_Start(media_audio_session_t* self, const char* playName, const char* publishName, const char* codecFormat, int playFrameCnt, int publishFrameCnt, RTMP* r)
{
    if(!self || !playName    || playName[0]    == '\0'
             || !publishName || publishName[0] == '\0'
             || !codecFormat || codecFormat[0] == '\0')
        return -1;

    
    self->isHold = tbi_false;
    
    self->audioSignalingPingTime = -1;
    
    self->videoStartTime = 0 ;
    
    self->playerframesCount = playFrameCnt;
    self->publisherframesCount = publishFrameCnt;
    
    self->codec = getCodecByFormat((uint32_t)getCodecByString(codecFormat));
    if(!self->codec || self->codec->open(self->codec))
        return -2;
    
    self->rettPacketCnt = 0;
    self->nonerettPacketCnt = 0;
    self->startTime = 0;
    self->packetTime = self->codec->audio.pTime * playFrameCnt;
    self->lastPercentage = 100.f;
    
    int bufferSize = self->codec->rate/1000 * self->codec->audio.pTime * 2; //PCM bit per sample = 2

    self->decoder.decode_buffer = calloc(1, bufferSize);
    self->encode.encode_buffer = calloc(1, bufferSize);
    
    self->producer.audioQ_buffer = speex_buffer_init(kRingPacketCount * bufferSize);
    self->producer.mutex = TBI_mutex_create();
    self->producer.audioSender = TBI_semaphore_create();
    self->producer.needUse = TRUE;
    
#ifdef JITTER_BUFFER_ENABLED
    if(!self->jitter_buffer){
        self->jitter_buffer = (tdav_speakup_jitterbuffer_t*)malloc(sizeof(tdav_speakup_jitterbuffer_t));
        tdav_speakup_jitterbuffer_open(self->jitter_buffer, 20, 16000);
    }
#else
    if(!self->received_buffer)
        close_audio_buffer(self->received_buffer);
    
    self->received_buffer = open_audio_buffer(self->codec->rate, bufferSize, self->codec->audio.pTime, playFrameCnt);
    self->SpeexReceived_buffer = speex_buffer_init(10000);
    
#endif

    self->producer.isRunning = tbi_true;
    if(self->codec->format == MEDIA_CODEC_FORMAT_G729){
        TBI_thread_create(&self->producer.threadId, __sender_thread_g729, self);
    }
    else if(self->codec->format <= MEDIA_CODEC_FORMAT_LAST_OPUS && self->codec->format >= MEDIA_CODEC_FORMAT_OPUS){
        TBI_thread_create(&self->producer.threadId, __sender_thread_opus, self);
    }else{
        TBI_thread_create(&self->producer.threadId, __sender_thread, self);
    }

    native_debug_function("AUDIO: playName = %s / publishName = %s", playName, publishName);
    
    if(self->rtmp.state < AUDIO_RTMP_STATE_CONNECTED)
    {
        media_audio_session_DestroyRTMP(self);
        self->rtmp.bIsOwn = tbi_false;
        self->rtmp.r = r;
        self->rtmp.bIsStarted = tbi_true;
    }
    
    self->rtmp.r->Link.publishpath.av_len = strlen(publishName);
    self->rtmp.r->Link.publishpath.av_val = calloc(1, self->rtmp.r->Link.publishpath.av_len);
    memcpy(self->rtmp.r->Link.publishpath.av_val, publishName, self->rtmp.r->Link.publishpath.av_len);
    self->rtmp.r->m_publishstream_id = -1;
    
    self->rtmp.r->Link.playpath.av_len = strlen(playName);
    self->rtmp.r->Link.playpath.av_val = calloc(1, self->rtmp.r->Link.playpath.av_len);
    memcpy(self->rtmp.r->Link.playpath.av_val, playName, self->rtmp.r->Link.playpath.av_len);
    self->rtmp.r->m_playstream_id = -1;
    
    self->rtmp.r->Link.lFlags |= RTMP_LF_LIVE;
    
    RTMP_SendCreateStream(self->rtmp.r);
    RTMP_SendCreateStream(self->rtmp.r);

    return 0;
}

int media_audio_session_send(media_audio_session_t* self, const void* buffer, int size)
{
    if(!self || !self->rtmp.bIsStarted)
        return -1;
    
    if(!RTMP_IsConnected(self->rtmp.r) || !self->rtmp.r->m_bPublishing)
        return 0;
    
    if(self->frameBuffer == 0)
    {
        self->frameBufSize = self->publisherframesCount * size;
        self->frameBuffer = malloc(self->frameBufSize);
        self->startPos = self->frameBuffer;
        self->framesCount = 0;
    }
    
    memcpy(self->startPos, buffer, size);
    self->startPos += size;
    self->framesCount++;
    
    if(self->framesCount < self->publisherframesCount)
        return 0;
    
    RTMPPacket* packet = (RTMPPacket*)TBI_object_new(RTMPPacket_def_t);
    packet->m_nChannel = 0x04;	/* source channel */
    packet->m_nInfoField2 = self->rtmp.r->m_publishstream_id;
    
    packet->m_packetType = RTMP_PACKET_TYPE_AUDIO;
    
    if(!self->rtmp.bIsFirstPacket || self->rtmp.isReconnected)
    {
        if(self->rtmp.isReconnected){
            self->frameBufSize = self->publisherframesCount * size;
            self->frameBuffer = malloc(self->frameBufSize);
            self->startPos = self->frameBuffer;
            self->framesCount = 0;
            self->rtmp.isReconnected = tbi_false;
        }
        
        TBI_ChangeChunkSize(self->rtmp.r, self->frameBufSize + 1);
        
        self->rtmp.startTimeStamp = RTMP_GetTime() - self->rtmp.connectionTimeStamp;
        fprintf(stderr, "AUDIO: Current time = %d, connection time = %d, delta time = %d\n", RTMP_GetTime(), self->rtmp.connectionTimeStamp, self->rtmp.startTimeStamp);
        packet->m_nTimeStamp = self->rtmp.startTimeStamp;
        packet->m_headerType = RTMP_PACKET_SIZE_LARGE;
        self->rtmp.bIsFirstPacket = tbi_true;
        self->rtmp.isReconnected = tbi_false;
    }
    else
    {
        self->rtmp.startTimeStamp += self->codec->audio.pTime * self->publisherframesCount;
        packet->m_nTimeStamp = self->rtmp.startTimeStamp;
        packet->m_headerType = RTMP_PACKET_SIZE_MEDIUM;
    }
    

    //fprintf(stderr, "package send failed -- RTMP_SendPacket(manager->rtmp.startTimeStamp  %d)\n",self->rtmp.startTimeStamp);
    
    
    
    packet->m_nBodySize = self->frameBufSize + 1;
    
    RTMPPacket_Alloc(packet, packet->m_nBodySize);
    
    packet->m_body[0] = self->codec->format;
    memcpy(packet->m_body + 1, self->frameBuffer, self->frameBufSize);
    
    if(!RTMP_SendPacket(self->rtmp.r, packet, 0)){
        TBI_DEBUG_ERROR("package send failed -- RTMP_SendPacket(manager->rtmp_media, packet, 0)\n");
    }
    
    TBI_OBJECT_SAFE_FREE(packet);
    
    self->startPos = self->frameBuffer;
    self->framesCount = 0;
    
    double deltaTime = TBI_time_epoch() - self->stat->lastPlayedFrameTime;
    double criticalPoint = 3000;
   // fprintf(stderr, "########### DECRICE AUDIO deltaTime = %f criticalPoint = %f \n",deltaTime,criticalPoint);
    
    if(deltaTime > criticalPoint && (self->stat->isunlock)){
        //fprintf(stderr, "########### DECRICE AUDIO ---- self->lastPlayed2TimeFrameTime = %f  self->lastPlayed2TimeFrameCount = %llu realAllTime %f deltaTime %f self->stat->islocked %i\n",self->stat->lastPlayed2TimeFrameTime,self->stat->lastPlayed2TimeFrameCount,criticalPoint,deltaTime,self->stat->isunlock);
        self->stat->isunlock = tbi_false;
        media_video_callback callback = self->stat->callback;
        double n=-1;
        callback(self->stat->callbackData, media_video_decrease, n);
        
    }
    
    return 0;
}

int media_audio_session_send_g729(media_audio_session_t* self, const void* buffer, int size)
{
    if(!self || !self->rtmp.bIsStarted)
        return -1;
    
    if(!RTMP_IsConnected(self->rtmp.r) || !self->rtmp.r->m_bPublishing)
        return 0;
    
    //    if(self->frameBuffer == 0)
    //    {
    //        self->frameBufSize = self->publisherframesCount * size;
    //        self->frameBufSize = size;
    //        self->frameBuffer = malloc(self->frameBufSize);
    //        self->startPos = self->frameBuffer;
    //        self->framesCount = 0;
    //    }
    
    //    memcpy(self->startPos, buffer, size);
    //    self->startPos += size;
    //    self->framesCount++;
    
    //    if(self->framesCount < self->publisherframesCount)
    //        return 0;
    
    RTMPPacket* packet = (RTMPPacket*)TBI_object_new(RTMPPacket_def_t);
    packet->m_nChannel = 0x04;	/* source channel */
    packet->m_nInfoField2 = self->rtmp.r->m_publishstream_id;
    
    packet->m_packetType = RTMP_PACKET_TYPE_AUDIO;
    
    if(!self->rtmp.bIsFirstPacket)
    {
        TBI_ChangeChunkSize(self->rtmp.r, size + 1);
        //        TBI_ChangeChunkSize(self->rtmp.r, self->frameBufSize + 1);
        
        self->rtmp.startTimeStamp = RTMP_GetTime() - self->rtmp.connectionTimeStamp;
        fprintf(stderr, "AUDIO: Current time = %d, connection time = %d, delta time = %d\n", RTMP_GetTime(), self->rtmp.connectionTimeStamp, self->rtmp.startTimeStamp);
        packet->m_nTimeStamp = self->rtmp.startTimeStamp;
        packet->m_headerType = RTMP_PACKET_SIZE_LARGE;
        self->rtmp.bIsFirstPacket = tbi_true;
    }
    else
    {
        self->rtmp.startTimeStamp += self->codec->audio.pTime * self->publisherframesCount;
        packet->m_nTimeStamp = self->rtmp.startTimeStamp;
        packet->m_headerType = RTMP_PACKET_SIZE_MEDIUM;
    }
    
    packet->m_nBodySize = size + 1;
    //    packet->m_nBodySize = self->frameBufSize + 1;
    
    RTMPPacket_Alloc(packet, packet->m_nBodySize);
    
    packet->m_body[0] = self->codec->format;
    //    memcpy(packet->m_body + 1, self->frameBuffer, self->frameBufSize);
    memcpy(packet->m_body + 1, buffer, size);
    
    if(!RTMP_SendPacket(self->rtmp.r, packet, 0)){
        TBI_DEBUG_ERROR("package send failed -- RTMP_SendPacket(manager->rtmp_media, packet, 0)\n");
    }
    
    TBI_OBJECT_SAFE_FREE(packet);
    
    self->startPos = self->frameBuffer;
    self->framesCount = 0;
    
    return 0;
}

//void media_audio_session_SetData(media_audio_session_t* self, void* in_data, int in_size)
//{
//    if(self && self->producer.droping)
//        return;
//    TBI_mutex_lock(self->producer.mutex);
//    if(self && self->producer.audioQ_buffer)
//        speex_buffer_write(self->producer.audioQ_buffer, (void*)in_data, in_size);
//    TBI_mutex_unlock(self->producer.mutex);
//    
//    
//    if(self->producer.audioSender && self->producer.needUse){
//        self->producer.needUse = tbi_false;
//        TBI_semaphore_increment(self->producer.audioSender);
//    }
//}

void media_audio_session_SetData(media_audio_session_t* self, void* in_data, int in_size)
{
    if(!in_data || !in_size || !self->producer.isRunning)
        return;
    
    audio_data_list_t* data_list = malloc(sizeof(audio_data_list_t));
    data_list->next = 0;
    data_list->size = in_size;
    data_list->buffer = malloc(data_list->size);
    memcpy(data_list->buffer, in_data, in_size);
    
    if(self->audio_data_last)
    {
        self->audio_data_last->next = data_list;
        self->audio_data_last = self->audio_data_last->next;
    }
    else
    {
        self->audio_data_last = data_list;
    }
    
    if(!self->audio_data_first)
        self->audio_data_first = self->audio_data_last;
    
    TBI_semaphore_increment(self->producer.audioSender);
}

void media_audio_session_increase(media_audio_session_t* self, double data)
{
    if(self->codec->bitrate_change)
        self->codec->bitrate_change(self->codec, tbi_false,data);
}

void media_audio_session_decrease(media_audio_session_t* self, double data)
{
    if(self->codec->bitrate_change)
        self->codec->bitrate_change(self->codec, tbi_true,data);
}

TBI_size_t encode(media_audio_session_t* self, const void* in_data, TBI_size_t in_size, void** out_data, TBI_size_t* out_max_size)
{
    int size = 0;
    if(self && self->codec){

        
        size= self->codec->encode(self->codec, in_data, in_size, out_data, out_max_size);
        
//        char *filePath = "/var/mobile/Applications/D5AA0930-40C2-4C5C-B9A9-6697EB30CA13/Documents/speex.pcm";
//        
//        static FILE* audio_file = 0;
//        static int k = 0 ;
//        if(k<500){
//            k++;
//            if(!audio_file)
//                audio_file =  fopen(filePath, "wb");
//            
//            if(audio_file){
//                fwrite(out_data, size, sizeof(char), audio_file);
//            }
//        }else{
//            if(audio_file){
//                fclose(audio_file);
//                //NSLog(@"__handle_input_buffer ENDDDDD-----");
//            }
//        }
    }
    
    
    return size;
    
}

TBI_size_t decode(media_audio_session_t* self, const void* in_data, TBI_size_t in_size, void** out_data, TBI_size_t* out_max_size)
{
//    static FILE *audio_file = 0;
//    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath]
//                                     stringByAppendingPathComponent:@"speex.dat"];
//    char *path = "/var/mobile/Applications/AF5C1B6E-487F-42D0-A421-CAE7F841D9C2/Seequ.app/speex2.dat" ;
//
//    if(!audio_file){
//        audio_file = fopen(path, "rb");
//    }
//    void *audio_data = malloc(in_size);
//    fprintf(stderr, "------------ %i",in_size);
//    
//    if(audio_file!=0){
//        fread(audio_data, in_size, sizeof(char), audio_file);
//    }
    
    return self->codec->decode(self->codec, in_data,in_size,out_data,out_max_size);
}

void media_audio_session_set_receied_data(media_audio_session_t* self, void *buffer, int buffer_size)
{
#ifdef JITTER_BUFFER_ENABLED
    void *temp_buffer = malloc(buffer_size);
    memcpy(temp_buffer, buffer, buffer_size);
    tdav_consumer_audiounit_put(self, temp_buffer, buffer_size);
#else
   // speex_buffer_write(self->SpeexReceived_buffer, buffer, buffer_size);
    put_audio_buffer(self->received_buffer, buffer, buffer_size, self->rtmp.r->nDataSize);
    
#endif
}

int media_audio_session_get_receied_data(media_audio_session_t* self, void *buffer, int buffer_size)
{
#ifdef JITTER_BUFFER_ENABLED
    return tdav_consumer_audiounit_get(self, buffer, buffer_size);
#else
    //return     speex_buffer_read(self->SpeexReceived_buffer, buffer, buffer_size);
    return pop_audio_buffer(self->received_buffer, buffer, buffer_size);
#endif
}

void media_audio_session_handle_packet(media_audio_session_t* self, RTMPPacket *packet)
{
//    media_audio_session_t* self = (media_audio_session_t*)callback;
//    int d = 0;
//    uint64_t et = TBI_time_epoch();
//    if(self->st == 0)
//    {
//        self->max = -1;
//        self->min = -1;
//        self->cnt = 0;
//        self->m = 0;
//        self->t1 = self->st = et;
//    }
//    else
//    {
//        d = et - self->st;
//        if(self->min == -1)
//        {
//            self->min = d;
//        }
//        else if(self->min > d)
//        {
//            self->min =  d;
//        }
//        if(self->max == -1)
//        {
//            self->max = d;
//        }
//        else if(self->max < d)
//        {
//            self->max =  d;
//        }
//    }
//    
//    self->cnt++;
//    self->m += d;
//    
//    if(et - self->t1 >= 1000)
//    {
//        fprintf(stderr, "=============, min = %d | max = %.4d | avr = %.2f\n", self->min, self->max, (double)self->m/(double)self->cnt);
//        self->max = -1;
//        self->min = -1;
//        self->m = 0;
//        self->cnt = 0;
//        self->t1 = et;
//    }
//    self->st = et;
    
    if (self)
    {
        if(self->last_audio_status == RTMP_STATUS_NO_AUDIO)
        {
            self->last_audio_status = 0 ;
            
            rtmp_event_t *event =  (rtmp_event_t*)TBI_object_new(rtmp_event_def_t);
            event->messageType = TBI_strdup("Audio reconnected\n");
            event->rtmp_call_event = RTMP_STATUS_AUDIO_RECONNECTED;
            
            if(self->statusCallback && self->callbackData)
                self->statusCallback(self->callbackData, (void*)event);
            TBI_OBJECT_SAFE_FREE(event);
        }

        // increase decrease mechanizm *******************************
        uint64_t currentTime = TBI_time_epoch();
        if(self->lastPacketTS > 0)
        {
            if((currentTime - self->lastPacketTS) > (self->packetTime + AUDIO_TIME_COIFFICENT)){
                
                self->rettPacketCnt++;
            }
            else
            {
                self->nonerettPacketCnt++;
            }
        }
        self->lastPacketTS = currentTime;

        if(self->startTime == 0)
        {
            self->startTime = currentTime;
        }
        else if(currentTime - self->startTime >= AUDIO_LOST_CALC_TIME)
        {
            float percentage = (float)self->rettPacketCnt/(float)(self->rettPacketCnt + self->nonerettPacketCnt) * 100.f;
            //fprintf(stderr, "belated packets percentage: %f\n", percentage);
//            int n = 1;
            
            //fprintf(stderr, "retransmition ******************************** percentage %f \n",percentage);
//            if(percentage > 2)
//            {
//                if(self->bitrate > 20)
//                {
//                    self->bitrate -= 20;
//                   // fprintf(stderr, "DECREASE %d\n",  self->bitrate);
//                    if(self->callback && self->callbackData){
//                      self->callback(self->callbackData, media_audio_decrease, (void*)&n, sizeof(n));
//                    }
//                }
//            }
//            else if(self->lastPercentage < 0.3 && percentage < 0.3)
//            {
//                if(self->bitrate < 740)
//                {
//                    self->bitrate += 20;
//                    //fprintf(stderr, "INCREASE %d\n",  self->bitrate);
//                    if(self->callback && self->callbackData)
//                      self->callback(self->callbackData, media_audio_increase, (void*)&n, sizeof(n));
//                }
//            }
            self->rettPacketCnt = 0;
            self->nonerettPacketCnt = 0;
            self->startTime = currentTime;
            self->lastPercentage = percentage;
        }
        // increase decrease mechanizm *******************************
        
//        int frameSz = (packet->m_nBodySize - 1)/self->playerframesCount;
//        char* frame = packet->m_body + 1;
//        
//        for (int i = 0; i < self->playerframesCount; i++)
//        {
//            int out_size = decode(self, frame, frameSz, &self->decoder.decode_buffer, &self->decoder.decode_buffer_size);
//            if(out_size)
//            {
//                media_audio_session_set_receied_data(self, self->decoder.decode_buffer, out_size);
//            }
//            frame += frameSz;
//        }
        
        self->audioSignalingPingTime = TBI_time_epoch();
        
        int out_size = decode(self, packet->m_body + 1, packet->m_nBodySize - 1, &self->decoder.decode_buffer, &self->decoder.decode_buffer_size);
        if(out_size)
        {
            //fprintf(stderr, "out_size %d\n",  out_size);
            self->lastPackageTime = TBI_time_epoch();
            media_audio_session_set_receied_data(self, self->decoder.decode_buffer, out_size);
        }
    }

    TBI_OBJECT_SAFE_FREE(packet);
}

static int __sender_thread_set_realtime(uint32_t ptime) {
    struct thread_time_constraint_policy policy;
//	int params [2] = {CTL_HW, HW_BUS_FREQ};
	int ret;
	
    
	// get bus frequence
	int /*freq_ns,*/ freq_ms;
    
    mach_timebase_info_data_t tbinfo;
    mach_timebase_info(&tbinfo);
    
    double clock2abs = ((double)tbinfo.denom / (double)tbinfo.numer) * 1000000;

//	size_t size = sizeof (freq_ns);
//	if((ret = sysctl (params, 2, &freq_ns, &size, NULL, 0))){
//		// check errno for more information
//		TBI_DEBUG_ERROR("sysctl() failed with error code=%d", ret);
//		return ret;
//	}
//	freq_ms = freq_ns/1000;
	freq_ms = clock2abs;
	/*
	 * THREAD_TIME_CONSTRAINT_POLICY:
	 *
	 * This scheduling mode is for threads which have real time
	 * constraints on their execution.
	 *
	 * Parameters:
	 *
	 * period: This is the nominal amount of time between separate
	 * processing arrivals, specified in absolute time units.  A
	 * value of 0 indicates that there is no inherent periodicity in
	 * the computation.
	 *
	 * computation: This is the nominal amount of computation
	 * time needed during a separate processing arrival, specified
	 * in absolute time units.
	 *
	 * constraint: This is the maximum amount of real time that
	 * may elapse from the start of a separate processing arrival
	 * to the end of computation for logically correct functioning,
	 * specified in absolute time units.  Must be (>= computation).
	 * Note that latency = (constraint - computation).
	 *
	 * preemptible: This indicates that the computation may be
	 * interrupted, subject to the constraint specified above.
	 */
	policy.period = (ptime/2) * freq_ms; // Half of the ptime
	policy.computation = 2 * freq_ms;
	policy.constraint = 3 * freq_ms;
	policy.preemptible = tbi_true;
	
	if ((ret = thread_policy_set(mach_thread_self(),
                                 THREAD_TIME_CONSTRAINT_POLICY, (int *)&policy,
                                 THREAD_TIME_CONSTRAINT_POLICY_COUNT)) != KERN_SUCCESS) {
		TBI_DEBUG_ERROR("thread_policy_set failed(period=%u,computation=%u,constraint=%u) failed with error code= %d",
						policy.period, policy.computation, policy.constraint,
						ret);
		return ret;
	}
	return 0;
}

static void *__sender_thread_opus(void *param)
{
//    return 0;
	TBI_DEBUG_INFO("__sender_thread_opus::ENTER");
//    usleep(20000);
    media_audio_session_t* audio = (media_audio_session_t*)param;
	uint32_t ptime = audio->codec->audio.pTime;
	
	// interval to sleep when using nonosleep() instead of conditional variable
	struct timespec interval;
	interval.tv_sec = (long)(ptime/1000);
	interval.tv_nsec = (long)(ptime%1000) * 1000000;
	
	// change thread priority
	__sender_thread_set_realtime(ptime);
    
    uint32_t size = 2 * audio->codec->rate/1000 * ptime;
    int out_size = 0;
    int enc_size = 0;

    audio->encode.total_buffer = malloc(1200);
    char test[1600];
    int testSize = 0;

    audio_data_list_t* audio_data_current = 0;
    
	// starts looping
	while (audio && audio->producer.isRunning)
    {
        TBI_semaphore_decrement(audio->producer.audioSender);
        if(!audio->lockForReconnect)
        {
            if(!audio_data_current)
            {
                if(audio->audio_data_first)
                {
                    audio_data_current = audio->audio_data_first;
                }
            }
            else if(audio_data_current->next)
            {
                audio_data_current = audio_data_current->next;
                free(audio->audio_data_first->buffer); audio->audio_data_first->buffer = 0;
                free(audio->audio_data_first);
                audio->audio_data_first = audio_data_current;
            }
            
            if(audio_data_current)
            {
                memcpy(test + testSize, audio_data_current->buffer, audio_data_current->size);
                testSize += audio_data_current->size;
                if(!audio->codec)
                    break;
                
                while (testSize >= size && out_size < audio->codec->audio.codec_frame_size * (audio->publisherframesCount + 1))
                {
                    enc_size = encode(audio, test, size, &audio->encode.encode_buffer, &audio->encode.encode_buffer_size);
                    if(enc_size > 0)
                    {
                        memcpy(audio->encode.total_buffer + out_size, audio->encode.encode_buffer, enc_size);
                        out_size += enc_size;
                    }
                    testSize -= size;
                    memmove(test, test + size, testSize);
                }
                if(out_size >=audio->codec->audio.codec_frame_size * audio->publisherframesCount)
                {
                    media_audio_session_send_opus(audio, audio->encode.total_buffer, out_size);
                    out_size= 0;
                }
            }
        }
    }
    free(audio->encode.total_buffer);
    
	TBI_DEBUG_INFO("AUDIO: __sender_thread_opus::EXIT");
	return TBI_null;
}

static void *__sender_thread_opus1(void *param)
{
	TBI_DEBUG_INFO("__sender_thread::ENTER");
    usleep(20000);
    media_audio_session_t* audio = (media_audio_session_t*)param;
	uint32_t ptime = audio->codec->audio.pTime;
	TBI_ssize_t avail;
	
	// interval to sleep when using nonosleep() instead of conditional variable
	struct timespec interval;
	interval.tv_sec = (long)(ptime/1000);
	interval.tv_nsec = (long)(ptime%1000) * 1000000;
	
	// change thread priority
	__sender_thread_set_realtime(ptime);
    
    uint32_t size = 2 * audio->codec->rate/1000 * ptime;
    uint8_t buffer[size];
    int out_size = 0;
    int enc_size = 0;
    audio->encode.total_buffer = malloc(600);
	// starts looping
	while (audio && audio->producer.isRunning)
    {
        //nanosleep(&interval, 0);
        TBI_semaphore_decrement(audio->producer.audioSender);
        
		// read data and send them
        avail = speex_buffer_get_available(audio->producer.audioQ_buffer);
        TBI_mutex_lock(audio->producer.mutex);
        while(avail >= size)
        {
            if(size==0) {
                TBI_DEBUG_INFO("while (audio && audio) *********** %d %d",size,avail);
            }
            
            avail -= speex_buffer_read(audio->producer.audioQ_buffer, buffer, size);
            enc_size= encode(audio, buffer, size, &audio->encode.encode_buffer, &audio->encode.encode_buffer_size);
            
            memcpy(audio->encode.total_buffer+out_size, audio->encode.encode_buffer, enc_size);
            out_size+=enc_size;
            // TBI_DEBUG_ERROR("__sender_thread_opus");

        }
        TBI_mutex_unlock(audio->producer.mutex);
        audio->producer.needUse = tbi_true;
        
        if(out_size >=audio->codec->audio.codec_frame_size*2)
        {
            if(out_size>audio->codec->audio.codec_frame_size*3)
            {
                TBI_DEBUG_INFO("__sender_thread-opus::ENTER *********** %d",out_size);
            }
            media_audio_session_send_opus(audio, audio->encode.total_buffer, out_size);
            out_size= 0;
        }
    }
    free(audio->encode.total_buffer);
	TBI_DEBUG_INFO("AUDIO: __sender_thread::EXIT");
	return TBI_null;
}

static void *__sender_thread_g729(void *param)
{
	TBI_DEBUG_INFO("__sender_thread::ENTER");
	
	media_audio_session_t* audio = (media_audio_session_t*)param;
	uint32_t ptime = audio->codec->audio.pTime;
	TBI_ssize_t avail;
	
	// interval to sleep when using nonosleep() instead of conditional variable
    int rpTime = ptime * audio->publisherframesCount;
    
	struct timespec interval;
	interval.tv_sec = (long)(ptime/1000);
	interval.tv_nsec = (long)((ptime - 5)%1000) * 1000000;

	// change thread priority
	__sender_thread_set_realtime(rpTime);
    
//    uint32_t size = 2 * audio->codec->rate/1000 * ptime;
    uint32_t size = 2 * audio->codec->rate/1000 * rpTime;
    uint8_t* buffer = calloc(1, size);
    
	// starts looping
	while (audio && audio->producer.isRunning)
    {
        nanosleep(&interval, 0);

		// read data and send them
        avail = speex_buffer_get_available(audio->producer.audioQ_buffer);
        if (avail >= size)
        {
            TBI_mutex_lock(audio->producer.mutex);
            avail -= speex_buffer_read(audio->producer.audioQ_buffer, buffer, size);
            TBI_mutex_unlock(audio->producer.mutex);
            int out_size = encode(audio, buffer, size, &audio->encode.encode_buffer, &audio->encode.encode_buffer_size);
            if(out_size > 0)
            {
                media_audio_session_send_g729(audio, audio->encode.encode_buffer, out_size);
            }
        }
    }
    
    free(buffer);
    
	TBI_DEBUG_INFO("AUDIO: __sender_thread::EXIT");
	return TBI_null;
}

static void *__sender_thread(void *param)
{
	TBI_DEBUG_INFO("__sender_thread::ENTER");
    media_audio_session_t* audio = (media_audio_session_t*)param;
	uint32_t ptime = audio->codec->audio.pTime;
	
	// change thread priority
	__sender_thread_set_realtime(ptime);
    
    uint32_t size = 2 * audio->codec->rate/1000 * ptime;
    int out_size = 0;
    
    audio->encode.total_buffer = malloc(1200);
    char test[2048];
    int testSize = 0, enc_size = 0;
    int collectTime = 0;
    
    audio_data_list_t* audio_data_current = 0;
    
	// starts looping
	while (audio && audio->producer.isRunning)
    {
        TBI_semaphore_decrement(audio->producer.audioSender);
        if(!audio_data_current)
        {
            if(audio->audio_data_first)
            {
                audio_data_current = audio->audio_data_first;
            }
        }
        else if(audio_data_current->next)
        {
            audio_data_current = audio_data_current->next;
            free(audio->audio_data_first->buffer); audio->audio_data_first->buffer = 0;
            free(audio->audio_data_first);
            audio->audio_data_first = audio_data_current;
        }

        if(audio_data_current)
        {
            memcpy(test + testSize, audio_data_current->buffer, audio_data_current->size);
            testSize += audio_data_current->size;
            while (testSize >= size && collectTime < (audio->publisherframesCount + 1) * audio->codec->audio.pTime)
            {
                enc_size = encode(audio, test, size, &audio->encode.encode_buffer, &audio->encode.encode_buffer_size);
                if(enc_size > 0)
                {
                    memcpy(audio->encode.total_buffer + out_size, audio->encode.encode_buffer, enc_size);
                    out_size += enc_size;
                    collectTime += ptime;
                }
                testSize -= size;
                memmove(test, test + size, testSize);
            }
            if(collectTime >= audio->publisherframesCount * audio->codec->audio.pTime)
            {
                media_audio_session_send_wo_collect(audio, audio->encode.total_buffer, out_size);
                out_size = 0;
                collectTime = 0;
            }
        }
    }

    free(audio->encode.total_buffer);
	TBI_DEBUG_INFO("AUDIO: __sender_thread::EXIT");
	return TBI_null;
}


static void *__sender_thread1(void *param)
{
	TBI_DEBUG_INFO("__sender_thread::ENTER");
	usleep(50000);
	media_audio_session_t* audio = (media_audio_session_t*)param;
	uint32_t ptime = audio->codec->audio.pTime;
	TBI_ssize_t avail;
	
	// interval to sleep when using nonosleep() instead of conditional variable
	struct timespec interval;
	interval.tv_sec = (long)(ptime/1000);
	interval.tv_nsec = (long)(ptime%1000) * 1000000;
	
	// change thread priority
	__sender_thread_set_realtime(ptime);
    
    uint32_t size = 2 * audio->codec->rate/1000 * ptime;
    uint8_t buffer[size];
	
	// starts looping
	while (audio && audio->producer.isRunning) {
		// wait for "ptime" milliseconds
        //		if(ptime <= kMaxPtimeBeforeUsingCondVars){
        nanosleep(&interval, 0);
        //		}
        //		else {
        //			tsk_condwait_timedwait(producer->senderCondWait, (uint64_t)ptime);
        //		}
		// check state
        //		if(!producer->started){
        //			break;
        //		}
		// read data and send them
//		if(audio->producer.sender_callback) {
			
			avail = speex_buffer_get_available(audio->producer.audioQ_buffer);

            TBI_mutex_lock(audio->producer.mutex);
        
			while (avail >= size && size>0)
            {
               
				avail -= speex_buffer_read(audio->producer.audioQ_buffer, buffer, size);
                
                int out_size = encode(audio, buffer, size, &audio->encode.encode_buffer, &audio->encode.encode_buffer_size);
                if(out_size > 0)
                    media_audio_session_send(audio, audio->encode.encode_buffer, out_size);
			}
        
			TBI_mutex_unlock(audio->producer.mutex);


//		}
        //		else;
	}
	TBI_DEBUG_INFO("__sender_thread::EXIT");
	return TBI_null;
}


void media_audio_session_status_cb(void* param, rtmp_event_t *event)
{
    if(!param || !event)
        return;
    
    media_audio_session_t* self = (media_audio_session_t*)param;
    if(event->rtmp_call_event == RTMP_EVENT_AUDIODATA)
    {
        media_audio_session_handle_packet(self, event->packet);
    }
    else if(event->rtmp_call_event == RTMP_EVENT_CONNECTED)
    {
        native_debug_function("AUDIO: RTMP_EVENT_CONNECTED");
        self->rtmp.state = AUDIO_RTMP_STATE_CONNECTED;
        
        self->rtmp.connectionTimeStamp = RTMP_GetTime();
    }
}

TBI_size_t tdav_consumer_audiounit_get(media_audio_session_t* self, void* data, TBI_size_t size)
{
    ////    self->codec->audo_paskage_header->seq_num++;
    ////    self->codec->audo_paskage_header->timestamp+=20;
    //    TBI_mutex_lock(self->ring.mutex);
    //	TBI_ssize_t retSize = 0;
    //        self->ring.leftBytes += size;
    //        while (self->ring.leftBytes >= self->ring.chunck.size) {
    //            self->ring.leftBytes -= self->ring.chunck.size;
    //            retSize =  (TBI_ssize_t)tdav_speakup_jitterbuffer_get(self->jitter_buffer, self->ring.chunck.buffer, self->ring.chunck.size, self->codec->audo_paskage_header);
    //            speex_buffer_write(self->ring.buffer, self->ring.chunck.buffer, retSize);
    //        }
    //        retSize = speex_buffer_read(self->ring.buffer, data, size);
    //        if(retSize < size){
    //            memset(((uint8_t*)data)+retSize, 0, (size - retSize));
    //        }
    //    TBI_mutex_unlock(self->ring.mutex);
    //    printf("%i \n",retSize);
    //
    //	return retSize;
    //}
    //TBI_size_t tdav_consumer_audiounit_put(media_audio_session_t* self, void* data, TBI_size_t size){
    //    self->codec->audo_paskage_header->seq_num++;
    //    self->codec->audo_paskage_header->timestamp+=20;
    //    TBI_mutex_lock(self->ring.mutex);
    //        int size_1 = tdav_speakup_jitterbuffer_put(self->jitter_buffer,data,size,self->codec->audo_paskage_header);
    //    TBI_mutex_unlock(self->ring.mutex);
    //    return size_1;
    return 0;
}
