//
//  media_video_session.c
//  TBIRTMP
//
//  Created by Administrator on 10/31/12.
//  Copyright (c) 2012 Grigori Jlavyan. All rights reserved.
//

#include "media_video_session.h"
#include "TBI_thread.h"
#include "TBI_string.h"
#include "TBIRTMP.h"
#include "mpeg4.h"
#include "media_codec_vp8.h"
#include "utlis.h"

#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>

#define RTMP_VIDEO_CHANKSIZE            900
#define RTMP_VIDEO_MIN_BITRATE          120
#define RTMP_VIDEO_MAX_BITRATE          700
#define RTMP_MAX_CHECK_TIME_COIFF       2.0
#define RTMP_STATISTICS_MIN_DTIME       0
#define RTMP_STATISTICS_MAX_DTIME       150

#define RANGE1(M)       (M > 0.9 && M <= 2)
#define RANGE2(M)       (M > 2 && M <= 4)
#define RANGE3(M)       (M > 4 && M <= 5)
#define RANGE4(M)       (M > 16 && M <= 24)
#define RANGE5(M)       (M > 24 && M <= 31)
#define RANGE6(M)       (M > 31)

#define RANGE1_COIFF    1.2
#define RANGE2_COIFF    1.2
#define RANGE3_COIFF    1.1
#define RANGE4_COIFF    1.1
#define RANGE5_COIFF    1.3
#define RANGE6_COIFF    1.6

#define DECREASE_COIFF  1.3

enum video_rtmp_state{
    VIDEO_RTMP_STATE_UNKNOWN,
    VIDEO_RTMP_STATE_DISCONNECTED,
    VIDEO_RTMP_STATE_HANDSHAKEFINISH,
    VIDEO_RTMP_STATE_CONNECTING,
    VIDEO_RTMP_STATE_CONNECTED
};

extern uint8_t H264_START_CODE_PREFIX[4];
const double videoAcceleration = 0.65;

void media_video_session_status_cb(void* param, rtmp_event_t *event);
void media_video_session_handle_packet(void* callback, RTMPPacket *packet);

int addpacketcomplitiondata(rtmp_video_stat_t* stat, uint64_t complitionTime)
{
    if(!stat)
        return 0;
    
    if(stat->packetCount == stat->maxPacketCount)
    {
        stat->packetCount--;
        for (int i = 0; i < stat->packetCount; i++)
        {
            stat->packetCompletionTimes[i] = stat->packetCompletionTimes[i + 1];
        }
    }
    
    stat->packetCompletionTimes[stat->packetCount] = complitionTime;
    stat->packetCount++;
    
    return stat->packetCount;
}

float calculateAdaptive(const uint64_t* complitionTimeList, int count)
{
    int cnt = 0;
    int deltaSUM = 0;
    for(int i = 0; i < count; i++)
    {
        if(complitionTimeList[i] > RTMP_STATISTICS_MIN_DTIME && complitionTimeList[i] <= RTMP_STATISTICS_MAX_DTIME)
        {
            deltaSUM += complitionTimeList[i];
            cnt++;
        }
    }

    return cnt ? (double)deltaSUM/(double)cnt : 0.f;
}

