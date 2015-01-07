

/**@file media_codec_speex.c
 * @brief Speex codecs
 *
 
 *
 
 */
#include "media_codec_speex.h"

#if HAVE_LIB_SPEEX

#include "memory.h"
#include "tbi_debug.h"
#include "media.h"

#include <stdlib.h>

#define SPEEX_BUFFER_MAX_SIZE		1024
#define SPEEX_DEFAULT_QUALITY		4

/* ============ Speex Plugin interface ================= */

int media_codec_speex_open(media_codec_t* self)
{
    if(self->codec)
        return 0;
    
	static int quality = SPEEX_DEFAULT_QUALITY;
	media_codec_speex_t* speex = (media_codec_speex_t*)calloc(1, sizeof(media_codec_speex_t));
	
	switch(self->format){
		case MEDIA_CODEC_FORMAT_SPEEX_NB:
			speex->encoder.state = speex_encoder_init(&speex_nb_mode);
			speex->decoder.state = speex_decoder_init(&speex_nb_mode);
			break;
		case MEDIA_CODEC_FORMAT_SPEEX_WB:
			speex->encoder.state = speex_encoder_init(&speex_wb_mode);
			speex->decoder.state = speex_decoder_init(&speex_wb_mode);
			break;
		case MEDIA_CODEC_FORMAT_SPEEX_UWB:
			speex->encoder.state = speex_encoder_init(&speex_uwb_mode);
			speex->decoder.state = speex_decoder_init(&speex_uwb_mode);
			break;
		default:
			TBI_DEBUG_ERROR("Not implemented");
			return -2;
	}
    
	speex_decoder_ctl(speex->decoder.state, SPEEX_GET_FRAME_SIZE, &speex->decoder.size);
	speex->decoder.size = (speex->decoder.size ? speex->decoder.size : SPEEX_BUFFER_MAX_SIZE) * sizeof(spx_int16_t);
	if(!(speex->decoder.buffer = calloc(1, speex->decoder.size))){
		speex->decoder.size = 0;
		TBI_DEBUG_ERROR("Failed to allocate new buffer");
		return -3;
	}
    
	speex_encoder_ctl(speex->encoder.state, SPEEX_SET_QUALITY, &quality);
	speex_encoder_ctl(speex->encoder.state, SPEEX_GET_FRAME_SIZE, &speex->encoder.size);
	if(!speex->encoder.size){
		speex->encoder.size = SPEEX_BUFFER_MAX_SIZE;
	}
    
	speex_bits_init(&speex->encoder.bits);
	speex_bits_init(&speex->decoder.bits);
	speex_bits_reset(&speex->encoder.bits);
	speex_bits_reset(&speex->decoder.bits);
    
    self->codec = speex;
    
	return 0;
}

int media_codec_speex_close(media_codec_t* self)
{
    if(!self->codec)
        return -1;
    
	media_codec_speex_t* speex = (media_codec_speex_t*)self->codec;
    
	if(speex){
		if(speex->decoder.state){
			speex_decoder_destroy(speex->decoder.state);
			speex->decoder.state = tbi_null;
		}
		speex_bits_destroy(&speex->decoder.bits);
		if(speex->decoder.buffer){
			free(speex->decoder.buffer);
            speex->decoder.buffer = 0;
			speex->decoder.size = 0;
		}
        
		if(speex->encoder.state){
			speex_encoder_destroy(speex->encoder.state);
			speex->encoder.state = tbi_null;
		}
		speex_bits_destroy(&speex->encoder.bits);
		speex->encoder.size = 0;
        
        free(speex);
        self->codec = 0;
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
    
	return 0;
}

tbi_size_t media_codec_speex_encode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
{
    if(!self->codec)
        return -1;
    
	media_codec_speex_t* speex = (media_codec_speex_t*)self->codec;
	tbi_size_t outsize = 0;
	
	if(!self || !in_data || !in_size || !out_data){
		TBI_DEBUG_ERROR("Invalid parameter");
		return 0;
	}
	
	speex_bits_reset(&speex->encoder.bits);
	speex_encode_int(speex->encoder.state, (spx_int16_t*)in_data, &speex->encoder.bits);
    
	if(*out_max_size <speex->encoder.size){
		if((*out_data = realloc((void*)(*out_data), speex->encoder.size))){
			*out_max_size = speex->encoder.size;
		}
		else{
			*out_max_size = 0;
			return 0;
		}
	}
	
	outsize = speex_bits_write(&speex->encoder.bits, *out_data, speex->encoder.size);
    
    return outsize;
}

tbi_size_t media_codec_speex_decode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
{
    if(!self->codec)
        return -1;
    
	int ret;
	tbi_size_t out_size = 0;
	media_codec_speex_t* speex = (media_codec_speex_t*)self->codec;
    
	if(!self || !in_data || !in_size || !out_data){
		TBI_DEBUG_ERROR("Invalid parameter");
		return 0;
	}
    
	/* initializes the bit-stream */
	speex_bits_read_from(&speex->decoder.bits, (char*)in_data, in_size);
    
	do{
		/* performs decode() */
		if((ret = speex_decode_int(speex->decoder.state, &speex->decoder.bits, speex->decoder.buffer))){
			TBI_DEBUG_ERROR("Failed to decode the buffer. retcode=%d", ret);
			break;
		}
        
		if(*out_max_size <(out_size + speex->decoder.size)){
			if((*out_data = realloc(*out_data, (out_size + speex->decoder.size)))){
				*out_max_size = (out_size + speex->decoder.size);
			}
			else{
				*out_max_size = 0;
				return 0;
			}
		}
        
		/* copy output buffer */
		memcpy(&((uint8_t*)*out_data)[out_size], speex->decoder.buffer, speex->decoder.size);
		out_size += speex->decoder.size;
	}
	while(speex_bits_remaining(&speex->decoder.bits) >= 5);
	
    
	return out_size;
}

//
//	Speex Codec Object definition
//
//#define SPEEX_OBJECT_DEFINITION(mode,name,description,format,rate)  \
//    static media_codec_t media_codec_speex_##mode##_s =       \
//    {                   \
//        media_audio,    \
//        name,           \
//        description,    \
//        format,         \
//        rate,           \
//        media_codec_speex_open,     \
//        media_codec_speex_close,    \
//        media_codec_speex_encode,   \
//        media_codec_speex_decode,   \
//    };                              \
//    media_codec_t *pmedia_codec_speex_##mode##_s = &media_codec_speex_##mode##_s;


//SPEEX_OBJECT_DEFINITION(wb, "SPEEX", "Speex-WB Codec", MEDIA_CODEC_FORMAT_SPEEX_WB, 16000);

static media_codec_t media_codec_speex_wb_s =
{
    media_audio,
    "SPEEX",
    "Speex-WB Codec",
    MEDIA_CODEC_FORMAT_SPEEX_WB,
    16000,
    {0,20},
    {352,288,12},
    {0,352,288}, // rotate
    0,
    1,
    1, // bits per sample
    media_codec_speex_open,
    media_codec_speex_close,
    media_codec_speex_encode,
    media_codec_speex_decode,
    tbi_null,
};
media_codec_t *pmedia_codec_speex_wb_s = &media_codec_speex_wb_s;


#endif /* HAVE_LIB_SPEEX */
