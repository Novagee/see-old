 

/**@file TBI_list.h
 * @brief Linked list. For more information about linked list you can visit http://en.wikipedia.org/wiki/Linked_list.
 *

 *

 */
#ifndef _TINYTBI_LIST_H_
#define _TINYTBI_LIST_H_

#include "tinysak_config.h"
#include "TBI_mutex.h"
#include "TBI_object.h"

TBI_BEGIN_DECLS

/**@ingroup TBI_list_group
* Check if the the linked list is empty or not.
*	This function will fail if the list is NULL.
*/
#define TBI_LIST_IS_EMPTY(self)				((self) ? (!(self)->head) : TBI_true)

#define TBI_LIST_IS_FIRST(self, item)		((self) ? ((self)->head == item) : TBI_false)
#define TBI_LIST_IS_LAST(self, item)		((self) ? ((self)->tail == item) : TBI_false)

#define TBI_LIST_FIRST_DATA(self)			(((self) && (self)->head) ? (self)->head->data : TBI_null)

/**@ingroup TBI_list_group
* Item for linked list. 
*/
typedef struct TBI_list_item_s
{
	TBI_DECLARE_OBJECT;
	void* data; /**< Opaque data. */
	struct TBI_list_item_s* next; /**< Next item. */
}
TBI_list_item_t;

/**@ingroup TBI_list_group
* Linked list.
*/
typedef struct TBI_list_s
{
	TBI_DECLARE_OBJECT;
	
	TBI_list_item_t* head; /**< The head of the linked list. */
	TBI_list_item_t* tail; /**< The tail of the linked list. */
	TBI_mutex_handle_t* mutex; /**< on-demand mutex. */
}
TBI_list_t;

/**@ingroup TBI_list_group 
* Function predicate used to match an item.
* @param item The current item to match.
* @param data Arbitrary data holding the object to compare.
* @retval 0 if match and <0 if first<second and >0 otherwise
*/
typedef int (*TBI_list_func_predicate)(const TBI_list_item_t* item, const void* data);


/**@ingroup TBI_list_group
* Loop through the linked list.
* @param item The current item.
* @param list Pointer to the list for which we want to get items.
*
*/
#define TBI_list_foreach(item, list) for(item = list ? list->head : TBI_null; item; item = item->next)

TINYSAK_API TBI_list_t* TBI_list_create();
TINYSAK_API TBI_list_item_t* TBI_list_item_create();

TINYSAK_API int TBI_list_lock(TBI_list_t* list);
TINYSAK_API int TBI_list_unlock(TBI_list_t* list);

TINYSAK_API void TBI_list_remove_item(TBI_list_t* list, TBI_list_item_t* item);
TINYSAK_API TBI_list_item_t* TBI_list_pop_item_by_data(TBI_list_t* list, const TBI_object_t * tskobj);
TINYSAK_API void TBI_list_remove_item_by_data(TBI_list_t* list, const TBI_object_t * tskobj);
TINYSAK_API void TBI_list_remove_item_by_pred(TBI_list_t* list, TBI_list_func_predicate predicate, const void * data);
TINYSAK_API TBI_list_item_t* TBI_list_pop_item_by_pred(TBI_list_t* list, TBI_list_func_predicate predicate, const void * data);
TINYSAK_API void TBI_list_clear_items(TBI_list_t* list);

TINYSAK_API TBI_list_item_t* TBI_list_pop_first_item(TBI_list_t* list);
TINYSAK_API void TBI_list_push_item(TBI_list_t* list, TBI_list_item_t** item, TBI_bool_t back);
#define TBI_list_push_back_item(list, item) TBI_list_push_item(list, item, TBI_true)
#define TBI_list_push_front_item(list, item) TBI_list_push_item(list, item, TBI_false)
TINYSAK_API void TBI_list_push_filtered_item(TBI_list_t* list, TBI_list_item_t** item, TBI_bool_t ascending);
#define TBI_list_push_ascending_item(list, item) TBI_list_pushfiltered_item(list, item, TBI_true)
#define TBI_list_push_descending_item(list, item) TBI_list_pushfiltered_item(list, item, TBI_false)

TINYSAK_API int TBI_list_push_list(TBI_list_t* destination, const TBI_list_t* source, TBI_bool_t back);
#define TBI_list_pushback_list(destination, source) TBI_list_push_list(destination, source, TBI_true)
#define TBI_list_pushfront_list(destination, source) TBI_list_push_list(destination, source, TBI_false)

TINYSAK_API int TBI_list_push_data(TBI_list_t* list, void** data, TBI_bool_t back);
#define TBI_list_push_back_data(list, data) TBI_list_push_data(list, data, TBI_true)
#define TBI_list_push_front_data(list, data) TBI_list_push_data(list, data, TBI_false)
TINYSAK_API int TBI_list_push_filtered_data(TBI_list_t* list, void** data, TBI_bool_t ascending);
#define TBI_list_push_ascending_data(list, data) TBI_list_push_filtered_data(list, data, TBI_true)
#define TBI_list_push_descending_data(list, data) TBI_list_push_filtered_data(list, data, TBI_false)

TINYSAK_API const TBI_list_item_t* TBI_list_find_item_by_data(const TBI_list_t* list, const TBI_object_t * tskobj);
TINYSAK_API const TBI_list_item_t* TBI_list_find_item_by_pred(const TBI_list_t* list, TBI_list_func_predicate predicate, const void* data);
TINYSAK_API const TBI_object_t* TBI_list_find_object_by_pred(const TBI_list_t* list, TBI_list_func_predicate predicate, const void* data);
TINYSAK_API TBI_size_t TBI_list_count(const TBI_list_t* list, TBI_list_func_predicate predicate, const void* data);

TINYSAK_GEXTERN const TBI_object_def_t *TBI_list_def_t;
TINYSAK_GEXTERN const TBI_object_def_t *TBI_list_item_def_t;


TBI_END_DECLS

#endif /* _TINYTBI_LIST_H_ */

