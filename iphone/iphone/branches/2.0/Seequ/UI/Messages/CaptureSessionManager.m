#import "CaptureSessionManager.h"
#import "Common.h"
#define MAX_DOUBLE_TAKE_RESPONSE_LENGTH  240

static NSString * const SeequCameraCaptureStillImageIsCapturingStillImageObserverContext = @"SeequCameraCaptureStillImageIsCapturingStillImageObserverContext";

@interface CaptureSessionManager (){
    AVCaptureDevicePosition position;
}


@property (nonatomic,retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic,retain) AVCaptureDeviceInput *audioInput;
@property ( nonatomic,retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic,assign) UIDeviceOrientation deviceOrientation;

/// If true, every messages sent to the delegate will be dispatched through the main queue
@property (assign, nonatomic) BOOL dispatchDelegateMessagesOnMainQueue;

@end

//AVCaptureVideoDataOutput
@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;
@synthesize movieFileOutput = _movieFileOutput;
@synthesize delegate = _delegate;
@synthesize needToClose =_needToClose;
@synthesize messageItem = _messageItem;
@synthesize videoInput;
@synthesize audioInput;
@synthesize  device =_device;
@synthesize dispatchDelegateMessagesOnMainQueue;
@synthesize assetExport;
@synthesize isMetadataChange = _isMetadataChange;
@synthesize outputURLForExported;
#define CAPTURE_FRAMES_PER_SECOND		20

#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
        self.dispatchDelegateMessagesOnMainQueue = YES;


	}
	return self;
}

- (void)addVideoPreviewLayer {
	[self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
    self.previewLayer.connection.videoScaleAndCropFactor =1.0;
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  
}
- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition) Position
{
	NSArray *Devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *Device in Devices)
	{
		if ([Device position] == Position)
		{
			return Device;
		}
	}
	return nil;
}


-(void) finish {
    [self.captureSession stopRunning];
    [self.captureSession removeInput:videoInput];
    [self.captureSession removeInput:audioInput];
    [self.previewLayer removeFromSuperlayer];
    [self removeObserverForSession];
    
}



-(void) flipCameraInput {
    [self.captureSession stopRunning];
    [self.captureSession removeInput:self.videoInput];
    [self.captureSession removeInput:self.audioInput];
    if (position == AVCaptureDevicePositionFront) {
        position = AVCaptureDevicePositionBack;
        
    } else {
        position = AVCaptureDevicePositionFront;
        
    }

    [self addVideoInput:position];
    [self addAudioInput];
    [self.captureSession startRunning];
    
}
-(void) startWriteToFile {
    [self cameraSetOutputProperties];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [NSString stringWithFormat:@"%@/out.mp4", [paths objectAtIndex:0]];
//    NSURL *documentsDirUrl = [NSURL fileURLWithPath:documentsDirectoryPath isDirectory:YES];
    NSURL *url =[NSURL fileURLWithPath:documentsDirectoryPath isDirectory:YES];
    BOOL isDir ;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:documentsDirectoryPath isDirectory:&isDir];
        NSLog(@"file exists...-%@",fileExists?@"Yes":@"No");
         NSError* error;

        @try {
        if(fileExists) {
           [[NSFileManager defaultManager] removeItemAtPath:documentsDirectoryPath error:&error];
                NSLog(@"removeItemAtPath...");
                if (error) {
                        NSLog(@"error removeItemAtPath -%@",error);
                }
        }
                [_movieFileOutput stopRecording];
                [_movieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
      


        }
        @catch (NSException *exception) {
        
        NSLog(@" the  description of  exception  is: %@", exception.debugDescription);
    }
}
-(void)export:(NSURL*) url{
    NSLog(@"url =%@", url.absoluteString);
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString: url.absoluteString]options:nil];
    NSMutableArray *metadata = [NSMutableArray array];
    AVMutableMetadataItem *metaItem = [AVMutableMetadataItem metadataItem];
    metaItem.key = AVMetadataCommonKeyPublisher;
    metaItem.keySpace = AVMetadataKeySpaceCommon;
    metaItem.value = @"Seequ";
    [metadata addObject:metaItem];
        assetExport = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    outputURLForExported = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:@"videoExport"] stringByAppendingString:@".mp4"]];
        NSLog(@"Exported URL -%@",outputURLForExported);
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[outputURLForExported path]];
  
    @try {
        if(fileExists) {
            NSError* error;
            [[NSFileManager defaultManager] removeItemAtPath:[outputURLForExported path] error:&error];
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@" the  description of  exception  is: %@", exception.debugDescription);
    }

    
    assetExport.outputURL = outputURLForExported;
