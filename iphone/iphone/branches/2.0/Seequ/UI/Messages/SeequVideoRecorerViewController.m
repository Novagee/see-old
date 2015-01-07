 //
//  SeequVideoRecorerViewController.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 3/12/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import <AviarySDK/AviarySDK.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#include <MobileCoreServices/UTCoreTypes.h>
#import "SeequVideoRecorerViewController.h"
#import "TBISoundService.h"
#import "SeequTimerLabel.h"
#import "UIImage+Operations.h"
#import "Common.h"
#import "DDExpandableButton.h"
#import "rtmpevent.h"
#include "idoubs2AppDelegate.h"
#import "SeequRecorderTypeView.h"
#import "ZNAssetsManager.h"
#import "GalleryCellInfo.h"
#import "GalleryViewController.h"
#import "SeequImagePickerViewController.h"
#import "SeequTakesViewController.h"

#define PICKER_MAXIMUM_ZOOM_SCALE 5.0

@interface SeequVideoRecorerViewController ()<UIVideoEditorControllerDelegate,AFPhotoEditorControllerDelegate, SeequRecorderTypeViewDelegate,GalleryViewControllerDelegate>{
    
    UIView*  toolbarView;
    UIView* timerView;
    UIButton* captureButton;
    UIButton* cancelButton;
    UIButton* cameraSwitchButton;
    UIButton* retakeButton;
    UIButton* useVideoButton;
    UIButton* flashButton;
    UIView*  circleView;
    UIView*  squareView;
    UIActivityIndicatorView *indicator;
    SeequTimerLabel*  timerLabel;
    BOOL captureButtonState;
    BOOL fromLibrary;
    CGFloat lastPinchScale_;
    CGFloat scale_;
    AVCaptureFlashMode  flashMode;
    CGPoint pointOfInterest_;
    AVCaptureVideoPreviewLayer *prevLayer;
    UIView* tempView;
    SeequRecorderTypeView* typeScroller;
    ///@note levon  temporary  var  for  diffs  between  tabBar camera  and  camera  from messages
    BOOL isPureCamera;
}
@property (nonatomic,retain) NSURL* urlForSend;
@property (nonatomic,retain) UIImage *imageForSend;
@property (nonatomic,retain) AVAudioPlayer *player;
@property (nonatomic,assign) SeequRecorderType recorderType;
@property (nonatomic,retain) DDExpandableButton *torchModeButton;
@property (nonatomic,retain)  UIVideoEditorController *videoEditor;
@property (nonatomic,retain) SeequRecordVideoEditor *editorView;

@end

@implementation SeequVideoRecorerViewController
@synthesize captureManager = _captureManager;
@synthesize delegate = _delegate;
@synthesize captureDelegate = _captureDelegate;
@synthesize urlForSend = _urlForSend;
@synthesize player =_player;
@synthesize recorderType = _recorderType;
@synthesize devicePosition = _devicePosition;
@synthesize forProfile;
@synthesize torchModeButton =_torchModeButton;
@synthesize videoEditor = _videoEditor;
@synthesize editorView = _editorView;

-(id) initWithType:(SeequRecorderType)type {
    self = [super init];
    if (self) {
        // Custom initialization
        captureButtonState = NO;
        if (type == SeequRecorderTypeNone) {
            _recorderType = SeequRecorderTypePhoto;
            isPureCamera = YES;

        } else {
            _recorderType = type;
            isPureCamera = NO;
        }
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        captureButtonState = NO;
    }
    return self;
}

-(void) drawCircumference:(CGRect) frame{
    CGFloat radius = MIN(frame.size.width,frame.size.height)/2;
    CGFloat inset  = 1;
    CAShapeLayer *ring = [CAShapeLayer layer];
    ring.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(frame, inset, inset)
                                           cornerRadius:radius-inset].CGPath;
    
    ring.fillColor   = [UIColor clearColor].CGColor;
    ring.strokeColor = [UIColor whiteColor].CGColor;
    
    ring.lineWidth   = 7;
    [captureButton.layer addSublayer:ring];
    
}
-(void)didDismissViewController {
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
    
}

