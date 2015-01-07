//
//  ShowVideoView.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 11/8/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"
#import "OpenGlView.h"
#import "TBIDefaultBadgView.h"
#import "Common.h"

#define kVideoViewChangeNotification @"kVideoViewChangeNotification"
#define kVideoViewOrientationChangeNotification @"kVideoViewOrientationChangeNotification"
#define kSelectContactNotification @"kSelectContactNotification"
#define kCallStateChange @"kCallStateChange"
#define SMALL_VIDEO_WIDTH 117
#define SMALL_VIDEO_HEIGHT 82


@protocol ShowVideoViewDelegate;

typedef enum VideoViewState {
    VideoViewState_NONE,
    VideoViewState_NORMAL,
    VideoViewState_NORMAL_MENU,
    VideoViewState_TAB_MENU,
    VideoViewState_TAB,
    VideoViewState_HIDE,
    VideoViewState_PREVIEW,
    VideoViewState_Calling
    
}
VideoViewState;

typedef enum NetworkState {
    NetworkState_NONE,
    NetworkQualityState_1,
    NetworkQualityState_2,
    NetworkQualityState_3,
    NetworkQualityState_4,
    NetworkQualityState_5
}
NetworkState;

@interface ShowVideoView : UIView {
//    id<ShowVideoViewDelegate> __weak _delegate;
    
    ContactObject *contactObject;
    UIImageView *imageViewProfile;
    
    UIView *viewReconnect;
    UILabel *labelReconnecting;
    UILabel *labelReconnectingAudio;
    BOOL isReconnecting;
    
    float position_y;
    float position_x;
    
    UIView *viewMenu;
    UIView *viewAlpha;
    UIView *viewAudioCallMenu;
    UIView *viewAudioEndCall;
    UIView *viewDisplayName;
    UIView *viewAlphaDisplayName;
    UILabel *labelDisplayName;
    UILabel *labelTime;
    UILabel *labelCallingState;
    
    VideoViewState videoViewState;
    NSTimer *timerHideMenu;
    NSTimer *timerHideChangeCameraButton;
    
    UIButton *buttonCallerName;
    UIButton *buttonChangeCamera;
    UIButton *buttonCallEnd;
    UIButton *buttonVideoOff;
    UIButton *buttonMute;
    UIButton *buttonSpeaker;
    
    UIButton *buttonPushUp;
    UIButton *buttonAudioMute;
    UIButton *buttonAudioVideo;
    UIButton *buttonAudioSpeaker;
    UIButton *buttonAudioMessage;
    UIButton *buttonAudioBuddy;
    UIButton *buttonAudioProfile;
    
    UIButton *buttonAudioEndCall;
    
    
    UIView *viewWhite;
    
    BOOL splited;
    BOOL videoRecive;
    BOOL videoSend;
    BOOL endCallTimerStarted;
    
    UIInterfaceOrientation interfaceOrientation;
    
    UIView *viewOutputVoice;
    UIImageView *imageViewOutputVoice;
    UILabel *labelOutputVoice;
}


@property (nonatomic, assign) id<ShowVideoViewDelegate> delegate;
@property (nonatomic, assign, setter = setVideoState:) VideoViewState videoViewState;
@property (nonatomic, strong) UIView* imageViewRemoteVideo;
@property (nonatomic, strong) OpenGlView* openGlView;
@property (nonatomic, strong) UIView* viewLocalVideo;
@property (nonatomic, strong) UIView *viewAudioCallMenu;
@property (nonatomic, strong) UIView *viewMenu;
@property (nonatomic, strong) UIView *viewAudioEndCall;
@property (nonatomic, strong) UIView *viewDisplayName;
@property (nonatomic, strong) UILabel *labelDisplayName;
@property (nonatomic, strong) UILabel *labelTime;
@property (nonatomic, strong) UIButton *buddyButton;
@property (nonatomic, strong) UIImageView *imageViewNetworkStatus;
@property (nonatomic, strong) TBIDefaultBadgView *messageBadgView;

@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, assign) BOOL splited;
@property (nonatomic, assign) BOOL videoRecive;
@property (nonatomic, assign) BOOL videoSend;


