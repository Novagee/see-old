//
//  media_audio_session.h
//  TBIRTMP
//
//  Created by Grigori Jlavyan on 11/6/12.
//  Copyright (c) 2012 Grigori Jlavyan. All rights reserved.
//

#ifndef TBIRTMP_media_audio_session_h
#define TBIRTMP_media_audio_session_h

#include "media_audio_buffer.h"
#include "media_codec.h"
#include "rtmp.h"
#include "TBI_semaphore.h"
#include <speex/speex_buffer.h>
#include "tdav_speakup_jitterbuffer.h"
#include "TBI_list.h"

typedef enum media_audio_event_s
{
    media_audio_increase,
    media_audio_decrease
}media_audio_event_t;


typedef void (*media_audio_callback)(void* callbackData, media_audio_event_t event, void* data, int size);

typedef struct audio_data_list_s
{
    uint8_t*                    buffer;
    int                         size;
    struct audio_data_list_s*   next;
} audio_data_list_t;

typedef struct media_audio_session_s {
    //media_audio_buffer_t *send_buffer;
    media_audio_buffer_t *received_buffer;
    SpeexBuffer * SpeexReceived_buffer;
    struct{
        void* decode_buffer;
        TBI_size_t decode_buffer_size;
        int framecount;
    } decoder;
    struct{
        void* encode_buffer;
        void* total_buffer;
        
        TBI_size_t encode_buffer_size;
        int framecount;
    } encode;
    struct{
        SpeexBuffer *audioQ_buffer;
        TBI_mutex_handle_t *mutex;
//        TBI_semaphore_handle_t* sem;
        TBI_semaphore_handle_t* audioSender;
        tbi_bool_t needUse;
        void* threadId;
        tbi_bool_t isRunning;
        tbi_bool_t droping;
    } producer;
    struct {
        RTMP* r;
        uint32_t connectionTimeStamp;
        uint32_t startTimeStamp;
        TBI_semaphore_handle_t* sem;
        TBI_list_t* packets;
        tbi_bool_t bIsStarted;
        tbi_bool_t bStartPlayPublish;
        void *threadId[2];
        int state;
        
        char *spspps;
        unsigned int spsppsSize;
        
        tbi_bool_t bIsFirstPacket;
        tbi_bool_t isReconnected;
        int isDrop;
        TBI_mutex_handle_t *mutex;
        
        tbi_bool_t bIsOwn;
    } rtmp;
    
    tbi_bool_t bStartConnect;
    
    int publisherframesCount;
    int playerframesCount;
    uint8_t* frameBuffer;
    int frameBufSize;
    uint8_t* startPos;
    int framesCount;
    
    int64_t audioSignalingPingTime;
    
    int lockForReconnect;
    
    media_codec_t* codec;

//    uint64_t st, t1;
//    uint64_t m;
//    int min;
//    int max;
//    int cnt;

    uint64_t startTime;
    uint64_t lastPacketTS;
    uint32_t packetTime;
    uint32_t rettPacketCnt;
    uint32_t nonerettPacketCnt;
    float lastPercentage;
    
    media_audio_callback callback;
    receiveCallback statusCallback;
    void* callbackData;
    
    
    int bitrate;
    
    audio_data_list_t* audio_data_first;
    audio_data_list_t* audio_data_last;

    //calculate video time
    uint64_t videoStartTime;
    
    rtmp_video_stat_t *stat;
    
    
    char *tmpPlayName ;
    char *tmpPublishName ;
    
    int playerFrameCount;
    int publisherFrameCount;
    char*uid;
    
    TBI_mutex_handle_t *restart;
    
    int media_audion_connection_status;

    int media_audion_connection_received_package;
    uint64_t lastPackageTime;
    enum RTMP_EVENT_TYPE last_audio_status;
    tbi_bool_t isHold ;
} media_audio_session_t;
media_audio_session_t* media_audio_session_restart(media_audio_session_t *self,char* url, media_audio_callback callback, void* callbackData);
int media_audio_session_reConnect(media_audio_session_t* self, const char* playName, const char* publishName, const char* codecFormat, int playFrameCnt, int publishFrameCnt);

int media_audio_session_create(media_audio_session_t **obj,char* url, media_audio_callback callback, receiveCallback statusCallback, void* callbackData,const char *uid);
int media_audio_session_reStart(media_audio_session_t* self, const char* playName, const char* publishName, const char* codecFormat, int playFrameCnt, int publishFrameCnt);
void media_audio_session_Destroy(media_audio_session_t** self);
int media_audio_session_Start(media_audio_session_t* self, const char* playName, const char* publishName, const char* codecFormat, int playFrameCnt, int publishFrameCnt, RTMP* r);
int media_audio_session_send(media_audio_session_t* self, const void* buffer, int size);
int media_audio_session_get_receied_data(media_audio_session_t* self, void *buffer, int buffer_size);
void media_audio_session_SetData(media_audio_session_t* self, void* in_data, int in_size);
void media_audio_session_increase(media_audio_session_t* self, double data);
void media_audio_session_decrease(media_audio_session_t* self, double data);
void media_audio_session_handle_packet(media_audio_session_t* self, RTMPPacket *packet);
;
#endif
