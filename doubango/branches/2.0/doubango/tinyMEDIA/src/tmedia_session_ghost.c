

/**@file tmedia_session_ghost.c
 * @brief Ghost session.
 *

 *

 */
#include "tinymedia/tmedia_session_ghost.h"

#include "tsk_memory.h"
#include "tsk_debug.h"

/* ============ Ghost Session ================= */

int tmedia_session_ghost_prepare(tmedia_session_t* self)
{
	return 0;
}

int tmedia_session_ghost_start(tmedia_session_t* self)
{
	return 0;
}

int tmedia_session_ghost_stop(tmedia_session_t* self)
{
	TSK_DEBUG_INFO("tmedia_session_ghost_stop");
	return 0;
}

int tmedia_session_ghost_pause(tmedia_session_t* self)
{
	return 0;
}










//=================================================================================================
//	Ghost session object definition
//
/* constructor */
static tsk_object_t* tmedia_session_ghost_ctor(tsk_object_t * self, va_list * app)
{
	tmedia_session_ghost_t *session = self;
	if(session){
		/* init base */
		tmedia_session_init(TMEDIA_SESSION(session), tmedia_none);
		/* init self */
	}
	return self;
}
/* destructor */
static tsk_object_t* tmedia_session_ghost_dtor(tsk_object_t * self)
{ 
	tmedia_session_ghost_t *session = self;
	if(session){
		/* deinit base */
		tmedia_session_deinit(TMEDIA_SESSION(session));
		/* deinit self */
		TSK_FREE(session->media);
	}

	return self;
}
/* object definition */
static const tsk_object_def_t tmedia_session_ghost_def_s = 
{
	sizeof(tmedia_session_ghost_t),
	tmedia_session_ghost_ctor, 
	tmedia_session_ghost_dtor,
	tmedia_codec_cmp, 
};
/* plugin definition*/
static const tmedia_session_plugin_def_t tmedia_session_ghost_plugin_def_s = 
{
	&tmedia_session_ghost_def_s,
	
	tmedia_ghost,
	"ghost",
	
	tsk_null,
	tmedia_session_ghost_prepare,
	tmedia_session_ghost_start,
	tmedia_session_ghost_stop,
	tmedia_session_ghost_pause,

	/* Audio part */
	{ tsk_null },


};
const tmedia_session_plugin_def_t *tmedia_session_ghost_plugin_def_t = &tmedia_session_ghost_plugin_def_s;
