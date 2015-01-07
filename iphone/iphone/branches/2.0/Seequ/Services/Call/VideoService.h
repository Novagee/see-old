//
//  VideoService.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 11/8/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OutgoingCallingView.h"
#import "IncomingCallingView.h"
#import "IncomingRequestView.h"
#import "ShowVideoView.h"
#import "rtmpmanager.h"
#import "TBIVideoProducer.h"
#import "TBIVideoConsumer.h"
#import "AudioSessionManager.h"
#include <AudioToolbox/AudioToolbox.h>


typedef enum OutputVoiceState {
    OutputVoiceState_Headset,
    OutputVoiceState_Speaker,
    OutputVoiceState_Bluetooth
}
OutputVoiceState;

@interface VideoService : NSObject <ShowVideoViewDelegate, OutgoingCallViewDelegate, IncomingCallViewDelegate, UIActionSheetDelegate> {
    OutgoingCallingView *outgoingCallView;
    IncomingCallingView *incomingCallView;
    IncomingRequestView *incomingRequestView;
    TBIVideoProducer *videoProducer;
    TBIVideoConsumer *videoConsumer;
    AudioSessionManager *audioSessionManager;

    ShowVideoView *showVideoView;
    enum RTMP_EVENT_TYPE rtmp_call_state;
    OutputVoiceState outputVoiceState;

    NSString *UserAgent;
    NSString *FlashArguments;
    
    NSString *callingSeequID;
    NSTimeInterval lastReciveVideoFrameTime;
    BOOL isMute;
    BOOL isCallIncoming;
    BOOL isFirstInvite;
    BOOL isOnHold;
    int sendingVideoState;
	BOOL sendingVideo;
    BOOL sendingAudio;
    
    UIDeviceOrientation prev_deviceOrientation;
    UIInterfaceOrientation interfaceOrientation;
    NSTimer *timerCheckForNotReciveVideo;
    NSTimer *timerVP8Bitrate;
    
    int oldTime;
    int dateSeconds;
    NSTimeInterval startCallTime;    
}

@property (nonatomic, strong) ShowVideoView *showVideoView;
@property (nonatomic, strong) OutgoingCallingView *outgoingCallView;
@property (nonatomic, strong) IncomingCallingView *incomingCallView;
@property (nonatomic, assign) enum RTMP_EVENT_TYPE rtmp_call_state;
@property (nonatomic, assign, setter = setSendingVideo:) BOOL sendingVideo;
@property (nonatomic, assign) BOOL sendingAudio;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, strong) ContactObject *contactObject;
@property (nonatomic, assign) BOOL isOnHold;
@property (nonatomic, assign) BOOL isRecVideoLandscape;
@property (nonatomic, retain) NSTimer *ringTimer;

- (void) onProximityStateChanged:(NSNotification*)notification;
- (void) setProducerOrentation:(AVCaptureVideoOrientation)orientation;
- (void) onRTMPEvent:(NSDictionary*)params;
- (void) CallWithContactObject:(ContactObject*)contact Video:(BOOL)video;
- (void) ReceiveIncomingCallWithContactObject:(ContactObject*)contact Video:(BOOL)video;
- (BOOL) isInCall;
- (void) onProximityStateChanged:(NSNotification*)notification;
- (void) onProximityStateChangedAfterDelay;
- (void) didRotateInterfaceOrientation:(NSNotification *)notification;
//- (void) SaveCallToServerWithDictionary:(NSDictionary*)dict;
- (void) RemoveIncomingRequestView;
- (void) onReciveVideoCheckTimer:(NSTimer*)timer;
- (void) setSendingVideo:(BOOL)sendingVideo_;
- (void) TimerVP8BitrateChange:(NSTimer*)timer;
- (void) SetDownScale:(BOOL) bDownScale;
@end