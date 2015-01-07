//
//  tsk_mpeg4.h
//  ios-ngn-stack
//
//  Created by Administrator on 10/6/12.
//  Copyright (c) 2012 Doubango Telecom. All rights reserved.
//

#ifndef ios_ngn_stack_tsk_mpeg4_h
#define ios_ngn_stack_tsk_mpeg4_h

#include "tinysak_config.h"
#include "tsk_common.h"

extern int isBaseLine;
TINYSAK_API int get_phone_version();
TINYSAK_API tsk_bool_t rtmp_get_sps_pps_nal_unit(int version, int frm_width, uint8_t* spspps, int* spsppslen );
TINYSAK_API tsk_bool_t get_sps_pps_nal_unit(int version, int frm_width, const uint8_t** sps, int* spslen, const uint8_t** pps, int* ppslen );
TINYSAK_API tsk_bool_t mpeg4_get_sps_pps_nal_unit(const char* file_name, uint8_t** sps, int* sps_len, uint8_t** pps, int* pps_len, int* mdat_offset);

#endif