static void media_video_session_checkbindwith(media_video_session_t* self)
{
    if(self && self->stat)
    {
        media_video_event_t event = media_video_unknown;
        int32_t bitrate = 0;
        double f, coiff = 0;
        tbi_bool_t bIncrease = TBI_false;

        uint64_t currentTime = TBI_time_epoch();
        
        if(self->stat->lastPacketRecvTime == 0)
            self->stat->lastPacketRecvTime = currentTime;
        
        if(currentTime - self->stat->lastPacketRecvTime > 400)
        {
            bitrate = TBI_MAX(MIN_BITRATE, self->stat->remoteBitrate / DECREASE_COIFF);
            f = (double)(bitrate - self->stat->remoteBitrate);
            self->stat->remoteBitrate = bitrate;
            
            media_video_callback callback = self->stat->callback;
            if(f && callback)
            {
                printf("DECREASE(%.2f)!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n", f);
                callback(self->stat->callbackData, media_video_decrease, f);
            }
        }
        
        self->stat->lastPacketRecvTime = currentTime;

        self->stat->adaptiveValue += calculateAdaptive(self->stat->packetCompletionTimes, self->stat->packetCount);
        
        self->stat->playedFrameCount++;
        if(self->stat->playedFrameCount == self->stat->checkTime)
        {
            float m = self->stat->adaptiveValue/(float)self->stat->playedFrameCount;
            printf("adaptive value == %.2f remote bitrate == %d\n", m, self->stat->remoteBitrate);
            if(RANGE1(m))
            {
                coiff = RANGE1_COIFF;
                bIncrease = TBI_true;
            }
            else if(RANGE2(m))
            {
                coiff = RANGE2_COIFF;
                bIncrease = TBI_true;
            }
            else if(RANGE3(m))
            {
                coiff = RANGE3_COIFF;
                bIncrease = TBI_true;
            }
            //===============
            else if(RANGE4(m))
            {
                coiff = RANGE4_COIFF;
                bIncrease = TBI_false;
            }
            else if(RANGE5(m))
            {
                coiff = RANGE5_COIFF;
                bIncrease = TBI_false;
            }
            else if(RANGE6(m))
            {
                coiff = RANGE6_COIFF;
                bIncrease = TBI_false;
            }
            
            if(coiff > 0)
            {
                if(bIncrease)
                {
                    if(self->codec->get_bitrate)
                    {
                        int locBitRate = self->codec->get_bitrate(self->codec);
                        float ratio = (float)self->stat->remoteBitrate/(float)locBitRate;
                        if(self->stat->remoteBitrate < MAX_BITRATE && ratio < 1.6)
                        {
                            event = media_video_increase;
                            bitrate = TBI_MIN(MAX_BITRATE, self->stat->remoteBitrate * coiff);
                        }
                    }
                }
                else
                {
                    if(self->stat->remoteBitrate > MIN_BITRATE)
                    {
                        event = media_video_decrease;
                        bitrate = TBI_MAX(MIN_BITRATE, self->stat->remoteBitrate / coiff);
                    }
                }
                
                if(bitrate > 0)
                {
                    f = (double)(bitrate - self->stat->remoteBitrate);
                    self->stat->remoteBitrate = bitrate;
                    
                    media_video_callback callback = self->stat->callback;
                    if(f && callback)
                    {
                        if(f > 0)
                            printf("INCREASE(%.2f)!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n", f);
                        else
                            printf("DECREASE(%.2f)!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n", f);
                        
                        callback(self->stat->callbackData, event, f);
                    }
                }
                
            }
            
            self->stat->playedFrameCount = 0;
            self->stat->adaptiveValue = 0.f;
        }
    }
}

static void* media_video_session_receiver(void * param)
{
    RTMPPacket* packet = 0;
    media_video_session_t* self = (media_video_session_t*)param;
    if(!self)
        return 0;
    
    int bHasMediaPacket = 0;
    
    TBI_DEBUG_INFO("VIDEO: media_video_session_receiver::ENTER");
    
    while(self->rtmp.bIsStarted && self->rtmp.state < VIDEO_RTMP_STATE_HANDSHAKEFINISH)
    {
        usleep(50000);
    }
    
    while (self->rtmp.bIsStarted)
    {
        if(!RTMP_IsConnected(self->rtmp.r))
            break;
        
        packet = TBI_object_new(RTMPPacket_def_t);
        if(RTMP_ReadPacket(self->rtmp.r, packet) && RTMPPacket_IsReady(packet))
        {
            
            bHasMediaPacket = RTMP_ClientPacket(self->rtmp.r, packet);
            if(bHasMediaPacket)
            {
                if(packet->partCount > 1)
                    addpacketcomplitiondata(self->stat, packet->completeTime - packet->createTime);
                
                media_video_session_checkbindwith(self);
            }
        }
        TBI_OBJECT_SAFE_FREE(packet);
    }
    
    TBI_DEBUG_INFO("VIDEO: media_video_session_receiver::EXIT");
    return 0;
}

