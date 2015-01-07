//
//  media_video_session.h
//  TBIRTMP
//
//  Created by Administrator on 10/31/12.
//  Copyright (c) 2012 Grigori Jlavyan. All rights reserved.
//

#ifndef TBIRTMP_media_video_session_h
#define TBIRTMP_media_video_session_h

#include "../../utils/types.h"
#include "media_codec_h264.h"
#include "rtmp.h"
#include "TBI_semaphore.h"
#include "TBI_list.h"
#include "mpeg4.h"
#include "media_converter_video_neon.h"

typedef enum media_video_event_s
{
    media_video_unknown = -1,
    media_video_increase,
    media_video_decrease
}media_video_event_t;

typedef void (*media_video_callback)(void* callbackData, media_video_event_t event, double data);

typedef void (*media_callback)(void* callbackData);


typedef int (*_send_video_callback)(void* callbackData, const void* buffer, int size);
typedef int (*_consume_video_callback)(void* callbackData, const void* buffer, int size, int width, int height);
typedef struct {
    int width;
    int height;
    int fps;
    video_size_type video_type;
} resolution_t;



typedef struct media_video_session_s
{
    uint64_t sessionId;
    char* codecFormat;
    
    _send_video_callback senderCallback;
    void* senderCallbackData;
    
    media_codec_t* codec;
    
    struct {
        void* buffer;
        unsigned int buffer_size;
    } encoder;

    struct {
        void* buffer;
        unsigned int buffer_size;
    } decoder;
    
    _consume_video_callback consumerCallback;
    void* consumerCallbackData;
    
    struct {
        RTMP* r;
        uint64_t connectionTimeStamp;
        TBI_semaphore_handle_t* sem;
        TBI_list_t* packets;
        tbi_bool_t bIsStarted;
        tbi_bool_t bStartPlayPublish;
        void *threadId[3];
        int state;

        char *spspps;
        unsigned int spsppsSize;
        
        uint32_t chankSize;
        
        tbi_bool_t bIsFirstPacket;
        int isDrop;
    } rtmp;
    tbi_bool_t bStartConnect;
    
    struct{
        resolution_t send;
        resolution_t receive;
    } video;
    
    int network_type;
    int internet_type;
    int32_t time_correction;
    
    int64_t firstPacketSendTime;
    int64_t lastPacketSendTime;
    int32_t lastTimeStamp;
    
    rtmp_video_stat_t *stat;
    char *tmpPlayName ;
    char *tmpPublishName ;
    
    int playerFrameCount;
    int publisherFrameCount;
    
    tbi_bool_t isReconnecting;
    
    double current_network_status;
} media_video_session_t;
void media_video_session_ini_video_size(resolution_t* self);

int media_video_session_create(media_video_session_t **obj,char* url, const char* codecFormat,media_video_callback callback, void* callbackData);
int media_video_session_reStart(media_video_session_t* self, const char* playName, const char* publishName, char* codecFormat);
int media_video_session_reConnect(media_video_session_t* self, const char* playName, const char* publishName, char* codecFormat);
int media_video_session_get_vp8_bitrate(media_video_session_t* self);
;
void media_video_session_Destroy(media_video_session_t** self);
int media_video_session_Start(media_video_session_t* self, const char* playName, const char* publishName, char* codecFormat);
int media_video_session_send(media_video_session_t* self, const void* buffer, int size);
int media_video_session_Consume(media_video_session_t* self, const void* data, unsigned int dataSize);
void media_video_session_setSenderCallback(media_video_session_t* self, _send_video_callback callback, void* callbackData);
void media_video_session_setConsumerCallback(media_video_session_t* self, _consume_video_callback callback, void* callbackData);
int  media_video_session_get_video_settings(const char* file_name, int number);
int media_video_session_send_package(media_video_session_t* self, const void* buffer, int size);
void media_video_session_increase(media_video_session_t* self, double data);
void media_video_session_decrease(media_video_session_t* self, double data);
int media_video_session_send_vp8_bitrate(media_video_session_t* self);
int media_video_session_changechanksize(media_video_session_t* self, tbi_bool_t up);

#endif