-(void) createRetakeUseButtons {
    retakeButton = [UIButton buttonWithType: UIButtonTypeCustom];
    retakeButton.frame = CGRectMake(0, 0, 80, 70);
    [retakeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [retakeButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    retakeButton.layer.masksToBounds = YES;
    [retakeButton setTitle:@"Retake" forState:UIControlStateNormal];
    retakeButton.center = CGPointMake(toolbarView.frame.size.width - 10- retakeButton.frame.size.width/2, toolbarView.frame.size.height -30);
    [retakeButton addTarget:self action:@selector(retakeClicked) forControlEvents:UIControlEventTouchUpInside];
    [toolbarView addSubview:retakeButton];
    retakeButton.hidden = YES;
    _editorView=[[SeequRecordVideoEditor alloc] init];
    _editorView.delegate=self;
    _editorView.center=CGPointMake(60, captureButton.center.y);
    [toolbarView addSubview:_editorView];
 //   editorView.hidden=YES;
    //// Use video button
    useVideoButton = [UIButton buttonWithType: UIButtonTypeCustom];
    useVideoButton.frame = CGRectMake(0, 0, 120, 70);
    [useVideoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [useVideoButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    useVideoButton.layer.masksToBounds = YES;
    
    useVideoButton.center = CGPointMake(toolbarView.frame.size.width - 5 - useVideoButton.frame.size.width/2, toolbarView.frame.size.height -70);
    [useVideoButton addTarget:self action:@selector(useVideoClicked) forControlEvents:UIControlEventTouchUpInside];
    [toolbarView addSubview:useVideoButton];
    useVideoButton.hidden = YES;
    if (_recorderType == SeequRecorderTypeVideo ||_recorderType == SeequRecorderTypeDoubleTake){
        [useVideoButton setTitle:@"Use Video" forState:UIControlStateNormal];
    }else{
        [useVideoButton setTitle:@"Use Photo" forState:UIControlStateNormal];
    }
    
    
    
    
}

-(void) createToolbarButtons{
    [self resetViews];
    ///create capture button
    captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    captureButton.frame = CGRectMake(0, 0, 70, 70);
    [self drawCircumference:captureButton.frame];
    circleView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, 54, 54)];
    if (_recorderType == SeequRecorderTypePhoto ) {
        circleView.backgroundColor = [UIColor whiteColor];
    } else {
        circleView.backgroundColor = [UIColor redColor];
    }
    circleView.layer.cornerRadius = 27;
    circleView.userInteractionEnabled = NO;
    [captureButton addSubview:circleView];
    if (_recorderType == SeequRecorderTypeVideo ||_recorderType == SeequRecorderTypeDoubleTake) {
        squareView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 30, 30)];
        squareView.backgroundColor = [UIColor redColor];
        squareView.userInteractionEnabled = NO;
        [captureButton addSubview:squareView];
        
    }
    [captureButton addTarget:self action:@selector(captureClicked) forControlEvents:UIControlEventTouchUpInside];
    [toolbarView addSubview: captureButton];
    captureButton.center = CGPointMake(toolbarView.frame.size.width/2, toolbarView.frame.size.height -50);
    
    /////////////////////////////////////
    
    ///create cancelButton
    cancelButton =[UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0, 0, 80, 70);
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    cancelButton.layer.masksToBounds = YES;
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.center = CGPointMake(toolbarView.frame.size.width - 20 - cancelButton.frame.size.width/2, toolbarView.frame.size.height- 25);
    [cancelButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    [toolbarView addSubview:cancelButton];
    
    ///create cameraSwitchButton
    cameraSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage*  image = [UIImage imageNamed:@"SwitchCamera"];
    cameraSwitchButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [cameraSwitchButton setImage:image forState:UIControlStateNormal];
    cameraSwitchButton.center = CGPointMake(toolbarView.frame.size.width - 30 - cameraSwitchButton.frame.size.width/2, toolbarView.frame.size.height - 70);
    [cameraSwitchButton addTarget: self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
    [toolbarView addSubview:cameraSwitchButton];
    ///create libraryButton
    
    [self createRetakeUseButtons];
    
    [self createTypeScroll];
    
    //    //// retake button
    //    if (_recorderType == SeequRecorderTypeVideo) {
    //        [self createToolbarButtons];
    //    } else {
    //    [self createFlashButton];
    //
    //    }
    //   [self createFlashButton];
    
}

-(void) createTypeScroll {
    if (typeScroller) {
        return;
    }
    SeequRecorderType t  = isPureCamera? SeequRecorderTypeNone:self.recorderType;
    typeScroller = [[SeequRecorderTypeView alloc] initWithFrame:CGRectMake(0, 0, toolbarView.frame.size.width/7*5, 30) state:t];
    typeScroller.center = CGPointMake(toolbarView.frame.size.width/2, 10);
    typeScroller.backgroundColor = [UIColor clearColor];
    [toolbarView addSubview:typeScroller];
    typeScroller.delegate = self;
}

-(void) resetViews {
    [_torchModeButton removeFromSuperview];
    self.torchModeButton =nil;
    [timerView removeFromSuperview];
    timerView = nil;
    [captureButton removeFromSuperview];
    captureButton  = nil;
    [captureButton removeFromSuperview];
    captureButton = nil;
    [cameraSwitchButton removeFromSuperview];
    cameraSwitchButton = nil;
    [retakeButton removeFromSuperview];
    retakeButton = nil;
    [_editorView removeFromSuperview];
    _editorView = nil;
    [useVideoButton removeFromSuperview];
    useVideoButton = nil;
    [cancelButton removeFromSuperview];
    cancelButton = nil;
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

-(void) createFlashButton {
    if (_recorderType == SeequRecorderTypeVideo || _recorderType ==SeequRecorderTypeDoubleTake) {
        timerView = [[UIView alloc] initWithFrame:CGRectMake(50,25, self.view.frame.size.width -100, 35)];
        UIView* backgroundView = [[UIView alloc] initWithFrame:timerView.bounds];
        backgroundView.backgroundColor = [UIColor darkGrayColor];
        backgroundView.alpha = 0.3;
        [timerView addSubview:backgroundView];
        timerLabel = [[SeequTimerLabel alloc] initWithFrame:timerView.bounds];
        timerLabel.backgroundColor=[UIColor clearColor];
        [timerView addSubview: timerLabel];
        
        [tempView addSubview: timerView];
        
        ////add Flash button
        UIImage*  image = [UIImage imageNamed: @"cameraFlashOn"];
        UIImage* image1 = [UIImage imageNamed: @"cameraFlashOff"];
        
        flashButton =[UIButton buttonWithType:UIButtonTypeCustom];
        flashButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [flashButton setBackgroundImage:image forState:UIControlStateSelected];
        [flashButton setBackgroundImage:image1 forState:UIControlStateNormal];
        [flashButton addTarget:self action:@selector(onFlashClicked) forControlEvents:UIControlEventTouchUpInside];
        [timerView addSubview:flashButton];
        flashButton.center = CGPointMake(10 + image.size.width/2, timerView.center.y/2 - 4);
        
    } else {
        
        [self.captureManager setPhotoFlashMode:AVCaptureFlashModeAuto];
        
     //   flashButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _torchModeButton = [[DDExpandableButton alloc] initWithPoint:CGPointMake(20.0f, 20.0f)
                                                           leftTitle:[UIImage imageNamed:@"Flash"]
                                                             buttons:[NSArray arrayWithObjects:@"Auto", @"On", @"Off", nil]];
        [self.view addSubview:_torchModeButton];
        [_torchModeButton addTarget:self action:@selector(onFlashClicked:) forControlEvents:UIControlEventValueChanged];
        [_torchModeButton setVerticalPadding:6];
        [_torchModeButton updateDisplay];
        
        [_torchModeButton setSelectedItem:2];
        
    }
}
-(void)onFlashClicked:(id) sender {
    DDExpandableButton* button = (DDExpandableButton*) sender;
    switch (button.selectedItem) {
        case 0:
            [self.captureManager setPhotoFlashMode:AVCaptureFlashModeAuto];
            break;
        case 1:
            [self.captureManager setPhotoFlashMode:AVCaptureFlashModeOn];
            break;
        default:
            [self.captureManager setPhotoFlashMode:AVCaptureFlashModeOff];
            
    } ;
}

-(void)onFlashClicked {
    [flashButton setSelected:!flashButton.selected];
    if (_recorderType == SeequRecorderTypeVideo ||_recorderType == SeequRecorderTypeDoubleTake) {
        [self.captureManager setVideoFlashMode:flashButton.selected == YES];
        
    } else {
        
        [self.captureManager setVideoFlashMode:flashMode];
    }
    
}
-(void)onLibraryClicked{
    UIImagePickerController * imagePicker = [UIImagePickerController new];
    [imagePicker setDelegate:self];
    if (_recorderType == SeequRecorderTypePhoto||_recorderType == SeequRecorderTypeDoubleTake) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
        NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
        if (![sourceTypes containsObject:(NSString *)kUTTypeMovie ]){
            //NSLog(@"no video");
        }
    }
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //    float rads = 0;
    if ([mediaType isEqualToString:@"public.image"]) {
        fromLibrary=YES;
        [self dismissViewControllerAnimated:NO completion:nil];
        UIImage *TakedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        
        self.imageForSend=TakedImage;
        if (isPureCamera) {
            GalleryCellInfo* info = [[GalleryCellInfo alloc] init];
            MessageItem* item  = [[MessageItem alloc] initWithType:Message_Type_Image image:TakedImage];
            info.item = item;
            info.actualImage = TakedImage;
            NSArray* array =[NSArray arrayWithObject:info];
            GalleryViewController*  vc = [GalleryViewController alloc];
            vc.galleryDelegate = self;
            vc.assets = array;
            vc.userName  = @"Photo";
            vc.selectedIndex = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
            UINavigationController*  nc = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:nc animated:YES completion:nil];

        } else {
            [_editorView setPhotoImage:TakedImage];
            [self performSelectorOnMainThread:@selector(dismiss:) withObject:picker waitUntilDone:YES];

        }
      
    }
    if ([mediaType isEqualToString:@"public.movie"]) {
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        indicator =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        [indicator setHidesWhenStopped:YES];
        [picker.view addSubview:indicator];
        NSURL *outputURL = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:@"video"] stringByAppendingString:@".mp4"]];
        [self performSelectorOnMainThread:@selector(startIndicator) withObject:indicator waitUntilDone:NO];
        [SeequVideoRecorerViewController convertVideoToLowQuailtyWithInputURL:videoUrl outputURL:outputURL handler:^(AVAssetExportSession *exportSession)
         {
             if (exportSession.status == AVAssetExportSessionStatusCompleted)
             {
                 NSLog(@"completed...");
                 self.urlForSend=outputURL;
                 __weak SeequVideoRecorerViewController* weakSelf = self;
                 fromLibrary=YES;
                     dispatch_async(dispatch_get_main_queue(), ^{
                         AVURLAsset *avUrl = [AVURLAsset assetWithURL:outputURL];
                         CMTime time = [avUrl duration];
                         int seconds = ceil(time.value/time.timescale);
                         if (seconds>VIDEO_DURATION) {
                             weakSelf.videoEditor = nil;
                             weakSelf.videoEditor=[[UIVideoEditorController alloc] init];
                             weakSelf.videoEditor.videoPath=[weakSelf.urlForSend path];
                             weakSelf.videoEditor.delegate=weakSelf;
                             weakSelf.videoEditor.videoMaximumDuration=VIDEO_DURATION;
                             [weakSelf performSelectorOnMainThread:@selector(dismiss:) withObject:picker waitUntilDone:YES];
                             [weakSelf presentViewController:weakSelf.videoEditor animated:YES completion:nil];
                         }else{
                             [weakSelf.editorView videoImageWithURL:outputURL];
                             [weakSelf performSelectorOnMainThread:@selector(dismiss:) withObject:picker waitUntilDone:YES];
                         }
   
                     });
                                      //                [picker dismissViewControllerAnimated:NO completion:nil];
             }
             else
             {
                 NSLog(@"error...");
                 
             }
             
         }];
        
        
    }
    
}
-(void)dismiss:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:NO completion:nil];

        cancelButton.hidden =YES;
        cameraSwitchButton.hidden = YES;
        retakeButton.hidden = NO;
        _editorView.hidden=NO;
        useVideoButton.hidden = NO;
        captureButton.hidden = YES;

    //    [picker dismissViewControllerAnimated:YES completion:^{
    //        [self.captureManager finish];
    //    }];
    //    self.urlForSend=outputURL;
    //    [self performSelector:@selector(useVideoClicked) withObject:nil afterDelay:1.];
    
    //    [picker dismissViewControllerAnimated:NO completion:nil];
    //    //    self.urlForSend=outputURL;
    //    [self useVideoClicked];
}

