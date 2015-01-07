

/**@file media_codec_gsm.h
 * @brief GSM Full Rate Codec (Based on libgsm)
 *
 */

#ifndef MEDIA_CODEC_GSM_H
#define MEDIA_CODEC_GSM_H




#include "media_codec.h"
#include "gsm/gsm.h"

/** GSM codec */
typedef struct media_codec_gsm_s
{
	gsm encoder;
	gsm decoder;
}
media_codec_gsm_t;

extern media_codec_t *pmedia_codec_gsm;


#endif /* HAVE_LIBGSM */

