 

/**@file TBI_params.c
 * @brief SIP/MSRP/XCAP Parameters parser.
 *

 *

 */
#include "TBI_params.h"
#include "TBI_memory.h"
#include "TBI_string.h"
#include "TBI_common.h"
#include "TBI_debug.h"

#include <string.h>

/**@defgroup TBI_params_group SIP/MSRP/XCAP Parameters parser.
*/

/* Predicate function used to find a parameter by name (case-insensitive).
*/
static int pred_find_param_by_name(const TBI_list_item_t *item, const void *name)
{
	if(item && item->data){
		TBI_param_t *param = item->data;
		return TBI_stricmp(param->name, name);
	}
	return -1;
}

/**@ingroup TBI_params_group
*/
TBI_param_t* TBI_param_create(const char* name, const char* value)
{
	return TBI_object_new(TBI_PARAM_VA_ARGS(name, value));
}

/**@ingroup TBI_params_group
*/
TBI_param_t* TBI_param_create_null()
{
	return TBI_param_create(TBI_null, TBI_null);
}

/**@ingroup TBI_params_group
* Converts a key-value-pair string (kvp) to @ref TBI_param_t object.
* @param line The kvp (e.g. 'branch=z9hG4bK652hsge') string to parse.
* @param size The size (length) of the kvp string.
* @retval @ref TBI_param_t object.
*/
TBI_param_t *TBI_params_parse_param(const char* line, TBI_size_t size)
{
	if(line && size){
		const char* start = line;
		const char* end = (line + size);
		const char* equal = strstr(line, "=");
		TBI_param_t *param = TBI_param_create_null();

		if(param && equal && equal<end){
			if((param->name = TBI_calloc((equal-start)+1, sizeof(const char)))){
				memcpy(param->name, start, (equal-start));
			}

			if((param->value = TBI_calloc((end-equal-1)+1, sizeof(const char)))){
				memcpy(param->value, equal+1, (end-equal-1));
			}
		}
		else if(param){
			if((param->name = TBI_calloc((end-start)+1, sizeof(const char)))){
				memcpy(param->name, start, (end-start));
			}
		}

		return param;
	}
	return TBI_null;
}
/**@ingroup TBI_params_group
* Checks if the supplied list of parameters contains a parameter named @a name (case-insensitive).
* @param self The list of parameters into which to search.
* @param name The name of the parameter to search.
* @retval @ref TBI_true if the parameter exist and @ref TBI_false otherwise.
*/
TBI_bool_t TBI_params_have_param(const TBI_params_L_t *self, const char* name)
{
	if(self){
		if(TBI_list_find_item_by_pred(self, pred_find_param_by_name, name)){
			return TBI_true;
		}
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
	}
	return TBI_false;
}

