//
//  TBIVideoProducer.m
//  Zangi
//
//  Created by Norayr Harutyunyan on 10/29/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "TBIVideoProducer.h"
#import "idoubs2AppDelegate.h"

#import <AVFoundation/AVCaptureDevice.h>

@implementation TBIVideoProducer

#define FPS 12
#define mIsH264HWEnc 1

- (id) init {
    self = [super init];
    
    if (self) {
        UseFrontCamera = YES;
        Orientation = AVCaptureVideoOrientationPortrait;
        imagePtr = NULL;
        imageMaxSize = 0;
    }
    
    return self;
}

- (void) StartVideoCaptureWithPath176x144{
    if(mIsH264HWEnc)
    {
        isVP8 = FALSE;
        videoMng = [[VideoSessionMng alloc] init];
        int fps = 12;//[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->video.send_fps;
        int width = 176;//[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->video.send_width;
        int height = 144;//[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->video.send_height;
        
        
        [videoMng creatVideoSessionWithFPSandFileName:fps Width:width Height:height file_name:@"test----1.mp4"];
        [videoMng startWriting];
        [self StartVideoCaptureModule];
        //[videoMng startWriting];
    }
	NSLog(@"Video capture started");
}
- (void) StartVideoCaptureWithPath352x288{
    if(mIsH264HWEnc)
    {
        isVP8 = FALSE;
        videoMng = [[VideoSessionMng alloc] init];
        int fps = 12;//[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->video.send_fps;
        int width = 352;//[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->video.send_width;
        int height = 288;//[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->video.send_height;
        
        [videoMng creatVideoSessionWithFPSandFileName:fps Width:width Height:height file_name:@"test----2.mp4"];
        [videoMng startWriting];
        [self StartVideoCaptureModule];
        //[videoMng startWriting];
    }
	NSLog(@"Video capture started");
}

- (void) StartVideoCapture {
    
    mIsDownScale = TRUE;
	[self StartVideoCaptureModule];
    
    if(mIsH264HWEnc)
    {
        rtmp_manager_t *manager = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager];
        
        isVP8 = manager->isVpx;
        
        int fps = 12;
        int width = 352;
        int height = 288;
        
        if(manager && manager->videoSession)
        {
            fps = manager->videoSession->video.send.fps;
            width = manager->videoSession->video.send.width;
            height = manager->videoSession->video.send.height;
        }
        
        if (videoMng) {
            [videoMng stopStreaming];
        }
        //
        
        if(manager->videoSession && manager->videoSession->codec && manager->videoSession->codec->format == MEDIA_CODEC_FORMAT_VP8)
        {
            //[videoMng startStreaming:true];
        }else{
            videoMng = [[VideoSessionMng alloc] init];
            [videoMng creatVideoSessionWithFPS:fps Width:width Height:height];
            [videoMng startStreaming:false];
        }
    }
	NSLog(@"Video capture started");
}

- (void) StartVideoCaptureModule {
    NSLog(@"Starting Video stream");
	if(CaptureSession) {
//        [CaptureSession stopRunning];
//        CaptureSession = nil;

        CaptureSession.sessionPreset =AVCaptureSessionPreset352x288;
        
        
        if ([NSThread currentThread] != [NSThread mainThread]) {
            [self performSelectorOnMainThread:@selector(StartSendingVideo) withObject:nil waitUntilDone:YES];
        }
        else {
            [self StartSendingVideo];
        }		NSLog(@"Already capturing");
		return;
	}
    
    
	CaptureDevice = UseFrontCamera ? [TBICamera frontFacingCamera] : [TBICamera backCamera];
	if(!CaptureDevice){
		NSLog(@"Failed to get valide capture device");
		return;
	}
	
	NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:CaptureDevice error:&error];
    if (!videoInput){
        NSLog(@"Failed to get video input: %@", error);
		CaptureDevice = nil;
        return;
    }
	
    CaptureSession = [[AVCaptureSession alloc] init];
    
    
    //	if(mHeight <= 144){
    //		mCaptureSession.sessionPreset = AVCaptureSessionPreset352x288;
    //	}
    //	else if(mHeight <= 240){
    //		mCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
    //	}
    //	else if(mHeight <= 288){
    CaptureSession.sessionPreset = AVCaptureSessionPreset352x288;
    //	}
    //	else if(mHeight <= 480){
    //		mCaptureSession.sessionPreset = AVCaptureSessionPresetHigh;
    //	}
    //	else {
    //		mCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
    //	}
    CaptureSession.sessionPreset = AVCaptureSessionPreset352x288;
    //    mCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
    //mCaptureSession.sessionPreset = AVCaptureSessionPreset352x288;
    [CaptureSession addInput:videoInput];
    
    // Currently, the only supported key is kCVPixelBufferPixelFormatTypeKey. Recommended pixel format choices are
	// kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange or kCVPixelFormatType_32BGRA.
	// On iPhone 3G, the recommended pixel format choices are kCVPixelFormatType_422YpCbCr8 or kCVPixelFormatType_32BGRA.
	//
    
    if ([CaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] &&
        [CaptureDevice lockForConfiguration:&error]) {
        [CaptureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        [CaptureDevice unlockForConfiguration];
    }
    
    AVCaptureVideoDataOutput *avCaptureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                              nil];
    
    avCaptureVideoDataOutput.videoSettings = settings;
    //    avCaptureVideoDataOutput.minFrameDuration = CMTimeMake(1, mFps);
	avCaptureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    
    dispatch_queue_t queue = dispatch_queue_create("org.protime", NULL);
    [avCaptureVideoDataOutput setSampleBufferDelegate:self queue:queue];
    [CaptureSession addOutput:avCaptureVideoDataOutput];
	
	// orientation
    
