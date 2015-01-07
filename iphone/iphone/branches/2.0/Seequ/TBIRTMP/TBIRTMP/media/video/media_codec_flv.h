/** @file tdav_codec_flv.h */
#ifndef MEDIA_CODEC_FLV_H
#define MEDIA_CODEC_FLV_H

#include "../../utils/types.h"
#include "libavcodec/avcodec.h"

typedef struct media_codec_flv_s
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

		unsigned short  last_seq;
	} decoder;
    
    tbi_bool_t opened;
}
media_codec_flv_t;

int media_codec_flv_open(media_codec_flv_t* flv, unsigned int width, unsigned int height, unsigned int fps, int encdec);
int media_codec_flv_close(media_codec_flv_t* flv);
unsigned int media_codec_flv_encode(media_codec_flv_t* flv, const void* in_data, unsigned int in_size, void** out_data, unsigned int* out_max_size);
unsigned int media_codec_flv_decode(media_codec_flv_t* flv, const void* in_data, unsigned int* in_size, void** out_data, unsigned int* out_max_size);
int  media_codec_flv_get_video_settings(const char* file_name);

#endif /* MEDIA_CODEC_FLV_H */