static void* media_video_session_connect(void * param)
{
    media_video_session_t *self = (media_video_session_t*)param;
    int n;
    TBI_DEBUG_INFO("VIDEO: media_video_session_connect::ENTER");
    
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
        
        self->rtmp.state = VIDEO_RTMP_STATE_HANDSHAKEFINISH;
        n = 150;
        while (self->rtmp.state != VIDEO_RTMP_STATE_CONNECTED && --n)
        {
            if (!self->bStartConnect)
                goto exit_thread;
            
            usleep(100000);
        }
        
        if(self->rtmp.state == VIDEO_RTMP_STATE_CONNECTED)
        {
            if(self->rtmp.bStartPlayPublish)
            { 
                RTMP_SendCreateStream(self->rtmp.r);
                RTMP_SendCreateStream(self->rtmp.r);
                self->rtmp.bStartPlayPublish = tbi_false;
            }
            break;
        }
        
        RTMP_Close(self->rtmp.r);
    }

    
exit_thread:
    TBI_DEBUG_INFO("VIDEO: media_video_session_connect::EXIT");
    self->bStartConnect = tbi_false;
    return 0;
}

void* media_video_session_packet_handler(void* param)
{
    rtmp_manager_t *manager =(rtmp_manager_t*)param;
    media_video_session_t* self = manager->videoSession;

    RTMPPacket* packet = TBI_null;
    if(self){
        TBI_DEBUG_INFO("[VIDEO] {media_video_session_packet_handler} START %d",self->rtmp.bIsStarted);
    }
    else
        TBI_DEBUG_INFO("[VIDEO] {media_video_session_packet_handler} START: SELF NULLL");
    
    while (self && self->rtmp.bIsStarted)
    {
        TBI_semaphore_decrement(self->rtmp.sem);
        if(!self->rtmp.bIsStarted)
            break;
        
        TBI_list_lock(self->rtmp.packets);

        TBI_list_item_t* item = TBI_list_pop_first_item(self->rtmp.packets);
        if( item )
        {
            packet = (RTMPPacket*)item->data;
            if(packet)
            {
                if(manager->isVideoReconnectiong && packet->m_packetType == 0x09)
                {
                    manager->isVideoReconnectiong = tbi_false;
                    rtmp_event_t *event =  (rtmp_event_t*)TBI_object_new(rtmp_event_def_t);
                    event->messageType = TBI_strdup("Video reconnected\n");
                    event->rtmp_call_event = RTMP_STATUS_VIDEO_RECONNECTED;
                    
                    if(manager->rtmp->onStatusCallback && manager->rtmp->callbackData)
                        manager->rtmp->onStatusCallback(manager->rtmp->callbackData, (void*)event);
                    TBI_OBJECT_SAFE_FREE(event);
                }
                media_video_session_handle_packet(self, packet);
            }
            TBI_object_unref(item);
        }
        
        TBI_list_unlock(self->rtmp.packets);
    }

	TBI_DEBUG_INFO("[VIDEO] {media_video_session_packet_handler} EXIT");
    return 0;
}

int  media_video_session_get_video_settings(const char* file_name , int number){
    return media_codec_h264_get_video_settings(file_name,number);
}

