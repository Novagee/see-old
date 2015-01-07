 

/**@file TBI_object.h
 * @brief Base object implementation.
 *

 *

 */
#ifndef TBI_OBJECT_H
#define TBI_OBJECT_H

#include "tinysak_config.h"

#include <stdarg.h>
#include <stdio.h>

TBI_BEGIN_DECLS

/**@ingroup TBI_object_group
* Plain object.
*/
typedef void TBI_object_t;

/**@ingroup TBI_object_group
* @def TBI_OBJECT_SAFE_FREE
* Safely free any well-defined object. If the reference count of the object was equal to 1 then this
 * 	object will be freed otherwise the refrence counter will be decremented. 
 *	In all case this operation will set the pointer (the object itself) to NULL.<br>
 * <b>Very Important</b>: Mutexes, Semaphores and CondVars are not well-defined objects. You should never use this macro to destroy them.
 * @param	self	The object to free or unref. 
**/
#define TBI_OBJECT_SAFE_FREE(self)		if(self) TBI_object_unref(self), self = TBI_null

/**@ingroup TBI_object_group
* tag a structure as an object. If this macro is used then you MUST
* provide a constructor and a destructor functions into an object definition (or meta-data).
* @ref TBI_object_new or @ref TBI_object_new_2 are used to create the object and  @ref TBI_object_unref or @ref TBI_object_delete to destroy it.
* @code
* typedef struct person_s{
*	TBI_DECLARE_OBJECT;
*	int id;
*	char* firstName;
*	char* lastName;
* } person_t;
* @endcode
* To create the object:
* @code
* // person_def_t: See bellow to understand how to create an object definition.
* person_t* person = TBI_object_new(person_def_t, "My First Name", "My last Name");
* @endcode
* To safely free the object:
* @code
* TBI_OBJECT_SAFE_FREE(person);
* @endcode
*/
#define TBI_DECLARE_OBJECT \
	const void* __base__; \
	TBI_size_t	refCount

/**@ingroup TBI_object_group
* Internal macro to get the definition of the object.
*/
#define TBI_OBJECT_DEF(self)			((const TBI_object_def_t*)self)

/**@ingroup TBI_object_group
* Meta-data used of define an object.
* You MUST provide at least a constructor and a destructor. The comparator should
* be provided if you would like to compare opaque object or sort linked lists.
* @code
*
* // constructor
* static void* person_create(TBI_object_t * self, va_list * app)
* {
* 	static int unique_id = 0;
* 	person_t *person = self;
* 	if(person){
* 		person->id = ++unique_id;
* 		person->firstName = TBI_strdup(va_arg(*app, const char *));
* 		person->lastName = TBI_strdup(va_arg(*app, const char *));
* 	}
* 	return self;
* }
* 
* // destructor
* static void* person_destroy(TBI_object_t * self)
* { 
* 	person_t *person = self;
* 	if(person){
* 		TBI_FREE(person->firstName);
* 		TBI_FREE(person->lastName);
* 	}
* 	return self;
* }
* 
* // comparator
* static int person_cmp(const TBI_object_t *object1, const TBI_object_t *object1)
* {
* 	const person_t *person1 = object1;
* 	const person_t *person2 = object2;
* 
* 	return (person1 && person2) ? (person1->id - person2->id) : -1;
* }
*
* // Meta-data (Object defnition)
* static const TBI_object_def_t person_def_s = 
* {
* 	sizeof(person_t),
* 	person_create,
* 	person_destroy,
* 	person_cmp, 
* }person_def_t;
* 
* @endcode
* Now, to create your object:
* @code
* person_t* person = TBI_object_new(person_def_t, "My First Name", "My last Name"); // Will call "person_create" function.
* @endcode
* Or
* @code
* #define PERSON_CREATE(firstName, lastName) TBI_object_new(person_def_t, firstName, lastName)
* person_t* person = PERSON_CREATE("My First Name", "My last Name") // For clarity, this form will be used in all projects declared using @ref TBI_DECLARE_OBJECT.
* @endcode
* To safely free your object:
* @code
* TBI_OBJECT_SAFE_FREE(person); // Will call "person_destroy" function.
* @endcode
*/
typedef struct TBI_object_def_s
{
	//! The size of the object.
	TBI_size_t size;
	//! Pointer to the constructor.
	TBI_object_t*	(* constructor) (TBI_object_t *, va_list *);
	//! Pointer to the destructor.
	TBI_object_t*	(* destructor) (TBI_object_t *);
	//! Pointer to the comparator.
	int		(* comparator) (const TBI_object_t *, const TBI_object_t *);
}
TBI_object_def_t;

TINYSAK_API TBI_object_t* TBI_object_new(const TBI_object_def_t *objdef, ...);
TINYSAK_API TBI_object_t* TBI_object_new_2(const TBI_object_def_t *objdef, va_list* ap);
TINYSAK_API TBI_size_t TBI_object_sizeof(const TBI_object_t *);
TINYSAK_API int TBI_object_cmp(const void *self, const TBI_object_t *object);
TINYSAK_API TBI_object_t* TBI_object_ref(TBI_object_t *self);
TINYSAK_API TBI_object_t* TBI_object_unref(TBI_object_t *self);
TINYSAK_API TBI_size_t TBI_object_get_refcount(TBI_object_t *self);
TINYSAK_API void TBI_object_delete(TBI_object_t *self);

TBI_END_DECLS

#endif /* TBI_OBJECT_H */

