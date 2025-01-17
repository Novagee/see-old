

/**@file tmedia_session.h
 * @brief Base session object.
 *

 *

 */
#ifndef TINYMEDIA_SESSION_H
#define TINYMEDIA_SESSION_H

#include "tinymedia_config.h"

#include "tinymedia/tmedia_codec.h"
#include "tinymedia/tmedia_qos.h"
#include "tinymedia/tmedia_params.h"


#include "tsk_list.h"

TMEDIA_BEGIN_DECLS

#define TMEDIA_SESSION(self)		((tmedia_session_t*)(self))
#define TMEDIA_SESSION_AUDIO(self)	((tmedia_session_audio_t*)(self))
#define TMEDIA_SESSION_VIDEO(self)	((tmedia_session_video_t*)(self))
#define TMEDIA_SESSION_MSRP(self)	((tmedia_session_msrp_t*)(self))

/**Max number of plugins (session types) we can create */
#define TMED_SESSION_MAX_PLUGINS			0x0F

/** Base objct used for all media sessions */
typedef struct tmedia_session_s
{
	TSK_DECLARE_OBJECT;
	
	//! unique id. If you want to modifiy this field then you must use @ref tmedia_session_get_unique_id()
	uint64_t id;
	//! session type
	tmedia_type_t type;
	//! list of codecs managed by this session
	tmedia_codecs_L_t* codecs;
	//! negociated codec
	tmedia_codecs_L_t* neg_codecs;
	//! whether the ro have been prepared (up to the manager to update the value)
	tsk_bool_t ro_changed;
	//! whether the session have been initialized (up to the manager to update the value)
	tsk_bool_t initialized;
	//! whether the session have been prepared (up to the manager to update the value)
	tsk_bool_t prepared;
	//! QoS
	tmedia_qos_tline_t* qos;
	//! bandwidth level
	tmedia_bandwidth_level_t bl;

	struct{
        
	} M;

	//! plugin used to create the session
	const struct tmedia_session_plugin_def_s* plugin;
    tsk_object_t *manager;
}
tmedia_session_t;

/** Virtual table used to define a session plugin */
typedef struct tmedia_session_plugin_def_s
{
	//! object definition used to create an instance of the session
	const tsk_object_def_t* objdef;

	//! the type of the session
	tmedia_type_t type;
	//! the media name. e.g. "audio", "video", "message", "image" etc.
	const char* media;
	
	int (*set) (tmedia_session_t* , const tmedia_param_t*);
	int (* prepare) (tmedia_session_t* );
	int (* start) (tmedia_session_t* );
	int (* pause) (tmedia_session_t* );
	int (* stop) (tmedia_session_t* );

	struct{ /* Special case */
		int (* send_dtmf) (tmedia_session_t*, uint8_t );
	} audio;


}
tmedia_session_plugin_def_t;

TINYMEDIA_API uint64_t tmedia_session_get_unique_id();
TINYMEDIA_API int tmedia_session_init(tmedia_session_t* self, tmedia_type_t type);
TINYMEDIA_API int tmedia_session_cmp(const tsk_object_t* sess1, const tsk_object_t* sess2);
TINYMEDIA_API int tmedia_session_plugin_register(const tmedia_session_plugin_def_t* plugin);
TINYMEDIA_API const tmedia_session_plugin_def_t* tmedia_session_plugin_find_by_media(const char* media);
TINYMEDIA_API int tmedia_session_plugin_unregister(const tmedia_session_plugin_def_t* plugin);
TINYMEDIA_API tmedia_session_t* tmedia_session_create(tmedia_type_t type);

TINYMEDIA_API int tmedia_session_deinit(tmedia_session_t* self);
typedef tsk_list_t tmedia_sessions_L_t; /**< List of @ref tmedia_session_t objects */
#define TMEDIA_DECLARE_SESSION tmedia_session_t __session__

/** Audio Session */
typedef struct tmedia_session_audio_s
{
	TMEDIA_DECLARE_SESSION;
}
tmedia_session_audio_t;
#define tmedia_session_audio_init(self)	tmedia_session_init(TMEDIA_SESSION(self), tmed_sess_type_audio)
TINYMEDIA_API int tmedia_session_audio_send_dtmf(tmedia_session_audio_t* self, uint8_t event);
#define tmedia_session_audio_deinit(self) tmedia_session_deinit(TMEDIA_SESSION(self))
#define tmedia_session_audio_create() tmedia_session_create(tmed_sess_type_audio)
#define TMEDIA_DECLARE_SESSION_AUDIO tmedia_session_audio_t __session_audio__

/** Video Session */
typedef struct tmedia_session_video_s
{
	TMEDIA_DECLARE_SESSION;
}
tmedia_session_video_t;
#define tmedia_session_video_init(self)	tmedia_session_init(TMEDIA_SESSION(self), tmed_sess_type_video)
#define tmedia_session_video_deinit(self) tmedia_session_deinit(TMEDIA_SESSION(self))
#define tmedia_session_video_create() tmedia_session_create(tmed_sess_type_video)
#define TMEDIA_DECLARE_SESSION_VIDEO tmedia_session_video_t __session_video__

