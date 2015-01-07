

/**@file tmedia_session_dummy.c
 * @brief Dummy sessions used for test only.
 *

 *

 */
#include "tinymedia/tmedia_session_dummy.h"

#include "tsk_memory.h"
#include "tsk_debug.h"

/* ============ Audio Session ================= */

int tmedia_session_daudio_set(tmedia_session_t* self, const tmedia_param_t* param)
{
	tmedia_session_daudio_t* daudio;

	daudio = (tmedia_session_daudio_t*)self;

	return 0;
}

int tmedia_session_daudio_prepare(tmedia_session_t* self)
{
	tmedia_session_daudio_t* daudio;

	daudio = (tmedia_session_daudio_t*)self;

	/* set local port */
	daudio->local_port = rand() ^ rand();

	return 0;
}

int tmedia_session_daudio_start(tmedia_session_t* self)
{
	return 0;
}

int tmedia_session_daudio_stop(tmedia_session_t* self)
{
	tmedia_session_daudio_t* daudio;

	daudio = (tmedia_session_daudio_t*)self;

	/* very important */
	daudio->local_port = 0;

	return 0;
}

int tmedia_session_daudio_send_dtmf(tmedia_session_t* self, uint8_t event)
{
	return 0;
}

int tmedia_session_daudio_pause(tmedia_session_t* self)
{
	return 0;
}


/* ============ Video Session ================= */

int tmedia_session_dvideo_set(tmedia_session_t* self, const tmedia_param_t* param)
{
	tmedia_session_dvideo_t* dvideo;

	dvideo = (tmedia_session_dvideo_t*)self;

	return 0;
}

int tmedia_session_dvideo_prepare(tmedia_session_t* self)
{
	tmedia_session_dvideo_t* dvideo;

	dvideo = (tmedia_session_dvideo_t*)self;

	/* set local port */
	dvideo->local_port = rand() ^ rand();

	return 0;
}

int tmedia_session_dvideo_start(tmedia_session_t* self)
{
	return -1;
}

int tmedia_session_dvideo_stop(tmedia_session_t* self)
{
	tmedia_session_dvideo_t* dvideo;

	dvideo = (tmedia_session_dvideo_t*)self;

	/* very important */
	dvideo->local_port = 0;

	return 0;
}

int tmedia_session_dvideo_pause(tmedia_session_t* self)
{
	return -1;
}


/* ============ Msrp Session ================= */

int tmedia_session_dmsrp_set(tmedia_session_t* self, const tmedia_param_t* param)
{
	tmedia_session_dmsrp_t* dmsrp;

	dmsrp = (tmedia_session_dmsrp_t*)self;

	return 0;
}

int tmedia_session_dmsrp_prepare(tmedia_session_t* self)
{
	return 0;
}

int tmedia_session_dmsrp_start(tmedia_session_t* self)
{
	return 0;
}

int tmedia_session_dmsrp_stop(tmedia_session_t* self)
{
	return 0;
}

int tmedia_session_dmsrp_pause(tmedia_session_t* self)
{
	return 0;
}




//=================================================================================================
//	Dummy Audio session object definition
//
/* constructor */
static tsk_object_t* tmedia_session_daudio_ctor(tsk_object_t * self, va_list * app)
{
	tmedia_session_daudio_t *session = self;
	if(session){
		/* init base: called by tmedia_session_create() */
		/* init self */
	}
	return self;
}
/* destructor */
static tsk_object_t* tmedia_session_daudio_dtor(tsk_object_t * self)
{ 
	tmedia_session_daudio_t *session = self;
	if(session){
		/* deinit base */
		tmedia_session_deinit(self);
		/* deinit self */
	}

	return self;
}
/* object definition */
static const tsk_object_def_t tmedia_session_daudio_def_s = 
{
	sizeof(tmedia_session_daudio_t),
	tmedia_session_daudio_ctor, 
	tmedia_session_daudio_dtor,
	tmedia_session_cmp, 
};
/* plugin definition*/
static const tmedia_session_plugin_def_t tmedia_session_daudio_plugin_def_s = 
{
	&tmedia_session_daudio_def_s,
	
	tmedia_audio,
	"audio",
	
	tmedia_session_daudio_set,
	tmedia_session_daudio_prepare,
	tmedia_session_daudio_start,
	tmedia_session_daudio_pause,
	tmedia_session_daudio_stop,
	
	/* Audio part */
	{ tsk_null },

};
const tmedia_session_plugin_def_t *tmedia_session_daudio_plugin_def_t = &tmedia_session_daudio_plugin_def_s;


//=================================================================================================
//	Dummy Video session object definition
//
/* constructor */
static tsk_object_t* tmedia_session_dvideo_ctor(tsk_object_t * self, va_list * app)
{
	tmedia_session_dvideo_t *session = self;
	if(session){
		/* init base: called by tmedia_session_create() */
		/* init self */
	}
	return self;
}
/* destructor */
static tsk_object_t* tmedia_session_dvideo_dtor(tsk_object_t * self)
{ 
	tmedia_session_dvideo_t *session = self;
	if(session){
		/* deinit base */
		tmedia_session_deinit(self);
		/* deinit self */
	}

	return self;
}
/* object definition */
static const tsk_object_def_t tmedia_session_dvideo_def_s = 
{
	sizeof(tmedia_session_dvideo_t),
	tmedia_session_dvideo_ctor, 
	tmedia_session_dvideo_dtor,
	tmedia_session_cmp, 
};
/* plugin definition*/
static const tmedia_session_plugin_def_t tmedia_session_dvideo_plugin_def_s = 
{
	&tmedia_session_dvideo_def_s,
	
	tmedia_video,
	"video",
	
	tmedia_session_dvideo_set,
	tmedia_session_dvideo_prepare,
	tmedia_session_dvideo_start,
	tmedia_session_dvideo_pause,
	tmedia_session_dvideo_stop,

	/* Audio part */
	{ tsk_null },


};
const tmedia_session_plugin_def_t *tmedia_session_dvideo_plugin_def_t = &tmedia_session_dvideo_plugin_def_s;


//=================================================================================================
//	Dummy Msrp session object definition
//
/* constructor */
static tsk_object_t* tmedia_session_dmsrp_ctor(tsk_object_t * self, va_list * app)
{
	tmedia_session_dmsrp_t *session = self;
	if(session){
		/* init base: called by tmedia_session_create() */
		/* init self */
	}
	return self;
}
/* destructor */
static tsk_object_t* tmedia_session_dmsrp_dtor(tsk_object_t * self)
{ 
	tmedia_session_dmsrp_t *session = self;
	if(session){
		/* deinit base */
		tmedia_session_deinit(self);
		/* deinit self */

	}

	return self;
}
/* object definition */
static const tsk_object_def_t tmedia_session_dmsrp_def_s = 
{
	sizeof(tmedia_session_dmsrp_t),
	tmedia_session_dmsrp_ctor, 
	tmedia_session_dmsrp_dtor,
	tmedia_session_cmp, 
};
/* plugin definition*/
static const tmedia_session_plugin_def_t tmedia_session_dmsrp_plugin_def_s = 
{
	&tmedia_session_dmsrp_def_s,
	
	tmedia_msrp,
	"message",
	
	tmedia_session_dmsrp_set,
	tmedia_session_dmsrp_prepare,
	tmedia_session_dmsrp_start,
	tmedia_session_dmsrp_pause,
	tmedia_session_dmsrp_stop,
	
	/* Audio part */
	{ tsk_null },


};
const tmedia_session_plugin_def_t *tmedia_session_dmsrp_plugin_def_t = &tmedia_session_dmsrp_plugin_def_s;
