//
//  rtmpmanager.c
//  ios-ngn-stack
//  
//  Created by Samvel on 6/23/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

//deaf3778e2bf9079b7a67b851ec4d8f337c20d8a

#include "rtmpmanager.h"
#include "pthread.h"
#include "media.h"
#include "mpeg4.h"
#include "media_audio_session.h"
#include "rtmp.h"
#include "TBIRTMP.h"
#include "TBI_thread.h"
#include "TBI_base64.h"
#include "TBI_rsa.h"
#include "TBI_uuid.h"
#include "log.h"
#include "rtmp_chatmanager.h"
#include "TBI_base64.h"
#include "TBI_string.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>


#ifdef CRYPTO
//#define RTMP_URL              "rtmps://zvc2.hawkstream.com/protimeSip"
//#define RTMP_MEDIA_URL        "rtmps://zvc2.hawkstream.com/protimeSip"
#else
//#define RTMP_URL              "rtmp://vzgo.protime.tv:80/protimeSip"
//#define RTMP_MEDIA_URL        "rtmp://vzgo.protime.tv:80/protimeSip"

//#define RTMP_URL              "rtmp://10.20.0.13/seequ"
//#define RTMP_MEDIA_URL        "rtmp://10.20.0.13/seequ"

//#define RTMP_URL              "rtmp://192.168.0.135/seequ"
//#define RTMP_MEDIA_URL        "rtmp://192.168.0.135/seequ"

//#define RTMP_URL              "rtmp://192.168.0.135/seequ"
//#define RTMP_MEDIA_URL        "rtmp://192.168.0.135/seequ"

//#define RTMP_URL              "rtmp://212.34.233.13/protimeSip"
//#define RTMP_MEDIA_URL        "rtmp://212.34.233.13/protimeSip"

//#define RTMP_URL              "rtmp://vzgo.protime.tv/seequ"
//#define RTMP_MEDIA_URL        "rtmp://vzgo.protime.tv/seequ"

//#define RTMP_URL              "rtmp://192.168.0.10/protimeSip"
//#define RTMP_MEDIA_URL        "rtmp://192.168.0.10/protimeSip"

//#define RTMP_URL              "rtmp://uvc.protime.tv/seequ"
#define RTMP_MEDIA_URL        "rtmp://uvc.protime.tv:1945/seequ"

#endif

#define RTMP_DEF_BUFTIME     (10 * 60 * 60 * 1000)

int video_type = 1;


#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

static rtmp_manager_t* rtmp_publisher = 0;
static rtmp_manager_t* rtmp_player = 0;
static int phoneVer = 0;

void rtmp_manager_recv_status(void* param, rtmp_event_t *event);
    
int rtmp_manager_get_video_settings(rtmp_manager_t* manager, const char*file_name, int number){
    return media_video_session_get_video_settings(file_name,number);
}

int rtmp_manager_get_bitrate(rtmp_manager_t* manager)
{
    if(!manager || !manager->videoSession || !manager->videoSession->codec || !manager->videoSession->codec->get_bitrate)
        return -1;
    
    return manager->videoSession->codec->get_bitrate(manager->videoSession->codec);
}

int rtmp_manager_get_vp8_bitrate(rtmp_manager_t* manager) {
    if(!manager->videoSession)
        return -1;
    
    return media_video_session_send_vp8_bitrate(manager->videoSession);
    
}
int rtmp_manager_get_current_vp8_bitrate(rtmp_manager_t* manager) {
    if(!manager->videoSession)
        return -1;
    return media_video_session_get_vp8_bitrate(manager->videoSession);
}
 
int rtmp_manager_changechanksize(rtmp_manager_t* manager, tbi_bool_t up)
{
    if(!manager)
        return -1;
    
    return media_video_session_changechanksize(manager->videoSession, up);
}
    
    void RTMP_CallRemove(rtmp_callinfo_t** callInfo)
    {
        if(callInfo && *callInfo && (*callInfo)->state != CallState_Idle)
        {
            if((*callInfo)->destNumber)
                free((*callInfo)->destNumber);
            
            if((*callInfo)->call_id)
                free((*callInfo)->call_id);
            
            if((*callInfo)->codec_list)
                free((*callInfo)->codec_list);
            
            if((*callInfo)->neg_codec)
                free((*callInfo)->neg_codec);
            
            (*callInfo)->state = CallState_Idle;
            
            free(*callInfo);
            *callInfo = 0;
        }
    }
    
    
static void* rtmp_receiver_cb(void * param)
{
    RTMPPacket* packet = 0;
    rtmp_manager_t* manager = (rtmp_manager_t*)param;
    if(!manager)
        return 0;
    
//    int bHasMediaPacket = 0;

    while (manager->bIsStarted)
    {
        if(!RTMP_IsConnected(manager->rtmp))
        {
            rtmp_event_t* event = calloc(1, sizeof(rtmp_event_t));
            event->rtmp_call_event = RTMP_EVENT_DISCONNECTED;
            event->messageType = strdup("Server disconnected");
            callBackEvent(event);
            break;
        }

        packet = TBI_object_new(RTMPPacket_def_t);
        if(RTMP_ReadPacket(manager->rtmp, packet) && RTMPPacket_IsReady(packet))
        {
            RTMP_ClientPacket(manager->rtmp, packet);
        }
        TBI_OBJECT_SAFE_FREE(packet);
    }
    
    return 0;
}

// Media initialization ==========================================================
void rtmp_manager_audio_callback(void* callbackData, media_video_event_t event, double data)
{
    rtmp_manager_t* manager = (rtmp_manager_t*)callbackData;
    AVal uid;
    AVal dstNumber;
    
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);

    dstNumber.av_val = manager->dst_number;
    dstNumber.av_len = strlen(manager->dst_number);
    
    double bitrate = -1 ;
    bitrate = rtmp_manager_get_vp8_bitrate(manager);
    
    switch (event)
    {
        case media_audio_increase:{
            TBI_RTMP_SendIncrease(manager->rtmp, &uid, &dstNumber,bitrate,data);
        }
            break;
        case media_audio_decrease:
            TBI_RTMP_SendDecrease(manager->rtmp, &uid, &dstNumber,bitrate ,data);
            break;
        default:
            break;
    }
    
}
    
    
    
int rtmp_manager_restart_media_session(rtmp_manager_t* manager,int width,int height,int fps)
{
    if(!manager)
        return -1;
    
//    if(manager->bIsMediaStarted)
//        return 0;
    

    
    
    //manager->audioSession = media_audio_session_Craete(RTMP_MEDIA_URL, rtmp_manager_audio_callback, (void*)manager);
    manager->audioSession = media_audio_session_restart(manager->audioSession,RTMP_MEDIA_URL, NULL, NULL);
    if(!manager->audioSession)
        return -2;
    
    

//    manager->videoSession = media_video_session_create(RTMP_MEDIA_URL, manager->videocodec,rtmp_manager_audio_callback, (void*)manager);
    
//    if(!manager->videoSession)
//        return -2;
    
//    manager->audioSession->stat = manager->videoSession->stat;
//    
//    manager->send_mutex = TBI_mutex_create();
    
//    manager->bIsMediaStarted = tbi_true;
        return 0;
}

int rtmp_manager_open_media_session(rtmp_manager_t* manager,int width,int height,int fps)
{
    if(!manager)
        return -1;
    
    if(manager->bIsMediaStarted)
        return 0;
    
    //manager->audioSession = media_audio_session_Craete(RTMP_MEDIA_URL, rtmp_manager_audio_callback, (void*)manager);
    media_audio_session_create(&manager->audioSession,RTMP_MEDIA_URL, NULL, rtmp_manager_recv_status, (void*)manager,manager->uid);
    if(!manager->audioSession)
        return -2;
    
    media_video_session_create(&manager->videoSession, RTMP_MEDIA_URL, manager->videocodec, rtmp_manager_audio_callback, (void*)manager);
    if(!manager->videoSession)
        return -2;
    
    manager->audioSession->stat = manager->videoSession->stat;
    

    
    manager->bIsMediaStarted = tbi_true;
    return 0;
}
    
    const char key[] = { 2, 8, 18, 9, 26, 15, 26, 31, 12, 5, 23, 15, 29, 4, 16, 7, 14, 29, 23 };
    int enc(char* decrypedBytes, int len, char** encodedBytes)
    {
        *encodedBytes = calloc(1, len);
        for(int i = 0; i < len; ++i)
        {
            (*encodedBytes)[i] = decrypedBytes[i] - key[i];
        }
        return len;
    }
    
    int dec(char* encryptedBytes, int len, char** decodedBytes)
    {
        *decodedBytes = calloc(1, len);
        for(int i = 0; i < len; ++i)
        {
            (*decodedBytes)[i] = encryptedBytes[i] + key[i];
        }
        return len;
    }
    
