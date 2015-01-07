
#ifndef _TINYTBI_DEBUG_H_
#define _TINYTBI_DEBUG_H_

#include "tinysak_config.h"
#include <stdio.h>

TBI_BEGIN_DECLS
//# define TRACE_LOG_MASSIGE
//# define TRACE_LOG_RTP
# define DEBUG_LEVEL DEBUG_LEVEL_INFO
#if !defined(DEBUG_LEVEL)
#	define DEBUG_LEVEL DEBUG_LEVEL_INFO
#endif
#define DEBUG_AUDIO_BUFFER  0

extern char LogFileName[];
extern char System_Versio[];
extern FILE *log_file;

extern unsigned int paket_rec_time;
extern int paket_number;

/**@ingroup TBI_debug_group
 * @def DEBUG_LEVEL_INFO
 * @a INFO level (4). This is the lowest possible level and will turn on all logging.
 */
/**@ingroup TBI_debug_group
 * @def DEBUG_LEVEL_WARN
 * @a WARN level (3). Warning are error which could change the normal process without blocking the application.
 */
/**@ingroup TBI_debug_group
 * @def DEBUG_LEVEL_ERROR
 * @a ERROR level (2). This level log error which might change the application behavior.
 */
/**@ingroup TBI_debug_group
 * @def DEBUG_LEVEL_FATAL
 * @a FATAL level (1). This level log fatal errors which might abort the application.
 */
#define DEBUG_LEVEL_INFO		4
#define DEBUG_LEVEL_WARN		3
#define DEBUG_LEVEL_ERROR		2
#define DEBUG_LEVEL_FATAL		1
#define DEBUG_LEVEL_MESSAGE     0

#if TBI_HAVE_DEBUG_H
#	include <my_debug.h>
#else
typedef int (*TBI_debug_f)(const void* arg, const char* fmt, ...);

/* INFO */
#	if (DEBUG_LEVEL >= DEBUG_LEVEL_INFO)
#		define TBI_DEBUG_INFO(FMT, ...)		\
if(TBI_debug_get_info_cb()) \
TBI_debug_get_info_cb()(TBI_debug_get_arg_data(), "*INFO: " FMT "\n", ##__VA_ARGS__); \
else \
fprintf(stderr, "*INFO: " FMT "\n", ##__VA_ARGS__);
#		define TBI_DEBUG_INFO_WOE(FMT, ...)		\
if(TBI_debug_get_info_cb()) \
TBI_debug_get_info_cb()(TBI_debug_get_arg_data(), FMT, ##__VA_ARGS__); \
else \
fprintf(stderr, FMT, ##__VA_ARGS__);
#	else
#		define TBI_DEBUG_INFO(FMT, ...)		((void)0)
#		define TBI_DEBUG_INFO_WOE(FMT, ...)	((void)0)
#	endif
/* WARN */
#	if (DEBUG_LEVEL >= DEBUG_LEVEL_WARN)
#		define TBI_DEBUG_WARN(FMT, ...)		\
if(TBI_debug_get_warn_cb()) \
TBI_debug_get_warn_cb()(TBI_debug_get_arg_data(), "**WARN: function: \"%s()\" \nfile: \"%s\" \nline: \"%u\" \nMSG: " FMT "\n", __FUNCTION__,  __FILE__, __LINE__, ##__VA_ARGS__); \
else \
fprintf(stderr, "**WARN: function: \"%s()\" \nfile: \"%s\" \nline: \"%u\" \nMSG: " FMT "\n", __FUNCTION__,  __FILE__, __LINE__, ##__VA_ARGS__);
#	else
#		define TBI_DEBUG_WARN(FMT, ...)		((void)0)
#	endif
/* ERROR */
#	if (DEBUG_LEVEL >= DEBUG_LEVEL_ERROR)
#		define TBI_DEBUG_ERROR(FMT, ...) 		\
if(TBI_debug_get_error_cb()) \
TBI_debug_get_error_cb()(TBI_debug_get_arg_data(), "***ERROR: function: \"%s()\" \nfile: \"%s\" \nline: \"%u\" \nMSG: " FMT "\n", __FUNCTION__,  __FILE__, __LINE__, ##__VA_ARGS__); \
else \
fprintf(stderr, "***ERROR: function: \"%s()\" \nfile: \"%s\" \nline: \"%u\" \nMSG: " FMT "\n", __FUNCTION__,  __FILE__, __LINE__, ##__VA_ARGS__);
#	else
#		define TBI_DEBUG_ERROR(FMT, ...)		((void)0)
#	endif
/* FATAL */
#	if (DEBUG_LEVEL >= DEBUG_LEVEL_FATAL)
#		define TBI_DEBUG_FATAL(FMT, ...)		\
if(TBI_debug_get_fatal_cb()) \
TBI_debug_get_fatal_cb()(TBI_debug_get_arg_data(), "****FATAL: function: \"%s()\" \nfile: \"%s\" \nline: \"%u\" \nMSG: " FMT "\n", __FUNCTION__,  __FILE__, __LINE__, ##__VA_ARGS__); \
else \
fprintf(stderr, "****FATAL: function: \"%s()\" \nfile: \"%s\" \nline: \"%u\" \nMSG: " FMT "\n", __FUNCTION__,  __FILE__, __LINE__, ##__VA_ARGS__);
#	else
#		define TBI_DEBUG_FATAL(FMT, ...)		((void)0)
#	endif
/* MESSAGE */
#	if (DEBUG_LEVEL >= DEBUG_LEVEL_MESSAGE)
#		define TBI_DEBUG_MESSAGE(FMT, ...)		\
if(TBI_debug_get_info_cb()) \
TBI_debug_get_info_cb()(TBI_debug_get_arg_data(), "\n #RTMP MESSAGE: " FMT "\n", ##__VA_ARGS__); \
else \
fprintf(stderr, "\n #SIP MESSAGE: " FMT "\n", ##__VA_ARGS__);
#	else
#		define TBI_DEBUG_INFO(FMT, ...)		((void)0)
#	endif

/* AUDIO BUFFER */
#	if (DEBUG_AUDIO_BUFFER == 1)
#		define TBI_DEBUG_AUDIO(FMT, ...)		\
fprintf(stderr, "*AUDIO: " FMT , ##__VA_ARGS__);
#	else
#		define TBI_DEBUG_AUDIO(FMT, ...)		((void)0)
#	endif

TINYSAK_API void TBI_debug_set_arg_data(const void*);
TINYSAK_API const void* TBI_debug_get_arg_data();
TINYSAK_API void TBI_debug_set_info_cb(TBI_debug_f );
TINYSAK_API TBI_debug_f TBI_debug_get_info_cb();
TINYSAK_API void TBI_debug_set_warn_cb(TBI_debug_f );
TINYSAK_API TBI_debug_f TBI_debug_get_warn_cb();
TINYSAK_API void TBI_debug_set_error_cb(TBI_debug_f );
TINYSAK_API TBI_debug_f TBI_debug_get_error_cb( );
TINYSAK_API void TBI_debug_set_fatal_cb(TBI_debug_f );
TINYSAK_API void TBI_debug_set_Log_File_Name(const char *filename);
TINYSAK_API TBI_debug_f TBI_debug_get_fatal_cb( );
TINYSAK_API const char* TBI_debug_get_Log_File_Name();
TINYSAK_API void TBI_debug_set_system_version(const char *sys_ver);

#endif /* TBI_HAVE_DEBUG_H */


TBI_END_DECLS

#endif /* _TINYTBI_DEBUG_H_ */

