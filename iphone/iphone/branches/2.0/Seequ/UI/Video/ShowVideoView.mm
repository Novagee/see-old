//
//  ShowVideoView.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 11/8/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "ShowVideoView.h"
#import "idoubs2AppDelegate.h"
#import "SeequBrowserViewController.h"


//#define RECONNECT_CALL_TIME_OUT 30
//#define START_RECONNECT_CALL_TIME_OUT 5



@implementation ShowVideoView


@synthesize delegate = _delegate;
@synthesize videoViewState;
@synthesize imageViewRemoteVideo;
@synthesize openGlView;
@synthesize viewLocalVideo;
@synthesize viewAudioCallMenu;
@synthesize viewMenu;
@synthesize viewAudioEndCall;
@synthesize viewDisplayName;
@synthesize labelDisplayName;
@synthesize labelTime;
@synthesize imageViewNetworkStatus;
@synthesize messageBadgView;
@synthesize interfaceOrientation;
@synthesize splited;
@synthesize videoRecive;
@synthesize videoSend;
@synthesize buddyButton=_buddyButton;

// Portrait
#define State_NORMAL_Rect CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)
#define State_NORMAL_MENU_Rect CGRectMake(0, -92, 320, [[UIScreen mainScreen] bounds].size.height)
#define State_TAB_MENU_Rect CGRectMake(0, -480, 320, 732)
#define State_TAB_Rect CGRectMake(0, -572, 320, 732)
#define State_Hide_Rect CGRectMake(0, -480, 320, 480)

//Landscape Right
#define State_NORMAL_Landscape_Right_Rect CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)
#define State_NORMAL_MENU_Landscape_Right_Rect CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)
#define State_TAB_MENU_Landscape_Right_Rect CGRectMake(320, 0, 320, [[UIScreen mainScreen] bounds].size.height)
#define State_TAB_Landscape_Right_Rect CGRectMake(320, 0, 320, [[UIScreen mainScreen] bounds].size.height)
#define State_Hide_Landscape_Right_Rect CGRectMake(320, 0, 320, [[UIScreen mainScreen] bounds].size.height)

//Landscape Left
#define State_NORMAL_Landscape_Left_Rect CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)
#define State_NORMAL_MENU_Landscape_Left_Rect CGRectMake(-50, 0, 320, [[UIScreen mainScreen] bounds].size.height)
#define State_TAB_MENU_Landscape_Left_Rect CGRectMake(-320, 0, 320, [[UIScreen mainScreen] bounds].size.height)
#define State_TAB_Landscape_Left_Rect CGRectMake(-320, 0, 320, [[UIScreen mainScreen] bounds].size.height)
#define State_Hide_Landscape_Left_Rect CGRectMake(-487, 0, 487, 480)

// Portrait
#define Local_Video_Small_Rect CGRectMake(242, 10, 67, 100)
#define Local_Video_Split_Rect CGRectMake(0, 240, 320, 240)
#define Local_Video_Rect CGRectMake(0, 92, 160, 160)
#define Local_Video_Rect_Hide CGRectMake(0, -160, 160, 160)
#define Remote_Video_Rect CGRectMake(160, 92, 160, 160)
#define Remote_Video_Rect_Hide CGRectMake(160, -160, 160, 160)

//Landscape Right
#define Local_Video_Small_Right_Rect CGRectMake(320 - 78, [[UIScreen mainScreen] bounds].size.height - 111, 67,100)

#define Local_Video_Split_Right_Rect CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height/2)

#define Local_Video_Right_Rect CGRectMake(320 - 50 - SMALL_VIDEO_WIDTH, 0, SMALL_VIDEO_WIDTH, SMALL_VIDEO_HEIGHT)

#define Remote_Video_Right_Rect CGRectMake(320 - 50 - SMALL_VIDEO_WIDTH, [[UIScreen mainScreen] bounds].size.height - SMALL_VIDEO_HEIGHT, SMALL_VIDEO_WIDTH, SMALL_VIDEO_WIDTH)

//Landscape Left
#define Local_Video_Small_Left_Rect CGRectMake(10, 10, 67,100)
#define Local_Video_Split_Left_Rect CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/2, 320, [[UIScreen mainScreen] bounds].size.height/2)
#define Local_Video_Left_Rect CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - SMALL_VIDEO_HEIGHT, SMALL_VIDEO_WIDTH, SMALL_VIDEO_HEIGHT)
#define Remote_Video_Left_Rect CGRectMake(0, 0, SMALL_VIDEO_WIDTH, SMALL_VIDEO_HEIGHT)


- (id)initWithContactObject:(ContactObject*)contact {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 572)];
    if (self) {
        // Initialization code
        
        contactObject = contact;
        [self setBackgroundColor:[UIColor blackColor]];
        self.imageViewRemoteVideo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
        [self.imageViewRemoteVideo setBackgroundColor:[UIColor blackColor]];
        self.openGlView = [[OpenGlView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
        [self.openGlView setBackgroundColor:[UIColor blackColor]];
        [self.imageViewRemoteVideo addSubview:self.openGlView];
        
        imageViewProfile = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
        [imageViewProfile setBackgroundColor:[UIColor blackColor]];
        imageViewProfile.contentMode = UIViewContentModeScaleAspectFill;
        [imageViewProfile setImage:contact.image];
        imageViewProfile.hidden = YES;
        [self.imageViewRemoteVideo addSubview:imageViewProfile];
        
        self.viewLocalVideo = [[UIView alloc] init];
        [self ChangeLocalVideoFrame:Local_Video_Small_Rect HaveBorder:YES Animation:NO];
        [self.viewLocalVideo setBackgroundColor:[UIColor whiteColor]];
        
        viewReconnect = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 50)];
        [viewReconnect setBackgroundColor:[UIColor blackColor]];
        [viewReconnect setAlpha:0.5];
        
        labelReconnecting = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 100)];
        [labelReconnecting setBackgroundColor:[UIColor clearColor]];
        [labelReconnecting setFont:[UIFont boldSystemFontOfSize:17]];
        [labelReconnecting setText:@"Reconnecting..."];
        [labelReconnecting setTextColor:[UIColor whiteColor]];
        [labelReconnecting setTextAlignment:NSTextAlignmentCenter];
        [labelReconnecting setNumberOfLines:0];
        [viewReconnect addSubview:labelReconnecting];
        labelReconnecting.center = CGPointMake(viewReconnect.frame.size.width/2, viewReconnect.frame.size.height/2);
        
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [self.imageViewRemoteVideo addGestureRecognizer:pinchGesture];
        
        UITapGestureRecognizer *doubleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OneTapOnLocalVideo:)];
        [doubleTap setNumberOfTapsRequired:1];
        [self.viewLocalVideo addGestureRecognizer:doubleTap];
        
        UIPanGestureRecognizer *PanGestureRemoteVideo = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(handlePanRemoteVideo:)];
        [self.imageViewRemoteVideo addGestureRecognizer:PanGestureRemoteVideo];
        UIPanGestureRecognizer *PanGestureLocalVideo = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(handlePanLocalVideo:)];
        [self.viewLocalVideo addGestureRecognizer:PanGestureLocalVideo];
        
        [self VideoTabMenu];
        [self AudioCallMenu];
        
        buttonChangeCamera = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 57, 30)];
        buttonChangeCamera.center = CGPointMake(self.viewLocalVideo.frame.origin.x + self.viewLocalVideo.frame.size.width/2,
                                                self.viewLocalVideo.frame.origin.y + self.viewLocalVideo.frame.size.height/2);
        [buttonChangeCamera setBackgroundImage:[UIImage imageNamed:@"SwitchCamera.png"] forState:UIControlStateNormal];
        [buttonChangeCamera addTarget:self
                               action:@selector(onButtonChangeCamera:)
                     forControlEvents:UIControlEventTouchUpInside];
        
        videoViewState = VideoViewState_NONE;
        
        splited = NO;
        endCallTimerStarted = NO;
        isReconnecting = NO;
        
        self.interfaceOrientation = UIDeviceOrientationUnknown;
        self.imageViewNetworkStatus = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
        [self.imageViewNetworkStatus setImage:[UIImage imageNamed:@"contactOnlineLabel.png"]];
        [self.openGlView addSubview:self.imageViewNetworkStatus];
        
        _buddyButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _buddyButton.frame=CGRectMake(55,5,25, 25);
        [_buddyButton setBackgroundImage:[UIImage imageNamed:@"SeequButtonWebActionForVideoView.png"] forState:UIControlStateNormal];
        [_buddyButton setBackgroundImage:[UIImage imageNamed:@"seequButtonWebActionConnectedForVideoView.png"] forState:UIControlStateSelected];
        [_buddyButton addTarget:self action:@selector(onBuddyButton) forControlEvents:UIControlEventTouchDown];
        [self.openGlView addSubview:_buddyButton];
        
        UIView *viewOutputVoiceAlpha = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
        viewOutputVoiceAlpha.layer.borderWidth = .0;
        viewOutputVoiceAlpha.layer.borderColor = [[UIColor clearColor] CGColor];
        viewOutputVoiceAlpha.layer.cornerRadius = 5.f;
        [viewOutputVoiceAlpha setBackgroundColor:[UIColor darkTextColor]];
        [viewOutputVoiceAlpha setAlpha:0.5];
        
        viewOutputVoice = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
        viewOutputVoice.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
        [viewOutputVoice setBackgroundColor:[UIColor clearColor]];
        [viewOutputVoice addSubview:viewOutputVoiceAlpha];
        
        labelOutputVoice = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 100, 30)];
        [labelOutputVoice setFont:[UIFont boldSystemFontOfSize:17]];
        [labelOutputVoice setTextColor:[UIColor whiteColor]];
        [labelOutputVoice setTextAlignment:NSTextAlignmentCenter];
        [labelOutputVoice setBackgroundColor:[UIColor clearColor]];
        [viewOutputVoice addSubview:labelOutputVoice];
        
        imageViewOutputVoice = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 100, 100)];
        [viewOutputVoice addSubview:imageViewOutputVoice];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBrowser_Session:)
                                                     name:BROWSER_SESSION object:nil];
    }
    
    return self;
}

-(void) updateCallerName:(ContactObject *)obj {
    contactObject = obj;
    [buttonCallerName setTitle: contactObject.displayName forState:UIControlStateNormal];
}

- (void) SetDefaultState {
    videoViewState = VideoViewState_NONE;
    splited = NO;
    self.interfaceOrientation = UIInterfaceOrientationPortrait;
}

- (void) setVideoState:(VideoViewState)state {
    videoViewState = state;
    if([idoubs2AppDelegate sharedInstance].videoService.isOnHold)
        openGlView.hidden = YES;
    
    if (state == VideoViewState_HIDE) {
        [idoubs2AppDelegate RefreshTab];
    }
}
-(void)onBuddyButton{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pressBuddybutton" object:nil];
}