int rtmp_manager_close_media_session(rtmp_manager_t* manager)
{
    if(!manager)
        return -1;
    
    
    RTMP_CallRemove(&manager->callInfo);
    
    if(!manager->bIsMediaStarted)
        return 0;
    
    
    
    manager->bIsMediaStarted = tbi_false;
    
    TBI_DEBUG_INFO("audio rtmp_manager_close_media_session 1");
    
    if(manager->audioSession)
    {
        media_audio_session_Destroy(&manager->audioSession);
    }
    
    TBI_DEBUG_INFO("video rtmp_manager_close_media_session 2");
    if(manager->videoSession)
    {
        TBI_mutex_lock(manager->send_mutex);
        media_video_session_Destroy(&manager->videoSession);
        manager->videoSession = 0 ;
        TBI_mutex_unlock(manager->send_mutex);
    }
        TBI_DEBUG_INFO("audio rtmp_manager_close_media_session 3");
    
    return 0;
}
    
// Audio session =================================================================
int rtmp_manager_init_audio_session(rtmp_manager_t* manager)
{
    return 0;
}
    
void rtmp_manager_set_send_audio(rtmp_manager_t* manager, void *buffer, int buffer_size)
{
    if(!manager || !manager->audioSession)
        return;
    
    media_audio_session_SetData(manager->audioSession, buffer, buffer_size);
}

    
int rtmp_manager_get_received_audio(rtmp_manager_t* manager, void *buffer, int buffer_size)
{
    if(!manager || !manager->audioSession)
        return 0;
    
    return media_audio_session_get_receied_data(manager->audioSession, buffer, buffer_size);
}

int rtmp_manager_send_audio(rtmp_manager_t* manager, const void* buffer, int size)
{
    if(!manager || !manager->audioSession)
        return -1;
    
    if(manager->audioSession->audioSignalingPingTime < 0)
        manager->audioSession->audioSignalingPingTime = TBI_time_epoch();
    else if(TBI_time_epoch()-manager->audioSession->audioSignalingPingTime>7200){
        native_debug_function("{rtmp_manager_send_audio}->audioSignalingPingTime %ull",manager->audioSession->audioSignalingPingTime);
        rtmp_manager_send_checknet(manager);
        manager->audioSession->audioSignalingPingTime = TBI_time_epoch();
    }
    
    
    return media_audio_session_send(manager->audioSession, buffer, size);
}
int rtmp_manager_send_checknet(rtmp_manager_t* manager)
{
    AVal uid;
    
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);
    
    TBI_RTMP_SendChecknet(manager->audioSession->rtmp.r,&uid);
    
    return 0;
}
    
// Video session =================================================================
int rtmp_manager_init_video_session(rtmp_manager_t* manager, _consume_video_callback callback,int weight, int height, int fps)
{
    if(!manager || !manager->videoSession || !callback)
        return -1;
    manager->height = weight;
    manager->height = height;
    manager->fps = fps;
    
    
        
    media_video_session_setConsumerCallback(manager->videoSession, callback, manager);

    return 0;
}
    
//
int rtmp_manager_send_video(rtmp_manager_t* manager, const void* buffer, int size)
{
   if(!manager || !manager->videoSession || !manager->send_mutex ||(manager->audioSession && manager->audioSession->lockForReconnect) )
        return -1;

    TBI_mutex_lock(manager->send_mutex);
    if(!manager->videoSession || manager->isVideoReconnectiong || manager->videoSession->isReconnecting)
    {
        TBI_mutex_unlock(manager->send_mutex);
        return -1;
    }
    if(manager && manager->videoSession && manager->videoSession->isReconnecting){
        TBI_mutex_unlock(manager->send_mutex);
        return 0;
    }
    
    if(manager && manager->videoSession)
        media_video_session_send_package(manager->videoSession, buffer, size);

        TBI_mutex_unlock(manager->send_mutex);
    
    return 0;
}

    
    

    
// RTMP =========================================================================
rtmp_manager_t* create_rtmp_manager(const char *udid, int udidSize,  const char* rtmpServer)
{
    rtmp_manager_t* manager = 0;
    if(rtmp_player)
        return rtmp_player;
        
    rtmp_player = (rtmp_manager_t*)malloc(sizeof(rtmp_manager_t));
    manager = rtmp_player;
    
    if(!manager)
        return manager;

    manager->rtmp = RTMP_Alloc();
    if(!manager->rtmp)
    {
        free(manager);
        return 0;
    }
    
    manager->isAudioReconnectiong = tbi_true;
    manager->isVideoReconnectiong = tbi_true;
    
    manager->callInfo = malloc(sizeof(rtmp_callinfo_t));
    manager->callInfo->state = CallState_Idle;
    
    
    manager->rtmpUrl = strdup(rtmpServer);
    
    manager->connect_mutex = TBI_mutex_create();
    RTMP_Init(manager->rtmp, tbi_true, tbi_true, "SIGNALING");
    TBI_RTMP_SetCallback(manager->rtmp, rtmp_manager_recv_status, manager);
    RTMP_SetupURL(manager->rtmp, manager->rtmpUrl);
    
    manager->bIsStarted = tbi_false;
    
    manager->uid = calloc(1, udidSize);
    memcpy(manager->uid, udid, udidSize);
    
    manager->registrationServerTime = -1;
    manager->registrationDeviceTime = -1;
    
    // audio data settings
    manager->audiocodec = strdup("g729"); //TMEDIA_CODEC_FORMAT_G729);
    
    // video data settings
    manager->videocodec = strdup("106"); //TMEDIA_CODEC_FORMAT_H264_BP30);
    
    manager->bIsMediaStarted = 0;

    
    phoneVer = get_phone_version();
    
    initMedia();
    if(phoneVer == iPod4 || phoneVer==iPhone4v5 || phoneVer == iPhone4v6)
    {
        manager->codecs_list = IPOD_SUPPORTED_AUDIO_CODECS_LIST;
        manager->videoCodecs_list = IPOD_SUPPORTED_VIDEO_CODECS_LIST;
        
//        video_type = SIZE_176_X_144;
        video_type = SIZE_352_X_288;
    }
    else
    {
        video_type = SIZE_352_X_288;
        manager->codecs_list = SUPPORTED_AUDIO_CODECS_LIST;
        manager->videoCodecs_list = SUPPORTED_VIDEO_CODECS_LIST;
    }
    
    manager->videoSession = 0;
    manager->audioSession = 0;
    manager->dstNumber = 0;
    manager->bisRtmpConnected = tbi_false;
    manager->lastRcvTime = 0;
    
    manager->isVpx = tbi_false;

    return manager;
}

void destroy_rtmp_manager(rtmp_manager_t* manager)
{
    if(manager && (manager == rtmp_player || manager == rtmp_publisher))
    {
        TBI_DEBUG_ERROR("[SYSTEM][RTMP-MANAGER] | Destroying %X\n", (int)manager);
        if (manager->rtmp)
        {
            RTMP_Free(manager->rtmp);
        }
        if(manager->rtmpUrl)
            TBI_free((void**)&manager->rtmpUrl);
        
        free(manager);
        manager = 0;
        
        TBI_DEBUG_ERROR("[SYSTEM][RTMP-MANAGER] | Destroyed %X\n", (int)manager);
    }
}

int prepare_rtmp_manager(rtmp_manager_t* manager, const char* sipSrv, const char* uName, const char* pswd)
{
    if(!manager)
        return -1;
    
    manager->sipServer = TBI_strdup(sipSrv);
    manager->userName = TBI_strdup(uName);
    manager->password = TBI_strdup(pswd);
    
    return 0;
}

int start_rtmp_manager(rtmp_manager_t* manager)
{
    if(!manager || !manager->rtmp)
        return -1;
   
    manager->send_mutex = TBI_mutex_create();
    
    native_debug_function("[SYSTEM][RTMP-MANAGER] | Starting %X", (int)manager);

    TBI_mutex_lock(manager->connect_mutex);
    
    manager->rtmp->m_inChunkSize= RTMP_DEFAULT_CHUNKSIZE;
    manager->rtmp->m_outChunkSize = RTMP_DEFAULT_CHUNKSIZE;
    manager->rtmp->m_playstream_id= -1;
    manager->rtmp->m_publishstream_id = -1;
    
    RTMP_Reset(manager->rtmp);

#if RTMP_WITHOUT_HANDSHAKE
    AVal sipServer;
    AVal username;
    AVal password;
    AVal codecs;
    AVal client;
    AVal uid;
    AVal videocodec;
    
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);
    
    sipServer.av_val = manager->sipServer;
    sipServer.av_len = strlen(manager->sipServer);
    
    char* encUName = 0;
    char* encPaswd = 0;
    char* encOut = 0;
    int encLen, outLen = 0;
    
	char keyFilePath[256];
	getResourceFilePath("public.pem", keyFilePath, 256);
	tbi_rsa_t* rsa = rsaOpen(keyFilePath);
	
    if((encLen = rsaEncode(rsa, manager->userName, strlen(manager->userName), &encOut, &outLen)) < 0)
    {
        rsaClose(&rsa);
        return 0;
    }
    
    TBI_size_t encUNameLen = TBI_base64_encode((uint8_t*)encOut, encLen, &encUName);
    
    if((encLen = rsaEncode(rsa, manager->password, strlen(manager->password), &encOut, &outLen)) < 0)
    {
        rsaClose(&rsa);
        return 0;
    }
    
    TBI_size_t encPaswdLen = TBI_base64_encode((uint8_t*)encOut, encLen, &encPaswd);
    free(encOut);
    rsaClose(&rsa);
    
    username.av_val = encUName;
    username.av_len = encUNameLen;
    
    password.av_val = encPaswd;
    password.av_len = encPaswdLen;
    
	char *c = "Iphone";
    client.av_val = c;
    client.av_len = strlen(c);
    
    codecs.av_val = manager->codecs_list;
    codecs.av_len = strlen(manager->codecs_list);
    
    videocodec.av_val = strdup(manager->videoCodecs_list);
    videocodec.av_len = strlen(manager->videoCodecs_list);

    if (!TBI_RTMP_ConnectWoHandshak(manager->rtmp, &uid, &sipServer, &username, &password, &client, &codecs, &videocodec, video_type, NULL))
    {
        TBI_DEBUG_ERROR("[SYSTEM][RTMP-MANAGER]{WOH} | Starting failed (connect) %X", (int)manager);
        TBI_mutex_unlock(manager->connect_mutex);
        return -2;
    }
