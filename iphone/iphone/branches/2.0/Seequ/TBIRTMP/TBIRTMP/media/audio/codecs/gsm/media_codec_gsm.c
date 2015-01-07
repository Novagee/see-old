

/**@file tdav_codec_gsm.c
 * @brief GSM Full Rate Codec (Based on libgsm)
 *

 *

 */
#include "media_codec_gsm.h"


#include "tbi_memory.h"
#include "tbi_debug.h"

#define MEDIA_GSM_FRAME_SIZE			33

/* ============ GSM Plugin interface ================= */

static int media_codec_gsm_open(media_codec_t* self)
{
    if(self->codec)
        return 0;
    
    media_codec_gsm_t* gsm = calloc(1, sizeof(media_codec_gsm_t));
 	self->codec = gsm;
	if(!gsm->encoder && !(gsm->encoder = gsm_create())){
		TBI_DEBUG_ERROR("Failed to create GSM encoder");
		return -2;
	}
	if(!gsm->decoder && !(gsm->decoder = gsm_create())){
		TBI_DEBUG_ERROR("Failed to create GSM decoder");
		return -3;
	}

	return 0;
}

static int media_codec_gsm_close(media_codec_t* self)
{
    if(!self || !self->codec)
        return 0;
    
	media_codec_gsm_t* gsm = (media_codec_gsm_t*)self->codec;

	if(gsm->encoder){
		gsm_destroy(gsm->encoder);
		gsm->encoder = tbi_null;
	}
	if(gsm->decoder){
		gsm_destroy(gsm->decoder);
		gsm->decoder = tbi_null;
	}
    free(gsm);
    self->codec = 0;
    
	return 0;
}

static tbi_size_t media_codec_gsm_encode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
{	
	tbi_size_t out_size;

	if(!self || !in_data || !in_size || !out_data){
		TBI_DEBUG_ERROR("Invalid parameter");
		return 0;
	}
	media_codec_gsm_t* gsm = (media_codec_gsm_t*)self->codec;
    if(!self->codec)
        return 0;
    
    int pcm_frame_size = ((20 * 8000)/1000) * sizeof(short);
    int gsm_frame_cnt = in_size / pcm_frame_size;
	out_size = gsm_frame_cnt * MEDIA_GSM_FRAME_SIZE;

	/* allocate new buffer if needed */
	if(*out_max_size < out_size){
		if(!(*out_data = TBI_realloc(*out_data, out_size))){
			TBI_DEBUG_ERROR("Failed to allocate new buffer");
			*out_max_size = 0;
			return 0;
		}
		*out_max_size = out_size;
	}
    
    for (int i = 0; i < gsm_frame_cnt; i++)
    {
        gsm_encode(gsm->encoder, (gsm_signal*)(in_data + i * pcm_frame_size), (gsm_byte*)((*out_data) + i * MEDIA_GSM_FRAME_SIZE));
    }
	return out_size;
}

static tbi_size_t media_codec_gsm_decode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
{
	tbi_size_t out_size;
	int ret;
	media_codec_gsm_t* gsm = (media_codec_gsm_t*)self->codec;
	if(!self || !in_data || !in_size || !out_data || (in_size % MEDIA_GSM_FRAME_SIZE)){
		TBI_DEBUG_ERROR("Invalid parameter");
		return 0;
	}
    if(!self->codec)
        return 0;

    int pcm_frame_size = ((20 * 8000)/1000) * sizeof(short);
    int gsm_frame_cnt = in_size / MEDIA_GSM_FRAME_SIZE;
	out_size = gsm_frame_cnt * pcm_frame_size;

	/* allocate new buffer if needed */
	if(*out_max_size <out_size){
		if(!(*out_data = TBI_realloc(*out_data, out_size))){
			TBI_DEBUG_ERROR("Failed to allocate new buffer");
			*out_max_size = 0;
			return 0;
		}
		*out_max_size = out_size;
	}

    for (int i = 0; i < gsm_frame_cnt; i++)
    {
        ret = gsm_decode(gsm->decoder, (gsm_byte*)(in_data + i * MEDIA_GSM_FRAME_SIZE), (gsm_signal*)((*out_data) + i * pcm_frame_size));
    }

	return out_size;
}

static media_codec_t media_codec_gsm_s =
{
	media_audio,
	"gsm",
	"gsm Codec",
	MEDIA_CODEC_FORMAT_GSM,
	8000, // rate
    {0,20},
    {0,0,0},
    {0,0,0}, // rotate
    0,
    -1,
    1, // bits per sample
	media_codec_gsm_open,
	media_codec_gsm_close,
	media_codec_gsm_encode,
	media_codec_gsm_decode,
};

media_codec_t *pmedia_codec_gsm = &media_codec_gsm_s;