-(void)startIndicator{
    [indicator setHidden:NO];
    [indicator startAnimating];
}
-(void)stopIndicator:(NSURL*)outputURL{
    [indicator stopAnimating];
}
-(void)useVideoClicked{
        AVURLAsset *avUrl = [AVURLAsset assetWithURL:self.urlForSend];
        CMTime time = [avUrl duration];
        int seconds = ceil(time.value/time.timescale);
        if (seconds>VIDEO_DURATION) {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"Oooops, you can't send videos longer 60 seconds. Please edit video or pick another." delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                [alert show];
                [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:2.5];
                return;
        }
    [self dismissViewControllerAnimated:YES completion:^{
        if (_recorderType==SeequRecorderTypeVideo ||_recorderType==SeequRecorderTypeDoubleTake){
            [_captureDelegate captureFinished: self.urlForSend fromLibrary:fromLibrary];
        }else{
            if ([_captureDelegate respondsToSelector:@selector(didFinish:Image:HighResolutionImage:fromLibrary:)]) {
                [_captureDelegate didFinish:self Image:self.imageForSend HighResolutionImage:self.imageForSend fromLibrary:fromLibrary];
            }
        }
        [self.captureManager finish];
    }];
    
    
}
-(void)dismissAlertView:(UIAlertView*)alert{
        [alert dismissWithClickedButtonIndex:0 animated:YES];
}
-(void) retakeClicked {
    
    [timerLabel reset];
    cancelButton.hidden =NO;
    cameraSwitchButton.hidden = NO;
    retakeButton.hidden = YES;
  //  editorView.hidden=YES;
    [_editorView removeVideoImage];
    useVideoButton.hidden = YES;
    captureButton.hidden = NO;
    [self updateLastPhotoThumbnail];
}