#else
    if (!RTMP_Connect(manager->rtmp, NULL))
    {
        TBI_DEBUG_ERROR("[SYSTEM][RTMP-MANAGER] | Starting failed (connect) %X", (int)manager);
        TBI_mutex_unlock(manager->connect_mutex);
        return -2;
    }
#endif //RTMP_WITHOUT_HANDSHAKE

    TBI_mutex_unlock(manager->connect_mutex);

    manager->lastRcvTime = TBI_time_epoch();
    manager->bIsStarted = tbi_true;
    TBI_thread_create(&manager->tid_sig, rtmp_receiver_cb, (void*)manager);

    native_debug_function("[SYSTEM][RTMP-MANAGER] | Started %X", (int)manager);
    
    return 0;
}

int stop_rtmp_manager(rtmp_manager_t* manager){
    if(!manager || !manager->rtmp)
        return -1;
    
    if(!manager->bIsStarted)
        return 0;
    
    native_debug_function("[SYSTEM][RTMP-MANAGER] | Stopping %X", (int)manager);
//    TBI_DEBUG_INFO("Stopping RTMP manager ======================= %X", (int)manager);
    
    manager->bIsStarted = 0;
    RTMP_UserInterrupt(manager->rtmp);

    rtmp_player = 0;
    if(manager->rtmp)
        RTMP_Close(manager->rtmp);

    native_debug_function("[SYSTEM][RTMP-MANAGER] | Stopped BJ %X", (int)manager);

    if(manager->tid_sig)
        TBI_thread_join(&manager->tid_sig);
    
    TBI_mutex_destroy(&manager->send_mutex);
    manager->send_mutex = 0;
    
    native_debug_function("[SYSTEM][RTMP-MANAGER] | Stopped %X", (int)manager);
//    TBI_DEBUG_INFO("RTMP manager stopped ======================= %X", (int)manager);

    return 0;
}
    
tbi_bool_t restart_rtmp_manager(rtmp_manager_t* manager)
{
    if(!manager)
        return tbi_false;
    
    native_debug_function("[SYSTEM][RTMP-MANAGER] | Re-Starting %X", (int)manager);
    
    int ret = -1;
    
    stop_rtmp_manager(manager);
    ret = start_rtmp_manager(manager
#if RTMP_WITHOUT_HANDSHAKE
#endif //RTMP_WITHOUT_HANDSHAKE
                             );
    return (ret == 0);
}

void rtmp_manager_set_appstate(rtmp_manager_t* manager, tbi_bool_t bIsInBkgMode)
{
    AVal uid;
    if ( manager )
    {
        manager->bIsInBkgMode = bIsInBkgMode;
        manager->bkgModeRcvCount = 0;
        if(manager->bIsInBkgMode)
            manager->bkgModeStartTime = TBI_time_epoch();

        uid.av_val = manager->uid;
        uid.av_len = strlen(manager->uid);
        TBI_RTMP_SendChangeState(manager->rtmp, &uid, bIsInBkgMode ? 0 : 1);
    }
}
    
int rtmp_manager_get_bkgmodercvcount(rtmp_manager_t* manager)
{
    if( !manager )
        return -1;
    
    return manager->bkgModeRcvCount;
}

uint64_t rtmp_manager_get_lastrcvtime(rtmp_manager_t* manager)
{
    if( !manager )
        return 0;
    
    return manager->lastRcvTime;
}
    
int rtmp_manager_set_audio_callback(rtmp_manager_t* manager, trtp_manager_rtmp_cb_f audio_callback, void* callbackdata)
{
    if(!manager || !audio_callback)
        return -1;
    
    return 0;
}

int rtmp_manager_set_video_callback(rtmp_manager_t* manager, trtp_manager_rtmp_cb_f video_callback, void* callbackdata)
{
    if(!manager || !video_callback)
        return -1;

    return 0;
}

    // Call initialization ===========================================================
    rtmp_callinfo_t* RTMP_CallInit(char* dstNum, char* call_id, char* cadec_list, char* video_cadec_list, int state)
    {
        if(!dstNum || dstNum[0] == '\0')
            return 0;
        
        rtmp_callinfo_t* callInfo = (rtmp_callinfo_t*)TBI_calloc(1, sizeof(rtmp_callinfo_t));
        
        callInfo->destNumber = dstNum;
        
        if(call_id)
            callInfo->call_id = call_id;
        if(cadec_list)
            callInfo->codec_list = cadec_list;
        callInfo->neg_codec = TBI_null;
        
        if(video_cadec_list)
            callInfo->video_codec_list = video_cadec_list;
        callInfo->neg_video_codec = TBI_null;
        
        callInfo->state = (CallState)state;
        
        return callInfo;
    }
    
int rtmp_manager_send_register(rtmp_manager_t* manager, char* sipSrv, char* uName, char* pswd)
{
    AVal sipServer;
    AVal videoCodec;
    AVal username;
    AVal password;
    AVal codecs;
    AVal client;
    AVal uid;
    int rv = 0;
    
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);
    
    native_debug_function("rtmp_manager_send_register(%s, %s, %s, %s, %s , %s)", manager->uid, sipSrv, uName, pswd, manager->codecs_list,manager->videoCodecs_list);

    sipServer.av_val = sipSrv;
    sipServer.av_len = strlen(sipSrv);
    
    char* encUName = 0;
    char* encPaswd = 0;
    char* encOut = 0;
    int encLen, outLen = 0;
    
    char keyFilePath[256];
    getResourceFilePath("public.pem", keyFilePath, 256);
    
    tbi_rsa_t* rsa = rsaOpen(keyFilePath);
    if((encLen = rsaEncode(rsa, uName, strlen(uName), &encOut, &outLen)) < 0)
    {
        rsaClose(&rsa);
        return 0;
    }
    
    TBI_size_t encUNameLen = TBI_base64_encode((uint8_t*)encOut, encLen, &encUName);
    free(encOut);
    
    if((encLen = rsaEncode(rsa, pswd, strlen(pswd), &encOut, &outLen)) < 0)
    {
        rsaClose(&rsa);
        return 0;
    }
    
    TBI_size_t encPaswdLen = TBI_base64_encode((uint8_t*)encOut, encLen, &encPaswd);
    free(encOut);
    rsaClose(&rsa);
    
    
    username.av_val = encUName;
    username.av_len = encUNameLen;
    
//    username.av_val = uName;
//    username.av_len = strlen(uName);
    
    password.av_val = encPaswd;
    password.av_len = encPaswdLen;
    
//    password.av_val = pswd;
//    password.av_len = strlen(pswd);
    char *c = "Iphone";
    client.av_val = c;
    client.av_len = strlen(c);

    codecs.av_val = strdup(manager->codecs_list);
    codecs.av_len = strlen(manager->codecs_list);
    
    videoCodec.av_val = strdup(manager->videoCodecs_list);
    videoCodec.av_len = strlen(manager->videoCodecs_list);    
    //TBI_DEBUG_ERROR("Send register %.*s@%.*s\n", username.av_len, username.av_val, sipServer.av_len, sipServer.av_val);
    
    
    rv = TBI_RTMP_SendRegister(manager->rtmp, &uid, &sipServer, &username, &password, &client, &codecs,&videoCodec, video_type);
    if(encUName)
        free(encUName);
    if(encPaswd)
        free(encPaswd);
    return rv;
}
    
tbi_bool_t is_rtmp_manager_connected(rtmp_manager_t* manager)
{
    if(!manager)
        return tbi_false;
        
    return RTMP_IsConnected(manager->rtmp);// && manager->bisRtmpConnected;
}

