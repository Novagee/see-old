

/**@file tmedia_producer.h
 * @brief Base producer object.
 *

 *

 */
#ifndef TINYMEDIA_PRODUCER_H
#define TINYMEDIA_PRODUCER_H

#include "tinymedia_config.h"

#include "tinymedia/tmedia_codec.h"
#include "tinymedia/tmedia_params.h"
#include "tmedia_common.h"

TMEDIA_BEGIN_DECLS

#define TMEDIA_PRODUCER_BITS_PER_SAMPLE_DEFAULT		16
#define TMEDIA_PRODUCER_CHANNELS_DEFAULT			2
#define TMEDIA_PRODUCER_RATE_DEFAULT				8000

/**Max number of plugins (producer types) we can create */
#define TMED_PRODUCER_MAX_PLUGINS			0x0F

/** cast any pointer to @ref tmedia_producer_t* object */
#define TMEDIA_PRODUCER(self)		((tmedia_producer_t*)(self))

typedef int (*tmedia_producer_enc_cb_f)(const void* callback_data, const void* buffer, tsk_size_t size);
typedef int (*tmedia_producer_raw_cb_f)(const void* callback_data, const void* buffer, tsk_size_t size, uint32_t duration, tsk_bool_t marker);

/**  Default Video chroma */
#define TMEDIA_PRODUCER_CHROMA_DEFAULT tmedia_chroma_yuv420p

/** Base object for all Producers */
typedef struct tmedia_producer_s
{
	TSK_DECLARE_OBJECT;
	
	tmedia_type_t type;
	const char* desc;

	struct{
		tmedia_chroma_t chroma;
		int fps;
		int rotation;
		tsk_size_t width;
		tsk_size_t height;
	} video;

	struct{
		uint8_t bits_per_sample;
		uint8_t channels;
		uint32_t rate;
		uint8_t ptime;
		uint8_t gain;
	} audio;

	const struct tmedia_producer_plugin_def_s* plugin;

	uint64_t session_id;

	struct{
		tmedia_producer_enc_cb_f callback;
		const void* callback_data;
	} enc_cb;

	struct{
		tmedia_producer_raw_cb_f callback;
		const void* callback_data;
	} raw_cb;
}
tmedia_producer_t;

/** Virtual table used to define a producer plugin */
typedef struct tmedia_producer_plugin_def_s
{
	//! object definition used to create an instance of the producer
	const tsk_object_def_t* objdef;
	
	//! the type of the producer
	tmedia_type_t type;
	//! full description (usefull for debugging)
	const char* desc;

	int (*set) (tmedia_producer_t* , const tmedia_param_t*);
	int (* prepare) (tmedia_producer_t* , const tmedia_codec_t*);
	int (* start) (tmedia_producer_t* );
	int (* pause) (tmedia_producer_t* );
	int (* stop) (tmedia_producer_t* );
}
tmedia_producer_plugin_def_t;

#define TMEDIA_DECLARE_PRODUCER tmedia_producer_t __producer__

TINYMEDIA_API tmedia_producer_t* tmedia_producer_create(tmedia_type_t type, uint64_t session_id);
TINYMEDIA_API int tmedia_producer_init(tmedia_producer_t* self);
TINYMEDIA_API int tmedia_producer_set_enc_callback(tmedia_producer_t *self, tmedia_producer_enc_cb_f callback, const void* callback_data);
TINYMEDIA_API int tmedia_producer_set_raw_callback(tmedia_producer_t *self, tmedia_producer_raw_cb_f callback, const void* callback_data);
TINYMEDIA_API int tmedia_producer_set(tmedia_producer_t* self, const tmedia_param_t* param);
TINYMEDIA_API int tmedia_producer_prepare(tmedia_producer_t *self, const tmedia_codec_t* codec);
TINYMEDIA_API int tmedia_producer_start(tmedia_producer_t *self);
TINYMEDIA_API int tmedia_producer_pause(tmedia_producer_t *self);
TINYMEDIA_API int tmedia_producer_stop(tmedia_producer_t *self);
TINYMEDIA_API int tmedia_producer_deinit(tmedia_producer_t* self);

TINYMEDIA_API int tmedia_producer_plugin_register(const tmedia_producer_plugin_def_t* plugin);
TINYMEDIA_API int tmedia_producer_plugin_unregister(const tmedia_producer_plugin_def_t* plugin);
TINYMEDIA_API int tmedia_producer_plugin_unregister_by_type(tmedia_type_t type);

TMEDIA_END_DECLS

#endif /* TINYMEDIA_PRODUCER_H */