-(void)switchCamera {
    [_captureManager flipCameraInput];
    flashButton.hidden = ![self.captureManager hasFlash];
    _torchModeButton.hidden = ![self.captureManager hasFlash];
    
}

-(void) cancelClicked {
    if (captureButtonState) {
        [self captureClicked];
        [self useVideoClicked];
    } else {
  
        [self dismissViewControllerAnimated:YES completion:^{
                  [self.captureManager finish];
            }];
    }

}
- (void)setupAudioSession {
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    UInt32 doSetProperty = 1;
    
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
    
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    
}

-(void) dispose:(NSString*)audioFile{
    [self setupAudioSession];
    NSURL *audioURL = [NSURL fileURLWithPath:audioFile];
    self.player=[[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    [_player prepareToPlay];
    [_player play];
}

-(void) captureClicked{
    if (_recorderType == SeequRecorderTypeVideo||_recorderType == SeequRecorderTypeDoubleTake) {
        captureButtonState = !captureButtonState;
        circleView.hidden= captureButtonState;
        if (!captureButtonState) {
            NSString *audioFile = [[NSBundle mainBundle] pathForResource:@"end_record" ofType:@"mp3"];
            [self performSelectorOnMainThread:@selector(dispose:) withObject:audioFile waitUntilDone:YES];
            [_captureManager stopWriteToFile];
            useVideoButton.enabled=NO;
            retakeButton.enabled=NO;
            captureButton.hidden = !captureButtonState;
            [timerLabel pause];
        } else {
            NSString *audioFile = [[NSBundle mainBundle] pathForResource:@"begin_record" ofType:@"mp3"];
            [self performSelectorOnMainThread:@selector(dispose:) withObject:audioFile waitUntilDone:YES];
            cancelButton.hidden =captureButtonState;
            cameraSwitchButton.hidden = captureButtonState;
            [_captureManager startWriteToFile];
            [timerLabel  start ];
        }
        if (isPureCamera && !captureButtonState) {
            cancelButton.hidden =NO;
            cameraSwitchButton.hidden = NO;
            captureButton.hidden = NO;
        } else {
            retakeButton.hidden = captureButtonState;
            useVideoButton.hidden = captureButtonState;
        }
       // editorView.hidden=captureButtonState;
    } else {
        AVCaptureConnection *stillImageConnection  = [[self.captureManager stillImageOutput] connectionWithMediaType:AVMediaTypeVideo];

        [stillImageConnection setVideoScaleAndCropFactor: scale_ * self.view.frame.size.height/436];
        [self.captureManager capturePhoto];
    }
    
    
    
}

-(void) createToolBar {
    toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height - 120, self.view.frame.size.width, 120)];
    UIView* backgroundView = [[UIView alloc] initWithFrame:toolbarView.bounds];
    backgroundView.backgroundColor = [UIColor darkGrayColor];
    backgroundView.alpha = 0.6;
    [toolbarView addSubview:backgroundView];
    [tempView addSubview: toolbarView];
    
    [self createToolbarButtons];
}