int rtmp_manager_send_unregister(rtmp_manager_t* manager)
{
    native_debug_function("rtmp_manager_send_unregister(%s)", manager->uid);
    if(!manager)
        return -1;
    
    AVal uid;
    
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);
    
    return TBI_RTMP_SendUnRegister(manager->rtmp, &uid);
}
int rtmp_manager_bw_estimator_start(rtmp_manager_t* manager,char*to){
    tbi_wifiestimator_bw_estimator((void*)manager,to);
    return 0;
}
    char* AVal2String(const AVal* aVal)
    {
        char* str = malloc(aVal->av_len + 1);
        strncpy(str, aVal->av_val, aVal->av_len);
        str[aVal->av_len] = '\0';
        return str;
}
#pragma mark ------- Call --------
    // Call =========================================================================
tbi_bool_t rtmp_manager_open_call(rtmp_manager_t* manager, const AVal* dstNum, const AVal* call_id, const AVal* cadec_list, const AVal* video_cadec_list, int state)
{
    if((manager->callInfo = RTMP_CallInit(AVal2String(dstNum), AVal2String(call_id), 0/*AVal2String(cadec_list)*/, 0/*AVal2String(video_cadec_list)*/, state)) == 0)
        return tbi_false;
    
    manager->isVpx = tbi_false;
        //    if(rtmp_manager_open_media_session(manager))
        //        return tbi_false;
        
   return tbi_true;
}
    
int rtmp_manager_send_call(rtmp_manager_t* manager, char *fullname,char* dialNum, char* callType, char* codecs, int frameCount, int network_type,int internet_type)
{
    if(!manager)
        return -1;
    manager->isHold = tbi_false;
    manager->isVideoReconnectiong = tbi_false;
    manager->isAudioReconnectiong = tbi_false;
    
//  rtmp_manager_bw_estimator_start(manager,dialNum);
    
    native_debug_function("rtmp_manager_send_call(%s, %s)", manager->uid, dialNum);
    manager->dstNumber = strdup(dialNum);
    manager->dst_number = strdup(dialNum);
    manager->network_type = network_type;
    rtmp_manager_open_media_session(manager,manager->weight,manager->height,manager->fps);

    AVal uid, dN, cT, avcodecs, videoCodec, name,test;
    
    name.av_val = fullname;
    name.av_len = strlen(fullname);
    
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);
    
    dN.av_val = dialNum;
    dN.av_len = strlen(dialNum);
    
    cT.av_val = callType;
    cT.av_len = strlen(callType);
    

    TBI_uuidstring_t uuid;
    TBI_uuidgenerate(&uuid);
    AVal callId;
    
    callId.av_val = uuid;
    callId.av_len = strlen(uuid);
    
    
    test.av_val = 0 ;
    test.av_len = 0 ;
    
    
    if(!rtmp_manager_open_call(manager, &dN, &callId,&test, &test, CallState_OutGoing))
    {
        return -2;
    }
    
    if (codecs && codecs[0] != '\0')
    {
        avcodecs.av_val = codecs;
        avcodecs.av_len = strlen(codecs);
    }
    else
    {
        avcodecs.av_val = manager->codecs_list;
        avcodecs.av_len = strlen(manager->codecs_list);
    }
    
    videoCodec.av_val = manager->videoCodecs_list;
    videoCodec.av_len = strlen(manager->videoCodecs_list);
    
    TBI_RTMP_SendMakeCall(manager->rtmp, 0, &uid, &callId,&name,&dN, &cT, &avcodecs, frameCount, &videoCodec,video_type,internet_type);
    return 0;
}

int rtmp_manager_send_hold(rtmp_manager_t* manager)
{
        if(!manager || manager->isHold || !manager->callInfo)
            return -1;
    
        manager->isHold = tbi_true;
    
        if(manager->videoSession)
            manager->videoSession->rtmp.isDrop = 1;

        native_debug_function("rtmp_manager_send_hold(%s)", manager->uid);
        

        AVal uid;
        
        uid.av_val = manager->uid;
        uid.av_len = strlen(manager->uid);

        AVal callId;
    
        callId.av_val = manager->callInfo->call_id;
        callId.av_len = strlen(manager->callInfo->call_id);
    
    
        TBI_RTMP_SendMakeHold(manager->rtmp, &uid,&callId);
        return 0;
}

int rtmp_manager_send_BW(rtmp_manager_t* manager, char* toUri,char*dataPack,int size)
{
        if(!manager)
            return -1;
        native_debug_function("rtmp_manager_send_BW(%s,%s)", manager->uid,toUri);
        //size = 800;
        AVal uid;
        uid.av_val = manager->uid;
        uid.av_len = strlen(manager->uid);
    
        AVal to;
        to.av_val = toUri;
        to.av_len = strlen(toUri);
    
        AVal data;
        data.av_val = dataPack;
        data.av_len = size;//sizeof(Ctl_Pkt_t);
    
        char* test = calloc(1, data.av_len + 1);
        memcpy(test, data.av_val, data.av_len);

    
        TBI_RTMP_SndBW(manager->rtmp, &uid,&to,&data);
        return 0;
}

int rtmp_manager_rcv_BW(rtmp_manager_t* manager,char *from, char* data)
{
    Ctl_Pkt_t *control_rcv = malloc(sizeof(Ctl_Pkt_t)) ;
    memcpy(control_rcv, data, sizeof(Ctl_Pkt_t));

    
   // native_debug_function("rtmp_manager_rcv_BW(%s)", data);
    PerformEstRcv((void*)manager,from,control_rcv);
    tbi_wifiestimator_reseiver((void*)manager,from,control_rcv);
    
    return 0;
}
    
int rtmp_manager_send_unhold(rtmp_manager_t* manager)
{
        if(!manager || !manager->callInfo)
            return -1;
        
        native_debug_function("rtmp_manager_send_unhold(%s)", manager->uid);
        if(manager->videoSession)
            manager->videoSession->rtmp.isDrop = 0;
    
        manager->isHold = tbi_false;
    
        AVal uid;
        
        uid.av_val = manager->uid;
        uid.av_len = strlen(manager->uid);
    
    AVal callId;
    
    callId.av_val = manager->callInfo->call_id;
    callId.av_len = strlen(manager->callInfo->call_id);
    
        TBI_RTMP_SendMakeUnHold(manager->rtmp, &uid,&callId);
        return 0;
}
    
void rtmp_manager_set_system_time_delay(rtmp_manager_t* manager,int64_t devicetime,int64_t servertime)
{
    if(!manager)
        return;
    manager->registrationServerTime = servertime;
    manager->registrationDeviceTime = devicetime;
    //    if(manager->audioSession){
    //        manager->audioSession->registrationDeviceTime = manager->registrationDeviceTime;
    //        manager->audioSession->registrationServerTime = manager->registrationServerTime;
    //    }
    
    native_debug_function("rtmp_manager_set_system_time_delay %ji   %ji   %ji %ji",servertime, devicetime, devicetime-servertime  , TBI_time_epoch());
}
    
int rtmp_manager_send_callvoip(rtmp_manager_t* manager, char* dialNum, char* callType)
{
    native_debug_function("rtmp_manager_send_callvoip(%s, %s)", manager->uid, dialNum);

    rtmp_manager_open_media_session(manager,manager->weight,manager->height,manager->fps);

    int frameSize = AUDIO_FRAMES_COUNT;
    AVal uid, dN, cT, codecs,videoCodec;
    
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);
    
    dN.av_val = strdup(dialNum);
    dN.av_len = strlen(dialNum);
        
    cT.av_val = strdup(callType);
    cT.av_len = strlen(callType);
        
//    const char *codecs_ = manager->codecs_list;
    codecs.av_val = strdup(SUPPORTED_AUDIO_CODECS_LIST);
    codecs.av_len = strlen(SUPPORTED_AUDIO_CODECS_LIST);
    
    videoCodec.av_val = strdup(manager->videoCodecs_list);
    videoCodec.av_len = strlen(manager->videoCodecs_list);
    
    AVal callId;
    
    callId.av_val = manager->callInfo->call_id;
    callId.av_len = strlen(manager->callInfo->call_id);

    // JSC - NOTE: videoCodec and vieo_type were swapped!
    //    TBI_RTMP_SendMakeCall(manager->rtmp, 1, &uid, &callId, &uid, &dN, &cT, &codecs, frameSize, video_type, &videoCodec, -1);
    
    TBI_RTMP_SendMakeCall(manager->rtmp, 1, &uid, &callId, &uid, &dN, &cT, &codecs, frameSize, &videoCodec, video_type, -1);
    
    return 0;
}
int rtmp_manager_send_dtmf(rtmp_manager_t* manager, char* dtmf)
{
    native_debug_function("rtmp_manager_send_dtmf(%s)", manager->uid);
    if(!manager)
        return -1;
    
    AVal uid, av_dtmf;
    
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);
    
    av_dtmf.av_val = strdup(dtmf);
    av_dtmf.av_len = 1;
    
    AVal callId;
    
    callId.av_val = manager->callInfo->call_id;
    callId.av_len = strlen(manager->callInfo->call_id);
    
    
    TBI_RTMP_SendDTMF(manager->rtmp, &uid,&callId, &av_dtmf);
    free(av_dtmf.av_val);
    
    return 0;
}
int rtmp_manager_send_accept(rtmp_manager_t* manager, char* codecs, int frameCount, int network_type, int internet_type)
{
    manager->isVideoReconnectiong = tbi_false;
    manager->isAudioReconnectiong = tbi_false;
    
    manager->isHold = tbi_false;
    AVal uid, avcodecs, videoCodec;

    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);

    if(codecs && codecs[0] != '\0')
    {
        avcodecs.av_val = codecs;
        avcodecs.av_len = strlen(codecs);
    }
    else
    {
        avcodecs.av_val = manager->codecs_list;
        avcodecs.av_len = strlen(manager->codecs_list);
    }
    
    videoCodec.av_val = manager->videoCodecs_list;
    videoCodec.av_len = strlen(manager->videoCodecs_list);
    manager->network_type = network_type;
    
    AVal callId;
    
    callId.av_val = manager->callInfo->call_id;
    callId.av_len = strlen(manager->callInfo->call_id);
    
    
    
    TBI_RTMP_SendAccept(manager->rtmp, &uid,&callId, &avcodecs, frameCount, &videoCodec, video_type, internet_type);
    return 0;
}

