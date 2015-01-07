

/**@file tbi_codec_g711.c
 * @brief G.711u and G.711a (a.k.a PCMU and PCMA) codec plugins.
 *
 
 *
 
 */
#include "media_codec_g711.h"



/* ============ G.711u Plugin interface ================= */

static tbi_size_t media_codec_g711u_encode(media_codec_t* self,const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
{
	register TBI_size_t i;
	register uint8_t* pout_data;
	register int16_t* pin_data;
	
	if(!in_data || !in_size || !out_data){
		TBI_DEBUG_ERROR("Invalid parameter");
		return 0;
	}
	
	if(*out_max_size <in_size>>1){
		if(!(*out_data = TBI_realloc(*out_data, in_size>>1))){
			TBI_DEBUG_ERROR("Failed to allocate new buffer");
			*out_max_size = 0;
			return 0;
		}
		*out_max_size = in_size>>1;
	}
	
	pout_data = *out_data;
	pin_data = (int16_t*)in_data;
	for(i = 0; i<(in_size>>1); i++){
		pout_data[i] = linear2ulaw(pin_data[i]);
	}
	
	return (in_size>>1);
}

static tbi_size_t media_codec_g711u_decode(media_codec_t* self,const void* in_data, tbi_size_t in_size, void** out_data, TBI_size_t* out_max_size)
{
	TBI_size_t i;
    
	if(!in_data || !in_size || !out_data){
		TBI_DEBUG_ERROR("Invalid parameter");
		return 0;
	}
    
	/* allocate new buffer */
	if(*out_max_size<(in_size<<1)){
		if(!(*out_data = TBI_calloc(in_size, sizeof(int16_t)))){
			TBI_DEBUG_ERROR("Failed to allocate new buffer");
			*out_max_size = 0;
			return 0;
		}
		*out_max_size = in_size<<1;
	}
    
	for(i = 0; i<in_size; i++){
		((short*)*out_data)[i] = ulaw2linear(((uint8_t*)in_data)[i]);
	}
	
	return (in_size<<1);
}


static int media_codec_pcmu_open(media_codec_t* self){
    if(self->codec)
        return 0;
	media_codec_g711u_t* pcmu = (media_codec_g711u_t*)calloc(1, sizeof(media_codec_g711u_t));
    self->codec = pcmu;
    
    return 0;
}

static int media_codec_pcmu_close(media_codec_t* self)
{
    if(self->codec)
    {
        free(self->codec);
        self->codec = 0;
    }
    return 0;
}

static int media_codec_pcma_open(media_codec_t* self){
    if(self->codec)
        return 0;
	media_codec_g711a_t* pcma = (media_codec_g711a_t*)calloc(1, sizeof(media_codec_g711a_t));
    self->codec = pcma;
    
    return 0;
}

static int media_codec_pcma_close(media_codec_t* self)
{
    if(self->codec)
    {
        free(self->codec);
        self->codec = 0;
    }
    return 0;
}

static tbi_size_t media_codec_g711a_encode(media_codec_t* self,const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
{
	register TBI_size_t i;
	register uint8_t* pout_data;
	register int16_t* pin_data;
	
	if(!in_data || !in_size || !out_data){
		TBI_DEBUG_ERROR("Invalid parameter");
		return 0;
	}
	
	if(*out_max_size <in_size>>1){
		if(!(*out_data = TBI_realloc(*out_data, in_size>>1))){
			TBI_DEBUG_ERROR("Failed to allocate new buffer");
			*out_max_size = 0;
			return 0;
		}
		*out_max_size = in_size>>1;
	}
	
	pout_data = *out_data;
	pin_data = (int16_t*)in_data;
	for(i = 0; i<(in_size>>1); i++){
		pout_data[i] = linear2alaw(pin_data[i]);
	}
    
	return (in_size>>1);
}


static tbi_size_t media_codec_g711a_decode(media_codec_t* self,const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
{
	TBI_size_t i;
	
	if(!in_data || !in_size || !out_data){
		TBI_DEBUG_ERROR("Invalid parameter");
		return 0;
	}
#if 0
	if(!file && count<=1000){
		file = fopen("./g711a.pcm", "wb");
	}
#endif
	/* allocate new buffer */
	if(*out_max_size<(in_size<<1)){
		if(!(*out_data = TBI_realloc(*out_data, in_size<<1))){
			TBI_DEBUG_ERROR("Failed to allocate new buffer");
			*out_max_size = 0;
			return 0;
		}
		*out_max_size = in_size<<1;
	}
	
	for(i = 0; i<in_size; i++){
		((short*)*out_data)[i] = alaw2linear(((uint8_t*)in_data)[i]);
	}
#if 0
	if(++count<=1000){
		fwrite(*out_data, sizeof(short), in_size, file);
	}
	else if(file){
		fclose(file);
		file = TBI_null;
	}
#endif
	return (in_size<<1);
}

static media_codec_t media_codec_pcma_s =
{
	media_audio,
	"pcma",
	"pcma Codec",
	MEDIA_CODEC_FORMAT_PCMA,
	8000, // rate
	{0,20},
    {352,288,12},
        {0}, // rotate
    0,
    -1,
    2, // bits per sample
	media_codec_pcma_open,
	media_codec_pcma_close,
	media_codec_g711a_encode,
	media_codec_g711a_decode,
};

media_codec_t *pmedia_codec_pcma = &media_codec_pcma_s;


static media_codec_t media_codec_pcmu_s =
{
	media_audio,
	"pcmu",
	"pcmu Codec",
	MEDIA_CODEC_FORMAT_PCMU,
	8000, // rate
    {0,20},
    {352,288,12},
    {0,352,288}, // rotate
    0,
    -1,
    2, // bits per sample
	media_codec_pcmu_open,
	media_codec_pcmu_close,
	media_codec_g711u_encode,
	media_codec_g711u_decode,
};

media_codec_t *pmedia_codec_pcmu = &media_codec_pcmu_s;
