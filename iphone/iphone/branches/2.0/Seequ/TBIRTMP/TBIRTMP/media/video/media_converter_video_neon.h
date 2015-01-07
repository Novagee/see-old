//
//  media_converter_video_neon.h
//  ios-ngn-stack
//
//  Created by Samvel on 1/26/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#ifndef ios_ngn_stack_media_converter_video_neon_h
#define ios_ngn_stack_media_converter_video_neon_h

#include "TBI_common.h"

#ifdef __ARM_NEON__

#ifdef __cplusplus
extern "C"{
#endif

extern void deinterlace_and_rotate_180_neon(uint8_t* ysrc, uint8_t* cbcrsrc, uint8_t* ydst, uint8_t* udst, uint8_t* vdst, int w, int h, int y_byte_per_row,int cbcr_byte_per_row);

extern void deinterlace_down_scale_neon(uint8_t* ysrc, uint8_t* cbcrsrc, uint8_t* ydst, uint8_t* u_dst, uint8_t* v_dst, int w, int h, int y_byte_per_row,int cbcr_byte_per_row,tbi_bool_t down_scale);

extern void rotate_down_scale_plane_neon_clockwise(int wDest, int hDest, int full_width, uint8_t* src, uint8_t* dst,tbi_bool_t down_scale);
extern void rotate_down_scale_plane_neon_anticlockwise(int wDest, int hDest, int full_width, uint8_t* src, uint8_t* dst,tbi_bool_t down_scale);
extern void rotate_down_scale_cbcr_to_cr_cb(int wDest, int hDest, int full_width, uint8_t* cbcr_src, uint8_t* cr_dst, uint8_t* cb_dst, tbi_bool_t clockWise, tbi_bool_t down_scale);
extern void deinterlace_down_scale_and_rotate_180_neon(uint8_t* ysrc, uint8_t* cbcrsrc, uint8_t* ydst, uint8_t* udst, uint8_t* vdst, int w, int h, int y_byte_per_row,int cbcr_byte_per_row,tbi_bool_t down_scale);
    
#ifdef __cplusplus
}
#endif

#endif //__ARM_NEON__

#endif