- (void) setVideoState:(VideoViewState)state Animation:(BOOL)animation {
    self.videoViewState = state;
    
    switch (state) {
        case VideoViewState_NONE:
        case VideoViewState_NORMAL: {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            [self ShowHideAllViews:YES];
            self.buddyButton.hidden=NO;
            [buttonAudioVideo setHighlighted:NO];
            buttonAudioProfile.enabled = YES;
            buttonAudioMessage.enabled = YES;
            buttonAudioBuddy.enabled = YES;
            labelCallingState.hidden = YES;
            self.viewLocalVideo.hidden = ![[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState];
            
            if (![self isVideoState]) {
                self.viewDisplayName.hidden = NO;
                self.viewAudioCallMenu.hidden = NO;
            }else{
                self.viewDisplayName.hidden=YES;
                self.viewAudioCallMenu.hidden=YES;
            }
            [[idoubs2AppDelegate sharedInstance] HideKeyboard];
            switch (self.interfaceOrientation) {
                case UIInterfaceOrientationPortrait: {
                    [self VIDEO_STATE_NORMAL_PORTRAIT:animation];
                }
                    break;
                case UIInterfaceOrientationLandscapeRight: {
                    [self VIDEO_STATE_NORMAL_LANDSCAPE_RIGHT:animation];
                }
                    break;
                case UIInterfaceOrientationLandscapeLeft: {
                    [self VIDEO_STATE_NORMAL_LANDSCAPE_LEFT:animation];
                }
                    break;
                default:
                    break;
            }
            
            [self calculateAudioCallEndButtonCenter];
        }
            break;
        case VideoViewState_NORMAL_MENU: {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            [self ShowHideAllViews:YES];
            self.viewLocalVideo.hidden = NO;
            self.buddyButton.hidden=NO;
            if (![self isVideoState]) {
                self.viewDisplayName.hidden = NO;
                self.viewAudioCallMenu.hidden = NO;
            }
            [[idoubs2AppDelegate sharedInstance] HideKeyboard];
            
            timerHideMenu = [self CreateTimerHideMenu];
            switch (self.interfaceOrientation) {
                case UIInterfaceOrientationPortrait: {
                    [self VIDEO_STATE_NORMAL_MENU_PORTRAIT:animation];
                }
                    break;
                case UIInterfaceOrientationLandscapeRight: {
                    [self VIDEO_STATE_NORMAL_MENU_LANDSCAPE_RIGHT:animation];
                }
                    break;
                case UIInterfaceOrientationLandscapeLeft: {
                    [self VIDEO_STATE_NORMAL_MENU_LANDSCAPE_LEFT:animation];
                }
                    break;
                default:
                    break;
            }
            
            [self calculateAudioCallEndButtonCenter];
        }
            break;
        case VideoViewState_TAB_MENU: {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            [self ShowHideAllViews:YES];
            self.viewDisplayName.hidden = YES;
            self.viewAudioCallMenu.hidden = YES;
            self.viewLocalVideo.hidden = NO;
            self.imageViewRemoteVideo.hidden = NO;
            self.buddyButton.hidden=YES;
            
            
            timerHideMenu = [self CreateTimerHideMenu];
            switch (self.interfaceOrientation) {
                case UIInterfaceOrientationPortrait: {
                    [self VIDEO_STATE_TAB_MENU_PORTRAIT:animation];
                }
                    break;
                case UIInterfaceOrientationLandscapeRight: {
                    [self VIDEO_STATE_TAB_MENU_LANDSCAPE_RIGHT:animation];
                }
                    break;
                case UIInterfaceOrientationLandscapeLeft: {
                    [self VIDEO_STATE_TAB_MENU_LANDSCAPE_LEFT:animation];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case VideoViewState_TAB: {
            [[UIApplication sharedApplication] setStatusBarHidden:[self isVideoState] withAnimation:UIStatusBarAnimationSlide];
            [self ShowHideAllViews:YES];
            self.viewDisplayName.hidden = YES;
            self.viewAudioCallMenu.hidden = YES;
            self.viewLocalVideo.hidden = NO;
            self.imageViewRemoteVideo.hidden = NO;
            self.buddyButton.hidden=YES;
            
            switch (self.interfaceOrientation) {
                case UIInterfaceOrientationPortrait: {
                    [self VIDEO_STATE_TAB_PORTRAIT:animation];
                }
                    break;
                case UIInterfaceOrientationLandscapeRight: {
                    [self VIDEO_STATE_TAB_LANDSCAPE_RIGHT:animation];
                }
                    break;
                case UIInterfaceOrientationLandscapeLeft: {
                    [self VIDEO_STATE_TAB_LANDSCAPE_LEFT:animation];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case VideoViewState_HIDE:
        case VideoViewState_PREVIEW:{
            if (state == VideoViewState_HIDE) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                
            }
            self.videoViewState = VideoViewState_HIDE;
            [idoubs2AppDelegate RefreshTab];
            [self ShowHideAllViews:NO];
            self.viewAudioCallMenu.hidden = YES;
            self.viewLocalVideo.hidden = YES;
            self.buddyButton.hidden=YES;
            
            [idoubs2AppDelegate RefreshTab];
            switch (self.interfaceOrientation) {
                case UIInterfaceOrientationPortrait: {
                    [self VIDEO_STATE_HIDE_PORTRAIT:NO];
                }
                    break;
                case UIInterfaceOrientationLandscapeRight: {
                    [self VIDEO_STATE_HIDE_LANDSCAPE_RIGHT:NO];
                }
                    break;
                case UIInterfaceOrientationLandscapeLeft: {
                    [self VIDEO_STATE_HIDE_LANDSCAPE_LEFT:NO];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case VideoViewState_Calling:{
            buttonPushUp.hidden = YES ;
            self.viewAudioCallMenu.hidden = NO;
            self.viewDisplayName.hidden = NO;
            viewLocalVideo.hidden = YES;
            [self VIDEO_STATE_NORMAL_PORTRAIT:NO];
            [buttonAudioVideo setSelected:self.videoSend];
            buttonAudioProfile.enabled = NO;
            buttonAudioMessage.enabled = NO;
            buttonAudioBuddy.enabled = NO;
            labelCallingState.hidden = NO;
        }
            break;
            
        default:
            break;
    }
    
    if (self.videoViewState == VideoViewState_HIDE && ([[idoubs2AppDelegate sharedInstance].videoService isInCall] || [idoubs2AppDelegate sharedInstance].videoService.isOnHold)) {
        [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView StartAnimation];
    } else {
        [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView StopAnimation];
    }
    
    [Common postNotificationWithName:kVideoViewChangeNotification object:[NSNumber numberWithInt:videoViewState]];
    [Common postNotificationWithName:kVideoViewOrientationChangeNotification object:[NSNumber numberWithInt:self.interfaceOrientation]];
    
    if (state != VideoViewState_HIDE && [_delegate respondsToSelector:@selector(didChangeLocalVideoFrame)]) {
        [_delegate didChangeLocalVideoFrame];
    }
    
    if ([_delegate respondsToSelector:@selector(didChangeRemoteVideoStateTo:Split:Orientation:frame:)]) {
        [_delegate didChangeRemoteVideoStateTo:state Split:splited Orientation:UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? YES : NO frame:self.viewLocalVideo.frame];
    }
}

- (BOOL) isVideoState {
    return (self.videoSend || self.videoRecive) ? YES : NO;
}

#pragma mark -
#pragma mark Video States Methods start
#pragma mark -

- (void) VIDEO_STATE_NORMAL_PORTRAIT:(BOOL)animation {
    [self setFrame:State_NORMAL_Rect Animation:animation];
    if ([[UIScreen mainScreen] bounds].size.height == 568) {
        if ([self isVideoState]) {
            [self setViewMenuFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 92, 320, 92) Animation:animation];
            viewReconnect.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 92);
        } else {
            [self setViewMenuFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 60, 320, 60) Animation:animation];
            viewReconnect.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 60);
        }
    } else {
        if ([self isVideoState]) {
            [self setViewMenuFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, 320, 92) Animation:animation];
            viewReconnect.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height);
        } else {
            [self setViewMenuFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 60, 320, 60) Animation:animation];
            viewReconnect.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 60);
        }
    }
    if (self.videoViewState == VideoViewState_Calling){
        [self setViewMenuFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 60, 320, 60) Animation:animation];
        viewReconnect.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 60);
        
    }
    if (splited) {
        [self ChangeLocalVideoFrame:Local_Video_Split_Rect HaveBorder:NO Animation:animation];
        [self setRemoteVideoFrame:CGRectMake(0, 0, 320, 240) Animation:animation];
    } else {
        [[idoubs2AppDelegate sharedInstance].videoService setProducerOrentation:AVCaptureVideoOrientationPortrait];
        
        [self ChangeLocalVideoFrame:Local_Video_Small_Rect HaveBorder:YES Animation:animation];
        [self setRemoteVideoFrame:CGRectMake(0, 0, 320, 480) Animation:animation];
    }
}

