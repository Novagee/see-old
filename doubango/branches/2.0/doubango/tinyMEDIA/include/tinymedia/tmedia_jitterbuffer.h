  

/**@file tmedia_jitterbuffer.h
 * @brief Audio/Video JitterBuffer Plugin
 *

 */
#ifndef TINYMEDIA_JITTER_BUFFER_H
#define TINYMEDIA_JITTER_BUFFER_H

#include "tinymedia_config.h"

#include "tinymedia/tmedia_params.h"
#include "tmedia_common.h"


#include "tsk_object.h"

TMEDIA_BEGIN_DECLS

/** cast any pointer to @ref tmedia_jitterbuffer_t* object */
#define TMEDIA_JITTER_BUFFER(self)		((tmedia_jitterbuffer_t*)(self))

/**Max number of plugins (jb types) we can create */
#if !defined(TMED_JITTER_BUFFER_MAX_PLUGINS)
#	define TMED_JITTER_BUFFER_MAX_PLUGINS			0x0F
#endif

typedef void (*func)(void*) ;
//typedef void (*func)(void *callBackData);
/** Base object for all JitterBuffers */
typedef struct tmedia_jitterbuffer_s
{
	TSK_DECLARE_OBJECT;

	tsk_bool_t opened;
    func callBack_function;
 	const struct tmedia_jitterbuffer_plugin_def_s* plugin;
}
tmedia_jitterbuffer_t;

#define TMEDIA_DECLARE_JITTER_BUFFER tmedia_jitterbuffer_t __jitterbuffer__

/** Virtual table used to define a consumer plugin */
typedef struct tmedia_jitterbuffer_plugin_def_s
{
	//! object definition used to create an instance of the jitterbufferr
	const tsk_object_def_t* objdef;
	
	//! the type of the jitter buffer
	tmedia_type_t type;

	//! full description (usefull for debugging)
	const char* desc;

	int (*set) (tmedia_jitterbuffer_t* , const tmedia_param_t*);
	int (* open) (tmedia_jitterbuffer_t*, uint32_t frame_duration, uint32_t rate);
	int (* tick) (tmedia_jitterbuffer_t*);
	int (* put) (tmedia_jitterbuffer_t*, void* data, tsk_size_t data_size, const tsk_object_t* proto_hdr);
	tsk_size_t (* get) (tmedia_jitterbuffer_t*, void* out_data, tsk_size_t out_size);
	int (* reset) (tmedia_jitterbuffer_t* );
	int (* close) (tmedia_jitterbuffer_t* );
}
tmedia_jitterbuffer_plugin_def_t;

TINYMEDIA_API int tmedia_jitterbuffer_init(tmedia_jitterbuffer_t* self);
TINYMEDIA_API int tmedia_jitterbuffer_set(tmedia_jitterbuffer_t *self, const tmedia_param_t* param);
TINYMEDIA_API int tmedia_jitterbuffer_open(tmedia_jitterbuffer_t* self, uint32_t frame_duration, uint32_t rate);
TINYMEDIA_API int tmedia_jitterbuffer_tick(tmedia_jitterbuffer_t* self);
TINYMEDIA_API int tmedia_jitterbuffer_put(tmedia_jitterbuffer_t* self, void* data, tsk_size_t data_size, const tsk_object_t* proto_hdr);
TINYMEDIA_API tsk_size_t tmedia_jitterbuffer_get(tmedia_jitterbuffer_t* self, void* out_data, tsk_size_t out_size);
TINYMEDIA_API int tmedia_jitterbuffer_reset(tmedia_jitterbuffer_t* self);
TINYMEDIA_API int tmedia_jitterbuffer_close(tmedia_jitterbuffer_t* self);
TINYMEDIA_API int tmedia_jitterbuffer_deinit(tmedia_jitterbuffer_t* self);

TINYMEDIA_API int tmedia_jitterbuffer_plugin_register(const tmedia_jitterbuffer_plugin_def_t* plugin);
TINYMEDIA_API int tmedia_jitterbuffer_plugin_unregister();
TINYMEDIA_API int tmedia_jitter_buffer_plugin_unregister_by_type(tmedia_type_t type);
TINYMEDIA_API tmedia_jitterbuffer_t* tmedia_jitterbuffer_create(tmedia_type_t type);

TMEDIA_END_DECLS


#endif /* TINYMEDIA_JITTER_BUFFER_H */ 
