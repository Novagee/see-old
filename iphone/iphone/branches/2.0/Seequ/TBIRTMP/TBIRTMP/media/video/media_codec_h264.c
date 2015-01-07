 

/**@file media_codec_h264.c
 * @brief H.264 codec plugin using FFmpeg for decoding and x264 for encoding
 * RTP payloader/depayloader follows RFC 3984
 *

 *

 */
#include "media_codec_h264.h"
#include "mpeg4.h"
#include "TBI_debug.h"

extern uint8_t *spsUniversal176x144;
extern uint32_t spsUniversalSize176x144;
extern uint8_t *ppsUniversal176x144;
extern uint32_t ppsUniversalSize176x144;

extern uint8_t *spsUniversal352x288;
extern uint32_t spsUniversalSize352x288;
extern uint8_t *ppsUniversal352x288;
extern uint32_t ppsUniversalSize352x288;

extern uint8_t *spsUniversal640x480;
extern uint32_t spsUniversalSize640x480;
extern uint8_t *ppsUniversal640x480;
extern uint32_t ppsUniversalSize640x480;

uint8_t H264_START_CODE_PREFIX[4] = { 0x00, 0x00, 0x00, 0x01 };

int  media_codec_h264_get_video_settings(const char* file_name, int number){
    int mdat_offset;
    tbi_bool_t bRet = tbi_false;
    if (number==SIZE_176_X_144) {
        bRet = mpeg4_get_sps_pps_nal_unit(file_name,&spsUniversal176x144,&spsUniversalSize176x144,&ppsUniversal176x144,&ppsUniversalSize176x144,&mdat_offset);
        TBI_DEBUG_INFO("************************************** sps_len = %i ; pps_len = %i ; mdat_offset = %i",spsUniversalSize176x144, ppsUniversalSize176x144, mdat_offset);
    } else if(number==SIZE_352_X_288){
        bRet = mpeg4_get_sps_pps_nal_unit(file_name,&spsUniversal352x288,&spsUniversalSize352x288,&ppsUniversal352x288,&ppsUniversalSize352x288,&mdat_offset);
       TBI_DEBUG_INFO("************************************** sps_len = %i ; pps_len = %i ; mdat_offset = %i",spsUniversalSize352x288, ppsUniversalSize352x288, mdat_offset);
    }
    else if(number==SIZE_640_X_480){
        bRet = mpeg4_get_sps_pps_nal_unit(file_name,&spsUniversal640x480,&spsUniversalSize640x480,&ppsUniversal640x480,&ppsUniversalSize640x480,&mdat_offset);
        TBI_DEBUG_INFO("************************************** sps_len = %i ; pps_len = %i ; mdat_offset = %i",spsUniversalSize640x480, ppsUniversalSize640x480, mdat_offset);
    }
    
    if (bRet == tbi_true) {
        return 0;
    }
    
    return -1;
}