int rtmp_manager_send_hangup(rtmp_manager_t* manager)
{
    if(!manager ||!manager->callInfo)
        return -1;
    native_debug_function("rtmp_manager_send_hangup(%s,%s)", manager->uid,manager->callInfo->call_id);
    
    
     native_debug_function("rtmp_manager_send_hangup 1");
    AVal uid;
    
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);

    AVal callId;
    
    callId.av_val = manager->callInfo->call_id;
    callId.av_len = strlen(manager->callInfo->call_id);
    
    TBI_RTMP_SendHangup(manager->rtmp, &uid,&callId);
    rtmp_manager_close_media_session(manager);
    native_debug_function("rtmp_manager_send_hangup 2");
    return 0;
}
    
int rtmp_manager_send_decline(rtmp_manager_t* manager)
{

    if(!manager)
        return -1;
    native_debug_function("rtmp_manager_send_decline(%s,%s)", manager->uid,manager->callInfo->call_id);
    AVal uid;
    
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);

    
    AVal callId;
    
    callId.av_val = manager->callInfo->call_id;
    callId.av_len = strlen(manager->callInfo->call_id);
    
    TBI_RTMP_SendDecline(manager->rtmp, &uid,&callId);
    return 0;
}

enum iPhoneModels rtmp_manager_get_phone_version(){
    return get_phone_version();
}

tbi_bool_t isVP8(rtmp_manager_t* manager){
    return manager->isVpx;
}

void rtmp_manager_restart_media(rtmp_manager_t* manager)
{
    char *publishName = createUnicId();
    if(manager->audioSession && manager->audioSession->tmpPlayName)
    {
        int playFrameCnt= manager->audioSession->playerframesCount;
        int publishFrameCnt = manager->audioSession->publisherframesCount;
        manager->audioSession->producer.droping = tbi_true;
        int playlen = strlen(manager->audioSession->tmpPlayName);
        char *elementPlayName = malloc(playlen);
        
        memcpy(elementPlayName,manager->audioSession->tmpPlayName, strlen(manager->audioSession->tmpPlayName));
        
        manager->audioSession->producer.isRunning = TBI_false;
        TBI_semaphore_increment(manager->audioSession->producer.audioSender);
        
        if(manager->audioSession){
            media_audio_session_Destroy(&manager->audioSession);
        }
        media_audio_session_create(&manager->audioSession,RTMP_MEDIA_URL, NULL, rtmp_manager_recv_status, (void*)manager,manager->uid);
        
        AVal uid;
        
        uid.av_val = manager->uid;
        uid.av_len = strlen(manager->uid);
        
        AVal callId;
        
        callId.av_val = manager->callInfo->call_id;
        callId.av_len = strlen(manager->callInfo->call_id);
        
        TBI_RTMP_SendTrying(manager->rtmp, &uid, &callId);
        
        AVal publisherId;
        AVal dstNumber;
        
        int lenPublish = 16;
        
        manager->audioSession->tmpPublishName = malloc(lenPublish + 1);
        memset(manager->audioSession->tmpPublishName, 0, lenPublish);
        
        memccpy(manager->audioSession->tmpPublishName, publishName, sizeof(char), lenPublish);
        
        
        manager->bIsMediaStarted = tbi_true;
        manager->audioSession->tmpPublishName[lenPublish]= '\0';
        
        publisherId.av_val = manager->audioSession->tmpPublishName;
        publisherId.av_len = strlen(manager->audioSession->tmpPublishName);
        
        dstNumber.av_val = manager->dst_number;
        dstNumber.av_len = strlen(manager->dst_number);
        
        TBI_RTMP_SendReConnect(manager->rtmp, &uid, &dstNumber,&publisherId);
        
        manager->audioSession->tmpPlayName = malloc(playlen);
        memcpy(manager->audioSession->tmpPlayName, elementPlayName, playlen);
        manager->audioSession->tmpPlayName[playlen] = '\0';
        manager->audioSession->stat = manager->videoSession->stat;
        manager->audioSession->rtmp.connectionTimeStamp = RTMP_GetTime();
        
        
        media_audio_session_Start(manager->audioSession, manager->audioSession->tmpPlayName, manager->audioSession->tmpPublishName, manager->audiocodec, playFrameCnt, publishFrameCnt, manager->rtmp);
        manager->audioSession->last_audio_status = RTMP_STATUS_NO_AUDIO;
        manager->audioSession->rtmp.isReconnected = tbi_true;
        manager->isAudioReconnectiong = tbi_true;
    }
    
    if(manager->videoSession && manager->videoSession->tmpPlayName)
    {
        manager->isVideoReconnectiong = tbi_true;
        manager->videoSession->isReconnecting = tbi_true;
        TBI_mutex_lock(manager->send_mutex);
        
        int playlen = strlen(manager->videoSession->tmpPlayName);
        char *elementPlayName = malloc(playlen);
        memcpy(elementPlayName,manager->videoSession->tmpPlayName, strlen(manager->videoSession->tmpPlayName));
        int send_video_type = manager->videoSession->video.send.video_type;
        int send_receive_type = manager->videoSession->video.receive.video_type;
        int network_type = manager->videoSession->network_type;
        int internet_type = manager->videoSession->internet_type;
        _consume_video_callback callback = manager->videoSession->consumerCallback;

        media_video_session_Destroy(&manager->videoSession);
        
        media_video_session_create(&manager->videoSession,RTMP_MEDIA_URL, manager->videocodec,rtmp_manager_audio_callback, (void*)manager);
        manager->videoSession->rtmp.bIsStarted = tbi_true;
        
        rtmp_manager_init_video_session(manager,callback,manager->height,manager->height,manager->fps);
        
        int lenPublish = 17;
        manager->videoSession->tmpPublishName = malloc(lenPublish+2);
        memset(manager->videoSession->tmpPublishName, 0, lenPublish);
        
        memccpy(manager->videoSession->tmpPublishName, publishName, sizeof(char), lenPublish-1);
        
        manager->videoSession->tmpPublishName[lenPublish-1]= 'v';
        manager->videoSession->tmpPublishName[lenPublish]= '\0';
        
        manager->videoSession->tmpPlayName = malloc(playlen);
        
        memcpy(manager->videoSession->tmpPlayName, elementPlayName, playlen);
        
        manager->videoSession->tmpPlayName[playlen] = '\0';
        
        manager->videoSession->rtmp.connectionTimeStamp = RTMP_GetTime();
        
        
        manager->videoSession->video.send.video_type = send_video_type;
        manager->videoSession->video.receive.video_type = send_receive_type;
        
        media_video_session_ini_video_size(&manager->videoSession->video.send);
        media_video_session_ini_video_size(&manager->videoSession->video.receive);
        
        manager->videoSession->network_type = network_type;
        manager->videoSession->internet_type = internet_type;
        
        char *codec = "vp8";
        media_video_session_Start(manager->videoSession, manager->videoSession->tmpPlayName, manager->videoSession->tmpPublishName, codec);
        
        TBI_mutex_unlock(manager->send_mutex);
        manager->isVideoReconnectiong = TBI_false;
    }
    
    manager->audioSession->producer.droping = tbi_false;
}
    
