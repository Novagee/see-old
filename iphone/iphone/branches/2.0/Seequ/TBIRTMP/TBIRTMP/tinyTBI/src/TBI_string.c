 

/**@file TBI_string.c
 * @brief Useful string functions to manipulate strings.
 * As I'm a lazy man, some comments come from <ahref="http://www.cplusplus.com">this website</a>
 *

 *

 */
#include "TBI_string.h"
#include "TBI_memory.h"
#include "TBI_time.h"
#include "TBI_debug.h"
#include "TBI_common.h"

#include <stdarg.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_MSC_VER)
#	define snprintf		_snprintf
#	define vsnprintf	_vsnprintf
#	define strdup		_strdup
#	define stricmp		_stricmp
#	define strnicmp		_strnicmp
#else
#	if !HAVE_STRNICMP && !HAVE_STRICMP
#	define stricmp		strcasecmp
#	define strnicmp		strncasecmp
#	endif
#endif

/**@defgroup TBI_string_group String utillity functions.
*/

static char HEX[] = "0123456789abcdef";

/**@ingroup TBI_string_group
*/
TBI_string_t* TBI_string_create(const char* str)
{
	return TBI_object_new(TBI_string_def_t, str);
}

/**@ingroup TBI_string_group
* From base 10 to base 16
* @param c the base 10 char to convert to base 16
* @retval The base 16 value
*/
char TBI_b10tob16(char c)
{
	return HEX[c & 15];
}

/**@ingroup TBI_string_group
* From base 16 to base 10
* @param c The base 16 char to convert to base 10
* @retval The base 10 value
*/
char TBI_b16tob10(char c)
{
	return isdigit(c) ? c - '0' : tolower(c) - 'a' + 10;
}

/**@ingroup TBI_string_group
* Compare two Null-terminated strings (case insensitive)
* Compares the C string str1 to the C string str2.
* This function starts comparing the first character of each string. If they are equal to each other, it continues with the following pairs 
* until the characters differ or until a terminanting null-character is reached.
* @param str1 First C string to be compared. 
* @param str2 Second C string to be compared. 
* @retval Returns an integral value indicating the relationship between the strings:
* <0 : str1 less than str2.<br>
* 0  : str1 identical to str2.<br>
* >0 : str1 greater than str2.<br>
*/
int TBI_stricmp(const char * str1, const char * str2)
{
	return (str1 && str2) ? 
		( (tolower(*str1) == tolower(*str2)) ? stricmp(str1, str2) : (*str1-*str2) )  /* Compare first charaters before doing complete comparison */
		: 
		( (!str1 && !str2) ? 0 : -1 );
}

/**@ingroup TBI_string_group
* Compare two Null-terminated strings (case insensitive)
* Compares the C string str1 to the C string str2.
* This function starts comparing the first character of each string. If they are equal to each other, it continues with the following pairs 
* until the characters differ or until a terminanting null-character is reached or @a n characters passed.
* @param str1 First C string to be compared. 
* @param str2 Second C string to be compared. 
* @param n The maximum number of characters to compare.
* @retval Returns an integral value indicating the relationship between the strings:
* <0 : str1 less than str2.<br>
* 0  : str1 identical to str2.<br>
* >0 : str1 greater than str2.<br>
*/
int TBI_strnicmp(const char * str1, const char * str2, TBI_size_t n)
{
	return (str1 && str2 && n) ? 
		( (tolower(*str1) == tolower(*str2)) ? strnicmp(str1, str2, n) : (*str1-*str2) )  /* Compare first charaters before doing complete comparison */
		: 
		( (!str1 && !str2) ? 0 : -1 );
}

/**@ingroup TBI_string_group
*/
int TBI_strcmp(const char * str1, const char * str2)
{
	return (str1 && str2) ?
		( (*str1 == *str2) ? stricmp(str1, str2) : (*str1-*str2) )  /* Compare first charaters before doing complete comparison */
		: 
		( (!str1 && !str2) ? 0 : -1 );
}

/**@ingroup TBI_string_group
* Compare two Null-terminated strings (case sensitive)
* Compares the C string str1 to the C string str2.
* This function starts comparing the first character of each string. If they are equal to each other, it continues with the following pairs 
* until the characters differ or until a terminanting null-character is reached.
* @param str1 First C string to be compared. 
* @param str2 Second C string to be compared.
* @param n The maximum number of characters to compare.
* @retval Returns an integral value indicating the relationship between the strings:
* <0 : str1 less than str2.<br>
* 0  : str1 identical to str2.<br>
* >0 : str1 greater than str2.<br>
*/
int TBI_strncmp(const char * str1, const char * str2, TBI_size_t n)
{
	return (str1 && str2) ? ((*str1 != *str2) ? -1 : strncmp(str1, str2, n)) : ((!str1 && !str2) ? 0 : -1);
}