- (void) VIDEO_STATE_NORMAL_LANDSCAPE_RIGHT:(BOOL)animation {
    
    
    //                    viewWhite.frame = CGRectMake(self.frame.size.width - 640, 0, 320, 480);
    [self setFrame:State_NORMAL_Landscape_Right_Rect Animation:animation];
    
    if ([self isVideoState]) {
        [self setViewMenuFrame:CGRectMake(-50, 0, 50, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
    } else {
        [self setViewMenuFrame:CGRectMake(0, 0, 50, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
    }
    
    if (splited) {
        [self ChangeLocalVideoFrame:Local_Video_Split_Right_Rect HaveBorder:NO Animation:animation];
        [self setRemoteVideoFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/2, 320, [[UIScreen mainScreen] bounds].size.height/2) Animation:animation];
    } else {
        [[idoubs2AppDelegate sharedInstance].videoService setProducerOrentation:AVCaptureVideoOrientationLandscapeLeft];
        [self ChangeLocalVideoFrame:Local_Video_Small_Right_Rect HaveBorder:YES Animation:animation];
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            [self setRemoteVideoFrame:CGRectMake(0, 44, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 88) Animation:animation];
        } else {
            [self setRemoteVideoFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
        }
    }
}

- (void) VIDEO_STATE_NORMAL_LANDSCAPE_LEFT:(BOOL)animation {
    
    //                    viewWhite.frame = CGRectMake(320, 0, 320, 480);
    [self setFrame:State_NORMAL_Landscape_Left_Rect Animation:animation];
    if ([self isVideoState]) {
        [self setViewMenuFrame:CGRectMake(320, 0, 50, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
    } else {
        [self setViewMenuFrame:CGRectMake(270, 0, 50, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
    }
    
    if (splited) {
        [self ChangeLocalVideoFrame:Local_Video_Split_Left_Rect HaveBorder:NO Animation:animation];
        [self setRemoteVideoFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height/2) Animation:animation];
    } else {
        [[idoubs2AppDelegate sharedInstance].videoService setProducerOrentation:AVCaptureVideoOrientationLandscapeRight];
        
        [self ChangeLocalVideoFrame:Local_Video_Small_Left_Rect HaveBorder:YES Animation:animation];
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            [self setRemoteVideoFrame:CGRectMake(0, 44, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 88) Animation:animation];
        } else {
            [self setRemoteVideoFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
        }
    }
}

- (void) VIDEO_STATE_NORMAL_MENU_PORTRAIT:(BOOL)animation {
    //                    viewWhite.frame = CGRectMake(0, 480, 320, 480);
    [self setFrame:State_NORMAL_MENU_Rect Animation:animation];
    
    if ([self isVideoState]) {
        [self setViewMenuFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 92, 320, 92) Animation:animation];
        viewReconnect.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 92);
    } else {
        [self setViewMenuFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 60, 320, 60) Animation:animation];
        viewReconnect.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 60);
    }
    
    if (splited) {
        CGRect frame = Local_Video_Split_Rect;
        frame.origin.y = frame.origin.y - 92;
        [self ChangeLocalVideoFrame:frame HaveBorder:NO Animation:animation];
        [self setRemoteVideoFrame:CGRectMake(0, State_NORMAL_MENU_Rect.origin.y, 320, 240) Animation:YES];
    } else {
        CGRect frame = Local_Video_Small_Rect;
        frame.origin.y = frame.origin.y - 92;
        [self ChangeLocalVideoFrame:frame HaveBorder:YES Animation:animation];
        
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            [self setRemoteVideoFrame:CGRectMake(0, 0, 320, 480) Animation:YES];
            [self ChangeLocalVideoFrame:Local_Video_Small_Rect HaveBorder:YES Animation:animation];
        } else {
            CGRect frame = Local_Video_Small_Rect;
            frame.origin.y = frame.origin.y - 92;
            [self ChangeLocalVideoFrame:frame HaveBorder:YES Animation:animation];
            [self setRemoteVideoFrame:CGRectMake(0, State_NORMAL_MENU_Rect.origin.y, 320, 480) Animation:YES];
        }
    }
}

- (void) VIDEO_STATE_NORMAL_MENU_LANDSCAPE_RIGHT:(BOOL)animation {
    //                    viewWhite.frame = CGRectMake(self.frame.size.width - 640, 0, 320, 480);
    [self setFrame:State_NORMAL_MENU_Landscape_Right_Rect Animation:animation];
    [self setViewMenuFrame:CGRectMake(0, 0, 50, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
    
    if (splited) {
        CGRect frame = Local_Video_Split_Right_Rect;
        frame.origin.x += 50;
        [self ChangeLocalVideoFrame:frame HaveBorder:NO Animation:animation];
        [self setRemoteVideoFrame:CGRectMake(50, [[UIScreen mainScreen] bounds].size.height/2, 320, [[UIScreen mainScreen] bounds].size.height/2) Animation:animation];
    } else {
        CGRect frame = Local_Video_Small_Right_Rect;
        frame.origin.x += 50;
        [self ChangeLocalVideoFrame:frame HaveBorder:YES Animation:animation];
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            [self setRemoteVideoFrame:CGRectMake(50, 44, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 88) Animation:animation];
        } else {
            [self setRemoteVideoFrame:CGRectMake(50, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
        }
    }
}

- (void) VIDEO_STATE_NORMAL_MENU_LANDSCAPE_LEFT:(BOOL)animation {
    //                    viewWhite.frame = CGRectMake(320, 0, 320, 480);
    [self setFrame:State_NORMAL_MENU_Landscape_Left_Rect Animation:animation];
    [self setViewMenuFrame:CGRectMake(270, 0, 50, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
    
    if (splited) {
        CGRect frame = Local_Video_Split_Left_Rect;
        frame.origin.x -= 50;
        [self ChangeLocalVideoFrame:frame HaveBorder:NO Animation:animation];
        [self setRemoteVideoFrame:CGRectMake(-50, 0, 320, [[UIScreen mainScreen] bounds].size.height/2) Animation:animation];
    } else {
        CGRect frame = Local_Video_Small_Left_Rect;
        frame.origin.x -= 50;
        [self ChangeLocalVideoFrame:frame HaveBorder:YES Animation:animation];
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            [self setRemoteVideoFrame:CGRectMake(-50, 44, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 88) Animation:animation];
        } else {
            [self setRemoteVideoFrame:CGRectMake(-50, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
        }
    }
}

- (void) VIDEO_STATE_TAB_MENU_PORTRAIT:(BOOL)animation {
    //                    viewWhite.frame = CGRectMake(0, 0, 320, 480);
    if ([self isVideoState]) {
        [self setViewMenuFrame:CGRectMake(0, 0, 320, 92) Animation:animation];
    } else {
        [self setViewMenuFrame:CGRectMake(0, 0, 320, 60) Animation:animation];
    }
    
    if ([self isVideoState]) {
        [self setFrame:State_TAB_MENU_Rect Animation:animation];
        [self ChangeLocalVideoFrame:Local_Video_Rect HaveBorder:NO Animation:animation];
        [self setRemoteVideoFrame:Remote_Video_Rect Animation:YES];
    } else {
        //        self.videoViewState = VideoViewState_HIDE;
        CGRect frame = State_TAB_MENU_Rect;
        frame.origin.y -= 192;
        [self setFrame:frame Animation:animation];
        [self ChangeLocalVideoFrame:Local_Video_Rect_Hide HaveBorder:NO Animation:animation];
        [self setRemoteVideoFrame:Remote_Video_Rect_Hide Animation:NO];
    }
}

- (void) VIDEO_STATE_TAB_MENU_LANDSCAPE_RIGHT:(BOOL)animation {
    //                    viewWhite.frame = CGRectMake(self.frame.size.width - 320, 0, 320, 480);
    [self setFrame:State_TAB_MENU_Landscape_Right_Rect Animation:animation];
    [self setViewMenuFrame:CGRectMake(270, 0, 50, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
    
    if ([self isVideoState]) {
        [self ChangeLocalVideoFrame:Local_Video_Right_Rect HaveBorder:NO Animation:animation];
        [self setRemoteVideoFrame:Remote_Video_Right_Rect Animation:YES];
    } else {
        //        self.videoViewState = VideoViewState_HIDE;
        CGRect frame = Local_Video_Right_Rect;
        frame.origin.x = 320;
        [self ChangeLocalVideoFrame:frame HaveBorder:NO Animation:animation];
        frame = Remote_Video_Right_Rect;
        frame.origin.x = 320;
        [self setRemoteVideoFrame:frame Animation:YES];
    }
}

- (void) VIDEO_STATE_TAB_MENU_LANDSCAPE_LEFT:(BOOL)animation {
    //                    viewWhite.frame = CGRectMake(0, 0, 320, 480);
    [self setFrame:State_TAB_MENU_Landscape_Left_Rect Animation:animation];
    [self setViewMenuFrame:CGRectMake(0, 0, 50, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
    
    if ([self isVideoState]) {
        CGRect frame = Local_Video_Left_Rect;
        frame.origin.x += 50;
        [self ChangeLocalVideoFrame:frame HaveBorder:NO Animation:animation];
        frame = Remote_Video_Left_Rect;
        frame.origin.x += 50;
        [self setRemoteVideoFrame:frame Animation:YES];
    } else {
        //        self.videoViewState = VideoViewState_HIDE;
        CGRect frame = Local_Video_Left_Rect;
        frame.origin.x = -Local_Video_Left_Rect.size.width;
        [self ChangeLocalVideoFrame:frame HaveBorder:NO Animation:animation];
        frame = Remote_Video_Left_Rect;
        frame.origin.x = -Remote_Video_Left_Rect.size.width;
        [self setRemoteVideoFrame:frame Animation:YES];
    }
}

- (void) VIDEO_STATE_TAB_PORTRAIT:(BOOL)animation {
    if ([self isVideoState]) {
        [self setViewMenuFrame:CGRectMake(0, -92, 320, 92) Animation:animation];
    } else {
        [self setViewMenuFrame:CGRectMake(0, -60, 320, 60) Animation:animation];
    }
    
    self.videoViewState = VideoViewState_TAB;
    
    if ([self isVideoState]) {
        [self setFrame:State_TAB_Rect Animation:TRUE];
        CGRect frame = Local_Video_Rect;
        frame.origin.y = 0;
        [self ChangeLocalVideoFrame:frame HaveBorder:NO Animation:animation];
        frame = Remote_Video_Rect;
        frame.origin.y = 0;
        [self setRemoteVideoFrame:frame Animation:animation];
    } else {
        self.videoViewState = VideoViewState_HIDE;
        [self VIDEO_STATE_HIDE_PORTRAIT:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [idoubs2AppDelegate RefreshTab];
    }
}

- (void) VIDEO_STATE_TAB_LANDSCAPE_RIGHT:(BOOL)animation {
    //                    viewWhite.frame = CGRectMake(self.frame.size.width - 320, 0, 320, 480);
    [self setFrame:State_TAB_Landscape_Right_Rect Animation:animation];
    [self setViewMenuFrame:CGRectMake(320, 0, 50, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
    
    if ([self isVideoState]) {
        CGRect frame = Local_Video_Right_Rect;
        frame.origin.x += 50;
        [self ChangeLocalVideoFrame:frame HaveBorder:NO Animation:animation];
        frame = Remote_Video_Right_Rect;
        frame.origin.x += 50;
        [self setRemoteVideoFrame:frame Animation:YES];
    } else {
        self.videoViewState = VideoViewState_HIDE;
        [self VIDEO_STATE_HIDE_LANDSCAPE_RIGHT:YES];
    }
}

- (void) VIDEO_STATE_TAB_LANDSCAPE_LEFT:(BOOL)animation {
    //                    viewWhite.frame = CGRectMake(0, 0, 320, 480);
    [self setFrame:State_TAB_Landscape_Left_Rect Animation:animation];
    [self setViewMenuFrame:CGRectMake(-50, 0, 50, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
    
    if ([self isVideoState]) {
        [self ChangeLocalVideoFrame:Local_Video_Left_Rect HaveBorder:NO Animation:animation];
        [self setRemoteVideoFrame:Remote_Video_Left_Rect Animation:YES];
    } else {
        self.videoViewState = VideoViewState_HIDE;
        [self VIDEO_STATE_HIDE_LANDSCAPE_LEFT:YES];
    }
}

- (void) VIDEO_STATE_HIDE_PORTRAIT:(BOOL)animation {
    [self setFrame:State_Hide_Rect Animation:animation];
    if ([self isVideoState]) {
        [self setViewMenuFrame:CGRectMake(0, -92, 320, 92) Animation:animation];
    } else {
        [self setViewMenuFrame:CGRectMake(0, -60, 320, 60) Animation:animation];
    }
    
    [self ChangeLocalVideoFrame:Local_Video_Rect_Hide HaveBorder:NO Animation:animation];
    [self setRemoteVideoFrame:Remote_Video_Rect_Hide Animation:animation];
}

- (void) VIDEO_STATE_HIDE_LANDSCAPE_RIGHT:(BOOL)animation {
    [self setFrame:State_Hide_Landscape_Right_Rect Animation:animation];
    [self setViewMenuFrame:CGRectMake(320, 0, 50, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
    
    CGRect frame = Local_Video_Right_Rect;
    frame.origin.x = 340;
    [self ChangeLocalVideoFrame:frame HaveBorder:NO Animation:animation];
    frame = Remote_Video_Right_Rect;
    frame.origin.x = 320;
    [self setRemoteVideoFrame:frame Animation:animation];
}

- (void) VIDEO_STATE_HIDE_LANDSCAPE_LEFT:(BOOL)animation {
    [self setFrame:State_Hide_Landscape_Left_Rect Animation:animation];
    [self setViewMenuFrame:CGRectMake(-50, 0, 50, [[UIScreen mainScreen] bounds].size.height) Animation:animation];
    
    CGRect frame = Local_Video_Left_Rect;
    frame.origin.x = -Local_Video_Left_Rect.size.width;
    [self ChangeLocalVideoFrame:frame HaveBorder:NO Animation:animation];
    frame = Remote_Video_Left_Rect;
    frame.origin.x = -Remote_Video_Left_Rect.size.width;
    [self setRemoteVideoFrame:frame Animation:animation];
}

- (void) ShowHideAllViews:(BOOL)show {
    self.hidden = !show;
    self.imageViewRemoteVideo.hidden = !show;
}

- (void) ShowRemotProfileImage:(BOOL)show {
    imageViewProfile.hidden = !show;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        CGRect maskBounds = CGRectMake(0, (imageViewProfile.frame.size.height - 320)/2, imageViewProfile.frame.size.width, 320);
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        CGPathRef maskPath = CGPathCreateWithRect(maskBounds, NULL);
        maskLayer.bounds = maskBounds;
        [maskLayer setPath:maskPath];
        [maskLayer setFillColor:[[UIColor blackColor] CGColor]];
        maskLayer.position = CGPointMake(maskBounds.size.width/2, maskBounds.size.height/2);
        
        [imageViewProfile.layer setMask:maskLayer];
        CGPathRelease(maskPath);
    } else {
        UIImageView *imageViewTemp = [[UIImageView alloc] initWithFrame:imageViewProfile.frame];
        [imageViewTemp setBackgroundColor:[UIColor blackColor]];
        imageViewTemp.contentMode = UIViewContentModeScaleAspectFill;
        [imageViewTemp setImage:imageViewProfile.image];
        imageViewTemp.hidden = imageViewProfile.hidden;
        [self.imageViewRemoteVideo insertSubview:imageViewTemp belowSubview:imageViewProfile];
        [imageViewProfile removeFromSuperview];
        imageViewProfile = imageViewTemp;
    }
}

- (void) SetRemotProfileImage:(UIImage*)image {
    [imageViewProfile setImage:image];
}

- (void) SetDisplayName {
    [self.labelDisplayName setText:contactObject.displayName];
}

- (void) SetTime:(int)time {
    [self.labelTime setText:[Common ConvertDurationToStringForCall:time]];
}


-(CGFloat) getAppropriateFontSize:(NSString*) message {
    CGSize textViewSize = [message sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]
                              constrainedToSize:CGSizeMake(labelReconnectingAudio.frame.size.width, FLT_MAX)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    
    return textViewSize.height > labelReconnectingAudio.frame.size.height ? 13.:17.;
}


- (void) ShowReconnectView:(BOOL)show Message:(NSString*)message {
    isReconnecting = show;
    
    if (show) {
        if (![self isVideoState]) {
            labelTime.hidden = YES;
            labelReconnectingAudio.hidden = NO;
            [labelReconnectingAudio setText:message];
            CGFloat fontSize = [self getAppropriateFontSize:message];
            [labelReconnectingAudio setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize]];
        } else {
            [labelReconnecting setText:message];
            if (![viewReconnect superview]) {
                labelReconnecting.transform = CGAffineTransformMakeRotation(0);
                switch (self.interfaceOrientation) {
                    case UIInterfaceOrientationPortrait: {
                        viewReconnect.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 87);
                        labelReconnecting.center = CGPointMake(viewReconnect.frame.size.width/2, viewReconnect.frame.size.height/2);
                    }
                        break;
                    case UIInterfaceOrientationLandscapeLeft: {
                        viewReconnect.frame = CGRectMake(0, 0, 270, [[UIScreen mainScreen] bounds].size.height);
                        labelReconnecting.center = CGPointMake(viewReconnect.frame.size.width/2, viewReconnect.frame.size.height/2 + 150);
                        labelReconnecting.transform = CGAffineTransformMakeRotation(-M_PI_2);
                    }
                        break;
                    case UIInterfaceOrientationLandscapeRight: {
                        viewReconnect.frame = CGRectMake(50, 0, 270, [[UIScreen mainScreen] bounds].size.height);
                        labelReconnecting.center = CGPointMake(viewReconnect.frame.size.width/2, viewReconnect.frame.size.height/2 - 150);
                        labelReconnecting.transform = CGAffineTransformMakeRotation(M_PI_2);
                    }
                        break;
                        
                    default:
                        break;
                }
                [[idoubs2AppDelegate sharedInstance].window addSubview:viewReconnect];
                
                [self setVideoState:VideoViewState_NORMAL_MENU Animation:YES];
            }
        }
    } else {
        labelTime.hidden = NO;
        labelReconnectingAudio.hidden = YES;
        [viewReconnect removeFromSuperview];
    }
}

- (void) ShowReconnectViewWithMessage:(NSString*)message {
    [self ShowReconnectView:YES Message:message];
}

- (void) StartTimerForEndCall {
    NSLog(@"[CALL] {StartTimerForEndCall}");
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:RTMP_CALL_EVENT_TYPE_REQUESTTIMEOUT], @"rtmp_call_event", nil];
    [[idoubs2AppDelegate sharedInstance].videoService onRTMPEvent:userInfo];
    [idoubs2AppDelegate RTMP_Hangup_Call];
}

- (void) StartTimerReconnectForEndCall {
    NSLog(@"[CALL][RECONNECT] {StartTimerReconnectForEndCall}");
    //    if (!endCallTimerStarted) {
    //        endCallTimerStarted = YES;
    //
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:RTMP_CALL_EVENT_TYPE_REQUESTTIMEOUT], @"rtmp_call_event", nil];
    [[idoubs2AppDelegate sharedInstance].videoService onRTMPEvent:userInfo];
    //        [self performSelector:@selector(onButtonEndCall:) withObject:nil afterDelay:START_RECONNECT_CALL_TIME_OUT];
    //    }
}

- (void) CancelTimerForEndCall {
    //    if (endCallTimerStarted) {
    //        endCallTimerStarted = NO;
    NSLog(@"[CALL] {CancelTimerForEndCall}");
    
    [NSObject cancelPreviousPerformRequestsWithTarget:[idoubs2AppDelegate sharedInstance].videoService.showVideoView selector:@selector(StartTimerForEndCall) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:[idoubs2AppDelegate sharedInstance].videoService.showVideoView selector:@selector(StartTimerReconnectForEndCall) object:nil];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onButtonEndCall:) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(StartTimerReconnectForEndCall:) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(StartTimerForEndCall) object:nil];
    //    }
}

- (void) setProfileImage:(UIImage*)image {
    //    [imageViewProfile setImage:[UIImage imageNamed:@"ExampleImage.png"]];
}

#pragma mark -
#pragma mark Video States Methods end
#pragma mark -

- (void) ChangeLocalVideoFrame:(CGRect)frame HaveBorder:(BOOL)border Animation:(BOOL)animation {
    if (animation) {
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3];
    }
    
    [self.viewLocalVideo setFrame:frame];
    
    if (animation) {
        [UIView commitAnimations];
    }
    
    if (border) {
        self.viewLocalVideo.layer.borderWidth = 2.;
        self.viewLocalVideo.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.viewLocalVideo.layer.cornerRadius = 2.f;
    } else {
        [self.viewLocalVideo.layer setMask:nil];
        [self.viewLocalVideo.layer setMasksToBounds:YES];
        self.viewLocalVideo.layer.borderWidth = 0.f;
        self.viewLocalVideo.layer.cornerRadius = 0.f;
    }
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        buttonChangeCamera.center = CGPointMake(self.viewLocalVideo.frame.size.height/2, self.viewLocalVideo.frame.size.width/2);
    } else {
        buttonChangeCamera.center = CGPointMake(self.viewLocalVideo.frame.size.width/2, self.viewLocalVideo.frame.size.height/2);
    }
    
    [self LocalVideoStateChanged:[idoubs2AppDelegate sharedInstance].videoService.isRecVideoLandscape];
}

- (void) callBackTimerHideMenu {
    [self StopTimerHideMenu];
    
    if ([self superview] && ![viewReconnect superview]) {
        if (videoViewState == VideoViewState_TAB_MENU) {
            [self setVideoState:VideoViewState_TAB Animation:YES];
        } else {
            if (videoViewState == VideoViewState_NORMAL_MENU) {
                [self setVideoState:VideoViewState_NORMAL Animation:YES];
            }
        }
    }
}

- (void) setFrame:(CGRect)frame Animation:(BOOL)animation {
    if (animation) {
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3];
    }
    self.frame = frame;
    if (animation) {
        [UIView commitAnimations];
    }
}

- (void) setViewMenuFrame:(CGRect)frame Animation:(BOOL)animation {
    if (animation) {
        [UIView beginAnimations:@"frameViewMenu" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3];
    }
    
    viewMenu.frame = frame;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)&& self.interfaceOrientation!=UIInterfaceOrientationPortraitUpsideDown) {
        frame.origin.x = 0;
        frame.origin.y = 0;
        viewAlpha.frame = frame;
        viewAudioEndCall.frame = frame;
    }
    
    if (animation) {
        [UIView commitAnimations];
    }
}

- (void) setRemoteVideoFrame:(CGRect)frame Animation:(BOOL)animation {
    
    if (animation) {
        [UIView beginAnimations:@"frameRemoteVideo" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3];
    }
    
    //    if (![self isVideoState] && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) &&
    //        (self.videoViewState == VideoViewState_NORMAL || self.videoViewState == VideoViewState_NORMAL_MENU)) {
    //        self.imageViewRemoteVideo.frame = CGRectMake(frame.origin.x, frame.origin.y+100, self.frame.size.width, self.frame.size.height);
    //        NSLog(@"self.imageViewRemoteVideo.frame: %@", NSStringFromCGRect(self.imageViewRemoteVideo.frame));
    //    } else {
    self.imageViewRemoteVideo.frame = frame;
    //    }
    
    // comented for integration
    //    if(![self.openGlView inicalizationStatus])
    //        self.openGlView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    [self changeNetworkStatusImageViewFrame];
    
    if (animation) {
        [UIView commitAnimations];
    }
    
    if(![self isVideoState]){
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            imageViewProfile.frame = CGRectMake(0, 0, imageViewRemoteVideo.frame.size.width, imageViewRemoteVideo.frame.size.height);
            imageViewProfile.hidden=NO;
        } else {
            if (videoViewState!=VideoViewState_HIDE && videoViewState!=VideoViewState_TAB_MENU) {
                NSLog(@"imageViewRemoteVideo.frame: %@", NSStringFromCGRect(imageViewRemoteVideo.frame));
                int origin_y = 0 - ([[UIScreen mainScreen] bounds].size.height - imageViewRemoteVideo.frame.size.height)/2;
                imageViewProfile.frame = CGRectMake(origin_y, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
                imageViewProfile.hidden=NO;
            }else
                imageViewProfile.hidden=YES;
        }
    }else{
        imageViewProfile.frame = CGRectMake(0, 0, imageViewRemoteVideo.frame.size.width, imageViewRemoteVideo.frame.size.height);
        
        
    }
}

- (void) changeNetworkStatusImageViewFrame {
    if (videoViewState == VideoViewState_NONE || videoViewState == VideoViewState_HIDE) {
        self.imageViewNetworkStatus.frame = CGRectZero;
    } else {
        self.imageViewNetworkStatus.frame = CGRectMake(10, 15, 35, 6);
    }
}

- (void) DrawSmallVideo {
    UIImage *image = [self renderToImage];
    
    static UIImageView *imageView = nil;
    
    if (imageView == nil) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 400, 400)];
        [imageView setBackgroundColor:[UIColor grayColor]];
        [self addSubview:imageView];
    }
    
    [imageView setImage:image];
}

- (UIImage*) renderToImage
{
    CGSize size = CGSizeMake(400, 400);
    UIGraphicsBeginImageContext(size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void) handlePanRemoteVideo:(UIPanGestureRecognizer *)recognizer {
    [self handlePan:recognizer];
}

- (void) handlePanLocalVideo:(UIPanGestureRecognizer *)recognizer {
    [self handlePan:recognizer];
}

- (void) handlePan:(UIPanGestureRecognizer *)recognizer {
    if([[idoubs2AppDelegate sharedInstance].videoService isInCall]){
        
        CGPoint translation = [recognizer translationInView:self];
        
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            self.center = CGPointMake(self.center.x,
                                      self.center.y + translation.y);
            
            self.viewLocalVideo.center = CGPointMake(self.viewLocalVideo.center.x,
                                                     self.viewLocalVideo.center.y + translation.y);
            
            self.imageViewRemoteVideo.center = CGPointMake(self.imageViewRemoteVideo.center.x,
                                                           self.imageViewRemoteVideo.center.y + translation.y);
            
            viewMenu.center = CGPointMake(viewMenu.center.x,
                                          viewMenu.center.y + translation.y);
            
            //        viewWhite.center = CGPointMake(viewWhite.center.x,
            //                                       viewWhite.center.y + translation.y);
        } else {
            self.center = CGPointMake(self.center.x + translation.x,
                                      self.center.y);
            
            self.viewLocalVideo.center = CGPointMake(self.viewLocalVideo.center.x + translation.x,
                                                     self.viewLocalVideo.center.y);
            
            self.imageViewRemoteVideo.center = CGPointMake(self.imageViewRemoteVideo.center.x + translation.x,
                                                           self.imageViewRemoteVideo.center.y);
            
            viewMenu.center = CGPointMake(viewMenu.center.x + translation.x,
                                          viewMenu.center.y);
            
            //        viewWhite.center = CGPointMake(viewWhite.center.x + translation.x,
            //                                       viewWhite.center.y);
        }
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:self];
        
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self RecognizerStateEnded];
        }
    }
}

