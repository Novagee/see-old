//
//  chatmanager.c
//  TBIRTMP
//
//  Created by Macbook on 9/12/13.
//  Copyright (c) 2013 Samvel Shahkbazyan. All rights reserved.
//

#include "rtmp_chatmanager.h"
#include "rtmpmanager.h"
#include "TBIRTMP.h"
#include "rtmp.h"

#include <string.h>

int rtmp_chatmanager_send_txtMsg(rtmp_manager_t* manager, const char* data, int len)
{
    if(!manager || ! data || len <= 0)
        return -1;
    
    AVal uid;
    
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);
    
    return TBI_RTMP_SendChatTextMessage(manager->rtmp, &uid, data, len);
}

int rtmp_chatmanager_send_txtMsgDeliveryNotify(rtmp_manager_t* manager, const char* data, int len)
{
    if(!manager || ! data || len <= 0)
        return -1;
    
    AVal uid;
    
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);

    return TBI_RTMP_SendTextDelivaryNotify(manager->rtmp, &uid, data, len);
}

int rtmp_chatmanager_send_instmsg(rtmp_manager_t* manager, int type, const char* data, int len, int queue)
{
    if(!manager || ! data || len <= 0)
        return -1;
    
    AVal uid;
    
    uid.av_val = manager->uid;
    uid.av_len = strlen(manager->uid);
    
    return TBI_RTMP_SendInstMsg(manager->rtmp, &uid, type, data, len, queue);
}

int rtmp_chatmanager_onReceive(rtmp_manager_t* manager, rtmp_event_t *event)
{
    callBackChatEvent(event);
    return 0;
}