 

/**@file TBI_md5.h
 * @brief Implements Message-Digest algorithm 5 (RFC 1321).
 *

 *

 */
#ifndef _TINYTBI_MD5_H_
#define _TINYTBI_MD5_H_

#include "tinysak_config.h"

TBI_BEGIN_DECLS

/**@ingroup TBI_md5_group
* @def TBI_MD5_DIGEST_SIZE
*/
/**@ingroup TBI_md5_group
* @def TBI_MD5_BLOCK_SIZE
*/
/**@ingroup TBI_md5_group
* @def TBI_MD5_EMPTY
*/
/**@ingroup TBI_md5_group
* @def TBI_MD5_STRING_SIZE
*/
/**@ingroup TBI_md5_group
* @def TBI_md5string_t
*/
/**@ingroup TBI_md5_group
* @def TBI_md5digest_t
*/
/**@ingroup TBI_MD5_DIGEST_CALC
* @def TBI_md5digest_t
*/


#define TBI_MD5_DIGEST_SIZE		16
#define TBI_MD5_BLOCK_SIZE		64

#define TBI_MD5_EMPTY			"d41d8cd98f00b204e9800998ecf8427e"

#define TBI_MD5_STRING_SIZE		(TBI_MD5_DIGEST_SIZE*2)
typedef char TBI_md5string_t[TBI_MD5_STRING_SIZE+1]; /**< Hexadecimal MD5 string. */
typedef uint8_t TBI_md5digest_t[TBI_MD5_DIGEST_SIZE]; /**< MD5 digest bytes. */

#define TBI_MD5_DIGEST_CALC(input, input_size, digest)		\
	{														\
		TBI_md5context_t ctx;								\
		TBI_md5init(&ctx);									\
		TBI_md5update(&ctx, (const uint8_t*)(input), (input_size));			\
		TBI_md5final((digest), &ctx);						\
	}

typedef struct TBI_md5context_s
{
	uint32_t buf[4];
	uint32_t bytes[2];
	uint32_t in[16];
}
TBI_md5context_t;

TINYSAK_API void TBI_md5init(TBI_md5context_t *context);
TINYSAK_API void TBI_md5update(TBI_md5context_t *context, uint8_t const *buf, TBI_size_t len);
TINYSAK_API void TBI_md5final(TBI_md5digest_t digest, TBI_md5context_t *context);
TINYSAK_API void TBI_md5transform(uint32_t buf[4], uint32_t const in[TBI_MD5_DIGEST_SIZE]);
TINYSAK_API int TBI_md5compute(const char* input, TBI_size_t size, TBI_md5string_t *result);

TBI_END_DECLS

#endif /* _TINYTBI_MD5_H_ */