- (void) RecognizerStateEnded {
    
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationPortrait: {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            
            if (self.frame.origin.y > -300 && self.frame.origin.y < -40 && result.height != 568) {
                if ([self isVideoState]) {
                    [self setVideoState:VideoViewState_NORMAL_MENU Animation:YES];
                } else {
                    [self setVideoState:VideoViewState_NORMAL Animation:YES];
                }
            } else {
                if (self.frame.origin.y > -40 || (self.frame.origin.y > -288 && result.height == 568)) {
                    [self setVideoState:VideoViewState_NORMAL Animation:YES];
                } else {
                    if (self.frame.origin.y < -600) {
                        [self setVideoState:VideoViewState_HIDE Animation:YES];
                    } else {
                        if (self.frame.origin.y < -520) {
                            [self setVideoState:VideoViewState_TAB Animation:YES];
                        } else {
                            [self setVideoState:VideoViewState_TAB_MENU Animation:YES];
                        }
                    }
                }
            }
        }
            break;
        case UIInterfaceOrientationLandscapeRight: {
            if (self.frame.origin.x < 185 && self.frame.origin.x > 25) {
                if ([self isVideoState]) {
                    [self setVideoState:VideoViewState_NORMAL_MENU Animation:YES];
                } else {
                    [self setVideoState:VideoViewState_NORMAL Animation:YES];
                }
            } else {
                if (self.frame.origin.x < 25) {
                    [self setVideoState:VideoViewState_NORMAL Animation:YES];
                } else {
                    if (self.frame.origin.x > 390) {
                        [self setVideoState:VideoViewState_HIDE Animation:YES];
                    } else {
                        if ([idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex == 1 ||
                            [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex == 2) {
                            if (self.frame.origin.x > 340) {
                                [self setVideoState:VideoViewState_TAB Animation:YES];
                            } else {
                                [self setVideoState:VideoViewState_TAB_MENU Animation:YES];
                            }
                        } else {
                            [self setVideoState:VideoViewState_NORMAL Animation:YES];
                        }
                    }
                }
            }
        }
            break;
        case UIInterfaceOrientationLandscapeLeft: {
            if (self.frame.origin.x < -25 && self.frame.origin.x > -185) {
                if ([self isVideoState]) {
                    [self setVideoState:VideoViewState_NORMAL_MENU Animation:YES];
                } else {
                    [self setVideoState:VideoViewState_NORMAL Animation:YES];
                }
            } else {
                if (self.frame.origin.x > -25) {
                    [self setVideoState:VideoViewState_NORMAL Animation:YES];
                } else {
                    if (self.frame.origin.x < -390) {
                        [self setVideoState:VideoViewState_HIDE Animation:YES];
                    } else {
                        if ([idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex == 1 ||
                            [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex == 2) {
                            if (self.frame.origin.x < -340) {
                                [self setVideoState:VideoViewState_TAB Animation:YES];
                            } else {
                                [self setVideoState:VideoViewState_TAB_MENU Animation:YES];
                            }
                        } else {
                            [self setVideoState:VideoViewState_NORMAL Animation:YES];
                        }
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        switch (videoViewState) {
            case VideoViewState_NONE:
            case VideoViewState_NORMAL:
            case VideoViewState_NORMAL_MENU: {
                if ([sender scale] > 1.0) {
                    splited = NO;
                } else {
                    splited = YES;
                }
                
                [self setVideoState:videoViewState Animation:NO];
            }
                break;
            default:{
            }
                break;
        }
    }
}

- (void) OneTapOnLocalVideo:(UITapGestureRecognizer*)sender {
    CGPoint translation = [sender locationInView:self.viewLocalVideo];
    
    if (CGRectContainsPoint(buttonChangeCamera.frame, translation) && [buttonChangeCamera superview]) {
        [self onButtonChangeCamera:buttonChangeCamera];
    } else {
        [self.viewLocalVideo addSubview:buttonChangeCamera];
        
        timerHideChangeCameraButton = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                       target:self
                                                                     selector:@selector(callBackTimerHideChangeCameraButton)
                                                                     userInfo:nil
                                                                      repeats:NO];
    }
}

- (void) callBackTimerHideChangeCameraButton {
    if (timerHideChangeCameraButton && [timerHideChangeCameraButton isKindOfClass:[NSTimer class]]) {
        [timerHideChangeCameraButton invalidate];
        timerHideChangeCameraButton = nil;
    }
    
    [buttonChangeCamera removeFromSuperview];
}

- (void) VideoTabMenu {
    viewMenu = [[UIView alloc] initWithFrame:CGRectMake(0, 480 - 92, 320, 92)];
    [viewMenu setBackgroundColor:[UIColor clearColor]];
    
    viewAlpha = [[UIView alloc] initWithFrame:CGRectMake(0, 42, 320, 92)];
    [viewAlpha setBackgroundColor:[UIColor blackColor]];
    [viewAlpha setAlpha:0.5];
    [viewMenu addSubview:viewAlpha];
    
    buttonAudioEndCall = [[UIButton alloc] init];
    buttonAudioEndCall.frame = CGRectMake(18, 10, 273, 41);
    [buttonAudioEndCall setBackgroundImage:[UIImage imageNamed:@"seequEndCall.png"]
                                  forState:UIControlStateNormal];
    
    [buttonAudioEndCall addTarget:self
                           action:@selector(onButtonEndCall:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [buttonAudioEndCall addTarget:self
                           action:@selector(onButtonTouchDown:)
                 forControlEvents:UIControlEventTouchDown];
    
    [buttonAudioEndCall addTarget:self
                           action:@selector(onButtonTouchCancel:)
                 forControlEvents:UIControlEventTouchUpOutside];
    
    [viewMenu addSubview:buttonAudioEndCall];
    
    viewAudioEndCall = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 92)];
    [viewAudioEndCall setBackgroundColor:[UIColor clearColor]];
    [viewMenu addSubview:viewAudioEndCall];
    
    buttonCallerName = [[UIButton alloc] init];
    buttonCallerName.frame = CGRectMake(0, 0, 320, 42);
    
    if (contactObject.FirstName != nil && [contactObject.FirstName isKindOfClass:[NSString class]] && contactObject.FirstName.length &&
        contactObject.LastName != nil && [contactObject.LastName isKindOfClass:[NSString class]] && contactObject.LastName.length) {
        [buttonCallerName setTitle:[NSString stringWithFormat:@"%@ %@", contactObject.FirstName, contactObject.LastName]
                          forState:UIControlStateNormal];
    } else {
        if (contactObject.FirstName != nil &&
            [contactObject.FirstName isKindOfClass:[NSString class]] &&
            contactObject.FirstName.length) {
            [buttonCallerName setTitle:contactObject.FirstName forState:UIControlStateNormal];
            
            buttonCallerName.enabled = NO;
        }
    }
    
    buttonCallerName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    buttonCallerName.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    UIImage *imageBG = [UIImage imageNamed:@"seequCallerNameBg.png"];
    [buttonCallerName setBackgroundImage:imageBG forState:UIControlStateNormal];
    [buttonCallerName addTarget:self
                         action:@selector(onButtonContactDetail:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [buttonCallerName addTarget:self
                         action:@selector(onButtonTouchDown:)
               forControlEvents:UIControlEventTouchDown];
    
    [buttonCallerName addTarget:self
                         action:@selector(onButtonTouchCancel:)
               forControlEvents:UIControlEventTouchUpOutside];
    
    [viewAudioEndCall addSubview:buttonCallerName];
    
    buttonCallEnd = [[UIButton alloc] init];
    buttonCallEnd.frame = CGRectMake(0, 42, 128, 50);
    [buttonCallEnd setBackgroundImage:[UIImage imageNamed:@"seequVideoCallEnd.png"] forState:UIControlStateNormal];
    [buttonCallEnd setBackgroundImage:[UIImage imageNamed:@"seequVideoCallEndSel.png"] forState:UIControlStateHighlighted];
    [buttonCallEnd addTarget:self
                      action:@selector(onButtonEndCall:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [buttonCallEnd addTarget:self
                      action:@selector(onButtonTouchDown:)
            forControlEvents:UIControlEventTouchDown];
    
    [buttonCallEnd addTarget:self
                      action:@selector(onButtonTouchCancel:)
            forControlEvents:UIControlEventTouchUpOutside];
    
    [viewAudioEndCall addSubview:buttonCallEnd];
    
    buttonVideoOff = [[UIButton alloc] init];
    buttonVideoOff.frame = CGRectMake(128, 42, 64, 50);
    [buttonVideoOff setBackgroundImage:[UIImage imageNamed:@"seequVideoOff.png"] forState:UIControlStateNormal];
    [buttonVideoOff setBackgroundImage:[UIImage imageNamed:@"seequVideoOff.png"] forState:UIControlStateHighlighted];
    [buttonVideoOff addTarget:self
                       action:@selector(onButtonVideoOff:)
             forControlEvents:UIControlEventTouchUpInside];
    
    [buttonVideoOff addTarget:self
                       action:@selector(onButtonTouchDown:)
             forControlEvents:UIControlEventTouchDown];
    
    [buttonVideoOff addTarget:self
                       action:@selector(onButtonTouchCancel:)
             forControlEvents:UIControlEventTouchUpOutside];
    
    [viewAudioEndCall addSubview:buttonVideoOff];
    
    buttonMute = [[UIButton alloc] init];
    buttonMute.frame = CGRectMake(192, 42, 64, 50);
    [buttonMute setBackgroundImage:[UIImage imageNamed:@"seequVideoMute.png"] forState:UIControlStateNormal];
    [buttonMute setBackgroundImage:[UIImage imageNamed:@"seequVideoMuteSel.png"] forState:UIControlStateHighlighted];
    [buttonMute addTarget:self
                   action:@selector(onButtonMute:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [buttonMute addTarget:self
                   action:@selector(onButtonTouchDown:)
         forControlEvents:UIControlEventTouchDown];
    
    [buttonMute addTarget:self
                   action:@selector(onButtonTouchCancel:)
         forControlEvents:UIControlEventTouchUpOutside];
    
    [viewAudioEndCall addSubview:buttonMute];
    
    buttonSpeaker = [[UIButton alloc] init];
    buttonSpeaker.frame = CGRectMake(256, 42, 64, 50);
    [buttonSpeaker setBackgroundImage:[UIImage imageNamed:@"seequVideoSpeaker.png"] forState:UIControlStateNormal];
    [buttonSpeaker addTarget:self
                      action:@selector(onButtonSpeaker:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [buttonSpeaker addTarget:self
                      action:@selector(onButtonTouchDown:)
            forControlEvents:UIControlEventTouchDown];
    
    [buttonSpeaker addTarget:self
                      action:@selector(onButtonTouchCancel:)
            forControlEvents:UIControlEventTouchUpOutside];
    
    [viewAudioEndCall addSubview:buttonSpeaker];
}

- (void) AudioCallMenu {
    self.viewDisplayName = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 110)];
    [self.viewDisplayName setBackgroundColor:[UIColor clearColor]];
    [self.imageViewRemoteVideo addSubview:self.viewDisplayName];
    
    viewAlphaDisplayName = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, 110)];
    [viewAlphaDisplayName setBackgroundColor:[UIColor blackColor]];
    [viewAlphaDisplayName setAlpha:0.5];
    [viewDisplayName addSubview:viewAlphaDisplayName];
    
    // Button Push Up
    buttonPushUp = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [buttonPushUp setBackgroundImage:[UIImage imageNamed:@"buttonAudioCallPushUp.png"] forState:UIControlStateNormal];
    
    [buttonPushUp addTarget:self
                     action:@selector(onButtonPushUp:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [buttonPushUp addTarget:self
                     action:@selector(onButtonTouchDown:)
           forControlEvents:UIControlEventTouchDown];
    
    [buttonPushUp addTarget:self
                     action:@selector(onButtonTouchCancel:)
           forControlEvents:UIControlEventTouchUpOutside];
    
    [viewDisplayName addSubview:buttonPushUp];
    
    self.labelDisplayName = [[UILabel alloc] initWithFrame:CGRectMake(10, 33, 300, 30)];
    [self.labelDisplayName setBackgroundColor:[UIColor clearColor]];
    [self.labelDisplayName setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:30]];
    [self.labelDisplayName setText:contactObject.displayName];
    [self.labelDisplayName setTextColor:[UIColor whiteColor]];
    [self.labelDisplayName setTextAlignment:NSTextAlignmentCenter];
    [viewDisplayName addSubview:self.labelDisplayName];
    
    labelCallingState = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 150, 24)];
    labelCallingState.center = CGPointMake(160,labelCallingState.center.y );
    labelCallingState.textAlignment = NSTextAlignmentCenter;
    [labelCallingState setBackgroundColor:[UIColor clearColor]];
    [labelCallingState setTextColor:[UIColor whiteColor]];
    [labelCallingState setFont:[UIFont boldSystemFontOfSize:20.0]];
    [labelCallingState setText:@"Calling"];
    [labelCallingState setHidden:YES];
    [viewDisplayName addSubview:labelCallingState];
    
    self.labelTime = [[UILabel alloc] initWithFrame:CGRectMake(10, 80, 300, 14)];
    [self.labelTime setBackgroundColor:[UIColor clearColor]];
    [self.labelTime setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
    [self.labelTime setText:@""];
    [self.labelTime setTextColor:[UIColor whiteColor]];
    [self.labelTime setTextAlignment:NSTextAlignmentCenter];
    [viewDisplayName addSubview:self.labelTime];
    
    labelReconnectingAudio = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 300, 50)];
    [labelReconnectingAudio setBackgroundColor:[UIColor clearColor]];
    [labelReconnectingAudio setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
    labelReconnectingAudio.minimumScaleFactor = 0.5;
    labelReconnectingAudio.adjustsFontSizeToFitWidth = YES;
    [labelReconnectingAudio setText:@"Reconnecting..."];
    [labelReconnectingAudio setTextColor:[UIColor redColor]];
    [labelReconnectingAudio setTextAlignment:NSTextAlignmentCenter];
    [labelReconnectingAudio setNumberOfLines:0];
    labelReconnectingAudio.hidden = YES;
    [viewDisplayName addSubview:labelReconnectingAudio];
    
    self.viewAudioCallMenu = [[UIView alloc] initWithFrame:CGRectMake(21, 133, 278, 213)];
    [self.viewAudioCallMenu setBackgroundColor:[UIColor clearColor]];
    [self.imageViewRemoteVideo addSubview:self.viewAudioCallMenu];
    
    // Button Mute
    buttonAudioMute = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 93, 107)];
    [buttonAudioMute setBackgroundImage:[UIImage imageNamed:@"menuMuteUp.png"] forState:UIControlStateNormal];
    [buttonAudioMute setBackgroundImage:[UIImage imageNamed:@"menuMuteDown.png"] forState:UIControlStateHighlighted];
    
    [buttonAudioMute addTarget:self
                        action:@selector(onButtonMute:)
              forControlEvents:UIControlEventTouchUpInside];
    
    [buttonAudioMute addTarget:self
                        action:@selector(onButtonTouchDown:)
              forControlEvents:UIControlEventTouchDown];
    
    [buttonAudioMute addTarget:self
                        action:@selector(onButtonTouchCancel:)
              forControlEvents:UIControlEventTouchUpOutside];
    
    [self.viewAudioCallMenu addSubview:buttonAudioMute];
    
    
    // Button Video
    buttonAudioVideo = [[UIButton alloc] initWithFrame:CGRectMake(93, 0, 93, 107)];
    [buttonAudioVideo setBackgroundImage:[UIImage imageNamed:@"menuVideoUp.png"] forState:UIControlStateNormal];
    [buttonAudioVideo setBackgroundImage:[UIImage imageNamed:@"menuVideoDown.png"] forState:UIControlStateSelected];
    
    [buttonAudioVideo addTarget:self
                         action:@selector(onButtonVideoOff:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [buttonAudioVideo addTarget:self
                         action:@selector(onButtonTouchDown:)
               forControlEvents:UIControlEventTouchDown];
    
    [buttonAudioVideo addTarget:self
                         action:@selector(onButtonTouchCancel:)
               forControlEvents:UIControlEventTouchUpOutside];
    
    [self.viewAudioCallMenu addSubview:buttonAudioVideo];
    
    
    // Button Speaker
    buttonAudioSpeaker = [[UIButton alloc] initWithFrame:CGRectMake(186, 0, 93, 107)];
    [buttonAudioSpeaker setBackgroundImage:[UIImage imageNamed:@"menuSpeakerUp.png"] forState:UIControlStateNormal];
    
    [buttonAudioSpeaker addTarget:self
                           action:@selector(onButtonSpeaker:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [buttonAudioSpeaker addTarget:self
                           action:@selector(onButtonTouchDown:)
                 forControlEvents:UIControlEventTouchDown];
    
    [buttonAudioSpeaker addTarget:self
                           action:@selector(onButtonTouchCancel:)
                 forControlEvents:UIControlEventTouchUpOutside];
    
    [self.viewAudioCallMenu addSubview:buttonAudioSpeaker];
    
    
    // Button Message
    buttonAudioMessage = [[UIButton alloc] initWithFrame:CGRectMake(0, 107, 93, 107)];
    [buttonAudioMessage setBackgroundImage:[UIImage imageNamed:@"menuMessageUp.png"] forState:UIControlStateNormal];
    [buttonAudioMessage setBackgroundImage:[UIImage imageNamed:@"menuMessageDown.png"] forState:UIControlStateHighlighted];
    
    [buttonAudioMessage addTarget:self
                           action:@selector(onButtonAudioMessage:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [buttonAudioMessage addTarget:self
                           action:@selector(onButtonTouchDown:)
                 forControlEvents:UIControlEventTouchDown];
    
    [buttonAudioMessage addTarget:self
                           action:@selector(onButtonTouchCancel:)
                 forControlEvents:UIControlEventTouchUpOutside];
    
    [self.viewAudioCallMenu addSubview:buttonAudioMessage];
    
    self.messageBadgView = [[TBIDefaultBadgView alloc] init];
    self.messageBadgView.frame = CGRectMake(60, 10, self.messageBadgView.frame.size.width, self.messageBadgView.frame.size.height);
    [self.messageBadgView SetText:nil];
    [buttonAudioMessage addSubview:self.messageBadgView];
    // Button Buddy
    buttonAudioBuddy = [[UIButton alloc] initWithFrame:CGRectMake(93, 107, 93, 107)];
    [buttonAudioBuddy setBackgroundImage:[UIImage imageNamed:@"menuBuddyUp.png"] forState:UIControlStateNormal];
    [buttonAudioBuddy setBackgroundImage:[UIImage imageNamed:@"menuBuddyDown.png"] forState:UIControlStateHighlighted];
    
    [buttonAudioBuddy addTarget:self
                         action:@selector(onButtonBuddy:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [buttonAudioBuddy addTarget:self
                         action:@selector(onButtonTouchDown:)
               forControlEvents:UIControlEventTouchDown];
    
    [buttonAudioBuddy addTarget:self
                         action:@selector(onButtonTouchCancel:)
               forControlEvents:UIControlEventTouchUpOutside];
    
    [self.viewAudioCallMenu addSubview:buttonAudioBuddy];
    
    // Button Profile
    buttonAudioProfile = [[UIButton alloc] initWithFrame:CGRectMake(186, 107, 93, 107)];
    [buttonAudioProfile setBackgroundImage:[UIImage imageNamed:@"menuProfileUp.png"] forState:UIControlStateNormal];
    [buttonAudioProfile setBackgroundImage:[UIImage imageNamed:@"menuProfileDown.png"] forState:UIControlStateHighlighted];
    
    [buttonAudioProfile addTarget:self
                           action:@selector(onButtonContactDetail:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [buttonAudioProfile addTarget:self
                           action:@selector(onButtonTouchDown:)
                 forControlEvents:UIControlEventTouchDown];
    
    [buttonAudioProfile addTarget:self
                           action:@selector(onButtonTouchCancel:)
                 forControlEvents:UIControlEventTouchUpOutside];
    
    [self.viewAudioCallMenu addSubview:buttonAudioProfile];
}

- (void) IncrementMessageBadgValue {
    [self.messageBadgView IncrementBagdValue];
    self.messageBadgView.frame = CGRectMake(buttonAudioMessage.frame.size.width - self.messageBadgView.frame.size.width - 7, 10, self.messageBadgView.frame.size.width, self.messageBadgView.frame.size.height);
}

- (void) SetNetworkState:(NetworkState)state {
    switch (state) {
        case NetworkState_NONE: {
            [self.imageViewNetworkStatus setImage:nil];
        }
            break;
        case NetworkQualityState_1:
        case NetworkQualityState_2:
        case NetworkQualityState_3:
        case NetworkQualityState_4:
        case NetworkQualityState_5: {
            NSString *imageName = [NSString stringWithFormat:@"NetworkQualityIndicator_%d.png", (int)state ];;
            [self.imageViewNetworkStatus setImage:[UIImage imageNamed:imageName]];
        }
            break;
        default:
            break;
    }
}

- (void) onButtonContactDetail:(id)sender {
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        if ([_delegate respondsToSelector:@selector(didClickOnContactDetail)]) {
            [_delegate didClickOnContactDetail];
        }
        
        [self StopTimerHideMenu];
        [self setVideoState:VideoViewState_HIDE Animation:NO];
        [self didEndHideVideoViewAnimation];
    }
}

- (void) didEndHideVideoViewAnimation {
    [self setVideoState:VideoViewState_HIDE Animation:YES];
    [Common postNotificationWithName:kSelectContactNotification object:contactObject];
}

- (void) onButtonEndCall:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOnEndCall)]) {
        [_delegate didClickOnEndCall];
    }
    
    timerHideMenu = [self CreateTimerHideMenu];
    [Common postNotificationWithName:kVideoViewOrientationChangeNotification object:[NSNumber numberWithInt:videoViewState]];
}

- (void) onButtonVideoOff:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(didClickOnVideoOff)]) {
        self.videoSend = [_delegate didClickOnVideoOff];
    }
    if (videoViewState != VideoViewState_Calling){
        timerHideMenu = [self CreateTimerHideMenu];
    }
    [buttonAudioVideo setSelected:self.videoSend];
    
    
}

- (void) onButtonPushUp:(id)sender {
    [self setVideoState:VideoViewState_TAB_MENU Animation:YES];
    
    timerHideMenu = [self CreateTimerHideMenu];
}

- (void) onButtonMute:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOnMute)]) {
        [_delegate didClickOnMute];
    }
    
    timerHideMenu = [self CreateTimerHideMenu];
}

- (void) onButtonSpeaker:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOnSpeaker)]) {
        [_delegate didClickOnSpeaker];
    }
    
    timerHideMenu = [self CreateTimerHideMenu];
}

- (void) onButtonChangeCamera:(id)sender {
    [self callBackTimerHideChangeCameraButton];
    [buttonChangeCamera removeFromSuperview];
    
    if ([_delegate respondsToSelector:@selector(didClickOnChangeCamera)]) {
        [_delegate didClickOnChangeCamera];
    }
    
    timerHideMenu = [self CreateTimerHideMenu];
}

- (void) onButtonAudioMessage:(id)sender {
    [self.messageBadgView SetText:nil];
    
    [self setVideoState:VideoViewState_TAB Animation:YES];
    [idoubs2AppDelegate RefreshTab];
    
    [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 1;
    UINavigationController *nav = [[idoubs2AppDelegate sharedInstance].tabBarController.viewControllers objectAtIndex:1];
    [nav popToRootViewControllerAnimated:NO];
}

- (void) onButtonBuddy:(id)sender {
    UINavigationController *nav = [[idoubs2AppDelegate sharedInstance].tabBarController.viewControllers objectAtIndex:2];
    SeequBrowserViewController *browser = [nav.viewControllers objectAtIndex:0];
    [browser onButtonAction:nil];
    
    if (browser.isInSession) {
        [buttonAudioBuddy setBackgroundImage:[UIImage imageNamed:@"menuBuddyDown.png"] forState:UIControlStateNormal];
        [buttonAudioBuddy setBackgroundImage:[UIImage imageNamed:@"menuBuddyUp.png"] forState:UIControlStateHighlighted];
        
        [self setVideoState:VideoViewState_TAB Animation:YES];
        [idoubs2AppDelegate RefreshTab];
        [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 2;
    } else {
        [buttonAudioBuddy setBackgroundImage:[UIImage imageNamed:@"menuBuddyUp.png"] forState:UIControlStateNormal];
        [buttonAudioBuddy setBackgroundImage:[UIImage imageNamed:@"menuBuddyDown.png"] forState:UIControlStateHighlighted];
    }
}

- (void) onBrowser_Session:(NSNotification*)notification {
    BOOL connect = [[notification object] boolValue];
    NSLog(@"1[BROWSER][Buddy][RCV] %s", connect ? "Enable" : "Disable");
    NSLog(@"2[BROWSER][Buddy][RCV] Notification - %@",notification);
    
    if (connect) {
        [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex=2;
        [self setVideoState:VideoViewState_TAB_MENU Animation:YES];
        [buttonAudioBuddy setBackgroundImage:[UIImage imageNamed:@"menuBuddyDown.png"] forState:UIControlStateNormal];
        [buttonAudioBuddy setBackgroundImage:[UIImage imageNamed:@"menuBuddyUp.png"] forState:UIControlStateHighlighted];
        [_buddyButton setSelected:YES];
        //            [_buddyButton setBackgroundImage:[UIImage imageNamed:@"seequButtonWebActionConnectedForVideoView.png"] forState:UIControlStateNormal];
    } else {
        [buttonAudioBuddy setBackgroundImage:[UIImage imageNamed:@"menuBuddyUp.png"] forState:UIControlStateNormal];
        [buttonAudioBuddy setBackgroundImage:[UIImage imageNamed:@"menuBuddyDown.png"] forState:UIControlStateHighlighted];
        [_buddyButton setSelected:NO];
        //            [_buddyButton setBackgroundImage:[UIImage imageNamed:@"SeequButtonWebActionForVideoView.png"] forState:UIControlStateNormal];
    }
}

- (void) onButtonTouchDown:(id)sender {
    [self StopTimerHideMenu];
}

- (void) onButtonTouchCancel:(id)sender {
    timerHideMenu = [self CreateTimerHideMenu];
}

- (void) SetVideoOffState:(BOOL)video {
    if (video) {
        [buttonVideoOff setBackgroundImage:[UIImage imageNamed:@"seequVideoOffSel.png"] forState:UIControlStateNormal];
        [buttonVideoOff setBackgroundImage:[UIImage imageNamed:@"seequVideoOff.png"] forState:UIControlStateHighlighted];
    } else {
        [buttonVideoOff setBackgroundImage:[UIImage imageNamed:@"seequVideoOff.png"] forState:UIControlStateNormal];
        [buttonVideoOff setBackgroundImage:[UIImage imageNamed:@"seequVideoOffSel.png"] forState:UIControlStateHighlighted];
    }
}

- (void) SetMuteState:(BOOL)mute {
    if (mute) {
        [buttonMute setBackgroundImage:[UIImage imageNamed:@"seequVideoMuteSel.png"] forState:UIControlStateNormal];
        [buttonMute setBackgroundImage:[UIImage imageNamed:@"seequVideoMute.png"] forState:UIControlStateHighlighted];
        
        [buttonAudioMute setBackgroundImage:[UIImage imageNamed:@"menuMuteDown.png"] forState:UIControlStateNormal];
        [buttonAudioMute setBackgroundImage:[UIImage imageNamed:@"menuMuteUp.png"] forState:UIControlStateHighlighted];
    } else {
        [buttonMute setBackgroundImage:[UIImage imageNamed:@"seequVideoMute.png"] forState:UIControlStateNormal];
        [buttonMute setBackgroundImage:[UIImage imageNamed:@"seequVideoMuteSel.png"] forState:UIControlStateHighlighted];
        
        [buttonAudioMute setBackgroundImage:[UIImage imageNamed:@"menuMuteUp.png"] forState:UIControlStateNormal];
        [buttonAudioMute setBackgroundImage:[UIImage imageNamed:@"menuMuteDown.png"] forState:UIControlStateHighlighted];
    }
}

- (void) SetSpeakerState:(int)voiceState OnHold:(BOOL)onHold ShowWindowIcon:(BOOL)show {
    switch (voiceState) {
        case OutputVoiceState_Headset: {
            if (onHold) {
                [buttonSpeaker setBackgroundImage:[UIImage imageNamed:@"seequVideoHeadset.png"] forState:UIControlStateNormal];
                [buttonAudioSpeaker setBackgroundImage:[UIImage imageNamed:@"menuHeadsetUp.png"] forState:UIControlStateNormal];
            } else {
                [buttonSpeaker setBackgroundImage:[UIImage imageNamed:@"seequVideoHeadsetSel.png"] forState:UIControlStateNormal];
                [buttonAudioSpeaker setBackgroundImage:[UIImage imageNamed:@"menuHeadsetDown.png"] forState:UIControlStateNormal];
            }
        }
            break;
        case OutputVoiceState_Speaker: {
            if (onHold) {
                [buttonSpeaker setBackgroundImage:[UIImage imageNamed:@"seequVideoSpeaker.png"] forState:UIControlStateNormal];
                [buttonAudioSpeaker setBackgroundImage:[UIImage imageNamed:@"menuSpeakerUp.png"] forState:UIControlStateNormal];
            } else {
                [buttonSpeaker setBackgroundImage:[UIImage imageNamed:@"seequVideoSpeakerSel.png"] forState:UIControlStateNormal];
                [buttonAudioSpeaker setBackgroundImage:[UIImage imageNamed:@"menuSpeakerDown.png"] forState:UIControlStateNormal];
            }
        }
            break;
        case OutputVoiceState_Bluetooth: {
            if (onHold) {
                [buttonSpeaker setBackgroundImage:[UIImage imageNamed:@"seequVideoBluetooth.png"] forState:UIControlStateNormal];
                [buttonAudioSpeaker setBackgroundImage:[UIImage imageNamed:@"menuBluetoothUp.png"] forState:UIControlStateNormal];
            } else {
                [buttonSpeaker setBackgroundImage:[UIImage imageNamed:@"seequVideoBluetoothSel.png"] forState:UIControlStateNormal];
                [buttonAudioSpeaker setBackgroundImage:[UIImage imageNamed:@"menuBluetoothDown.png"] forState:UIControlStateNormal];
            }
        }
            break;
            
        default:
            break;
    }
    
    if (show) {
        [self ShowOutputVoiceIcone:voiceState];
    }
}

- (void) ShowOutputVoiceIcone:(int)state {
    [NSObject cancelPreviousPerformRequestsWithTarget:viewOutputVoice];
    UIImage *image;
    
    switch (state) {
        case OutputVoiceState_Headset: {
            image = [UIImage imageNamed:@"seequAudioOutputHeadset.png"];
            [labelOutputVoice setText:@"Headset"];
        }
            break;
        case OutputVoiceState_Speaker: {
            image = [UIImage imageNamed:@"seequAudioOutputSpeaker.png"];
            [labelOutputVoice setText:@"Speaker"];
        }
            break;
        case OutputVoiceState_Bluetooth: {
            image = [UIImage imageNamed:@"seequAudioOutputBluetooth.png"];
            [labelOutputVoice setText:@"Bluetooth"];
        }
            break;
        default:
            break;
    }
    
    [imageViewOutputVoice setImage:image];
    [[idoubs2AppDelegate sharedInstance].window addSubview:viewOutputVoice];
    [viewOutputVoice performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:3.0];
}

- (NSTimer*) CreateTimerHideMenu {
    [self StopTimerHideMenu];
    
    return [NSTimer scheduledTimerWithTimeInterval:3.0
                                            target:self
                                          selector:@selector(callBackTimerHideMenu)
                                          userInfo:nil
                                           repeats:NO];
}

- (void) StopTimerHideMenu {
    if (timerHideMenu && [timerHideMenu isKindOfClass:[NSTimer class]]) {
        [timerHideMenu invalidate];
        timerHideMenu = nil;
    }
}

- (CGPoint) CalculateVelocityBetweenPoints:(CGPoint)point1 Point:(CGPoint)point2 {
    return CGPointMake((point1.x - point2.x)/10, (point1.y - point2.y)/10);
}

- (void) didRotateInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if ((self.videoViewState == VideoViewState_TAB || self.videoViewState == VideoViewState_TAB_MENU) &&
        [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex != 1 &&
        [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex != 2 &&
        UIInterfaceOrientationIsLandscape(orientation)) {
        return;
    }
    
    self.interfaceOrientation = orientation;
    
    labelReconnecting.transform = CGAffineTransformMakeRotation(0);
    viewMenu.transform = CGAffineTransformMakeRotation(0);
    viewMenu.frame = CGRectMake(0, 480, 320, 92);
    buttonChangeCamera.transform = CGAffineTransformMakeRotation(0);
    [self setViewMenuInterfaceOrientation:self.interfaceOrientation];
    
    int labelReconnectHeight = 220;
    
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationPortrait: {
            self.frame = State_NORMAL_Rect;
            [self setRemoteVideoFrame:CGRectMake(0, 0, 320, 480) Animation:NO];
            [self ChangeLocalVideoFrame:Local_Video_Small_Rect HaveBorder:!splited Animation:YES];
            
            viewMenu.transform = CGAffineTransformMakeRotation(0);
            viewMenu.frame = CGRectMake(0, 0, 320, 92);
            viewOutputVoice.transform = CGAffineTransformMakeRotation(0);
            viewReconnect.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 87);
            labelReconnecting.center = CGPointMake(viewReconnect.frame.size.width/2, viewReconnect.frame.size.height/2);
            
            self.viewDisplayName.frame = CGRectMake(0, 0, 320, 110);
            self.labelDisplayName.frame = CGRectMake(10, 33, 300, 30);
            self.labelTime.frame = CGRectMake(10, 80, 300, 14);
            labelReconnectingAudio.frame = CGRectMake(10, 60, 300, 50);
        }
            break;
        case UIInterfaceOrientationLandscapeLeft: {
            self.frame = State_NORMAL_Landscape_Left_Rect;
            CGRect frame = self.imageViewRemoteVideo.frame;
            frame.origin.x = 0;
            [self setRemoteVideoFrame:frame Animation:NO];
            [self ChangeLocalVideoFrame:CGRectMake(10, 10, 100, 67) HaveBorder:!splited Animation:YES];
            
            viewMenu.transform = CGAffineTransformMakeRotation(-M_PI_2);
            viewMenu.center = CGPointMake(345, 240);
            viewOutputVoice.transform = CGAffineTransformMakeRotation(-M_PI_2);
            viewReconnect.frame = CGRectMake(0, 0, 270, [[UIScreen mainScreen] bounds].size.height);
            labelReconnecting.center = CGPointMake(viewReconnect.frame.size.width/2, viewReconnect.frame.size.height/2);
            labelReconnecting.transform = CGAffineTransformMakeRotation(-M_PI_2);
            
            if ([[UIScreen mainScreen] bounds].size.height == 568) {
                self.viewDisplayName.frame = CGRectMake(-44, 0, [[UIScreen mainScreen] bounds].size.height, 50);
            } else {
                self.viewDisplayName.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, 50);
            }
            
            self.labelDisplayName.frame = CGRectMake(5, 10, [[UIScreen mainScreen] bounds].size.height - 200, 30);
            self.labelTime.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height - labelReconnectHeight, 10, labelReconnectHeight, 30);
            labelReconnectingAudio.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height - labelReconnectHeight, 0, labelReconnectHeight, 50);
        }
            break;
        case UIInterfaceOrientationLandscapeRight: {
            self.frame = State_NORMAL_Landscape_Right_Rect;
            CGRect frame = self.imageViewRemoteVideo.frame;
            frame.origin.x = self.frame.size.width - 320;
            [self setRemoteVideoFrame:frame Animation:NO];
            [self ChangeLocalVideoFrame:CGRectMake(self.frame.size.width - 111, [[UIScreen mainScreen] bounds].size.height - 78, 100, 67) HaveBorder:!splited Animation:YES];
            
            viewMenu.transform = CGAffineTransformMakeRotation(M_PI_2);
            viewMenu.center = CGPointMake(self.frame.size.width - 345, 240);
            viewOutputVoice.transform = CGAffineTransformMakeRotation(M_PI_2);
            viewReconnect.frame = CGRectMake(50, 0, 270, [[UIScreen mainScreen] bounds].size.height);
            labelReconnecting.center = CGPointMake(viewReconnect.frame.size.width/2, viewReconnect.frame.size.height/2);
            labelReconnecting.transform = CGAffineTransformMakeRotation(M_PI_2);
            
            if ([[UIScreen mainScreen] bounds].size.height == 568) {
                self.viewDisplayName.frame = CGRectMake(-44, 0, [[UIScreen mainScreen] bounds].size.height, 50);
            } else {
                self.viewDisplayName.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, 50);
            }
            
            self.labelDisplayName.frame = CGRectMake(5, 10, [[UIScreen mainScreen] bounds].size.height - 200, 30);
            self.labelTime.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height - labelReconnectHeight, 10, labelReconnectHeight, 30);
            labelReconnectingAudio.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height - labelReconnectHeight, 0, labelReconnectHeight, 50);
        }
            break;
            
        default:
            break;
    }
    
    viewAlphaDisplayName.frame = CGRectMake(0, 0, self.viewDisplayName.frame.size.width, self.viewDisplayName.frame.size.height);
    self.viewLocalVideo.transform = CGAffineTransformMakeRotation(0);
    self.imageViewRemoteVideo.transform = CGAffineTransformMakeRotation(0);
    
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationLandscapeRight: {
            //self.viewLocalVideo.transform = CGAffineTransformMakeRotation(M_PI_2);
            
            self.imageViewRemoteVideo.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
            break;
        case UIInterfaceOrientationLandscapeLeft: {
            //self.viewLocalVideo.transform = CGAffineTransformMakeRotation(-M_PI_2);
            self.imageViewRemoteVideo.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        default:
            break;
    }
    
    [self setVideoState:videoViewState Animation:(videoViewState != VideoViewState_HIDE && videoViewState != VideoViewState_NORMAL) ? YES : NO];
    [self calculateAudioCallEndButtonCenter];
    [self ShowRemotProfileImage:!imageViewProfile.hidden];
    CGFloat fontSize = [self getAppropriateFontSize:labelReconnectingAudio.text];
    [labelReconnectingAudio setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize]];
}

- (void) setViewMenuInterfaceOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait: {
            viewMenu.frame = CGRectMake(0, 0, 320, 60);
            buttonCallEnd.center = CGPointMake(64, 66);
            buttonVideoOff.center = CGPointMake(160, 66);
            buttonMute.center = CGPointMake(224, 66);
            buttonSpeaker.center = CGPointMake(288, 66);
            buttonCallerName.frame = CGRectMake(0, 0, 320, 42);
            [buttonCallerName setBackgroundImage:[UIImage imageNamed:@"seequCallerNameBg.png"] forState:UIControlStateNormal];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            viewMenu.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, 50);
            buttonCallEnd.center = CGPointMake(64, 25);
            buttonVideoOff.center = CGPointMake(160, 25);
            buttonMute.center = CGPointMake(224, 25);
            buttonSpeaker.center = CGPointMake(288, 25);
            buttonCallerName.frame = CGRectMake(320, 0, [[UIScreen mainScreen] bounds].size.height - 320, 50);
            [buttonCallerName setBackgroundImage:[UIImage imageNamed:@"seequCallerNameLandscapeBg.png"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    
    viewAlpha.frame = viewMenu.frame;
    viewAudioEndCall.frame = viewMenu.frame;
}

- (void) LocalVideoStateChanged:(BOOL)isLandscape {
    if (![self isVideoState] || self.videoViewState == VideoViewState_TAB || self.videoViewState == VideoViewState_TAB_MENU) {
        return;
    }
    
    if(!self.splited){
        if (isLandscape) {
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                self.viewLocalVideo.frame = CGRectMake(self.viewLocalVideo.frame.origin.x, self.viewLocalVideo.frame.origin.y, 67, 100);
                if (self.videoViewState==VideoViewState_NORMAL_MENU) {
                    self.viewLocalVideo.frame=CGRectMake(self.viewLocalVideo.frame.origin.x+self.viewMenu.frame.size.width, self.viewLocalVideo.frame.origin.y, self.viewLocalVideo.frame.size.width, self.viewLocalVideo.frame.size.height);
                }
            } else {
                
                self.viewLocalVideo.frame = CGRectMake(242 - 15, self.viewLocalVideo.frame.origin.y, 82, 100);
            }
        } else {
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                    self.viewLocalVideo.frame = CGRectMake(self.viewLocalVideo.frame.origin.x, self.viewLocalVideo.frame.origin.y, 82, 100);
                } else {
                    self.viewLocalVideo.frame = CGRectMake(self.viewLocalVideo.frame.origin.x - 15, self.viewLocalVideo.frame.origin.y, 82, 100);
                }
            } else {
                self.viewLocalVideo.frame = CGRectMake(242, self.viewLocalVideo.frame.origin.y, 67, 100);
            }
        }
    }
}