//    CMTime start = CMTimeMakeWithSeconds(1.0, 600);
//    CMTime duration = CMTimeMakeWithSeconds(3.0, 600);
//    CMTimeRange range = CMTimeRangeMake(start, duration);
//    assetExport.timeRange = range;
    
    //assetExport.outputFileType = AVFileTypeAppleM4V; // AVFileTypeMPEG4 or AVFileTypeQuickTimeMovie (video format);
    assetExport.outputFileType =  AVFileTypeQuickTimeMovie; // AVFileTypeMPEG4 or AVFileTypeQuickTimeMovie (video format);
    assetExport.metadata = metadata;
    assetExport.shouldOptimizeForNetworkUse = YES;
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        switch ([assetExport status])
        {
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"Export sucess");
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Export failed: %@", [[assetExport error] localizedDescription]);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            default:
                break;
        }
                
        if (assetExport.status == AVAssetExportSessionStatusCompleted)
            
        {
            
            
            [_delegate didFinishWriteToFile:outputURLForExported item:self.messageItem closeVideo:_needToClose];
            
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[url path]];
            @try {
                if(fileExists) {
                    NSError* error;
                    [[NSFileManager defaultManager] removeItemAtPath:[url path] error:&error];
                }
           }
            @catch (NSException *exception) {
                
                NSLog(@" the  description of  exception  is: %@", exception.debugDescription);
            }
            
            
           
        }
        else
        {
            NSLog(@"error...");
            
        }

    }];

    
}
///@todo  must  use  delegate to  notify  finishing  writing  to  the  file
-(void) stopWriteToFile {
        @try{
                [_movieFileOutput stopRecording];
        }
        @catch(NSExpression *e){
                NSLog(@"stop recording %@",[e description]);
        }
        
    
    
}
-(AVCaptureDevice*) getAudioDevice {
    NSArray*  devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    return [devices objectAtIndex:0];
}

//-(void)setFlashModeOn {
//    AVCaptureDevice *_currentDevice = self.currentVideoDeviceInput.device;
//    BOOL shouldChangeFlashMode = (_flashMode != flashMode);
//    if (![_currentDevice hasFlash] || !shouldChangeFlashMode)
//        return;
//    
//    _flashMode = flashMode;
//    
//    NSError *error = nil;
//    if (_currentDevice && [_currentDevice lockForConfiguration:&error]) {
//		
//		if (_flashMode == SCFlashModeLight) {
//			if ([_currentDevice isTorchModeSupported:AVCaptureTorchModeOn]) {
//				[_currentDevice setTorchMode:AVCaptureTorchModeOn];
//			}
//			if ([_currentDevice isFlashModeSupported:AVCaptureFlashModeOff]) {
//				[_currentDevice setFlashMode:AVCaptureFlashModeOff];
//			}
//		} else {
//			if ([_currentDevice isTorchModeSupported:AVCaptureTorchModeOff]) {
//				[_currentDevice setTorchMode:AVCaptureTorchModeOff];
//			}
//			if ([_currentDevice isFlashModeSupported:(AVCaptureFlashMode)_flashMode]) {
//				[_currentDevice setFlashMode:(AVCaptureFlashMode)_flashMode];
//			}
//		}
//        
//        [_currentDevice unlockForConfiguration];
//        
//    } else if (error) {
//        NSLog(@"error locking device for flash mode change (%@)", error);
//    }
//}
//