- (id)initWithContactObject:(ContactObject*)contact;
- (void) VideoTabMenu;
- (void) AudioCallMenu;
- (void) setVideoState:(VideoViewState)state Animation:(BOOL)animation;
- (void) handlePanRemoteVideo:(UIPanGestureRecognizer *)recognizer;
- (void) handlePanLocalVideo:(UIPanGestureRecognizer *)recognizer;
- (void) handlePan:(UIPanGestureRecognizer *)recognizer;
- (void) RecognizerStateEnded;
- (void) onButtonContactDetail:(id)sender;
- (void) onButtonEndCall:(id)sender;
- (void) onButtonVideoOff:(id)sender;
- (void) onButtonPushUp:(id)sender;
- (void) onButtonMute:(id)sender;
- (void) onButtonSpeaker:(id)sender;
- (void) onButtonChangeCamera:(id)sender;
- (void) onButtonAudioMessage:(id)sender;
- (void) onButtonBuddy:(id)sender;
- (void) onBrowser_Session:(NSNotification*)notification;
- (void) removeNotification;
- (void) onButtonTouchDown:(id)sender;
- (void) onButtonTouchCancel:(id)sender;
- (void) setViewMenuInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (void) callBackTimerHideMenu;
- (void) callBackTimerHideChangeCameraButton;
- (void) setFrame:(CGRect)frame Animation:(BOOL)animation;
- (void) setViewMenuFrame:(CGRect)frame Animation:(BOOL)animation;
- (void) setRemoteVideoFrame:(CGRect)frame Animation:(BOOL)animation;
- (void) ChangeLocalVideoFrame:(CGRect)frame HaveBorder:(BOOL)border Animation:(BOOL)animation;
- (void) OneTapOnLocalVideo:(UIPinchGestureRecognizer*)sender;
- (void) SetVideoOffState:(BOOL)video;
- (void) SetMuteState:(BOOL)mute;
- (void) SetSpeakerState:(int)voiceState OnHold:(BOOL)onHold ShowWindowIcon:(BOOL)show;
- (void) ShowOutputVoiceIcone:(int)state;
- (void) didEndHideVideoViewAnimation;
- (CGPoint) CalculateVelocityBetweenPoints:(CGPoint)point1 Point:(CGPoint)point2;
- (NSTimer*) CreateTimerHideMenu;
- (void) StopTimerHideMenu;
- (void) DrawSmallVideo;
- (UIImage*) renderToImage;
- (void) didRotateInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (void) SetDefaultState;
- (BOOL) isVideoState;
- (void) SetNetworkState:(NetworkState)state;
- (void) IncrementMessageBadgValue;
- (void) updateCallerName:(ContactObject*) obj;
- (void) VIDEO_STATE_NORMAL_PORTRAIT:(BOOL)animation;
- (void) VIDEO_STATE_NORMAL_LANDSCAPE_RIGHT:(BOOL)animation;
- (void) VIDEO_STATE_NORMAL_LANDSCAPE_LEFT:(BOOL)animation;

- (void) VIDEO_STATE_NORMAL_MENU_PORTRAIT:(BOOL)animation;
- (void) VIDEO_STATE_NORMAL_MENU_LANDSCAPE_RIGHT:(BOOL)animation;
- (void) VIDEO_STATE_NORMAL_MENU_LANDSCAPE_LEFT:(BOOL)animation;

- (void) VIDEO_STATE_TAB_MENU_PORTRAIT:(BOOL)animation;
- (void) VIDEO_STATE_TAB_MENU_LANDSCAPE_RIGHT:(BOOL)animation;
- (void) VIDEO_STATE_TAB_MENU_LANDSCAPE_LEFT:(BOOL)animation;

- (void) VIDEO_STATE_TAB_PORTRAIT:(BOOL)animation;
- (void) VIDEO_STATE_TAB_LANDSCAPE_RIGHT:(BOOL)animation;
- (void) VIDEO_STATE_TAB_LANDSCAPE_LEFT:(BOOL)animation;

- (void) VIDEO_STATE_HIDE_PORTRAIT:(BOOL)animation;
- (void) VIDEO_STATE_HIDE_LANDSCAPE_RIGHT:(BOOL)animation;
- (void) VIDEO_STATE_HIDE_LANDSCAPE_LEFT:(BOOL)animation;

- (void) ShowHideAllViews:(BOOL)show;
- (void) ShowRemotProfileImage:(BOOL)show;
- (void) SetRemotProfileImage:(UIImage*)image;
- (void) SetDisplayName;
- (void) SetTime:(int)time;
- (void) ShowReconnectView:(BOOL)show Message:(NSString*)message;
- (void) ShowReconnectViewWithMessage:(NSString*)message;
- (void) StartTimerForEndCall;
- (void) StartTimerReconnectForEndCall;
- (void) CancelTimerForEndCall;
- (void) setProfileImage:(UIImage*)image;
- (void) LocalVideoStateChanged:(BOOL)isLandscape;
- (void) changeNetworkStatusImageViewFrame;
- (void) calculateAudioCallEndButtonCenter;

- (void) setCallingStateText:(NSString*)text;

@end


@protocol ShowVideoViewDelegate <NSObject>

@optional

- (void) onButtonEndCall:(id)sender;
- (void) didClickOnContactDetail;
- (void) didClickOnEndCall;
- (BOOL) didClickOnVideoOff;
- (void) didClickOnMute;
- (void) didClickOnSpeaker;
- (void) didClickOnChangeCamera;
- (void) didChangeLocalVideoFrame;
- (void) didChangeRemoteVideoStateTo:(VideoViewState)state Split:(BOOL)splited Orientation:(BOOL)isLandscape frame:(CGRect)frame;

@end