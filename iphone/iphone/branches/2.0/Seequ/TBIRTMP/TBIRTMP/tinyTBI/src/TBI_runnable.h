 

/**@file TBI_runnable.h
 * @brief Base class for runnable object.
 *

 *

 */
#ifndef _TINYTBI_RUNNABLE_H_
#define _TINYTBI_RUNNABLE_H_

#include "tinysak_config.h"

#include "TBI_object.h"
#include "TBI_semaphore.h"
#include "TBI_list.h"

TBI_BEGIN_DECLS

/**@ingroup TBI_runnable_group
*/
typedef void * (*TBI_runnable_func_run)(void* self);

/**@ingroup TBI_runnable_group
*/
#define TBI_RUNNABLE(self)	((TBI_runnable_t*)(self))

/**@ingroup TBI_runnable_group
* Runnable.
*/
typedef struct TBI_runnable_s
{
	TBI_DECLARE_OBJECT;
	
	const TBI_object_def_t *objdef;
	
	void* tid[1];
	TBI_runnable_func_run run;
	TBI_semaphore_handle_t *semaphore;
	
	TBI_bool_t running;
	TBI_bool_t started;
	TBI_bool_t initialized;
	/** whether the enqueued data are important or not. 
	* if yes, the thread will not be joined until all data in the queue have been consumed.
	* default value: TBI_false
	*/
	TBI_bool_t important;
	
	TBI_list_t *objects;
}
TBI_runnable_t;

/**@ingroup TBI_runnable_group
*/
#define TBI_DECLARE_RUNNABLE TBI_runnable_t __runnable__

TINYSAK_API TBI_runnable_t* TBI_runnable_create();

TINYSAK_API int TBI_runnable_start(TBI_runnable_t *self, const TBI_object_def_t *objdef);
TINYSAK_API int TBI_runnable_set_important(TBI_runnable_t *self, TBI_bool_t important);
TINYSAK_API int TBI_runnable_enqueue(TBI_runnable_t *self, ...);
TINYSAK_API int TBI_runnable_stop(TBI_runnable_t *self);

TINYSAK_GEXTERN const TBI_object_def_t *TBI_runnable_def_t;


/**@ingroup TBI_runnable_group
* @def TBI_RUNNABLE_RUN_BEGIN
*/
/**@ingroup TBI_runnable_group
* @def TBI_RUNNABLE_RUN_END
*/
#define TBI_RUNNABLE_RUN_BEGIN(self) \
	TBI_RUNNABLE(self)->running = TBI_true;	\
	for(;;) { \
		TBI_semaphore_decrement(TBI_RUNNABLE(self)->semaphore); \
		if(!TBI_RUNNABLE(self)->running &&  \
			(!TBI_RUNNABLE(self)->important || (TBI_RUNNABLE(self)->important && TBI_LIST_IS_EMPTY(TBI_RUNNABLE(self)->objects)))) \
			break;
		

#define TBI_RUNNABLE_RUN_END(self) \
	} \
	TBI_RUNNABLE(self)->running = TBI_false;

/**@ingroup TBI_runnable_group
* @def TBI_RUNNABLE_ENQUEUE
*/
/**@ingroup TBI_runnable_group
* @def TBI_RUNNABLE_ENQUEUE_OBJECT
*/
#define TBI_RUNNABLE_ENQUEUE(self, ...)												\
{																					\
	if((self) && TBI_RUNNABLE(self)->initialized){												\
		TBI_object_t *object = TBI_object_new(TBI_RUNNABLE(self)->objdef, ##__VA_ARGS__);		\
		TBI_list_push_back_data(TBI_RUNNABLE(self)->objects, (void**)&object);							\
		TBI_semaphore_increment(TBI_RUNNABLE(self)->semaphore);									\
	}																				\
	else{																			\
		TBI_DEBUG_WARN("Invalid/uninitialized runnable object.");					\
	}																				\
}

#define TBI_RUNNABLE_ENQUEUE_OBJECT(self, object)									\
{																					\
	if((self) && TBI_RUNNABLE(self)->initialized){									\
		TBI_list_push_back_data(TBI_RUNNABLE(self)->objects, (void**)&object);		\
		TBI_semaphore_increment(TBI_RUNNABLE(self)->semaphore);						\
	}																				\
	else{																			\
		TBI_DEBUG_WARN("Invalid/uninitialized runnable object.");					\
		TBI_OBJECT_SAFE_FREE(object);												\
	}																				\
}

#define TBI_RUNNABLE_ENQUEUE_OBJECT_SAFE(self, object)								\
{																					\
	if((self) && TBI_RUNNABLE(self)->initialized){									\
		TBI_list_lock(TBI_RUNNABLE(self)->objects);									\
		TBI_list_push_back_data(TBI_RUNNABLE(self)->objects, (void**)&object);		\
		TBI_list_unlock(TBI_RUNNABLE(self)->objects);								\
		TBI_semaphore_increment(TBI_RUNNABLE(self)->semaphore);						\
	}																				\
	else{																			\
		TBI_DEBUG_WARN("Invalid/uninitialized runnable object.");					\
		TBI_OBJECT_SAFE_FREE(object);												\
	}																				\
}

/**@ingroup TBI_runnable_group
*/
#define TBI_RUNNABLE_POP_FIRST(self) \
	TBI_list_pop_first_item(TBI_RUNNABLE(self)->objects)
static TBI_list_item_t* TBI_RUNNABLE_POP_FIRST_SAFE(TBI_runnable_t* self){
	TBI_list_item_t* item;
	TBI_list_lock(self->objects);
	item= TBI_list_pop_first_item(self->objects);
	TBI_list_unlock(self->objects);
	return item;
}

TBI_END_DECLS

#endif /* _TINYTBI_RUNNABLE_H_ */