- (void)addObserverForSession:(AVCaptureSession*)theSession {
    // add notification observers
//    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
         [self.stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:(__bridge void *)(SeequCameraCaptureStillImageIsCapturingStillImageObserverContext)];
}

//
// Misc methods
//

- (void) dispatchBlockOnAskedQueue:(void(^)())block {
	if (self.dispatchDelegateMessagesOnMainQueue) {
		dispatch_async(dispatch_get_main_queue(), block);
	} else {
		block();
	}
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if( context == (__bridge void *)(SeequCameraCaptureStillImageIsCapturingStillImageObserverContext) ) {
//        
//		BOOL isCapturingStillImage = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
//		if ( isCapturingStillImage ) {
//            [self _willCapturePhoto];
//		} else {
//            [self _didCapturePhoto];
//        }
//        
//	} else if (context == SCCameraFocusModeObserverContext) {
//        // Update the focus UI overlay string when the focus mode changes
//        if ([self.delegate respondsToSelector:@selector(cameraUpdateFocusMode:)]) {
//            [self.delegate cameraUpdateFocusMode:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:(AVCaptureFocusMode)[[change objectForKey:NSKeyValueChangeNewKey] integerValue]]]];
//        }
//	}
//}
- (UIImage *)_uiimageFromJPEGData:(NSData *)jpegData
{
	return [UIImage imageWithData:jpegData];
}

-(AVCaptureVideoOrientation) captureOrientation{
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationLandscapeLeft:
            return  AVCaptureVideoOrientationLandscapeRight;
        case UIDeviceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationFaceDown:
            return AVCaptureVideoOrientationPortrait;
        case UIDeviceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        default:
            return AVCaptureVideoOrientationPortrait;
            
            
    }
}

- (void) capturePhoto {
    if (self.stillImageOutput) {
        self.deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        [connection setVideoOrientation:[self captureOrientation]];
        NSLog(@"the orientation is  %d",connection.videoOrientation);
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:
         ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
             
             if (!imageDataSampleBuffer) {
                 NSLog(@"failed to obtain image data sample buffer");
                 // TODO: return delegate error
                 return;
             }
             
             // add JPEG and image data
             NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             if (jpegData) {
                 // add JPEG
             //    [photoDict setObject:jpegData forKey:SCAudioVideoRecorderPhotoJPEGKey];
                 
                 // add image
                 UIImage *image = [Common fixOrientationOfImage:[self _uiimageFromJPEGData:jpegData] ];
                 
                 [self.delegate didFinishMakePhoto:image];
             } else {
                 NSLog(@"failed to create jpeg still image data");
                 // TODO: return delegate on error
             }
             
         }];
    }
}



- (void)removeObserverForSession {
    if (!self.captureSession)
        return;
//    
//    // remove notification observers (we don't want to just 'remove all' because we're also observing background notifications
//    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//    
//    // session notifications
//    [notificationCenter removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:self.captureSession];
//      [notificationCenter removeObserver:self name:AVCaptureSessionWasInterruptedNotification object:self.captureSession];
//    [notificationCenter removeObserver:self name:AVCaptureSessionInterruptionEndedNotification object:self.captureSession];
//    
//    // capture input notifications
//    [notificationCenter removeObserver:self name:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil];
//    
//    // capture device notifications
//    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
//    
//    // Applicaton
//    [notificationCenter removeObserver:self];
//    
//    // focus
////    if (self.videoInput) {
////        [self.videoInput.device removeObserver:self forKeyPath:@"adjustingFocus"];
////		// focusMode
////		[self removeObserver:self forKeyPath:@"currentVideoDeviceInput.device.focusMode"];
////	}
//    
//    // capturingStillImage
////    if (self.stillImageOutput) {
////        [self.stillImageOutput removeObserver:self forKeyPath:@"capturingStillImage" context:(__bridge void *)(SCCameraCaptureStillImageIsCapturingStillImageObserverContext)];
////    }
}