/* ============ H.264 Base Profile X.X Plugin interface functions ================= */
int media_codec_h264_open(media_codec_t* self)
{
	int ret;

	if(!self){
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	media_codec_h264_t *h264 = calloc(1, sizeof(media_codec_h264_t));
    
    self->codec = h264;

    
    
    unsigned int width  = self->video.width;
    unsigned int height= self->video.height;
    unsigned int fps = self->video.fps;
    
	/* the caller (base class) alreasy checked that the codec is not opened */
    
	//
	//	Encoder
	//
#ifdef RTMP_H264_ENCODER
    if(!(h264->encoder.codec = avcodec_find_encoder(CODEC_ID_H264))){
		TBI_DEBUG_ERROR("Failed to find H.264 encoder");
		return -2;
	}
    
	h264->encoder.context = avcodec_alloc_context();
	avcodec_get_context_defaults(h264->encoder.context);

#if TDAV_UNDER_WINDOWS
	h264->encoder.context->dsp_mask = (FF_MM_MMX | FF_MM_MMXEXT | FF_MM_SSE);
#endif

	h264->encoder.context->pix_fmt		= PIX_FMT_YUV420P;
	h264->encoder.context->time_base.num  = 1;
	h264->encoder.context->time_base.den  = fps;
	h264->encoder.context->width = width;
	h264->encoder.context->height = height;

//	h264->encoder.context->rc_lookahead = 0;

	//h264->encoder.context->refs = 1;
    h264->encoder.context->scenechange_threshold = 0;
    h264->encoder.context->me_subpel_quality = 0;
//    h264->encoder.context->partitions = X264_PART_I4X4 | X264_PART_I8X8 | X264_PART_P8X8 | X264_PART_B8X8;
    h264->encoder.context->me_method = ME_EPZS;
    h264->encoder.context->trellis = 0;

	h264->encoder.context->me_range = 16;
	h264->encoder.context->max_qdiff = 4;
//	h264->encoder.context->mb_qmin = h264->encoder.context->qmin = 10;
//	h264->encoder.context->mb_qmax = h264->encoder.context->qmax = 51;
	h264->encoder.context->qcompress = 0.6f;
	h264->encoder.context->mb_decision = FF_MB_DECISION_SIMPLE;
//	h264->encoder.context->flags2 |= CODEC_FLAG2_FASTPSKIP;
	h264->encoder.context->flags |= CODEC_FLAG_LOOP_FILTER;
	h264->encoder.context->flags |= CODEC_FLAG_GLOBAL_HEADER;
	h264->encoder.context->max_b_frames = 0;
	h264->encoder.context->b_frame_strategy = 1;
	h264->encoder.context->chromaoffset = 0;

    h264->encoder.context->profile = FF_PROFILE_H264_BASELINE;
    h264->encoder.context->level = 30;

//	h264->encoder.context->crf = 22;
	h264->encoder.context->thread_count = 1;
	h264->encoder.context->rtp_payload_size = 900;
	h264->encoder.context->opaque = 0;
	h264->encoder.context->gop_size = fps * 2; // Each 2 second(s)
		
	// Picture (YUV 420)
	if(!(h264->encoder.picture = avcodec_alloc_frame())){
		TBI_DEBUG_ERROR("Failed to create encoder picture");
		return -2;
	}
	avcodec_get_frame_defaults(h264->encoder.picture);
	
	size = avpicture_get_size(PIX_FMT_YUV420P, h264->encoder.context->width, h264->encoder.context->height);
	if(!(h264->encoder.buffer = calloc(size, sizeof(uint8_t)))){
		TBI_DEBUG_ERROR("Failed to allocate encoder buffer");
		return -2;
	}

	// Open encoder
	if((ret = avcodec_open(h264->encoder.context, h264->encoder.codec)) < 0){
		TBI_DEBUG_ERROR("Failed to open codec");
		return ret;
	}
#endif //RTMP_H264_ENCODER

	//
	//	Decoder
	//
	if(!(h264->decoder.codec = avcodec_find_decoder(CODEC_ID_H264))){
		TBI_DEBUG_ERROR("Failed to find H.264 decoder");
		return -2;
	}

	h264->decoder.context = avcodec_alloc_context3(h264->decoder.codec);
	avcodec_get_context_defaults3(h264->decoder.context, h264->decoder.codec);
	
	h264->decoder.context->pix_fmt = PIX_FMT_YUV420P;
	h264->decoder.context->flags2 |= CODEC_FLAG2_FAST;
	h264->decoder.context->width = width;
	h264->decoder.context->height = height;
    h264->decoder.context->debug = FF_DEBUG_PICT_INFO;
	
	// Picture (YUV 420)
	if(!(h264->decoder.picture = avcodec_alloc_frame())){
		TBI_DEBUG_ERROR("Failed to create decoder picture");
		return -2;
	}
	avcodec_get_frame_defaults(h264->decoder.picture);

	// Open decoder
	if((ret = avcodec_open2(h264->decoder.context, h264->decoder.codec, 0)) < 0){
		TBI_DEBUG_ERROR("Failed to open codec");
		return ret;
	}

	return 0;
}

int media_codec_h264_close(media_codec_t* self)
{
    
    
  
	if(!self){
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
    
    media_codec_h264_t *h264 = (media_codec_h264_t*) self->codec;
    
	/* the caller (base class) alreasy checked that the codec is opened */

	//
	//	Encoder
	//
	if(h264->encoder.context){
		avcodec_close(h264->encoder.context);
		av_free(h264->encoder.context);
	}
	if(h264->encoder.picture){
		av_free(h264->encoder.picture);
	}
	if(h264->encoder.buffer){
		free(h264->encoder.buffer);
        h264->encoder.buffer = 0;
	}

	//
	//	Decoder
	//
	if(h264->decoder.context){
		avcodec_close(h264->decoder.context);
		av_free(h264->decoder.context);
	}
	if(h264->decoder.picture){
		av_free(h264->decoder.picture);
	}
	free(h264->decoder.accumulator);
    h264->decoder.accumulator = 0;
	h264->decoder.accumulator_pos = 0;

	return 0;
}

// For Hardware. Not need to encode. The in_data is already encoded.
int isBaseLine = 1;
tbi_size_t media_codec_h264_encode(media_codec_t* self, const void* in_data, unsigned int in_size, void** out_data, unsigned int* out_max_size)
{
//    media_codec_h264_t *h264 = (media_codec_h264_t*)self->codec;
    
    *out_data = realloc(*out_data, in_size);
    memcpy(*out_data, in_data, in_size);
    *out_max_size = in_size;
    return *out_max_size;
}

tbi_size_t media_codec_h264_decode(media_codec_t* self, const void* in_data, unsigned int in_size, void** out_data, unsigned int* out_max_size)
{
    
    media_codec_h264_t *h264 = (media_codec_h264_t*)self->codec;
    
    static int packet_count = 0;
    static int bad_packet_count = 0;
    
	int ret;
	unsigned int retsize = 0, size_to_copy = 0;
	static unsigned int xmax_size = (1920 * 1080 * 3) >> 3;
	static unsigned int start_code_prefix_size = sizeof(H264_START_CODE_PREFIX);
	int got_picture_ptr;
    
	if(!h264 || !in_data || !in_size || !out_data || !h264->decoder.context){
		TBI_DEBUG_ERROR("Invalid parameter");
		return 0;
	}
	
	size_to_copy = in_size + start_code_prefix_size;
	
	// start-accumulator
	if(!h264->decoder.accumulator){
		if(size_to_copy > xmax_size){
			TBI_DEBUG_ERROR("%u too big to contain valid encoded data. xmax_size=%u", size_to_copy, xmax_size);
			return 0;
		}
		if(!(h264->decoder.accumulator = calloc(size_to_copy, sizeof(uint8_t)))){
			TBI_DEBUG_ERROR("Failed to allocated new buffer");
			return 0;
		}
		h264->decoder.accumulator_size = size_to_copy;
	}
	if((h264->decoder.accumulator_pos + size_to_copy) >= xmax_size){
		TBI_DEBUG_ERROR("BufferOverflow");
		h264->decoder.accumulator_pos = 0;
		return 0;
	}
	if((h264->decoder.accumulator_pos + size_to_copy) > h264->decoder.accumulator_size){
		if(!(h264->decoder.accumulator = realloc(h264->decoder.accumulator, (h264->decoder.accumulator_pos + size_to_copy)))){
			TBI_DEBUG_ERROR("Failed to reallocated new buffer");
			h264->decoder.accumulator_pos = 0;
			h264->decoder.accumulator_size = 0;
			return 0;
		}
		h264->decoder.accumulator_size = (h264->decoder.accumulator_pos + size_to_copy);
	}
    
    memcpy(&((uint8_t*)h264->decoder.accumulator)[h264->decoder.accumulator_pos], H264_START_CODE_PREFIX, start_code_prefix_size);
    h264->decoder.accumulator_pos += start_code_prefix_size;

	memcpy(&((uint8_t*)h264->decoder.accumulator)[h264->decoder.accumulator_pos], in_data, in_size);
	h264->decoder.accumulator_pos += in_size;

	// end-accumulator
    if (((uint8_t*)(h264->decoder.accumulator))[0] == H264_START_CODE_PREFIX[0] &&
        ((uint8_t*)(h264->decoder.accumulator))[1] == H264_START_CODE_PREFIX[1] &&
        ((uint8_t*)(h264->decoder.accumulator))[2] == H264_START_CODE_PREFIX[2] &&
        ((uint8_t*)(h264->decoder.accumulator))[3] == H264_START_CODE_PREFIX[3]) {
        
        AVPacket packet;
        packet_count++;
        
        /* decode the picture */
        av_init_packet(&packet);
        packet.size = h264->decoder.accumulator_pos;
        packet.data = h264->decoder.accumulator;
        
        ret = avcodec_decode_video2(h264->decoder.context, h264->decoder.picture, &got_picture_ptr, &packet);
        if(ret < 0){
//            TBI_DEBUG_ERROR("=============Failed to decode the buffer");
            bad_packet_count++;
        }
        else if(got_picture_ptr){
            unsigned int xsize;
            
            /* fill out */
            xsize = avpicture_get_size(h264->decoder.context->pix_fmt, h264->decoder.context->width, h264->decoder.context->height);
            if(*out_max_size<xsize){
                if((*out_data = realloc(*out_data, (xsize + FF_INPUT_BUFFER_PADDING_SIZE)))){
                    *out_max_size = xsize;
                }
                else{
                    *out_max_size = 0;
                    bad_packet_count++;
                    
                    return 0;
                }
            }
            retsize = xsize;
            self->rotate.width = h264->decoder.context->width;
            self->rotate.height = h264->decoder.context->height;

            avpicture_layout((AVPicture *)h264->decoder.picture, h264->decoder.context->pix_fmt, h264->decoder.context->width, h264->decoder.context->height, *out_data, retsize);
        }
    }
    
    h264->decoder.accumulator_pos = 0;

	return retsize;
}

static media_codec_t media_codec_h264_s =
{
	media_video,
	"h264",
	"h264 Codec",
	MEDIA_CODEC_FORMAT_H264_352_X_288,
	8000, // rate
	{0,0},
    {288,352,12},
    {0,352,288}, // rotate
    0,
    -1,
    2, // bits per sample
	media_codec_h264_open,
	media_codec_h264_close,
	media_codec_h264_encode,
	media_codec_h264_decode,
};
media_codec_t *pmedia_codec_h264 = &media_codec_h264_s;
