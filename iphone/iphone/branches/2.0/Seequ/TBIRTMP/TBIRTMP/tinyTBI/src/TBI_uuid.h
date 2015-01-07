 

/**@file TBI_uuid.h
 * @brief Universally Unique Identifier (UUID version 5) implementation (RFC 4122).
 *		  This implementation is not fully conform to RFC 4122 but could be safely used to generate random UUIDs.
 *

 *

 */
#ifndef _TINYTBI_UUID_H_
#define _TINYTBI_UUID_H_

#include "tinysak_config.h"

TBI_BEGIN_DECLS

#define TBI_UUID_DIGEST_SIZE			16
#define TBI_UUID_STRING_SIZE			((TBI_UUID_DIGEST_SIZE*2)+4/*-*/)

typedef char TBI_uuidstring_t[TBI_UUID_STRING_SIZE+1]; /**< Hexadecimal UUID digest string. */
typedef char TBI_uuiddigest_t[TBI_UUID_DIGEST_SIZE]; /**< UUID digest bytes. */

TINYSAK_API int TBI_uuidgenerate(TBI_uuidstring_t *result);

TBI_END_DECLS

#endif /* _TINYTBI_UUID_H_ */