// JSC   UIDevice *device = [UIDevice currentDevice];
// JSC   UIDeviceOrientation devOr = device.orientation;
    AVCaptureVideoOrientation avCor;
// JSC
//    switch (devOr) {
//        case UIDeviceOrientationFaceDown:
//        case UIDeviceOrientationFaceUp:
//        case UIDeviceOrientationPortrait:
//            avCor = AVCaptureVideoOrientationPortrait;
//            break;
//        case UIDeviceOrientationPortraitUpsideDown:
//            avCor = AVCaptureVideoOrientationPortraitUpsideDown;
//            break;
//        case UIDeviceOrientationLandscapeLeft:
//            avCor = AVCaptureVideoOrientationLandscapeLeft;
//            break;
//        case UIDeviceOrientationLandscapeRight:
//            avCor = AVCaptureVideoOrientationLandscapeRight;
//            break;
//        default:
//            break;
//    }
    avCor = AVCaptureVideoOrientationLandscapeLeft;
    for(int i = 0; i < [[avCaptureVideoDataOutput connections] count]; i++) {
        AVCaptureConnection *captureConnection = [[avCaptureVideoDataOutput connections] objectAtIndex:i];
        if(captureConnection.supportsVideoOrientation) {
            captureConnection.videoOrientation = avCor;
        }
//        [captureConnection setVideoMinFrameDuration:CMTimeMake(1, FPS)];
//        [captureConnection setVideoMaxFrameDuration:CMTimeMake(1, FPS)];
    }
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:&error];
    if(error) {
        NSLog(@"%@", error);
    }
    [device setActiveVideoMinFrameDuration:CMTimeMake(1, FPS)];
    [device setActiveVideoMaxFrameDuration:CMTimeMake(1, FPS)];
    [device unlockForConfiguration];
    
	
    //dispatch_release(queue);
	
	if([NSThread currentThread] != [NSThread mainThread]){// From Doubango worker thread?
		[self performSelectorOnMainThread:@selector(StartSendingVideo) withObject:nil waitUntilDone:YES];
	}
	else {
		[self StartSendingVideo];
	}
}

