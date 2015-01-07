 

/**@file TBI_buffer.c
 * @brief Buffer manager.
 *

 *

 */
#include "TBI_buffer.h"

#include "TBI_memory.h"
#include "TBI_debug.h"

#if defined(_WIN32_WCE)
#	include "TBI_string.h" /* TBI_strlen() */
#endif


#include <stdio.h>
#include <string.h>

/**@defgroup TBI_buffer_group Buffer management.
*/

#if defined(_MSC_VER) || TBI_UNDER_WINDOWS
#	define vsnprintf	_vsnprintf
#endif

/**@ingroup TBI_buffer_group
* Creates new buffer.
* @param data A pointer to the data to copy into the newly created buffer.
* @param size The size of the data to copy.
* @retval A new buffer object.
* @sa @ref TBI_buffer_create_null
*/
TBI_buffer_t* TBI_buffer_create(const void* data, TBI_size_t size)
{
	return TBI_object_new(TBI_buffer_def_t, data, size);
}

/**@ingroup TBI_buffer_group
* Creates a new empty buffer.
* @retval A new empty buffer object.
* @sa TBI_buffer_create.
*/
TBI_buffer_t* TBI_buffer_create_null()
{
	return TBI_buffer_create(TBI_null, 0);
}

/**@ingroup TBI_buffer_group
* Appends new data to the buffer.
* @param self The buffer to append to. The buffer should be created using @ref TBI_buffer_create or @ref TBI_buffer_create_null.
* @param format A string with embedded tag to be substituted.
* @param ... List of parameters.
* @retval Zero if succeed and non-zero error code otherwise.
* @sa @ref TBI_buffer_append.
*
* @code
* TBI_buffer_t* buffer = TBI_buffer_create_null();
* TBI_buffer_append_2(buffer, "str1=%s, c1=%c and val1=%x", "str1", 'c', 0x2554);
* printf(TBI_BUFFER_TO_STRING(buffer));
* TBI_OBJECT_SAFE_FREE(buffer);
* @endcode
*/
int TBI_buffer_append_2(TBI_buffer_t* self, const char* format, ...)
{
	/*
	 * I suppose that sizeof(char) = 1-byte
	 */
	int len = 0;
	va_list ap;
	char *buffer;
	TBI_size_t oldsize;
    va_list ap2;

	if(!self){
		return -1;
	}

	oldsize = self->size;
	buffer = (char*)TBI_BUFFER_DATA(self);
	
	/* initialize variable arguments (needed for 64bit platforms where vsnprintf will change the va_list) */
	va_start(ap, format);
	va_start(ap2, format);
	
	/* compute destination len for windows mobile
	*/
#if defined(_WIN32_WCE)
	{
		int n;
		len = (TBI_strlen(format)*2);
		buffer = TBI_realloc(buffer, (oldsize+len));
		for(;;){
			if( (n = vsnprintf((char*)(buffer + oldsize), len, format, ap)) >= 0 && (n<=len) ){
				len = n;
				break;
			}
			else{
				len += 10;
				buffer = TBI_realloc(buffer, (oldsize+len));
			}
		}
	}
#else
    len = vsnprintf(TBI_null, 0, format, ap);
    buffer = TBI_realloc(buffer, oldsize+len+1);
    vsnprintf((buffer + oldsize), len
#if !defined(_MSC_VER) || defined(__GNUC__)
		+1
#endif
		, format, ap2);
#endif
	
	/* reset variable arguments */
	va_end(ap);
	va_end(ap2);

	self->data = buffer;
	self->size = (oldsize+len);
	
	return 0;
}

/**@ingroup TBI_buffer_group
* Appends data to the buffer.
* @param self The buffer to append to. The buffer should be created using @ref TBI_buffer_create or @ref TBI_buffer_create_null.
* @param data The data to append to the buffer.
* @param size The size of the @a data to append.
* @retval Zero if succeed and non-zero error code otherwise.
* @sa @ref TBI_buffer_append_2.
*
* @code
* TBI_buffer_t* buffer = TBI_buffer_create_null();
* TBI_buffer_append(buffer, "doubango", TBI_strlen("doubango"));
* printf(TBI_BUFFER_TO_STRING(buffer));
* TBI_OBJECT_SAFE_FREE(buffer);
* @endcode
*/
int TBI_buffer_append(TBI_buffer_t* self, const void* data, TBI_size_t size)
{
	if(self && data && size){
		TBI_size_t oldsize = self->size;
		TBI_size_t newsize = oldsize + size;
		
		if(oldsize){
			self->data = TBI_realloc(self->data, newsize);
		}
		else{
			self->data = TBI_calloc(size, sizeof(uint8_t));
		}

		if(self->data){
			memcpy((void*)(TBI_BUFFER_TO_U8(self) + oldsize), data, size);
			self->size = newsize;
			return 0;
		}
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
	}
	return -1;
}