//void rtmp_manager_restart_media(rtmp_manager_t* manager)
//{
//
//
//
//    manager->audioSession->producer.droping = tbi_true;
//
//
//    AVal uid;
//
//    uid.av_val = manager->uid;
//    uid.av_len = strlen(manager->uid);
//    TBI_RTMP_SendTrying(manager->rtmp, &uid);
//
//    AVal publisherId;
//    AVal dstNumber;
//
//    char *publishName = createUnicId();
//    int lenPublish = 16;
////    int lenPlay = 16+2;
//
//    free(manager->audioSession->tmpPublishName);
//    
//    manager->audioSession->tmpPublishName = malloc(lenPublish+1);
////    manager->audioSession->tmpPlayName = malloc(lenPlay+1);
//    memset(manager->audioSession->tmpPublishName, 0, lenPublish);
////    memset(manager->audioSession->tmpPlayName, 0, lenPlay);
//    
//    memccpy(manager->audioSession->tmpPublishName, publishName, sizeof(char), lenPublish);
//    
//    
//
////    sprintf(manager->audioSession->tmpPlayName, "%s_a", publishName, lenPublish);
//    
//
//    
//    
//    manager->audioSession->tmpPublishName[lenPublish]= '\0';
////    manager->audioSession->tmpPublishName[lenPlay]= '\0';
//    
//    publisherId.av_val = manager->audioSession->tmpPublishName;
//    publisherId.av_len = strlen(manager->audioSession->tmpPublishName);
//    
//    
//    dstNumber.av_val = manager->dst_number;
//    dstNumber.av_len = strlen(manager->dst_number);
//    
////    if(manager->audioSession)
////    {
////        media_audio_session_Destroy(&manager->audioSession);
////    }
//    
//    TBI_RTMP_SendReConnect(manager->rtmp, &uid, &dstNumber,&publisherId);
//    
//    rtmp_manager_restart_media_session(manager,manager->weight,manager->height,manager->fps);
//    
//    //rtmp_manager_open_media_session(manager,manager->weight,manager->height,manager->fps);
//    
//    native_debug_function("rtmp_manager_restart_media(%i)", manager);
//    
//    TBI_mutex_lock(manager->audioSession->producer.mutex);
//    if(manager->audioSession){
//        native_debug_function("media_audio_session_Start(****************************************************************************** audio)");
//        manager->audioSession->rtmp.isReconnected = tbi_true;
//        media_audio_session_reStart(manager->audioSession, manager->audioSession->tmpPlayName, manager->audioSession->tmpPublishName, manager->audiocodec, manager->audioSession->playerFrameCount, manager->audioSession->publisherFrameCount);
//        native_debug_function("media_audio_session_Start(++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ audio)");
//    }
//    TBI_mutex_unlock(manager->audioSession->producer.mutex);
//    
////     char *codec ;
////    
////     if(isVP8(manager))
////         codec = "vp8";
////     else
////         codec = "h264";
////    
////    if(manager->videoSession){
////        native_debug_function("media_audio_session_Start(****************************************************************************** video)");
////        media_video_session_reStart(manager->videoSession, manager->videoSession->tmpPlayName, manager->videoSession->tmpPublishName, codec);
////        native_debug_function("media_audio_session_Start(++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ video)");
////    }
////
//    
//    manager->audioSession->producer.droping = tbi_false;
//}
    
     
void rtmp_manager_recv_media_settings(rtmp_manager_t* manager, rtmp_event_t *event)
{
    if(manager->audiocodec)
        free( manager->audiocodec);
    
    manager->audiocodec = malloc(event->audio_event.codec.av_len+1);
    memcpy(manager->audiocodec, event->audio_event.codec.av_val, event->audio_event.codec.av_len);
    manager->audiocodec[event->audio_event.codec.av_len] = '\0';

    TBI_DEBUG_INFO("%s: publishFramesize = %i playFramesize = %i codec = %.*s   video codec = %.*s \n", __FUNCTION__, event->audio_event.publisherFrameCount,
                                                                                                 event->audio_event.playerFrameCount,
                                                                                                 event->audio_event.codec.av_len,
                                                                                                 event->audio_event.codec.av_val, event->video_event.codec.av_len ,  event->video_event.codec.av_val);
    

//    if(event->call_type == PT_IPHONE ){
//        manager->isVpx = tbi_true;
//    }
//    else{
//        manager->isVpx = tbi_false;
//    }
    
    
    if(manager->audioSession)
    {
        
        manager->audioSession->tmpPlayName = NULL;
        
        manager->audioSession->tmpPublishName = NULL;
        
        manager->audioSession->tmpPlayName = TBI_malloc(event->playName.av_len + 1);
        sprintf(manager->audioSession->tmpPlayName, "%.*s", event->playName.av_len, event->playName.av_val);
        
        manager->audioSession->tmpPublishName = TBI_malloc(event->publishName.av_len + 1);
        sprintf(manager->audioSession->tmpPublishName, "%.*s", event->publishName.av_len, event->publishName.av_val);
        
        media_audio_session_Start(manager->audioSession, manager->audioSession->tmpPlayName, manager->audioSession->tmpPublishName, manager->audiocodec, event->audio_event.playerFrameCount, event->audio_event.publisherFrameCount, manager->rtmp);
//        free(manager->audioSession->tmpPlayName);
//        free(manager->audioSession->tmpPublishName);
    }
   
    if(manager->videoSession)
    {
        if (!event->video_type) {
            event->video_type = 3;
        }
        
        manager->videoSession->time_correction =  manager->registrationDeviceTime - manager->registrationServerTime;
        
        manager->videoSession->video.send.video_type = event->video_type;
        manager->videoSession->video.receive.video_type = video_type;
        
        //manager->videoSession->video.outgoing = SIZE_352_X_288;
        //manager->videoSession->video.send.video_type = SIZE_176_X_144;
        //manager->videoSession->video.receive.video_type = SIZE_640_X_480;
        
        

        
        manager->videoSession->tmpPlayName = calloc(1, event->playName.av_len + 2);
        sprintf(manager->videoSession->tmpPlayName, "%.*sv", event->playName.av_len, event->playName.av_val);

        manager->videoSession->tmpPublishName = calloc(1, event->publishName.av_len + 2);
        sprintf(manager->videoSession->tmpPublishName, "%.*sv", event->publishName.av_len, event->publishName.av_val);
            
        char *codec = malloc(event->video_event.codec.av_len + 1);
        memcpy(codec, event->video_event.codec.av_val, event->video_event.codec.av_len);
        codec[event->video_event.codec.av_len] = '\0';
        
        media_video_session_ini_video_size(&manager->videoSession->video.send);
        media_video_session_ini_video_size(&manager->videoSession->video.receive);
        
//        if(isVP8(manager))
//           codec = "vp8";
//        else
//           codec = "h264";
        
        manager->videoSession->network_type = manager->network_type;
        manager->videoSession->internet_type = event->video_event.internet_type;
        
        media_video_session_Start(manager->videoSession, manager->videoSession->tmpPlayName, manager->videoSession->tmpPublishName, codec);
        
        if(manager->videoSession->codec->format == MEDIA_CODEC_FORMAT_VP8) {
            manager->isVpx = tbi_true;
        }else{
            manager->isVpx = tbi_false;
        }
        
//        free(manager->videoSession->tmpPlayName);
//        free(manager->videoSession->tmpPublishName);
        TBI_FREE(codec);
    }
}
    
int rtmp_manager_onIncomingCall(rtmp_manager_t* manager, rtmp_event_t *event)
{
    
    AVal uid,test;
    
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);
    
    
    
    if(manager->callInfo && manager->callInfo->state !=CallState_Idle){
        TBI_RTMP_SendDecline(manager->rtmp, &uid,&event->callId);
        native_debug_function("[RTMP-MANAGER] Rejecting second incoming call");
        //TODO: Answer with "486 Busy Here" message
        return -1;
    }
    
    if(!rtmp_manager_open_call(manager, &event->callNumber, &event->callId, &test, &test, CallState_InComing))
    {
        return -2;
    }
    
    AVal callId;
    

    //sprintf(callId.av_val, "%.*s", event->callId.av_len, event->callId.av_val);
    //callId.av_len = event->callId.av_len; //manager->callInfo->call_id;
    

    callId.av_val = manager->callInfo->call_id;
    callId.av_len = strlen(manager->callInfo->call_id);
    
    
    TBI_RTMP_SendTrying(manager->rtmp, &uid,&event->callId);
    
    manager->dstNumber = (char*)malloc(event->callNumber.av_len + 1);
    strncpy(manager->dstNumber, event->callNumber.av_val, event->callNumber.av_len);
    manager->dstNumber[event->callNumber.av_len] = '\0';
    
    
    int len = 8 ;
    manager->dst_number = (char*)malloc(len + 1);
    strncpy(manager->dst_number, event->callNumber.av_val+4, len);
    manager->dst_number[len] = '\0';
    test.av_val = 0 ;
    test.av_len = 0 ;
    

    
    rtmp_manager_open_media_session(manager,manager->weight,manager->height,manager->fps);
    return 0;
}

int rtmp_manager_onCloseCall(rtmp_manager_t* manager, rtmp_event_t *event)
{
    if(!manager->callInfo ||
       !event->callId.av_val ||
       !event->callId.av_len ||
       strncmp(manager->callInfo->call_id, event->callId.av_val, event->callId.av_len) )
    {
        //TODO: Answer with "481 Call/Transaction Does Not Exist" message
//        native_debug_function("[RTMP-MANAGER] Rejecting Call Close with not existing Call ID:%s", manager->callInfo->call_id);
        return 0;
    }
    
    if(manager->dstNumber)
    {
        free(manager->dstNumber);
        manager->dstNumber = 0;
    }

    rtmp_manager_close_media_session(manager);
    return 0;
}

void rtmp_manager_onIncrease(rtmp_manager_t* manager, rtmp_event_t *event)
{
    media_video_session_increase(manager->videoSession, event->level);
}
    