-(void) createTimer {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCaptureManager:[[CaptureSessionManager alloc] init] ];
    //   NSAssert(self.delegate, @"The  delegate  must be initialized");
    self.captureManager.delegate = self;
        for (AVCaptureDeviceInput *deviceInput in self.captureManager.captureSession.inputs) {
                [self.captureManager.captureSession removeInput:deviceInput];
        }
        for (AVCaptureOutput *output in self.captureManager.captureSession.outputs) {
                [self.captureManager.captureSession removeOutput:output];
        }
    [[self captureManager] addVideoInput:self.devicePosition];
    [[self captureManager] addVideoOutput];
    [self.captureManager addStillImageOutput];
    [[self captureManager] addAudioInput];
	[[self captureManager] addVideoPreviewLayer];
	CGRect layerRect = self.view.layer.bounds;
	[[[self captureManager] previewLayer] setBounds:layerRect];
	[[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                  CGRectGetMidY(layerRect))];
    scale_ = 1.0;
    tempView = [[UIView alloc] initWithFrame: self.view.bounds];
    prevLayer =[[self captureManager] previewLayer];
    [tempView.layer addSublayer:prevLayer];
    //	[[[self view] layer] addSublayer:prevLayer];
    [self.view addSubview:tempView];
    [self createToolBar];
    [self createFlashButton];
    
    [self createTimer];
    //    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    //    tapRecognizer.delegate = self;
    //    [self.view addGestureRecognizer:tapRecognizer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissCamera) name:@"DISMISS_CAMERA" object:nil];
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self.view addGestureRecognizer:pinchRecognizer];
    pointOfInterest_ = CGPointMake(tempView.frame.size.width / 2, tempView.frame.size.height / 2);
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipeGesture:)];
    [leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipeGesture:)];
    [rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipeRecognizer];
    [self.view addGestureRecognizer:leftSwipeRecognizer];
    
    @try {
        [_captureManager.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
        [[_captureManager captureSession] startRunning];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
        
    }
    BOOL _hasFlash =[self.captureManager hasFlash];
    flashButton.hidden = !_hasFlash;
    //    [self.captureManager.device addObserver:self
    //              forKeyPath:@"adjustingExposure"
    //                 options:NSKeyValueObservingOptionNew
    //                 context:nil];
    //
    [self updateLastPhotoThumbnail];

    if (forProfile) {
        [typeScroller removeFromSuperview];
        CGRect f = self.view.bounds;
     //   f.size.height -= self.navigationBar.bounds.size.height;
        CGFloat barHeight = (f.size.height - f.size.width) / 2;
        UIView*  view = [[UIView alloc] initWithFrame:self.view.bounds];
        view.backgroundColor = [UIColor clearColor];
        UIView* topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, f.size.width, barHeight)];
        topView .backgroundColor = [UIColor darkGrayColor];
        topView.alpha = 0.6;
        [view addSubview:topView];
        UIView* bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, f.size.height - barHeight, f.size.width, barHeight -toolbarView.frame.size.height)];
        bottomView .backgroundColor = [UIColor darkGrayColor];
        bottomView.alpha = 0.6;

        [view addSubview:bottomView];
        [self.view addSubview: view];
        view.userInteractionEnabled =NO;
   //     self.cameraOverlayView = view;
        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRTMPEventForIncomingCall:) name:@"Registration_is_ready" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSavedPhoto) name:kPhotoSavedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideoCapturing) name:kStopVideoCapturing object:nil];

}

-(void) stopVideoCapturing {
    if( captureButtonState){
        [self captureClicked];
    }
}

-(void) updateSavedPhoto {
    [self performSelector:@selector(updateLastPhotoThumbnail) withObject:nil afterDelay:0.1];
}

- (void)handleRightSwipeGesture:(UISwipeGestureRecognizer *)recognizer{
    if (!captureButtonState) {
        [typeScroller swipeRight];
    }
}
- (void) handleLeftSwipeGesture:(UISwipeGestureRecognizer *)recognizer{
    if (!captureButtonState) {
        [typeScroller swipeLeft];
    }
    
}