-(BOOL)hasFlash {
    return [self.device hasFlash];
}

-(void) setVideoFlashMode:(BOOL) flag{
    
    NSError *error = nil;
    if (self.device && [self.device lockForConfiguration:&error]) {
        
        if (flag) {
            if ([self.device isTorchModeSupported:AVCaptureTorchModeOn]) {
                [self.device setTorchMode:AVCaptureTorchModeOn];
            }
            if ([self.device isFlashModeSupported:AVCaptureFlashModeOff]) {
                [self.device setFlashMode:AVCaptureFlashModeOff];
            }
        } else {
            if ([self.device isTorchModeSupported:AVCaptureTorchModeOff]) {
                [self.device setTorchMode:AVCaptureTorchModeOff];
            }
            if ([self.device isFlashModeSupported:AVCaptureFlashModeOn]) {
                [self.device setFlashMode:AVCaptureFlashModeOn];
            }
        }
        
        [self.device unlockForConfiguration];
        
    } else if (error) {
        NSLog(@"error locking device for flash mode change (%@)", error);
    }


}

-(void) setPhotoFlashMode:(AVCaptureFlashMode) flag{
    
    NSError *error = nil;
    if (self.device && [self.device lockForConfiguration:&error]) {
        
        if (flag == AVCaptureFlashModeOff) {
            if ([self.device isTorchModeSupported:AVCaptureTorchModeOff]) {
                [self.device setTorchMode:AVCaptureTorchModeOff];
            }
            if ([self.device isFlashModeSupported:AVCaptureFlashModeOff]) {
                [self.device setFlashMode:AVCaptureFlashModeOff];
            }
        } else if  (flag == AVCaptureTorchModeOn){
            if ([self.device isTorchModeSupported:AVCaptureTorchModeOn]) {
                [self.device setTorchMode:AVCaptureTorchModeOff];
            }
            if ([self.device isFlashModeSupported:AVCaptureFlashModeOff]) {
                [self.device setFlashMode:AVCaptureFlashModeOn];
            }
        } else {
            if ([self.device isTorchModeSupported:AVCaptureTorchModeOff]) {
                [self.device setTorchMode:AVCaptureTorchModeOff];
            }
            if ([self.device isFlashModeSupported:AVCaptureFlashModeOn]) {
                [self.device setFlashMode:AVCaptureFlashModeAuto];
            }
        }
        
        [self.device unlockForConfiguration];
        
    }else if (error) {
        NSLog(@"error locking device for flash mode change (%@)", error);
    }
    
    
}

-(void) addStillImageOutput{
    // setup photo settings
    NSDictionary *photoSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   AVVideoCodecJPEG, AVVideoCodecKey,
                                   nil];
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [self.stillImageOutput setOutputSettings:photoSettings];
    [self.captureSession addOutput:self.stillImageOutput];
}

- (void)addVideoInput:(AVCaptureDevicePosition)devicePosition {
	self.device = [self CameraWithPosition:devicePosition];
    position = devicePosition;
	if (self.device) {
		NSError *error;
        if (self.device && [self.device lockForConfiguration:&error]) {
//            if (self.device.smoothAutoFocusSupported ) {
//                self.device.smoothAutoFocusEnabled =  YES;
//                self.device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
//            }
            if (self.device.hasFlash) {
                [self.device setFlashMode:AVCaptureFlashModeOn];
            }
            if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                _device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
                
            } else if ([_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                _device.focusMode = AVCaptureFocusModeAutoFocus;
            }
            
            if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                _device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            } else if ([_device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
                _device.exposureMode = AVCaptureExposureModeAutoExpose;
            }
            
            if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
                _device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
            } else if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                _device.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
            }
          }
         [self.device unlockForConfiguration];
        self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
        
		if (!error) {
			if ([[self captureSession] canAddInput:videoInput]){
				[[self captureSession] addInput:videoInput];
			}else{
				NSLog(@"Couldn't add video input");
                return;
            }
      
		} else {
			NSLog(@"Couldn't create video input");
            return;
        }
	}
	else
		NSLog(@"Couldn't create video capture device");
    

}


