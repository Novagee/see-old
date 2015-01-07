//
//  VideoSessionMng.h
//  rtspstreamer
//
//  Created by Samvel on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoSessionMng : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate,NSStreamDelegate> {
    AVAssetWriter *videoWriter;
    AVAssetWriterInput *videoWriterInput;
    
    NSString* path;
    CMTime lastSampleTime;
    NSTimer* timer;
    uint32_t frameWriteTime;
    
    BOOL isRunning;
    FILE* file;
    char* data;
    int dataSz;
    int dataMaxSz;
    char* sps;
    int spsSz;
    char* pps;
    int ppsSz;
    unsigned int frmSz;
    
    int mWidth;
    int mHeight;
    int mfps;
    int ms;
    
    BOOL isSetTime;
}

- (BOOL) creatVideoSessionWithFPS:(int)fps Width:(int)width Height:(int)height;
- (BOOL)initWriter:(NSURL*)outputURL Width:(int)width Height:(int)height FPS:(int)fps;
//- (BOOL)initReader:(NSURL*)inputURL;
- (BOOL) creatVideoSessionWithFPSandFileName:(int)fps Width:(int)width Height:(int)height file_name:(NSString*)file_name;

- (void)writetofile:(CMSampleBufferRef)sampleBuffer;
- (BOOL)readfileheader;
- (void)startsend;
-(void) closeFile;
- (BOOL)startStreaming:(BOOL)isVP8;
- (BOOL)stopStreaming;
- (BOOL)stopStreamingImedently;
- (void)newVideoSample:(CMSampleBufferRef)sampleBuffer;
//- (BOOL)playVideo;
//- (CMSampleBufferRef)readVideoBuffer;
- (NSString*)getWorkingDir;
- (BOOL)startWriting;
- (void)stopWriting;
- (void) stopStreaming_Asynchronously;
//- (BOOL)stopStreamingImedentlyl;
@property (strong) AVAssetWriter *videoWriter;
@property (strong) AVAssetWriterInput *videoWriterInput;

@property (readwrite) BOOL isRunning;
@property (readonly) NSString* path;

@end
