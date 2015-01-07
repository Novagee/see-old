//
//  VideoSessionMng.m
//  rtspstreamer
//
//  Created by Samvel on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoSessionMng.h"
#import "idoubs2AppDelegate.h"
#include "tsk_debug.h"

@implementation VideoSessionMng

@synthesize videoWriter;
@synthesize videoWriterInput;
@synthesize isRunning;
@synthesize path;


- (id) init {
	self = [super init];
    self.isRunning = NO;
    self->file = NULL;
    self->frmSz = 0;
    self->data = NULL;
    self->dataSz = 0;
    self->frameWriteTime = 0;
	return self;
}

- (BOOL) creatVideoSessionWithFPS:(int)fps Width:(int)width Height:(int)height {
    path = [NSString stringWithFormat:@"%@/test.mp4", [self getWorkingDir]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:path error:&error];
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    if (![self initWriter:url Width:width Height:height FPS:fps])
        return NO;
    
    return YES;
}

- (BOOL) creatVideoSessionWithFPSandFileName:(int)fps Width:(int)width Height:(int)height file_name:(NSString*)file_name {
    path = [NSString stringWithFormat:@"%@/%@",[self getWorkingDir],file_name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:path error:&error];
        if (error != nil)
            NSLog(@"Error: file removing failed: %@", error);
        NSLog(@"File successfully removed");
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    if (![self initWriter:url Width:width Height:height FPS:fps])
        return NO;
    
    return YES;
}


///@todo  levon
- (NSString*)getWorkingDir {
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    return documentsDir;
}

- (BOOL)initWriter:(NSURL*)outputURL Width:(int)width Height:(int)height FPS:(int)fps {
    NSError *error = nil;
    videoWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeMPEG4 error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoCompressionProps = nil;
    
    if([[[UIDevice currentDevice].systemVersion substringToIndex:1] integerValue] < 7 || rtmp_manager_get_phone_version() < iPad2){
        videoCompressionProps =  [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithDouble:200.0*1000.0], AVVideoAverageBitRateKey,
                                  [NSNumber numberWithInt:(fps)], AVVideoMaxKeyFrameIntervalKey,
                                  nil ];
    }else{
        videoCompressionProps =  [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithDouble:200.0*1000.0], AVVideoAverageBitRateKey,
                                  [NSNumber numberWithInt:(fps)], AVVideoMaxKeyFrameIntervalKey,
                                  
                                  [NSNumber numberWithBool:NO], AVVideoAllowFrameReorderingKey,
                                  [NSNumber numberWithInt:fps], AVVideoAverageNonDroppableFrameRateKey,
                                  nil ];
    }
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   //AVVideoProfileLevelH264BaselineAutoLevel, AVVideoProfileLevelKey,
                                   AVVideoScalingModeResizeAspectFill, AVVideoScalingModeKey,
                                   [NSNumber numberWithInt:width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:height], AVVideoHeightKey,
                                   videoCompressionProps, AVVideoCompressionPropertiesKey,
                                   nil];
    
    
    

    videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSParameterAssert(videoWriterInput);
    videoWriterInput.expectsMediaDataInRealTime = YES;
//    videoWriter.shouldOptimizeForNetworkUse = YES;
    
    // add input
    [videoWriter addInput:videoWriterInput];
    
    if( videoWriter.status == AVAssetWriterStatusFailed )
    {
//        NSLog(@"Error: %@", videoWriter.error);
        return NO;
    }

//    NSLog(@"Video writer initialized.");
    
    mWidth = width;
    mHeight = height;
    mfps = fps;
    ms = 1000/fps*0.8;
    
    return YES;
}

- (BOOL)startStreaming:(BOOL)isVP8{
    if(isRunning || !videoWriter)
        return NO;
    
    isRunning = YES;
    
    if( videoWriter.status != AVAssetWriterStatusWriting  )
    {
        if(!isVP8)
            [videoWriter startWriting];
        isSetTime = YES;
    }
    
    [NSThread detachNewThreadSelector:@selector(startsend)
                             toTarget:self
                           withObject:nil];
    
    return YES;
}

