 

/**@file TBI_sha1.h
 * @brief US Secure Hash Algorithm 1 (RFC 3174)
 *

 *

 */
#ifndef _TINYTBI_SHA1_H_
#define _TINYTBI_SHA1_H_

#include "tinysak_config.h"

TBI_BEGIN_DECLS

/**@ingroup TBI_sha1_group
* SHA-1 error codes.
*/
typedef enum TBI_sha1_errcode_e
{
    shaSuccess = 0,		/**< Success */
    shaNull,            /**< Null pointer parameter */
    shaInputTooLong,    /**< input data too long */
    shaStateError       /**< called Input after Result */
}
TBI_sha1_errcode_t;

/**@ingroup TBI_sha1_group
*@def TBI_SHA1_DIGEST_SIZE
*/
/**@ingroup TBI_sha1_group
*@def TBI_SHA1_BLOCK_SIZE
*/
/**@ingroup TBI_sha1_group
*@def TBI_SHA1_STRING_SIZE
*/
/**@ingroup TBI_sha1_group
*@def TBI_sha1string_t
* Hexadecimal SHA-1 digest string.
*/
/**@ingroup TBI_sha1_group
*@def TBI_sha1digest_t
* SHA-1 digest bytes.
*/

#define TBI_SHA1_DIGEST_SIZE			20
#define TBI_SHA1_BLOCK_SIZE				64

#define TBI_SHA1_STRING_SIZE		(TBI_SHA1_DIGEST_SIZE*2)
typedef char TBI_sha1string_t[TBI_SHA1_STRING_SIZE+1];
typedef char TBI_sha1digest_t[TBI_SHA1_DIGEST_SIZE]; /**< SHA-1 digest bytes. */

/**@ingroup TBI_sha1_group
* Computes SHA-1 digest.
* @param input The input data.
* @param input_size The size of the input data.
* @param digest @ref TBI_sha1digest_t object conaining the sha1 digest result.
* @sa @ref TBI_sha1compute.
*/
#define TBI_SHA1_DIGEST_CALC(input, input_size, digest)			\
			{													\
				TBI_sha1context_t ctx;							\
				TBI_sha1reset(&ctx);							\
				TBI_sha1input(&ctx, (input), (input_size));		\
				TBI_sha1result(&ctx, (digest));					\
			}

/**@ingroup TBI_sha1_group
 *  This structure will hold context information for the SHA-1
 *  hashing SSESSION
 */
typedef struct TBI_sha1context_s
{
    uint32_t Intermediate_Hash[TBI_SHA1_DIGEST_SIZE/4]; /* Message Digest  */

    uint32_t Length_Low;            /**< Message length in bits      */
    uint32_t Length_High;           /**< Message length in bits      */

                               
    int_least16_t Message_Block_Index;/**< Index into message block array   */
    uint8_t Message_Block[64];      /**< 512-bit message blocks      */

    int32_t Computed;               /**< Is the digest computed?         */
    int32_t Corrupted;             /**< Is the message digest corrupted? */
} 
TBI_sha1context_t;

/*
 *  Function Prototypes
 */

TINYSAK_API TBI_sha1_errcode_t TBI_sha1reset(TBI_sha1context_t *);
TINYSAK_API TBI_sha1_errcode_t TBI_sha1input(TBI_sha1context_t *, const uint8_t *, unsigned length);
TINYSAK_API TBI_sha1_errcode_t TBI_sha1result(TBI_sha1context_t *, TBI_sha1digest_t Message_Digest);
TINYSAK_API void TBI_sha1final(uint8_t *Message_Digest, TBI_sha1context_t *context);
TINYSAK_API TBI_sha1_errcode_t TBI_sha1compute(const char* input, TBI_size_t size, TBI_sha1string_t *result);

TBI_END_DECLS

#endif /* _TINYTBI_SHA1_H_ */

