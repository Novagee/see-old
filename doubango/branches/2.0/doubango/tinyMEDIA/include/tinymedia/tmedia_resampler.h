

/**@file tmedia_resampler.h
 * @brief Audio Resampler Plugin
 *

 */
#ifndef TINYMEDIA_RESAMPLER_H
#define TINYMEDIA_RESAMPLER_H

#include "tinymedia_config.h"

#include "tsk_object.h"

#ifndef TMEDIA_RESAMPLER_QUALITY
#	define TMEDIA_RESAMPLER_QUALITY 3
#endif

TMEDIA_BEGIN_DECLS

/** cast any pointer to @ref tmedia_resampler_t* object */
#define TMEDIA_RESAMPLER(self)		((tmedia_resampler_t*)(self))

/** Base object for all resamplers */
typedef struct tmedia_resampler_s
{
	TSK_DECLARE_OBJECT;

	tsk_bool_t opened;

	const struct tmedia_resampler_plugin_def_s* plugin;
}
tmedia_resampler_t;

#define TMEDIA_DECLARE_RESAMPLER tmedia_resampler_t __resampler__

/** Virtual table used to define a consumer plugin */
typedef struct tmedia_resampler_plugin_def_s
{
	//! object definition used to create an instance of the resamplerr
	const tsk_object_def_t* objdef;
	
	//! full description (usefull for debugging)
	const char* desc;

	// ! quality is from 0-10
	int (* open) (tmedia_resampler_t*,  uint32_t in_freq, uint32_t out_freq, tsk_size_t frame_duration, int8_t channels, uint32_t quality);
	tsk_size_t (* process) (tmedia_resampler_t*, const uint16_t* in_data, tsk_size_t in_size, uint16_t* out_data, tsk_size_t out_size);
	int (* close) (tmedia_resampler_t* );
}
tmedia_resampler_plugin_def_t;

TINYMEDIA_API int tmedia_resampler_init(tmedia_resampler_t* self);
TINYMEDIA_API int tmedia_resampler_open(tmedia_resampler_t* self, uint32_t in_freq, uint32_t out_freq, uint32_t frame_duration, uint32_t channels, uint32_t quality);
TINYMEDIA_API tsk_size_t tmedia_resampler_process(tmedia_resampler_t* self, const uint16_t* in_data, tsk_size_t in_size, uint16_t* out_data, tsk_size_t out_size);
TINYMEDIA_API int tmedia_resampler_close(tmedia_resampler_t* self);
TINYMEDIA_API int tmedia_resampler_deinit(tmedia_resampler_t* self);

TINYMEDIA_API int tmedia_resampler_plugin_register(const tmedia_resampler_plugin_def_t* plugin);
TINYMEDIA_API int tmedia_resampler_plugin_unregister();
TINYMEDIA_API tmedia_resampler_t* tmedia_resampler_create();

TMEDIA_END_DECLS


#endif /* TINYMEDIA_RESAMPLER_H */ 
