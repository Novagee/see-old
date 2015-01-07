 

/**@file TBI_timer.c
* @brief Timer Manager.
*
*
*
* @date Created: Sat Nov 8 16:54:58 2009 mdiop
*/
#include "TBI_timer.h"
#include "TBI_debug.h"
#include "TBI_list.h"
#include "TBI_thread.h"
#include "TBI_runnable.h"
#include "TBI_condwait.h"
#include "TBI_semaphore.h"
#include "TBI_time.h"


/**@defgroup TBI_timer_group Timers Management
*/

#define TBI_TIMER_CREATE(timeout, callback, arg)	TBI_object_new(TBI_timer_def_t, timeout, callback, arg)
#define TBI_TIMER_TIMEOUT(self)						((TBI_timer_t*)self)->timeout
#define TBI_TIMER_GET_FIRST()						(manager->timers && manager->timers->head) ? (TBI_timer_t*)(((TBI_list_item_t*)(manager->timers->head))->data) : 0

/**
 * @struct	TBI_timer_s
 * @brief	Timer.
**/
typedef struct TBI_timer_s
{
	TBI_DECLARE_OBJECT;

	TBI_timer_id_t id;	/**< Unique timer identifier. */
	const void *arg; /**< Opaque data to return with the callback function. */
	uint64_t timeout; /**< When the timer will timeout(as EPOCH time). */
	TBI_timer_callback_f callback; /**< The callback function to call after @ref timeout milliseconds. */

	unsigned canceled:1;
}
TBI_timer_t;
typedef TBI_list_t TBI_timers_L_t; /**< List of @ref TBI_timer_t elements. */

/**
 * @struct	TBI_timer_manager_s
 *
 * @brief	Timer manager.
**/
typedef struct TBI_timer_manager_s
{
	TBI_DECLARE_RUNNABLE;

	void* mainThreadId[1];
	TBI_condwait_handle_t *condwait;
	TBI_mutex_handle_t *mutex;
	TBI_semaphore_handle_t *sem;

	TBI_timers_L_t *timers;
}
TBI_timer_manager_t;
typedef TBI_list_t TBI_timer_manager_L_t; /**< List of @ref TBI_timer_manager_t elements. */

/*== Definitions */
static void *__TBI_timer_manager_mainthread(void *param); 
static int __TBI_pred_find_timer_by_id(const TBI_list_item_t *item, const void *id);
static void __TBI_timer_manager_raise(TBI_timer_t *timer);
static void *run(void* self);

/**@ingroup TBI_timer_group
*/
TBI_timer_manager_handle_t* TBI_timer_manager_create()
{
	return TBI_object_new(TBI_timer_manager_def_t);
}

/**@ingroup TBI_timer_group
* Starts the timer manager.
*/
int TBI_timer_manager_start(TBI_timer_manager_handle_t *self)
{
	int err = -1;
	TBI_timer_manager_t *manager = self;
	
	TBI_DEBUG_INFO("TBI_timer_manager_start");

	if(!manager){
		return -1;
	}

	TBI_mutex_lock(manager->mutex);

	if(!TBI_RUNNABLE(manager)->running && !TBI_RUNNABLE(manager)->started){				
		TBI_RUNNABLE(manager)->run = run;
		if((err = TBI_runnable_start(TBI_RUNNABLE(manager), TBI_timer_def_t))){
			//TBI_OBJECT_SAFE_FREE(manager);
			goto bail;
		}
	}
	else{
		TBI_DEBUG_WARN("Timer manager already running");
	}

bail:
	TBI_mutex_unlock(manager->mutex);

	return err;
}

#if defined(DEBUG) || defined(_DEBUG) || !defined(NDEBUG)
/**@ingroup TBI_timer_group
*/
void TBI_timer_manager_debug(TBI_timer_manager_handle_t *self)
{
	TBI_timer_manager_t *manager = self;
	if(manager){
		//int index = 0;
		TBI_list_item_t *item = TBI_null;

		TBI_mutex_lock(manager->mutex);
		
		TBI_list_foreach(item, manager->timers){
			TBI_timer_t* timer = item->data;
			TBI_DEBUG_INFO("timer [%llu]- %llu, %llu", timer->id, timer->timeout, TBI_time_now());
		}

		TBI_mutex_unlock(manager->mutex);
	}
}
#endif

