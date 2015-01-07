 

/**@file TBI_options.c
 * @brief Options.
 *

 *

 */
#include "TBI_options.h"
#include "TBI_memory.h"
#include "TBI_string.h"
#include "TBI_common.h"

#include <string.h>

/**@defgroup TBI_options_group Options.
*/

/** Predicate function used to find an option by id.
*/
static int pred_find_option_by_id(const TBI_list_item_t *item, const void *id)
{
	if(item && item->data){
		TBI_option_t *option = item->data;
		return (option->id - *((int*)id));
	}
	return -1;
}

/**@ingroup TBI_options_group
*/
TBI_option_t* TBI_option_create(int id, const char* value)
{
	return TBI_object_new(TBI_OPTION_VA_ARGS(id, value));
}

/**@ingroup TBI_options_group
*/
TBI_option_t* TBI_option_create_null()
{
	return TBI_option_create(0, TBI_null);
}


/**@ingroup TBI_options_group
* Checks if the supplied list of options contains an option with this @a id.
* @param self The list of options into which to search.
* @param id The id of the option to search.
* @retval @ref TBI_true if the parameter exist and @ref TBI_false otherwise.
*/
TBI_bool_t TBI_options_have_option(const TBI_options_L_t *self, int id)
{
	if(self){
		if(TBI_list_find_item_by_pred(self, pred_find_option_by_id, &id)){
			return TBI_true;
		}
	}
	return TBI_false;
}

/**@ingroup TBI_options_group
* Adds an option to the list of options. If the option already exist(same id), then it's value will be updated.
* @param self The destination list.
* @param id The id of the option to add.
* @param value The value of the option to add.
* @retval Zero if succeed and -1 otherwise.
*/
int TBI_options_add_option(TBI_options_L_t **self, int id, const char* value)
{
	TBI_option_t *option;

	if(!self) {
		return -1;
	}

	if(!*self){
		*self = TBI_list_create();
	}

	if((option = (TBI_option_t*)TBI_options_get_option_by_id(*self, id))){
		TBI_strupdate(&option->value, value); /* Already exist ==> update the value. */
	}
	else{
		option = TBI_option_create(id, value);
		TBI_list_push_back_data(*self, (void**)&option);
	}

	return 0;
}

int TBI_options_add_option_2(TBI_options_L_t **self, const TBI_option_t* option)
{
	int ret = -1;
	if(!self || !option || !option){
		return ret;
	}

	ret = TBI_options_add_option(self, option->id, option->value);
	return ret;
}

/**@ingroup TBI_options_group
* Removes an option from the list of options.
* @param self The source list.
* @param id The id of the option to remove.
* @retval Zero if succeed and -1 otherwise.
*/
int TBI_options_remove_option(TBI_options_L_t *self, int id)
{
	if(self){
		TBI_list_remove_item_by_pred(self, pred_find_option_by_id, &id);
		return 0;
	}
	return -1;
}

/**@ingroup TBI_options_group
* Gets an option from the list of options by id.
* @param self The source list.
* @param id The id of the option to retrieve.
* @retval @ref TBI_option_t if succeed and NULL otherwise.
*/
const TBI_option_t *TBI_options_get_option_by_id(const TBI_options_L_t *self, int id)
{
	if(self){
		const TBI_list_item_t *item_const = TBI_list_find_item_by_pred(self, pred_find_option_by_id, &id);
		if(item_const){
			return item_const->data;
		}
	}
	return 0;
}

/**@ingroup TBI_options_group
* Gets the value of a option.
* @param self The source list.
* @param id The id of the option to retrieve.
* @retval The value of the option if succeed and @ref TBI_null otherwise.
*/
const char *TBI_options_get_option_value(const TBI_options_L_t *self, int id)
{
	if(self){
		const TBI_list_item_t *item_const = TBI_list_find_item_by_pred(self, pred_find_option_by_id, &id);
		if(item_const && item_const->data){
			return ((const TBI_option_t *)item_const->data)->value;
		}
	}
	return TBI_null;
}

/**@ingroup TBI_options_group
* Gets the value of a option.
* @param self The source list.
* @param id The id of the option to retrieve.
* @retval The value of the option if succeed and -1 otherwise.
*/
int TBI_options_get_option_value_as_int(const TBI_options_L_t *self, int id)
{
	const char *value = TBI_options_get_option_value(self, id);
	return value ? atoi(value) : -1;
}






















//=================================================================================================
//	option object definition
//
static TBI_object_t* TBI_option_ctor(TBI_object_t * self, va_list * app)
{
	TBI_option_t *option = self;
	if(option){
		int id = va_arg(*app, int);
		const char* value = va_arg(*app, const char *);
		
		option->id = id;
		if(!TBI_strnullORempty(value)) {
			option->value = TBI_strdup(value);
		}
	}

	return self;
}

static TBI_object_t* TBI_option_dtor(TBI_object_t * self)
{ 
	TBI_option_t *option = self;
	if(option){
		TBI_FREE(option->value);
	}

	return self;
}

static const TBI_object_def_t TBI_option_def_s = 
{
	sizeof(TBI_option_t),
	TBI_option_ctor, 
	TBI_option_dtor,
	TBI_null, 
};
const TBI_object_def_t* TBI_option_def_t = &TBI_option_def_s;

