 

/**@file TBI_condwait.h
 * @brief Pthread CondWait
 *

 *

 */
#ifndef _TINYTBI_CONDWAIT_H_
#define _TINYTBI_CONDWAIT_H_

#include "tinysak_config.h"
#include "TBI_mutex.h"

TBI_BEGIN_DECLS

/**@ingroup TBI_condwait_group
*	An opaque handle to a condwait object.
*/
typedef void TBI_condwait_handle_t;

TINYSAK_API TBI_condwait_handle_t* TBI_condwait_create();
TINYSAK_API int TBI_condwait_wait(TBI_condwait_handle_t* handle);
TINYSAK_API int TBI_condwait_timedwait(TBI_condwait_handle_t* handle, uint64_t ms);
TINYSAK_API int TBI_condwait_signal(TBI_condwait_handle_t* handle);
TINYSAK_API int TBI_condwait_broadcast(TBI_condwait_handle_t* handle);
TINYSAK_API void TBI_condwait_destroy(TBI_condwait_handle_t** handle);

TBI_END_DECLS

#endif /* _TINYTBI_CONDWAIT_H_ */

