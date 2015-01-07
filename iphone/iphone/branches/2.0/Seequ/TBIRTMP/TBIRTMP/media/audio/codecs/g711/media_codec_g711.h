

/**@file tbi_codec_g711.h
 * @brief G.711u and G.711a (a.k.a PCMU and PCMA) codec plugins.
 *

 *

 */

#include "g711.h" /* algorithms */
#include "media_codec.h"
#include "TBI_memory.h"
#include "TBI_debug.h"

#ifndef TINYTBI_CODEC_G711U_H
#define TINYTBI_CODEC_G711U_H


typedef struct media_codec_g711u_s
{
}
media_codec_g711u_t;

/** G.711a codec */
typedef struct media_codec_g711a_s
{
	
}
media_codec_g711a_t;

extern media_codec_t *pmedia_codec_pcmu;
extern media_codec_t *pmedia_codec_pcma;

#endif /* TINYTBI_CODEC_G711_H */
