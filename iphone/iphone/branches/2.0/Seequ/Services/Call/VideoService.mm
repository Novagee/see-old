//
//  VideoService.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 11/8/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "VideoService.h"
#import "idoubs2AppDelegate.h"
#import "CDMessage.h"
#import "MessageCoreDataManager.h"
#import "RTMPChatManager.h"
#import "ContactStorage.h"


#define CALLING_SCREEN_WAIT_TIME 3.0
#define REMOVE_INCOMING_REQUESTVIEW_TIME 5.0
#define PROXIMITY_STATE_CHANGE_DELAY 3.0
#ifndef MESSAGE_ID
#define MESSAGE_ID [NSString stringWithFormat:@"msgId%.0f", [[NSDate date] timeIntervalSince1970]*1000.0]
#endif
@interface VideoService()

@property (nonatomic,retain) UILocalNotification* currentNotification;
@end
@implementation VideoService

@synthesize showVideoView;
@synthesize outgoingCallView;
@synthesize incomingCallView;
@synthesize rtmp_call_state;
@synthesize sendingVideo;
@synthesize sendingAudio;
@synthesize interfaceOrientation;
@synthesize contactObject;
@synthesize isOnHold;
@synthesize isRecVideoLandscape;
@synthesize ringTimer;

- (id) init {
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReceivCallFromFlash:) name:@"kNgnInviteFromFlash" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivVideoFrame:) name:@"kNgnReceivVideoFrame_Name" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRequestEvent:) name:@"REQUEST" object:nil];
        
        isMute = NO;
        prev_deviceOrientation = UIDeviceOrientationUnknown;
        sendingVideoState = -1;
        outputVoiceState = OutputVoiceState_Headset;
        
        videoProducer = [[TBIVideoProducer alloc] init];
        videoConsumer = [TBIVideoConsumer sharedVideoConsumer];
        audioSessionManager = [AudioSessionManager sharedInstance];
        [audioSessionManager start];
    }
    
    return self;
}

