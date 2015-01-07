 

/**@file TBI_timer.h
 * @brief Timer Manager.
 *

 *

 */
#ifndef _TINYTBI_TIMER_H_
#define _TINYTBI_TIMER_H_

#include "tinysak_config.h"

#include "TBI_object.h"

TBI_BEGIN_DECLS


/**@ingroup TBI_timer_group
* @def TBI_TIMER_CALLBACK
*/
#define TBI_TIMER_CALLBACK_F(callback)				((TBI_timer_callback_f)callback)

/**@ingroup TBI_timer_group
* @def TBI_INVALID_TIMER_ID
*/
/**@ingroup TBI_timer_group
* @def TBI_TIMER_ID_IS_VALID
*/
#define TBI_INVALID_TIMER_ID						0
#define TBI_TIMER_ID_IS_VALID(id)					((id) != TBI_INVALID_TIMER_ID)

/**@ingroup TBI_timer_group
* @def TBI_timer_manager_handle_t
*/
/**@ingroup TBI_timer_group
* @def TBI_timer_id_t
*/
/**@ingroup TBI_timer_group
* @def TBI_timer_callback
*/
typedef void TBI_timer_manager_handle_t;
typedef uint64_t TBI_timer_id_t;
typedef int (*TBI_timer_callback_f)(const void* arg, TBI_timer_id_t timer_id);

TINYSAK_API TBI_timer_manager_handle_t* TBI_timer_manager_create();

TINYSAK_API int TBI_timer_manager_start(TBI_timer_manager_handle_t *self);
TINYSAK_API int TBI_timer_manager_stop(TBI_timer_manager_handle_t *self);
#if defined(DEBUG) || defined(_DEBUG)
TINYSAK_API void TBI_timer_manager_debug(TBI_timer_manager_handle_t *self);
#endif

TINYSAK_API TBI_timer_id_t TBI_timer_manager_schedule(TBI_timer_manager_handle_t *self, uint64_t timeout, TBI_timer_callback_f callback, const void *arg);
TINYSAK_API int TBI_timer_manager_cancel(TBI_timer_manager_handle_t *self, TBI_timer_id_t id);
TINYSAK_API int TBI_timer_manager_destroy(TBI_timer_manager_handle_t **self);


// Global Timer manager
TINYSAK_API int TBI_timer_mgr_global_ref();
TINYSAK_API int TBI_timer_mgr_global_start();
TINYSAK_API TBI_timer_id_t TBI_timer_mgr_global_schedule(uint64_t timeout, TBI_timer_callback_f callback, const void *arg);
TINYSAK_API int TBI_timer_mgr_global_cancel(TBI_timer_id_t id);
TINYSAK_API int TBI_timer_mgr_global_stop();
TINYSAK_API int TBI_timer_mgr_global_unref();


TINYSAK_GEXTERN const TBI_object_def_t *TBI_timer_def_t;
TINYSAK_GEXTERN const TBI_object_def_t *TBI_timer_manager_def_t;

TBI_END_DECLS

#endif /* _TINYTBI_TIMER_H_ */

