 

/**@file TBI_params.h
 * @brief SIP/MSRP/XCAP Parameters parser.
 *

 *

 */
#ifndef _TINYTBI_PARAMS_H_
#define _TINYTBI_PARAMS_H_

#include "tinysak_config.h"
#include "TBI_object.h"
#include "TBI_list.h"
#include "TBI_buffer.h"


TBI_BEGIN_DECLS

#define TBI_PARAM_VA_ARGS(name, value)		TBI_param_def_t, (const char*)name, (const char*)value

#define TBI_PARAM(self)				((TBI_param_t*)(self))

/**@ingroup TBI_params_group
* Parameter.
*/
typedef struct TBI_param_s
{
	TBI_DECLARE_OBJECT;

	char *name;/**< The name of the parameter. */
	char *value;/**< The value of the parameter. */
	
	TBI_bool_t tag;/**< tag to be used for any use case (e.g. validity of the parameter, whether to ignore the param., ...). Default value: @ref TBI_false.*/
}
TBI_param_t;

typedef TBI_list_t TBI_params_L_t; /**< List of @ref TBI_param_t elements. */

TINYSAK_API TBI_param_t* TBI_param_create(const char* name, const char* value);
TINYSAK_API TBI_param_t* TBI_param_create_null();

TINYSAK_API TBI_param_t *TBI_params_parse_param(const char* line, TBI_size_t size);

TINYSAK_API TBI_bool_t TBI_params_have_param(const TBI_params_L_t *self, const char* name);
TINYSAK_API int TBI_params_add_param(TBI_params_L_t **self, const char* name, const char* value);
TINYSAK_API int TBI_params_add_param_2(TBI_params_L_t **self, const TBI_param_t* param);
TINYSAK_API int TBI_params_remove_param(TBI_params_L_t *self, const char* name);
TINYSAK_API const TBI_param_t *TBI_params_get_param_by_name(const TBI_params_L_t *self, const char* name);
TINYSAK_API const char *TBI_params_get_param_value(const TBI_params_L_t *self, const char* name);
TINYSAK_API int TBI_params_get_param_value_as_int(const TBI_params_L_t *self, const char* name);

TINYSAK_API int TBI_params_param_tostring(const TBI_param_t *param, TBI_buffer_t* output);
TINYSAK_API int TBI_params_tostring(const TBI_params_L_t *self, const char separator, TBI_buffer_t* output);
TINYSAK_API TBI_params_L_t* TBI_params_fromstring(const char* string, const char* separator, TBI_bool_t trim);

TINYSAK_GEXTERN const TBI_object_def_t *TBI_param_def_t;

TBI_END_DECLS

#endif /* _TINYTBI_PARAMS_H_ */

