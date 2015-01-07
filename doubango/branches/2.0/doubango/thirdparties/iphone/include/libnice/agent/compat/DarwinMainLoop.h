/*
 *  DarwinMainLoop.h
 *  libnice-darwin
 *
 *  Created by Vadim Tsyganok on 8/21/10.
 *  Copyright 2010 tsyganok.com. All rights reserved.
 *
 */

// This is definition to represent Darwin's main loop
#import <CoreFoundation/CoreFoundation.h>
#define GMainLoop CFRunLoopRef
#define GSource CFRunLoopSource