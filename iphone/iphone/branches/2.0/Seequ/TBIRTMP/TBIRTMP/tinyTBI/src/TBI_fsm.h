 

/**@file TBI_fsm.h
 * @brief Finite-state machine (FSM) implementation.
 * @sa http://en.wikipedia.org/wiki/Finite-state_machine.
 *

 *

 */
#ifndef _TINYTBI_FSM_H_
#define _TINYTBI_FSM_H_

#include "tinysak_config.h"
#include "TBI_list.h"
#include "TBI_safeobj.h"

/**@ingroup TBI_fsm_group
* @def TBI_FSM_ONTERMINATED
*/

TBI_BEGIN_DECLS

#define TBI_FSM_ONTERMINATED_F(self)				(TBI_fsm_onterminated_f)(self)

/**@ingroup TBI_fsm_group
* @def TBI_fsm_state_any
*/
/**@ingroup TBI_fsm_group
* @def TBI_fsm_state_default
*/
/**@ingroup TBI_fsm_group
* @def TBI_fsm_state_none
*/
/**@ingroup TBI_fsm_group
* @def TBI_fsm_state_final
*/
#define TBI_fsm_state_any -0xFFFF
#define TBI_fsm_state_default -0xFFF0
#define TBI_fsm_state_none -0xFF00
#define TBI_fsm_state_final -0xF000

/**@ingroup TBI_fsm_group
* @def TBI_fsm_action_any
*/
#define TBI_fsm_action_any -0xFFFF

/**@ingroup TBI_fsm_group
* @def TBI_fsm_state_id_t
*/
/**@ingroup TBI_fsm_group
* @def TBI_fsm_action_id_t
*/
/**@ingroup TBI_fsm_group
* @def TBI_fsm_cond
*/
/**@ingroup TBI_fsm_group
* @def TBI_fsm_exec
*/
/**@ingroup TBI_fsm_group
* @def TBI_fsm_onterminated
*/

typedef int TBI_fsm_state_id;
typedef int TBI_fsm_action_id;
typedef TBI_bool_t (*TBI_fsm_cond)(const void*, const void*);
typedef int (*TBI_fsm_exec)(va_list *app);
typedef int (*TBI_fsm_onterminated_f)(const void*);


/**@ingroup TBI_fsm_group
* @def TBI_FSM_ADD
*/
/**@ingroup TBI_fsm_group
* @def TBI_FSM_ADD_ALWAYS
*/
/**@ingroup TBI_fsm_group
* @def TBI_FSM_ADD_NOTHING
*/
/**@ingroup TBI_fsm_group
* @def TBI_FSM_ADD_ALWAYS_NOTHING
*/
/**@ingroup TBI_fsm_group
* @def TBI_FSM_ADD_DEFAULT
*/
/**@ingroup TBI_fsm_group
* @def TBI_FSM_ADD_NULL
*/
#define TBI_FSM_ADD(from, action, cond, to, exec, desc)\
	1,\
	(TBI_fsm_state_id)from, \
	(TBI_fsm_action_id)action, \
	(TBI_fsm_cond)cond, \
	(TBI_fsm_state_id)to, \
	(TBI_fsm_exec)exec, \
	(const char*)desc
#define TBI_FSM_ADD_ALWAYS(from, action, to, exec, desc) TBI_FSM_ADD(from, action, TBI_fsm_cond_always, to, exec, desc)
#define TBI_FSM_ADD_NOTHING(from, action, cond, desc) TBI_FSM_ADD(from, action, cond, from, TBI_fsm_exec_nothing, desc)
#define TBI_FSM_ADD_ALWAYS_NOTHING(from, desc)	TBI_FSM_ADD(from, TBI_fsm_action_any, TBI_fsm_cond_always, from, TBI_fsm_exec_nothing, desc)
#define TBI_FSM_ADD_DEFAULT()
#define TBI_FSM_ADD_NULL()\
	TBI_null

/**@ingroup TBI_fsm_group
* FSM entry.
*/
typedef struct TBI_fsm_entry_s
{
	TBI_DECLARE_OBJECT;

	TBI_fsm_state_id from;
	TBI_fsm_action_id action;
	TBI_fsm_cond cond;
	TBI_fsm_state_id to;
	TBI_fsm_exec exec;
	const char* desc;
}
TBI_fsm_entry_t;

/**@ingroup TBI_fsm_group
* List of @ref TBI_fsm_entry_t elements. 
*/
typedef TBI_list_t TBI_fsm_entries_L_t;

/**@ingroup TBI_fsm_group
* FSM.
*/
typedef struct TBI_fsm_s
{
	TBI_DECLARE_OBJECT;

	unsigned debug:1;
	TBI_fsm_state_id current;
	TBI_fsm_state_id term;
	TBI_fsm_entries_L_t* entries;

	TBI_fsm_onterminated_f callback_term;
	const void* callback_data;

	TBI_DECLARE_SAFEOBJ;
}
TBI_fsm_t;

TINYSAK_API TBI_fsm_t* TBI_fsm_create(TBI_fsm_state_id state_curr, TBI_fsm_state_id state_term);

TINYSAK_API int TBI_fsm_exec_nothing(va_list *app);
TINYSAK_API TBI_bool_t TBI_fsm_cond_always(const void*, const void*);
TINYSAK_API int TBI_fsm_set(TBI_fsm_t* self, ...);
TINYSAK_API int TBI_fsm_set_callback_terminated(TBI_fsm_t* self, TBI_fsm_onterminated_f callback, const void* callbackdata);
TINYSAK_API int TBI_fsm_act(TBI_fsm_t* self, TBI_fsm_action_id action, const void* cond_data1, const void* cond_data2, ...);
TINYSAK_API TBI_bool_t TBI_fsm_terminated(TBI_fsm_t* self);

TINYSAK_GEXTERN const TBI_object_def_t *TBI_fsm_def_t;
TINYSAK_GEXTERN const TBI_object_def_t *TBI_fsm_entry_def_t;

TBI_END_DECLS

#endif /* _TINYTBI_FSM_H_ */
