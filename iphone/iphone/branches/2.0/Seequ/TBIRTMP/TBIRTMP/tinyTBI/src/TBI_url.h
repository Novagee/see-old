 

/**@file TBI_url.h
 * @brief Useful string functions to manipulate strings.
 *

 *

 */
#ifndef _TINYTBI_URL_H_
#define _TINYTBI_URL_H_

#include "tinysak_config.h"

TBI_BEGIN_DECLS

TINYSAK_API char* TBI_url_encode(const char* url);
TINYSAK_API char* TBI_url_decode(const char* url);

TBI_END_DECLS

#endif /* _TINYTBI_URL_H_ */

