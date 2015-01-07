
#include "DDebug.h"

#include "SipStack.h"

#include "Common.h"

#if ANDROID /* callbacks will fail with jni */
#	include <android/log.h>
#	define ANDROID_DEBUG_TAG "tinyWRAP"
#endif

/* Very Important ==> never call functions which could raise debug callbacks into callback functions
*  Callbacks should not used with Android (JNI).
*/

enum cb_type{
	cb_info,
	cb_warn,
	cb_error,
	cb_fatal
};

int DDebugCallback::debug_info_cb(const void* arg, const char* fmt, ...)
{
    return 0;}

int DDebugCallback::debug_warn_cb(const void* arg, const char* fmt, ...){
    return 0;}

int DDebugCallback::debug_error_cb(const void* arg, const char* fmt, ...){
    return 0;}

int DDebugCallback::debug_fatal_cb(const void* arg, const char* fmt, ...){

    return 0;}

