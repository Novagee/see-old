 

/**@file TBI_hmac.h
 * @brief HMAC: Keyed-Hashing for Message Authentication (RFC 2104) / FIPS-198-1.
 * HMAC-MD5 and HMAC-SHA-1 are also implemented.
 *

 *

 */
#ifndef _TINYTBI_HMAC_H_
#define _TINYTBI_HMAC_H_

#include "tinysak_config.h"

#include "TBI_sha1.h"
#include "TBI_md5.h"

TBI_BEGIN_DECLS

TINYSAK_API int hmac_md5_compute(const uint8_t* input, TBI_size_t input_size, const char* key, TBI_size_t key_size, TBI_md5string_t *result);
TINYSAK_API int hmac_md5digest_compute(const uint8_t* input, TBI_size_t input_size, const char* key, TBI_size_t key_size, TBI_md5digest_t result);

TINYSAK_API int hmac_sha1_compute(const uint8_t* input, TBI_size_t input_size, const char* key, TBI_size_t key_size, TBI_sha1string_t *result);
TINYSAK_API int hmac_sha1digest_compute(const uint8_t* input, TBI_size_t input_size, const char* key, TBI_size_t key_size, TBI_sha1digest_t result);

TBI_END_DECLS

#endif /* _TINYTBI_HMAC_H_ */