int media_video_session_create(media_video_session_t **obj, char* url, const char* codecFormat,media_video_callback callback, void* callbackData)
{
    (*obj) = (media_video_session_t*)TBI_calloc(1, sizeof(media_video_session_t));
    media_video_session_t *self = *obj;
    
    if(!self)
        return -1;
    self->isReconnecting = tbi_false;
    struct timeval tv;
    gettimeofday(&tv, 0);
    
    self->sessionId = tv.tv_sec * 1000 + tv.tv_usec/1000;
    self->rtmp.bIsFirstPacket = tbi_false;
    self->codec = 0;
    
    self->rtmp.chankSize = RTMP_VIDEO_CHANKSIZE/2;
    
    self->rtmp.r = RTMP_Alloc();
    if(!self->rtmp.r)
        return -1;
    
    RTMP_Init(self->rtmp.r, tbi_false, tbi_false, "VIDEO");
    TBI_RTMP_SetCallback(self->rtmp.r, media_video_session_status_cb, self);
    RTMP_SetupURL(self->rtmp.r, url);
    
    self->rtmp.state = RTMP_EVENT_TYPE_UNKNOWN;
    self->rtmp.bStartPlayPublish = tbi_false;

    self->current_network_status = -1 ;
    
    self->stat = TBI_calloc(1, sizeof(rtmp_video_stat_t));
    self->stat->lastPlayedFrameTime = 0 ;
    self->stat->callback = callback;
    self->stat->callbackData = callbackData;
    
    self->stat->packetCount = 0;
    self->stat->maxPacketCount = 0;
    self->stat->packetCompletionTimes = TBI_null;
    self->stat->playedFrameCount = 0;
    self->stat->checkTime = 0;
    self->stat->adaptiveValue = 0.f;
    self->stat->remoteBitrate = MIN_BITRATE;
    self->stat->lastPacketRecvTime = 0;
    
    self->encoder.buffer = TBI_null;
    self->encoder.buffer_size = 0;
    
    self->rtmp.connectionTimeStamp = TBI_time_epoch();
    self->rtmp.sem = TBI_semaphore_create();
    self->rtmp.packets = TBI_list_create();
    
    self->rtmp.bIsStarted = tbi_true;
    self->rtmp.isDrop = 0;
    TBI_thread_create(&self->rtmp.threadId[0], media_video_session_receiver, (void*)self);
    TBI_thread_create(&self->rtmp.threadId[1], media_video_session_packet_handler, callbackData);
    
    self->bStartConnect = tbi_true;
    TBI_thread_create(&self->rtmp.threadId[2], media_video_session_connect, (void*)self);
    
    return 0;
}

void media_video_session_Destroy(media_video_session_t** self)
{
    if(*self)
    {
        if((*self)->rtmp.r)
        {
            (*self)->bStartConnect = tbi_false;
            if((*self)->rtmp.threadId[2])
            {
                TBI_thread_join(&(*self)->rtmp.threadId[2]);
            }
            
            (*self)->rtmp.bIsStarted = tbi_false;
            RTMP_UserInterrupt((*self)->rtmp.r);
            RTMP_Close((*self)->rtmp.r);
            
            if((*self)->rtmp.threadId[1])
            {
                TBI_semaphore_increment((*self)->rtmp.sem);
                TBI_thread_join(&(*self)->rtmp.threadId[1]);
            }

            if((*self)->rtmp.threadId[0])
            {
                TBI_thread_join(&(*self)->rtmp.threadId[0]);
            }
            
            if((*self)->rtmp.sem)
            {
                TBI_semaphore_destroy(&(*self)->rtmp.sem);
                (*self)->rtmp.sem = 0;
            }
            
            RTMP_Free((*self)->rtmp.r);
            (*self)->rtmp.r = 0;
        }
        
        if((*self)->rtmp.spspps)
        {
            free((*self)->rtmp.spspps);
            (*self)->rtmp.spspps = 0;
            (*self)->rtmp.spsppsSize = 0;
        }

        if((*self)->codec)
        {
            (*self)->codec->close((*self)->codec);
            (*self)->codec = 0;
        }
        
        TBI_FREE((*self)->encoder.buffer);
        
        free(*self);
        *self = 0;
    }
}


media_codec_t* getVideoCodecByFormat(uint32_t codecFormat)
{
    switch (codecFormat) {
        case MEDIA_CODEC_FORMAT_VP8:
            return pmedia_codec_vp8;
        case MEDIA_CODEC_FORMAT_H264:
            return pmedia_codec_h264;
        default:
            break;
    }
    return tbi_null;
}

int getVideoCodecByString(const char* codecFormat)
{
    char *vp8 = "vp8";
    char *h264 ="h264";
    
    if(!TBI_strncmp(vp8, codecFormat, sizeof(vp8)))
        return MEDIA_CODEC_FORMAT_VP8;
    if(!TBI_strncmp(h264,codecFormat,sizeof(h264)))
        return MEDIA_CODEC_FORMAT_H264;

    return tbi_null;
}

