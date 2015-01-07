 

/**@file TBI_semaphore.h
 * @brief Pthread Semaphore.
 *

 *

 */
#ifndef _TINYTBI_SEMAPHORE_H_
#define _TINYTBI_SEMAPHORE_H_

#include "tinysak_config.h"

TBI_BEGIN_DECLS

typedef void TBI_semaphore_handle_t;

TINYSAK_API TBI_semaphore_handle_t* TBI_semaphore_create();
TINYSAK_API int TBI_semaphore_increment(TBI_semaphore_handle_t* handle);
TINYSAK_API int TBI_semaphore_decrement(TBI_semaphore_handle_t* handle);
TINYSAK_API void TBI_semaphore_destroy(TBI_semaphore_handle_t** handle);

TBI_END_DECLS

#endif /* _TINYTBI_SEMAPHORE_H_ */