/**@ingroup TBI_params_group
* Adds a parameter to the list of parameters. If the parameter already exist(case-insensitive), then it's value will be updated.
* @param self The destination list.
* @param name The name of the parameter to add.
* @param value The value of the parameter to add.
* @retval Zero if succeed and -1 otherwise.
*/
int TBI_params_add_param(TBI_params_L_t **self, const char* name, const char* value)
{
	TBI_param_t *param;

	if(!self || !name) {
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	if(!*self){
		*self = TBI_list_create();
	}

	if((param = (TBI_param_t*)TBI_params_get_param_by_name(*self, name))){
		TBI_strupdate(&param->value, value); /* Already exist ==> update the value. */
	}
	else{
		param = TBI_param_create(name, value);
		TBI_list_push_back_data(*self, (void**)&param);
	}

	return 0;
}

int TBI_params_add_param_2(TBI_params_L_t **self, const TBI_param_t* param)
{
	if(!self || !param || !param){
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	return TBI_params_add_param(self, param->name, param->value);
}

/**@ingroup TBI_params_group
* Removes a parameter from the list of parameters.
* @param self The list from which to remove the parameter.
* @param name The name(case-insensitive) of the parameter to remove.
* @retval Zero if succeed and -1 otherwise.
*/
int TBI_params_remove_param(TBI_params_L_t *self, const char* name)
{
	if(self){
		TBI_list_remove_item_by_pred(self, pred_find_param_by_name, name);
		return 0;
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
}

/**@ingroup TBI_params_group
* Gets a parameter from the list of parameters by name.
* @param self The source list.
* @param name The name(case-insensitive) of the parameter to retrieve.
* @retval @ref TBI_param_t if succeed and @ref TBI_null otherwise.
*/
const TBI_param_t *TBI_params_get_param_by_name(const TBI_params_L_t *self, const char* name)
{
	if(self){
		const TBI_list_item_t *item_const = TBI_list_find_item_by_pred(self, pred_find_param_by_name, name);
		if(item_const){
			return item_const->data;
		}
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
	}
	return TBI_null;
}

/**@ingroup TBI_params_group
* Gets the value of a parameter.
* @param self The source list.
* @param name The name(case-insensitive) of the parameter to retrieve.
* @retval The value of the parameter if succeed and NULL otherwise.
*/
const char *TBI_params_get_param_value(const TBI_params_L_t *self, const char* name)
{
	if(self && name){
		const TBI_list_item_t *item_const = TBI_list_find_item_by_pred(self, pred_find_param_by_name, name);
		if(item_const && item_const->data){
			return ((const TBI_param_t *)item_const->data)->value;
		}
	}
	else{
		TBI_DEBUG_ERROR("Invalid parameter");
	}
	return TBI_null;
}

/**@ingroup TBI_params_group
* Gets the value of a parameter.
* @param self The source list.
* @param name The name(case-insensitive) of the parameter to retrieve.
* @retval The value of the parameter if succeed and -1 otherwise.
*/
int TBI_params_get_param_value_as_int(const TBI_params_L_t *self, const char* name)
{
	const char *value = TBI_params_get_param_value(self, name);
	return value ? atoi(value) : -1;
}

/**@ingroup TBI_params_group
* Serializes a @ref TBI_param_t object.
* @param param The parameter to serialize.
* @param output The output buffer.
* @retval Zero if succeed and -1 otherwise.
*/
int TBI_params_param_tostring(const TBI_param_t *param, TBI_buffer_t* output)
{
	if(param){
		return TBI_buffer_append_2(output, param->value?"%s=%s":"%s", param->name, param->value);
	}
	return -1;
}

/**@ingroup TBI_params_group
* Serializes a @ref TBI_params_L_t object.
* @param self The list of parameters to serialize.
* @param separator The character to use as separator between params.
* @param output The output buffer.
* @retval Zero if succeed and non-zero error code otherwise.
*/
int TBI_params_tostring(const TBI_params_L_t *self, const char separator, TBI_buffer_t* output)
{
	int ret = -1;

	if(self){
		TBI_list_item_t *item;
		ret = 0; // for empty lists
		TBI_list_foreach(item, self){
			TBI_param_t* param = item->data;
			//TBI_params_param_tostring(param, output);
			if(TBI_LIST_IS_FIRST(self, item)){
				if((ret = TBI_buffer_append_2(output, param->value?"%s=%s":"%s", param->name, param->value))){
					goto bail;
				}
			}
			else{
				if((ret = TBI_buffer_append_2(output, param->value?"%c%s=%s":"%c%s", separator, param->name, param->value))){
					goto bail;
				}
			}
		}
	}

bail:
	return ret;
}

/**@ingroup TBI_params_group
*/
TBI_params_L_t* TBI_params_fromstring(const char* string, const char* separator, TBI_bool_t trim)
{
	TBI_params_L_t* params = TBI_null;
	TBI_param_t* param;

	int i = 0, index;
	TBI_size_t size = TBI_strlen(string);

#define PUSH_PARAM() \
	if(!params){ \
		params = TBI_list_create(); \
	} \
	if(trim){ \
		if(param->name){ \
			TBI_strtrim(&param->name); \
		} \
		if(param->value){ \
			TBI_strtrim(&param->value); \
		} \
	} \
	TBI_list_push_back_data(params, (void**)&param);

	while((index = TBI_strindexOf((string + i), (size - i), separator)) != -1){
		if((param = TBI_params_parse_param((string + i), index))){
			PUSH_PARAM();
		}
		i += (index + 1);
	}

	// last one
	if(i<(int)size){
		if((param = TBI_params_parse_param((string + i), (size - i)))){
			PUSH_PARAM();
		}
	}
	
	return params;
}





















//=================================================================================================
//	param object definition
//
static TBI_object_t* TBI_param_ctor(TBI_object_t* self, va_list * app)
{
	TBI_param_t *param = self;
	if(param){
		const char* name = va_arg(*app, const char *);
		const char* value = va_arg(*app, const char *);

		if(!TBI_strnullORempty(name)) {
			param->name = TBI_strdup(name);
			if(!TBI_strnullORempty(value)) {
				param->value = TBI_strdup(value);
			}
		}
	}

	return self;
}

static TBI_object_t* TBI_param_dtor(TBI_object_t* self)
{ 
	TBI_param_t *param = self;
	if(param){
		TBI_FREE(param->name);
		TBI_FREE(param->value);
	}

	return self;
}

static const TBI_object_def_t TBI_param_def_s = 
{
	sizeof(TBI_param_t),
	TBI_param_ctor, 
	TBI_param_dtor,
	TBI_null, 
};
const TBI_object_def_t *TBI_param_def_t = &TBI_param_def_s;

