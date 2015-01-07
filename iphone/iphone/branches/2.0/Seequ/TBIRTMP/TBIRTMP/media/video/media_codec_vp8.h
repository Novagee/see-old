/*
 *  Created by Grigori Jlavyan .
 *  Copyright 2011 BeInteractive. All rights reserved.
 *
 */


#ifndef TINYDAV_CODEC_VP8_H
#define TINYDAV_CODEC_VP8_H


#define HAVE_LIBVPX 1
#if HAVE_LIBVPX
#include "media_codec.h"

//#include "tinymedia/tmedia_codec.h"

#define VPX_CODEC_DISABLE_COMPAT 1 /* strict compliance with the latest SDK by disabling some backwards compatibility  */
#include <vpx/vpx_encoder.h>
#include <vpx/vpx_decoder.h>
#include <vpx/vp8cx.h>
#include <vpx/vp8dx.h>
#include "types.h"
#include "TBI_mutex.h"

typedef enum{
    INSTANCE_1=1,
    INSTANCE_2=2,
    INSTANCE_3=3,
} INSTANCE_NUMBER;

typedef struct vp8_encoder_instance_s{
	// Encoder
	struct{
		unsigned initialized:1;
		vpx_codec_pts_t pts;
		vpx_codec_ctx_t context;
		uint16_t pic_id;
		uint16_t gop_size;
		uint64_t frame_count;
        
		struct{
			uint8_t* ptr;
			tbi_size_t size;
		} rtp;
	} encoder;
    
//	// decoder
//	struct{
//		unsigned initialized:1;
//		vpx_codec_ctx_t context;
//		void* accumulator;
//		tbi_size_t accumulator_pos;
//		tbi_size_t accumulator_size;
//		uint16_t last_seq;
//		unsigned last_PartID:4;
//		unsigned last_S:1;
//		unsigned last_N:1;
//		unsigned frame_corrupted;
//	} decoder;
    
    struct {
        int width ;
        int height;
        int fps ;
        tbi_bool_t flip;
    } out;
    struct {
        int width ;
        int height;
        int fps ;
        tbi_bool_t flip;
    } in;
    INSTANCE_NUMBER intanse;
    int bitrate;
    tbi_bool_t forceKeyFrame;
//    tbi_bool_t isResChanged;
    tbi_bool_t isOpened;
    
} vp8_encoder_instance_t;


typedef struct vp8_instance_s{
	// decoder
	struct{
		unsigned initialized:1;
		vpx_codec_ctx_t context;
		void* accumulator;
		tbi_size_t accumulator_pos;
		tbi_size_t accumulator_size;
		uint16_t last_seq;
		unsigned last_PartID:4;
		unsigned last_S:1;
		unsigned last_N:1;
		unsigned frame_corrupted;
	} decoder;
} vp8_decoder_instance_t;


/* VP8 codec */
typedef struct media_codec_vp8_s
{
    vp8_encoder_instance_t *instance1;
    vp8_encoder_instance_t *instance2;
    vp8_encoder_instance_t *instance3;
    vp8_encoder_instance_t *currentInstance;
    
    vp8_decoder_instance_t *decoderInstance;
    
    tbi_bool_t changeForNext ;
    
    TBI_mutex_handle_t *chage;
    
    tbi_bool_t isClosed;
}
media_codec_vp8_t;

extern const media_codec_t *pmedia_codec_vp8;

#endif /* HAVE_LIBVPX */


#endif /* TINYDAV_CODEC_VP8_H */