/**@ingroup TBI_string_group
* Duplicate a Null-terminated string.
* @param s1 The string to duplicate.
* @retval The duplicated string. It's up to you to free the returned string.
*/
char* TBI_strdup(const char *s1)
{
	if(s1){
		return strdup(s1);
	}
	return TBI_null;
}

/**	Duplicates the first @a n chars of @a s1.
 * @param s1 The string to duplicate. 
 * @param n The number of characters to copy to the new string. 
 * @retval	null A copy of @a s1. 
**/
char* TBI_strndup(const char *s1, TBI_size_t n)
{
	char *ret = TBI_null;

	if(s1 && n){
		TBI_size_t len = TBI_strlen(s1);
		TBI_size_t nret = (n > len) ? (len) : (n);

		ret = TBI_calloc((nret+1), sizeof(uint8_t));
		memcpy(ret, s1, nret);
	}

	return ret;
}

/**@ingroup TBI_string_group
* Checks if @a str contains @a substring.
* @param str The master string.
* @param size The size of the master string.
* @param substring the substring.
* @retval @a TBI_true if @a str contains at least one occurence of @a substring and @a TBI_false othewise.
*/
TBI_bool_t TBI_strcontains(const char * str, TBI_size_t size, const char * substring)
{
	return (TBI_strindexOf(str, size, substring) >= 0);
}

/**@ingroup TBI_string_group
* Gets the first occurrence of @a substring within @a str.
* @param str The master string.
* @param size The size of the master string.
* @param substring The substring that is to be searched for within @a str.
* @retval The index of the first ocurrence of @a substring in @a str.
* If no occurrence of @a substring is found, then -1 is returned.
*/
int TBI_strindexOf(const char * str, TBI_size_t size, const char * substring)
{
	if(str && substring){
		const char* sub_start = strstr(str, substring);
		if(sub_start && (sub_start < (str + size))){
			return (sub_start - str);
		}
	}
	return -1;
}

/**@ingroup TBI_string_group
*/
int TBI_strLastIndexOf(const char * str, TBI_size_t size, const char * substring)
{
	if(str && substring){
		TBI_size_t sub_size = TBI_strlen(substring);
		const char* last_sub_start = TBI_null;
		const char* sub_start = strstr(str, substring);
		const char* end = (str + size);
		while(sub_start && (sub_start < end)){
			last_sub_start = sub_start;
			if((sub_start + sub_size)<end){
				sub_start = strstr((sub_start + sub_size), substring);
			}
			else{
				break;
			}
		}
		if(last_sub_start){
			return (last_sub_start - str); 
		}
	}
	return -1;
}

/**@ingroup TBI_string_group
* Appends a copy of the source string to the destination string. The terminating null character in destination is overwritten by the first character of source, 
* and a new null-character is appended at the end of the new string formed by the concatenation of both in destination. If the destination is NULL then new 
* memory will allocated and filled with source value.
* @param destination Pointer de the destination array containing the new string.
* @param source C string to be appended. This should not overlap destination. If NULL then nothing is done.
*/
void TBI_strcat(char** destination, const char* source)
{
	TBI_strncat(destination, source, TBI_strlen(source));
}

/**@ingroup TBI_string_group
*/
void TBI_strcat_2(char** destination, const char* format, ...)
{
	char* temp = TBI_null;
	int len;
	va_list ap;
	
	/* initialize variable arguments */
	va_start(ap, format);
	/* compute */
	if((len = TBI_sprintf_2(&temp, format, &ap))){
		TBI_strncat(destination, temp, len);
	}
	/* reset variable arguments */
	va_end(ap);
	TBI_FREE(temp);
}

/**@ingroup TBI_string_group
*/
void TBI_strncat(char** destination, const char* source, TBI_size_t n)
{
	TBI_size_t index = 0;
	TBI_size_t TBI_size_to_cat = (n > TBI_strlen(source)) ? TBI_strlen(source) : n;

	if(!source || !n){
		return;
	}

	if(!*destination){
		*destination = (char*)TBI_malloc(TBI_size_to_cat+1);
		strncpy(*destination, source, TBI_size_to_cat+1);
	}else{
		index = TBI_strlen(*destination);
		*destination = TBI_realloc(*destination, index + TBI_size_to_cat+1);
		strncpy(((*destination)+index), source, TBI_size_to_cat+1);
	}
	(*destination)[index + TBI_size_to_cat] = '\0';
}