- (void) calculateAudioCallEndButtonCenter {
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && self.interfaceOrientation!=UIInterfaceOrientationPortraitUpsideDown) {
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            self.viewAudioCallMenu.frame = CGRectMake(21, 170, 278, 213);
        } else {
            self.viewAudioCallMenu.frame = CGRectMake(21, 133, 278, 213);
        }
        buttonAudioEndCall.center = CGPointMake(viewMenu.frame.size.width/2, viewMenu.frame.size.height/2);
        buttonPushUp.hidden = NO;
        
    } else {
        self.viewAudioCallMenu.center = CGPointMake(self.imageViewRemoteVideo.frame.size.height/2, self.imageViewRemoteVideo.frame.size.width/2);
        buttonAudioEndCall.center = CGPointMake(viewMenu.frame.size.height/2, viewMenu.frame.size.width/2);
        buttonPushUp.hidden = YES;
        
    }
}

#pragma mark -
#pragma mark UIView Delegate Methods
#pragma mark -

- (void)didMoveToWindow {
    if ([self superview]) {
        [[idoubs2AppDelegate sharedInstance].window addSubview:self.imageViewRemoteVideo];
        [[idoubs2AppDelegate sharedInstance].window addSubview:self.viewLocalVideo];
        //        [[idoubs2AppDelegate sharedInstance].window addSubview:viewWhite];
        [[idoubs2AppDelegate sharedInstance].window addSubview:viewMenu];
        viewDisplayName.hidden = NO;
        viewAudioEndCall.hidden = NO;
        labelReconnectingAudio.hidden = YES;
    } else {
        [self CancelTimerForEndCall];
        [self.imageViewRemoteVideo removeFromSuperview];
        [self.viewLocalVideo removeFromSuperview];
        //        [viewWhite removeFromSuperview];
        [viewMenu removeFromSuperview];
        [Common postNotificationWithName:kVideoViewChangeNotification object:[NSNumber numberWithInt:VideoViewState_HIDE]];
        [viewOutputVoice removeFromSuperview];
        [viewReconnect removeFromSuperview];
        self.labelTime.hidden = NO;
        labelReconnectingAudio.hidden = YES;
        viewDisplayName.hidden = YES;
        viewAudioEndCall.hidden = YES;
        
        if ([UIDevice currentDevice].isProximityMonitoringEnabled) {
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}
- (void) setCallingStateText:(NSString*)text {
    [UIView beginAnimations:@"animateViewCenter" context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                           forView:labelCallingState
                             cache:YES];
    
    labelCallingState.text = text;
    
    [UIView commitAnimations];
}
-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BROWSER_SESSION object:nil];
}

- (void) dealloc {
}

@end
