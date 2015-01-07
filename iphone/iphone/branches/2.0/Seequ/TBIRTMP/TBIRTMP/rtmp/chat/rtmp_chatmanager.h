//
//  chatmanager.h
//  TBIRTMP
//
//  Created by Macbook on 9/12/13.
//  Copyright (c) 2013 Grigori Jlavyan. All rights reserved.
//

#ifndef TBIRTMP_chatmanager_h
#define TBIRTMP_chatmanager_h

#include "tbi_config.h"
#include "rtmpmanager.h"

TBI_BEGIN_DECLS

enum IM_TYPE
{
    IM_TYPE_NONE
    , IM_TYPE_REMOVE
    , IM_TYPE_ADD
    , IM_TYPE_ACCEPT
    , IM_TYPE_DECLINE
    , IM_TYPE_CREAT_GROUP
    , IM_TYPE_JOIN_GROUP
    , IM_TYPE_LEAVE_GROUP
    , IM_TYPE_INVITE_GROUP
    , IM_TYPE_MESSAGE_GROUP
    , IM_TYPE_DESTROY_GROUP
    , IM_TYPE_MESSAGE
};

TINYRTMP_API int rtmp_chatmanager_send_txtMsg(rtmp_manager_t* manager, const char* data, int len);
TINYRTMP_API int rtmp_chatmanager_send_txtMsgDeliveryNotify(rtmp_manager_t* manager, const char* data, int len);
TINYRTMP_API int rtmp_chatmanager_send_instmsg(rtmp_manager_t* manager, int type, const char* data, int len, int queue);
TINYRTMP_API int rtmp_chatmanager_onReceive(rtmp_manager_t* manager, rtmp_event_t *event);

TBI_END_DECLS

#endif
