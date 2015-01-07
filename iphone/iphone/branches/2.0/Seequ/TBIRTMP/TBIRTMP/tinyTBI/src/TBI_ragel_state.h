

/**@file TBI_ragel_state.h
 * @brief Ragel state for SIP, HTTP and MSRP parsing.
 *

 *

 */
#ifndef TINYSAK_RAGEL_STATE_H
#define TINYSAK_RAGEL_STATE_H

#include "tinysak_config.h"
#include "TBI_params.h"

#include <string.h>

TBI_BEGIN_DECLS


#if defined(_MSC_VER)
#	define atoi64	_atoi64
#else
#	define atoi64	atoll
#endif

/**@ingroup TBI_ragel_state_group
*/
#define TBI_SCANNER_SET_STRING(string) \
	if(!string) \
	{ \
		int len = (int)(te  - ts);  \
		if(len >0) \
		{ \
			string = TBI_calloc(len+1, sizeof(char)), memcpy(string, ts, len); \
		} \
	}

/**@ingroup TBI_ragel_state_group
*/
#define TBI_PARSER_SET_STRING(string) \
	{  \
		int len = (int)(p  - tag_start);  \
		if(len && tag_start){ \
			if(string){ \
				TBI_FREE(string); \
			} \
			string = TBI_calloc(len+1, sizeof(char)), memcpy(string, tag_start, len); \
		}  \
	}

/**@ingroup TBI_ragel_state_group
*/
#define TBI_SCANNER_SET_INTEGER(integer) \
	{ \
		int len = (int)(te  - ts); \
		if(len>=0) \
		{ \
			char* tmp = TBI_calloc(len+1, sizeof(char)); \
			memcpy(tmp, ts, len); \
			integer = atoi(tmp); \
			free(tmp); \
		} \
	}

/**@ingroup TBI_ragel_state_group
*/
#define TBI_PARSER_SET_INTEGER_EX(retval, type, func) \
	{ \
		int len = (int)(p  - tag_start); \
		if(len>=0) \
		{ \
			char* tmp = TBI_calloc(len+1, sizeof(char)); \
			memcpy(tmp, tag_start, len); \
			retval = (type) func(tmp); \
			free(tmp); \
		} \
	}
/**@ingroup TBI_ragel_state_group
* @def TBI_PARSER_SET_INTEGER
*/
/**@ingroup TBI_ragel_state_group
* @def TBI_PARSER_SET_INT
*/
/**@ingroup TBI_ragel_state_group
* @def TBI_PARSER_SET_UINT
*/
/**@ingroup TBI_ragel_state_group
* @def TBI_PARSER_SET_FLOAT
*/
/**@ingroup TBI_ragel_state_group
* @def TBI_PARSER_SET_DOUBLE
*/
#define TBI_PARSER_SET_INTEGER(retval) TBI_PARSER_SET_INTEGER_EX(retval, int, atoi)
#define TBI_PARSER_SET_INT(retval) TBI_PARSER_SET_INTEGER(retval)
#define TBI_PARSER_SET_UINT(retval) TBI_PARSER_SET_INTEGER_EX(retval, uint32_t, atoi64)
#define TBI_PARSER_SET_FLOAT(retval) TBI_PARSER_SET_INTEGER_EX(retval, float, atof)
#define TBI_PARSER_SET_DOUBLE(retval) TBI_PARSER_SET_INTEGER_EX(retval, double, atof)

/**@ingroup TBI_ragel_state_group
*/
#define TBI_PARSER_ADD_PARAM(dest) \
	{ \
		TBI_size_t len = (TBI_size_t)(p  - tag_start); \
		TBI_param_t *param = TBI_params_parse_param(tag_start, len); \
		if(param) \
		{ \
			if(!dest) dest = TBI_list_create(); \
			TBI_list_push_back_data(dest, ((void**) &param)); \
		} \
	}

/**@ingroup TBI_ragel_state_group
*/
#define TBI_SACANNER_ADD_PARAM(dest) \
	{ \
		int len = (int)(te  - ts); \
		if(len >0) \
		{ \
			TBI_param_t *param = TBI_params_parse_param(ts, len); \
			if(param) \
			{ \
				if(!dest) dest = TBI_list_create(); \
				TBI_list_push_back_data(dest, ((void**) &param)); \
			} \
		} \
	}

/**@ingroup TBI_ragel_state_group
*/
#define TBI_PARSER_ADD_STRING(dest) \
	{ \
		TBI_size_t len = (TBI_size_t)(p  - tag_start); \
		TBI_string_t *string = TBI_string_create(TBI_null); \
		string->value = TBI_calloc(len+1, sizeof(char)), memcpy(string->value, tag_start, len); \
		if(!dest)  \
		{  \
			dest = TBI_list_create(); \
		} \
		TBI_list_push_back_data(dest, ((void**) &string)); \
	}

/**@ingroup TBI_ragel_state_group
* Ragel state.
*/
typedef struct TBI_ragel_state_s
{
	int cs; /**< Ragel current state. */
	const char *p; /**< Data pointing to the buffer to parse. */
	const char *pe; /**< Data end pointer. */
	const char *eof; /**< End of the file (in our cas data) pointer. */
		
	const char* tag_start; /**< Last tag start position set by ragel machine. */
	const char* tag_end; /**< The end of the ragel tag. */
}
TBI_ragel_state_t;


TINYSAK_API void TBI_ragel_state_init(TBI_ragel_state_t *state, const char *data, TBI_size_t size);

TBI_END_DECLS

#endif /* TINYSAK_RAGEL_STATE_H */

