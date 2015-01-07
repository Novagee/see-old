/*
 *  DarwinCompat.h
 *  libnice-darwin
 *
 *  Created by Vadim Tsyganok on 8/21/10.
 *  Copyright 2010 tsyganok.com. All rights reserved.
 *
 */

// Darwin-specific compatibility
#ifndef DARWIN_COMPAT
#define DARWIN_COMPAT

#include "libnice/compat/BasicCompat.h"
#import <CoreFoundation/CoreFoundation.h>

//typedef struct __CFRunLoopSource * GSource;

// return FALSE if source should be removed:
typedef cbool (*DarwinSourceFunc)(void* data);
#define GSourceFunc DarwinSourceFunc

#define GMainContextRef  CFRunLoopRef
// CFRunLoopSourceContext

typedef struct __DarwinCompatSource * DarwinCompatSourceRef;
#define GSourceRef DarwinCompatSourceRef


// Creates timer, sets callback and attaches to run loop:
DarwinCompatSourceRef darwin_timeout(int interval, CFRunLoopRef runLoop, DarwinSourceFunc f, void* contextData);


#define GDestroyNotify CFAllocatorReleaseCallBack

CFSocketRef darwin_socket(CFSocketNativeHandle handle, CFOptionFlags callBackOptions, CFSocketCallBack f, void* contextData, CFAllocatorReleaseCallBack destroy);
DarwinCompatSourceRef darwin_add_run_loop_socket_source(CFSocketRef socket, CFRunLoopRef runLoop);

#define GIOChannelRef CFSocketRef
#define GIOCondition CFSocketCallBackType

#define G_IO_IN kCFSocketReadCallBack
// Hmmm darwin does not give real callback:
#define G_IO_ERR kCFSocketNoCallBack


// Translation of Regular run-loop stuff:

// We guarantee that currently processed source (timer) cannot be destroyed on it's own
// but we will keep the check to be able to remove this assumption later:
#define g_current_main_current_source_is_destroyed() (FALSE)

// There is weird attempt to unref main context which never been ref'd before
// so eat this call:
#define g_main_context_unref(ignore) 

// Removes source from run-loop.
void darwin_compat_source_destroy(DarwinCompatSourceRef source);
#define g_source_destroy(s) darwin_compat_source_destroy(s)

void darwin_compat_unref(DarwinCompatSourceRef source);
#define g_source_unref(s) darwin_compat_unref(s)

// Channel is socket
void darwin_socket_unref(CFSocketRef socket);
#define g_io_channel_unref(socket) darwin_socket_unref(socket)
 
#define DarwinAddress CFDataRef
#endif