/** Msrp Session */
struct tmedia_session_msrp_s;
struct tmsrp_event_s;
// use "struct tmsrp_event_s" instead of "tmsrp_event_t" to avoid linking aginst tinyMSRP
typedef int (*tmedia_session_msrp_cb_f)(const struct tmsrp_event_s* event);
typedef struct tmedia_session_msrp_s
{
	TMEDIA_DECLARE_SESSION;

	struct {
		tmedia_session_msrp_cb_f func;
		const void* data;
	} callback;
	
	int (* send_file) (struct tmedia_session_msrp_s*, const char* path, va_list *app);
	int (* send_message) (struct tmedia_session_msrp_s*, const void* data, tsk_size_t size, const tmedia_params_L_t *params);
}
tmedia_session_msrp_t;
#define tmedia_session_msrp_init(self)	tmedia_session_init(TMEDIA_SESSION(self), tmed_sess_type_msrp)
#define tmedia_session_msrp_deinit(self) tmedia_session_deinit(TMEDIA_SESSION(self))
#define tmedia_session_msrp_create() tmedia_session_create(tmed_sess_type_msrp)
#define TMEDIA_DECLARE_SESSION_MSRP tmedia_session_msrp_t __session_msrp__

/** Session manager */
typedef struct tmedia_session_mgr_s
{
	TSK_DECLARE_OBJECT;
	
	//! whether we are the offerer or not
	tsk_bool_t offerer;
	//! local IP address or FQDN
	char* addr;
	//! public IP address or FQDN
	char* public_addr;
	//! whether the @a addr is IPv6 or not (useful when @addr is a FQDN)
	tsk_bool_t ipv6;

	struct{

	} sdp;

	tsk_bool_t started;
	tsk_bool_t ro_changed;
	tsk_bool_t state_changed;
	tsk_bool_t mediaType_changed;

	//! session type
	tmedia_type_t type;
	//! QoS type
	struct {
		tmedia_qos_stype_t type;
		tmedia_qos_strength_t strength;
	} qos;
	
	//! bandwidth level
	tmedia_bandwidth_level_t bl;

	/* NAT Traversal context */


	//! List of all sessions
	tmedia_sessions_L_t* sessions;
#if (RTMP_ENABLED == 1)
    struct{
        struct rtmp_manager_t *incoming_session;
        struct rtmp_manager_t *outgoing_session;
        tsk_bool_t is_transport_rtmp;
    } rtmp;
#endif //(RTMP_ENABLED == 1)
	//! User's parameters used to confugure plugins
	tmedia_params_L_t* params;
}
tmedia_session_mgr_t;

typedef enum tmedia_session_param_type_e
{
	tmedia_sptype_null = 0,
	
	tmedia_sptype_set,
	//tmedia_sptype_get
}
tmedia_session_param_type_t;

#define TMEDIA_SESSION_SET_PARAM(MEDIA_TYPE_ENUM, PLUGIN_TYPE_ENUM, VALUE_TYPE_ENUM, KEY_STR, VALUE) \
	tmedia_sptype_set, (tmedia_type_t)MEDIA_TYPE_ENUM, (tmedia_param_plugin_type_t)PLUGIN_TYPE_ENUM, (tmedia_param_value_type_t)VALUE_TYPE_ENUM, \
		(const char*)KEY_STR, TMEDIA_PARAM_VALUE_TYPE_IS_PTR(VALUE_TYPE_ENUM) ? (void*)VALUE : (void*)&VALUE