int media_video_session_reConnect(media_video_session_t* self, const char* playName, const char* publishName, char* codecFormat)
{
    if(!self || !playName || playName[0] == '\0' || !publishName || publishName[0] == '\0')
        return -1;
    
    self->codec->networkType = self->network_type;
    
    if(self->internet_type)
        self->codec->networkType = self->internet_type;
    
//    if(self->codec->open(self->codec) < 0)
//    {
//        free(self);
//        return 0;
//    }
//    
    
    self->rtmp.bIsStarted = tbi_true;
    self->stat->realDeltaPlayTime = 1000.0/(double)self->codec->video.fps;
    self->stat->lastPlayed2TimeFrameCount= 0 ;
    self->stat->lastPlayed2TimeFrameTime = 0 ;
    native_debug_function("VIDEO: playName = %s / publishName = %s", playName, publishName);
    
    self->rtmp.r->Link.publishpath.av_len = strlen(publishName);
    self->rtmp.r->Link.publishpath.av_val = TBI_calloc(1, self->rtmp.r->Link.publishpath.av_len);
    memcpy(self->rtmp.r->Link.publishpath.av_val, publishName, self->rtmp.r->Link.publishpath.av_len);
    self->rtmp.r->m_publishstream_id = -1;

    self->rtmp.r->Link.playpath.av_len = strlen(playName);
    self->rtmp.r->Link.playpath.av_val = TBI_calloc(1, self->rtmp.r->Link.playpath.av_len);
    memcpy(self->rtmp.r->Link.playpath.av_val, playName, self->rtmp.r->Link.playpath.av_len);
    self->rtmp.r->m_playstream_id = -1;
    
    self->rtmp.r->Link.lFlags |= RTMP_LF_LIVE;
    
    if(self->rtmp.state < VIDEO_RTMP_STATE_CONNECTED)
    {
        self->rtmp.bStartPlayPublish = tbi_true;
    }
    else
    {
        RTMP_SendCreateStream(self->rtmp.r);
        RTMP_SendCreateStream(self->rtmp.r);
        self->rtmp.bStartPlayPublish = tbi_false;
    }
    
    return 0;
}


int media_video_session_Start(media_video_session_t* self, const char* playName, const char* publishName, char* codecFormat)
{
    if(!self || !playName || playName[0] == '\0' || !publishName || publishName[0] == '\0')
        return -1;
    
    self->codec = getVideoCodecByFormat((uint32_t)getVideoCodecByString(codecFormat));
    self->codec->networkType = self->network_type;
    
    if(self->internet_type)
        self->codec->networkType = self->internet_type;
    
    if(self->codec->open(self->codec) < 0)
    {
        free(self);
        return 0;
    }
    
    self->stat->realDeltaPlayTime = 1000.0/(double)self->codec->video.fps;
    self->stat->lastPlayed2TimeFrameCount= 0 ;
    self->stat->lastPlayed2TimeFrameTime = 0 ;
    
    self->stat->maxPacketCount = RTMP_MAX_CHECK_TIME_COIFF * self->codec->video.fps;
    self->stat->packetCompletionTimes = TBI_calloc(self->stat->maxPacketCount, sizeof(uint64_t));
    self->stat->checkTime = RTMP_MAX_CHECK_TIME_COIFF * self->codec->video.fps;
    
    native_debug_function("VIDEO: playName = %s / publishName = %s", playName, publishName);
    
    self->rtmp.r->Link.publishpath.av_len = strlen(publishName);
    self->rtmp.r->Link.publishpath.av_val = TBI_calloc(1, self->rtmp.r->Link.publishpath.av_len);
    memcpy(self->rtmp.r->Link.publishpath.av_val, publishName, self->rtmp.r->Link.publishpath.av_len);
    self->rtmp.r->m_publishstream_id = -1;
    
    self->rtmp.r->Link.playpath.av_len = strlen(playName);
    self->rtmp.r->Link.playpath.av_val = TBI_calloc(1, self->rtmp.r->Link.playpath.av_len);
    memcpy(self->rtmp.r->Link.playpath.av_val, playName, self->rtmp.r->Link.playpath.av_len);
    self->rtmp.r->m_playstream_id = -1;      
    
    self->rtmp.r->Link.lFlags |= RTMP_LF_LIVE;
    
    if(self->rtmp.state < VIDEO_RTMP_STATE_CONNECTED)
    {
        self->rtmp.bStartPlayPublish = tbi_true;
    }
    else
    {
        RTMP_SendCreateStream(self->rtmp.r);
        RTMP_SendCreateStream(self->rtmp.r);
        self->rtmp.bStartPlayPublish = tbi_false;
    }   

    return 0;
}

