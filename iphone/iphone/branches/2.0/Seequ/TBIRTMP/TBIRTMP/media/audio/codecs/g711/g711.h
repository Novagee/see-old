

/**@file tdav_codec_g711.h
 * @brief G.711u and G.711a (a.k.a PCMU and PCMA) codec plugins.
 *

 *

 */
#ifndef TINYTBI_CODEC_G711_IMPLEMENTATION_H
#define TINYTBI_CODEC_G711_IMPLEMENTATION_H

unsigned char linear2alaw(short	pcm_val);
short alaw2linear(unsigned char	a_val);
unsigned char linear2ulaw(short	pcm_val);
short ulaw2linear(unsigned char	u_val);


#endif /* TINYTBI_CODEC_G711_IMPLEMENTATION_H */
