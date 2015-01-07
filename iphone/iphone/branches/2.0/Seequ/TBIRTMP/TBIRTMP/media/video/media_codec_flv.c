/** @file media_codec_flv.c */
#include "media_codec_flv.h"
#include "media.h"
#include "mpeg4.h"
#include "TBI_debug.h"

extern uint8_t *spsUniversal;
extern uint32_t spsUniversalSize;
extern uint8_t *ppsUniversal;
extern uint32_t ppsUniversalSize;


int  media_codec_flv_get_video_settings(const char* file_name){
//    int mdat_offset;
//    
//    mpeg4_get_sps_pps_nal_unit(file_name,&spsUniversal,&spsUniversalSize,&ppsUniversal,&ppsUniversalSize,&mdat_offset);
//    fprintf(stderr, "sps_len = %i ; pps_len = %i ; mdat_offset = %i\n",spsUniversalSize, ppsUniversalSize,mdat_offset);
    return 0;
}

int media_codec_flv_open(media_codec_flv_t* flv, unsigned int width, unsigned int height, unsigned int fps, int encdec)
{
	int ret;
	int size;

	if(!flv){
		fprintf(stderr, "Invalid parameter");
		return -1;
	}

	/* the caller (base class) alreasy checked that the codec is not opened */
	
	//
	//	Encoder
	//
    if(encdec == MEDIA_ENCODER || encdec == MEDIA_ENCDEC)
    {
        if(!(flv->encoder.codec = avcodec_find_encoder(CODEC_ID_FLV1))){
            fprintf(stderr, "Failed to find flv encoder");
            return -2;
        }
    
        flv->encoder.context = avcodec_alloc_context3(flv->encoder.codec);
        avcodec_get_context_defaults3(flv->encoder.context, flv->encoder.codec);
        
        flv->encoder.context->pix_fmt           = PIX_FMT_YUV420P;
        flv->encoder.context->time_base.num     = 1;
        flv->encoder.context->time_base.den     = fps;
        flv->encoder.context->width             = width;
        flv->encoder.context->height            = height;
        
        flv->encoder.context->qmin = 4;
        flv->encoder.context->qmax = 31;
        flv->encoder.context->mb_decision = FF_MB_DECISION_RD;
        
        flv->encoder.context->thread_count = 1;
        flv->encoder.context->rtp_payload_size = 900;
        flv->encoder.context->opaque = 0;
        flv->encoder.context->gop_size = fps*2; /* each 2 seconds */
        flv->encoder.context->flags |= CODEC_FLAG_QSCALE;
        flv->encoder.context->global_quality = FF_QP2LAMBDA * 5;
        
        flv->encoder.context->flags |= CODEC_FLAG_AC_PRED;			/* Annex I and T */
        flv->encoder.context->flags |= CODEC_FLAG_LOOP_FILTER;		/* Annex J */
        
        flv->encoder.frame_count = 0;
		
        // Picture (YUV 420)
        if(!(flv->encoder.picture = avcodec_alloc_frame())){
            fprintf(stderr, "Failed to create encoder picture");
            return -2;
        }
        avcodec_get_frame_defaults(flv->encoder.picture);
        
        size = avpicture_get_size(flv->encoder.context->pix_fmt, flv->encoder.context->width, flv->encoder.context->height);
        if(!(flv->encoder.buffer = calloc(size, sizeof(uint8_t)))){
            fprintf(stderr, "Failed to allocate encoder buffer");
            return -2;
        }
        
        // Open encoder
        if((ret = avcodec_open2(flv->encoder.context, flv->encoder.codec, 0)) < 0){
            fprintf(stderr, "Failed to open codec");
            return ret;
        }
    }
    
	//
	//	Decoder
	//
    if(encdec == MEDIA_DECODER || encdec == MEDIA_ENCDEC)
    {
        if(!(flv->decoder.codec = avcodec_find_decoder(CODEC_ID_FLV1))){
            fprintf(stderr, "Failed to find flv decoder");
            return -2;
        }
        
        flv->decoder.context = avcodec_alloc_context3(flv->decoder.codec);
        avcodec_get_context_defaults3(flv->decoder.context, flv->decoder.codec);
        
        flv->decoder.context->pix_fmt = PIX_FMT_YUV420P;
        flv->decoder.context->flags2 |= CODEC_FLAG2_FAST;
        flv->decoder.context->width = width;
        flv->decoder.context->height = height;
        flv->decoder.context->debug = FF_DEBUG_PICT_INFO;
        
        // Picture (YUV 420)
        if(!(flv->decoder.picture = avcodec_alloc_frame())){
            fprintf(stderr, "Failed to create decoder picture");
            return -2;
        }
        avcodec_get_frame_defaults(flv->decoder.picture);
        
        // Open decoder
        if((ret = avcodec_open2(flv->decoder.context, flv->decoder.codec, 0)) < 0){
            fprintf(stderr, "Failed to open codec");
            return ret;
        }
    }
    
	return 0;
}

