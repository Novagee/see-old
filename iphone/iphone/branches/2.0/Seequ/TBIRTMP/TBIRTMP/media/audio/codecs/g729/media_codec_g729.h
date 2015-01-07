

/**@file tdav_codec_g729.h
 * @brief G729a codec.
 * Source from: http://www.itu.int/rec/T-REC-G.729-199611-S!AnnA/en
 *

 *

 */
#ifndef MEDIA_CODEC_G729_H
#define MEDIA_CODEC_G729_H

#include "tbi_config.h"

#ifndef HAVE_G729
dadasdas
#include "media_codec.h"

#include "g729/typedef.h"
#include "g729/ld8a.h"


TBI_BEGIN_DECLS

/** G.729abb codec */
typedef struct media_codec_g729ab_s
{
	struct{
		Word16 prm[PRM_SIZE+1];        /* Analysis parameters + frame type      */
		Word16 serial[SERIAL_SIZE];    /* Output bitstream buffer               */

		Word16 frame;                  /* frame counter */

		/* For G.729B */
		Word16 vad_enable;
	} encoder;

	struct{
		Word16  serial[SERIAL_SIZE];          /* Serial stream               */
		Word16  synth_buf[L_FRAME+M], *synth; /* Synthesis                   */
		Word16  parm[PRM_SIZE+2];             /* Synthesis parameters        */
		Word16  Az_dec[MP1*2];                /* Decoded Az for post-filter  */
		Word16  T2[2];                        /* Pitch lag for 2 subframes   */

		/* For G.729B */
		Word16  Vad;
	} decoder;
}
media_codec_g729ab_t;

extern media_codec_t *pmedia_codec_g729ab;

TBI_END_DECLS

#endif /* TINYDAV_CODEC_G729_H */

#endif
