/*
 *  Base64.h
 *  libnice-darwin
 *
 *  Created by Vadim Tsyganok on 8/20/10.
 *  Copyright 2010 tsyganok.com. All rights reserved.
 *
 */
#import <CoreFoundation/CoreFoundation.h>
UInt8* CompatBase64Encode(const void *buffer, size_t length, bool separateLines, size_t *outputLength);
void *CompatBase64Decode(const char *inputBuffer, size_t length, size_t *outputLength);
// This one is for 0-terminated strings specifically
void *CompatBase64DecodeString(const char *inputBuffer, size_t *outputLength);

// de-GNU stuff:

#define g_base64_decode(buffer, outputLength) CompatBase64DecodeString(buffer, outputLength)
#define g_base64_encode(data,length) (char*)(CompatBase64Encode(data, length, FALSE, NULL))