int media_codec_flv_close(media_codec_flv_t* flv)
{
	if(!flv){
		fprintf(stderr, "Invalid parameter");
		return -1;
	}

	/* the caller (base class) alreasy checked that the codec is opened */

	//
	//	Encoder
	//
	if(flv->encoder.context){
		avcodec_close(flv->encoder.context);
		av_free(flv->encoder.context);
	}
	if(flv->encoder.picture){
		av_free(flv->encoder.picture);
	}
	if(flv->encoder.buffer){
		free(flv->encoder.buffer);
        flv->encoder.buffer = 0;
	}

	//
	//	Decoder
	//
	if(flv->decoder.context){
		avcodec_close(flv->decoder.context);
		av_free(flv->decoder.context);
	}
	if(flv->decoder.picture){
		av_free(flv->decoder.picture);
	}
    
	return 0;
}

unsigned int media_codec_flv_encode(media_codec_flv_t* flv, const void* in_data, unsigned int in_size, void** out_data, unsigned int* out_max_size)
{
    int ret;
    int size;
    int got_packet;
    
    AVPacket pkt;
    av_init_packet(&pkt);
    pkt.data = NULL;
    pkt.size = 0;
    
    if(!flv || !in_data || !in_size || !out_data){
        TBI_DEBUG_ERROR("Invalid parameter");
        return 0;
    }
    
    // wrap yuv420 buffer
    size = avpicture_fill((AVPicture *)flv->encoder.picture, (uint8_t*)in_data, flv->encoder.context->pix_fmt, flv->encoder.context->width, flv->encoder.context->height);
    if(size != in_size){
        /* guard */
        TBI_DEBUG_ERROR("Invalid size");
        return 0;
    }
    
    flv->encoder.picture->pts = AV_NOPTS_VALUE;
    flv->encoder.picture->quality = flv->encoder.context->global_quality;
    
    flv->encoder.picture->key_frame = (flv->encoder.frame_count == 0 || flv->encoder.frame_count%flv->encoder.context->gop_size == 0) ? 1 : 0;
    
    //    ret = avcodec_encode_video(flv->encoder.context, flv->encoder.buffer, size, flv->encoder.picture);
    
    pkt.data = flv->encoder.buffer;
    pkt.size = size;
    ret = avcodec_encode_video2(flv->encoder.context, &pkt, flv->encoder.picture, &got_packet);

    if(*out_data || ret > *out_max_size)
    {
        *out_data = realloc(*out_data, ret);
        *out_max_size = ret;
    }
    
    memcpy(*out_data, flv->encoder.buffer, ret);
    flv->encoder.frame_count++;
    
    return ret;
}

unsigned int media_codec_flv_decode(media_codec_flv_t* flv, const void* in_data, unsigned int* in_size, void** out_data, unsigned int* out_max_size)
{
    unsigned int retsize = 0;
	return retsize;
}
