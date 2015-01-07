  

/**@file tdav_speakup_JitterBuffer.h
 * @brief Speakup audio JitterBuffer Plugin
 *

 */
#ifndef TINYDAV_SPEAKUP_JITTER_BUFFER_H
#define TINYDAV_SPEAKUP_JITTER_BUFFER_H
#include "tbi_time.h"
#include "tbi_memory.h"
#include "tbi_debug.h"


//#include "tinydav_config.h"

//#include "tmedia_jitterbuffer.h"

#include "tdav_jitterbuffer.h"

//TDAV_BEGIN_DECLS

/** Speakuo JitterBufferr*/
typedef struct tdav_speakup_jitterBuffer_s
{
	//TMEDIA_DECLARE_JITTER_BUFFER;

	
	uint8_t jcodec;
	uint64_t ref_timestamp;
	uint32_t frame_duration;
	uint32_t rate;
	uint32_t _10ms_size_bytes;
    jitterbuffer *jbuffer;
}
tdav_speakup_jitterbuffer_t;
TBI_size_t tdav_speakup_jitterbuffer_open(tdav_speakup_jitterbuffer_t* self, uint32_t frame_duration, uint32_t rate);
TBI_size_t tdav_speakup_jitterbuffer_put(tdav_speakup_jitterbuffer_t* self, void* data, TBI_size_t data_size, void* proto_hdr);
TBI_size_t tdav_speakup_jitterbuffer_get(tdav_speakup_jitterbuffer_t* self, void* out_data, TBI_size_t out_size, void* proto_hdr);

//const tmedia_jitterbuffer_plugin_def_t *tdav_speakup_jitterbuffer_plugin_def_t;

//TDAV_END_DECLS

#endif /* TINYDAV_SPEAKUP_JITTER_BUFFER_H */