//#define TMEDIA_SESSION_GET_PARAM(MEDIA_TYPE_ENUM, PLUGIN_TYPE_ENUM, VALUE_TYPE_ENUM, KEY_STR, VALUE_PTR) \
//	tmedia_sptype_get, (tmedia_type_t)MEDIA_TYPE_ENUM, (tmedia_param_plugin_type_t)PLUGIN_TYPE_ENUM, (tmedia_param_value_type_t)VALUE_TYPE_ENUM, \
//						(const char*)KEY_STR, (void**)&VALUE_PTR
/* Manager */
#define TMEDIA_SESSION_MANAGER_SET_INT32(KEY_STR, VALUE_INT32)	TMEDIA_SESSION_SET_PARAM(tmedia_none, tmedia_ppt_manager, tmedia_pvt_int32, KEY_STR, VALUE_INT32)
#define TMEDIA_SESSION_MANAGER_SET_POBJECT(KEY_STR, VALUE_PTR)	TMEDIA_SESSION_SET_PARAM(tmedia_none, tmedia_ppt_manager, tmedia_pvt_pobject, KEY_STR, VALUE_PTR)
#define TMEDIA_SESSION_MANAGER_SET_STR(KEY_STR, VALUE_STR)	TMEDIA_SESSION_SET_PARAM(tmedia_none, tmedia_ppt_manager, tmedia_pvt_pchar, KEY_STR, VALUE_STR)
#define TMEDIA_SESSION_MANAGER_SET_INT64(KEY_STR, VALUE_INT64)	TMEDIA_SESSION_SET_PARAM(tmedia_none, tmedia_ppt_manager, tmedia_pvt_int64, KEY_STR, VALUE_INT64)
//#define TMEDIA_SESSION_MANAGER_GET_INT32(KEY_STR, VALUE_PINT32)	TMEDIA_SESSION_GET_PARAM(tmedia_none, tmedia_ppt_manager, tmedia_pvt_int32, KEY_STR, VALUE_PINT32)
//#define TMEDIA_SESSION_MANAGER_GET_PVOID(KEY_STR, VALUE_PPTR)	TMEDIA_SESSION_GET_PARAM(tmedia_none, tmedia_ppt_manager, tmedia_pvt_pobject, KEY_STR, VALUE_PPTR)
//#define TMEDIA_SESSION_MANAGER_GET_STR(KEY_STR, VALUE_PSTR)	TMEDIA_SESSION_GET_PARAM(tmedia_none, tmedia_ppt_manager, tmedia_pvt_pchar, KEY_STR, VALUE_PSTR)
//#define TMEDIA_SESSION_MANAGER_GET_INT64(KEY_STR, VALUE_PINT64)	TMEDIA_SESSION_GET_PARAM(tmedia_none, tmedia_ppt_manager, tmedia_pvt_int64, KEY_STR, VALUE_PINT64)
/* Any Session */
#define TMEDIA_SESSION_SET_INT32(MEDIA_TYPE_ENUM, KEY_STR, VALUE_INT32)	TMEDIA_SESSION_SET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_session, tmedia_pvt_int32, KEY_STR, VALUE_INT32)
#define TMEDIA_SESSION_SET_POBJECT(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PTR)	TMEDIA_SESSION_SET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_session, tmedia_pvt_pobject, KEY_STR, VALUE_PTR)
#define TMEDIA_SESSION_SET_STR(MEDIA_TYPE_ENUM, KEY_STR, VALUE_STR)	TMEDIA_SESSION_SET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_session, tmedia_pvt_pchar, KEY_STR, VALUE_STR)
#define TMEDIA_SESSION_SET_INT64(MEDIA_TYPE_ENUM, KEY_STR, VALUE_INT64)	TMEDIA_SESSION_SET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_session, tmedia_pvt_int64, KEY_STR, VALUE_INT64)
//#define TMEDIA_SESSION_GET_INT32(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PINT32)	TMEDIA_SESSION_GET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_session, tmedia_pvt_int32, KEY_STR, VALUE_PINT32)
//#define TMEDIA_SESSION_GET_PVOID(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PPTR)	TMEDIA_SESSION_GET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_session, tmedia_pvt_pobject, KEY_STR, VALUE_PPTR)
//#define TMEDIA_SESSION_GET_STR(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PSTR)	TMEDIA_SESSION_GET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_session, tmedia_pvt_pchar, KEY_STR, VALUE_PSTR)
//#define TMEDIA_SESSION_GET_INT64(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PINT64)	TMEDIA_SESSION_GET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_session, tmedia_pvt_int64, KEY_STR, VALUE_PINT64)
/* Audio Session */
#define TMEDIA_SESSION_AUDIO_SET_INT32(KEY_STR, VALUE_INT32)	TMEDIA_SESSION_SET_INT32(tmedia_audio, KEY_STR, VALUE_INT32)
#define TMEDIA_SESSION_AUDIO_SET_POBJECT(KEY_STR, VALUE_PTR)	TMEDIA_SESSION_SET_POBJECT(tmedia_audio, KEY_STR, VALUE_PTR)
#define TMEDIA_SESSION_AUDIO_SET_STR(KEY_STR, VALUE_STR)	TMEDIA_SESSION_SET_STR(tmedia_audio, KEY_STR, VALUE_STR)
#define TMEDIA_SESSION_AUDIO_SET_INT64(KEY_STR, VALUE_INT64)	TMEDIA_SESSION_SET_INT64(tmedia_audio, KEY_STR, VALUE_INT64)
//#define TMEDIA_SESSION_AUDIO_GET_INT32(KEY_STR, VALUE_PINT32)	TMEDIA_SESSION_GET_INT32(tmedia_audio, KEY_STR, VALUE_PINT32)
//#define TMEDIA_SESSION_AUDIO_GET_PVOID(KEY_STR, VALUE_PPTR)	TMEDIA_SESSION_GET_PVOID(tmedia_audio, KEY_STR, VALUE_PPTR)
//#define TMEDIA_SESSION_AUDIO_GET_STR(KEY_STR, VALUE_PSTR)	TMEDIA_SESSION_GET_STR(tmedia_audio, KEY_STR, VALUE_PSTR)
//#define TMEDIA_SESSION_AUDIO_GET_INT64(KEY_STR, VALUE_PINT64)	TMEDIA_SESSION_GET_INT64(tmedia_audio, KEY_STR, VALUE_PINT64)
/* Video Session */
#define TMEDIA_SESSION_VIDEO_SET_INT32(KEY_STR, VALUE_INT32)	TMEDIA_SESSION_SET_INT32(tmedia_video, KEY_STR, VALUE_INT32)
#define TMEDIA_SESSION_VIDEO_SET_POBJECT(KEY_STR, VALUE_PTR)	TMEDIA_SESSION_SET_POBJECT(tmedia_video, KEY_STR, VALUE_PTR)
#define TMEDIA_SESSION_VIDEO_SET_STR(KEY_STR, VALUE_STR)	TMEDIA_SESSION_SET_STR(tmedia_video, KEY_STR, VALUE_STR)
#define TMEDIA_SESSION_VIDEO_SET_INT64(KEY_STR, VALUE_INT64)	TMEDIA_SESSION_SET_INT64(tmedia_video, KEY_STR, VALUE_INT64)
//#define TMEDIA_SESSION_VIDEO_GET_INT32(KEY_STR, VALUE_PINT32)	TMEDIA_SESSION_GET_INT32(tmedia_video, KEY_STR, VALUE_PINT32)
//#define TMEDIA_SESSION_VIDEO_GET_PVOID(KEY_STR, VALUE_PPTR)	TMEDIA_SESSION_GET_PVOID(tmedia_video, KEY_STR, VALUE_PPTR)
//#define TMEDIA_SESSION_VIDEO_GET_STR(KEY_STR, VALUE_PSTR)	TMEDIA_SESSION_GET_STR(tmedia_video, KEY_STR, VALUE_PSTR)
//#define TMEDIA_SESSION_VIDEO_GET_INT64(KEY_STR, VALUE_PINT64)	TMEDIA_SESSION_GET_INT64(tmedia_video, KEY_STR, VALUE_PINT64)
/* Msrp Session */
#define TMEDIA_SESSION_MSRP_SET_INT32(KEY_STR, VALUE_INT32)	TMEDIA_SESSION_SET_INT32(tmedia_msrp, KEY_STR, VALUE_INT32)
#define TMEDIA_SESSION_MSRP_SET_POBJECT(KEY_STR, VALUE_PTR)	TMEDIA_SESSION_SET_POBJECT(tmedia_msrp, KEY_STR, VALUE_PTR)
#define TMEDIA_SESSION_MSRP_SET_STR(KEY_STR, VALUE_STR)	TMEDIA_SESSION_SET_STR(tmedia_msrp, KEY_STR, VALUE_STR)
#define TMEDIA_SESSION_MSRP_SET_INT64(KEY_STR, VALUE_INT64)	TMEDIA_SESSION_SET_INT64(tmedia_msrp, KEY_STR, VALUE_INT64)
//#define TMEDIA_SESSION_MSRP_GET_INT32(KEY_STR, VALUE_PINT32)	TMEDIA_SESSION_GET_INT32(tmedia_msrp, KEY_STR, VALUE_PINT32)
//#define TMEDIA_SESSION_MSRP_GET_PVOID(KEY_STR, VALUE_PPTR)	TMEDIA_SESSION_GET_PVOID(tmedia_msrp, KEY_STR, VALUE_PPTR)
//#define TMEDIA_SESSION_MSRP_GET_STR(KEY_STR, VALUE_PSTR)	TMEDIA_SESSION_GET_STR(tmedia_msrp, KEY_STR, VALUE_PSTR)
//#define TMEDIA_SESSION_MSRP_GET_INT64(KEY_STR, VALUE_PINT64)	TMEDIA_SESSION_GET_INT64(tmedia_msrp, KEY_STR, VALUE_PINT64)
/* Any Consumer */
#define TMEDIA_SESSION_CONSUMER_SET_INT32(MEDIA_TYPE_ENUM, KEY_STR, VALUE_INT32)	TMEDIA_SESSION_SET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_consumer, tmedia_pvt_int32, KEY_STR, VALUE_INT32)
#define TMEDIA_SESSION_CONSUMER_SET_POBJECT(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PTR)	TMEDIA_SESSION_SET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_consumer, tmedia_pvt_pobject, KEY_STR, VALUE_PTR)
#define TMEDIA_SESSION_CONSUMER_SET_STR(MEDIA_TYPE_ENUM, KEY_STR, VALUE_STR)	TMEDIA_SESSION_SET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_consumer, tmedia_pvt_pchar, KEY_STR, VALUE_STR)
#define TMEDIA_SESSION_CONSUMER_SET_INT64(MEDIA_TYPE_ENUM, KEY_STR, VALUE_INT64)	TMEDIA_SESSION_SET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_consumer, tmedia_pvt_int64, KEY_STR, VALUE_INT64)
//#define TMEDIA_SESSION_CONSUMER_GET_INT32(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PINT32)	TMEDIA_SESSION_GET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_consumer, tmedia_pvt_int32, KEY_STR, VALUE_PINT32)
//#define TMEDIA_SESSION_CONSUMER_GET_PVOID(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PPTR)	TMEDIA_SESSION_GET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_consumer, tmedia_pvt_pobject, KEY_STR, VALUE_PPTR)
//#define TMEDIA_SESSION_CONSUMER_GET_STR(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PSTR)	TMEDIA_SESSION_GET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_consumer, tmedia_pvt_pchar, KEY_STR, VALUE_PSTR)
//#define TMEDIA_SESSION_CONSUMER_GET_INT64(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PINT64)	TMEDIA_SESSION_GET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_consumer, tmedia_pvt_int64, KEY_STR, VALUE_PINT64)
/* Audio Consumer */
#define TMEDIA_SESSION_AUDIO_CONSUMER_SET_INT32(KEY_STR, VALUE_INT32)	TMEDIA_SESSION_CONSUMER_SET_INT32(tmedia_audio, KEY_STR, VALUE_INT32)
#define TMEDIA_SESSION_AUDIO_CONSUMER_SET_POBJECT(KEY_STR, VALUE_PTR)	TMEDIA_SESSION_CONSUMER_SET_POBJECT(tmedia_audio, KEY_STR, VALUE_PTR)
#define TMEDIA_SESSION_AUDIO_CONSUMER_SET_STR(KEY_STR, VALUE_STR)	TMEDIA_SESSION_CONSUMER_SET_STR(tmedia_audio, KEY_STR, VALUE_STR)
#define TMEDIA_SESSION_AUDIO_CONSUMER_SET_INT64(KEY_STR, VALUE_INT64)	TMEDIA_SESSION_CONSUMER_SET_INT64(tmedia_audio, KEY_STR, VALUE_INT64)
//#define TMEDIA_SESSION_AUDIO_CONSUMER_GET_INT32(KEY_STR, VALUE_PINT32)	TMEDIA_SESSION_CONSUMER_GET_INT32(tmedia_audio, KEY_STR, VALUE_PINT32)
//#define TMEDIA_SESSION_AUDIO_CONSUMER_GET_PVOID(KEY_STR, VALUE_PPTR)	TMEDIA_SESSION_CONSUMER_GET_PVOID(tmedia_audio, KEY_STR, VALUE_PPTR)
//#define TMEDIA_SESSION_AUDIO_CONSUMER_GET_STR(KEY_STR, VALUE_PSTR)	TMEDIA_SESSION_CONSUMER_GET_STR(tmedia_audio, KEY_STR, VALUE_PSTR)
//#define TMEDIA_SESSION_AUDIO_CONSUMER_GET_INT64(KEY_STR, VALUE_PINT64)	TMEDIA_SESSION_CONSUMER_GET_INT64(tmedia_audio, KEY_STR, VALUE_PINT64)
/* Video Consumer */
#define TMEDIA_SESSION_VIDEO_CONSUMER_SET_INT32(KEY_STR, VALUE_INT32)	TMEDIA_SESSION_CONSUMER_SET_INT32(tmedia_video, KEY_STR, VALUE_INT32)
#define TMEDIA_SESSION_VIDEO_CONSUMER_SET_POBJECT(KEY_STR, VALUE_PTR)	TMEDIA_SESSION_CONSUMER_SET_POBJECT(tmedia_video, KEY_STR, VALUE_PTR)
#define TMEDIA_SESSION_VIDEO_CONSUMER_SET_STR(KEY_STR, VALUE_STR)	TMEDIA_SESSION_CONSUMER_SET_STR(tmedia_video, KEY_STR, VALUE_STR)
#define TMEDIA_SESSION_VIDEO_CONSUMER_SET_INT64(KEY_STR, VALUE_INT64)	TMEDIA_SESSION_CONSUMER_SET_INT64(tmedia_video, KEY_STR, VALUE_INT64)
//#define TMEDIA_SESSION_VIDEO_CONSUMER_GET_INT32(KEY_STR, VALUE_PINT32)	TMEDIA_SESSION_CONSUMER_GET_INT32(tmedia_video, KEY_STR, VALUE_PINT32)
//#define TMEDIA_SESSION_VIDEO_CONSUMER_GET_PVOID(KEY_STR, VALUE_PPTR)	TMEDIA_SESSION_CONSUMER_GET_PVOID(tmedia_video, KEY_STR, VALUE_PPTR)
//#define TMEDIA_SESSION_VIDEO_CONSUMER_GET_STR(KEY_STR, VALUE_PSTR)	TMEDIA_SESSION_CONSUMER_GET_STR(tmedia_video, KEY_STR, VALUE_PSTR)
//#define TMEDIA_SESSION_VIDEO_CONSUMER_GET_INT64(KEY_STR, VALUE_PINT64)	TMEDIA_SESSION_CONSUMER_GET_INT64(tmedia_video, KEY_STR, VALUE_PINT64)
/* Msrp Consumer */
#define TMEDIA_SESSION_MSRP_CONSUMER_SET_INT32(KEY_STR, VALUE_INT32)	TMEDIA_SESSION_CONSUMER_SET_INT32(tmedia_msrp, KEY_STR, VALUE_INT32)
#define TMEDIA_SESSION_MSRP_CONSUMER_SET_POBJECT(KEY_STR, VALUE_PTR)	TMEDIA_SESSION_CONSUMER_SET_POBJECT(tmedia_msrp, KEY_STR, VALUE_PTR)
#define TMEDIA_SESSION_MSRP_CONSUMER_SET_STR(KEY_STR, VALUE_STR)	TMEDIA_SESSION_CONSUMER_SET_STR(tmedia_msrp, KEY_STR, VALUE_STR)
#define TMEDIA_SESSION_MSRP_CONSUMER_SET_INT64(KEY_STR, VALUE_INT64)	TMEDIA_SESSION_CONSUMER_SET_INT64(tmedia_msrp, KEY_STR, VALUE_INT64)
//#define TMEDIA_SESSION_MSRP_CONSUMER_GET_INT32(KEY_STR, VALUE_PINT32)	TMEDIA_SESSION_CONSUMER_GET_INT32(tmedia_msrp, KEY_STR, VALUE_PINT32)
//#define TMEDIA_SESSION_MSRP_CONSUMER_GET_PVOID(KEY_STR, VALUE_PPTR)	TMEDIA_SESSION_CONSUMER_GET_PVOID(tmedia_msrp, KEY_STR, VALUE_PPTR)
//#define TMEDIA_SESSION_MSRP_CONSUMER_GET_STR(KEY_STR, VALUE_PSTR)	TMEDIA_SESSION_CONSUMER_GET_STR(tmedia_msrp, KEY_STR, VALUE_PSTR)
//#define TMEDIA_SESSION_MSRP_CONSUMER_GET_INT64(KEY_STR, VALUE_PINT64)	TMEDIA_SESSION_CONSUMER_GET_INT64(tmedia_msrp, KEY_STR, VALUE_PINT64)
/* Any Producer */
#define TMEDIA_SESSION_PRODUCER_SET_INT32(MEDIA_TYPE_ENUM, KEY_STR, VALUE_INT32)	TMEDIA_SESSION_SET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_producer, tmedia_pvt_int32, KEY_STR, VALUE_INT32)
#define TMEDIA_SESSION_PRODUCER_SET_POBJECT(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PTR)	TMEDIA_SESSION_SET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_producer, tmedia_pvt_pobject, KEY_STR, VALUE_PTR)
#define TMEDIA_SESSION_PRODUCER_SET_STR(MEDIA_TYPE_ENUM, KEY_STR, VALUE_STR)	TMEDIA_SESSION_SET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_producer, tmedia_pvt_pchar, KEY_STR, VALUE_STR)
#define TMEDIA_SESSION_PRODUCER_SET_INT64(MEDIA_TYPE_ENUM, KEY_STR, VALUE_INT64)	TMEDIA_SESSION_SET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_producer, tmedia_pvt_int64, KEY_STR, VALUE_INT64)
//#define TMEDIA_SESSION_PRODUCER_GET_INT32(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PINT32)	TMEDIA_SESSION_GET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_producer, tmedia_pvt_int32, KEY_STR, VALUE_PINT32)
//#define TMEDIA_SESSION_PRODUCER_GET_PVOID(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PPTR)	TMEDIA_SESSION_GET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_producer, tmedia_pvt_pobject, KEY_STR, VALUE_PPTR)
//#define TMEDIA_SESSION_PRODUCER_GET_STR(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PSTR)	TMEDIA_SESSION_GET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_producer, tmedia_pvt_pchar, KEY_STR, VALUE_PSTR)
//#define TMEDIA_SESSION_PRODUCER_GET_INT64(MEDIA_TYPE_ENUM, KEY_STR, VALUE_PINT64)	TMEDIA_SESSION_GET_PARAM(MEDIA_TYPE_ENUM, tmedia_ppt_producer, tmedia_pvt_int64, KEY_STR, VALUE_PINT64)
/* Audio Producer */
#define TMEDIA_SESSION_AUDIO_PRODUCER_SET_INT32(KEY_STR, VALUE_INT32)	TMEDIA_SESSION_PRODUCER_SET_INT32(tmedia_audio, KEY_STR, VALUE_INT32)
#define TMEDIA_SESSION_AUDIO_PRODUCER_SET_POBJECT(KEY_STR, VALUE_PTR)	TMEDIA_SESSION_PRODUCER_SET_POBJECT(tmedia_audio, KEY_STR, VALUE_PTR)
#define TMEDIA_SESSION_AUDIO_PRODUCER_SET_STR(KEY_STR, VALUE_STR)	TMEDIA_SESSION_AUDIO_PRODUCER_SET_STR(tmedia_audio, KEY_STR, VALUE_STR)
#define TMEDIA_SESSION_AUDIO_PRODUCER_SET_INT64(KEY_STR, VALUE_INT64)	TMEDIA_SESSION_PRODUCER_SET_INT64(tmedia_audio, KEY_STR, VALUE_INT64)
//#define TMEDIA_SESSION_AUDIO_PRODUCER_GET_INT32(KEY_STR, VALUE_PINT32)	TMEDIA_SESSION_PRODUCER_GET_INT32(tmedia_audio, KEY_STR, VALUE_PINT32)
//#define TMEDIA_SESSION_AUDIO_PRODUCER_GET_PVOID(KEY_STR, VALUE_PPTR)	TMEDIA_SESSION_PRODUCER_GET_PVOID(tmedia_audio, KEY_STR, VALUE_PPTR)
//#define TMEDIA_SESSION_AUDIO_PRODUCER_GET_STR(KEY_STR, VALUE_PSTR)	TMEDIA_SESSION_AUDIO_PRODUCER_GET_STR(tmedia_audio, KEY_STR, VALUE_PSTR)
//#define TMEDIA_SESSION_AUDIO_PRODUCER_GET_INT64(KEY_STR, VALUE_PINT64)	TMEDIA_SESSION_PRODUCER_GET_INT64(tmedia_audio, KEY_STR, VALUE_PINT64)
/* Video Producer */
#define TMEDIA_SESSION_VIDEO_PRODUCER_SET_INT32(KEY_STR, VALUE_INT32)	TMEDIA_SESSION_PRODUCER_SET_INT32(tmedia_video, KEY_STR, VALUE_INT32)
#define TMEDIA_SESSION_VIDEO_PRODUCER_SET_POBJECT(KEY_STR, VALUE_PTR)	TMEDIA_SESSION_PRODUCER_SET_POBJECT(tmedia_video, KEY_STR, VALUE_PTR)
#define TMEDIA_SESSION_VIDEO_PRODUCER_SET_STR(KEY_STR, VALUE_STR)	TMEDIA_SESSION_AUDIO_PRODUCER_SET_STR(tmedia_video, KEY_STR, VALUE_STR)
#define TMEDIA_SESSION_VIDEO_PRODUCER_SET_INT64(KEY_STR, VALUE_INT64)	TMEDIA_SESSION_PRODUCER_SET_INT64(tmedia_video, KEY_STR, VALUE_INT64)
//#define TMEDIA_SESSION_VIDEO_PRODUCER_GET_INT32(KEY_STR, VALUE_PINT32)	TMEDIA_SESSION_PRODUCER_GET_INT32(tmedia_video, KEY_STR, VALUE_PINT32)
//#define TMEDIA_SESSION_VIDEO_PRODUCER_GET_PVOID(KEY_STR, VALUE_PPTR)	TMEDIA_SESSION_PRODUCER_GET_PVOID(tmedia_video, KEY_STR, VALUE_PPTR)
//#define TMEDIA_SESSION_VIDEO_PRODUCER_GET_STR(KEY_STR, VALUE_PSTR)	TMEDIA_SESSION_AUDIO_PRODUCER_GET_STR(tmedia_video, KEY_STR, VALUE_PSTR)
//#define TMEDIA_SESSION_VIDEO_PRODUCER_GET_INT64(KEY_STR, VALUE_PINT64)	TMEDIA_SESSION_PRODUCER_GET_INT64(tmedia_video, KEY_STR, VALUE_PINT64)
/* Msrp Producer */
#define TMEDIA_SESSION_MSRP_PRODUCER_SET_INT32(KEY_STR, VALUE_INT32)	TMEDIA_SESSION_PRODUCER_SET_INT32(tmedia_msrp, KEY_STR, VALUE_INT32)
#define TMEDIA_SESSION_MSRP_PRODUCER_SET_POBJECT(KEY_STR, VALUE_PTR)	TMEDIA_SESSION_PRODUCER_SET_POBJECT(tmedia_msrp, KEY_STR, VALUE_PTR)
#define TMEDIA_SESSION_MSRP_PRODUCER_SET_STR(KEY_STR, VALUE_STR)	TMEDIA_SESSION_AUDIO_PRODUCER_SET_STR(tmedia_msrp, KEY_STR, VALUE_STR)
#define TMEDIA_SESSION_MSRP_PRODUCER_SET_INT64(KEY_STR, VALUE_INT64)	TMEDIA_SESSION_PRODUCER_SET_INT64(tmedia_msrp, KEY_STR, VALUE_INT64)
//#define TMEDIA_SESSION_MSRP_PRODUCER_GET_INT32(KEY_STR, VALUE_PINT32)	TMEDIA_SESSION_PRODUCER_GET_INT32(tmedia_msrp, KEY_STR, VALUE_PINT32)
//#define TMEDIA_SESSION_MSRP_PRODUCER_GET_PVOID(KEY_STR, VALUE_PPTR)	TMEDIA_SESSION_PRODUCER_GET_PVOID(tmedia_msrp, KEY_STR, VALUE_PPTR)
//#define TMEDIA_SESSION_MSRP_PRODUCER_GET_STR(KEY_STR, VALUE_PSTR)	TMEDIA_SESSION_AUDIO_PRODUCER_GET_STR(tmedia_msrp, KEY_STR, VALUE_PSTR)
//#define TMEDIA_SESSION_MSRP_PRODUCER_GET_INT64(KEY_STR, VALUE_PINT64)	TMEDIA_SESSION_PRODUCER_GET_INT64(tmedia_msrp, KEY_STR, VALUE_PINT64)


