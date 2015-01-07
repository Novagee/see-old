

/**@file tmedia_common.h
 * @brief Common functions and definitions.
 *

 *

 */
#ifndef TINYMEDIA_COMMON_H
#define TINYMEDIA_COMMON_H

#include "tinymedia_config.h"



TMEDIA_BEGIN_DECLS

/** List of all supported media types */
typedef enum tmedia_type_e
{
	tmedia_none = 0x00,
	tmedia_ghost = (0x01 << 0),

	tmedia_audio = (0x01 << 1),
	tmedia_video = (0x01 << 2),
	tmedia_chat = (0x01 << 3),
	tmedia_file = (0x01 << 4),
	tmedia_t38 = (0x01 << 5),

	tmedia_msrp = (tmedia_chat | tmedia_file),
	tmedia_audiovideo = (tmedia_audio | tmedia_video),

	tmedia_all = (tmedia_audio | tmedia_video | tmedia_msrp | tmedia_t38)
}
tmedia_type_t;

typedef enum tmedia_video_size_type_e
{
	tmedia_vst_none,
	tmedia_vst_sqcif,
	tmedia_vst_qcif,
	tmedia_vst_qvga,
	tmedia_vst_cif,
	tmedia_vst_vga,
	tmedia_vst_4cif,
	tmedia_vst_svga,
	tmedia_vst_xga,
	tmedia_vst_sxga,
	tmedia_vst_16cif,
	tmedia_vst_hd720p,
	tmedia_vst_hd1080p,
	
	tmedia_vst_ios_low,
	tmedia_vst_ios_medium,
	tmedia_vst_ios_high
}
tmedia_video_size_type_t;

typedef struct tmedia_video_size_s
{
	tmedia_video_size_type_t type;

}
tmedia_video_size_t;

// used by tinyWRAP
typedef enum tmedia_srtp_mode_e
{
	tmedia_srtp_mode_none,
	tmedia_srtp_mode_optional,
	tmedia_srtp_mode_mandatory
}
tmedia_srtp_mode_t;

// used by tinyWRAP
typedef enum tmedia_chroma_e
{
	tmedia_chroma_none=0,
	tmedia_chroma_rgb24,		// will be stored as bgr24 on x86 (little endians) machines; e.g. WindowsPhone7
	tmedia_chroma_bgr24,		// used by windows consumer (DirectShow) - 
	tmedia_chroma_rgb32,       // used by iOS4 consumer (iPhone and iPod touch)
	tmedia_chroma_rgb565le,	// (used by both android and wince consumers)
	tmedia_chroma_rgb565be,
	tmedia_chroma_nv12, // used by iOS4 producer (iPhone and iPod Touch 3GS and 4)
	tmedia_chroma_nv21, // Yuv420 SP (used by android producer)
	tmedia_chroma_yuv422p,
	tmedia_chroma_uyvy422, // used by iOS4 producer (iPhone and iPod Touch 3G)
	tmedia_chroma_yuv420p, // Default
}
tmedia_chroma_t;

// used by tinyWRAP
// keep order (low->unrestricted)
typedef enum tmedia_bandwidth_level_e
{
	tmedia_bl_low,
	tmedia_bl_medium,
	tmedia_bl_hight,
	tmedia_bl_unrestricted
}
tmedia_bandwidth_level_t;

TINYMEDIA_API int tmedia_parse_rtpmap(const char* rtpmap, char** name, int32_t* rate, int32_t* channels);
TINYMEDIA_API int tmedia_parse_video_fmtp(const char* fmtp, tmedia_bandwidth_level_t bl, unsigned* width, unsigned* height, unsigned* fps);

TINYMEDIA_API int tmedia_get_video_quality(tmedia_bandwidth_level_t bl);
#define tmedia_get_video_qscale tmedia_get_video_quality

TMEDIA_END_DECLS

#endif /* TINYMEDIA_COMMON_H */
