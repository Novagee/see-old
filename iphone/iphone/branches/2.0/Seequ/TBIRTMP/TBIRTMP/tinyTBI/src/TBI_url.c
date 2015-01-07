 

/**@file TBI_url.c
 * @brief Utility functions to encode/decode urls.
 *

 *

 */
#include "TBI_url.h"
#include "TBI_memory.h"
#include "TBI_string.h"

#include <ctype.h>
#include <string.h>

/**@defgroup TBI_url_group Utility functions to encode/decode urls.
*/


/**@ingroup TBI_url_group
* Encode an url.
* @param url The url to encode
* @retval The encoded url. It is up to you to free the returned string.
*
* @sa TBI_url_decode
*
*/
char* TBI_url_encode(const char* url) {
    if(!url)
        return 0;
    
	char *purl = (char*)url, *buf = TBI_malloc(TBI_strlen(url) * 3 + 1), *pbuf = buf;
	while (*purl) {
		if (isalnum(*purl) || *purl == '-' || *purl == '_' || *purl == '.' || *purl == '~'){
			*pbuf++ = *purl;
		}
		else if (*purl == ' '){
			*pbuf++ = '+';
		}
		else{
			*pbuf++ = '%', *pbuf++ = TBI_b10tob16(*purl >> 4), *pbuf++ = TBI_b10tob16(*purl & 15);
		}
		purl++;
	}
	*pbuf = '\0';
	return buf;
}

/**@ingroup TBI_url_group
* Decode an url.
* @param url The url to encode
* @retval The decoded url. It is up to you to free the returned string.
*
* @sa TBI_url_encode
*/
char* TBI_url_decode(const char* url) {
	char *purl = (char*)url, *buf = TBI_malloc(TBI_strlen(url) + 1), *pbuf = buf;
	while (*purl) {
		if (*purl == '%') {
			if (purl[1] && purl[2]) {
				*pbuf++ = TBI_b16tob10(purl[1]) << 4 | TBI_b16tob10(purl[2]);
				purl += 2;
			}
		} else if (*purl == '+') { 
			*pbuf++ = ' ';
		} else {
			*pbuf++ = *purl;
		}
		purl++;
	}
	*pbuf = '\0';
	return buf;
}