- (BOOL) StopVideoCapture {
    [self StopSendingVideo];
	if(![NSThread isMainThread]){
		[self performSelectorOnMainThread:@selector(stopPreview) withObject:nil waitUntilDone:YES];
	}
	else {
		[self stopPreview];
	}
    
    if(mIsH264HWEnc && videoMng) {
        if ([videoMng stopStreaming]) {
            [videoMng closeFile];
            videoMng = nil;
        } else {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL) StopVideoCaptureImedently {
    [self StopSendingVideo];
    [self stopPreview];
    
    if(mIsH264HWEnc && videoMng) {
        if ([videoMng stopStreamingImedently]) {
            [videoMng closeFile];
            videoMng = nil;
        } else {
            return NO;
        }
    }
    
    return YES;
}

- (void) StartSendingVideo {
	if (CaptureSession) {
		//if (![CaptureSession isRunning] || [CaptureSession isInterrupted]) {
			[CaptureSession startRunning];
		//}
	}
}


- (void) StopSendingVideo {
	if (CaptureSession) {
		if ([CaptureSession isRunning] ) {
			[CaptureSession stopRunning];
        }
        CaptureDevice = nil;
	}
}

- (void) setPreview:(UIView*)preview {
	if (preview == nil) {
		// stop preview
		[self stopPreview];
		if (Preview) {
			// remove views
			for (UIView *view in Preview.subviews) {
				[view removeFromSuperview];
			}
			// remove layers
			for(CALayer *ly in Preview.layer.sublayers){
				if([ly isKindOfClass: [AVCaptureVideoPreviewLayer class]]){
					[ly removeFromSuperlayer];
					break;
				}
			}
			Preview = nil;
		}
	}
	else {
        if (Preview == preview) {
            NSArray *arraySublayers = Preview.layer.sublayers;
            for (AVCaptureVideoPreviewLayer *ly in arraySublayers) {
                if ([ly isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
                    [self setPreviewOrentation:ly orientation:AVCaptureVideoOrientationPortrait];

                    ly.frame = Preview.bounds;
                    break;
                }
            }
            if (![CaptureSession isRunning]) {
                [CaptureSession startRunning];
            }
        } else {
            // start preview
            
            if ((Preview = preview)) {
                [self startPreview];
            }
        }
	}
}

- (void) startPreview {
	if(CaptureSession && Preview){
//        AVCaptureVideoPreviewLayer* previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:CaptureSession];
		AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:CaptureSession];
		previewLayer.frame = Preview.bounds;
		previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//		if(previewLayer.orientationSupported){
//			previewLayer.orientation = Orientation;
//		}
		
		// remove all sublayers and add new one
		if(Preview){
			for(CALayer *ly in Preview.layer.sublayers){
				if([ly isKindOfClass:[AVCaptureVideoPreviewLayer class]]){
					[ly removeFromSuperlayer];
					break;
				}
			}
			[Preview.layer addSublayer:previewLayer];
		}
        [CaptureSession beginConfiguration];
        NSArray *outputs = [CaptureSession outputs];
        
        for (AVCaptureVideoDataOutput *avCaptureVideoDataOutput in outputs) {
            for(int i = 0; i < [[avCaptureVideoDataOutput connections] count]; i++) {
                AVCaptureConnection *captureConnection = [[avCaptureVideoDataOutput connections] objectAtIndex:i];
                if(captureConnection.supportsVideoOrientation) {
                    [captureConnection setVideoOrientation:Orientation];
                }
            }
        }
        [CaptureSession commitConfiguration];
        
		if(![CaptureSession isRunning]){
			[CaptureSession startRunning];
		}
	}
}

- (void)stopPreview{
	if(CaptureSession){
		if([CaptureSession isRunning]){
			[CaptureSession stopRunning];
		}
	}
	// remove all sublayers
	if(Preview){
		for(CALayer *ly in Preview.layer.sublayers){
			if([ly isKindOfClass:[AVCaptureVideoPreviewLayer class]]){
				[ly removeFromSuperlayer];
				break;
			}
		}
	}
    Preview = nil;
}
-(void) setPreviewOrentation:(AVCaptureVideoPreviewLayer*)ly orientation:(AVCaptureVideoOrientation)orientation{
    [CaptureSession beginConfiguration];
    if ([ly respondsToSelector:@selector(connection)])
    {
        if ([ly.connection isVideoOrientationSupported])
        {
            [ly.connection setVideoOrientation:orientation];
        }
    }
    else
    {
        // Deprecated in 6.0; here for backward compatibility
        if ([ly.connection isVideoOrientationSupported])
        {
            [ly.connection setVideoOrientation:orientation];
        }
    }
    [CaptureSession commitConfiguration];
}



- (void) setOrientation:(AVCaptureVideoOrientation)orientation {
    
    [CaptureSession beginConfiguration];
    
    if(orientation==3){
        orientation = 4 ;
        
    }else if(orientation==4){
        orientation = 3 ;
    }
    NSLog(@"#################################### orientation = %i",orientation);
    
    NSArray *outputs = [CaptureSession outputs];
    
    for (AVCaptureVideoDataOutput *avCaptureVideoDataOutpu in outputs) {
        for(int i = 0; i < [[avCaptureVideoDataOutpu connections] count]; i++) {
            AVCaptureConnection *captureConnection = [[avCaptureVideoDataOutpu connections] objectAtIndex:i];
            if(captureConnection.supportsVideoOrientation) {
                [captureConnection setVideoOrientation:orientation];
            }
        }
    }
    NSArray *arraySublayers = Preview.layer.sublayers;
    for (AVCaptureVideoPreviewLayer *ly in arraySublayers) {
        if ([ly isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
            ly.frame = Preview.bounds;
            [self setPreviewOrentation:ly orientation:orientation];
        }
    }
    Orientation = orientation;
    [CaptureSession commitConfiguration];
}

- (void) SetDownScale:(BOOL) bDownScale{
    if(mIsDownScale != bDownScale)
        mIsDownScale = bDownScale;
}

- (void) toggleCamera {
	UseFrontCamera = !UseFrontCamera;

	CaptureDevice = UseFrontCamera ? [TBICamera frontFacingCamera] : [TBICamera backCamera];
	if(!CaptureDevice){
		NSLog(@"Failed to get valide capture device");
		return;
	}
	
	NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:CaptureDevice error:&error];
    if (!videoInput){
        NSLog(@"Failed to get video input: %@", error);
		CaptureDevice = nil;
        return;
    }

    for (AVCaptureDeviceInput *deviceInput in CaptureSession.inputs) {
        //  JSC [CaptureSession removeInput:[CaptureSession.inputs objectAtIndex:0]];
        [CaptureSession removeInput:deviceInput];
    }
    
    if ([CaptureSession canAddInput:videoInput]) {
        [CaptureSession addInput:videoInput];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    //    NSLog(@"didOutputSampleBuffer");
//    static uint64_t time_now =  TBI_time_epoch();
//    static int count =0;
//    
//    count++;
//    
//    if((TBI_time_epoch()-time_now)>1000){
//        NSLog(@"###### *************** %i",count);
//        time_now = TBI_time_epoch();
//        count = 0;
//    }
    
    if( !CMSampleBufferDataIsReady(sampleBuffer) )
        return;
    
    
    
//    if([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->isHold){
//        return;
//    }
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    rtmp_manager_t *manager = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager];
    
    if(manager && manager->videoSession && manager->videoSession->isReconnecting){
        return ;
    }
    
    if(CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess)
    {
        if(!isVP8)
        {
            [videoMng writetofile:sampleBuffer];
        }
        else
        {

            size_t plane_width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
            size_t plane_height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
            
            //NSLog(@"************************************* plane_width = %d plane_height = %d",plane_width,plane_height);
            
            
            uint8_t* y_src= (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
            uint8_t* cbcr_src= (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
            
            int y_byte_per_row = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
            int cbcr_byte_per_row = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
            
//            int uv_w, uv_h;
            if(mIsDownScale)
            {
                mWidth = plane_width/2;
                mHeight = plane_height/2;
            }
            else
            {
                mWidth = plane_width;
                mHeight = plane_height;
            }
// JSC
//            uv_w = mWidth/2;
//            uv_h = mHeight/2;
            
            int ysize, usize;
            ysize = mWidth * mHeight;
            usize = ysize/4;
            
            uint32_t imageSize = (mWidth * mHeight * 3)/2;
            if(imagePtr == NULL || imageMaxSize < imageSize)
            {
                imageMaxSize = imageSize + 16;
                imagePtr = (uint8_t*)TBI_realloc(imagePtr, imageMaxSize);
            }

            uint8_t* u_dest = imagePtr + ysize;
            uint8_t* v_dest = u_dest + usize;
            deinterlace_down_scale_neon(y_src, cbcr_src, imagePtr, u_dest, v_dest, mWidth, mHeight, y_byte_per_row, cbcr_byte_per_row, mIsDownScale);
            if([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession && [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->codec)
            {
                media_codec_t* codec = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->codec;
                codec->video.change_resolution(codec, mWidth, mHeight);
            }

//            if(plane_width > plane_height){
//                if([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession && [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->codec)
//                    [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->codec->rotate.isLandscape = 1;
//            }else{
//                if([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession && [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->codec)
//                    [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->codec->rotate.isLandscape = 0;
//            }
            
            rtmp_manager_send_video([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager], imagePtr, imageSize);
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    }
}

- (void) dealloc {
    [self StopVideoCapture];

}

@end
