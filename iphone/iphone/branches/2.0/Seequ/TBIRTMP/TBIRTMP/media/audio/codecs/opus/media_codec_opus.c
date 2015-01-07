

/**@file tdav_codec_gsm.c
 * @brief GSM Full Rate Codec (Based on libgsm)
 *
 
 *
 
 */
#include "media_codec_opus.h"

#include "tbi_memory.h"
#include "tbi_debug.h"
#include "TBI_time.h"

/* ============ GSM Plugin interface ================= */

static int media_codec_opus_open(media_codec_t* self)
{
    if(self->codec)
        return 0;
    
    media_codec_opus_t* opus = calloc(1, sizeof(media_codec_opus_t));
 	self->codec = opus;
    
    int useInBandFEC = 0 ;
    int use_vbr = 0;
    int error;
    
    opus->decoder = opus_decoder_create(self->rate,self->audio.channels, &error);
    
    
    if(error!=OPUS_OK){
        TBI_DEBUG_ERROR("Opus decoder encountered an error %s", opus_strerror(error));
        return 0;
    }
    
    
    opus->encoder = opus_encoder_create(self->rate, self->audio.channels, OPUS_APPLICATION_VOIP, &error);
    
    opus_encoder_ctl(opus->encoder, OPUS_SET_VBR(use_vbr));
    
    if(self->audio.birate >= 6000 && self->audio.birate <= 510000){
        opus_encoder_ctl(opus->encoder, OPUS_SET_BITRATE(self->audio.birate));
    }
    
    opus_encoder_ctl(opus->encoder, OPUS_SET_INBAND_FEC(useInBandFEC));
    opus_encoder_ctl(opus->encoder, OPUS_SET_SIGNAL(OPUS_APPLICATION_VOIP));
    
    if(error!=OPUS_OK){
        TBI_DEBUG_ERROR("Opus encoder encountered an error %s", opus_strerror(error));
        return 0;
    }
    
	return 0;
}

static int media_codec_opus_close(media_codec_t* self)
{
    if(!self || !self->codec)
        return 0;
    
	media_codec_opus_t* opus = (media_codec_opus_t*)self->codec;
    
    if(opus->encoder)
        opus_encoder_destroy(opus->encoder);
    if(opus->decoder)
        opus_decoder_destroy(opus->decoder);
    free(opus);
    self->codec = 0;
	return 0;
}


static tbi_size_t media_codec_opus_encode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
{
    long time = TBI_time_epoch();
	tbi_size_t out_size = 0;
    
	if(!self || !in_data || !in_size || !out_data){
		TBI_DEBUG_ERROR("Invalid parameter");
		return 0;
	}
    
    //int count = (int)(in_size/320);
	media_codec_opus_t* opus = (media_codec_opus_t*)self->codec;
    if(!self->codec)
        return 0;
    if(*out_max_size < self->audio.codec_frame_size){
        *out_max_size = self->audio.codec_frame_size;
        *out_data =  TBI_realloc(*out_data, *out_max_size);
    }
    out_size = opus_encode(opus->encoder,(const opus_int16*)in_data, (int)(in_size/2),*out_data,*out_max_size);
    
    //TBI_DEBUG_INFO("out_size = %i %i" , TBI_time_epoch()-time,in_size);
	return out_size;
}

static tbi_size_t media_codec_opus_decode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
{
    
    
	tbi_size_t out_size = 0;
	media_codec_opus_t* opus = (media_codec_opus_t*)self->codec;
    
	if(!self || !in_data || !in_size || !out_data){
		TBI_DEBUG_ERROR("Invalid parameter");
		return 0;
	}
    int count = (int)(in_size/self->audio.codec_frame_size);
    if(*out_max_size<self->audio.pcm_frame_size*count){
        *out_data = TBI_realloc(*out_data, self->audio.pcm_frame_size*count);
        *out_max_size = self->audio.pcm_frame_size*count;
    }
    *out_max_size = 0;
    for (int i =0 ;i < in_size/self->audio.codec_frame_size; i++) {
        *out_max_size+=self->audio.pcm_frame_size;
        out_size += opus_decode(opus->decoder,(const unsigned char*)(in_data+i*self->audio.codec_frame_size), (int)(in_size/count),(opus_int16*)(*out_data + i*self->audio.pcm_frame_size),(self->audio.pcm_frame_size),0);
    }
    
	return out_size*2;
}

