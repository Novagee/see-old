//
//  rtmpevent.h
//  TBIRTMP
//
//  Created by Macbook on 10/24/13.
//  Copyright (c) 2013 Grigori Jlavyan. All rights reserved.
//

#ifndef TBIRTMP_rtmpevent_h
#define TBIRTMP_rtmpevent_h

#include "TBI_object.h"
#include "amf.h"

#ifdef __cplusplus
extern "C"
{
#endif

    enum RTMP_EVENT_TYPE {
        RTMP_EVENT_TYPE_UNKNOWN                         = 0,
        
        //RTMP events
        RTMP_EVENT_CONNECTED                            = 1,
        RTMP_EVENT_DISCONNECTED,
        RTMP_EVENT_AUDIODATA,
        RTMP_EVENT_VIDEODATA,
        RTMP_EVENT_PUBLISHER_STREAM_CREATED,
        RTMP_EVENT_PING,
        
        //Response messages
        RTMP_EVENT_RESULT_ACCEPT                        = 51,
        
        //Registration events
        RTMP_REG_EVENT_TYPE_REGISTRATION_SUCCESS        = 101,
        RTMP_REG_EVENT_TYPE_UNREGISTRATION_SUCCESS,
        RTMP_REG_EVENT_TYPE_REGISTRATION_FAILURE,
        
        //Call events
        RTMP_CALL_EVENT_TYPE_STATUS                     = 121,
        RTMP_CALL_EVENT_TYPE_INCOMING,
        RTMP_CALL_EVENT_TYPE_INPROGRESS,
        RTMP_CALL_EVENT_TYPE_RINGING,
        RTMP_CALL_EVENT_TYPE_ACCEPTED,
        RTMP_CALL_EVENT_TYPE_CONNECTED,
        RTMP_CALL_EVENT_TYPE_CLOSED,
        RTMP_CALL_EVENT_TYPE_DECLINE,
        RTMP_CALL_EVENT_TYPE_CANCELED,
        RTMP_CALL_EVENT_TYPE_FAILED,
        RTMP_CALL_EVENT_TYPE_BUSY_HERE,
        RTMP_CALL_EVENT_TYPE_NOT_ACCEPTABLE_HERE,
        RTMP_CALL_EVENT_TYPE_REQUEST_TERMINATE,
        RTMP_CALL_EVENT_TYPE_TEMPORARILY_UNAVAILABLE,
        RTMP_CALL_EVENT_TYPE_NOT_FOUND,
        RTMP_CALL_EVENT_TYPE_NOTENOUGHCREDIT,
        RTMP_CALL_EVENT_TYPE_CALLLIMITREACHED,
        RTMP_CALL_EVENT_TYPE_REQUESTTIMEOUT,
        RTMP_CALL_EVENT_TYPE_LOCAL_HOLD_OK,
        RTMP_CALL_EVENT_TYPE_LOCAL_HOLD_NOK,
        RTMP_CALL_EVENT_TYPE_LOCAL_RESUME_OK,
        RTMP_CALL_EVENT_TYPE_LOCAL_RESUME_NOK,
        RTMP_CALL_EVENT_TYPE_REMOTE_HOLD,
        RTMP_CALL_EVENT_TYPE_REMOTE_RESUME,
        RTMP_CALL_EVENT_TYPE_REFER,
        RTMP_REG_EVENT_TYPE_RECEIVE_BW_PING,
        RTMP_CALL_EVENT_TYPE_REMOTE_UNHOLD,
        RTMP_CALL_EVENT_TYPE_FORBIDDEN,
        RTMP_CALL_EVENT_TYPE_NOT_REACHABLE,
        RTMP_CALL_EVENT_TYPE_LOCATING,
        
        
        //Other
        
        RTMP_STATUS_EVENT_INCREASE                      = 201,
        RTMP_STATUS_EVENT_DECREASE,
        RTMP_STATUS_EVENT_RECEIVE_RECONNECT,
        RTMP_STATUS_EVENT_SEND_RECONNECT,
        RTMP_STATUS_LOCAL_CONNECTION_CORRUPTED,
        RTMP_STATUS_EVENT_AUDIO_PING,
        RTMP_STATUS_LOCAL_CONNECTION_ALIVE,
        RTMP_STATUS_VIDEO_RECONNECTED,
        RTMP_STATUS_AUDIO_RECONNECTED,
        RTMP_STATUS_AUDIO_RECONNECT,
        RTMP_STATUS_NO_AUDIO,
        RTMP_STATUS_LOCAL_CONNECTION_ALIVE_INITIAL_STATE,
        RTMP_STATUS_LOCAL_CONNECTION_CORRUPTED_INITIAL_STATE,
        RTMP_STATUS_NO_VIDEO,
        RTMP_STATUS_FORCE_LOGOUT,
        
        //RTMP chat messages
        RTMP_CHAT_EVENT_BEGIN                           = 301,
        RTMP_CHAT_EVENT_TYPE_TXT_MESSAGE                = RTMP_CHAT_EVENT_BEGIN,
        RTMP_CHAT_EVENT_TYPE_TXT_MSG_DELIVERED,
        RTMP_CHAT_EVENT_TYPE_ROSTER,
        RTMP_CHAT_EVENT_TYPE_PRESENCE,
        RTMP_CHAT_EVENT_RESULT_TXT_MESSAGE,
        RTMP_CHAT_EVENT_INSTMSG,
        RTMP_CHAT_EVENT_INSTMSG_RESULT,
        RTMP_CHAT_EVENT_END,
        //==================
    };

    typedef enum PeerType
    {
        PT_UNKNOWN = -1,
        PT_FLASH = 0,
        PT_IPHONE,
        PT_ANDROID,
        PT_PSTN
    } PeerType;

    typedef struct rtmp_audio_event_s{
        AVal codec;
        int publisherFrameCount;
        int playerFrameCount;
        int internet_type;
    } rtmp_audio_event_t;
    
    typedef struct rtmp_event_s
    {
        TBI_DECLARE_OBJECT;
    
        char *messageType;
        char *from;
        AVal callNumber;
        AVal publishName;
        AVal playName;
        enum RTMP_EVENT_TYPE rtmp_call_event;
        rtmp_audio_event_t audio_event;
        rtmp_audio_event_t video_event;
        void* packet;
        PeerType call_type;
        int video_type;
        AVal media;
        int client_type;
        AVal FlashMessage;
        double level;
        double bitrate;
        AVal callId;
        int chatMsgType;
        
    } rtmp_event_t;

    extern const TBI_object_def_t* rtmp_event_def_t;

#ifdef __cplusplus
}
#endif
    
#endif
