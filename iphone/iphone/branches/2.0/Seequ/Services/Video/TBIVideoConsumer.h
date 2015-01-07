//
//  TBIVideoConsumer.h
//  Zangi
//
//  Created by Norayr Harutyunyan on 10/30/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "OpenGlView.h"


#define kTBIReceivVideoFrame_Name @"TBIReceivVideoFrame_Name"
#define LendscapeModeZoom 1.5

static unsigned int decoderWidth;
static unsigned int decoderHeight;


@interface TBIVideoConsumer : NSObject {
    OpenGlView* mDisplay;

    
	uint8_t* _mBufferPtr;
	size_t _mBufferSize;


    
    int tmpWidth;
	int tmpHeight;
    
	int mWidth;
	int mHeight;
    
	unsigned int Width;
	unsigned int Height;
    
    BOOL isUpdateFrame;
    BOOL isFirstFrame;
    UIInterfaceOrientation interfaceOrientation;
    
    
    int displayState;
    BOOL displaySplited;
    int displayIsLandscape;
    
    int oldDisplayState;
    BOOL oldDisplaySplited;
    int oldDisplayIsLandscape;

    uint64_t numberOfPackage;
    BOOL isDisplayStateChange;
    
    CGRect fitToRect;
   
}

-(uint64_t)getNumberOfFrame;
+ (TBIVideoConsumer *) sharedVideoConsumer;
- (void) set_mBufferPtr:(uint8_t*)frame frameSize:(int)frameSize width:(int)width height:(int)height;
+ (int) consumeFrame:(void*) _frame;
- (int) drawFrame;
- (void) setOrientation:(AVCaptureVideoOrientation)orientation;
- (void) setDisplay:(OpenGlView*)display;
- (void) StartVideoConsume;
- (OpenGlView*) getOpenGlViewmDisplay;

+ (void) initVideoSession;
- (void) stopVideoRender;
- (void) RemotVideoFrameChangedTo:(int)state Split:(BOOL)splited Orientation:(BOOL)isLandscape frame:(CGRect)frame ;

@end