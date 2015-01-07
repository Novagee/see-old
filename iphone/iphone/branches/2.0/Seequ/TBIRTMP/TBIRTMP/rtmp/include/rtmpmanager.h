//
//  rtmpmanager.h
//  ios-ngn-stack
//
//  Created by Samvel on 6/23/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#ifndef ios_ngn_stack_rtmpmanager_h
#define ios_ngn_stack_rtmpmanager_h
#define RTMP_SEARCH_TAG      "pid"

#define TINYRTMP_API

typedef enum CallState
{
    CallState_Unknown = -1,
    CallState_Idle = 0,
    CallState_OutGoing,
    CallState_InComing,
    CallState_Ringing,
    CallState_InCall,
    CallState_OnHold
} CallState;


typedef struct rtmp_callinfo_s
{
    char* destNumber;
    char* call_id;
    char* codec_list;
    char* neg_codec;
    char* video_codec_list;
    char* neg_video_codec;
    
    int state;
    CallState stateOfCall;
}rtmp_callinfo_t;




#include "rtmp.h"
#include "utlis.h"
#include "../../media/video/media_video_session.h"
#include "../../media/audio/media_audio_session.h"
#include "TBI_list.h"
#include "TBI_semaphore.h"
#include "wifiestimator.h"
#include <pthread.h>
//#define JITTER_BUFFER_ENABLED

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus


    

    
typedef int (*trtp_manager_rtmp_cb_f)(const void* callback_data, const char* data, int dataSize, const char* payload, uint16_t seq_num, uint32_t timestamp);
typedef void (*rtmp_manager_status_cb_f)(const char* status, int size);

typedef struct rtmp_manager_s {

    char* videocodec;
    char* audiocodec;
    char* codecs_list;
    char* videoCodecs_list;
    
    void *tid_sig;

    tbi_bool_t bIsMediaStarted;
    tbi_bool_t bIsStarted;
    
    char* uid;
    char* dstNumber;
    char* dst_number;
    int network_type;
    media_video_session_t* videoSession;
    media_audio_session_t* audioSession;
    
    TBI_mutex_handle_t *connect_mutex;
    
    rtmp_callinfo_t* callInfo;
    
    RTMP* rtmp;
    tbi_bool_t bisRtmpConnected;
    
    int weight;
    int height;
    int fps;
    tbi_bool_t isVpx;
    TBI_mutex_handle_t *send_mutex;
    
    rtmp_wifiestimator_t wifiestimator;
    
    int64_t registrationServerTime;
    int64_t registrationDeviceTime;
    
    tbi_bool_t isHold ;
    tbi_bool_t isAudioReconnectiong ;
    tbi_bool_t isVideoReconnectiong ;
    
    tbi_bool_t bIsInBkgMode;
    int bkgModeRcvCount;
    uint64_t bkgModeStartTime;
    uint64_t lastRcvTime;
    
    char* rtmpUrl;
    char* sipServer;
    char* userName;
    char* password;
    
} rtmp_manager_t;
    
TINYRTMP_API rtmp_manager_t* create_rtmp_manager(const char *udid, int udidSize, const char* rtmpServer);
TINYRTMP_API void destroy_rtmp_manager(rtmp_manager_t* manager);
    TINYRTMP_API int prepare_rtmp_manager(rtmp_manager_t* manager, const char* sipSrv, const char* uName, const char* pswd);
TINYRTMP_API int start_rtmp_manager(rtmp_manager_t* manager);

TINYRTMP_API int stop_rtmp_manager(rtmp_manager_t* manager);
TINYRTMP_API tbi_bool_t restart_rtmp_manager(rtmp_manager_t* manager);
    
TINYRTMP_API void rtmp_manager_set_appstate(rtmp_manager_t* manager, tbi_bool_t bIsInBkgMode);
TINYRTMP_API int rtmp_manager_get_bkgmodercvcount(rtmp_manager_t* manager);
TINYRTMP_API uint64_t rtmp_manager_get_lastrcvtime(rtmp_manager_t* manager);
    