- (BOOL)startWriting{
    if(isRunning || !videoWriter)
        return NO;
    
    isRunning = YES;
    
    if( videoWriter.status != AVAssetWriterStatusWriting  )
    {
        [videoWriter startWriting];
        isSetTime = YES;
    }
    
    return YES;
}

- (void)stopWriting {
     [videoWriter finishWritingWithCompletionHandler:nil];
}

- (BOOL)stopStreaming {
    if(!isRunning)
        return YES;
    
    isRunning = NO;

    [NSThread detachNewThreadSelector:@selector(stopStreaming_Asynchronously) toTarget:self withObject:nil];
    
    return YES;
}

- (BOOL)stopStreamingImedently {
    if(!isRunning)
        return YES;
    
    isRunning = NO;
    [self stopStreaming_Asynchronously];

    
    return YES;
}



- (void) stopStreaming_Asynchronously {
    @autoreleasepool {
        [videoWriter finishWritingWithCompletionHandler:^{
            NSLog(@"finishWriting");
        }];

        if(data)
        {
            free(data);
            data = NULL;
            dataSz = 0;
        }
        if(sps)
        {
            free(sps);
            sps = NULL;
            spsSz = 0;
        }
        if(pps)
        {
            free(pps);
            pps = NULL;
            ppsSz = 0;
        }
    }
}

- (void)writetofile:(CMSampleBufferRef)sampleBuffer{
    if(isSetTime == YES) {
        lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        if( videoWriter.status != AVAssetWriterStatusWriting  ) {
            [videoWriter startWriting];
        }
        
        [videoWriter startSessionAtSourceTime:lastSampleTime];
        isSetTime = NO;
    }
    
    [self newVideoSample:sampleBuffer];
}

- (void) newVideoSample:(CMSampleBufferRef)sampleBuffer {
    if (isRunning) {
        if (videoWriter.status > AVAssetWriterStatusWriting) {
            NSLog(@"Warning: writer status is %d", videoWriter.status);
            if( videoWriter.status == AVAssetWriterStatusFailed )
                NSLog(@"Error: %@", videoWriter.error);
            return;
        }
        
        if (videoWriter.status == AVAssetWriterStatusWriting && ![videoWriterInput appendSampleBuffer:sampleBuffer])
            NSLog(@"Unable to write to video input");
    }
}

- (BOOL)readfileheader {
    unsigned int atomSz;
    int size;
    char buf[8];
    while (!feof(file)) 
    {
        size = fread(buf, sizeof(char), 8, file);
        if(size < 8)
            return NO;
        
        atomSz = (unsigned int)ntohl(*((unsigned int*)buf));
        if(strncmp(buf + sizeof(unsigned int), "mdat", strlen("mdat")) == 0)
        {
            return YES;
        }
        
        fseek(file, atomSz - 8, SEEK_CUR);
    }
    
    return NO;
}

- (void) closeFile {
    if (file)
        fclose(file);
}


///@todo levon

//- (void)startsend {
//    int pos, fileSize, unreadContent, readSize;
//
//    char buf[sizeof(unsigned int)];
//    
//    while (1) {
//        if(!isRunning)
//            return;
//        
//        if (!file) {
//            file = fopen([path UTF8String], "rb");
//            if (file) {
//                if (![self readfileheader]) {
//                    fclose(file);
//                    file = NULL;
//                }
//            }
//        }
//        
//        if (file) {
//            pos = ftell(file);
//            fseek(file, 0L, SEEK_END);
//            fileSize = ftell(file);
//            fseek(file, pos, SEEK_SET);
//            
//            unreadContent = fileSize - pos;
//            if (frmSz == 0 && fileSize - pos >= sizeof(unsigned int)) {
//                readSize = fread(buf, sizeof(char), sizeof(unsigned int), file);
//                if (readSize >= sizeof(unsigned int)) {
//                    frmSz = ntohl(*((unsigned int*)buf));
//                    readSize -= sizeof(unsigned int);
//                    if (data == NULL) {
//                        dataSz = frmSz;
//                        data = (char*)malloc(dataSz);
//                    }
//                    else if(frmSz > dataSz)
//                    {
//                        dataSz = frmSz;
//                        data = (char*)realloc(data, dataSz);
//                    }
//                }
//            }
//            if (frmSz > 0 && unreadContent >= frmSz) {
//                readSize = fread(data, sizeof(char), frmSz, file);
//                if (readSize >= frmSz) {
//                    if (isRunning) {
//                        rtmp_manager_send_video([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager], data, frmSz);
//                    }
//                    frmSz = 0;
//                }
//                
//                [NSThread sleepForTimeInterval:0.03];
//                continue;
//            }
//        }
//        
//        [NSThread sleepForTimeInterval:0.005];
//    }
//
//    fclose(file);
//    file = NULL;
//}