-(void) onRTMPEventForIncomingCall:(NSNotification*)notification {
    
    NSDictionary *userInfo = notification.object;
    NSString *key = @"event";
    
    NSValue *test_kay = [userInfo objectForKey: key];
    rtmp_event_t test;
    [test_kay getValue:&test];
    if (test.rtmp_call_event == RTMP_CALL_EVENT_TYPE_INCOMING) {
        NSLog(@"dismis ");
        if(IS_IOS_7){
            [self dismissCamera];
        }else{
            
            if ([[UIDevice currentDevice].model rangeOfString:@"iPod"].location != NSNotFound) {
                [self dismissViewControllerAnimated:NO completion:^{
                    [self.captureManager finish];
                }];
            }else{
                [self performSelectorOnMainThread:@selector(dismissCamera) withObject:nil waitUntilDone:YES];
            }
            
        }
    }
}
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if ([keyPath isEqualToString:@"adjustingExposure"]) {
//        NSLog(@"dddddd");
//
//    }
////    if (!adjustingExposure_) {
////        return;
////    }
////
////	if ([keyPath isEqual:@"adjustingExposure"] == NO ||
////        [[change objectForKey:NSKeyValueChangeNewKey] boolValue]) {
////        return;
////    }
////
////    adjustingExposure_ = NO;
////
////    NSError *error = nil;
////    if ([device_ lockForConfiguration:&error]) {
////        [device_ setExposureMode:AVCaptureExposureModeLocked];
////        [device_ unlockForConfiguration];
////    }
////    [self performSelector:@selector(autofocus) withObject:nil afterDelay:1];
//}
//
//- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer{
//    CGPoint point = [recognizer locationInView:_torchModeButton];
//    if (_torchModeButton && CGRectContainsPoint(_torchModeButton.frame,point) ) {
//        [self onFlashClicked:nil];
//    }
//
//}
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    
    CGFloat pinchScale = recognizer.scale;
    if(recognizer.state == UIGestureRecognizerStateBegan){
        lastPinchScale_ = pinchScale;
        return;
    }
    CGRect defaultBounds_ = tempView.frame;
    if(lastPinchScale_ == 0){
        lastPinchScale_ = pinchScale;
        return;
    }
    
    //calculate zoom scale
    CGFloat diff = (pinchScale - lastPinchScale_) * 2;
    CGFloat scale = scale_;
    if(diff > 0){
        scale += 0.05;
    }else{
        scale -= 0.05;
    }
    if(scale > PICKER_MAXIMUM_ZOOM_SCALE){
        scale = PICKER_MAXIMUM_ZOOM_SCALE;
    }else if(scale < 1.0){
        scale = 1.0;
    }
    if(scale_ == scale){
        return;
    }
    scale_ = scale;
    
    //calcurate zoom rect
    
    AVCaptureConnection *stillImageConnection  = [[self.captureManager stillImageOutput] connectionWithMediaType:AVMediaTypeVideo];
    
    if(_recorderType == SeequRecorderTypePhoto){
        CGAffineTransform affineTransform = CGAffineTransformMakeTranslation(scale_, scale_);
        affineTransform = CGAffineTransformScale(affineTransform, scale_, scale_);
        affineTransform = CGAffineTransformRotate(affineTransform, 0);
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        //previewLayer is object of AVCaptureVideoPreviewLayer
        [[[self captureManager]previewLayer] setAffineTransform:affineTransform];
        [self.captureManager.device lockForConfiguration:nil];
        [stillImageConnection setVideoScaleAndCropFactor: scale_* self.view.frame.size.height/436];
        [CATransaction commit];
    }else {
        if(IS_IOS_7){
            CGAffineTransform zt = CGAffineTransformScale(CGAffineTransformIdentity, scale_, scale_);
            
            CGRect rect = CGRectApplyAffineTransform(defaultBounds_, zt);
            
            if(CGPointEqualToPoint(pointOfInterest_, CGPointZero) || scale == 1.0){
                rect.origin.x = 0;
                rect.origin.y = 0;
            }else{
                rect.origin.x = -((pointOfInterest_.x * scale_) - defaultBounds_.size.width / 2);
                rect.origin.y = -((pointOfInterest_.y * scale_) - defaultBounds_.size.height / 2);
            }
            if(rect.origin.x > 0){
                rect.origin.x = 0;
            }
            if(rect.origin.y > 0){
                rect.origin.y = 0;
            }
            if(rect.origin.x + rect.size.width < defaultBounds_.size.width){
                rect.origin.x = defaultBounds_.size.width - rect.size.width;
            }
            if(rect.origin.y + rect.size.height < defaultBounds_.size.height){
                rect.origin.y = defaultBounds_.size.height - rect.size.height;
            }
            [self.captureManager.device lockForConfiguration:nil];
            
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            // prevLayer.frame = rect;
            NSLog(@"  preview layer rect  is %f", pinchScale);
            NSLog(@"  scale is %f", scale_);
            //  indicatorLayer_.frame = iframe;
            [CATransaction commit];
            
            self.captureManager.device.videoZoomFactor = scale_;
            [stillImageConnection setVideoScaleAndCropFactor:scale_];
            [self.captureManager.device unlockForConfiguration];
        }else{
            
            
            stillImageConnection.videoScaleAndCropFactor = scale_;
            
            CGAffineTransform affineTransform = CGAffineTransformMakeTranslation(scale_, scale_);
            affineTransform = CGAffineTransformScale(affineTransform, scale_, scale_);
            affineTransform = CGAffineTransformRotate(affineTransform, 0);
            [CATransaction begin];
            [CATransaction setAnimationDuration:.025];
            //previewLayer is object of AVCaptureVideoPreviewLayer
            [[[self captureManager]previewLayer] setAffineTransform:affineTransform];
            [CATransaction commit];
            
            
        }
        
        
    }
    //
    //    //calcurate indicator rect
    //    CGRect iframe = indicatorLayer_.frame;
    //    iframe.origin.x = (pointOfInterest_.x * scale_) - fabs(rect.origin.x) - INDICATOR_RECT_SIZE / 2.0;
    //    iframe.origin.y = (pointOfInterest_.y * scale_) - fabs(rect.origin.y) - INDICATOR_RECT_SIZE / 2.0;
    //
    
    
    //set frame without animation
    //    [CATransaction begin];
    //    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    //    // prevLayer.frame = rect;
    //    NSLog(@"  preview layer rect  is %f", pinchScale);
    //    NSLog(@"  scale is %f", scale_);
    //    //  indicatorLayer_.frame = iframe;
    //    [CATransaction commit];
    //    // [self.captureManager.device lockForConfiguration:nil];
    //    // self.captureManager.device.videoZoomFactor = scale_;
    //    [self.captureManager.device unlockForConfiguration];
    //    lastPinchScale_ = pinchScale;
}