#define TMEDIA_SESSION_SET_NULL()							tmedia_sptype_null
//#define TMEDIA_SESSION_GET_NULL()							tmedia_sptype_null

//#define TMEDIA_SESSION_SET_REMOTE_IP(IP_STR)				tmedia_sptype_remote_ip, (const char*) IP_STR
//#define TMEDIA_SESSION_SET_LOCAL_IP(IP_STR, IPv6_BOOL)		tmedia_sptype_local_ip, (const char*) IP_STR, (tsk_bool_t)IPv6_BOOL
//#define TMEDIA_SESSION_SET_RTCP(ENABLED_BOOL)				tmedia_sptype_set_rtcp, (tsk_bool_t)ENABLED_BOOL
//#define TMEDIA_SESSION_SET_QOS(TYPE_ENUM, STRENGTH_ENUM)	tmedia_sptype_qos, (tmedia_qos_stype_t)TYPE_ENUM, (tmedia_qos_strength_t)STRENGTH_ENUM


TINYMEDIA_API tmedia_session_mgr_t* tmedia_session_mgr_create(tmedia_type_t type, const char* addr, tsk_bool_t ipv6, tsk_bool_t offerer);
TINYMEDIA_API tmedia_session_t* tmedia_session_mgr_find(tmedia_session_mgr_t* self, tmedia_type_t type);
TINYMEDIA_API int tmedia_session_mgr_start(tmedia_session_mgr_t* self);
TINYMEDIA_API int tmedia_session_mgr_set(tmedia_session_mgr_t* self, ...);
TINYMEDIA_API int tmedia_session_mgr_set_2(tmedia_session_mgr_t* self, va_list *app);
TINYMEDIA_API int tmedia_session_mgr_set_3(tmedia_session_mgr_t* self, const tmedia_params_L_t* params);
TINYMEDIA_API int tmedia_session_mgr_stop(tmedia_session_mgr_t* self);