- (void) onRTMPEvent:(NSDictionary*)params {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    NSString *seequID = [params objectForKey:@"number"];
    
    RTMP_EVENT_TYPE event = (RTMP_EVENT_TYPE)[[params objectForKey:@"rtmp_call_event"] integerValue];
    
    if (self.rtmp_call_state == event) {
        return;
    }
    
    self.rtmp_call_state = event;
    
    switch (self.rtmp_call_state) {
        case RTMP_CALL_EVENT_TYPE_INCOMING: {
            
            if (!incomingCallView) {
                [[idoubs2AppDelegate sharedInstance] HideKeyboard];
                [[idoubs2AppDelegate sharedInstance].soundService setSpeakerEnabled:1];
                
                
                if ([[params objectForKey:@"client_type"] intValue] == 0) {
                    FlashArguments = [params objectForKey:@"flash_message"];
                    if (FlashArguments && [FlashArguments isKindOfClass:[NSString class]] && [FlashArguments length]) {
                        NSArray *array = [FlashArguments componentsSeparatedByString:@";"];
                        if ([array count]) {
                            self.contactObject = [[ContactObject alloc] initWithSeequID:seequID];
                            self.contactObject.FirstName = [array objectAtIndex:0];
                        }
                    } else {
                        [idoubs2AppDelegate RTMP_Decline_Call];
                    }
                } else {
                    
                    UINavigationController *nav = [idoubs2AppDelegate sharedInstance].contacts;
                    SeequContactsViewController *contacts = [nav.viewControllers objectAtIndex:0];
                    
                    if ([contacts isKindOfClass:[SeequContactsViewController class]]) {
                        self.contactObject = [contacts CheckObjectInArrayWithPT:seequID];
                        
                        if (!self.contactObject || !self.contactObject.FirstName || !self.contactObject.LastName) {
                            if (!self.contactObject) {
                                self.contactObject = [[ContactStorage sharedInstance] GetContactObjectBySeequId:seequID];
                            }
                            
                        }
                        
                        NSData *imageData;
                        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2) {
                            //Retina display
                            imageData = [Common GetLastCatchedImageWithSeequID:seequID Height:IMAGE_HEIGHT*2];
                        } else {
                            imageData = [Common GetLastCatchedImageWithSeequID:seequID Height:IMAGE_HEIGHT];
                        }
                        
                        if (imageData) {
                            self.contactObject.image = [[UIImage alloc] initWithData:imageData];
                        } else {
                            self.contactObject.image = [Common GetImageByPTID:seequID andHeight:IMAGE_HEIGHT];
                        }
                    }
                }
                
                [self.showVideoView setProfileImage:self.contactObject.image];
                
                NSString *call_state = [params objectForKey:@"CallState"];
                [self ReceivCallState:call_state];
                
//                [audioSessionManager detectAvailableDevices];
                
                if (audioSessionManager.bluetoothDeviceAvailable) {
                    outputVoiceState = OutputVoiceState_Bluetooth;
                } else {
                    outputVoiceState = OutputVoiceState_Speaker;
                }
                
                [[idoubs2AppDelegate sharedInstance].soundService setSpeakerEnabled:outputVoiceState];
                [showVideoView SetSpeakerState:outputVoiceState OnHold:self.isOnHold ShowWindowIcon:NO];
                
                [self ReceiveIncomingCallWithContactObject:self.contactObject Video:self.sendingVideo];
                if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                    [[idoubs2AppDelegate sharedInstance].soundService playRingTone];
                    self.currentNotification = nil;
                } else {
                    UILocalNotification* localNotif = [[UILocalNotification alloc] init];
                    if (localNotif) {
                        localNotif.alertAction = @"Launch";
                        UserInfoCoreData* inf = [[ContactStorage sharedInstance] getUserInfoBySeequId:self.contactObject.SeequID];
                        localNotif.alertBody = [NSString  stringWithFormat:@"%@ %@ is calling you.", inf.firstName, inf.lastName];
                        localNotif.soundName = @"ringtone.mp3";
                        localNotif.applicationIconBadgeNumber = ++[UIApplication sharedApplication].applicationIconBadgeNumber;
                        
                        self.currentNotification = localNotif;
                        
                        
                        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
                        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                        [[idoubs2AppDelegate sharedInstance].soundService startVibrate];
                        NSTimeInterval delay_in_seconds=17;
                        
                        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW,delay_in_seconds * NSEC_PER_SEC);
                        dispatch_after(delay,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if ([[UIApplication sharedApplication] applicationState]==UIApplicationStateBackground && self.rtmp_call_state==RTMP_CALL_EVENT_TYPE_INCOMING) {
                                    [[idoubs2AppDelegate sharedInstance].soundService playRingTone];
                                }
                                
                            });
                        });
                        
                    }
                }
            }
            
            break;
        }
            
        case RTMP_CALL_EVENT_TYPE_LOCATING: {
            if ([self.showVideoView superview]) {
                [[idoubs2AppDelegate sharedInstance].soundService playLocating];
                if (self.showVideoView){
                    [self.showVideoView setCallingStateText:@"Locating"];
                }
            }
        }
            break;
        case RTMP_CALL_EVENT_TYPE_RINGING: {
            [[idoubs2AppDelegate sharedInstance].soundService stopLocating];
            [[idoubs2AppDelegate sharedInstance].soundService playRingBackTone];
            
            if (self.showVideoView){
                [self.showVideoView setCallingStateText:@"Ringing"];
            }
            
        }
            break;
        case RTMP_CALL_EVENT_TYPE_ACCEPTED:
        case RTMP_CALL_EVENT_TYPE_CONNECTED:
        {
            if (![UIDevice currentDevice].isProximityMonitoringEnabled) {
                [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
            }
            
            self.isOnHold = NO;
            self.isRecVideoLandscape = NO;
            self.showVideoView.videoRecive = NO;
            startCallTime = [[NSDate date] timeIntervalSince1970];
            [self.showVideoView.messageBadgView SetText:nil];
            
            oldTime = 0;
            dateSeconds = 0;
            [[idoubs2AppDelegate sharedInstance].soundService stopRingBackTone];
            [[idoubs2AppDelegate sharedInstance].soundService stopRingTone];
            [[idoubs2AppDelegate sharedInstance].soundService stopLocating];
            [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ initAudioPlugin:[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]];
            [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ startRecordAndPlayAudio];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didRotateInterfaceOrientation:)
                                                         name:UIDeviceOrientationDidChangeNotification
                                                       object:nil];
            NSLog(@"11111111111111-%@",[NSDate date]);
            
            if (outgoingCallView) {
                [outgoingCallView removeFromSuperview];
                outgoingCallView = nil;
            }
            
            if (!showVideoView) {
                showVideoView = [[ShowVideoView alloc] initWithContactObject:self.contactObject];
                showVideoView.delegate = self;
            } else {
                [showVideoView SetRemotProfileImage:self.contactObject.image];
                [showVideoView updateCallerName:self.contactObject];
                [showVideoView SetDisplayName];
                
            }
            
            [showVideoView SetDefaultState];
            
            if (self.sendingVideo) {
                [videoProducer StartVideoCapture];
                [videoProducer setPreview: showVideoView.viewLocalVideo];
                sendingVideoState = (int)self.sendingVideo;
            }
            
            prev_deviceOrientation = UIDeviceOrientationUnknown;
            [self didRotateInterfaceOrientation:nil];
            sendingVideoState = -1;
            
            //            if (self.sendingVideo) {
            [showVideoView setVideoState:VideoViewState_NORMAL Animation:NO];
            //            } else {
            //                [showVideoView setVideoState:VideoViewState_TAB_MENU Animation:NO];
            //            }
            
            if (!showVideoView.superview) {
                [[idoubs2AppDelegate sharedInstance].window addSubview:showVideoView];
//                [audioSessionManager detectAvailableDevices];
                
                if (audioSessionManager.bluetoothDeviceAvailable) {
                    outputVoiceState = OutputVoiceState_Bluetooth;
                } else {
                    if (self.sendingVideo) {
                        outputVoiceState = OutputVoiceState_Speaker;
                    } else {
                        outputVoiceState = OutputVoiceState_Headset;
                    }
                }
                
                if (![self.showVideoView isVideoState]) {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DefaultAudioOutputInAudioCall"]) {
                        outputVoiceState = OutputVoiceState_Speaker;
                    }
                }
                
                [[idoubs2AppDelegate sharedInstance].soundService setSpeakerEnabled:outputVoiceState];
                [showVideoView SetSpeakerState:outputVoiceState OnHold:NO ShowWindowIcon:NO];
                [showVideoView SetMuteState:NO];
                isMute = NO;
                
            }
            [videoConsumer setDisplay:showVideoView.openGlView];
            [self.showVideoView.buddyButton setSelected:NO];
            self.showVideoView.videoRecive = NO;
            self.showVideoView.videoSend = self.sendingVideo;
            self.showVideoView.viewAudioCallMenu.hidden = [self.showVideoView isVideoState];
            self.showVideoView.viewAudioEndCall.hidden = !self.showVideoView.viewAudioCallMenu.hidden;
            self.showVideoView.viewLocalVideo.hidden = !self.showVideoView.viewAudioCallMenu.hidden;
            self.showVideoView.viewDisplayName.hidden = self.showVideoView.viewAudioCallMenu.hidden;
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            
            if ([idoubs2AppDelegate sharedInstance].tabBarController.presentedViewController == [idoubs2AppDelegate sharedInstance].seequBookmarks) {
                [[idoubs2AppDelegate sharedInstance].tabBarController dismissViewControllerAnimated:NO completion:nil];
            }
            
            
            
            
            
            
            
            [idoubs2AppDelegate sharedInstance].showProfile = NO;
            [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView setShowProfile:[idoubs2AppDelegate sharedInstance].showProfile];
            [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView setInCall:YES];
            
            if (self.sendingVideo) {
                [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Video];
            } else {
                [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Audio];
            }
            
            [self.showVideoView SetNetworkState:NetworkQualityState_1];
            
            if (timerVP8Bitrate && [timerVP8Bitrate isValid]) {
                [timerVP8Bitrate invalidate];
                timerVP8Bitrate = nil;
            }
            
            //            if([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager] && [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession){
            //            if ([UIDevice currentDevice].proximityState) {
            //                [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->rtmp.isDrop = 1;
            //            } else {
            //                [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->rtmp.isDrop = 0;
            //            }
            //            }
            timerVP8Bitrate = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(TimerVP8BitrateChange:) userInfo:nil repeats:YES];
            [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(timerInCallTick:)
                                           userInfo:nil
                                            repeats:YES];
            
        }
            break;
        case RTMP_CALL_EVENT_TYPE_REQUESTTIMEOUT:
        case RTMP_CALL_EVENT_TYPE_CLOSED:
        case RTMP_CALL_EVENT_TYPE_DECLINE:
        case RTMP_CALL_EVENT_TYPE_NOTENOUGHCREDIT:
        case RTMP_CALL_EVENT_TYPE_NOT_REACHABLE:
        case RTMP_CALL_EVENT_TYPE_FORBIDDEN:
        case RTMP_CALL_EVENT_TYPE_CANCELED:
        case RTMP_CALL_EVENT_TYPE_REQUEST_TERMINATE:
        case RTMP_CALL_EVENT_TYPE_FAILED:
        case RTMP_CALL_EVENT_TYPE_NOT_FOUND:
        case RTMP_CALL_EVENT_TYPE_BUSY_HERE:
        case RTMP_CALL_EVENT_TYPE_NOT_ACCEPTABLE_HERE:
        case RTMP_CALL_EVENT_TYPE_TEMPORARILY_UNAVAILABLE: {
            BOOL played=NO;
            [[idoubs2AppDelegate sharedInstance].soundService stopRingTone];
            [self.ringTimer invalidate];
            self.ringTimer=nil;
            
            self.isOnHold = NO;
            if (self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_DECLINE || self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_BUSY_HERE||
                self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_NOTENOUGHCREDIT) {
                [[idoubs2AppDelegate sharedInstance].soundService playDecline];
                played=YES;
            }
            if (self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_CANCELED){
                
                if(self.currentNotification)
                    [[UIApplication sharedApplication] cancelLocalNotification:self.currentNotification];
            }
            
            if ([UIDevice currentDevice].isProximityMonitoringEnabled) {
                [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            }
            
            if (timerCheckForNotReciveVideo && [timerCheckForNotReciveVideo isValid]) {
                [timerCheckForNotReciveVideo invalidate];
                timerCheckForNotReciveVideo = nil;
            }
            
            [videoConsumer stopVideoRender];
            [videoProducer StopVideoCapture];
            NSLog(@"onRTMPEvent -> stopRecordAndPlayAudio type:%u", rtmp_call_state);
            [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ stopRecordAndPlayAudio:[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]];
            [[idoubs2AppDelegate sharedInstance].soundService stopRingBackTone];
            [[idoubs2AppDelegate sharedInstance].soundService stopRingTone];
            [[idoubs2AppDelegate sharedInstance].soundService stopLocating];
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            
            [idoubs2AppDelegate RefreshTab];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
            
            
            //            [showVideoView removeFromSuperview];
            
            if (incomingCallView) {
                [incomingCallView removeFromSuperview];
                incomingCallView = nil;
            }
            
            if (showVideoView && [showVideoView superview]) {
                if (self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_DECLINE ||self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_NOTENOUGHCREDIT) {
                    if (self.showVideoView) {
                        [self.showVideoView setCallingStateText:@"Declined"];
                    }
                    //                    [outgoingCallView setCallingStateText:@"Declined"];
                    [showVideoView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:CALLING_SCREEN_WAIT_TIME];
                    self.rtmp_call_state = RTMP_EVENT_TYPE_UNKNOWN;
                    [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ stopRecordAndPlayAudio:[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]];
                } else {
                    if (self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_REQUESTTIMEOUT ||
                        self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_NOT_FOUND ||
                        self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_TEMPORARILY_UNAVAILABLE) {
                        if (self.showVideoView) {
                            [self.showVideoView setCallingStateText:@"No Answer"];
                        }
                        //                        [outgoingCallView setCallingStateText:@"No Answer"];
                        [showVideoView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:CALLING_SCREEN_WAIT_TIME];
                        self.rtmp_call_state = RTMP_EVENT_TYPE_UNKNOWN;
                        [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ stopRecordAndPlayAudio:[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]];
                    } else {
                        if (self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_BUSY_HERE) {
                            if (self.showVideoView) {
                                [self.showVideoView setCallingStateText:@"User Busy"];
                            }
                            //                            [outgoingCallView setCallingStateText:@"User Busy"];
                            [showVideoView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:CALLING_SCREEN_WAIT_TIME];
                            self.rtmp_call_state = RTMP_EVENT_TYPE_UNKNOWN;
                            [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ stopRecordAndPlayAudio:[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]];
                        } else {
                            if (self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_NOT_REACHABLE || self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_FORBIDDEN) {
                                if (self.showVideoView) {
                                    [self.showVideoView setCallingStateText:@"Not reachable"];
                                }
                                //                                [outgoingCallView setCallingStateText:@"Not reachable"];
                                [showVideoView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:CALLING_SCREEN_WAIT_TIME];
                                self.rtmp_call_state = RTMP_EVENT_TYPE_UNKNOWN;
                                [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ stopRecordAndPlayAudio:[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]];
                            }else {
                                [showVideoView removeFromSuperview];
                            }
                        }
                    }
                }
            }
            
            UserAgent = nil;
            FlashArguments = nil;
            
            [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Default];
            [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex;
            //            [showVideoView setVideoState:VideoViewState_HIDE Animation:YES];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            
            [idoubs2AppDelegate sharedInstance].showProfile = YES;
            [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView setShowProfile:[idoubs2AppDelegate sharedInstance].showProfile];
            [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView setInCall:NO];
            
            if (timerVP8Bitrate && [timerVP8Bitrate isValid]) {
                [timerVP8Bitrate invalidate];
                timerVP8Bitrate = nil;
            }
            if ([[UIApplication sharedApplication] applicationState]==UIApplicationStateBackground && !played) {
                [[idoubs2AppDelegate sharedInstance].soundService playCallDrop];
                played=YES;
            }
            
            if (self.rtmp_call_state==RTMP_CALL_EVENT_TYPE_REQUESTTIMEOUT && !played) {
                [[idoubs2AppDelegate sharedInstance].soundService playCallDrop];
            }
            
            
        }
            break;
        case RTMP_CALL_EVENT_TYPE_REMOTE_HOLD:{
            NSLog(@"RTMP_CALL_EVENT_TYPE_REMOTE_HOLD");
            self.isOnHold =  YES;
            oldTime = dateSeconds;
            [[idoubs2AppDelegate sharedInstance].soundService playHoldBeep];
            [showVideoView SetSpeakerState:outputVoiceState OnHold:self.isOnHold ShowWindowIcon:NO];
            
            if ([idoubs2AppDelegate sharedInstance].showProfile) {
                if ([self.showVideoView isVideoState]) {
                    [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Video_Selected];
                } else {
                    [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Audio_Selected];
                }
            } else {
                if ([self.showVideoView isVideoState]) {
                    [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Video];
                } else {
                    [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Audio];
                }
            }
            if (![self.showVideoView isVideoState]) {
                [self.showVideoView ShowReconnectView:YES Message:@"On Hold..."];
            }
            
            if ([self isInCall] || [self.outgoingCallView superview]) {
                [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ AudioUnitPlugin_handle_mute:YES];
            }
            [self.showVideoView ShowReconnectView:YES Message:@"On Hold..."];
        }
            break;
        case RTMP_CALL_EVENT_TYPE_REMOTE_UNHOLD:{
            NSLog(@"RTMP_CALL_EVENT_TYPE_REMOTE_UNHOLD");
            self.isOnHold = NO;
            startCallTime = [[NSDate date] timeIntervalSince1970];
            rtmp_call_state = RTMP_CALL_EVENT_TYPE_ACCEPTED;
            [showVideoView SetSpeakerState:outputVoiceState OnHold:self.isOnHold ShowWindowIcon:NO];
            if ([idoubs2AppDelegate sharedInstance].showProfile) {
                if ([self.showVideoView isVideoState]) {
                    [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Video_Selected];
                } else {
                    [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Audio_Selected];
                }
            } else {
                if ([self.showVideoView isVideoState]) {
                    [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Video];
                } else {
                    [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Audio];
                }
            }
            
            if (![self.showVideoView isVideoState]) {
                [self.showVideoView ShowReconnectView:NO Message:@""];
            }
            
            if ([self isInCall] || [self.outgoingCallView superview]) {
                [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ AudioUnitPlugin_handle_mute:isMute];
            }
            [self.showVideoView ShowReconnectView:NO Message:@""];
        }
            break;
        default: {
            break;
        }
    }
}
-(BOOL)isInSilentMode{
    CFStringRef state = nil;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    OSStatus status = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &state);
    
    if (status == kAudioSessionNoError)
    {
        return (CFStringGetLength(state) == 0);   // YES = silent
    }
    return NO;
}
- (void) CallWithContactObject:(ContactObject*)contact  Video:(BOOL)video {
    if (![[idoubs2AppDelegate sharedInstance] isConnected]) {
        return;
    }
    
    isCallIncoming = NO;
    isFirstInvite = YES;
    
    self.sendingAudio = YES;
    if (video) {
        self.sendingVideo = YES;
    } else {
        self.sendingVideo = NO;
    }
    
    self.contactObject = contact;
    callingSeequID = self.contactObject.SeequID;
    
    if (self.showVideoView) {
        [showVideoView removeNotification];
    }
    
    //    outgoingCallView = [[OutgoingCallingView alloc] initWithContactObject:self.contactObject Video:video];
    //    outgoingCallView.delegate = self;
    
    showVideoView = [[ShowVideoView alloc] initWithContactObject:self.contactObject];
    showVideoView.delegate = self;
    
    [showVideoView setInterfaceOrientation:UIInterfaceOrientationPortrait];
    [showVideoView SetRemotProfileImage:self.contactObject.image];
    [showVideoView updateCallerName:self.contactObject];
    [showVideoView SetDisplayName];
    
    showVideoView.videoRecive = NO;
    showVideoView.videoSend = self.sendingVideo;
    
    [showVideoView ShowHideAllViews:YES];
    
    [self.showVideoView ShowRemotProfileImage:YES];
    
    [UIView beginAnimations:@"CallView" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [showVideoView setVideoState:VideoViewState_Calling Animation:NO];
    [[idoubs2AppDelegate sharedInstance].window addSubview:showVideoView];
    [UIView commitAnimations];
    
    self.showVideoView.viewAudioEndCall.hidden = !self.showVideoView.viewAudioCallMenu.hidden;
    [self.showVideoView.buddyButton setSelected:NO];
    
    [idoubs2AppDelegate  RTMP_Call_To:callingSeequID Call_Type:video ? @"video":@"audio"];
    
    [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ startRecordAndPlayAudio];
//    [audioSessionManager detectAvailableDevices];
    
    if (audioSessionManager.bluetoothDeviceAvailable) {
        outputVoiceState = OutputVoiceState_Bluetooth;
    } else {
        if (video) {
            outputVoiceState = OutputVoiceState_Speaker;
        } else {
            outputVoiceState = OutputVoiceState_Headset;
        }
    }
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    if (![self.showVideoView isVideoState]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DefaultAudioOutputInAudioCall"]) {
            outputVoiceState = OutputVoiceState_Speaker;
        }
    }
    
    [[idoubs2AppDelegate sharedInstance].soundService setSpeakerEnabled:outputVoiceState];
    [showVideoView SetSpeakerState:outputVoiceState OnHold:self.isOnHold ShowWindowIcon:NO];
    [showVideoView SetMuteState:NO];
    isMute = NO;
    
    [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex;
    
    if (![UIDevice currentDevice].isProximityMonitoringEnabled) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    }
    
    
}