-(BOOL) shouldAutorotate {
    return NO;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark CaptureSessionManagerDelegate

-(void) didFinishWriteToFile:(NSURL *)url item:(MessageItem *)item closeVideo:(BOOL)flag{
      NSURL *outputURL = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:@"video"] stringByAppendingString:@".mp4"]];
        [SeequVideoRecorerViewController convertVideoToLowQuailtyWithInputURL:url outputURL:outputURL handler:^(AVAssetExportSession * exportSession) {
                if (exportSession.status == AVAssetExportSessionStatusCompleted){
                        self.urlForSend = outputURL;
                        fromLibrary=NO;
                        [_editorView videoImageWithURL:outputURL];
                        useVideoButton.enabled=YES;
                        retakeButton.enabled=YES;
                }
                
        }];
    
}

-(void) didFinishMakePhoto:(UIImage *)image {
      if(isPureCamera) {
        [[ZNAssetsManager sharedInstance] saveImage:image];
      } else {
          fromLibrary=NO;
          self.imageForSend=image;
          [_editorView setPhotoImage:image];
          cancelButton.hidden =YES;
          cameraSwitchButton.hidden = YES;
          retakeButton.hidden = NO;
          _editorView.hidden=NO;
          useVideoButton.hidden = NO;
          captureButton.hidden = YES;

      }
    
    //    if ([_captureDelegate respondsToSelector:@selector(didFinish:Image:HighResolutionImage:fromLibrary:)]) {
    //
    //        [_captureDelegate didFinish:self Image:image HighResolutionImage:image fromLibrary:fromLibrary];
    ////         UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    //    }
    
}

#pragma mark  UIGestureRecognizerDelegate

