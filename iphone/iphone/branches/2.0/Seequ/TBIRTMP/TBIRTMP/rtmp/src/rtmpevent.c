//
//  rtmpevent.c
//  TBIRTMP
//
//  Created by Macbook on 10/24/13.
//  Copyright (c) 2013 Grigori Jlavyan. All rights reserved.
//

#include "rtmpevent.h"
#include "TBI_memory.h"

#include <stdio.h>

//=================================================================================================
//	rtmp_event_t object definition
//
static TBI_object_t* rtmp_event_ctor(TBI_object_t * self, va_list * app)
{
    rtmp_event_t *inst = (rtmp_event_t*)self;
    if(inst)
    {
        inst->rtmp_call_event = RTMP_EVENT_TYPE_UNKNOWN;
        inst->messageType = TBI_null;
        
        inst->callNumber.av_val = TBI_null;
        inst->callNumber.av_len = 0;
        inst->callId.av_val = TBI_null;
        inst->callId.av_len = 0;
        inst->publishName.av_val = TBI_null;
        inst->publishName.av_len = 0;
        inst->playName.av_val = TBI_null;
        inst->playName.av_len = 0;
        inst->from = TBI_null;
        
        inst->packet = TBI_null;
        inst->call_type = PT_UNKNOWN;
        inst->client_type = 0;
        inst->bitrate = 0.f;
        inst->level = 0.f;
        
        inst->audio_event.codec.av_val = 0;
        inst->audio_event.codec.av_len = 0;
        inst->video_event.codec.av_len = 0;
        inst->video_event.codec.av_val = 0;
        inst->audio_event.publisherFrameCount = 0;
        inst->audio_event.playerFrameCount = 0;
    }
    
    return self;
}

static TBI_object_t* rtmp_event_dtor(TBI_object_t * self)
{
    rtmp_event_t *inst = (rtmp_event_t*)self;
    if(inst)
    {
        TBI_FREE(inst->messageType);
        TBI_FREE(inst->from);
    }
    
    return self;
}

static const TBI_object_def_t rtmp_event_def_s =
{
    sizeof(rtmp_event_t),
    rtmp_event_ctor,
    rtmp_event_dtor,
    TBI_null,
};

const TBI_object_def_t *rtmp_event_def_t = &rtmp_event_def_s;