/**@ingroup TBI_timer_group
*/
int TBI_timer_manager_stop(TBI_timer_manager_handle_t *self)
{
	int ret = -1;
	TBI_timer_manager_t *manager = self;

	if(!manager){
		TBI_DEBUG_ERROR("Invalid paramater");
		return -1;
	}

	// all functions called below are thread-safe ==> do not lock
	// "mainthread" uses manager->mutex and runs in a separate thread ==> deadlock

	if(TBI_RUNNABLE(manager)->running){
		if((ret = TBI_runnable_stop(TBI_RUNNABLE(manager)))){
			goto bail;
		}
		
		TBI_semaphore_increment(manager->sem);
		TBI_condwait_signal(manager->condwait);
		
		ret = TBI_thread_join(manager->mainThreadId);
		goto bail;
	}
	else{
		ret = 0; /* already running. */
		goto bail;
	}

bail:
	return ret;
}

/**@ingroup TBI_timer_group
*/
TBI_timer_id_t TBI_timer_manager_schedule(TBI_timer_manager_handle_t *self, uint64_t timeout, TBI_timer_callback_f callback, const void *arg)
{
	TBI_timer_id_t timer_id = TBI_INVALID_TIMER_ID;
	TBI_timer_manager_t *manager = self;

	if(manager && (TBI_RUNNABLE(manager)->running || TBI_RUNNABLE(manager)->started)){
		TBI_timer_t *timer;

		timer = TBI_TIMER_CREATE(timeout, callback, arg);
		timer_id = timer->id;
		TBI_mutex_lock(manager->mutex);
		TBI_list_push_ascending_data(manager->timers, ((void**) &timer));
		TBI_mutex_unlock(manager->mutex);
		
		//TBI_timer_manager_debug(self);

		TBI_condwait_signal(manager->condwait);
		TBI_semaphore_increment(manager->sem);
	}

	return timer_id;
}

/**@ingroup TBI_timer_group
*/
int TBI_timer_manager_cancel(TBI_timer_manager_handle_t *self, TBI_timer_id_t id)
{
	int ret = -1;
	TBI_timer_manager_t *manager = self;

	/* Check validity. */
	if(!TBI_TIMER_ID_IS_VALID(id)){ /* Very common. */
		return 0;
	}

	if(!TBI_LIST_IS_EMPTY(manager->timers) && TBI_RUNNABLE(manager)->running){
		const TBI_list_item_t *item;
		TBI_mutex_lock(manager->mutex);
		item = TBI_list_find_item_by_pred(manager->timers, __TBI_pred_find_timer_by_id, &id);
		if(item && item->data){
			TBI_timer_t *timer = item->data;
			timer->canceled = 1;
			
			if(item == manager->timers->head){
				/* The timer we are waiting on ? ==> remove it now. */
				TBI_condwait_signal(manager->condwait);
			}
			
			ret = 0;
		}
		TBI_mutex_unlock(manager->mutex);
	}
	return ret;
}

