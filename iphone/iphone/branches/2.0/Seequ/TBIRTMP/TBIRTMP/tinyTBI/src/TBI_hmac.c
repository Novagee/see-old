 

/**@file TBI_hmac.c
 * @brief HMAC: Keyed-Hashing for Message Authentication (RFC 2104) / FIPS-198-1.
 *

 *

 */
#include "TBI_hmac.h"

#include "TBI_string.h"
#include "TBI_buffer.h"

#include <string.h>

/**@defgroup TBI_hmac_group Keyed-Hashing for Message Authentication (RFC 2104/ FIPS-198-1).
*/

/**@ingroup TBI_hmac_group
*/
typedef enum TBI_hash_type_e { md5, sha1 } TBI_hash_type_t;

int TBI_hmac_xxxcompute(const uint8_t* input, TBI_size_t input_size, const char* key, TBI_size_t key_size, TBI_hash_type_t type, uint8_t* digest)
{
#define TBI_MAX_BLOCK_SIZE	TBI_SHA1_BLOCK_SIZE

	TBI_size_t i, newkey_size;

	TBI_size_t block_size = type == md5 ? TBI_MD5_BLOCK_SIZE : TBI_SHA1_BLOCK_SIZE; // Only SHA-1 and MD5 are supported for now
	TBI_size_t digest_size = type == md5 ? TBI_MD5_DIGEST_SIZE : TBI_SHA1_DIGEST_SIZE;
	char hkey [TBI_MAX_BLOCK_SIZE];
	
	uint8_t ipad [TBI_MAX_BLOCK_SIZE];
	uint8_t opad [TBI_MAX_BLOCK_SIZE];
	

	memset(ipad, 0, sizeof(ipad));
	memset(opad, 0, sizeof(ipad));

	/*
	*	H(K XOR opad, H(K XOR ipad, input))
	*/

	// Check key len
	if (key_size > block_size){
		if(type == md5){
			TBI_MD5_DIGEST_CALC(key, key_size, (uint8_t*)hkey);
		}
		else if(type == sha1){
			TBI_SHA1_DIGEST_CALC((uint8_t*)key, key_size, hkey);
		}
		else return -3;
		
		newkey_size = digest_size;
	}
	else{
		memcpy(hkey, key, key_size);
		newkey_size = key_size;
	}

	memcpy(ipad, hkey, newkey_size);
	memcpy(opad, hkey, newkey_size);
	
	/* [K XOR ipad] and [K XOR opad]*/
	for (i=0; i<block_size; i++){
		ipad[i] ^= 0x36;
		opad[i] ^= 0x5c;
	}
	
	
	{
		TBI_buffer_t *passx; // pass1 or pass2
		int pass1_done = 0;
		
		passx = TBI_buffer_create(ipad, block_size); // pass1
		TBI_buffer_append(passx, input, input_size);

digest_compute:
		if(type == md5){
			TBI_MD5_DIGEST_CALC(TBI_BUFFER_TO_U8(passx), TBI_BUFFER_SIZE(passx), digest);
		}
		else{
			TBI_SHA1_DIGEST_CALC(TBI_BUFFER_TO_U8(passx), TBI_BUFFER_SIZE(passx), (char*)digest);
		}

		if(pass1_done){
			TBI_OBJECT_SAFE_FREE(passx);
			goto pass1_and_pass2_done;
		}
		else{
			pass1_done = 1;
		}

		TBI_buffer_cleanup(passx);
		TBI_buffer_append(passx, opad, block_size); // pass2
		TBI_buffer_append(passx, digest, digest_size);

		goto digest_compute;
	}

pass1_and_pass2_done:

	return 0;
}


/**@ingroup TBI_hmac_group
 *
 * Calculate HMAC-MD5 hash (hexa-string) as per RFC 2104.
 *
 * @author	Mamadou
 * @date	12/29/2009
 *
 * @param [in,out]	input	The input data.
 * @param	input_size		The size of the input. 
 * @param [in,out]	key		The input key. 
 * @param	key_size		The size of the input key. 
 * @param [out]	result		Pointer to the result.
 *
 * @return	Zero if succeed and non-zero error code otherwise. 
**/
int hmac_md5_compute(const uint8_t* input, TBI_size_t input_size, const char* key, TBI_size_t key_size, TBI_md5string_t *result)
{
	TBI_md5digest_t digest;
	int ret;

	if((ret = hmac_md5digest_compute(input, input_size, key, key_size, digest))){
		return ret;
	}
	TBI_str_from_hex(digest, TBI_MD5_DIGEST_SIZE, *result);
	(*result)[TBI_MD5_STRING_SIZE] = '\0';

	return 0;
}


/**@ingroup TBI_hmac_group
 *
 * Calculate HMAC-MD5 hash (bytes) as per RFC 2104. 
 *
 * @author	Mamadou
 * @date	12/29/2009
 *
 * @param [in,out]	input	The input data. 
 * @param	input_size		The Size of the input. 
 * @param [in,out]	key		The input key. 
 * @param	key_size		The size of the input key. 
 * @param	result			Pointer to the result. 
 *
 * @return	Zero if succeed and non-zero error code otherwise.
**/
int hmac_md5digest_compute(const uint8_t* input, TBI_size_t input_size, const char* key, TBI_size_t key_size, TBI_md5digest_t result)
{
	return TBI_hmac_xxxcompute(input, input_size, key, key_size, md5, result);
}

/**@ingroup TBI_hmac_group
 *
 * Calculate HMAC-SHA-1 hash (hexa-string) as per RFC 2104.
 *
 * @author	Mamadou
 * @date	12/29/2009
 *
 * @param [in,out]	input	The input data.  
 * @param	input_size		The Size of the input. 
 * @param [in,out]	key		The input key. 
 * @param	key_size		The size of the input key.
 * @param [out]	result		Pointer to the result.
 *
 * @return	Zero if succeed and non-zero error code otherwise.
**/
int hmac_sha1_compute(const uint8_t* input, TBI_size_t input_size, const char* key, TBI_size_t key_size, TBI_sha1string_t *result)
{
	TBI_sha1digest_t digest;
	int ret;

	if((ret = hmac_sha1digest_compute(input, input_size, key, key_size, digest))){
		return ret;
	}
	TBI_str_from_hex((uint8_t*)digest, TBI_SHA1_DIGEST_SIZE, *result);
	(*result)[TBI_SHA1_STRING_SIZE] = '\0';

	return 0;
}

/**@ingroup TBI_hmac_group
 *
 * Calculate HMAC-SHA-1 hash (bytes) as per RFC 2104.
 *
 * @author	Mamadou
 * @date	12/29/2009
 *
 * @param [in,out]	input	If non-null, the input. 
 * @param	input_size		The size of the input. 
 * @param [in,out]	key		The input key. 
 * @param	key_size		The size of the input key.
 * @param	result			Pointer to the result. 
 *
 * @return	Zero if succeed and non-zero error code otherwise. 
**/
int hmac_sha1digest_compute(const uint8_t* input, TBI_size_t input_size, const char* key, TBI_size_t key_size, TBI_sha1digest_t result)
{
	return TBI_hmac_xxxcompute(input, input_size, key, key_size, sha1, (uint8_t*)result);
}