void media_video_session_ini_video_size(resolution_t* self){
    switch (self->video_type) {
        case SIZE_176_X_144:{
            self->width = 176;
            self->height = 144;
            self->fps = VIDEO_FPS;
        }
            break;
        case SIZE_352_X_288:
        {
            self->width = 352;
            self->height = 288;
            self->fps = VIDEO_FPS;
        }
            break;
        case SIZE_640_X_480:
        {
            self->width = 640;
            self->height = 480;
            self->fps = VIDEO_FPS; 
        }
            break;
        default:
            break;
    }
}

int media_video_session_send_package(media_video_session_t* self, const void* buffer, int size)
{
    tbi_size_t out_size;
    if(!self || !self->codec || !self->codec->codec)
        return 0;
    
    if((out_size = self->codec->encode(self->codec,buffer,size, &self->encoder.buffer, &self->encoder.buffer_size)))
    {
        return media_video_session_send(self, self->encoder.buffer, out_size);
    }
    return out_size;
}

int media_video_session_send(media_video_session_t* self, const void* buffer, int size)
{
    tbi_bool_t isKeyFrame;
    
    if(!self || !self->rtmp.bIsStarted)
        return -1;
    
    if(!RTMP_IsConnected(self->rtmp.r) || !self->rtmp.r->m_bPublishing)
        return 0;

    const int channel = 0x05;
    const int frameHdrSize = 9;
    
    if(self->rtmp.r->m_outChunkSize != self->rtmp.chankSize)
    {
        TBI_ChangeChunkSize(self->rtmp.r, self->rtmp.chankSize);
    }
    RTMPPacket* packet = (RTMPPacket*)TBI_object_new(RTMPPacket_def_t);
    packet->m_nChannel = channel;	/* source channel */
    packet->m_nInfoField2 = self->rtmp.r->m_publishstream_id;
    
    packet->m_packetType = RTMP_PACKET_TYPE_VIDEO;
    
    if(!self->rtmp.bIsFirstPacket)
    {
        packet->m_headerType = RTMP_PACKET_SIZE_LARGE;
        self->rtmp.bIsFirstPacket = tbi_true;
        packet->m_nTimeStamp = TBI_time_epoch() - self->rtmp.connectionTimeStamp;
        fprintf(stderr, "VIDEO: Current time = %lld, connection time = %lld, delta time = %d\n", TBI_time_epoch(), self->rtmp.connectionTimeStamp, packet->m_nTimeStamp);
    }
    else
    {
        packet->m_headerType = RTMP_PACKET_SIZE_MEDIUM;
        packet->m_nTimeStamp = TBI_time_epoch() - self->rtmp.connectionTimeStamp;
    }

    isKeyFrame = ((((char*)buffer)[0] & 0x1F) == 5);
    if(isKeyFrame)
    {
        uint8_t spspps[64];
        int spslen;
        if(!rtmp_get_sps_pps_nal_unit(spspps, &spslen,(int)self->video.send.video_type))
            return 0;
        
        packet->m_nBodySize = spslen;
        RTMPPacket_Alloc(packet, packet->m_nBodySize);
        memcpy(packet->m_body, spspps, packet->m_nBodySize);
        
        RTMP_SendPacket(self->rtmp.r, packet, 0);
        RTMPPacket_Free(packet, "send video spspps frame");
        
        packet->m_headerType = RTMP_PACKET_SIZE_MEDIUM;
        packet->m_nTimeStamp = TBI_time_epoch() - self->rtmp.connectionTimeStamp;
        
        packet->m_nBodySize = size + frameHdrSize;
        RTMPPacket_Alloc(packet, packet->m_nBodySize);
        packet->m_body[0] = 0x17;
    }
    else
    {
        packet->m_nBodySize = size + frameHdrSize;
        RTMPPacket_Alloc(packet, packet->m_nBodySize);
        packet->m_body[0] = 0x27;
    }
    
    packet->m_body[1] = 0x01;
    packet->m_body[2] = 0x00;
    packet->m_body[3] = 0x00;
    packet->m_body[4] = 0x00;
    
    if(isKeyFrame)
        fprintf(stderr, "%s - frame size = %d\n", isKeyFrame ? "K" : "I", size);
    
    *((unsigned int*)(&packet->m_body[5])) = htonl(size);
    
    memcpy(packet->m_body + frameHdrSize, buffer, size);
    
    if(!RTMP_SendPacket(self->rtmp.r, packet, 0)){
        TBI_DEBUG_ERROR("package send failed -- RTMP_SendPacket(manager->rtmp_media, packet, 0)");
    }

    TBI_OBJECT_SAFE_FREE(packet);
    
    return 0;
}

