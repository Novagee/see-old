 

/**@file TBI_time.h
 * @brief Datetime functions.
 *

 *

 */
#ifndef _TINYTBI_TIME_H_
#define _TINYTBI_TIME_H_

#include "tinysak_config.h"

TBI_BEGIN_DECLS

//#if defined(__SYMBIAN32__) || ANDROID /* Forward declaration */
struct timeval;
struct timezone;
struct timespec;
//#endif

/**@ingroup TBI_time_group
*/
#define TBI_TIME_S_2_MS(S) ((S)*1000)
#define TBI_TIME_MS_2_S(MS) ((MS)/1000)

TINYSAK_API int TBI_gettimeofday(struct timeval *tv, struct timezone *tz);
TINYSAK_API uint64_t TBI_time_get_ms(struct timeval *tv);
TINYSAK_API uint64_t TBI_time_epoch();
TINYSAK_API uint64_t TBI_time_now();


TBI_END_DECLS

#endif /* _TINYTBI_TIME_H_ */