/**@ingroup TBI_string_group
* Writes into the array pointed by str a C string consisting on a sequence of data formatted as the format argument specifies. After the format parameter, 
* the function expects at least as many additional arguments as specified in format.
* This function behaves exactly as printf does, but writing its results to a string instead of stdout. The size of the array passed as str should be enough to 
* contain the entire formatted string.
* @param str Pointer to an array of char elements where the resulting C string is stored. 
* MUST be NULL.
* @param format C string that contains the text to be written to the buffer. For more information see definiton of C function @a sprintf
* @retval On success, the total number of characters written is returned. This count does not include the additional null-character automatically appended 
* at the end of the string.
* On failure, a negative number is returned.
*/
int TBI_sprintf(char** str, const char* format, ...)
{
	int len;
	va_list ap;
	
	/* initialize variable arguments */
	va_start(ap, format);
	/* compute */
	len = TBI_sprintf_2(str, format, &ap);
	/* reset variable arguments */
	va_end(ap);
	
	return len;
}

/**@ingroup TBI_string_group
*/
int TBI_sprintf_2(char** str, const char* format, va_list* ap)
{
	int len = 0;
    va_list ap2;

	/* free previous value */
	if(*str){
		TBI_free((void**)str);
	}
	
	/* needed for 64bit platforms where vsnprintf will change the va_list */
    TBI_va_copy(ap2, *ap);
    
	/* compute destination len for windows mobile
	*/
#if defined(_WIN32_WCE)
	{
		int n;
		len = (TBI_strlen(format)*2);
		*str = (char*)TBI_calloc(1, len+1);
		for(;;){
			if( (n = vsnprintf(*str, len, format, *ap)) >= 0 && (n<len) ){
				len = n;
				goto done;
			}
			else{
				len += 10;
				*str = TBI_realloc(*str, len+1);
			}
		}
done:
		(*str)[len] = '\0';
	}
#else
    len = vsnprintf(0, 0, format, *ap);
    *str = (char*)TBI_calloc(1, len+1);
    vsnprintf(*str, len
#if !defined(_MSC_VER) || defined(__GNUC__)
		+1
#endif
		, format, ap2);
#endif
	
    va_end(ap2);
    
	return len;
}

/**@ingroup TBI_string_group
* Updates the value of @a str.
* @param str The string to update.
* @param newval The new value of @a str.
*/
void TBI_strupdate(char** str, const char* newval)
{
	TBI_free((void**)str);
	*str = TBI_strdup(newval);
}


/**@ingroup TBI_string_group
* Removes all occurrences of white space characters from the beginning of this @a str.
* @param str The string to trim.
*/
void TBI_strtrim_left(char **str)
{
	if(str && *str){
		TBI_size_t count = 0;
		while(isspace(*((*str)+count))) count++;
		if(count){
			strcpy((*str), (*str)+count);
		}
	}
}

/**@ingroup TBI_string_group
* Removes all occurrences of white space characters from the end of @a str.
* @param str The string to trim.
*/
void TBI_strtrim_right(char **str)
{
	if(str && *str){
		TBI_size_t size;
		if((size = TBI_strlen(*str))){
			while(isspace(*((*str)+size-1))) size--;
			*(*str + size) = '\0';
		}
	}
}
/**@ingroup TBI_string_group
* Removes all occurrences of white space characters from the beginning and end of @a str.
* @param str The string to trim.
*/
void TBI_strtrim(char **str)
{
	// left
	TBI_strtrim_left(str);
	// right
	TBI_strtrim_right(str);
}

/**@ingroup TBI_string_group
* Adds quotes ("") to the beginning and end of @a str.<br>
* @param str The string to quote.
* Example: TBI_strquote("doubango") = ""doubango\"".
*/
void TBI_strquote(char **str)
{
	TBI_strquote_2(str, '"', '"');
}

/**@ingroup TBI_string_group
* Adds quotes to the beginning and end of @a str.
* @param str The string to quote.
* @param lquote Quote to add to the begining of @a str.
* @param rquote Quote to add to the end of @a str.
*/
void TBI_strquote_2(char **str, char lquote, char rquote)
{
	if(str && *str){
		char *result = TBI_null;
		TBI_sprintf(&result, "%c%s%c", lquote, *str, rquote);
		TBI_free((void**)str);
		*str = result;
	}
}