static media_codec_t media_codec_opus_s =
{
	media_audio,
	"opus",
	"opus Codec",
	MEDIA_CODEC_FORMAT_OPUS,
	8000, // rate
    {1,10,16000,20,320},
    {0,0,0},
    {0,0,0}, // rotate
    0,
    -1,
    1, // bits per sample
	media_codec_opus_open,
	media_codec_opus_close,
	media_codec_opus_encode,
	media_codec_opus_decode,
};

media_codec_t *pmedia_codec_opus = &media_codec_opus_s;



#pragma CODEC WITH BITRATE

static media_codec_t media_codec_opus8_8_s =
{
	media_audio,
	"opus8_8",
	"opus8_8 Codec",
	MEDIA_CODEC_FORMAT_OPUS8_8,
	8000, // rate
    {1,20,8000,20,320},
    {0,0,0},
    {0,0,0}, // rotate
    0,
    -1,
    1, // bits per sample
	media_codec_opus_open,
	media_codec_opus_close,
	media_codec_opus_encode,
	media_codec_opus_decode,
};

media_codec_t *pmedia_codec_opus8_8 = &media_codec_opus8_8_s;


static media_codec_t media_codec_opus8_16_s =
{
	media_audio,
	"opus8_16",
	"opus8_16 Codec",
	MEDIA_CODEC_FORMAT_OPUS8_16,
	8000, // rate
    {1,20,16000,40,320},
    {0,0,0},
    {0,0,0}, // rotate
    0,
    -1,
    1, // bits per sample
	media_codec_opus_open,
	media_codec_opus_close,
	media_codec_opus_encode,
	media_codec_opus_decode,
};

media_codec_t *pmedia_codec_opus8_16 = &media_codec_opus8_16_s;



static media_codec_t media_codec_opus8_32_s =
{
	media_audio,
	"opus8_32",
	"opus8_32 Codec",
	MEDIA_CODEC_FORMAT_OPUS8_32,
	8000, // rate
    {1,20,32000,80,320},
    {0,0,0},
    {0,0,0}, // rotate
    0,
    -1,
    1, // bits per sample
	media_codec_opus_open,
	media_codec_opus_close,
	media_codec_opus_encode,
	media_codec_opus_decode,
};

media_codec_t *pmedia_codec_opus8_32 = &media_codec_opus8_32_s;

static media_codec_t media_codec_opus16_16_s =
{
	media_audio,
	"opus16_16",
	"opus16_16 Codec",
	MEDIA_CODEC_FORMAT_OPUS16_16,
	16000, // rate
    {1,20,16000,40,640},
    {0,0,0},
    {0,0,0}, // rotate
    0,
    -1,
    1, // bits per sample
	media_codec_opus_open,
	media_codec_opus_close,
	media_codec_opus_encode,
	media_codec_opus_decode,
};

media_codec_t *pmedia_codec_opus16_16 = &media_codec_opus16_16_s;

static media_codec_t media_codec_opus16_32_s =
{
	media_audio,
	"opus16_32",
	"opus16_32 Codec",
	MEDIA_CODEC_FORMAT_OPUS16_32,
	16000, // rate
    {1,20,32000,80,640},
    {0,0,0},
    {0,0,0}, // rotate
    0,
    -1,
    1, // bits per sample
	media_codec_opus_open,
	media_codec_opus_close,
	media_codec_opus_encode,
	media_codec_opus_decode,
};

media_codec_t *pmedia_codec_opus16_32 = &media_codec_opus16_32_s;

