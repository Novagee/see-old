 

/**@file TBI_thread.h
 * @brief Utility functions for threading.
 *

 *

 */
#ifndef _TINYTBI_THREAD_H_
#define _TINYTBI_THREAD_H_

#include "tinysak_config.h"

TBI_BEGIN_DECLS

TINYSAK_API void TBI_thread_sleep(uint64_t ms);
TINYSAK_API int TBI_thread_create(void** tid, void *(*start) (void *), void *arg);
TINYSAK_API int TBI_thread_set_priority(void* tid, int32_t priority);
TINYSAK_API int TBI_thread_set_priority_2(int32_t priority);
TINYSAK_API int TBI_thread_join(void** tid);

TBI_END_DECLS

#endif


