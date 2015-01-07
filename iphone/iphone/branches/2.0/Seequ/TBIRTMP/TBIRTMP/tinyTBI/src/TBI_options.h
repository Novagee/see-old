 

/**@file TBI_options.h
 * @brief Options.
 *

 *

 */
#ifndef _TINYTBI_OPTIONS_H_
#define _TINYTBI_OPTIONS_H_

#include "tinysak_config.h"
#include "TBI_object.h"
#include "TBI_list.h"
#include "TBI_buffer.h"


TBI_BEGIN_DECLS

#define TBI_OPTION_VA_ARGS(id, value)		TBI_option_def_t, (int)id, (const char*)value

#define TBI_OPTION(self)				((TBI_option_t*)(self))

/**@ingroup TBI_options_group
* Parameter.
*/
typedef struct TBI_option_s
{
	TBI_DECLARE_OBJECT;

	int id;
	char* value;
	
	TBI_bool_t tag;
}
TBI_option_t;

typedef TBI_list_t TBI_options_L_t; /**< List of @ref TBI_option_t elements. */

TINYSAK_API TBI_option_t* TBI_option_create(int id, const char* value);
TINYSAK_API TBI_option_t* TBI_option_create_null();

TINYSAK_API int TBI_options_have_option(const TBI_options_L_t *self, int id);
TINYSAK_API int TBI_options_add_option(TBI_options_L_t **self, int id, const char* value);
TINYSAK_API int TBI_options_add_option_2(TBI_options_L_t **self, const TBI_option_t* option);
TINYSAK_API int TBI_options_remove_option(TBI_options_L_t *self, int id);
TINYSAK_API const TBI_option_t *TBI_options_get_option_by_id(const TBI_options_L_t *self, int id);
TINYSAK_API const char *TBI_options_get_option_value(const TBI_options_L_t *self, int id);
TINYSAK_API int TBI_options_get_option_value_as_int(const TBI_options_L_t *self, int id);

TINYSAK_GEXTERN const TBI_object_def_t *TBI_option_def_t;

TBI_END_DECLS

#endif /* _TINYTBI_OPTIONS_H_ */

