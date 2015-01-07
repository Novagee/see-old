//
//  tinyRTMP.h
//  tinyRTMP
//
//  Created by Grigori Jlavyan on 10/16/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//
#import "rtmpmanager.h"

TINYRTMP_API void callBackEvent(rtmp_event_t *event);
TINYRTMP_API void callBackChatEvent(rtmp_event_t *event);
TINYRTMP_API int native_debug_function(char* fmt, ...);
TINYRTMP_API int getResourceFilePath(const char* fileName, char* filePath, int len);
TINYRTMP_API int getDocumentsFilePath(const char* fileName, char* filePath, int len);
