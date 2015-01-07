#import "AROverlayViewController.h"

@implementation AROverlayViewController

@synthesize captureManager;
@synthesize  delegate;
@synthesize messageItem;

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setCaptureManager:[[CaptureSessionManager alloc] init] ];
    NSAssert(self.delegate, @"The  delegate  must be initialized");
    self.captureManager.delegate = self.delegate;
    self.captureManager.messageItem = self.messageItem;
	[[self captureManager] addVideoInput:AVCaptureDevicePositionFront];
    [[self captureManager] addVideoOutput];
    [[self captureManager] addAudioInput];

	[[self captureManager] addVideoPreviewLayer];
	CGRect layerRect = CGRectMake(0, 0, 100, 100);//[[[self view] layer] bounds];
	[[[self captureManager] previewLayer] setBounds:layerRect];
	[[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                CGRectGetMidY(layerRect))];
	[[[self view] layer] addSublayer:[[self captureManager] previewLayer]];
    [captureManager.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
	[[captureManager captureSession] startRunning];
  
}
-(void) interruptRecording {
    if (captureManager.movieFileOutput.isRecording) {
        captureManager.needToClose = NO;
        [captureManager stopWriteToFile];
    }
    
}


-(void) startRecording {
    [captureManager startWriteToFile];
 //   [self performSelector:@selector(interruptRecording) withObject:nil afterDelay:4.];
}

-(void) stopRecording {
    captureManager.needToClose =YES;
    [captureManager stopWriteToFile];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}


@end

