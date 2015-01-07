 

/**@file TBI_list.c
 * @brief Linked list.
 *

 *

 */
#include "TBI_list.h"
#include "TBI_memory.h"
#include "TBI_debug.h"

//#include <assert.h>
#include <string.h>

// FIXME: remove asserts

/**@defgroup TBI_list_group Linked list.
* For more information about linked list you can visit http://en.wikipedia.org/wiki/Linked_list.
*/

/** TBI_list_find_by_item
*/
static int TBI_list_find_by_item(const TBI_list_item_t* item, const void* _item)
{
	return (item == (const TBI_list_item_t*)_item) ? 0 : -1;
}

/**@ingroup TBI_list_group
* Creates a linked list object.
* You MUST use @ref TBI_OBJECT_SAFE_FREE() to safely free the object.
*/
TBI_list_t* TBI_list_create()
{
	return TBI_object_new(TBI_list_def_t);
}

/**@ingroup TBI_list_group
* Create and initialize an item to be added to a linked list.
* You MUST use @ref TBI_OBJECT_SAFE_FREE() to safely free the object.
*/
TBI_list_item_t* TBI_list_item_create()
{
	return TBI_object_new(TBI_list_item_def_t);
}

/**@ingroup TBI_list_group
* Locks the list to avoid concurrent access. The list should be unlocked using
* @ref TBI_list_unlock.
* @param list The list to lock.
* @retval zero if succeed and non-zero error code otherwise.
* @sa @ref TBI_list_unlock
*/
int TBI_list_lock(TBI_list_t* list)
{
	if(list){
		if(!list->mutex){
			list->mutex = TBI_mutex_create();
		}
		return TBI_mutex_lock(list->mutex);
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
}

/**@ingroup TBI_list_group
* UnLocks a previously locked list.
* @param list The list to unlock.
* @retval zero if succeed and non-zero error code otherwise.
* @sa @ref TBI_list_lock
*/
int TBI_list_unlock(TBI_list_t* list)
{
	if(list && list->mutex){
		return TBI_mutex_unlock(list->mutex); 
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
}

/**@ingroup TBI_list_group
* Remove an free an item from the @a list.
* @param list the list from which to remove the @a item.
* @param item the item to remove (and free) from the @a list.
*/
void TBI_list_remove_item(TBI_list_t* list, TBI_list_item_t* item)
{
	TBI_list_remove_item_by_pred(list, TBI_list_find_by_item, (const void*)item);
}

/**@ingroup TBI_list_group
* Pops an object from the @a list.
* @param list The list from which to pop the object.
* @param tskobj Any valid object(declared using @ref TBI_DECLARE_OBJECT) to remove.
* @retval The item.
*/
TBI_list_item_t* TBI_list_pop_item_by_data(TBI_list_t* list, const TBI_object_t * tskobj)
{
	if(list){
		TBI_list_item_t *prev = TBI_null;
		TBI_list_item_t *curr = prev = list->head;

		while(curr){
			if(!TBI_object_cmp(curr->data, tskobj)){
				if(prev == curr){
					/* Found at first position. */
					if(list->head == list->tail){
						/* There was only one item */
						list->head = list->tail = TBI_null;
					}
					else{
						list->head = curr->next;
					}
				}
				else {
					if(curr == list->tail){
						/* Found at last position */
						list->tail = prev;
						list->tail->next = TBI_null;
					}
					else{
						prev->next = curr->next;
					}
				}

				return curr;
			}
			
			prev = curr;
			curr = curr->next;
		}
	}

	return TBI_null;
}

/**@ingroup TBI_list_group
* Removes an object from the @a list.
* @param list The list from which to remove the object.
* @param tskobj Any valid object(declared using @ref TBI_DECLARE_OBJECT) to remove.
*/
void TBI_list_remove_item_by_data(TBI_list_t* list, const TBI_object_t * tskobj)
{
	TBI_list_item_t* item;
	if((item = TBI_list_pop_item_by_data(list, tskobj))){
		TBI_object_unref(item);
	}
}

/**@ingroup TBI_list_group
* Pops an item from the @a list using a predicate function.
* @param list The list from which to pop the item.
* @param predicate The predicate function used to match the item.
* @param data Arbitrary data to pass to the predicate function.
* @retval The item
*/
TBI_list_item_t* TBI_list_pop_item_by_pred(TBI_list_t* list, TBI_list_func_predicate predicate, const void * data)
{
	if(list){
		TBI_list_item_t *prev = TBI_null;
		TBI_list_item_t *curr = prev = list->head;

		while(curr){
			if(!predicate(curr, data)){
				if(prev == curr){
					/* Found at first position. */
					if(list->head == list->tail){
						/* There was only one item */
						list->head = list->tail = TBI_null;
					}
					else{
						list->head = curr->next;
					}
				}
				else {
					if(curr == list->tail){
						/* Found at last position */
						list->tail = prev;
						list->tail->next = TBI_null;
					}
					else{
						prev->next = curr->next;
					}
				}

				return curr;
			}
			
			prev = curr;
			curr = curr->next;
		}
	}

	return 0;
}

/**@ingroup TBI_list_group
* Removes an item from the @a list using a predicate function.
* @param list The list from which to remove the item.
* @param predicate The predicate function used to match the item.
* @param data Arbitrary data to pass to the predicate function.
*/
void TBI_list_remove_item_by_pred(TBI_list_t* list, TBI_list_func_predicate predicate, const void * data)
{
	TBI_list_item_t* item;
	if((item = TBI_list_pop_item_by_pred(list, predicate, data))){
		TBI_object_unref(item);
	}
}

/**@ingroup TBI_list_group
* Clean up and remove all items from the @a list.
* @param list The list ro clean up.
*/
void TBI_list_clear_items(TBI_list_t* list)
{
	if(list){
		TBI_list_item_t* next = TBI_null;
		TBI_list_item_t* curr = list->head;

		while(curr){
			next = curr->next;
			TBI_object_unref(curr);
			curr = next;
		}
		list->head = TBI_null;
		list->tail = TBI_null;
	}
}

/**@ingroup TBI_list_group
* Pops first item from the @a list. The item will be definitely removed from the list.
* @param list The list from which to pop the item.
* @retval The first item. It is up to you to free the returned item (@ref TBI_OBJECT_SAFE_FREE(item)).
*/
TBI_list_item_t* TBI_list_pop_first_item(TBI_list_t* list)
{
	TBI_list_item_t* item = TBI_null;
	if(list){
		item = list->head;
		if(list->head){
			if(list->head->next){
				list->head = list->head->next;
			}
			else{
				list->head = list->tail = TBI_null;
			}
		}
	}

	return item;
}

/**@ingroup TBI_list_group
* Add an item to the @a list.
* @param list The destination @a list.
* @param item The @a item to add.
* @param back Indicates whether to put the item back or not.
*/
void TBI_list_push_item(TBI_list_t* list, TBI_list_item_t** item, TBI_bool_t back)
{
	// do not test
	TBI_bool_t first = !list->head;
	
	if(back && list->tail){
		list->tail->next = *item, list->tail = *item, (*item)->next = TBI_null;
	}
	else {
		(*item)->next = list->head, list->head = *item;
	}
	
	if(first){
		list->tail = list->head = *item, list->tail->next = TBI_null;
	}
	(*item) = TBI_null;
}

/**@ingroup TBI_list_group
* Add an item to the list in ascending or descending order.
* @param list The destination @a list.
* @param item The  @a item to add.
* @param ascending Indicates whether to put the @a item in ascending order or not.
*/
void TBI_list_push_filtered_item(TBI_list_t* list, TBI_list_item_t** item, TBI_bool_t ascending)
{
	if(list)
	{
		TBI_list_item_t *prev = TBI_null;
		TBI_list_item_t *curr = prev = list->head;
		
		while(curr)
		{
			int diff = TBI_object_cmp((*item), curr);
			if((diff </*=*/ 0 && ascending) || (diff >/*=*/0 && !ascending)){
				if(curr == list->head){
					TBI_list_push_front_item(list, item);
				}
				else{
					(*item)->next = curr;
					prev->next = (*item);
				}

				return;
			}
			
			prev = curr;
			curr = curr->next;
		}

		TBI_list_push_back_item(list, item);
	}
}

/**@ingroup TBI_list_group
* Add all items in @a src into @a dest.
* @param dest The destination list.
* @param src The source list.
* @param back Indicates whether to put the list back or not.
**/
int TBI_list_push_list(TBI_list_t* dest, const TBI_list_t* src, TBI_bool_t back)
{
	const TBI_list_item_t* curr = (src)->head;
	TBI_object_t* copy;
	
	if(!dest || !src){
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	while(curr){
		copy = TBI_object_ref(curr->data);
		TBI_list_push_data(dest, (void**)&copy, back);
				
		curr = curr->next;
	}
	return 0;
}

/**@ingroup TBI_list_group
* Add an opaque data to the @a list.
* @param list The destination @a list.
* @param data The @a data to add.
* @param back Indicates whether to put the item back or not.
*/
int TBI_list_push_data(TBI_list_t* list, void** data, TBI_bool_t back)
{
	if(list && data && *data){
		TBI_list_item_t *item = TBI_list_item_create();
		item->data = *data;
		
		TBI_list_push_item(list, &item, back);
		(*data) = TBI_null;

		return 0;
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
}

/**@ingroup TBI_list_group
* Add an opaque data to the list in ascending or descending order.
* @param list The destination @a list.
* @param data The @a data to add.
* @param ascending Indicates whether to put the @a data in ascending order or not.
*/
int TBI_list_push_filtered_data(TBI_list_t* list, void** data, TBI_bool_t ascending)
{
	if(list && data && *data){
		TBI_list_item_t *item = TBI_list_item_create();
		item->data = *data;
		
		TBI_list_push_filtered_item(list, &item, ascending);
		(*data) = TBI_null;

		return 0;
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
}

/**@ingroup TBI_list_group
* Find an item from a list.
* @param list The @a list holding the item.
* @param tskobj The @a object to find.
* @retval A @ref TBI_list_item_t item if found and NULL otherwize.
*/
const TBI_list_item_t* TBI_list_find_item_by_data(const TBI_list_t* list, const TBI_object_t* tskobj)
{
	if(list && tskobj){
		TBI_list_item_t *item;
		TBI_list_foreach(item, list){
			if(!TBI_object_cmp(item->data, tskobj)){
				return item;
			}
		}
	}
	
	return 0;
}

/**@ingroup TBI_list_group
* Find first item matching criteria defined by the @a predicate.
* @param list the list to query
* @param predicate the predicate against which to test each item
* @param data data passed to the predicate function for comparaison
* @retval the item which match the criteria and NULL otherwise
* @sa @ref TBI_list_find_item_by_data
*/
const TBI_list_item_t* TBI_list_find_item_by_pred(const TBI_list_t* list, TBI_list_func_predicate predicate, const void* data)
{
	if(predicate){
		const TBI_list_item_t *item;
		TBI_list_foreach(item, list){
			if(!predicate(item, data)){
				return item;
			}
		}
	}
	else{
		TBI_DEBUG_WARN("Cannot use an uninitialized predicate function");
	}
	return TBI_null;
}

/**@ingroup TBI_list_group
* Find first item matching criteria defined by the @a predicate.
* @param list the list to query
* @param predicate the predicate against which to test each item
* @param data data passed to the predicate function for comparaison
* @retval the data holded by the item which match the criteria and NULL otherwise
* @sa @ref TBI_list_find_item_by_pred
*/
const TBI_object_t* TBI_list_find_object_by_pred(const TBI_list_t* list, TBI_list_func_predicate predicate, const void* data)
{
	const TBI_list_item_t *item;
	if((item = TBI_list_find_item_by_pred(list, predicate, data))){
		return item->data;
	}
	else{
		return TBI_null;
	}
}

/**@ingroup TBI_list_group
* Counts the number of item matching the predicate.
* @param list The list containing the items to count
* @param predicate The predicate to use to match the items
* @param data Data passed to the predicate function for comparaison
* @retval The number of item matching the predicate
*/
TBI_size_t TBI_list_count(const TBI_list_t* list, TBI_list_func_predicate predicate, const void* data)
{
	TBI_size_t count = 0;
	if(predicate && list){
		const TBI_list_item_t *item;
		TBI_list_foreach(item, list){
			if(!predicate(item, data)){
				++count;
			}
		}
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
	}

	return count;
}











//=================================================================================================
//	Item object definition
//
static TBI_object_t* TBI_list_item_ctor(TBI_object_t * self, va_list * app)
{
	TBI_list_item_t *item = self;
	if(item){
	}
	return self;
}

static TBI_object_t* TBI_list_item_dtor(TBI_object_t *self)
{
	TBI_list_item_t *item = self;
	if(item){
		item->data = TBI_object_unref(item->data);
	}
	else{
		TBI_DEBUG_WARN("Cannot free an uninitialized item");
	}
	return item;
}

static int TBI_list_item_cmp(const TBI_object_t *_item1, const TBI_object_t *_item2)
{	
	const TBI_list_item_t* item1 = _item1;
	const TBI_list_item_t* item2 = _item2;
	
	if(item1 && item2){
		return TBI_object_cmp(item1->data, item2->data);
	}
	else return -1;
}

static const TBI_object_def_t TBI_list_item_def_s =
{
	sizeof(TBI_list_item_t),	
	TBI_list_item_ctor,
	TBI_list_item_dtor,
	TBI_list_item_cmp,
};
const TBI_object_def_t *TBI_list_item_def_t = &TBI_list_item_def_s;

//=================================================================================================
//	List object definition
//
static TBI_object_t* TBI_list_ctor(TBI_object_t *self, va_list *app)
{
	TBI_list_t *list = self;
	if(list){
	}

	return self;
}

static TBI_object_t* TBI_list_dtor(TBI_object_t *self)
{ 
	TBI_list_t *list = self;
	if(list){
#if 0
		/* Not thread-safe */
		TBI_list_item_t* next = TBI_null;
		TBI_list_item_t* curr = list->head;

		while(curr){
			next = curr->next;
			/*curr =*/ TBI_object_unref(curr);
			curr = next;
		}
#else
		/* Thread-safe method */
		TBI_list_item_t* item;
		while((item = TBI_list_pop_first_item(list))){
			TBI_object_unref(item);
		}
#endif

		/* destroy the on-demand mutex */
		if(list->mutex){
			TBI_mutex_destroy(&list->mutex);
		}
	}
	else{
		TBI_DEBUG_WARN("Cannot free an uninitialized list");
	}
	return list;
}

static const TBI_object_def_t TBI_list_def_s =
{
	sizeof(TBI_list_t),
	TBI_list_ctor,
	TBI_list_dtor,
	TBI_null,
};
const TBI_object_def_t *TBI_list_def_t = &TBI_list_def_s;