- (void)startsend
{
    int pos, fileSize, unreadContent, readSize;
    char buf[sizeof(unsigned int)];
    char *tmpBuf = NULL;
    int tmpSize = 0;
    tbi_bool_t bIsFirst = tbi_true;
    while (1) {
        if(!isRunning)
            return;
        
        if(!file)
        {
            file = fopen([path UTF8String], "rb");
            if(file)
            {
                if(![self readfileheader])
                {
                    fclose(file);
                    file = NULL;
                }
            }
        }
        
        if(file)
        {
            pos = ftell(file);
            fseek(file, 0L, SEEK_END);
            fileSize = ftell(file);
            fseek(file, pos, SEEK_SET);
            
            unreadContent = fileSize - pos;
            //            if(!b && unreadContent == 0)
            //            {
            //                time = GetTickCount();
            //                b = YES;
            //            }
            //            else if(b && unreadContent > 0)
            //            {
            //                NSLog(@"write time ================ %d", GetTickCount() - time);
            //                b = NO;
            //            }
            if(frmSz == 0 && fileSize - pos >= sizeof(unsigned int))
            {
                readSize = fread(buf, sizeof(char), sizeof(unsigned int), file);
                if(readSize >= sizeof(unsigned int))
                {
                    frmSz = ntohl(*((unsigned int*)buf));
// JSC                   readSize -= sizeof(unsigned int);
                    if(!tmpBuf || tmpSize < frmSz)
                    {
                        tmpBuf = (char*)realloc((void*)tmpBuf, frmSz);
                        tmpSize = frmSz;
                    }
                }
            }
            if(frmSz > 0 && unreadContent >= frmSz)
            {
                readSize = fread(tmpBuf, sizeof(char), frmSz, file);
                if(readSize >= frmSz) {
                    if(bIsFirst)
                    {
                        bIsFirst = tbi_false;
                    }
                    else if(tmpBuf[1] != 1)
                    {
                        if(isRunning){
                            rtmp_manager_send_video([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager], data, dataSz);
                            dataSz = 0;
                        }
                    }
                    else if(tmpBuf[1] == 1)
                    {
                        printf("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n");
                    }
                    
                    if(!data || dataMaxSz < (sizeof(unsigned int) + dataSz + frmSz))
                    {
                        dataMaxSz = sizeof(unsigned int) + dataSz + frmSz;
                        data = (char*)realloc(data, dataMaxSz);
                    }
                    
                    if (dataSz > 0)
                    {
                        *((unsigned int*)&data[dataSz]) = (unsigned int)htonl(1);
                        dataSz += sizeof(unsigned int);
                    }
                    
                    if(tmpBuf) {
                        memcpy(data + dataSz, tmpBuf, frmSz);
                        dataSz += frmSz;
                    }
                    
                    frmSz = 0;
                }
                [NSThread sleepForTimeInterval:0.033];
                continue;
            }
        }
        [NSThread sleepForTimeInterval:0.01];
    }
    
    fclose(file);
    file = NULL;
}

- (void)dealloc {
    [self stopStreaming];
}

@end