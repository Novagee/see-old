#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "MessageItem.h"


@protocol CaptureSessionManagerDelegate <NSObject>
@optional
-(void) didFinishWriteToFile:(NSURL*) url item:(MessageItem*) item closeVideo:(BOOL) flag;
-(void) didFinishMakePhoto:(UIImage*) image;

@end


@interface CaptureSessionManager : NSObject<AVCaptureFileOutputRecordingDelegate> {

}


@property (nonatomic,retain) AVCaptureDevice*  device;
@property (nonatomic,weak) id<CaptureSessionManagerDelegate> delegate;
@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic,retain) MessageItem*  messageItem;
@property (nonatomic,assign) BOOL needToClose;
@property (nonatomic, strong) AVAssetExportSession* assetExport;
@property (nonatomic, assign) BOOL isMetadataChange;
@property(nonatomic, strong) NSURL *outputURLForExported;
- (void)addVideoPreviewLayer;
- (void)addVideoInput:(AVCaptureDevicePosition) devicePosition;
-(void) addAudioInput;
-(void) flipCameraInput;
-(void) addVideoOutput;
- (void) cameraSetOutputProperties;
-(void) startWriteToFile;
-(void) stopWriteToFile;
//-(void) pauseRecording;
//-(void) resumeRecording;
-(void) updateOrientation;
-(BOOL) hasFlash;
-(void) addStillImageOutput;
-(void) finish;
-(void) capturePhoto;
-(void) setVideoFlashMode:(BOOL) flag;
-(void) setPhotoFlashMode:(AVCaptureFlashMode) flag;
-(AVCaptureStillImageOutput*) stillImageOutput;
@end
