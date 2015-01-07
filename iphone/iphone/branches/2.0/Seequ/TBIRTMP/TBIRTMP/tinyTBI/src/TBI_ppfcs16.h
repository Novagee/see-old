 

/**@file TBI_ppfcs16.h
 * @brief PPP in HDLC-like Framing (RFC 1662).
 *

 *

 */
#ifndef _TINYTBI_PPFCS16_H_
#define _TINYTBI_PPFCS16_H_

#include "tinysak_config.h"

TBI_BEGIN_DECLS

#define TBI_PPPINITFCS16    0xffff  /* Initial FCS value */
#define TBI_PPPGOODFCS16    0xf0b8  /* Good final FCS value */

TINYSAK_API uint16_t TBI_pppfcs16(register uint16_t fcs, register const uint8_t* cp, register int32_t len);

TBI_END_DECLS

#endif /* _TINYTBI_PPFCS16_H_ */

