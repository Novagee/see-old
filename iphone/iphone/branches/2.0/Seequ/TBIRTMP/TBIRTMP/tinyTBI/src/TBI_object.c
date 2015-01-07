 

/**@file TBI_object.c
 * @brief Base object implementation.
 *

 *

 */
#include "TBI_object.h"
#include "TBI_memory.h"
#include "TBI_debug.h"
#include "TBI_common.h"

/**@defgroup TBI_object_group Base object implementation.
* @brief Provides utility functions to ease Object Oriented Programming in C.
*/

#if defined (_DEBUG) || defined (DEBUG)
#	define TBI_DEBUG_OBJECTS	0
static int TBI_objects_count = 0;
#else
#	define TBI_DEBUG_OBJECTS	0
#endif

/** Object meta-data (definition).
*/
typedef struct TBI_object_header_s{
	const void* base; /**< Opaque data holding a pointer to the actual meta-data(size, constructor, destructor and comparator) */
	int	refCount; /**< Reference counter. */
}
TBI_object_header_t;
#define TBI_OBJECT_HEADER(object)	((TBI_object_header_t*)object)

/**@ingroup TBI_object_group
* Creates new object. The object MUST be declared using @ref TBI_DECLARE_OBJECT macro.
* @param objdef The object meta-data (definition). For more infomation see @ref TBI_object_def_t.
* @param ... List of parameters to pass to the constructor(defined in the meta-data).
* @retval @ref TBI_object_t object with a reference counter equal to 1.
* @sa @ref TBI_object_new_2.
*/
TBI_object_t* TBI_object_new(const TBI_object_def_t *objdef, ...)
{
	// Do not check "objdef", let the application die if it's null
	TBI_object_t *newobj = TBI_calloc(1, objdef->size);
	if(newobj){
		(*(const TBI_object_def_t **) newobj) = objdef;
		TBI_OBJECT_HEADER(newobj)->refCount = 1;
		if(objdef->constructor){ 
			va_list ap;
			va_start(ap, objdef);
			newobj = objdef->constructor(newobj, &ap);
			va_end(ap);

#if TBI_DEBUG_OBJECTS
		TBI_DEBUG_INFO("N∞ objects:%d", ++TBI_objects_count);
#endif
		}
		else{
			TBI_DEBUG_WARN("No constructor found.");
		}
	}
	else{
		TBI_DEBUG_ERROR("Failed to create new TBI_object.");
	}

	return newobj;
}

/**@ingroup TBI_object_group
* Creates new object. The object MUST be declared using @ref TBI_DECLARE_OBJECT macro.
* @param objdef The object meta-data (definition). For more infomation see @ref TBI_object_def_t.
* @param ap Variable argument list to pass to the constructor(defined in the meta-data).
* @retval @ref TBI_object_t object with a reference counter equal to 1.
* @sa @ref TBI_object_new.
*/
TBI_object_t* TBI_object_new_2(const TBI_object_def_t *objdef, va_list* ap)
{
	TBI_object_t *newobj = TBI_calloc(1, objdef->size);
	if(newobj){
		(*(const TBI_object_def_t **) newobj) = objdef;
		TBI_OBJECT_HEADER(newobj)->refCount = 1;
		if(objdef->constructor){ 
			newobj = objdef->constructor(newobj, ap);

#if TBI_DEBUG_OBJECTS
		TBI_DEBUG_INFO("N∞ objects:%d", ++TBI_objects_count);
#endif
		}
		else{
			TBI_DEBUG_WARN("No constructor found.");
		}
	}
	else{
		TBI_DEBUG_ERROR("Failed to create new TBI_object.");
	}

	return newobj;
}

