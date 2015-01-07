 

/**@file tinysak_config.h
 * @brief Global configuration file.
 *
 * This file incude all your preferences or configuration. All specific configuration
 * must be defined in this file. You must include this file in all your header files.
 *

 *

 */
#ifndef _TBI_UTILS_H_
#define _TBI_UTILS_H_

#ifdef __SYMBIAN32__
#undef _WIN32 /* Because of WINSCW */
#endif

/* Windows (XP/Vista/7/CE and Windows Mobile) macro definition.
*/
#if defined(WIN32)|| defined(_WIN32) || defined(_WIN32_WCE)
#	define TBI_UNDER_WINDOWS	1
#endif

/* Used on Windows and Symbian systems to export/import public functions and global variables.
*/
#if !defined(__GNUC__) && defined(TINYSAK_EXPORTS)
# 	define TINYSAK_API		__declspec(dllexport)
#	define TINYSAK_GEXTERN	__declspec(dllexport)
#elif !defined(__GNUC__) /*&& defined(TINYSAK_IMPORTS)*/
# 	define TINYSAK_API		__declspec(dllimport)
#	define TINYSAK_GEXTERN	__declspec(dllimport)
#else
#	define TINYSAK_API
#	define TINYSAK_GEXTERN	extern
#endif

/* Guards against C++ name mangling */
#ifdef __cplusplus
#	define TBI_BEGIN_DECLS extern "C" {
#	define TBI_END_DECLS }
#else
#	define TBI_BEGIN_DECLS 
#	define TBI_END_DECLS
#endif

#if defined(_MSC_VER)
#	define TBI_INLINE	__forceinline
#elif defined(__GNUC__) && !defined(__APPLE__)
#	define TBI_INLINE	__inline
#else
#	define TBI_INLINE	
#endif


/* Disable some well-known warnings for M$ Visual Studio*/
#ifdef _MSC_VER
#	define _CRT_SECURE_NO_WARNINGS
#	pragma warning( disable : 4996 )
#endif

/*	Features */
#if TBI_UNDER_WINDOWS
#	define HAVE_GETTIMEOFDAY				0
#else
#	define HAVE_GETTIMEOFDAY				1
#endif

#if defined(ANDROID)
#	define HAVE_CLOCK_GETTIME	1
#endif

#include <stdint.h>
#include <stddef.h>
#include "TBI_common.h"


#if HAVE_CONFIG_H
#	include "../config.h"
#endif

#endif /* _TBI_UTILS_H_ */

