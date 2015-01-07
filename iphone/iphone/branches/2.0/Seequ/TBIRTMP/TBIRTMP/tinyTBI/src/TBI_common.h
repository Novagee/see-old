 

/**@file TBI_common.h
 * Commons.
 *

 *

 */

#ifndef _TINYTBI_COMMON_H_
#define _TINYTBI_COMMON_H_

typedef int TBI_boolean_t;
#define TBI_bool_t TBI_boolean_t

/**@def TBI_true
* True (1).
*/
/**@def TBI_false
* False (0).
*/
#define TBI_true	1
#define TBI_false	0

#define TBI_MIN(a,b)            (((a) < (b)) ? (a) : (b))
#define TBI_MAX(a,b)            (((a) > (b)) ? (a) : (b))
#define TBI_ABS(a)				(((a)< 0) ? -(a) : (a))
#define TBI_CLAMP(nMin, nVal, nMax)		((nVal) > (nMax)) ? (nMax) : (((nVal) < (nMin)) ? (nMin) : (nVal))
// used to avoid doing *((uint32_t*)ptr) which don't respect memory alignment on
// some embedded (ARM,?...) platforms
#define TBI_TO_UINT32(u8_ptr) (((uint32_t)(u8_ptr)[0]) | ((uint32_t)(u8_ptr)[1])<<8 | ((uint32_t)(u8_ptr)[2])<<16 | ((uint32_t)(u8_ptr)[3])<<24)
#define TBI_TO_INT32(u8_ptr) (((int32_t)(u8_ptr)[0]) | ((int32_t)(u8_ptr)[1])<<8 | ((int32_t)(u8_ptr)[2])<<16 | ((int32_t)(u8_ptr)[3])<<24)
#define TBI_TO_UINT16(u8_ptr) (((uint16_t)(u8_ptr)[0]) | ((uint16_t)(u8_ptr)[1])<<8)

typedef int TBI_ssize_t; /**< Signed size */
typedef unsigned int TBI_size_t; /**< Unsigned size */

#if !defined(va_copy)
#	define TBI_va_copy(D, S)       ((D) = (S))
#else
#	define TBI_va_copy(D, S)       va_copy((D), (S))
#endif

#ifdef NULL
#define TBI_null    NULL /**< Null pointer */
#else
#define TBI_null    0  /**< Null pointer */
#endif

#endif /* _TINYTBI_COMMON_H_ */