/**@ingroup TBI_object_group
* Gets the size of an opaque object.
* @param self The object for which we want to get the size.
* The object MUST be declared using @ref TBI_DECLARE_OBJECT macro and created using @ref TBI_object_new or @ref TBI_object_new_2.
* @retval The size of the object.
*/
TBI_size_t TBI_object_sizeof(const TBI_object_t *self)
{
	const TBI_object_def_t **objdef = (const TBI_object_def_t **)self;
	if(objdef && *objdef){
		return (*objdef)->size;
	}
	else{
		TBI_DEBUG_ERROR("NULL object definition.");
		return 0;
	}
}

/**@ingroup TBI_object_group
* Compares two well-defined objects.
* If the meta-data (definition) of the first object (@a object1) do not include a function comparator then this method will amlways return -1.
* @param object1 The first object to compare.
* @param object2 The second object to compare.
* @retval Zero if the two object are equal.
* Positive value if @a object1 is greater than @a object2 and a negative value otherwise.
*/
int TBI_object_cmp(const TBI_object_t *object1, const TBI_object_t *object2)
{
	const TBI_object_def_t **objdef = (const TBI_object_def_t **)object1;

	if(objdef && *objdef && (*objdef)->comparator){
		return (*objdef)->comparator(object1, object2);
	}
	return -1;
}

/**@ingroup TBI_object_group
* Increment the refrence counting of the object.<br>
* Refernce counting: http://en.wikipedia.org/wiki/Reference_counting.<br>
* The object MUST be declared using @ref TBI_DECLARE_OBJECT macro and created using @ref TBI_object_new or @ref TBI_object_new_2.
* @param self The object holding the counter to increment.
* @retval The new object (incremented).
* @sa TBI_object_unref.
*/
TBI_object_t* TBI_object_ref(TBI_object_t *self)
{
	TBI_object_header_t* objhdr = TBI_OBJECT_HEADER(self);
	if(objhdr && objhdr->refCount){
		objhdr->refCount++;
		return self;
	}
	return TBI_null;
}

/**@ingroup TBI_object_group
* Decrement the refrence counting of the object.<br>
* Refernce counting: http://en.wikipedia.org/wiki/Reference_counting.<br>
* The object MUST be declared using @ref TBI_DECLARE_OBJECT macro and created using @ref TBI_object_new or @ref TBI_object_new_2.
* @param self The object holding the counter to decrement.
* @retval If the refernce counter is equal to zero then NULL is returned otherwise a new object (decremented) is returned.
* @sa ref TBI_object_ref.
* @sa ref TBI_OBJECT_SAFE_FREE.
*/
TBI_object_t* TBI_object_unref(TBI_object_t *self)
{
	if(self){
		TBI_object_header_t* objhdr = TBI_OBJECT_HEADER(self);
		if(objhdr->refCount){ // If refCount is == 0 then, nothing should happen.
			if(!--objhdr->refCount){
				TBI_object_delete(self);
				return TBI_null;
			}
		}
		else{
			return TBI_null;
		}
	}
	return self;
}

TBI_size_t TBI_object_get_refcount(TBI_object_t *self)
{
	return self ? TBI_OBJECT_HEADER(self)->refCount : 0;
}

/**@ingroup TBI_object_group
* Delete an object. This function will delete the object even if it's reference counter is greater than 1.
* This mean that this function is not safe. You should use @ref TBI_OBJECT_SAFE_FREE to safely delete an object.
* The object MUST be declared using @ref TBI_DECLARE_OBJECT macro and created using @ref TBI_object_new or @ref TBI_object_new_2.
* @param self The object to delete.
* @sa @ref TBI_OBJECT_SAFE_FREE.
*/
void TBI_object_delete(TBI_object_t *self)
{
	const TBI_object_def_t ** objdef = self;
	if(self && *objdef){
		if((*objdef)->destructor){
			self = (*objdef)->destructor(self);
#if TBI_DEBUG_OBJECTS
		TBI_DEBUG_INFO("N∞ objects:%d", --TBI_objects_count);
#endif
		}
		else{
			TBI_DEBUG_WARN("No destructor found.");
		}
		free(self);
	}
}

