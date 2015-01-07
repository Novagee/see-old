 

/**@file TBI_mutex.h
 * @brief Pthread Mutex.
 *

 *

 */
#ifndef _TBI_UTILS_MUTEX_H_
#define _TBI_UTILS_MUTEX_H_

#include "tinysak_config.h"

TBI_BEGIN_DECLS

/**@ingroup TBI_mutex_group
* Mutex handle.
*/
typedef void TBI_mutex_handle_t;

TINYSAK_API TBI_mutex_handle_t* TBI_mutex_create();
TINYSAK_API TBI_mutex_handle_t* TBI_mutex_create_2(TBI_bool_t recursive);
TINYSAK_API int TBI_mutex_lock(TBI_mutex_handle_t* handle);
TINYSAK_API int TBI_mutex_unlock(TBI_mutex_handle_t* handle);
TINYSAK_API void TBI_mutex_destroy(TBI_mutex_handle_t** handle);

TBI_END_DECLS

#endif /* _TBI_UTILS_MUTEX_H_ */

