//
//  TBI_mpeg4.h
//  ios-ngn-stack
//
//  Created by Administrator on 10/6/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#ifndef ios_ngn_stack_TBI_mpeg4_h
#define ios_ngn_stack_TBI_mpeg4_h

#include "types.h"
#include <stdint.h>

typedef enum{
    SIZE_NO        = 0,
    SIZE_176_X_144 = 1,
    SIZE_320_X_240 = 2,
    SIZE_352_X_288 = 3,
    SIZE_640_X_480 = 4,
    
} video_size_type;

extern int isBaseLine;
enum iPhoneModels get_phone_version();

tbi_bool_t rtmp_get_sps_pps_nal_unit(uint8_t* spspps, int* spsppslen,int type );
tbi_bool_t get_sps_pps_nal_unit(const uint8_t** sps, int* spslen, const uint8_t** pps, int* ppslen, int type  );
tbi_bool_t mpeg4_get_sps_pps_nal_unit(const char* file_name, uint8_t** sps, uint32_t* sps_len, uint8_t** pps, uint32_t* pps_len, int* mdat_offset);

#endif