void rtmp_manager_media_reConnect(rtmp_manager_t* manager, rtmp_event_t *event)
{
    native_debug_function("rtmp_manager_media_reConnect()");
    AVal uid;
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);
    
    AVal callId;
    
    callId.av_val = manager->callInfo->call_id;
    callId.av_len = strlen(manager->callInfo->call_id);
    
    TBI_RTMP_SendTrying(manager->rtmp, &uid,&callId);

    TBI_mutex_lock(manager->audioSession->producer.mutex);
    if(manager->audioSession){
        //RTMP_DeleteStreams(manager->audioSession->rtmp.r);
        manager->audioSession->tmpPlayName = calloc(1, event->playName.av_len + 1);
        sprintf(manager->audioSession->tmpPlayName, "%.*s", event->playName.av_len, event->playName.av_val);
        manager->audioSession->tmpPlayName[event->playName.av_len] = '\0';
        native_debug_function("media_audio_session_Start(******************************************************************************)");
        media_audio_session_reConnect(manager->audioSession, manager->audioSession->tmpPlayName, manager->audioSession->tmpPublishName, manager->audiocodec, manager->audioSession->playerframesCount, manager->audioSession->publisherframesCount);
        manager->audioSession->last_audio_status = RTMP_STATUS_NO_AUDIO;
        native_debug_function("media_audio_session_Start(++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++)");
    }
    TBI_mutex_unlock(manager->audioSession->producer.mutex);
    
    
    
    if(manager->videoSession)
    {
            manager->videoSession->isReconnecting = tbi_true;
            manager->videoSession->tmpPlayName = calloc(1, event->playName.av_len + 2);
            sprintf(manager->videoSession->tmpPlayName, "%.*sv", event->playName.av_len, event->playName.av_val);
            
            if(event->publishName.av_val && event->publishName.av_len > 0)
            {
                    manager->videoSession->tmpPublishName = calloc(1, event->publishName.av_len + 2);
                    sprintf(manager->videoSession->tmpPublishName, "%.*sv", event->publishName.av_len, event->publishName.av_val);
            }
            
            native_debug_function("media_video_session_reConnect(***********************************************************)");
            char *codec = "vp8";
            
            media_video_session_reConnect(manager->videoSession, manager->videoSession->tmpPlayName, manager->videoSession->tmpPublishName, codec);
            
            manager->videoSession->isReconnecting = TBI_false;
            native_debug_function("media_video_session_reConnect(+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++)");
            manager->audioSession->lockForReconnect = 0;
    }
}
    
void rtmp_manager_onDecrease(rtmp_manager_t* manager, rtmp_event_t *event)
{
    media_video_session_decrease(manager->videoSession, event->level);
}
 