int TBI_timer_manager_destroy(TBI_timer_manager_handle_t **self)
{
	if(!self || !*self){
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	TBI_OBJECT_SAFE_FREE(*self);
	return 0;
}

static void *run(void* self)
{
	int ret;
	TBI_list_item_t *curr;
	TBI_timer_manager_t *manager = self;

	TBI_RUNNABLE(manager)->running = TBI_true; // VERY IMPORTANT --> needed by the main thread

	/* create main thread */
	if((ret = TBI_thread_create(&(manager->mainThreadId[0]), __TBI_timer_manager_mainthread, manager))){
		TBI_DEBUG_FATAL("Failed to create mainthread: %d\n", ret);
		return TBI_null;
	}

	TBI_DEBUG_INFO("Timer manager run()::enter");

	TBI_RUNNABLE_RUN_BEGIN(manager);

	if((curr = TBI_RUNNABLE_POP_FIRST_SAFE(TBI_RUNNABLE(manager)))){
		TBI_timer_t *timer = (TBI_timer_t *)curr->data;
		if(timer->callback){
			timer->callback(timer->arg, timer->id);
		}
		TBI_object_unref(curr);
	}

	TBI_RUNNABLE_RUN_END(manager);

	TBI_DEBUG_INFO("Timer manager run()::exit");

	return TBI_null;
}

static int __TBI_pred_find_timer_by_id(const TBI_list_item_t *item, const void *id)
{
	TBI_timer_t *timer;
	if(item && item->data){
		timer = item->data;
		return (int)(timer->id - *((TBI_timer_id_t*)id));
	}
	return -1;
}

static void *__TBI_timer_manager_mainthread(void *param)
{
	int ret;
	TBI_timer_t *curr;
	uint64_t epoch;
	TBI_timer_manager_t *manager = param;

	TBI_DEBUG_INFO("TIMER MANAGER -- START");

	while(TBI_RUNNABLE(manager)->running){
		TBI_semaphore_decrement(manager->sem);

peek_first:
		if(!TBI_RUNNABLE(manager)->running){
			break;
		}

		TBI_mutex_lock(manager->mutex);
		curr = TBI_TIMER_GET_FIRST();
		TBI_mutex_unlock(manager->mutex);

		if(curr && !curr->canceled) {
			epoch = TBI_time_now();
			if(epoch >= curr->timeout){
				TBI_timer_t *timer = TBI_object_ref(curr);
				//TBI_DEBUG_INFO("Timer raise %llu", timer->id);

				TBI_mutex_lock(manager->mutex);
				TBI_RUNNABLE_ENQUEUE_OBJECT_SAFE(TBI_RUNNABLE(manager), timer);
				TBI_list_remove_item_by_data(manager->timers, curr);
				TBI_mutex_unlock(manager->mutex);
			}
			else{
				if((ret = TBI_condwait_timedwait(manager->condwait, (curr->timeout - epoch)))){
					TBI_DEBUG_ERROR("CONWAIT for timer manager failed [%d]", ret);
					break;
				}
				else{
					goto peek_first;
				}
			}
		}
		else if(curr){
			TBI_mutex_lock(manager->mutex);
			/* TBI_DEBUG_INFO("Timer canceled %llu", curr->id); */
			TBI_list_remove_item_by_data(manager->timers, curr);
			TBI_mutex_unlock(manager->mutex);
		}
	} /* while() */
	
	TBI_DEBUG_INFO("TIMER MANAGER -- STOP");

	return 0;
}





/* ================= Global Timer Manager ================= */

static TBI_timer_manager_t* __timer_mgr = TBI_null;
static int __timer_mgr_start_count = 0;

int TBI_timer_mgr_global_ref()
{
	if(!__timer_mgr){
		__timer_mgr = TBI_timer_manager_create();
	}
	else{
		__timer_mgr = TBI_object_ref(__timer_mgr);
	}
	return 0;
}

int TBI_timer_mgr_global_start()
{
	int ret = 0;
	if(!__timer_mgr){
		TBI_DEBUG_ERROR("No global Timer manager could be found");
		return -1;
	}
	if(!TBI_RUNNABLE(__timer_mgr)->running && !TBI_RUNNABLE(__timer_mgr)->started){
		if((ret = TBI_timer_manager_start(__timer_mgr))){
			return ret;
		}
	}
	__timer_mgr_start_count++;
	return ret;
}

TBI_timer_id_t TBI_timer_mgr_global_schedule(uint64_t timeout, TBI_timer_callback_f callback, const void *arg)
{
	if(!__timer_mgr){
		TBI_DEBUG_ERROR("No global Timer manager could be found");
		return TBI_INVALID_TIMER_ID;
	}
	return TBI_timer_manager_schedule(__timer_mgr, timeout, callback, arg);
}

int TBI_timer_mgr_global_cancel(TBI_timer_id_t id)
{
	if(!__timer_mgr){
		TBI_DEBUG_ERROR("No global Timer manager could be found");
		return -1;
	}
	return TBI_timer_manager_cancel(__timer_mgr, id);
}

int TBI_timer_mgr_global_stop()
{
	int ret = 0;
	if(!__timer_mgr){
		TBI_DEBUG_ERROR("No global Timer manager could be found");
		return -1;
	}

	if(__timer_mgr_start_count <= 0){
		TBI_DEBUG_ERROR("Global Timer is in an invalid state");
		return -2;
	}

	if(TBI_RUNNABLE(__timer_mgr)->running){
		if(__timer_mgr_start_count == 1){
			if((ret = TBI_timer_manager_stop(__timer_mgr))){
				return ret;
			}
		}
		__timer_mgr_start_count--;
	}
	return 0;
}

int TBI_timer_mgr_global_unref()
{
	if(!__timer_mgr){
		TBI_DEBUG_ERROR("No global Timer manager could be found");
		return -1;
	}

	__timer_mgr = TBI_object_unref(__timer_mgr);

	return 0;
}







//=================================================================================================
//	Timer manager object definition
//
static TBI_object_t* TBI_timer_manager_ctor(TBI_object_t * self, va_list * app)
{
	TBI_timer_manager_t *manager = self;
	if(manager){
		manager->timers = TBI_list_create();
		manager->sem = TBI_semaphore_create();
		manager->condwait = TBI_condwait_create();
		manager->mutex = TBI_mutex_create();
	}
	return self;
}

static TBI_object_t* TBI_timer_manager_dtor(TBI_object_t * self)
{ 
	TBI_timer_manager_t *manager = self;
	
	if(manager){
		TBI_timer_manager_stop(manager);

		TBI_semaphore_destroy(&manager->sem);
		TBI_condwait_destroy(&manager->condwait);
		TBI_mutex_destroy(&manager->mutex);
		TBI_object_unref(manager->timers);
	}

	return self;
}

static const TBI_object_def_t TBI_timer_manager_def_s = 
{
	sizeof(TBI_timer_manager_t),
	TBI_timer_manager_ctor, 
	TBI_timer_manager_dtor,
	TBI_null, 
};
const TBI_object_def_t * TBI_timer_manager_def_t = &TBI_timer_manager_def_s;






//=================================================================================================
//	Timer object definition
//
static TBI_object_t* TBI_timer_ctor(TBI_object_t * self, va_list * app)
{
	static TBI_timer_id_t TBI_unique_timer_id = 1;
	TBI_timer_t *timer = self;
	if(timer){
		timer->id = TBI_unique_timer_id++;
		timer->timeout = va_arg(*app, uint64_t);
		timer->callback = va_arg(*app, TBI_timer_callback_f);
		timer->arg = va_arg(*app, const void *);

		timer->timeout += TBI_time_now();
	}
	return self;
}

static TBI_object_t* TBI_timer_dtor(TBI_object_t * self)
{ 
	TBI_timer_t *timer = self;
	if(timer){
	}

	return self;
}

static int TBI_timer_cmp(const TBI_object_t *obj1, const TBI_object_t *obj2)
{
	const TBI_timer_t *t1 = obj1;
	const TBI_timer_t *t2 = obj2;

	if(t1 && t2){
		return (int)(t1->timeout - t2->timeout);
	}
	else if(!t1 && !t2) return 0;
	else return -1;
}

static const TBI_object_def_t TBI_timer_def_s = 
{
	sizeof(TBI_timer_t),
	TBI_timer_ctor, 
	TBI_timer_dtor,
	TBI_timer_cmp, 
};
const TBI_object_def_t * TBI_timer_def_t = &TBI_timer_def_s;


