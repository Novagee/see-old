//
//  TBIVideoProducer.h
//  Zangi
//
//  Created by Norayr Harutyunyan on 10/29/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoSessionMng.h"
#import "TBICamera.h"

@interface TBIVideoProducer : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession *CaptureSession;
	AVCaptureDevice *CaptureDevice;
    VideoSessionMng* videoMng;
	UIView* Preview;
    AVCaptureVideoOrientation Orientation;
    
    BOOL UseFrontCamera;

    int startTime;
    BOOL mIsDownScale;
    uint8_t* imagePtr;
    uint32_t imageMaxSize;
    int mWidth;
    int mHeight;
    
    BOOL isVP8;
}

- (void) StartVideoCapture;
- (BOOL) StopVideoCapture;
- (void) StartSendingVideo;
- (void) StopSendingVideo;
- (void) setPreview:(UIView*)preview;
- (void) setOrientation:(AVCaptureVideoOrientation)orientation;
- (void) toggleCamera;
-(void) StartVideoCaptureModule;
- (void) StartVideoCaptureWithPath352x288;
- (void) StartVideoCaptureWithPath176x144;
- (BOOL) StopVideoCaptureImedently;
- (void) SetDownScale:(BOOL) bDownScale;

@end
