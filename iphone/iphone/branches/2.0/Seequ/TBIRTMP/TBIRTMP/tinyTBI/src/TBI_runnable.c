 

/**@file TBI_runnable.c
 * @brief Base class for runnable object.
 *

 *

 */
#include "TBI_runnable.h"
#include "TBI_thread.h"
#include "TBI_debug.h"

/**@defgroup TBI_runnable_group Base class for runnable object.
*/

/**@ingroup TBI_runnable_group
* Creates new Runnable object.
* @retval @ref TBI_runnable_t.
*/
TBI_runnable_t* TBI_runnable_create()
{
	return TBI_object_new(TBI_runnable_def_t);
}

/**@ingroup TBI_runnable_group
* Initializes a runnable object and allocate it's internal fields.
* @param self The runnable object to initialize.
* @param objdef Internal objects definition class.
* @retval Zero if succeed and nonzero error code otherwise.
* @sa TBI_runnable_deinit.
*/
static int TBI_runnable_init(TBI_runnable_t *self, const TBI_object_def_t *objdef)
{
	if(self && objdef){
		if(self->initialized){
			TBI_DEBUG_ERROR("Already initialized");
			return -2;
		}
		
		self->semaphore = TBI_semaphore_create();
		self->objdef = objdef;
		self->objects = TBI_list_create();

		self->initialized = TBI_true;
		return 0;
	}
	TBI_DEBUG_ERROR("Invalid Parameter");
	return -1;
}

/**@ingroup TBI_runnable_group
* DeInitializes a runnable object.
* @param self The runnable object to deinitialize.
* @retval Zero if succeed and nonzero error code otherwise.
* @sa TBI_runnable_init.
*/
static int TBI_runnable_deinit(TBI_runnable_t *self)
{
	if(self){
		if(!self->initialized){
			return 0; /* Already deinitialized */
		}
		else if(self->running){
			TBI_DEBUG_ERROR("Cannot deinit a runnable object while running.");
			return -3;
		}

		TBI_semaphore_destroy(&self->semaphore);
		TBI_OBJECT_SAFE_FREE(self->objects);

		self->initialized = TBI_false;

		return 0;
	}
	TBI_DEBUG_ERROR("Invalid parameter");
	return -1;
}

/**@ingroup TBI_runnable_group
* Starts a runnable object.
* @param self The runnable object to start.
* @param objdef Internal objects definition (meta-data) class.
* @retval Zero if succeed and nonzero error code otherwise.
* @sa TBI_runnable_stop.
*/
int TBI_runnable_start(TBI_runnable_t *self, const TBI_object_def_t *objdef)
{
	if(self){
		int ret = -1;
		if(self->running) return -2;
		else if(!self->run) return -3;
		else if(TBI_runnable_init(self, objdef)) return -4;

		/* call run() function in new thread. */
		if((ret = TBI_thread_create(&(self->tid[0]), self->run, self))){
			TBI_DEBUG_ERROR("Failed to start new thread.");
			return ret;
		}
		// Do not set "running" to true here
		// Problem: When you try to stop the thread before it start
		// Will be done by "TBI_RUNNABLE_RUN_BEGIN" which is called into the thread
		//self->running = TBI_true;

		self->started = TBI_true;
		return 0;
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
}

/**@ingroup TBI_runnable_group
* To indicate whether the enqueued data is important or not.
* @param self The runnable object
* @param important @a TBI_true or @a TBI_false. If set to @a TBI_true, the thread will not be joined 
* until all data in the queue have been consumed.
*/
int TBI_runnable_set_important(TBI_runnable_t *self, TBI_bool_t important)
{
	if(self){
		self->important = important;
		return 0;
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
}

/**@ingroup TBI_runnable_group
* Stops a runnable object.
* @param self The runnable object to stop.
* @retval Zero if succeed and nonzero error code otherwise.
* @sa TBI_runnable_start.
*/
int TBI_runnable_stop(TBI_runnable_t *self)
{
	int ret = -1;
	if(self){
		if(!self->initialized) {
			if(!self->running){
				/* already deinitialized */
				return 0;
			}
			else{
				/* should never happen */
				TBI_DEBUG_ERROR("Not initialized.");
				return -2;
			}
		}
		else if(!self->running) {

			if(self->started){
				TBI_size_t count = 0;
				/* Thread is started but not running ==> Give it time.*/
				while(++count <= 5){
					TBI_thread_sleep(count * 200);
					if(self->running){
						goto stop;
					}
				}
			}
			else{
				return 0; /* already stopped */
			} 
			return -3;
		}

stop:
		self->running = TBI_false;
		TBI_semaphore_increment(self->semaphore);

		if((ret = TBI_thread_join(&(self->tid[0])))){
			self->running = TBI_true;
			TBI_DEBUG_ERROR("Failed to join the thread.");
			return ret;
		}
		TBI_runnable_deinit(self);

		self->started = TBI_false;
	}
	return ret;
}

//=================================================================================================
//	Runnable object definition
//
static TBI_object_t* TBI_runnable_ctor(TBI_object_t * self, va_list * app)
{
	TBI_runnable_t* runnable = self;
	if(runnable){
	}
	return self;
}

static TBI_object_t* TBI_runnable_dtor(TBI_object_t * self)
{ 
	TBI_runnable_t* runnable = self;
	if(runnable){
		/* stops runnable object (if running or started) */
		TBI_runnable_stop(runnable);
	}
	return self;
}

static const TBI_object_def_t TBI_runnable_def_s = 
{
	sizeof(TBI_runnable_t),
	TBI_runnable_ctor, 
	TBI_runnable_dtor,
	TBI_null, 
};
const TBI_object_def_t *TBI_runnable_def_t = &TBI_runnable_def_s;

