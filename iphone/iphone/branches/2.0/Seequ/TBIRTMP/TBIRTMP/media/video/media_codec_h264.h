

/**@file tdav_codec_h264.h
 * @brief H.264 codec plugin using FFmpeg for decoding and x264 for encoding
 * RTP payloader/depayloader follows RFC 3984.
 *
 
 *
 */
#ifndef MEDIA_CODEC_H264_H
#define MEDIA_CODEC_H264_H

#include "../../utils/types.h"
#include "libavcodec/avcodec.h"
#include "media_codec.h"

typedef struct media_codec_h264_s
{
	// Encoder
	struct{
		AVCodec* codec;
		AVCodecContext* context;
		AVFrame* picture;
		void* buffer;
		int64_t frame_count;
	} encoder;
	
	// decoder
	struct{
		AVCodec* codec;
		AVCodecContext* context;
		AVFrame* picture;
        
		void* accumulator;
		unsigned int    accumulator_pos;
		unsigned int    accumulator_size;
		unsigned short  last_seq;
	} decoder;
    
    tbi_bool_t opened;
}
media_codec_h264_t;

extern media_codec_t *pmedia_codec_h264;

int media_codec_h264_open(media_codec_t* h264);
int media_codec_h264_close(media_codec_t* h264);
//tbi_size_t media_codec_h264_encode(media_codec_t* h264, const void* in_data, unsigned int in_size, void** out_data, unsigned int* out_max_size);
//tbi_size_t media_codec_h264_decode(media_codec_t* h264, const void* in_data, unsigned int in_size, void** out_data, unsigned int* out_max_size);
int  media_codec_h264_get_video_settings(const char* file_name, int numbe);

#endif /* MEDIA_CODEC_H264_H */