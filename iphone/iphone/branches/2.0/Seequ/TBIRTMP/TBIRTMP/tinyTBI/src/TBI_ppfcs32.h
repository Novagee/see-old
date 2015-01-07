 

/**@file TBI_ppfcs32.h
 * @brief PPP in HDLC-like Framing (RFC 1662).
 *

 *

 */
#ifndef _TINYTBI_PPFCS32_H_
#define _TINYTBI_PPFCS32_H_

#include "tinysak_config.h"

TBI_BEGIN_DECLS

#define TBI_PPPINITFCS32  0xffffffff   /* Initial FCS value */
#define TBI_PPPGOODFCS32  0xdebb20e3   /* Good final FCS value */

TINYSAK_API uint32_t TBI_pppfcs32(register uint32_t fcs, register const uint8_t* cp, register int32_t len);

TBI_END_DECLS

#endif /* _TINYTBI_PPFCS32_H_ */