//custom
//static int media_custom_codec_opus_open(media_codec_t* self)
//{
//    if(self->codec)
//        return 0;
//    
//    media_custom_codec_opus_t* opus_custom = calloc(1, sizeof(media_custom_codec_opus_t));
// 	self->codec = opus_custom;
//    
//    int use_vbr = 0;
//    
//    int channels = 1;
//    int error;
//    self->rate = 500;
//    opus_custom->mode = opus_custom_mode_create(self->rate, 48, &error);
//    if(!opus_custom->mode)
//    {
//        TBI_DEBUG_ERROR("Opus opus_custom_mode_create error %s", opus_strerror(error));
//        return -1;
//    }
//    
//    opus_custom->decoder = opus_custom_decoder_create(opus_custom->mode, channels, &error);
//    if(error!=OPUS_OK){
//        TBI_DEBUG_ERROR("Opus decoder encountered an error %s", opus_strerror(error));
//        return -1;
//    }
//    
//    ///opus_encoder_init(opus->encoder , API_fs_Hz, channels, OPUS_APPLICATION_VOIP);
//    
//    opus_custom->encoder = opus_custom_encoder_create(opus_custom->mode, channels, &error);
//    opus_custom_encoder_ctl(opus_custom->encoder, OPUS_SET_VBR(use_vbr));
//    
//    int maxBitRate = 12000;
//    int useInBandFEC = 0 ;
//    
//    if(maxBitRate >= 6000 && maxBitRate <= 510000){
//        opus_custom_encoder_ctl(opus_custom->encoder, OPUS_SET_BITRATE(maxBitRate));
//    }
//    
//    opus_custom_encoder_ctl(opus_custom->encoder, OPUS_SET_INBAND_FEC(useInBandFEC));
//    opus_custom_encoder_ctl(opus_custom->encoder, OPUS_SET_SIGNAL(OPUS_APPLICATION_VOIP));
//    
//    if(error!=OPUS_OK){
//        TBI_DEBUG_ERROR("Opus encoder encountered an error %s", opus_strerror(error));
//        return -1;
//    }
//    
//	return 0;
//}
//
//static int media_custom_codec_opus_close(media_codec_t* self)
//{
//    if(!self || !self->codec)
//        return 0;
//    
//	media_custom_codec_opus_t* opus = (media_custom_codec_opus_t*)self->codec;
//    
//    if(opus->encoder)
//        opus_custom_encoder_destroy(opus->encoder);
//    if(opus->decoder)
//        opus_custom_decoder_destroy(opus->decoder);
//    free(opus);
//    self->codec = 0;
//	return 0;
//}

//static tbi_size_t media_custom_codec_opus_encode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
//{
//	tbi_size_t out_size = 0;
//    
//	if(!self || !in_data || !in_size || !out_data){
//		TBI_DEBUG_ERROR("Invalid parameter");
//		return 0;
//	}
//    //int count = (int)(in_size/320);
//	media_custom_codec_opus_t* opus = (media_custom_codec_opus_t*)self->codec;
//    if(!self->codec)
//        return 0;
//    
//    int channels = 1 ;
//    
//    int frame_size = opus_custom_encoder_get_size(opus->mode, channels);
//    
//    if(*out_max_size < OPUS_FRAME_SIZE*AUDIO_FRAMES_COUNT){
//        *out_max_size = OPUS_FRAME_SIZE*AUDIO_FRAMES_COUNT;
//        *out_data =  TBI_realloc(*out_data, *out_max_size);
//    }
//    
//    out_size = opus_custom_encode(opus->encoder,(const opus_int16*)in_data, (int)(in_size/2),*out_data,*out_max_size);
//	return out_size;
//}
//
//static tbi_size_t media_custom_codec_opus_decode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
//{
//	tbi_size_t out_size = 0;
//	media_custom_codec_opus_t* opus = (media_custom_codec_opus_t*)self->codec;
//    
//	if(!self || !in_data || !in_size || !out_data){
//		TBI_DEBUG_ERROR("Invalid parameter");
//		return 0;
//	}
//    //int count = (int)(in_size/OPUS_FRAME_SIZE);
//    if(*out_max_size<PCM_FRAME_SIZE*AUDIO_FRAMES_COUNT){
//        *out_data = TBI_realloc(*out_data, PCM_FRAME_SIZE*AUDIO_FRAMES_COUNT);
//        *out_max_size = PCM_FRAME_SIZE*AUDIO_FRAMES_COUNT;
//    }
//    
//    out_size = opus_custom_decode(opus->decoder,(const unsigned char*)in_data, (int)in_size,(opus_int16*)(*out_data), *out_max_size);
//	return out_size*2;
//}
//
//
//static media_codec_t media_custom_codec_opus_s =
//{
//	media_audio,
//	"opus",
//	"opus Codec",
//	MEDIA_CODEC_FORMAT_OPUS,
//	8000, // rate
//    {0,10},
//    {0,0,0},
//    12000,
//    -1,
//    1, // bits per sample
//	media_custom_codec_opus_open,
//	media_custom_codec_opus_close,
//	media_custom_codec_opus_encode,
//	media_custom_codec_opus_decode,
//};
//
//media_codec_t *pmedia_custom_codec_opus = &media_custom_codec_opus_s;




