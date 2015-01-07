

/**@file media_codec_speex.h
 * @brief Speex codecs
 *

 *

 */
#ifndef TBI_MEDIA_CODEC_SPEEX_H
#define TBI_MEDIA_CODEC_SPEEX_H

#include "tbi_config.h"

#if HAVE_LIB_SPEEX

#include "media_codec.h"
#include "types.h"

#include <speex/speex.h> 

TBI_BEGIN_DECLS


/** Speex codec */
typedef struct media_codec_speex_s
{
	struct{
		void* state;
		SpeexBits bits;
		tbi_size_t size;
	} encoder;

	struct {
		void* state;
		SpeexBits bits;
		spx_int16_t* buffer;
		tbi_size_t size;
	} decoder;
}
media_codec_speex_t;

extern media_codec_t* pmedia_codec_speex_wb_s;

TBI_END_DECLS

#endif /* TINYDAV_CODEC_SPEEX_H */

#endif /* TINYDAV_CODEC_SPEEX_H */