- (void) ReceiveIncomingCallWithContactObject:(ContactObject*)contact Video:(BOOL)video {
    isCallIncoming = YES;
    self.contactObject = contact;
    callingSeequID = self.contactObject.SeequID;
    incomingCallView = [[IncomingCallingView alloc] initWithContactObject:self.contactObject Video:video];
    incomingCallView.delegate = self;
    [[idoubs2AppDelegate sharedInstance].window addSubview:incomingCallView];
}

- (void) ReceivCallState:(NSString*)call_state {
    self.sendingVideo = NO;
    self.sendingAudio = NO;
    
    if ([call_state isEqualToString:@"video"]) {
        self.sendingVideo = YES;
        self.sendingAudio = YES;
    } else {
        if ([call_state isEqualToString:@"audio"]) {
            self.sendingAudio = YES;
        }
    }
}

- (void) ReceivCallFromFlash:(NSNotification*)notification {
    NSDictionary* dict = [notification object];
    UserAgent = [dict valueForKey:@"User_Agent"];
    FlashArguments = [dict valueForKey:@"Protime_Flash"];
    
    uint index = (uint)([UserAgent rangeOfString:@"SipFlash"].location);
    if (index <= [UserAgent length]) {
        if ([FlashArguments length]) {
            NSArray *array = [FlashArguments componentsSeparatedByString:@";"];
            if ([array count] == 3) {
                
            }
        }
    } else {
        UserAgent = nil;
        FlashArguments = nil;
    }
}

