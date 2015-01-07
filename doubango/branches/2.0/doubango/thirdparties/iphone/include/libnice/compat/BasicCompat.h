/*
 *  BasicCompat.h
 *  libnice-darwin
 *
 *  Created by Vadim Tsyganok on 8/19/10.
 *  Copyright 2010 tsyganok.com. All rights reserved.
 *
 */

#ifndef BASIC_COMPAT
#define BASIC_COMPAT


#import <CoreFoundation/CoreFoundation.h>


// DARWIN ***IS REAL*** UNIX (linux is NOT UNIX).
#define G_OS_UNIX 
// We do have GET_IF_ADDRS
#define HAVE_GETIFADDRS


#define G_BEGIN_DECLS
#define G_END_DECLS
#define G_GNUC_UNUSED 
#define G_GNUC_WARN_UNUSED_RESULT

typedef signed char cbool;
typedef cbool gboolean;
typedef UInt8 guint8;
typedef UInt16 guint16;
typedef UInt32 guint32;
typedef UInt64 guint64;
typedef unsigned int guint;
typedef signed int gint;
typedef long glong;
typedef char gchar;
typedef unsigned char guchar;
typedef void* gpointer;
typedef unsigned long gsize;

typedef struct timeval GTimeVal;
#define G_GUINT64_FORMAT "lu"


typedef struct {
	const char *key;
	unsigned int value;
} CompatDebugKey;
#define GDebugKey CompatDebugKey

// Supposed to expand to string identifying the current function
#define G_STRFUNC "<unknown function: feature not ported>"


// Memory allocation will be done by malloc/free
#define g_slice_new0(TYPE)  calloc(1,sizeof(TYPE))
#define g_slice_free(TYPE,ref) free(ref)

#define compat_new0(struct_type, n_structs) (n_structs ? (struct_type*)calloc(n_structs, sizeof(struct_type)) : NULL)
#define g_new0(struct_type, n_structs) compat_new0(struct_type, n_structs)

// This one HAS to be free()
#define g_free(ref) free(ref)

// String functions:
#define g_strdup(src) compat_strdup(src)
char* compat_strdup(const char* src);
#define g_strlcpy(dest,src,size) strlcpy(dest, src, size)

// Memory copying
void* compat_memdup(const void* src, unsigned int byte_size);
#define g_memdup(src,size) compat_memdup(src,size)
char* compat_strndup(const char* str, size_t n);
#define g_strndup(s,n) compat_strndup(s, n)

// logging
#define compat_debug(...)
#define g_debug(...)

// Asserts and warnings stuff:
#define g_assert(val) 
// Ok, not reached, so?
#define g_assert_not_reached()
#define g_return_if_reached() return
#define g_return_val_if_reached(val) return val
#define g_return_val_if_fail(expr, val) {if(!expr){printf("Oppps!!!");return val;}} 
#define g_warning printf

// Surprise is not defined by default:
#ifndef MIN
#define MIN(a,b)  ((a)<(b))?(a):(b)
#define MAX(a,b)  ((a)>(b))?(a):(b)
#endif

#define g_snprintf snprintf

#define g_get_current_time(result) gettimeofday(result,0)
void compat_time_val_add(struct timeval* v, long microseconds);
#define g_time_val_add(t,m) compat_time_val_add(t,m)
#endif