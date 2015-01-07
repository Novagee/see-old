 

/**@file TBI_buffer.h
 * @brief Buffer manager.
 *

 *

 */
#ifndef _TINYTBI_BUFFER_H_
#define _TINYTBI_BUFFER_H_

#include "tinysak_config.h"
#include "TBI_list.h"

/**@ingroup TBI_buffer_group
* @def TBI_BUFFER
* Converts to @ref TBI_buffer_t object.
* @param self @ref TBI_buffer_t object.
*/
/**@ingroup TBI_buffer_group
* @def TBI_BUFFER_DATA
* Gets the internal buffer.
* @param self @ref TBI_buffer_t object.
*/
/**@ingroup TBI_buffer_group
* @def TBI_BUFFER_SIZE
* Gets the size of the internal buffer.
* @param self @ref TBI_buffer_t object.
*/

TBI_BEGIN_DECLS


#define TBI_BUFFER(self)					((TBI_buffer_t*)self)
#define TBI_BUFFER_DATA(self)				(self ? TBI_BUFFER(self)->data : TBI_null)
#define TBI_BUFFER_SIZE(self)				(self ? TBI_BUFFER(self)->size : 0)

/**@ingroup TBI_buffer_group
* @def TBI_BUFFER_TO_STRING
* Gets a the internal buffer as a pointer to a string (const char*).
* @param self @ref TBI_buffer_t object.
*/
/**@ingroup TBI_buffer_group
* @def TBI_BUFFER_TO_U8
* Gets a the internal buffer as a pointer to an unsigned string (uint8_t*).
* @param self @ref TBI_buffer_t object.
*/
#define TBI_BUFFER_TO_STRING(self)			(self ? (const char*)TBI_BUFFER_DATA(self) : TBI_null)
#define TBI_BUFFER_TO_U8(self)				(self ? (uint8_t*)TBI_BUFFER_DATA(self) : TBI_null)

/**@ingroup TBI_buffer_group
* Buffer object.
*/
typedef struct TBI_buffer_s
{
	TBI_DECLARE_OBJECT;

	void *data; /**< Interanl data. */
	TBI_size_t size; /**< The size of the internal data. */
}
TBI_buffer_t;

typedef TBI_list_t TBI_buffers_L_t; /**<@ingroup TBI_buffer_group List of @ref TBI_buffer_t elements. */

TINYSAK_API TBI_buffer_t* TBI_buffer_create(const void* data, TBI_size_t size);
TINYSAK_API TBI_buffer_t* TBI_buffer_create_null();

TINYSAK_API int TBI_buffer_append_2(TBI_buffer_t* self, const char* format, ...);
TINYSAK_API int TBI_buffer_append(TBI_buffer_t* self, const void* data, TBI_size_t size);
TINYSAK_API int TBI_buffer_realloc(TBI_buffer_t* self, TBI_size_t size);
TINYSAK_API int TBI_buffer_remove(TBI_buffer_t* self, TBI_size_t position, TBI_size_t size);
TINYSAK_API int TBI_buffer_insert(TBI_buffer_t* self, TBI_size_t position, const void*data, TBI_size_t size);
TINYSAK_API int TBI_buffer_copy(TBI_buffer_t* self, TBI_size_t start, const void* data, TBI_size_t size);
TINYSAK_API int TBI_buffer_cleanup(TBI_buffer_t* self);
TINYSAK_API int TBI_buffer_takeownership(TBI_buffer_t* self, void** data, TBI_size_t size);

TINYSAK_GEXTERN const TBI_object_def_t *TBI_buffer_def_t;

TBI_END_DECLS

#endif /* _TINYTBI_BUFFER_H_ */