- (void) onProximityStateChanged:(NSNotification*)notification {
    static NSTimeInterval last_changed = 0;
    
    if (!last_changed) {
        last_changed = [[NSDate date] timeIntervalSince1970];
        [self performSelector:@selector(onProximityStateChangedAfterDelay) withObject:nil afterDelay:1.0];
        
        return;
    }
    
    NSTimeInterval current_time = [[NSDate date] timeIntervalSince1970];
    
    if (current_time - last_changed < 1.0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    } else {
        [self performSelector:@selector(onProximityStateChangedAfterDelay) withObject:nil afterDelay:1.0];
    }
    
    last_changed = [[NSDate date] timeIntervalSince1970];
}

- (void) onProximityStateChangedAfterDelay {
    static OutputVoiceState prev_outputVoiceState;
    UIDevice *device = [UIDevice currentDevice];
    [NSObject cancelPreviousPerformRequestsWithTarget:videoProducer selector:@selector(setPreview:) object:nil];
    
    if (![self isInCall]) {
        return;
    }
    
    if (self.sendingVideo) {
        if (device.proximityState) {
            [videoProducer performSelector:@selector(setPreview:) withObject:nil afterDelay:PROXIMITY_STATE_CHANGE_DELAY];
        } else {
            [videoProducer setPreview:showVideoView.viewLocalVideo];
        }
    }
    
    if([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager] && [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession){
        if (device.proximityState) {
            [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->rtmp.isDrop = 1;
        } else {
            [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->rtmp.isDrop = 0;
        }
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ProximityAudioOutputChange"]) {
        if (device.proximityState) {
            prev_outputVoiceState = outputVoiceState;
            outputVoiceState = OutputVoiceState_Headset;
            [[idoubs2AppDelegate sharedInstance].soundService setSpeakerEnabled:outputVoiceState];
            [showVideoView SetSpeakerState:outputVoiceState OnHold:NO ShowWindowIcon:NO];
        } else {
            outputVoiceState = prev_outputVoiceState;
            [[idoubs2AppDelegate sharedInstance].soundService setSpeakerEnabled:outputVoiceState];
            [showVideoView SetSpeakerState:outputVoiceState OnHold:NO ShowWindowIcon:NO];
        }
    }
}

- (void) onRequestEvent:(NSNotification*)notification {
    NSDictionary *dict = [notification object];
    
    if (self.showVideoView.videoViewState != VideoViewState_NORMAL && self.showVideoView.videoViewState != VideoViewState_NORMAL_MENU) {
        return;
    }
    
    NSString *from = [dict objectForKey:@"SEEQUID"];
    ContactObject *obj = [[ContactStorage sharedInstance] GetContactObjectBySeequId:from];
    
    if (!obj) {
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(RemoveIncomingRequestView) object:nil];
    
    if (incomingRequestView) {
        [incomingRequestView removeFromSuperview];
        incomingRequestView = nil;
    }
    
    BOOL small = NO;
    if (UIDeviceOrientationIsLandscape(prev_deviceOrientation) && ![self.showVideoView isVideoState]) {
        small = YES;
    }
    
    if (dict && [dict objectForKey:@"type"] && [[dict objectForKey:@"type"] isKindOfClass:[NSString class]]) {
        NSString *requestType = [dict objectForKey:@"type"];
        
        if ([requestType isEqualToString:@"RINGBACK"]) {
            incomingRequestView = [[IncomingRequestView alloc] initWithContactObject:obj
                                                                             Message:@"has requested a Ringback"
                                                                              Target:self
                                                                 IncomingRequestType:IncomingRequest_Type_RingBack
                                                                               Small:small];
        } else {
            if ([requestType isEqualToString:@"REVIEW"]) {
                incomingRequestView = [[IncomingRequestView alloc] initWithContactObject:obj
                                                                                 Message:@"has requested a Review"
                                                                                  Target:self
                                                                     IncomingRequestType:IncomingRequest_Type_Review
                                                                                   Small:small];
            } else {
                if ([requestType isEqualToString:@"*#===REFRESH===#*"]) {
                } else {
                    //                    dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:from, @"SEEQUID", text, @"message", nil];
                }
            }
        }
    } else {
        NSString *message = [dict objectForKey:@"message"];
        incomingRequestView = [[IncomingRequestView alloc] initWithContactObject:obj
                                                                         Message:message
                                                                          Target:self
                                                             IncomingRequestType:IncomingRequest_Type_Message
                                                                           Small:small];
        
    }
    
    if (incomingRequestView) {
        if (self.showVideoView.splited) {
            if (UIDeviceOrientationIsLandscape(prev_deviceOrientation)) {
                [[idoubs2AppDelegate sharedInstance].window addSubview:incomingRequestView];
                if (prev_deviceOrientation == UIDeviceOrientationLandscapeLeft) {
                    incomingRequestView.center = CGPointMake(280, [idoubs2AppDelegate sharedInstance].window.frame.size.height/2);
                    incomingRequestView.transform = CGAffineTransformMakeRotation(M_PI_2);
                } else {
                    incomingRequestView.center = CGPointMake(40, [idoubs2AppDelegate sharedInstance].window.frame.size.height/2);
                    incomingRequestView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                }
            } else {
                [self.showVideoView.imageViewRemoteVideo addSubview:incomingRequestView];
                incomingRequestView.center = CGPointMake(160, 120);
            }
        } else {
            [self.showVideoView.imageViewRemoteVideo addSubview:incomingRequestView];
            if (UIDeviceOrientationIsLandscape(prev_deviceOrientation)) {
                if ([self.showVideoView isVideoState]) {
                    if (prev_deviceOrientation == UIDeviceOrientationLandscapeLeft) {
                        incomingRequestView.center = CGPointMake(210, 310 - 160);
                    } else {
                        incomingRequestView.center = CGPointMake(200, 210 - 160);
                    }
                } else {
                    if ([[UIScreen mainScreen] bounds].size.height == 568) {
                        incomingRequestView.center = CGPointMake(70, 195);
                    } else {
                        incomingRequestView.center = CGPointMake(70, 195);
                    }
                }
            } else {
                if ([self.showVideoView isVideoState]) {
                    incomingRequestView.center = CGPointMake(160, 165);
                } else {
                    incomingRequestView.center = CGPointMake(160, self.showVideoView.viewAudioCallMenu.frame.origin.y + self.showVideoView.viewAudioCallMenu.frame.size.height + incomingRequestView.frame.size.height/2);
                }
            }
        }
        
        [self.showVideoView IncrementMessageBadgValue];
    }
    
    [self performSelector:@selector(RemoveIncomingRequestView) withObject:nil afterDelay:REMOVE_INCOMING_REQUESTVIEW_TIME];
}

- (void)timerInCallTick:(NSTimer*)timer {
    // to be implemented for the call time display
    
    if (self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_ACCEPTED) {
        if (!self.isOnHold) {
            NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
            
            dateSeconds = oldTime + currentTime - startCallTime;
            
            [self.showVideoView SetTime:dateSeconds];
        }
    } else {
        if (self.rtmp_call_state != RTMP_CALL_EVENT_TYPE_LOCAL_HOLD_OK &&
            self.rtmp_call_state != RTMP_CALL_EVENT_TYPE_LOCAL_HOLD_NOK &&
            self.rtmp_call_state != RTMP_CALL_EVENT_TYPE_LOCAL_RESUME_OK &&
            self.rtmp_call_state != RTMP_CALL_EVENT_TYPE_LOCAL_RESUME_NOK &&
            self.rtmp_call_state != RTMP_CALL_EVENT_TYPE_REMOTE_HOLD &&
            self.rtmp_call_state != RTMP_CALL_EVENT_TYPE_REMOTE_UNHOLD) {
            [timer invalidate];
        } else {
            if (self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_LOCAL_HOLD_OK ||
                self.rtmp_call_state == RTMP_CALL_EVENT_TYPE_REMOTE_HOLD) {
                
                //                [self switchNoVideo:nil];
                
                
                
            }
        }
    }
}

#pragma mark -
#pragma mark IncomingRequestView Delegate Methods
#pragma mark -

- (void) didClickOnIncomingRequestView:(IncomingRequestView*)requestView {
    [self.showVideoView.messageBadgView SetText:nil];
    switch (requestView.incomingRequestType) {
        case IncomingRequest_Type_Message: {
            UINavigationController *nav = [[idoubs2AppDelegate sharedInstance].tabBarController.viewControllers objectAtIndex:1];
            [nav popToRootViewControllerAnimated:NO];
            
            [self.showVideoView setVideoState:VideoViewState_TAB Animation:YES];
            [idoubs2AppDelegate RefreshTab];
            
            [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 1;
            [idoubs2AppDelegate sharedInstance].ReplyWithMessageNumber = requestView.contactObject.SeequID;
            [idoubs2AppDelegate sharedInstance].messageNavigationTitle = [NSString stringWithFormat:@"%@ %@", requestView.contactObject.FirstName, requestView.contactObject.LastName];
        }
            break;
        case IncomingRequest_Type_RingBack:
        case IncomingRequest_Type_Review:
        case IncomingRequest_Type_Connection: {
            [self.showVideoView setVideoState:VideoViewState_TAB Animation:YES];
            [[idoubs2AppDelegate sharedInstance].tabBarController setSelectedIndex:3];
        }
            break;
        default:
            break;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:requestView];
    [requestView removeFromSuperview];
}

- (BOOL) isInCall {
    if (rtmp_call_state == RTMP_CALL_EVENT_TYPE_ACCEPTED ||  rtmp_call_state == RTMP_CALL_EVENT_TYPE_REMOTE_HOLD ||  rtmp_call_state == RTMP_CALL_EVENT_TYPE_REMOTE_UNHOLD) {
        return YES;
    }
    
    return NO;
}

- (void) onReceivVideoFrame:(NSNotification*)notification {
    BOOL isLandscape = [[notification object] boolValue];
    
    if (isLandscape != self.isRecVideoLandscape) {
        self.isRecVideoLandscape = isLandscape;
        if (self.sendingVideo) {
            [self.showVideoView LocalVideoStateChanged:self.isRecVideoLandscape];
            [self didChangeLocalVideoFrame];
        }
    }
    
    lastReciveVideoFrameTime = [[NSDate date] timeIntervalSince1970];
    [self.showVideoView ShowRemotProfileImage:NO];
    [self.showVideoView ShowReconnectView:NO Message:@""];
    [idoubs2AppDelegate sharedInstance].videoService.showVideoView.imageViewNetworkStatus.hidden = NO;
    
    if (![self isInCall]) {
        return;
    }
    
    if (!self.showVideoView.videoRecive) {
        self.showVideoView.videoRecive = YES;
        self.showVideoView.viewAudioCallMenu.hidden = YES;
        self.showVideoView.viewAudioEndCall.hidden = !self.showVideoView.viewAudioCallMenu.hidden;
        self.showVideoView.viewLocalVideo.hidden = NO;
        self.showVideoView.viewDisplayName.hidden = self.showVideoView.viewAudioCallMenu.hidden;
        [self.showVideoView setVideoState:self.showVideoView.videoViewState Animation:NO];
        if ([idoubs2AppDelegate sharedInstance].showProfile) {
            [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Video_Selected];
        } else {
            [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Video];
        }
        
        if (self.showVideoView.videoViewState != VideoViewState_NORMAL || self.showVideoView.videoViewState != VideoViewState_NORMAL_MENU) {
            [self.showVideoView setVideoState:VideoViewState_NORMAL Animation:YES];
        }
    }
    
    [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView setSelectedIndex:[idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex];
    
    if (!timerCheckForNotReciveVideo) {
        timerCheckForNotReciveVideo = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onReciveVideoCheckTimer:) userInfo:nil repeats:YES];
    }
    
    [self.showVideoView changeNetworkStatusImageViewFrame];
}

- (void) onReciveVideoCheckTimer:(NSTimer*)timer {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    
    if (currentTime - lastReciveVideoFrameTime > 4) {
        [idoubs2AppDelegate sharedInstance].videoService.showVideoView.imageViewNetworkStatus.hidden = YES;
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView ShowRemotProfileImage:YES];
        [idoubs2AppDelegate sharedInstance].videoService.showVideoView.openGlView.hidden = YES;
        
        if (!self.sendingVideo && self.showVideoView.videoRecive) {
            self.showVideoView.videoRecive = NO;
            if ([idoubs2AppDelegate sharedInstance].showProfile) {
                [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Audio_Selected];
            } else {
                [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Audio];
            }
            if (self.showVideoView.videoViewState != VideoViewState_HIDE) {
                [timerCheckForNotReciveVideo invalidate];
                timerCheckForNotReciveVideo = nil;
            }
        }
        
        if (!self.sendingVideo) {
            self.showVideoView.viewAudioCallMenu.hidden = NO;
            self.showVideoView.viewAudioEndCall.hidden = !self.showVideoView.viewAudioCallMenu.hidden;
            self.showVideoView.viewLocalVideo.hidden = YES;
            self.showVideoView.viewDisplayName.hidden = self.showVideoView.viewAudioCallMenu.hidden;
            [self.showVideoView setVideoState:self.showVideoView.videoViewState Animation:NO];
        }
        
        [self.showVideoView calculateAudioCallEndButtonCenter];
    }
}

- (void) didClickOnContactDetail {
    
}

- (void) didClickOnEndCall {
    self.isOnHold = NO;
    NSLog(@"didClickOnEndCall -> stopRecordAndPlayAudio");
    [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ stopRecordAndPlayAudio:[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]];
    [[idoubs2AppDelegate sharedInstance].soundService stopRingBackTone];
    [[idoubs2AppDelegate sharedInstance].soundService stopRingTone];
    [[idoubs2AppDelegate sharedInstance].soundService stopLocating];
    [idoubs2AppDelegate RTMP_Hangup_Call];
    [outgoingCallView removeFromSuperview];
    outgoingCallView = nil;
    [self.showVideoView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
    [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Default];
    [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex;
    self.rtmp_call_state = RTMP_EVENT_TYPE_UNKNOWN;
    if ([UIDevice currentDevice].isProximityMonitoringEnabled) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [idoubs2AppDelegate RefreshTab];
}

- (void) didClickOnAnswerWithCamera {
    [[idoubs2AppDelegate sharedInstance].soundService stopRingBackTone];
    [[idoubs2AppDelegate sharedInstance].soundService stopRingTone];
    [[idoubs2AppDelegate sharedInstance].soundService stopLocating];
    [idoubs2AppDelegate RTMP_Accept_Call];
    [incomingCallView removeFromSuperview];
    incomingCallView = nil;
    
    [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Video];
    [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex;
}

- (void) didClickOnAnswerWithVoiceOnly {
    [[idoubs2AppDelegate sharedInstance].soundService stopRingBackTone];
    [[idoubs2AppDelegate sharedInstance].soundService stopRingTone];
    [[idoubs2AppDelegate sharedInstance].soundService stopLocating];
    self.sendingVideo = NO;
    [idoubs2AppDelegate RTMP_Accept_Call];
    [incomingCallView removeFromSuperview];
    incomingCallView = nil;
    
    [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Audio];
    [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex;
}

- (void) didClickOnAnswer {
    [[idoubs2AppDelegate sharedInstance].soundService stopRingBackTone];
    [[idoubs2AppDelegate sharedInstance].soundService stopRingTone];
    [[idoubs2AppDelegate sharedInstance].soundService stopLocating];
    [idoubs2AppDelegate RTMP_Accept_Call];
    [incomingCallView removeFromSuperview];
    incomingCallView = nil;
    
    [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Audio];
    [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex;
}

- (void) didClickOnReplyWithMessage {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Message %@ %@", self.contactObject.FirstName, self.contactObject.LastName]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"I'll call you later.", @"On my way.", @"Custom...", nil];
    [sheet showFromTabBar:[idoubs2AppDelegate sharedInstance].tabBarController.tabBar];
}

- (void) didClickOnDeclineCall {
    NSLog(@"didClickOnEndCall -> didClickOnDeclineCall");
    [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ stopRecordAndPlayAudio:[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]];
    [[idoubs2AppDelegate sharedInstance].soundService stopRingBackTone];
    [[idoubs2AppDelegate sharedInstance].soundService stopRingTone];
    [[idoubs2AppDelegate sharedInstance].soundService stopLocating];
    [idoubs2AppDelegate RTMP_Decline_Call];
    [incomingCallView removeFromSuperview];
    incomingCallView = nil;
}

- (BOOL) didClickOnVideoOff {
    if (self.showVideoView.videoViewState == VideoViewState_Calling) {
        self.sendingVideo = !self.sendingVideo;
        return self.sendingVideo;
    }
    self.sendingVideo = !self.sendingVideo;
    
    [self didChangeLocalVideoFrame];
    
    if ([idoubs2AppDelegate sharedInstance].showProfile) {
        if ([self.showVideoView isVideoState]) {
            [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Video_Selected];
        } else {
            [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Audio_Selected];
        }
    } else {
        if ([self.showVideoView isVideoState]) {
            [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Video];
        } else {
            [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Audio];
        }
    }
    
    self.showVideoView.viewAudioCallMenu.hidden = [self.showVideoView isVideoState];
    self.showVideoView.viewAudioEndCall.hidden = !self.showVideoView.viewAudioCallMenu.hidden;
    self.showVideoView.viewLocalVideo.hidden = !self.showVideoView.viewAudioCallMenu.hidden;
    self.showVideoView.viewDisplayName.hidden = self.showVideoView.viewAudioCallMenu.hidden;
    
    if ([self.showVideoView isVideoState]) {
        [self.showVideoView setVideoState:self.showVideoView.videoViewState Animation:NO];
    } else {
        [self.showVideoView setVideoState:VideoViewState_NORMAL Animation:NO];
        [self.showVideoView calculateAudioCallEndButtonCenter];
    }
    
    return self.sendingVideo;
}

- (void) didClickOnMute {
    isMute = !isMute;
    
    if (!self.isOnHold) {
        [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ AudioUnitPlugin_handle_mute:isMute];
        [showVideoView SetMuteState:[[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ isMuted]];
    } else {
        [showVideoView SetMuteState:isMute];
    }
}

- (void) didClickOnSpeaker {
    switch (outputVoiceState) {
        case OutputVoiceState_Headset: {
            outputVoiceState = OutputVoiceState_Speaker;
        }
            break;
        case OutputVoiceState_Speaker: {
            if (audioSessionManager.bluetoothDeviceAvailable) {
                outputVoiceState = OutputVoiceState_Bluetooth;
            } else {
                outputVoiceState = OutputVoiceState_Headset;
            }
        }
            break;
        case OutputVoiceState_Bluetooth: {
            outputVoiceState = OutputVoiceState_Headset;
        }
            break;
        default:
            break;
    }
    
    [[idoubs2AppDelegate sharedInstance].soundService setSpeakerEnabled:outputVoiceState];
    [showVideoView SetSpeakerState:outputVoiceState OnHold:self.isOnHold ShowWindowIcon:[self.showVideoView isVideoState]];
}

- (void) didClickOnChangeCamera {
    [videoProducer toggleCamera];
    
    switch (prev_deviceOrientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationUnknown:
        {
            [videoProducer setOrientation: AVCaptureVideoOrientationPortrait];
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            [videoProducer setOrientation: AVCaptureVideoOrientationPortraitUpsideDown];
            break;
        }
        case UIDeviceOrientationLandscapeLeft: {
            [videoProducer setOrientation: AVCaptureVideoOrientationLandscapeRight];
            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            [videoProducer setOrientation: AVCaptureVideoOrientationLandscapeLeft];
            break;
        }
    }
}
- (void) setProducerOrentation:(AVCaptureVideoOrientation)orientation {
    [videoProducer setOrientation:orientation];
}
- (void) didChangeLocalVideoFrame {
    if (sendingVideoState != (int)self.sendingVideo && self.sendingVideo && self.isInCall) {
        [videoProducer StartVideoCapture];
    }
    
    sendingVideoState = (int)self.sendingVideo;
    if (self.sendingVideo && showVideoView.videoViewState != VideoViewState_Calling) {
        [videoProducer setPreview:showVideoView.viewLocalVideo];
        [showVideoView SetVideoOffState:YES];
    } else {
        [videoProducer setPreview:nil];
        [showVideoView SetVideoOffState:NO];
    }
    
    if (!(self.showVideoView.videoViewState == VideoViewState_NORMAL || self.showVideoView.videoViewState == VideoViewState_NORMAL_MENU) &&
        incomingRequestView) {
        [self RemoveIncomingRequestView];
    }
}

- (void) didChangeRemoteVideoStateTo:(VideoViewState)state Split:(BOOL)splited Orientation:(BOOL)isLandscape  frame:(CGRect)frame {
    [videoConsumer RemotVideoFrameChangedTo:(int)state Split:splited Orientation:isLandscape frame:frame];
}

#pragma mark -
#pragma mark UIActionSheet Delegate Methods
#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        [[idoubs2AppDelegate sharedInstance].soundService stopRingBackTone];
        [[idoubs2AppDelegate sharedInstance].soundService stopRingTone];
        [[idoubs2AppDelegate sharedInstance].soundService stopLocating];
        [self didClickOnDeclineCall];
        //        NSString *Message_ID = MESSAGE_ID;
        
        switch (buttonIndex) {
            case 0: {
                
                
                SeequMessageObject* info = [[SeequMessageObject alloc] init];
                NSString*  seequ_id =self.contactObject.SeequID;
                
                info.msgId = MESSAGE_ID;
                info.from =seequ_id;
                info.msg = @"I'll call you later.";
                
                info.type = Message_Type_Text;
                info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
                RTMPChatManager* manager = (RTMPChatManager*)[idoubs2AppDelegate getChatManager];
                [manager sendTextMessage:info AddToResendList:NO];
                
                NSMutableDictionary*  dictionary  =[[NSMutableDictionary alloc] init];
                [dictionary setObject:seequ_id forKey:@"to"];
                [dictionary setObject:info.msgId forKey:@"msgId"];
                [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"isDelivered"];
                [dictionary setObject:@"I'll call you later." forKey:@"msg"];
                [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"isGroup"];
                [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"isSend"];
                [dictionary setObject:[NSDate date] forKey:@"date"];
                
                [[MessageCoreDataManager sharedManager] addMessageForSend:dictionary thumbnail:nil];
                
            }
                break;
            case 1: {
                SeequMessageObject* info = [[SeequMessageObject alloc] init];
                NSString*  seequ_id =self.contactObject.SeequID;
                
                info.msgId = MESSAGE_ID;
                info.from =seequ_id;
                info.msg = @"On my way.";
                
                info.type = Message_Type_Text;
                info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
                RTMPChatManager* manager = (RTMPChatManager*)[idoubs2AppDelegate getChatManager];
                [manager sendTextMessage:info AddToResendList:NO];
                
                
                NSMutableDictionary*  dictionary  =[[NSMutableDictionary alloc] init];
                [dictionary setObject:seequ_id forKey:@"to"];
                [dictionary setObject:info.msgId forKey:@"msgId"];
                [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"isDelivered"];
                [dictionary setObject:@"On my way." forKey:@"msg"];
                [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"isGroup"];
                [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"isSend"];
                [dictionary setObject:[NSDate date] forKey:@"date"];
                
                [[MessageCoreDataManager sharedManager] addMessageForSend:dictionary thumbnail:nil];
            }
                break;
            default: {
                [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 0;
                [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 1;
                [idoubs2AppDelegate sharedInstance].ReplyWithMessageNumber = callingSeequID;
                [idoubs2AppDelegate sharedInstance].messageNavigationTitle = [NSString stringWithFormat:@"%@ %@", self.contactObject.FirstName, self.contactObject.LastName];
                
                UINavigationController *nav = [[idoubs2AppDelegate sharedInstance].tabBarController.viewControllers objectAtIndex:1];
                [nav popToRootViewControllerAnimated:YES];
            }
                break;
        }
    }
}

- (void) RemoveIncomingRequestView {
    [incomingRequestView removeFromSuperview];
    incomingRequestView = nil;
}

- (void) didRotateInterfaceOrientation:(NSNotification *)notification {
    if (![self isInCall]) {
        return;
    }
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    if (prev_deviceOrientation != deviceOrientation) {
        [incomingRequestView removeFromSuperview];
        switch (deviceOrientation) {
            case UIDeviceOrientationPortrait: {
                prev_deviceOrientation = UIDeviceOrientationPortrait;
                [videoProducer setOrientation: AVCaptureVideoOrientationPortrait];
                [self.showVideoView didRotateInterfaceOrientation:UIInterfaceOrientationPortrait];
                break;
            }
            case UIDeviceOrientationPortraitUpsideDown: {
                prev_deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
                [videoProducer setOrientation: AVCaptureVideoOrientationPortraitUpsideDown];
                [self.showVideoView didRotateInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown];
                break;
            }
            case UIDeviceOrientationLandscapeRight: {
                prev_deviceOrientation = UIDeviceOrientationLandscapeRight;
                [videoProducer setOrientation: AVCaptureVideoOrientationLandscapeRight];
                [self.showVideoView didRotateInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
                break;
            }
            case UIDeviceOrientationLandscapeLeft: {
                prev_deviceOrientation = UIDeviceOrientationLandscapeLeft;
                [videoProducer setOrientation: AVCaptureVideoOrientationLandscapeLeft];
                [self.showVideoView didRotateInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
                break;
            }
            default: {
                UINavigationController *navCtrl = [[idoubs2AppDelegate sharedInstance].tabBarController.viewControllers objectAtIndex:[idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex];
                if (navCtrl && navCtrl.viewControllers && navCtrl.viewControllers.count) {
                    UIViewController *controller = [navCtrl.viewControllers objectAtIndex:0];
                    if (controller && controller.interfaceOrientation != self.showVideoView.interfaceOrientation) {
                        switch (controller.interfaceOrientation) {
                            case UIDeviceOrientationPortrait: {
                                prev_deviceOrientation = UIDeviceOrientationPortrait;
                                [videoProducer setOrientation: AVCaptureVideoOrientationPortrait];
                                [self.showVideoView didRotateInterfaceOrientation:UIInterfaceOrientationPortrait];
                                break;
                            }
                            case UIDeviceOrientationPortraitUpsideDown: {
                                prev_deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
                                [videoProducer setOrientation: AVCaptureVideoOrientationPortraitUpsideDown];
                                [self.showVideoView didRotateInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown];
                                break;
                            }
                            case UIDeviceOrientationLandscapeRight: {
                                prev_deviceOrientation = UIDeviceOrientationLandscapeRight;
                                [videoProducer setOrientation: AVCaptureVideoOrientationLandscapeLeft];
                                [self.showVideoView didRotateInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
                                break;
                            }
                            case UIDeviceOrientationLandscapeLeft: {
                                prev_deviceOrientation = UIDeviceOrientationLandscapeLeft;
                                [videoProducer setOrientation: AVCaptureVideoOrientationLandscapeRight];
                                [self.showVideoView didRotateInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
                                break;
                            }
                            default: {
                                prev_deviceOrientation = UIDeviceOrientationPortrait;
                                [videoProducer setOrientation: AVCaptureVideoOrientationPortrait];
                                [self.showVideoView didRotateInterfaceOrientation:UIInterfaceOrientationPortrait];
                                break;
                            }
                        }
                    }
                }
                
                if (prev_deviceOrientation == UIDeviceOrientationUnknown) {
                    prev_deviceOrientation = UIDeviceOrientationPortrait;
                    [videoProducer setOrientation: AVCaptureVideoOrientationPortrait];
                    [self.showVideoView didRotateInterfaceOrientation:UIInterfaceOrientationPortrait];
                }
            }
        }
    }
}

- (void) setSendingVideo:(BOOL)sendingVideo_ {
    sendingVideo = sendingVideo_;
    if (self.showVideoView) {
        self.showVideoView.videoSend = sendingVideo_;
    }
}

- (void) TimerVP8BitrateChange:(NSTimer*)timer {
    static int prev_bitrate = 0;
    int bitrate = rtmp_manager_get_current_vp8_bitrate([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]);
    
    if (bitrate == prev_bitrate) {
        return;
    }
    
    prev_bitrate = bitrate;
    
    if (bitrate < 0) {
        [self.showVideoView SetNetworkState:NetworkQualityState_1];
    } else {
        if (bitrate < 160) {
            [self.showVideoView SetNetworkState:NetworkQualityState_2];
        } else {
            if (bitrate < 320) {
                [self.showVideoView SetNetworkState:NetworkQualityState_3];
            } else {
                if (bitrate < 500) {
                    [self.showVideoView SetNetworkState:NetworkQualityState_4];
                } else {
                    [self.showVideoView SetNetworkState:NetworkQualityState_5];
                }
            }
        }
    }
}

- (void) SetDownScale:(BOOL) bDownScale{
    [self->videoProducer SetDownScale:bDownScale];
}

@end