/**@ingroup TBI_buffer_group
* Reallocates the buffer.
* @param self The buffer to realloc.
* @param size The new size.
* @retval Zero if succeed and non-zero error code otherwise.
*/
int TBI_buffer_realloc(TBI_buffer_t* self, TBI_size_t size)
{
	if(self)
	{
		if(size == 0){
			return TBI_buffer_cleanup(self);
		}

		if(self->size == 0){ // first time?
			self->data = TBI_calloc(size, sizeof(uint8_t));
		}
		else if(self->size != size){ // only realloc if different sizes
			self->data = TBI_realloc(self->data, size);
		}

		self->size = size;
		return 0;
	}
	return -1;
}

/**@ingroup TBI_buffer_group
* Removes a chunck of data from the buffer.
* @param self The buffer from which to remove the chunck.
* @param position The chunck start position.
* @param size The size of the chunck.
* @retval Zero if succeed and non-zero error code otherwise.
*/
int TBI_buffer_remove(TBI_buffer_t* self, TBI_size_t position, TBI_size_t size)
{
	if(self && self->data && size){
		if((position == 0) && ((position + size) >= self->size)){ /* Very common case. */
			return TBI_buffer_cleanup(self);
		}
		else if((position + size) < self->size){
			memcpy(((uint8_t*)self->data) + position, ((uint8_t*)self->data) + position + size, 
				self->size-(position+size));
			return TBI_buffer_realloc(self, (self->size-size));
		}
	}
	return -1;
}

/**@ingroup TBI_buffer_group
* Inserts a chunck of data into the buffer.
* @param self The buffer to insert to.
* @param position The starting position to insert to.
* @param data A pointer to the chunck to insert.
* @param size The size of the chunck.
* @retval Zero if succeed and non-zero error code otherwise.
*/
int TBI_buffer_insert(TBI_buffer_t* self, TBI_size_t position, const void* data, TBI_size_t size)
{
	if(self && size)
	{
		int ret;
		TBI_size_t tomove;

		if(position > self->size){
			TBI_DEBUG_ERROR("Invalid parameter");
			return -2;
		}

		tomove = (self->size - position);

		if((ret = TBI_buffer_realloc(self, (self->size + size)))){
			return ret;
		}
		memmove(((uint8_t*)self->data) + position + size, ((uint8_t*)self->data) + position,
			tomove/*self->size - (position + size)*/);
		

		if(data){
			memcpy(((uint8_t*)self->data) + position, data, size);
		}
		else{
			memset(((uint8_t*)self->data) + position, 0, size);
		}

		return 0;
	}
	return -1;
}

int TBI_buffer_copy(TBI_buffer_t* self, TBI_size_t start, const void* data, TBI_size_t size)
{
	int ret = 0;
	if(!self || !data || !size){
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	
	// realloc the buffer to match the overral size
	if((ret = TBI_buffer_realloc(self, (start + size)))){
		TBI_DEBUG_ERROR("failed to realloc the buffer");
		return ret;
	}

	memcpy(((uint8_t*)self->data) + start, data, size);
	return ret;
}

/**@ingroup TBI_buffer_group
* Cleanups the internal data and reset the size.
* @param self The buffer holding the internal data to free.
* @retval Zero if succeed and non-zero error code otherwise.
*/
int TBI_buffer_cleanup(TBI_buffer_t* self)
{
	if(self && self->data){
		TBI_free(&(self->data));
		self->size = 0;
	}
	return 0;
}

/**@ingroup TBI_buffer_group
* Takes the ownership of the @a data. If the destination buffer had data, then it will
* be cleaned up.
* @param self The buffer
* @param data
* @param size
* @retval Zero if succeed and non-zero error code otherwise.
*/
int TBI_buffer_takeownership(TBI_buffer_t* self, void** data, TBI_size_t size)
{
	if(!self || !data || !*data || !size){
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	if(self->data){
		TBI_free(&(self->data));
	}
	self->data = *data;
	self->size = size;
	*data = TBI_null;

	return 0;
}












//=================================================================================================
//	Buffer object definition
//
static TBI_object_t* TBI_buffer_ctor(TBI_object_t * self, va_list * app)
{
	TBI_buffer_t *buffer = self;
	const void *data = va_arg(*app, const void *);
	TBI_size_t size = va_arg(*app, TBI_size_t);
	
	if(data && size){
		buffer->data = TBI_calloc((size+1), sizeof(uint8_t));
		memcpy(buffer->data, data, size);
		buffer->size = size;
	}
	return self;
}

static TBI_object_t* TBI_buffer_dtor(TBI_object_t * self)
{ 
	TBI_buffer_t *buffer = self;
	if(buffer){
		TBI_FREE(buffer->data);
		buffer->size = 0;
	}

	return self;
}

static const TBI_object_def_t TBI_buffer_def_s = 
{
	sizeof(TBI_buffer_t),
	TBI_buffer_ctor, 
	TBI_buffer_dtor,
	TBI_null, 
};
const TBI_object_def_t *TBI_buffer_def_t = &TBI_buffer_def_s;