/**@ingroup TBI_string_group
* Removes quotes ("") from the beginning and end of @a str.<br>
* @param str The string to unquote.
* Example: TBI_strunquote(""doubango"") = "doubango".
*/
void TBI_strunquote(char **str)
{
	TBI_strunquote_2(str, '"', '"');
}

/**@ingroup TBI_string_group
* Removes quotes from the beginning and end of @a str. The string must starts with @a lquote
* and end with @a rquote.
* @param str The string to unquote.
* @param lquote Quote to remove from the begining of @a str.
* @param rquote Quote to remove from the end of @a str.
*/
void TBI_strunquote_2(char **str, char lquote, char rquote)
{
	if(str && *str){
		TBI_size_t size = TBI_strlen(*str);
		if(size>=2 && **str == lquote && *((*str)+size-1) == rquote){
			strcpy((*str), (*str)+1);
			*((*str)+size-2) = '\0';
		}
	}
}

/**@ingroup TBI_string_group
* Conversts an integer to string.
* @param i The integer number to convert to a string.
* @param result Pointer to the string where to copy the result.
*/
void TBI_itoa(int64_t i, TBI_istr_t *result)
{
	memset(result, 0, sizeof(*result));
    sprintf(*result,"%lld",i);
}

/**@ingroup TBI_string_group
*/
int64_t TBI_atoll(const char* str)
{
	// FIXME: use HAVE_ATOLL and use macro instead of function
	if(str){
#if defined(_MSC_VER)
		return _atoi64(str);
#elif defined(__GNUC__)
		return atoll(str);
#else
		return atol(str); 
#endif
	}
	return 0;
}

/**@ingroup TBI_string_group
*/
long TBI_atox(const char* str)
{
	long ret = 0;
	if(str){
		sscanf(str, "%lx", &ret);
	}
	return ret;
}

/**@ingroup TBI_string_group
 * Generates a random string.
 *
 * @param result	A pointer to the result. 
**/
void TBI_strrandom(TBI_istr_t *result)
{
	static uint64_t __counter = 1;
	TBI_itoa((TBI_time_now() ^ (rand())) ^ ++__counter, result);
}

/**@ingroup TBI_string_group
 *
 * Converts hexadecimal bytes into string representation.
 *
 * @param hex	The hexadecimal bytes to convert. 
 * @param	size		The size of the hexadecimal bytes. 
 * @param str	The pointer to the result. MUST be enought large to hold the result.
 *						It is up to you to add the final '\\0'.
 * @sa @ref TBI_str_to_hex
**/
void TBI_str_from_hex(const uint8_t *hex, TBI_size_t size, char* str)
{
	static const char *TBI_HEXA_VALUES = {"0123456789abcdef"};
	TBI_size_t i;

	for (i = 0 ; i<size; i++){
		str[2*i] = TBI_HEXA_VALUES [ (*(hex+i) & 0xf0) >> 4 ];
		str[(2*i)+1] = TBI_HEXA_VALUES [ (*(hex+i) & 0x0f)		];
	}
}

/**@ingroup TBI_string_group
 * Converts string chars into hexadecimal bytes.
 *
 * @param str	If non-null, the string. 
 * @param	size		The size. 
 * @param hex	If non-null, the hexadecimal. 
**/
void TBI_str_to_hex(const char *str, TBI_size_t size, uint8_t* hex)
{
	// to avoid SIGBUS error when memory is misaligned do not use sscanf("%2x")
	TBI_DEBUG_FATAL("Not implemented.");
}










//=================================================================================================
//	String object definition
//
static TBI_object_t* TBI_string_ctor(TBI_object_t * self, va_list * app)
{
	TBI_string_t *string = self;
	const char *value = va_arg(*app, const char *);
	if(value){
		string->value = TBI_strdup(value);
	}
	return self;
}

static TBI_object_t* TBI_string_dtor(TBI_object_t * self)
{ 
	TBI_string_t *string = self;
	if(string){
		TBI_FREE(string->value);
	}

	return self;
}

static int TBI_string_cmp(const TBI_object_t *_s1, const TBI_object_t *_s2)
{
	const TBI_string_t *s1 = _s1;
	const TBI_string_t *s2 = _s2;

	if(s1 && s2){
		return TBI_stricmp(s1->value, s2->value);
	}
	else if(!s1 && !s2) return 0;
	else return -1;
}

static const TBI_object_def_t TBI_string_def_s = 
{
	sizeof(TBI_string_t),
	TBI_string_ctor, 
	TBI_string_dtor,
	TBI_string_cmp, 
};
const TBI_object_def_t *TBI_string_def_t = &TBI_string_def_s;