/*!
 * gesture recognizer delegate
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]){
        return FALSE;
    }
    return TRUE;
}
+ (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    NSData *data=[NSData dataWithContentsOfURL:outputURL];
    NSLog(@"outpute file size %d",[data length]);
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
         
     }];
}
-(void) dismissCamera{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.captureManager finish];
    }];
    
}

- (void)updateLastPhotoThumbnail
{
    [[ZNAssetsManager sharedInstance].library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        NSInteger numberOfAssets = [group numberOfAssets];
        if (numberOfAssets > 0) {
            NSInteger lastIndex = numberOfAssets - 1;
            [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:lastIndex] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                UIImage *thumbnail = [UIImage imageWithCGImage:[result thumbnail]];
                if (thumbnail && thumbnail.size.width > 0) {
                    [_editorView setPhotoImage:thumbnail];
                    *stop = YES;
                }
            }];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
}
#pragma SeequRecordVideoEditorDelegate
-(void)videoEditorPressed{
        if (!retakeButton.isHidden) {
                if (_recorderType==SeequRecorderTypeVideo || _recorderType == SeequRecorderTypeDoubleTake) {
                        self.videoEditor = nil;
                        _videoEditor=[[UIVideoEditorController alloc] init];
                        _videoEditor.videoPath=[self.urlForSend path];
                        _videoEditor.delegate=self;
                        _videoEditor.videoMaximumDuration=VIDEO_DURATION;
                        [self presentViewController:_videoEditor animated:YES completion:nil];
                }else{
                        [self launchPhotoEditorWithImage:self.imageForSend highResolutionImage:self.imageForSend controller:self];
                }
                
        } else {
                if (!isPureCamera) {
                        UIImagePickerController * imagePicker = [UIImagePickerController new];
                        [imagePicker setDelegate:self];
                        if (_recorderType == SeequRecorderTypePhoto) {
                                [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                                
                        }else{
                                [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
                                imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
                                
                                
                        }
                        [self presentViewController:imagePicker animated:YES completion:nil];
                }else{
                        if (_recorderType == SeequRecorderTypePhoto) {
                                [self prepareSeequImagePickerWithPickerType:kPickerTypePhoto];
                        } else {
                                [self prepareSeequImagePickerWithPickerType:kPickerTypeMovie];
                                
                        }
                        
                }
                
        }
}
#pragma UIVideoEditorControllerDelegate
-(void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath{
    NSURL*url=[[NSURL alloc] initFileURLWithPath:editedVideoPath];
    self.urlForSend=url;
    [_editorView videoImageWithURL:url];
    [editor dismissViewControllerAnimated:YES completion:nil];
}
-(void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error{
    NSLog(@"fail edite video %@ ",error);
}
-(void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor{
    [editor dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Photo Editor Creation and Presentation
- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage controller:(UIViewController*) vc
{
    
    [AFPhotoEditorController setPremiumAddOns:(AFPhotoEditorPremiumAddOnHiRes | AFPhotoEditorPremiumAddOnWhiteLabel)];
    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:editingResImage];
    [photoEditor setDelegate:self];
 //   static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
//    });
    
    [vc presentViewController:photoEditor animated:YES completion:nil];
}

- (void) setPhotoEditorCustomizationOptions
{
    // Set Tool Order
    NSArray * toolOrder = @[kAFCrop,kAFEffects, kAFFocus, kAFFrames, kAFStickers, kAFEnhance, kAFOrientation,  kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme, kAFSharpness];//
    [AFPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set Custom Crop Sizes
    [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:NO];
    [AFPhotoEditorCustomization setCropToolInvertEnabled:NO];

//    NSDictionary * fourBySix = @{kAFCropPresetHeight : @(4.0f), kAFCropPresetWidth : @(6.0f)};
//    NSDictionary * fiveBySeven = @{kAFCropPresetHeight : @(5.0f), kAFCropPresetWidth : @(7.0f)};
    NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
    [AFPhotoEditorCustomization setCropToolPresets:@[ square]];//@[fourBySix, fiveBySeven, square]
    
    // Set Supported Orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray * supportedOrientations = @[@(UIInterfaceOrientationPortrait), @(UIInterfaceOrientationPortraitUpsideDown), @(UIInterfaceOrientationLandscapeLeft), @(UIInterfaceOrientationLandscapeRight)];
        [AFPhotoEditorCustomization setSupportedIpadOrientations:supportedOrientations];
    }
}

#pragma Photo Editor Delegate Methods

// This is called when the user taps "Done" in the photo editor.
- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    self.imageForSend = image;
    NSLog(@"the size of  received image %@ ",NSStringFromCGSize(image.size));
    [_editorView setPhotoImage:image];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)photoEditorCanceled:(AFPhotoEditorController *)editor{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma  SeequRecorderTypeViewDelegate methods 

-(void) didChangeToState:(SeequRecorderType)type {
    NSLog(@"-(void) didChangeToState:(SeequRecorderType)type");
    if ([_captureDelegate respondsToSelector:@selector(didChangeRecorderType:)]) {
        [_captureDelegate didChangeRecorderType:type];
    }
    self.recorderType = type;
    [self createToolbarButtons];
    [self createFlashButton];
    [self updateLastPhotoThumbnail];
}
-(void)prepareSeequImagePickerWithPickerType:(SeequPickerType)pickerType{
        __weak SeequVideoRecorerViewController *weakSelf=self;
        NSMutableArray *assetGroups=[NSMutableArray array];
        ALAssetsLibrary *assetLibrary = [SeequTakesViewController defaultAssetsLibrary];
        dispatch_async(dispatch_get_main_queue(), ^{
                // Group enumerator Block
                void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
                {
                        if (group == nil) {
                                if ([assetGroups count]>0) {
                                        [weakSelf presentSeequImagePicker:assetGroups withPickerType:pickerType];
                                }
                                return;
                        }
                        NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                        NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                        if (pickerType == kPickerTypeMovie) {
                                [group setAssetsFilter:[ALAssetsFilter allVideos]];
                        }else{
                                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                        }
                        if ([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"] && nType == ALAssetsGroupSavedPhotos) {
                                
                                [assetGroups insertObject:group atIndex:0];
                                
                        }
                        else {
                                if (group.numberOfAssets != 0) {
                                        [assetGroups addObject:group];
                                }
                        }
                        
                };
                // Group Enumerator Failure Block
                void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [alert show];
                };
                [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                            usingBlock:assetGroupEnumerator
                                          failureBlock:assetGroupEnumberatorFailure];
                
        });

}
-(void)presentSeequImagePicker:(NSMutableArray*)assetGroups withPickerType:(SeequPickerType)pickerType{
         NSMutableArray *controllersArray=[NSMutableArray array];
        SeequImagePickerViewController *seequImagePicker=[[SeequImagePickerViewController alloc] init];
        [seequImagePicker setPickerType:pickerType];
        SeequAssetsViewController *assetsView=[[SeequAssetsViewController alloc] initWithFrame:self.view.frame];
        assetsView.assetsGroup=(ALAssetsGroup*)[assetGroups objectAtIndex:0];
        [assetsView setPickerType:pickerType];
        [controllersArray addObject:seequImagePicker];
        [controllersArray addObject:assetsView];
        UINavigationController *navigationController=[[UINavigationController alloc] init];
        [navigationController setViewControllers:controllersArray];
        [self presentViewController:navigationController animated:YES completion:nil];
        
}

@end
