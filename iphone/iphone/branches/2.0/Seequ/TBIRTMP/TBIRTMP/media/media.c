//
//  media.c
//  rtmptest
//
//  Created by Administrator on 10/30/12.
//  Copyright (c) 2012 Administrator. All rights reserved.
//
#include "media.h"
#include "media_codec.h"
#include <libavcodec/avcodec.h>
#include <stdio.h>

tbi_bool_t initMedia()
{
    avcodec_register_all();

    return tbi_true;
}

float short2float(short sh)
{
    return (((float)sh)/32768.f);
}

short float2short(float f)
{
    return (short)(f * 32768);
}