TINYRTMP_API int rtmp_manager_set_audio_callback(rtmp_manager_t* manager, trtp_manager_rtmp_cb_f audio_callback, void* callbackdata);
TINYRTMP_API int rtmp_manager_set_video_callback(rtmp_manager_t* manager, trtp_manager_rtmp_cb_f video_callback, void* callbackdata);
TINYRTMP_API int rtmp_manager_send_video(rtmp_manager_t* manager, const void* buffer, int size);
TINYRTMP_API int rtmp_manager_send_audio(rtmp_manager_t* manager, const void* buffer, int size);
TINYRTMP_API int rtmp_manager_send_checknet(rtmp_manager_t* manager);
    
TINYRTMP_API int rtmp_manager_send_register(rtmp_manager_t* manager, char* sipSrv, char* uName, char* pswd);
TINYRTMP_API int rtmp_manager_send_unregister(rtmp_manager_t* manager);
TINYRTMP_API tbi_bool_t is_rtmp_manager_connected(rtmp_manager_t* manager);
    
TINYRTMP_API int rtmp_manager_send_call(rtmp_manager_t* manager, char *fullname,char* dialNum, char* callType, char* codecs, int frameCount, int network_type,int internet_type);
TINYRTMP_API int rtmp_manager_send_callvoip(rtmp_manager_t* manager, char* dialNum, char* callType);
TINYRTMP_API int rtmp_manager_send_hold(rtmp_manager_t* manager);
TINYRTMP_API int rtmp_manager_send_unhold(rtmp_manager_t* manager);
TINYRTMP_API int rtmp_manager_send_accept(rtmp_manager_t* manager, char* codecs, int frameCount, int network_type, int internet_type);
TINYRTMP_API int rtmp_manager_send_hangup(rtmp_manager_t* manager);
TINYRTMP_API int rtmp_manager_send_decline(rtmp_manager_t* manager);
    
TINYRTMP_API void rtmp_manager_restart_media(rtmp_manager_t* manager);
    
TINYRTMP_API int rtmp_manager_send_dtmf(rtmp_manager_t* manager, char* dtmf);
    
TINYRTMP_API int rtmp_manager_open_media_session(rtmp_manager_t* manager,int width,int height,int fps);
TINYRTMP_API int rtmp_manager_close_media_session(rtmp_manager_t* manager);

TINYRTMP_API int rtmp_manager_init_video_session(rtmp_manager_t* manager, _consume_video_callback callback,int weight, int height, int fps);
TINYRTMP_API int rtmp_manager_init_audio_session(rtmp_manager_t* manager);
    
TINYRTMP_API void rtmp_manager_set_send_audio(rtmp_manager_t* manager, void *buffer, int buffer_size);
TINYRTMP_API int rtmp_manager_get_received_audio(rtmp_manager_t* manager, void *buffer, int buffer_size);

    
    
TINYRTMP_API int rtmp_manager_get_video_settings(rtmp_manager_t* manager, const char*file_name, int number);
TINYRTMP_API int rtmp_manager_get_bitrate(rtmp_manager_t* manager);
TINYRTMP_API int rtmp_manager_get_vp8_bitrate(rtmp_manager_t* manager);
TINYRTMP_API int rtmp_manager_send_BW(rtmp_manager_t* manager, char* toUri,char*dataPack,int size);
TINYRTMP_API void rtmp_manager_set_system_time_delay(rtmp_manager_t* manager,int64_t devicetime,int64_t servertime);
TINYRTMP_API int rtmp_manager_get_current_vp8_bitrate(rtmp_manager_t* manager);
    
TINYRTMP_API int rtmp_manager_changechanksize(rtmp_manager_t* manager, tbi_bool_t up);

TINYRTMP_API enum iPhoneModels rtmp_manager_get_phone_version();

#ifdef __cplusplus
}
#endif //__cplusplus


#endif
