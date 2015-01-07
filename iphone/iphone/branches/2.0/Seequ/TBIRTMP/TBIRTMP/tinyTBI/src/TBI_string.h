 

/**@file TBI_string.h
 * @brief Useful string functions to manipulate strings.
 *

 *

 */
#ifndef _TINYTBI_STRING_H_
#define _TINYTBI_STRING_H_

#include "tinysak_config.h"

#include "TBI_object.h"
#include "TBI_list.h"

/**@ingroup TBI_string_group
* @def TBI_STRING_STR
* Gets the internal string pointer. 
*/
TBI_BEGIN_DECLS

#define TBI_STRING_STR(self)				((TBI_string_t*)self)->value

typedef char TBI_istr_t[21]; /**< Integer number as string value. */

TINYSAK_API char TBI_b10tob16(char c);
TINYSAK_API char TBI_b16tob10(char c);

TINYSAK_API int TBI_stricmp(const char * str1, const char * str2);
TINYSAK_API int TBI_strnicmp(const char * str1, const char * str2, TBI_size_t n);
TINYSAK_API int TBI_strcmp(const char * str1, const char * str2);
TINYSAK_API int TBI_strncmp(const char * str1, const char * str2, TBI_size_t n);
TINYSAK_API char* TBI_strdup(const char *s1);
TINYSAK_API char* TBI_strndup(const char *s1, TBI_size_t n);
TINYSAK_API TBI_bool_t TBI_strcontains(const char * str, TBI_size_t size, const char * substring);
TINYSAK_API int TBI_strindexOf(const char * str, TBI_size_t size, const char * substring);
TINYSAK_API int TBI_strLastIndexOf(const char * str, TBI_size_t size, const char * substring);
TINYSAK_API void TBI_strcat(char** destination, const char* source);
TINYSAK_API void TBI_strcat_2(char** destination, const char* format, ...);
TINYSAK_API void TBI_strncat(char** destination, const char* source, TBI_size_t n);
TINYSAK_API int TBI_sprintf(char** str, const char* format, ...);
TINYSAK_API int TBI_sprintf_2(char** str, const char* format, va_list* ap);
TINYSAK_API void TBI_strupdate(char** str, const char* newval);
TINYSAK_API void TBI_strtrim_left(char **str);
TINYSAK_API void TBI_strtrim_right(char **str);
TINYSAK_API void TBI_strtrim(char **str);
TINYSAK_API void TBI_strquote(char **str);
TINYSAK_API void TBI_strquote_2(char **str, char lquote, char rquote);
TINYSAK_API void TBI_strunquote(char **str);
TINYSAK_API void TBI_strunquote_2(char **str, char lquote, char rquote);
TINYSAK_API void TBI_itoa(int64_t i, TBI_istr_t *result);
TINYSAK_API int64_t TBI_atoll(const char*);
TINYSAK_API long TBI_atox(const char*);
TINYSAK_API void TBI_strrandom(TBI_istr_t *result);
TINYSAK_API void TBI_str_from_hex(const uint8_t *hex, TBI_size_t size, char* str);
TINYSAK_API void TBI_str_to_hex(const char *str, TBI_size_t size, uint8_t* hex);

/**@ingroup TBI_string_group
* @def TBI_strtrim_both
*/
/**@ingroup TBI_string_group
* @def TBI_strempty
*/
/**@ingroup TBI_string_group
* @def TBI_striequals
*/
/**@ingroup TBI_string_group
* @def TBI_strniequals
*/
/**@ingroup TBI_string_group
* @def TBI_strequals
*/
/**@ingroup TBI_string_group
* @def TBI_strnequals
*/
#define TBI_strtrim_both(str) TBI_strtrim_left(str), TBI_strtrim_right(str);
#define TBI_strempty(s) (*(s) == '\0')
#define TBI_strnullORempty(s) (!(s) || TBI_strempty((s)))
#define TBI_striequals(s1, s2) (TBI_stricmp((const char*)(s1), (const char*)(s2)) ? TBI_false : TBI_true)
#define TBI_strniequals(s1, s2, n) (TBI_strnicmp((const char*)(s1), (const char*)(s2), n) ? TBI_false : TBI_true)
#define TBI_strequals(s1, s2) (TBI_strcmp((const char*)(s1), (const char*)(s2)) ? TBI_false : TBI_true)
#define TBI_strnequals(s1, s2, n) (TBI_strncmp((const char*)(s1), (const char*)(s2), n) ? TBI_false : TBI_true)
#define TBI_strlen(s) ((s) ? strlen((s)) : 0)

/**@ingroup TBI_string_group
* String object.
*/
typedef struct TBI_string_s
{
	TBI_DECLARE_OBJECT;

	char *value; /**< The value of the string object. */
}
TBI_string_t;

typedef TBI_list_t TBI_strings_L_t;

TINYSAK_API TBI_string_t* TBI_string_create(const char* str);

TINYSAK_GEXTERN const TBI_object_def_t *TBI_string_def_t;

TBI_END_DECLS

#endif /* _TINYTBI_STRING_H_ */