-(void) updateOrientation{
    
    AVCaptureConnection *previewLayerConnection=self.previewLayer.connection;
    [previewLayerConnection setVideoOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)addVideoOutput {
    
   
    if (!self.movieFileOutput) {
        _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        Float64 TotalSeconds = MAX_DOUBLE_TAKE_RESPONSE_LENGTH;  //Total seconds
        int32_t preferredTimeScale = 20;    //Frames per second
        CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);
        _movieFileOutput.maxRecordedDuration = maxDuration;
        _movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;

    } else {
        NSLog(@"Already  exists");
    }
        if(!captureSession){
                NSLog(@"############################");
        }
        
        for(AVCaptureOutput *output in self.captureSession.outputs){
                [self.captureSession removeOutput:output];
        }
        
  if([self.captureSession canAddOutput:_movieFileOutput]) {
            @try {
                     [self.captureSession addOutput:_movieFileOutput];
            }
            @catch (NSException *exception) {
                    NSLog(@"error %@",[exception description]);
            }
    } else {
            NSLog(@"Unable  add  temporary  video file  as  output");
        NSAssert(FALSE,@"Unable  add  temporary  video file  as  output" );
    }
    


}

-(void) addAudioInput {
    AVCaptureDevice *audioDevice = [self getAudioDevice];
    NSError *error = nil;
    self.audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
    if (error)
    {
        NSLog(@"%@", error);
    }
    
    if ([self.captureSession canAddInput:self.audioInput])
    {
        [self.captureSession addInput:self.audioInput];
    }

}



- (void) cameraSetOutputProperties
{
	//SET THE CONNECTION PROPERTIES (output properties)
	AVCaptureConnection *CaptureConnection = [_movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
	
	//Set landscape (if required)
	if ([CaptureConnection isVideoOrientationSupported])
	{
	//	AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationLandscapeRight;		//<<<<<SET VIDEO ORIENTATION IF LANDSCAPE
		[CaptureConnection setVideoOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
	}
	
	//Set frame rate (if requried)
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

	CMTimeShow(device.activeVideoMinFrameDuration);
	CMTimeShow(device.activeVideoMaxFrameDuration);
    
    // JSC
    //	if (CaptureConnection.supportsVideoMinFrameDuration)
    //		CaptureConnection.videoMinFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
    //	if (CaptureConnection.supportsVideoMaxFrameDuration)
    //		CaptureConnection.videoMaxFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
    NSError *error;
    [device lockForConfiguration:&error];
    
    if(error) {
        NSLog(@"%@", error);
    }
    
    [device setActiveVideoMinFrameDuration:CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND)];
    [device setActiveVideoMaxFrameDuration:CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND)];
    
    [device unlockForConfiguration];

    CMTimeShow(device.activeVideoMinFrameDuration);
    CMTimeShow(device.activeVideoMaxFrameDuration);
    
}


#pragma mark AVCaptureFileOutputRecordingDelegate
-(void) captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    NSLog(@"the video file  path : %@",[outputFileURL path]);
        
        NSLog(@"*********error********** %@",error);
        
    _isMetadataChange = YES;
    if(_isMetadataChange){
           [self export:outputFileURL];
    }else{
        //[_delegate didFinishWriteToFile:outputFileURL item:self.messageItem closeVideo:_needToClose];
    
    }
   

    
}

-(void) captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
        NSLog(@"start");
}
-(AVCaptureStillImageOutput*) stillImageOutput{
    return _stillImageOutput;
}
@end
