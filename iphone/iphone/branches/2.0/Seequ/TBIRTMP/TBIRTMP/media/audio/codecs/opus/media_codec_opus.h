

/**@file media_codec_gsm.h
 * @brief GSM Full Rate Codec (Based on libgsm)
 *
 */

#ifndef MEDIA_CODEC_OPUS_H
#define MEDIA_CODEC_OPUS_H





#include "media_codec.h"
#include "opus/opus.h"
//#include "opus/opus_custom.h"

/** GSM codec */
typedef struct media_codec_opus_s
{
    int frame_size;
    OpusDecoder *decoder;
    OpusEncoder *encoder;
}
media_codec_opus_t;

//typedef struct media_custom_codec_opus_s
//{
//    int frame_size;
//    OpusCustomDecoder *decoder;
//    OpusCustomEncoder *encoder;
//    OpusCustomMode *mode;
//}
//media_custom_codec_opus_t;

extern media_codec_t *pmedia_custom_codec_opus;
extern media_codec_t *pmedia_codec_opus;
extern media_codec_t *pmedia_codec_opus12;
extern media_codec_t *pmedia_codec_opus32;

extern media_codec_t *pmedia_codec_opus8_8;
extern media_codec_t *pmedia_codec_opus8_16;
extern media_codec_t *pmedia_codec_opus8_32;
extern media_codec_t *pmedia_codec_opus16_16;
extern media_codec_t *pmedia_codec_opus16_32;

#endif /* HAVE_LIBGSM */

