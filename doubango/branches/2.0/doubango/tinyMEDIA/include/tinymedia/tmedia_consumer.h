

/**@file tmedia_consumer.h
 * @brief Base consumer object.
 *

 *

 */
#ifndef TINYMEDIA_CONSUMER_H
#define TINYMEDIA_CONSUMER_H

#include "tinymedia_config.h"

#include "tinymedia/tmedia_codec.h"
#include "tinymedia/tmedia_params.h"
#include "tmedia_common.h"

TMEDIA_BEGIN_DECLS

#define TMEDIA_CONSUMER_BITS_PER_SAMPLE_DEFAULT		16
#define TMEDIA_CONSUMER_CHANNELS_DEFAULT			2
#define TMEDIA_CONSUMER_RATE_DEFAULT				8000
#define TMEDIA_CONSUMER_PTIME_DEFAULT				20

/**Max number of plugins (consumer types) we can create */
#if !defined(TMED_CONSUMER_MAX_PLUGINS)
#	define TMED_CONSUMER_MAX_PLUGINS			0x0F
#endif

/** cast any pointer to @ref tmedia_consumer_t* object */
#define TMEDIA_CONSUMER(self)		((tmedia_consumer_t*)(self))

/**  Default Video chroma */
#if !defined(TMEDIA_CONSUMER_CHROMA_DEFAULT)
#	define TMEDIA_CONSUMER_CHROMA_DEFAULT tmedia_chroma_yuv420p
#endif

/** Base object for all Consumers */
typedef struct tmedia_consumer_s
{
	TSK_DECLARE_OBJECT;
	
	tmedia_type_t type;
	const char* desc;

	struct{
		int fps;
		struct {
			tmedia_chroma_t chroma;
			tsk_size_t width;
			tsk_size_t height;
		} in;
		struct {
			tmedia_chroma_t chroma;
			tsk_size_t width;
			tsk_size_t height;
			tsk_bool_t auto_resize; // auto_resize to "in.width, in.height"
		} display;
	} video;

	struct{
		uint8_t bits_per_sample;
		uint8_t ptime;
		uint8_t gain;
		struct{
			uint8_t channels;
			uint32_t rate;
		} in;
		struct{
			uint8_t channels;
			uint32_t rate;
		} out;
	} audio;

	uint64_t session_id;
	const struct tmedia_consumer_plugin_def_s* plugin;
}
tmedia_consumer_t;

/** Virtual table used to define a consumer plugin */
typedef struct tmedia_consumer_plugin_def_s
{
	//! object definition used to create an instance of the consumer
	const tsk_object_def_t* objdef;
	
	//! the type of the consumer
	tmedia_type_t type;
	//! full description (usefull for debugging)
	const char* desc;

	int (*set) (tmedia_consumer_t* , const tmedia_param_t*);
	int (* prepare) (tmedia_consumer_t*, const tmedia_codec_t* );
	int (* start) (tmedia_consumer_t* );
	int (* consume) (tmedia_consumer_t*, const void* buffer, tsk_size_t size, const tsk_object_t* proto_hdr);
	int (* pause) (tmedia_consumer_t* );
	int (* stop) (tmedia_consumer_t* );
}
tmedia_consumer_plugin_def_t;

#define TMEDIA_DECLARE_CONSUMER tmedia_consumer_t __consumer__

TINYMEDIA_API tmedia_consumer_t* tmedia_consumer_create(tmedia_type_t type, uint64_t session_id);
TINYMEDIA_API int tmedia_consumer_init(tmedia_consumer_t* self);
TINYMEDIA_API int tmedia_consumer_set(tmedia_consumer_t *self, const tmedia_param_t* param);
TINYMEDIA_API int tmedia_consumer_prepare(tmedia_consumer_t *self, const tmedia_codec_t* codec);
TINYMEDIA_API int tmedia_consumer_start(tmedia_consumer_t *self);
TINYMEDIA_API int tmedia_consumer_consume(tmedia_consumer_t* self, const void* buffer, tsk_size_t size, const tsk_object_t* proto_hdr);
TINYMEDIA_API int tmedia_consumer_pause(tmedia_consumer_t *self);
TINYMEDIA_API int tmedia_consumer_stop(tmedia_consumer_t *self);
TINYMEDIA_API int tmedia_consumer_deinit(tmedia_consumer_t* self);

TINYMEDIA_API int tmedia_consumer_plugin_register(const tmedia_consumer_plugin_def_t* plugin);
TINYMEDIA_API int tmedia_consumer_plugin_unregister(const tmedia_consumer_plugin_def_t* plugin);
TINYMEDIA_API int tmedia_consumer_plugin_unregister_by_type(tmedia_type_t type);

TMEDIA_END_DECLS

#endif /* TINYMEDIA_CONSUMER_H */
