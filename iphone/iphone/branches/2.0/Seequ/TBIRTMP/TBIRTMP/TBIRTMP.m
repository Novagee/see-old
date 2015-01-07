
//
//  tinyRTMP.m
//  tinyRTMP
//
//  Created by Grigori Jlavyan on 10/16/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//
//
#import "TBIRTMP.h"
#import <Foundation/Foundation.h>

int TBI_debug_function(const void* arg, const char* fmt, ...){
    va_list argList;
    va_start (argList, fmt);
    NSLogv([NSString stringWithUTF8String:fmt], argList);
    va_end (argList);
    return 0;
}


int native_debug_function(char* fmt, ...)
{
    @autoreleasepool {
        va_list args;
        va_start (args, fmt);
        NSLogv([NSString stringWithUTF8String:fmt], args);
        va_end (args);
    }
    return 0;
}

void callBackEvent(rtmp_event_t *event)
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:event->rtmp_call_event], @"rtmp_call_event"
                              , [NSNumber numberWithInt:event->client_type], @"client_type"
                              , [NSString stringWithFormat:@"%.*s", event->callNumber.av_len, event->callNumber.av_val], @"callNumber"
                              , [NSString stringWithFormat:@"%.*s", event->media.av_len, event->media.av_val], @"media"
                              , [NSString stringWithFormat:@"%.*s", event->FlashMessage.av_len, event->FlashMessage.av_val], @"FlashMessage"
                              , [NSString stringWithFormat:@"%s", (event->messageType ? event->messageType : "")], @"messageType"
                              , [NSNumber numberWithInt: event->call_type], @"call_type"
                              , nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Registration_is_ready" object:userInfo];

}

void callBackChatEvent(rtmp_event_t *event)
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:event->rtmp_call_event], @"rtmp_call_event"
                              , [NSData dataWithBytes:event->messageType length:strlen(event->messageType)], @"messageType"
                              , [NSNumber numberWithInt:event->chatMsgType], @"chatMsgType"
                              , nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"rtmp_chat_event" object:userInfo];
}

int getResourceFilePath(const char* fileName, char* filePath, int len)
{
    if(!filePath)
        return -1;
    NSString *soundFilePath = [[NSBundle mainBundle] resourcePath];
    if(!soundFilePath)
        return -2;
    
    if(fileName)
        soundFilePath = [soundFilePath stringByAppendingPathComponent:[NSString stringWithUTF8String:fileName]];
    
    if(soundFilePath.length > len)
        return -3;
    
    strcpy(filePath, [soundFilePath UTF8String]);
    
    return soundFilePath.length;
}

int getDocumentsFilePath(const char* fileName, char* filePath, int len)
{
    if(!filePath)
        return -1;
    
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    if(!documentsDirectory)
        return -2;
    
    if(fileName)
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:fileName]];

    if(documentsDirectory.length > len)
        return -3;
    
    strcpy(filePath, [documentsDirectory UTF8String]);
    
    return documentsDirectory.length;
}