TINYMEDIA_API int tmedia_session_mgr_hold(tmedia_session_mgr_t* self, tmedia_type_t type);
TINYMEDIA_API tsk_bool_t tmedia_session_mgr_is_held(tmedia_session_mgr_t* self, tmedia_type_t type, tsk_bool_t local);
TINYMEDIA_API int tmedia_session_mgr_resume(tmedia_session_mgr_t* self, tmedia_type_t type);
TINYMEDIA_API int tmedia_session_mgr_add_media(tmedia_session_mgr_t* self, tmedia_type_t type);
TINYMEDIA_API int tmedia_session_mgr_remove_media(tmedia_session_mgr_t* self, tmedia_type_t type);
TINYMEDIA_API int tmedia_session_mgr_set_qos(tmedia_session_mgr_t* self, tmedia_qos_stype_t qos_type, tmedia_qos_strength_t qos_strength);
TINYMEDIA_API tsk_bool_t tmedia_session_mgr_canresume(tmedia_session_mgr_t* self);
TINYMEDIA_API tsk_bool_t tmedia_session_mgr_has_active_session(tmedia_session_mgr_t* self);
TINYMEDIA_API int tmedia_session_mgr_send_dtmf(tmedia_session_mgr_t* self, uint8_t event);
TINYMEDIA_API int tmedia_session_mgr_send_file(tmedia_session_mgr_t* self, const char* path, ...);
TINYMEDIA_API int tmedia_session_mgr_send_message(tmedia_session_mgr_t* self, const void* data, tsk_size_t size, const tmedia_params_L_t *params);
TINYMEDIA_API int tmedia_session_mgr_set_msrp_cb(tmedia_session_mgr_t* self, const void* callback_data, tmedia_session_msrp_cb_f func);


TINYMEDIA_GEXTERN const tsk_object_def_t *tmedia_session_mgr_def_t;

TMEDIA_END_DECLS

#endif /* TINYMEDIA_SESSION_H */