void rtmp_manager_recv_status(void* param, rtmp_event_t *event)
{
    if(!param || !event)
        return;
    
    rtmp_manager_t* manager = (rtmp_manager_t*)param;
    int ret = 0;
    
    manager->lastRcvTime = TBI_time_epoch();
    if(event->rtmp_call_event >= RTMP_CHAT_EVENT_BEGIN && event->rtmp_call_event <= RTMP_CHAT_EVENT_END)
    {
        rtmp_chatmanager_onReceive(manager, event);
        return;
    }
    
    switch (event->rtmp_call_event) {
        case RTMP_EVENT_CONNECTED:
            native_debug_function("[RTMP][RCV] <CONNECTED>");
            manager->bisRtmpConnected = tbi_true;
            break;
        case RTMP_EVENT_DISCONNECTED:
            native_debug_function("[RTMP][RCV] <DISCONNECTED>");
            break;
        case RTMP_STATUS_EVENT_INCREASE:
        {
            native_debug_function("[RTMP][RCV] <INCREASE> | changeSize:%f, currentEncoderBitrate:%f", event->level, event->bitrate);
            if(manager && manager->videoSession && event->bitrate!=-1)
                manager->videoSession->current_network_status = event->bitrate;
            rtmp_manager_onIncrease(manager, event);
        }
//            free(event);
            break;
        case RTMP_STATUS_EVENT_DECREASE:
        {
            native_debug_function("[RTMP][RCV] <DECREASE> | changeSize:%f, currentEncoderBitrate:%f", event->level, event->bitrate);
            rtmp_manager_onDecrease(manager, event);
            if(manager && manager->videoSession && event->bitrate!=-1)
                manager->videoSession->current_network_status = event->bitrate;
//            free(event);
        }
            break;
        case RTMP_STATUS_EVENT_RECEIVE_RECONNECT:{
            native_debug_function("[RTMP][RCV] <RECONNECT>");
            if(manager->audioSession){
                manager->audioSession->lockForReconnect = 1 ;
//                rtmp_manager_media_reConnect(manager, event);
            }
            if(manager && manager->videoSession && event->level!=-1)
                manager->videoSession->current_network_status = event->level;
            rtmp_manager_media_reConnect(manager, event);
        }
            break;
        case RTMP_CALL_EVENT_TYPE_ACCEPTED:
            native_debug_function("[RTMP][RCV] <ACCEPTED>");
            rtmp_manager_recv_media_settings(manager, event);
            break;
        case RTMP_EVENT_PUBLISHER_STREAM_CREATED:
            free(event);
            return;
        case RTMP_EVENT_PING:
            native_debug_function("[RTMP][RCV] <PING>");
            break;
        case RTMP_EVENT_AUDIODATA:
            media_audio_session_handle_packet(manager->audioSession, (RTMPPacket*)event->packet);
            return;
        //Call events handling
        case RTMP_CALL_EVENT_TYPE_INCOMING:
            native_debug_function("[RTMP][RCV] <INCOMING>");
            ret = rtmp_manager_onIncomingCall(manager, event);
            break;
        case RTMP_CALL_EVENT_TYPE_INPROGRESS:
            native_debug_function("[RTMP][RCV] <INPROGRESS>");
            break;
        case RTMP_CALL_EVENT_TYPE_RINGING:
            native_debug_function("[RTMP][RCV] <RINGING>");
            break;
        case RTMP_CALL_EVENT_TYPE_DECLINE:
            native_debug_function("[RTMP][RCV] <DECLINE>");
            break;
        case RTMP_CALL_EVENT_TYPE_CANCELED:
            native_debug_function("[RTMP][RCV] <CANCELED>");
            break;
        case RTMP_CALL_EVENT_TYPE_FAILED:
            native_debug_function("[RTMP][RCV] <FAILED>");
            break;
        case RTMP_CALL_EVENT_TYPE_BUSY_HERE:
            native_debug_function("[RTMP][RCV] <BUSY HERE>");
            break;
        case RTMP_CALL_EVENT_TYPE_NOT_ACCEPTABLE_HERE:
            native_debug_function("[RTMP][RCV] <NOT ACCEPTABLE HERE>");
            break;
        case RTMP_CALL_EVENT_TYPE_REQUEST_TERMINATE:
            native_debug_function("[RTMP][RCV] <REQUEST TERMINATE>");
            break;
        case RTMP_CALL_EVENT_TYPE_TEMPORARILY_UNAVAILABLE:
            native_debug_function("[RTMP][RCV] <TEMPORARILY UNAVAILABLE>");
            break;
        case RTMP_CALL_EVENT_TYPE_NOT_FOUND:
            native_debug_function("[RTMP][RCV] <NOT FOUND>");
            break;
        case RTMP_CALL_EVENT_TYPE_FORBIDDEN:
            native_debug_function("[RTMP][RCV] <FORBIDDEN>");
            break;
        case RTMP_CALL_EVENT_TYPE_NOT_REACHABLE:
            native_debug_function("[RTMP][RCV] <NOT REACHABLE>");
            break;
        case RTMP_CALL_EVENT_TYPE_CLOSED:
            native_debug_function("[RTMP][RCV] <CLOSED>");
            RTMP_DeleteStreams(manager->rtmp);
            break;
        case RTMP_CALL_EVENT_TYPE_LOCAL_HOLD_OK:
            native_debug_function("[RTMP][RCV] <LOCAL HOLD OK>");
            break;
        case RTMP_CALL_EVENT_TYPE_LOCAL_HOLD_NOK:
            native_debug_function("[RTMP][RCV] <LOCAL HOLD NOK>");
            break;
        case RTMP_CALL_EVENT_TYPE_LOCAL_RESUME_OK:
            native_debug_function("[RTMP][RCV] <LOCAL RESUME OK>");
            break;
        case RTMP_CALL_EVENT_TYPE_LOCAL_RESUME_NOK:
            native_debug_function("[RTMP][RCV] <LOCAL RESUME NOK>");
            break;
        case RTMP_CALL_EVENT_TYPE_REMOTE_HOLD:{
            native_debug_function("[RTMP][RCV] <REMOTE HOLD>");
            if(!manager->callInfo ||
               !event->callId.av_val ||
               !event->callId.av_len ||
               strncmp(manager->callInfo->call_id, event->callId.av_val, event->callId.av_len) )
            {
                //TODO: Answer with "481 Call/Transaction Does Not Exist" message
                native_debug_function("[RTMP-MANAGER] Rejecting Call Hold with not existing Call ID:%s", manager->callInfo->call_id);
                ret = -1;
                break;
            }
            
            manager->isHold = tbi_true;
            if(manager->audioSession){
                manager->audioSession->isHold = manager->isHold;
            }
            if(manager->videoSession)
                manager->videoSession->rtmp.isDrop = 1;
        }
            break;
        case RTMP_CALL_EVENT_TYPE_REMOTE_UNHOLD:{
            native_debug_function("[RTMP][RCV] <REMOTE UNHOLD>");
            if(!manager->callInfo ||
               !event->callId.av_val ||
               !event->callId.av_len ||
               strncmp(manager->callInfo->call_id, event->callId.av_val, event->callId.av_len) )
            {
                //TODO: Answer with "481 Call/Transaction Does Not Exist" message
                native_debug_function("[RTMP-MANAGER] Rejecting Call Unhold with not existing Call ID:%s", manager->callInfo->call_id);
                ret = -1;
                break;
            }
            
            manager->isHold = tbi_false;
            if(manager->audioSession)
                manager->audioSession->isHold = manager->isHold;
            if(manager->videoSession)
                manager->videoSession->rtmp.isDrop = 0;
        }
            break;
        case RTMP_CALL_EVENT_TYPE_REFER:
            native_debug_function("[RTMP][RCV] <REFER>");
            break;
         case RTMP_STATUS_EVENT_SEND_RECONNECT:{
             native_debug_function("[RTMP][RCV] <RECONNECT>");
             break;
         }
        case RTMP_REG_EVENT_TYPE_REGISTRATION_SUCCESS:{
            native_debug_function("[RTMP][RCV] <REGISTRATION SUCCESS>");
            if(manager->audioSession)
            {
                //rtmp_manager_restart_media(manager);
                if(manager->audioSession->lockForReconnect==1)
                {
                    rtmp_event_t *event =  (rtmp_event_t*)TBI_object_new(rtmp_event_def_t);
                    event->messageType = TBI_strdup("Audio reconnected\n");
                    event->rtmp_call_event = RTMP_STATUS_EVENT_SEND_RECONNECT;
                    
                    if(manager->audioSession->statusCallback && manager->audioSession->callbackData)
                        manager->audioSession->statusCallback(manager->audioSession->callbackData, (void*)event);
                    
                    TBI_OBJECT_SAFE_FREE(event);
                    
                    rtmp_manager_restart_media(manager);
                    manager->audioSession->lockForReconnect = 0 ;
                }
            }
        }
            break;
        case RTMP_REG_EVENT_TYPE_UNREGISTRATION_SUCCESS:
            native_debug_function("[RTMP][RCV] <UNREGISTRATION SUCCESS>");
            break;
        case RTMP_REG_EVENT_TYPE_REGISTRATION_FAILURE:
            native_debug_function("%s (%s)", "[RTMP][RCV] <REGISTRATION FAILURE>", event->messageType ? event->messageType : "");
            break;
        case RTMP_STATUS_FORCE_LOGOUT:
             native_debug_function("[RTMP][RCV] <FORCE LOGOUT>");
             break;
        case RTMP_CALL_EVENT_TYPE_NOTENOUGHCREDIT:
            native_debug_function("[RTMP][RCV] <TYPE NOTENOUGHCREDIT>");
            break;
        case RTMP_CALL_EVENT_TYPE_REQUESTTIMEOUT:
            native_debug_function("[RTMP][RCV] <REQUESTTIMEOUT>");
        case RTMP_REG_EVENT_TYPE_RECEIVE_BW_PING:
            rtmp_manager_rcv_BW(manager,event->from,event->messageType);
            native_debug_function("[RTMP][RCV] <RECEIVE BW PING>");
            break;
        case RTMP_CALL_EVENT_TYPE_LOCATING:
            native_debug_function("[RTMP][RCV] <LOCATING>");
            break;
        case RTMP_STATUS_AUDIO_RECONNECTED:
        {
            if(!manager->isAudioReconnectiong)
            {
                manager->isAudioReconnectiong = TBI_false;
                //free(event);
                //return;
            }
            native_debug_function("[RTMP][RCV] <AUDIO RECONNECTED>");
            manager->audioSession->lockForReconnect = 0;
//            if(manager->videoSession)
//                manager->videoSession->isReconnecting = TBI_false;
        }
            break;
        case RTMP_STATUS_VIDEO_RECONNECTED:
//            native_debug_function("RTMP_STATUS_VIDEO_RECONNECTED");
            break;
        case RTMP_STATUS_EVENT_AUDIO_PING:
            native_debug_function("[RTMP][RCV] <AUDIO PING>");
            if(manager->audioSession){
                
                if(manager->audioSession->media_audion_connection_status == 1)
                    manager->audioSession->media_audion_connection_status = 3 ;
                if(manager->audioSession->media_audion_connection_status == 5 || manager->audioSession->media_audion_connection_status == 4)
                    manager->audioSession->media_audion_connection_status = 6 ;
//                  rtmp_manager_restart_media(manager);
            }
            break;
        case RTMP_STATUS_NO_AUDIO:
            native_debug_function("[RTMP][RCV] <NO AUDIO>");
            if(manager->audioSession){
                if(manager->audioSession->media_audion_connection_status == 1)
                    manager->audioSession->media_audion_connection_status = 3 ;
                if(manager->audioSession->media_audion_connection_status == 5 || manager->audioSession->media_audion_connection_status == 4)
                    manager->audioSession->media_audion_connection_status = 6 ;
//                rtmp_manager_restart_media(manager);
            }
            break;
        case RTMP_STATUS_AUDIO_RECONNECT:{
            if(!manager->audioSession->lockForReconnect){
//            manager->audioSession->lockForReconnect = 1 ;
//            manager->audioSession->producer.isRunning = TBI_false;
//                
//            native_debug_function("RTMP_STATUS_AUDIO_RECONNECT 1");
//
//            usleep(1000000);
//            rtmp_manager_restart_media(manager);
//            native_debug_function("RTMP_STATUS_AUDIO_RECONNECT 2");
            }
            break;
        }
        case RTMP_STATUS_LOCAL_CONNECTION_CORRUPTED:{
            native_debug_function("[RTMP][RCV] <CONNECTION CORRUPTED>");
            if(!manager->audioSession->lockForReconnect){
//                manager->audioSession->producer.isRunning = TBI_false;
//                
//                TBI_semaphore_increment(manager->audioSession->producer.audioSender);
//                TBI_semaphore_increment(manager->audioSession->producer.audioSender);
//                TBI_semaphore_increment(manager->audioSession->producer.audioSender);
//                
//                TBI_thread_join(&manager->audioSession->producer.threadId);
//                
//                manager->isVideoReconnectiong = TBI_false;
                manager->audioSession->lockForReconnect = 1;
            }
            break;
        }
        case RTMP_STATUS_NO_VIDEO:
            native_debug_function("[RTMP][RCV] <NO VIDEO>");
            break;
        case RTMP_STATUS_LOCAL_CONNECTION_ALIVE:
            native_debug_function("[RTMP][RCV] <CONNECTION ALIVE>");
            break;
        case RTMP_STATUS_LOCAL_CONNECTION_ALIVE_INITIAL_STATE:
            native_debug_function("[RTMP][RCV] <CONNECTION ALIVE INITIAL STATE>");
            break;
        case RTMP_STATUS_LOCAL_CONNECTION_CORRUPTED_INITIAL_STATE:
            native_debug_function("[RTMP][RCV] <CORRUPTED INITIAL STATE>");
            break;
            
        default:
            break;
    }
    
    if( event->rtmp_call_event == RTMP_CALL_EVENT_TYPE_CLOSED
       || event->rtmp_call_event == RTMP_CALL_EVENT_TYPE_DECLINE
       || event->rtmp_call_event == RTMP_CALL_EVENT_TYPE_CANCELED
       || event->rtmp_call_event == RTMP_CALL_EVENT_TYPE_FAILED
       || event->rtmp_call_event == RTMP_CALL_EVENT_TYPE_BUSY_HERE
       || event->rtmp_call_event == RTMP_CALL_EVENT_TYPE_NOT_ACCEPTABLE_HERE
       || event->rtmp_call_event == RTMP_CALL_EVENT_TYPE_REQUEST_TERMINATE
       || event->rtmp_call_event == RTMP_CALL_EVENT_TYPE_TEMPORARILY_UNAVAILABLE
       || event->rtmp_call_event == RTMP_CALL_EVENT_TYPE_NOT_FOUND
       || event->rtmp_call_event == RTMP_CALL_EVENT_TYPE_NOTENOUGHCREDIT
       || event->rtmp_call_event == RTMP_CALL_EVENT_TYPE_REQUESTTIMEOUT
       || event->rtmp_call_event == RTMP_CALL_EVENT_TYPE_FORBIDDEN
       || event->rtmp_call_event == RTMP_CALL_EVENT_TYPE_NOT_REACHABLE)
          ret = rtmp_manager_onCloseCall(manager, event);
    
    if(ret == 0)
    {
        callBackEvent(event);
    }
}
    
#ifdef __cplusplus
}
#endif //__cplusplus
