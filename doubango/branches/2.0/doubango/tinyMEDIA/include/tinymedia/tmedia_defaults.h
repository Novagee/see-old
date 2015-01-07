
#ifndef TINYMEDIA_DEFAULTS_H
#define TINYMEDIA_DEFAULTS_H

#include "tinymedia_config.h"

#include "tmedia_common.h"

TMEDIA_BEGIN_DECLS

//
// Codecs: Bandwidth
//
TINYMEDIA_API int tmedia_defaults_set_bl(tmedia_bandwidth_level_t bl);
TINYMEDIA_API tmedia_bandwidth_level_t tmedia_defaults_get_bl();

//
// Denoiser: Echo suppression, AEC, Noise redution, AGC, ...
//
TINYMEDIA_API int tmedia_defaults_set_echo_tail(uint32_t echo_tail);
TINYMEDIA_API int tmedia_defaults_set_echo_skew(uint32_t echo_skew);
TINYMEDIA_API uint32_t tmedia_defaults_get_echo_tail();
TINYMEDIA_API uint32_t tmedia_defaults_get_echo_skew();
TINYMEDIA_API int tmedia_defaults_set_agc_level(float agc_level);
TINYMEDIA_API float tmedia_defaults_get_agc_level();
TINYMEDIA_API int tmedia_defaults_set_noise_supp_level(int32_t noise_supp_level);
TINYMEDIA_API int32_t tmedia_defaults_get_noise_supp_level();
TINYMEDIA_API int tmedia_defaults_set_screen_size(int32_t sx, int32_t sy);
TINYMEDIA_API int32_t tmedia_defaults_get_screen_x();
TINYMEDIA_API int32_t tmedia_defaults_get_screen_y();
TINYMEDIA_API int tmedia_defaults_set_audio_gain(int32_t audio_producer_gain, int32_t audio_consumer_gain);
TINYMEDIA_API int32_t tmedia_defaults_get_audio_producer_gain();
TINYMEDIA_API int32_t tmedia_defaults_get_audio_consumer_gain();
TINYMEDIA_API int tmedia_defaults_set_max_queue_packet_count(int max_queue_packet_count);
TINYMEDIA_API int tmedia_defaults_get_max_queue_packet_count();
TINYMEDIA_API tmedia_srtp_mode_t tmedia_defaults_get_srtp_mode();

TMEDIA_END_DECLS

#endif /* TINYMEDIA_DEFAULTS_H */