int media_video_session_Consume(media_video_session_t* self, const void* data, unsigned int dataSize)
{
    if(!data || !dataSize || !self->codec || !self->codec->codec)
        return -1;
    
    int out_size = self->codec->decode(self->codec, data, dataSize, &self->decoder.buffer, &self->decoder.buffer_size);
    if(out_size > 0)
    {
        if(self->consumerCallback && self->consumerCallbackData){
            media_codec_h264_t *codec = self->codec->codec;
            self->consumerCallback(self->consumerCallbackData, self->decoder.buffer, out_size, codec->decoder.picture->width,codec->decoder.picture->height);
        }
    }
    
    return out_size;
}

void media_video_session_setSenderCallback(media_video_session_t* self, _send_video_callback callback, void* callbackData)
{
    if(self)
    {
        self->senderCallback = callback;
        self->senderCallbackData = callbackData;
    }
}

void media_video_session_setConsumerCallback(media_video_session_t* self, _consume_video_callback callback, void* callbackData)
{
    self->consumerCallback = callback;
    self->consumerCallbackData = callbackData;
}

void media_video_session_put_packet(media_video_session_t* self, RTMPPacket *packet)
{
    if(!self || !self->rtmp.packets || !self->rtmp.sem)
        return;
    
    TBI_list_lock(self->rtmp.packets);
    TBI_list_push_back_data(self->rtmp.packets, (void**)&packet);
    TBI_list_unlock(self->rtmp.packets);
    TBI_semaphore_increment(self->rtmp.sem);
}

