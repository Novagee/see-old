 

/**@file TBI_safeobj.h
 * @brief Thread-Safe object.
 *

 *

 */
#ifndef _TINYTBI_SAFEOBJ_H_
#define _TINYTBI_SAFEOBJ_H_

#include "tinysak_config.h"
#include "TBI_mutex.h"

TBI_BEGIN_DECLS

//#define TBI_DECLARE_SAFEOBJ\
//	union{ \
//		TBI_mutex_handle_t *mutex; \
//	}

/**@ingroup TBI_safeobj_group
* Macro helper to declare an object as thread-safe.
*/
#define TBI_DECLARE_SAFEOBJ		TBI_mutex_handle_t *mutex

#define TBI_SAFEOBJ_MUTEX(safeobj) ((safeobj)->mutex)

/**@ingroup TBI_safeobj_group
* @def TBI_safeobj_init
* You MUST call this method before using @ref TBI_safeobj_lock or @ref TBI_safeobj_unlock to initilize the internal mutex.
* Before freeing your safeobject you MUST call @ref TBI_safeobj_deinit to deinitialize the internal mutex.
* @param safeobj The thread-safe object to initialize.
* @sa @ref TBI_safeobj_deinit.
*/
/**@ingroup TBI_safeobj_group
*@def TBI_safeobj_lock
* Locks a previously initialized safeobject.
* @param safeobj The thread-safe object to lock.
*/
/**@ingroup TBI_safeobj_group
*@def TBI_safeobj_unlock
* Unlocks a previously locked safeobject.
* @param safeobj The thread-safe object to unlock.
*/
/**@ingroup TBI_safeobj_group
*@def TBI_safeobj_deinit
* Deinitialize a previously initialize safeobject.
* @param safeobj The thread-safe object to deinitialize.
* @sa @ref TBI_safeobj_init.
*/
#define TBI_safeobj_init(safeobj)	TBI_SAFEOBJ_MUTEX(safeobj) = (TBI_SAFEOBJ_MUTEX(safeobj) ? TBI_SAFEOBJ_MUTEX(safeobj) : TBI_mutex_create())
#define TBI_safeobj_lock(safeobj)	TBI_mutex_lock(TBI_SAFEOBJ_MUTEX(safeobj))
#define TBI_safeobj_unlock(safeobj) TBI_mutex_unlock(TBI_SAFEOBJ_MUTEX(safeobj))
#define TBI_safeobj_deinit(safeobj)	TBI_mutex_destroy(&TBI_SAFEOBJ_MUTEX(safeobj))

TBI_END_DECLS

#endif /* _TINYTBI_SAFEOBJ_H_ */

