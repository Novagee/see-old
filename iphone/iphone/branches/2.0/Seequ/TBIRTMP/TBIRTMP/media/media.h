//
//  media.h
//  rtmptest
//
//  Created by Administrator on 10/30/12.
//  Copyright (c) 2012 Administrator. All rights reserved.
//

#ifndef rtmp_media_h
#define rtmp_media_h

#include "types.h"

#define MEDIA_ENCODER     0
#define MEDIA_DECODER     1
#define MEDIA_ENCDEC      2

/** List of all supported media types */
typedef enum media_type_e
{
	media_none  = 0x00,
	media_ghost = (0x01 << 0),
    
	media_audio = (0x01 << 1),
	media_video = (0x01 << 2),
	media_chat  = (0x01 << 3),
	media_file  = (0x01 << 4),
	media_t38   = (0x01 << 5),
    
	media_msrp          = (media_chat | media_file),
	media_audiovideo    = (media_audio | media_video),
    
	media_all           = (media_audio | media_video | media_msrp | media_t38)
}
media_type_t;

typedef enum media_bandwidth_level_e
{
	media_bl_low,
	media_bl_medium,
	media_bl_hight,
	media_bl_unrestricted
}
media_bandwidth_level_t;

tbi_bool_t initMedia();
float short2float(short sh);
short float2short(float f);

#endif
