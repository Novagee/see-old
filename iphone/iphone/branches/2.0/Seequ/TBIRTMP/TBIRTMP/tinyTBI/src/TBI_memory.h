 

/**@file TBI_memory.h
 * @brief Useful memory management functions to handle memory.
 *

 *

 */
#ifndef _TINYTBI_MEMORY_H_
#define _TINYTBI_MEMORY_H_

#include "tinysak_config.h"

#include <stdlib.h> /* TBI_size_t */

/**@ingroup TBI_memory_group
* @def TBI_SAFE_FREE
* Safely free the memory pointed by @a ptr.
*/
/**@ingroup TBI_memory_group
* @def TBI_FREE
* Safely free the memory pointed by @a ptr.
*/

TBI_BEGIN_DECLS

#define TBI_SAFE_FREE(ptr) (void)TBI_free((void**)(&ptr));
#define TBI_FREE(ptr) TBI_SAFE_FREE(ptr)

TINYSAK_API void* TBI_malloc(TBI_size_t size);
TINYSAK_API void* TBI_realloc (void * ptr, TBI_size_t size);
TINYSAK_API void TBI_free(void** ptr);
TINYSAK_API void* TBI_calloc(TBI_size_t num, TBI_size_t size);

TBI_END_DECLS

#endif /* _TINYTBI_MEMORY_H_ */

