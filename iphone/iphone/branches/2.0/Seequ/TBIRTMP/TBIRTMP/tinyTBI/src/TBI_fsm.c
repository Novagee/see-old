 

/**@file TBI_fsm.c
 * @brief Finite-state machine (FSM) implementation.
 * @sa http://en.wikipedia.org/wiki/Finite-state_machine.
 *

 *

 */
#include "TBI_fsm.h"
#include "TBI_memory.h"
#include "TBI_debug.h"

/**@defgroup TBI_fsm_group Finite-state machine (FSM) implementation.
*/

int TBI_fsm_exec_nothing(va_list *app){ return 0/*success*/; }
TBI_bool_t TBI_fsm_cond_always(const void* data1, const void* data2) { return TBI_true; }

/**@ingroup TBI_fsm_group
*/
TBI_fsm_t* TBI_fsm_create(TBI_fsm_state_id state_curr, TBI_fsm_state_id state_term)
{
	return TBI_object_new(TBI_fsm_def_t, state_curr, state_term);
}

/**@ingroup TBI_fsm_group
*/
TBI_fsm_entry_t* TBI_fsm_entry_create()
{
	return TBI_object_new(TBI_fsm_entry_def_t);
}

/**@ingroup TBI_fsm_group
* Add entries (states) to the FSM.
* @param self The FSM.
* @param ... One of these  helper macros: @b TBI_FSM_ADD_*. MUST end with 
* @b TBI_FSM_ADD_NULL.
* @retval Zero if succeed and non-zero error code otherwise.
*/
int TBI_fsm_set(TBI_fsm_t* self, ...)
{
	va_list args;
	int guard;
	
	if(!self){
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	
	va_start(args, self);
	while((guard = va_arg(args, int))){
		TBI_fsm_entry_t* entry;
		if((entry = TBI_fsm_entry_create())){
			entry->from = va_arg(args, TBI_fsm_state_id);
			entry->action = va_arg(args, TBI_fsm_action_id);
			entry->cond = va_arg(args, TBI_fsm_cond);
			entry->to = va_arg(args, TBI_fsm_state_id);
			entry->exec = va_arg(args, TBI_fsm_exec);
			entry->desc = va_arg(args, const char*);
			
			TBI_list_push_descending_data(self->entries, (void**)&entry);
		}
	}
	va_end(args);
	
	return 0;
}

/**@ingroup TBI_fsm_group
* Sets the @a callback function to call when the FSM enter in the final state.
* @param self The FSM.
* @param callback The callback function to call.
* @param callbackdata Opaque data (user-data) to pass to the callback function.
* @retval Zero if succeed and non-zero error code otherwise.
*/
int TBI_fsm_set_callback_terminated(TBI_fsm_t* self, TBI_fsm_onterminated_f callback, const void* callbackdata)
{
	if(self){
		self->callback_term = callback;
		self->callback_data = callbackdata;
		return 0;
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
}

/**@ingroup TBI_fsm_group
* Execute an @a action. This action will probably change the current state of the FSM.
* @param self The FSM.
* @param action The id of the action to execute.
* @param cond_data1 The first opaque data to pass to the @a condition function.
* @param cond_data2 The first opaque data to pass to the @a condition function.
* @param ... Variable parameters to pass to the @a exec function.
* @retval Zero if succeed and non-zero error code otherwise.
*/
int TBI_fsm_act(TBI_fsm_t* self, TBI_fsm_action_id action, const void* cond_data1, const void* cond_data2, ...)
{
	TBI_list_item_t *item;
	va_list ap;
	TBI_bool_t found = TBI_false;
	TBI_bool_t terminates = TBI_false; /* thread-safeness -> DO NOT REMOVE THIS VARIABLE */
	int ret_exec = 0; /* success */
	
	if(!self){
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	if(TBI_fsm_terminated(self)){
		TBI_DEBUG_WARN("The FSM is in the final state.");
		return -2;
	}
	
	// lock
	TBI_safeobj_lock(self);
	
	va_start(ap, cond_data2);
	TBI_list_foreach(item, self->entries)
	{
		TBI_fsm_entry_t* entry = item->data;
		if((entry->from != TBI_fsm_state_any) && (entry->from != self->current)){
			continue;
		}

		if((entry->action != TBI_fsm_action_any) && (entry->action != action)){
			continue;
		}
		
		// check condition
		if(entry->cond(cond_data1, cond_data2)){
			// For debug information
			if(self->debug){
				TBI_DEBUG_INFO("State machine: %s", entry->desc);
			}
			
			if(entry->to != TBI_fsm_action_any){ /* Stay at the current state if dest. state is Any */
				self->current = entry->to;
			}
			
			if(entry->exec){
				if((ret_exec = entry->exec(&ap))){
					TBI_DEBUG_INFO("State machine: Exec function failed. Moving to terminal state.");
				}
			}
			else{ /* Nothing to execute */
				ret_exec = 0;
			}
			
			terminates = (ret_exec || (self->current == self->term));
			found = TBI_true;
			break;
		}
	}
	va_end(ap);
	
	// unlock
	TBI_safeobj_unlock(self);

	/* Only call the callback function after unlock. */
	if(terminates){
		self->current = self->term;
		if(self->callback_term){
			self->callback_term(self->callback_data);
		}
	}
	if(!found){
		TBI_DEBUG_WARN("State machine: No matching state found.");
	}
	
	return ret_exec;
}

TBI_bool_t TBI_fsm_terminated(TBI_fsm_t* self)
{
	if(self){
		return (self->current == self->term);
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
		return TBI_true;
	}
}


//=================================================================================================
//	fsm object definition
//
static TBI_object_t* TBI_fsm_ctor(TBI_object_t * self, va_list * app)
{
	TBI_fsm_t *fsm = self;
	if(fsm){
		fsm->current = va_arg(*app, TBI_fsm_state_id);
		fsm->term = va_arg(*app, TBI_fsm_state_id);

		fsm->entries = TBI_list_create();

#if defined(DEBUG) || defined(_DEBUG)
		fsm->debug = 1; /* default value, could be changed at any time */
#endif
		TBI_safeobj_init(fsm);
	}

	return self;
}

static TBI_object_t* TBI_fsm_dtor(TBI_object_t * self)
{ 
	TBI_fsm_t *fsm = self;
	if(fsm){
		/* If not in the terminal state ==>do it */
		/*if(fsm->current != fsm->term){
			TBI_safeobj_lock(fsm);
			if(fsm->callback_term){
				fsm->callback_term(fsm->callback_data);
			}
			TBI_safeobj_unlock(fsm);
		}*/
		TBI_safeobj_deinit(fsm);

		TBI_OBJECT_SAFE_FREE(fsm->entries);
	}

	return self;
}

static const TBI_object_def_t TBI_fsm_def_s = 
{
	sizeof(TBI_fsm_t),
	TBI_fsm_ctor, 
	TBI_fsm_dtor,
	TBI_null, 
};
const TBI_object_def_t *TBI_fsm_def_t = &TBI_fsm_def_s;

//=================================================================================================
//	fsm entry object definition
//
static TBI_object_t* TBI_fsm_entry_ctor(TBI_object_t * self, va_list * app)
{
	TBI_fsm_entry_t *fsm_entry = self;
	if(fsm_entry){
	}

	return self;
}

static TBI_object_t* TBI_fsm_entry_dtor(TBI_object_t * self)
{ 
	TBI_fsm_entry_t *fsm_entry = self;
	if(fsm_entry){
		/* desc is "const char*" => should not be deleted */
		/* TBI_FREE(fsm_entry->desc); */
	}

	return self;
}
static int TBI_fsm_entry_cmp(const TBI_object_t *_entry1, const TBI_object_t *_entry2)
{
	const TBI_fsm_entry_t* entry1 = _entry1;
	const TBI_fsm_entry_t* entry2 = _entry2;
	if(entry1 && entry2){
		/* Put "Any" states at the bottom. (Strong)*/
		if(entry1->from == TBI_fsm_state_any){
			return -20;
		}
		else if(entry2->from == TBI_fsm_state_any){
			return +20;
		}

		/* Put "Any" actions at the bottom. (Weak)*/
		if(entry1->action == TBI_fsm_action_any){
			return -10;
		}
		else if(entry1->action == TBI_fsm_action_any){
			return +10;
		}
	}
	return 0;
}

static const TBI_object_def_t TBI_fsm_entry_def_s = 
{
	sizeof(TBI_fsm_entry_t),
	TBI_fsm_entry_ctor, 
	TBI_fsm_entry_dtor,
	TBI_fsm_entry_cmp, 
};
const TBI_object_def_t *TBI_fsm_entry_def_t = &TBI_fsm_entry_def_s;