void media_video_session_handle_packet(void* callback, RTMPPacket *packet)
{
    const char *pbody, *sps, *pps;
    unsigned int nalSize, bodySize, spsSize, ppsSize;
    media_video_session_t* self = (media_video_session_t*)callback;

    if(self->isReconnecting){
        static int  k = 0 ;
        k++;
        if(k==10){
            self->isReconnecting = tbi_false;
            self->rtmp.r->m_bPublishing = tbi_true;
            k = 0 ;
        }
    }
    
    if (self && self->rtmp.bIsStarted)
    {
        pbody = packet->m_body;
        bodySize = packet->m_nBodySize;
        if(pbody[0] == 0x17 && pbody[1] == 0x00)
        {
            pbody += 2;
            if(pbody[3] == 1)
            {
                pbody += 9;
                spsSize = ntohs(*((short*)pbody));
                pbody += sizeof(short);
                sps = pbody;
                pbody += spsSize;
                
                pbody += 1;
                ppsSize = ntohs(*((short*)pbody));
                pbody += sizeof(short);
                pps = pbody;
                pbody += ppsSize;
                int currSz = spsSize + sizeof(H264_START_CODE_PREFIX) + ppsSize;
                if(!self->rtmp.spspps || self->rtmp.spsppsSize < currSz)
                {
                    self->rtmp.spsppsSize = currSz;
                    self->rtmp.spspps = TBI_realloc(self->rtmp.spspps, self->rtmp.spsppsSize);
                }
                char* p = self->rtmp.spspps;
                memcpy(p, sps, spsSize); p += spsSize;
                memcpy(p, H264_START_CODE_PREFIX, sizeof(H264_START_CODE_PREFIX)); p += sizeof(H264_START_CODE_PREFIX);
                memcpy(p, pps, ppsSize); p += ppsSize;
                
                self->codec->decode( self->codec, self->rtmp.spspps, self->rtmp.spsppsSize, &self->decoder.buffer, &self->decoder.buffer_size );
            }
        }
        else if((pbody[0] == 0x17 || pbody[0] == 0x27) && pbody[1] == 0x01)
        {
            pbody += 5;
            bodySize -= 5;
            while(bodySize)
            {
                nalSize = ntohl(*((int*)pbody));
                pbody += sizeof(unsigned int);
                bodySize -= sizeof(unsigned int);
                if(((*pbody & 0x1f) == 5) || ((*pbody & 0x1f) == 1) || self->codec->format == MEDIA_CODEC_FORMAT_VP8)
                {
                    int out_size = -1;
                    
                    if(self->rtmp.isDrop == 0) {
                        out_size =  self->codec->decode(self->codec, pbody, bodySize, &self->decoder.buffer, &self->decoder.buffer_size );
                    }
                   
                    if(out_size > 0)
                    {
                        if(self->consumerCallback)
                        {
                            self->consumerCallback(self->consumerCallbackData, self->decoder.buffer, out_size, self->codec->rotate.width, self->codec->rotate.height);
                        }
                    }
                }
                
                pbody += nalSize;
                bodySize -= nalSize;
            }
        }
    }
}

void media_video_session_increase(media_video_session_t* self, double data)
{
    if(self && self->codec && self->codec->bitrate_change)
        self->codec->bitrate_change(self->codec, tbi_false, data);
}

void media_video_session_decrease(media_video_session_t* self, double data)
{
    if(self && self->codec && self->codec->bitrate_change)
        self->codec->bitrate_change(self->codec, tbi_true,data);
}

int media_video_session_get_vp8_bitrate(media_video_session_t* self) {
    if (!self) {
        return -1;
    }
    return self->current_network_status;
}
int media_video_session_send_vp8_bitrate(media_video_session_t* self) {
    if (self && self->codec && self->codec->format == MEDIA_CODEC_FORMAT_VP8) {
        media_codec_vp8_t *media_codec = (media_codec_vp8_t*)self->codec->codec;
        return media_codec->currentInstance->bitrate;
    }

    return self->current_network_status;
}

int media_video_session_changechanksize(media_video_session_t* self, tbi_bool_t up)
{
    if(!self)
        return -1;
    
    uint32_t oldSize = self->rtmp.chankSize;
    if(up)
    {
        if(self->rtmp.chankSize != RTMP_VIDEO_CHANKSIZE)
            self->rtmp.chankSize = RTMP_VIDEO_CHANKSIZE;
    }
    else
    {
        if(self->rtmp.chankSize == RTMP_VIDEO_CHANKSIZE)
            self->rtmp.chankSize = RTMP_VIDEO_CHANKSIZE/2;
    }
    TBI_DEBUG_INFO("changechanksize: %d to %d", oldSize, self->rtmp.chankSize);
    return oldSize;
}

void media_video_session_status_cb(void* param, rtmp_event_t *event)
{
    if(!param || !event)
        return;
    
    media_video_session_t* self = (media_video_session_t*)param;
    if(event->rtmp_call_event == RTMP_EVENT_VIDEODATA)
    {
        media_video_session_put_packet(self, event->packet);
    }
    else if(event->rtmp_call_event == RTMP_EVENT_CONNECTED)
    {
        native_debug_function("VIDEO: RTMP_EVENT_CONNECTED");
        self->rtmp.state = VIDEO_RTMP_STATE_CONNECTED;
        self->rtmp.connectionTimeStamp = TBI_time_epoch();
        
        self->isReconnecting = TBI_false;
    }
}










