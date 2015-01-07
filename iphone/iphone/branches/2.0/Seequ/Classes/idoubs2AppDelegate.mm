// TODO: JSC - https://github.com/chrisballinger/FFmpeg-iOS

#import "idoubs2AppDelegate.h"
#import "SeequActivityViewController.h"
#import "AviaryViewController.h"
#import "AviaryPickerController.h"
#import "MediaSessionMgr.h"
#import "SeequVideoRecorerViewController.h"
#if (XMPP_ON==1)
#import "XMPPManager.h"
#else
#import "RTMPChatManager.h"
#endif //(XMPP_ON==1)
#import "ChatManager.h"
#import "Common.h"
#include "TBI_thread.h"
#import "CJSONDeserializer.h"
#import <malloc/malloc.h>
#import <objc/runtime.h>
#include "rtmpmanager.h"
#include <AudioToolbox/AudioToolbox.h>
//#include "TBI_rsa.h"
#include "TBI_base64.h"
#include "RSLogging.h"
#import "SeequTakesViewController.h"
#import "ActivityStorage.h"
#import "MessageCoreDataManager.h"

//#import "NetworkClock.h"

#define XMPP_ENTER_BACKGROUND_SIGNOUT_TIME  60
#define PING_CHECKING_TIMEOUT               120000 //msec
#define RECONNECT_CALL_TIME_OUT 60
#define START_RECONNECT_CALL_TIME_OUT 12

#define COM_SEEQU_SEEQU_APPID @"9f30399fc572432ba0c6fcbe54f60ed4"
#define COM_SEEQU_DEVELOPMENT_APPID @"7d9b1627e70bee881701f98959f53846"
//#define SIP_SERVER @"10.20.0.22"

//#define SIP_SERVER @"hawkstream.com"
//#define SIP_SERVER @"10.10.50.25"



#pragma mark sip callback events implementation -------------------------

@interface idoubs2AppDelegate()
{
    dispatch_block_t loop;
    dispatch_source_t _timer;
}
@end

@interface idoubs2AppDelegate(SipCallbackEvents)
-(void) onNetworkEvent:(NSNotification*)notification;
@end

@interface idoubs2AppDelegate(RTMPCallbackEvents)
-(void) onRTMPEvent:(NSNotification*)notification;
-(void) onRTMPEventOnMainThread:(NSNotification*)notification;
@end

@implementation idoubs2AppDelegate(SipCallbackEvents)

void* taskRunWait(void* param)
{
    idoubs2AppDelegate* self = (__bridge idoubs2AppDelegate*)param;
    int n = 30;
    self->hasNewNetEvent = NO;
//    RSLog(@"[SYSTEM][NETWORK CHANGE] Started network change task !!!");
    while (n-- && !self->hasNewNetEvent)
    {
        usleep(100000);
    }
    if(!self->hasNewNetEvent)
    {
        self->registerCommand = YES;
        self->isNetworkChanged = NO;
//        RSLog(@"[SYSTEM][NETWORK CHANGE] Network change active task complite. Starting registration.");
    }
//    else
//        RSLog(@"[SYSTEM][NETWORK CHANGE] New network change event raised. Canceling active task !!!");
    return 0;
}

- (void) notReachable {
//    RSLog(@"[SYSTEM][NETWORK CHANGE] Network change : NO CONNECTION!!!");
}
 
-(void) startNetworkChange:(NetworkStatus)status {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(notReachable) object:nil];
    bIsNetworkReachable = TRUE;
    isNetworkChanged = NO;
    if(registerCommand == NO)
    {
        hasNewNetEvent = YES;
        if(status == ReachableViaWiFi && status == lastNetStatus && ![self IsIPAddressChanged])
            return;
        if(!taskRunWaitHandle || !TBI_thread_join(&taskRunWaitHandle))
        {
            isNetworkChanged = YES;
            TBI_thread_create(&taskRunWaitHandle, taskRunWait, (__bridge void*)self);
        }
    }
    lastNetStatus = status;
}

//== Network events == //
-(void) onNetworkEvent:(NSNotification*)anotification {
	NetworkStatus internetStatus = [internetReach currentReachabilityStatus];
        BOOL isInCall=[[idoubs2AppDelegate sharedInstance].videoService isInCall];
        switch (internetStatus)
    {
		case NotReachable:
        {
//            RSLog(@"[SYSTEM][NETWORK CHANGE] : NotReachable");
            bIsNetworkReachable = FALSE;
            registerCommand = NO;
            [self performSelector:@selector(notReachable) withObject:nil afterDelay:10];

            break;
		}
		case ReachableViaWiFi:{
                        if (lastNetStatus==ReachableViaWWAN && isInCall) {
                              self.isChangeFrom3GToWIFI=YES;
                        }else{
                              self.isChangeFrom3GToWIFI=NO;
                        }
//            RSLog(@"[SYSTEM][NETWORK CHANGE] : ReachableViaWiFi");
            [self startNetworkChange:internetStatus];
        }
			break;
        case ReachableViaWWAN: {
//            RSLog(@"[SYSTEM][NETWORK CHANGE] : ReachableViaWWAN");
            [self startNetworkChange:internetStatus];
			break;
		}
    }
}

-(void) onHostEvent:(NSNotification*)anotification {
    Reachability *test = [anotification object];
    [test isReachable]
    RSLog(@"[SYSTEM][NETWORK CHANGE] IsNetworkReachable - %i", [test isReachable]);
}

@end

@implementation idoubs2AppDelegate(RTMPCallbackEvents)

-(void) onRTMPEvent:(NSNotification*)notification {
    NSDictionary *userInfo = notification.object;
    
    RTMP_EVENT_TYPE rtmp_call_event = (RTMP_EVENT_TYPE)[[userInfo objectForKey:@"rtmp_call_event"] intValue];
    NSString* callNumber = [userInfo objectForKey: @"callNumber"];
    int client_type = [[userInfo objectForKey:@"client_type"] intValue];
    
    if (rtmp_call_event == RTMP_STATUS_LOCAL_CONNECTION_CORRUPTED) {
        registerCommand = YES;
    }
    
    LAST_RTMP_EVENT_TYPE = rtmp_call_event;
    if (rtmp_call_event == RTMP_CALL_EVENT_TYPE_INCOMING) {
        recive_call_number = [callNumber stringByReplacingOccurrencesOfString:@"sip:" withString:@""];
        recive_call_number = [recive_call_number stringByReplacingOccurrencesOfString:@"@sip.protime.tv" withString:@""];
        
        if (recive_call_number.length > 7) {
            recive_call_number = [recive_call_number substringToIndex:8];
        }
        
        if (recive_call_number.length > callNumber.length) {
            recive_call_number = [recive_call_number substringToIndex:callNumber.length];
        }
        
        recive_call_state = [userInfo objectForKey: @"media"];
        if (client_type == 0) {
            flash_message = [userInfo objectForKey: @"FlashMessage"];
        } else {
            flash_message = @"";
        }
    }

    [self performSelectorOnMainThread:@selector(onRTMPEventOnMainThread:)
                           withObject:notification
                        waitUntilDone:NO];

    return;
}

- (void) onProximityStateChanged:(NSNotification*)notification{
    if([idoubs2AppDelegate sharedInstance] && [idoubs2AppDelegate sharedInstance].videoService)
        [[idoubs2AppDelegate sharedInstance].videoService onProximityStateChanged:notification];
}

-(void) onRTMPEventOnMainThread:(NSNotification*)notification {
    
//    int randomValue = rand();
//    NSLog(@"start -------- %d" ,randomValue);
    
    NSDictionary *userInfo = notification.object;
    RTMP_EVENT_TYPE rtmp_call_event = (RTMP_EVENT_TYPE)[[userInfo objectForKey:@"rtmp_call_event"] intValue];
    
    switch (rtmp_call_event)
    {
        case RTMP_EVENT_CONNECTED:
            RSLogRTMP(@"[EVENT] : RTMP_EVENT_CONNECTED");
#if (RTMP_WITHOUT_HANDSHAKE == 0)
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autologin"]) {
                NSString *username = [[Common sharedCommon] SeequID];
                NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"pass"];
                
                rtmp_manager_send_register([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager],
//                                           (char*)[@"192.168.0.10" UTF8String],
                                           (char*)[[Common getBaseSIPLink] UTF8String],
                                           (char*)[username UTF8String],
                                           (char*)[password UTF8String]);
            }
#endif //RTMP_WITHOUT_HANDSHAKE
            break;
        case RTMP_REG_EVENT_TYPE_REGISTRATION_SUCCESS:
        {
            RSLogRTMP(@"[EVENT] : RTMP_REG_EVENT_TYPE_REGISTRATION_SUCCESS");
            if (registerCommand == YES)
            {
                registerCommand = NO;
                bIsReceivedRegResponse = YES;
            }
            
            
           // if (([[idoubs2AppDelegate sharedInstance].videoService isInCall] || [[idoubs2AppDelegate sharedInstance].videoService.outgoingCallView superview]))
           //     rtmp_manager_restart_media(manager);
            //[idoubs2AppDelegate  RTMP_Call_To:@"62887002" Call_Type:@"video"];
            rtmp_manager_set_appstate(manager, ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground));
            ///@todo  levon  re-join groups
            NSArray* arr = [[MessageCoreDataManager sharedManager] getAllValidGroups];
            NSLog(@"Array  for re-join :\n %@",arr);
            [[RTMPChatManager sharedRTMPManager] joinGroups:arr];
            [[RTMPChatManager sharedRTMPManager] startResend];
            
        }
            break;

        case RTMP_REG_EVENT_TYPE_UNREGISTRATION_SUCCESS:
        case RTMP_REG_EVENT_TYPE_REGISTRATION_FAILURE: {
            RSLogRTMP(@"[EVENT] : RTMP_REG_EVENT_TYPE_UNREGISTRATION_SUCCESS or RTMP_REG_EVENT_TYPE_REGISTRATION_FAILURE");
            registerCommand = YES;
            bIsReceivedRegResponse = YES;
            [[RTMPChatManager sharedRTMPManager] stopResend];
            NSString* messageType = [userInfo objectForKey: @"messageType"];
            if (rtmp_call_event == RTMP_REG_EVENT_TYPE_REGISTRATION_FAILURE && [messageType isEqualToString:@"401 Unauthorized"]) {
                
                UILocalNotification* localNotif = [[UILocalNotification alloc] init];
                if (localNotif) {
                    
                    localNotif.alertAction = @"Launch";
                    localNotif.alertBody = @"Seequ receive Event- 401 Unauthorized ";
                    localNotif.soundName = @"default";
                    localNotif.repeatInterval = 0;
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
                }
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"autologin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
            break;
        case RTMP_EVENT_DISCONNECTED: {
            RSLogRTMP(@"[EVENT] : RTMP_EVENT_DISCONNECTED");
            registerCommand = YES;
//            if ([self.videoService isInCall]) {
//                NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:RTMP_CALL_EVENT_TYPE_CLOSED], @"rtmp_call_event", nil];
//                [self.videoService onRTMPEvent:userInfo];
//            }
        }
            break;
        case RTMP_CALL_EVENT_TYPE_INCOMING: {
            
            
            
            RSLogRTMP(@"[EVENT] : RTMP_CALL_EVENT_TYPE_INCOMING");
            [self.soundService vibrate];
            [self performSelectorOnMainThread:@selector(ClosePreperViewController) withObject:nil waitUntilDone:YES];
            
            int client_type = [[userInfo objectForKey:@"client_type"] intValue];
            NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:recive_call_number, @"number",
                                      [NSNumber numberWithInt:rtmp_call_event], @"rtmp_call_event",
                                      recive_call_state, @"CallState",
                                      [NSNumber numberWithInt:client_type], @"client_type",
                                      flash_message, @"flash_message",
                                      nil];
            
            NSLog(@"recive_call_state: %@", recive_call_state);
            [[idoubs2AppDelegate sharedInstance].videoService onRTMPEvent:userInfo];
        }
            break;
        case RTMP_CALL_EVENT_TYPE_REQUESTTIMEOUT:
        case RTMP_CALL_EVENT_TYPE_CLOSED:
        case RTMP_CALL_EVENT_TYPE_CANCELED:
        case RTMP_CALL_EVENT_TYPE_RINGING:
        case RTMP_CALL_EVENT_TYPE_LOCATING:
        case RTMP_CALL_EVENT_TYPE_FORBIDDEN:
        case RTMP_CALL_EVENT_TYPE_NOT_REACHABLE:
        case RTMP_CALL_EVENT_TYPE_ACCEPTED:
        case RTMP_CALL_EVENT_TYPE_DECLINE:
        case RTMP_CALL_EVENT_TYPE_FAILED:
        case RTMP_CALL_EVENT_TYPE_REQUEST_TERMINATE:
        case RTMP_CALL_EVENT_TYPE_NOT_FOUND:
        case RTMP_CALL_EVENT_TYPE_BUSY_HERE:
        case RTMP_CALL_EVENT_TYPE_NOTENOUGHCREDIT:
        case RTMP_CALL_EVENT_TYPE_NOT_ACCEPTABLE_HERE:
        case RTMP_CALL_EVENT_TYPE_TEMPORARILY_UNAVAILABLE:
        case RTMP_CALL_EVENT_TYPE_REMOTE_HOLD:
        case RTMP_CALL_EVENT_TYPE_REMOTE_UNHOLD:
        {
            NSNumber* call_type = [userInfo objectForKey:@"call_type"];
            NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:rtmp_call_event], @"rtmp_call_event", call_type, @"call_type", nil];
            [[idoubs2AppDelegate sharedInstance].videoService onRTMPEvent:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Recent" object:nil];
        }
            break;
        case RTMP_CALL_EVENT_TYPE_STATUS: {
//            NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:test.rtmp_call_event], @"rtmp_call_event",
//                                      [NSString stringWithUTF8String:test.messageType], @"jsonData", nil];
//            //                [NSData dataWithBytes:test.messageType length:sizeof(test.messageType)]
//            [[idoubs2AppDelegate sharedInstance].videoCallController onRTMPEvent:userInfo];
        }
            break;
        case RTMP_STATUS_EVENT_RECEIVE_RECONNECT: {
            NSLog(@"[EVENT] : RTMP_STATUS_EVENT_RECEIVE_RECONNECT");
            if ([self.videoService isInCall]) {
                [self.videoService.showVideoView ShowReconnectView:YES Message:@"Call reconnected. \n Starting the call..."];

                [NSObject cancelPreviousPerformRequestsWithTarget:self.videoService.showVideoView selector:@selector(StartTimerForEndCall) object:nil];
//                [self.videoService.showVideoView CancelTimerForEndCall];
//                [self.videoService.showVideoView StartTimerReconnectForEndCall];
//                [self.videoService.showVideoView performSelector:@selector(StartTimerReconnectForEndCall) withObject:nil afterDelay:START_RECONNECT_CALL_TIME_OUT];
            }
        }
            break;
        case RTMP_STATUS_EVENT_SEND_RECONNECT: {
            NSLog(@"[EVENT] : RTMP_STATUS_EVENT_SEND_RECONNECT");
            if ([self.videoService isInCall]) {

                [NSObject cancelPreviousPerformRequestsWithTarget:self.videoService.showVideoView selector:@selector(StartTimerForEndCall) object:nil];
//                [self.videoService.showVideoView CancelTimerForEndCall];
//                [self.videoService.showVideoView StartTimerReconnectForEndCall];
                [self.videoService.showVideoView performSelector:@selector(StartTimerReconnectForEndCall) withObject:nil afterDelay:START_RECONNECT_CALL_TIME_OUT];
            }
        }
            break;
        case RTMP_STATUS_AUDIO_RECONNECTED:
        case RTMP_STATUS_VIDEO_RECONNECTED: {
            NSLog(@"[EVENT] : RTMP_STATUS_AUDIO_RECONNECTED");
            if ([self.videoService isInCall]) {
                [self.videoService.showVideoView ShowReconnectView:NO Message:@""];
                [NSObject cancelPreviousPerformRequestsWithTarget:self.videoService.showVideoView selector:@selector(StartTimerForEndCall) object:nil];
//                [NSObject cancelPreviousPerformRequestsWithTarget:self.videoService.showVideoView selector:@selector(StartTimerReconnectForEndCall) object:nil];
//                [self.videoService.showVideoView CancelTimerForEndCall];
            }
        }
            break;
        case RTMP_STATUS_NO_AUDIO: {
//            [self.videoService.showVideoView ShowReconnectView:YES Message:@""];
        }
            break;
        case RTMP_STATUS_LOCAL_CONNECTION_ALIVE: {
            RSLogRTMP(@"[EVENT] : RTMP_STATUS_AUDIO_RECONNECTED");
            if ([self.videoService isInCall]) {
                [self.videoService.showVideoView ShowReconnectView:YES Message:@"Remote party connection problem. \n Waiting for call reconnection..."];
                [self.videoService.showVideoView performSelector:@selector(StartTimerForEndCall) withObject:nil afterDelay:RECONNECT_CALL_TIME_OUT];
//                [self.videoService.showVideoView StartTimerForEndCall];
            }
        }
            break;
        case RTMP_STATUS_LOCAL_CONNECTION_CORRUPTED: {
            RSLogRTMP(@"[EVENT] : RTMP_STATUS_LOCAL_CONNECTION_CORRUPTED");
            if ([self.videoService isInCall]) {
                [self.videoService.showVideoView ShowReconnectView:YES Message:@"Network connection problem. \n Trying to reconnect the call..."];
                [self.videoService.showVideoView performSelector:@selector(StartTimerForEndCall) withObject:nil afterDelay:RECONNECT_CALL_TIME_OUT];
//                [self.videoService.showVideoView StartTimerForEndCall];
            }
        }
            break;
            
        case RTMP_STATUS_EVENT_INCREASE:
        case RTMP_STATUS_EVENT_DECREASE:
        {
            int bitrate = rtmp_manager_get_bitrate([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]);
            rtmp_manager_changechanksize([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager], (bitrate > 140));
            [self.videoService SetDownScale: (bitrate <= 140)];
            break;
        }
        case RTMP_EVENT_TYPE_UNKNOWN: {
        }
            break;
                    
        case RTMP_STATUS_FORCE_LOGOUT:{
            NSLog(@"JSC: RTMP_STATUS_FORCE_LOGOUT");
                [self logOutSeequ:^(BOOL completion) {
                        if (completion) {
                                [self ShowDefaultMessageWithText:@"You have logged in on another device"];
                        }
                }];
            }
        default:
            break;

    }
//    NSLog(@"end -------- %d" ,randomValue);
    //    }
}


@end

#pragma mark Default implementation -------------------------

@implementation idoubs2AppDelegate



@synthesize window;
@synthesize tabBarController;
@synthesize preparForCallAnswerViewController;
@synthesize videoService;
@synthesize soundService;
@synthesize browser;
@synthesize contacts;
@synthesize messages;
@synthesize recent;
@synthesize settings;
@synthesize takes;
@synthesize seequPresentation;
@synthesize arrayPushes;
@synthesize isFromRemotNotification;
@synthesize messageFromNotification;
@synthesize messageFromLocalNotification;
@synthesize messageNavigationTitle;
@synthesize messageFromActivity;
@synthesize messageFromActivityImage;
@synthesize messageFromActivityVideoPath;
@synthesize messageFromActivityTo;
@synthesize messageFromActivityText;
@synthesize pushMessageUserName;
@synthesize urlReq;
@synthesize ReplyWithMessageNumber;
@synthesize DeviceToken;
@synthesize audio;
@synthesize AudioUnitPlugin_;
@synthesize xmppRoster;
@synthesize callType;
@synthesize refreshingTab;
@synthesize gsm_callState;
@synthesize sleepTimer = _sleepTimer;
@synthesize dropboxClient=_dropboxClient;

#pragma mark -
#pragma mark Application lifecycle

-(BOOL) deletePathIfExsict:(NSString*)path{
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    
    if (data.length) {
        return 0;
    }
    return 1;
}

-(NSString*) getTestVideoPath176x144{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    return [NSString stringWithFormat:@"%@/test----1.mp4", documentsDir];
}
-(NSString*) getTestVideoPath352x288{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    return [NSString stringWithFormat:@"%@/test----2.mp4", documentsDir];
}

- (void) captureVideo {
     @autoreleasepool {
         if ([self deletePathIfExsict:[self getTestVideoPath176x144]]) {
             [NSThread sleepForTimeInterval:1.8];
         }
         
         [self calculateSPSxPPS:SIZE_176_X_144];
         if([self deletePathIfExsict:[self getTestVideoPath352x288]])
         {
             [NSThread sleepForTimeInterval:0.5];
             [controller StartVideoCaptureWithPath352x288];
             [NSThread sleepForTimeInterval:1.8];
         }
         [NSThread sleepForTimeInterval:0.5];
         [self calculateSPSxPPS:SIZE_352_X_288];
     }
}

- (void)calculateSPSxPPS:(int)number {
    if ([controller StopVideoCaptureImedently]) {
        NSString *video_file_path;
        
        if(number==SIZE_176_X_144)
            video_file_path =  [self getTestVideoPath176x144];
        else
            video_file_path =  [self getTestVideoPath352x288];
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:video_file_path];
        [NSThread sleepForTimeInterval:0.5];
        if (data.length) {
            const char *path = [video_file_path UTF8String];
            if (rtmp_manager_get_video_settings([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager], path,number) == -1) {
                if ([[NSFileManager defaultManager] removeItemAtPath:video_file_path error:nil]) {
                    if (number == SIZE_176_X_144) {
                        [controller StartVideoCaptureWithPath176x144];
                    }
                    
                    [self captureVideo];
                }
            }
        } else {
            NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir = [documentPaths objectAtIndex:0];
            NSString *video_file_path =  [NSString stringWithFormat:@"%@/test.mp4", documentsDir];
            NSData *data = [[NSData alloc] initWithContentsOfFile:video_file_path];
            if (data.length) {
                const char *path = [video_file_path UTF8String];
                rtmp_manager_get_video_settings([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager], path,number);
            }
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window.backgroundColor=[UIColor blackColor];
    [UIApplication sharedApplication].statusBarStyle=UIStatusBarStyleLightContent;
    self.isRosterReceived = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstLogin"];
 //   SeequTakesViewController *control = [[SeequTakesViewController alloc] initWithNibName: @"SeequTakesViewController" bundle: nil];
    SeequVideoRecorerViewController*  control = [[SeequVideoRecorerViewController alloc] initWithType:SeequRecorderTypeNone];
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController: control];
    self.takes = navControl;
    
    [AFPhotoEditorController setAPIKey:@"0c84a8f08c42520f" secret:@"c5bcd27647666e0b"];
     NSString *appId;
     
        if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.Seequ.Development"]){
                appId=COM_SEEQU_DEVELOPMENT_APPID;
        } else{
                appId=COM_SEEQU_SEEQU_APPID;
        }
        
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:appId
                                                           delegate:self];
    [BITHockeyManager sharedHockeyManager].crashManager.crashManagerStatus = BITCrashManagerStatusAlwaysAsk;
    
    [[BITHockeyManager sharedHockeyManager] setDisableCrashManager:NO];
    
     [[BITHockeyManager sharedHockeyManager] setDebugLogEnabled: YES];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
   
    TBI_debug_set_system_version([[[UIDevice currentDevice] systemVersion] UTF8String]);
    
// JSC
//    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                         [UIColor whiteColor],UITextAttributeTextColor,
//                                                          [UIColor blackColor], UITextAttributeTextShadowColor,
//                                                          [NSValue valueWithUIOffset:UIOffsetMake(0, -0.7)], UITextAttributeTextShadowOffset,
//                                                          [UIFont fontWithName:@"Helvetica-Bold" size:20.0], UITextAttributeFont, nil]];

    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowOffset = CGSizeMake(0, -0.7);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor],NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"Helvetica-Bold" size:20.0], NSFontAttributeName, nil]];
    
    DBSession *dbSession = [[DBSession alloc]
                                initWithAppKey:@"158momrhiiieiwc"
                                appSecret:@"8x2rdwgbs4e7g6p"
                                root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];
    
        
        [self registerForCalls];
    
    self.videoService = [[VideoService alloc] init];
    self.soundService = [[TBISoundService alloc] init];
    
    registerCommand = YES;
    taskRunWaitHandle = NULL;
    isNetworkChanged = NO;
    self.showProfile = YES;
    self.refreshingTab = NO;

    controller = [[TBIVideoProducer alloc] init];
    
// JSC
//    if([self deletePathIfExsict:[self getTestVideoPath176x144]]) {
//        [controller StartVideoCaptureWithPath176x144];
//    }
//    [NSThread detachNewThreadSelector:@selector(captureVideo) toTarget:self withObject:nil];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    NSDictionary *dict1 = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    NSString *status = [dict1 objectForKey:@"status"];
    
    self.messageFromNotification = NO;
    self.messageFromLocalNotification = NO;
    self.isFromRemotNotification = NO;
    
    if (status) {
        if ([status isEqualToString:@"Message"]) {
            self.messageFromNotification = YES;
            self.pushMessageUserName = [dict1 objectForKey:@"from"];
            NSDictionary *aps = [dict1 objectForKey:@"aps"];
            NSDictionary *alert = [aps objectForKey:@"alert"];
            NSString *body = [alert objectForKey:@"body"];
            NSRange range = [body rangeOfString:@" send you an image"];
            NSString*  str = nil;
            BOOL flag = YES;
            if (range.location != NSNotFound) {
                str = [body substringToIndex:range.location];
                flag = NO;
            }
            range = [body rangeOfString:@" send you a video"];
            if (range.location != NSNotFound) {
                str = [body substringToIndex:range.location];
                flag = NO;
            }
            if (flag) {
                NSArray *pushText=[body componentsSeparatedByString:@":"];
                NSAssert(pushText.count, @"must have at once  1 ':' symbol");
                self.messageNavigationTitle =[pushText objectAtIndex:0];
                //[body stringByReplacingOccurrencesOfString:@"sent you a message." withString:@""];

            } else {
                self.messageNavigationTitle =str;
            }
        } else {
            NSDictionary *dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:[dict1 objectForKey:@"from"], @"SEEQUID", @"REFRESH", @"type", nil];
            [Common postNotificationWithName:@"REQUEST" object:dictPostNotification];
        }
        
    }
    
	NSLog(@"Registering for push notifications...");
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *theSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        NSLog(@"registerUserNotificationSettings:%@", theSettings);        
        [[UIApplication sharedApplication] registerUserNotificationSettings:theSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
#endif
    
	// add observers
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProximityStateChanged:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkEvent:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHostEvent:) name:kHostReachabilityNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRTMPEvent:) name:@"Registration_is_ready" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMissedEvent:) name:@"AddedMissed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAuthenticationProblem:) name:@"AuthenticationProblem" object:nil];
    
	// add observers
    
	hostReach = [Reachability reachabilityWithHostName:HOST_NAME_REACHABALITY ];
	[hostReach startNotifier];
	
    internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];
    
	// Set the tab bar controller as the window's root view controller and display.
//    [self.window addSubview:self.tabBarController.view];

    NSMutableArray *controllers = [self CreateTabBarControllers];
    self.tabBarController = [[TabBarVCDemoViewController alloc] initWithControllers:controllers];
    self.tabBarController.TBIdelegate = self;
    self.tabBarController.delegate = self;
	// Set the tab bar controller as the window's root view controller and display.
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
	
//	multitaskingSupported = [[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)] && [[UIDevice currentDevice] isMultitaskingSupported];
//	JSC: backgroundTask = UIBackgroundTaskInvalid;

//	if(multitaskingSupported){
//		NSLog(@"Multitasking IS supported");
//	}
    
    NSString* str = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultTabBar"];
    if (!str) {
        self.tabBarController.selectedIndex = 2;
    } else {
        int d  = [str intValue];
        self.tabBarController.selectedIndex = d;
    }
    
    
    if ([status isEqualToString:@"Ringback"] || [status isEqualToString:@"Connection"]) {
        self.tabBarController.selectedIndex = 3;
    }
    
    AudioUnitPlugin_= [[AudioUnitPlugin alloc] init] ;

    [self startTimer];

    BOOL aut_problem = [[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"];
    
    NSLog(@"JSC - aut_problem: %@", (aut_problem ? @"YES" : @"NO"));
    
      if (aut_problem) {
        NSString * retValu= [Common LoginWithSeequID:[[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_IMPI"]
                                      Password:[[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_PASSWORD"]];
        
         BOOL isAuth =retValu?NO:YES;
        
        if (!isAuth) {
            [self ShowRegisterView];
        } else {
            [[NSUserDefaults standardUserDefaults] synchronize];
            
             NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
             NSString *error_message = [Common RegisterPushNotificationWithDeviceToken:deviceToken registerForce:NO];
                if ([error_message isEqualToString:@"Dublicate User"]) {
                        [self duplicateAccount];
                }else
            [NSThread detachNewThreadSelector:@selector(PreparingAccount)
                                     toTarget:self
                                   withObject:nil];
        }
    } else {
        BOOL isRegistered = [[NSUserDefaults standardUserDefaults] boolForKey:@"autologin"];
        
        if (!isRegistered) {
            NSLog(@" is autologin -%@",isRegistered?@"YES":@"NO");
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"company"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"title"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"status"];
            [self.tabBarController presentViewController:self.seequPresentation animated:NO completion:nil];
        } else {
                
            NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
            NSString *error_message = [Common RegisterPushNotificationWithDeviceToken:deviceToken registerForce:NO];
            if ([error_message isEqualToString:@"Dublicate User"]) {
                
                        [self duplicateAccount];
            }else{
                 NSString *retValu= [Common LoginWithSeequID:[[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_IMPI"]
                                                           Password:[[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_PASSWORD"]];
                BOOL isAuth =retValu?NO:YES;
                        
                        if (!isAuth) {
                                [self ShowRegisterView];
                        } else {
                                
                                //                SeequActivityViewController *activityViewController = [self.recent.viewControllers objectAtIndex:0];
                                //                [activityViewController SetRequestArray];
                                //                [activityViewController SetRecentArray];
                                
                                [NSThread detachNewThreadSelector:@selector(PreparingAccount)
                                                         toTarget:self
                                                       withObject:nil];
                        }
                }
        }
    }
    self.tabBarController.tabBarView.backgroundColor=[UIColor clearColor];
    contactBadgView = [[TBIDefaultBadgView alloc] init];
    contactBadgView.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
  
    [contactBadgView setDelegate:self];
    [self SetContactTabBadgValue:@""];
    [self.tabBarController.tabBarView addSubview:contactBadgView];
    
    recentBadgView = [[TBIDefaultBadgView alloc] init];
    recentBadgView.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
    [recentBadgView setDelegate:self];
    [self SetRecentTabBadgValue:@""];
    [self.tabBarController.tabBarView addSubview:recentBadgView];
    
    messageBadgView = [[TBIDefaultBadgView alloc] init];
    messageBadgView.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
    [messageBadgView setDelegate:self];
    [self SetMessageTabBadgValue:@""];
    [self.tabBarController.tabBarView addSubview:messageBadgView];
    
    self.arrayPushes = [[NSMutableArray alloc] init];
    
    if ([idoubs2AppDelegate sharedInstance].messageFromNotification) {
        [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 1;
    }
    
    [self creatMessagesBadge];
    
#if (XMPP_ON==0)
    [idoubs2AppDelegate getChatManager];
#endif //(XMPP_ON==0)
    [Common getUserBalance:^(NSMutableDictionary *dict) {
        [[ContactStorage sharedInstance] getUserInfoBySeequId:[Common sharedCommon ].contactObject.SeequID];
        NSLog(@"%@", dict);
    }];

    return YES;
}

- (void) ShowRegisterView {
    if ([self.tabBarController.presentedViewController isKindOfClass:[RegisteringViewController class]]) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"company"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"title"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"status"];
    [[NSUserDefaults standardUserDefaults] setBool:NO    forKey:@"autologin"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autorisation_problem"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ."
                                                    message:@"Account seems to be changed. \n Please login again."
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    
    RegisteringViewController *registeringViewController = [[RegisteringViewController alloc] initWithNibName:@"RegisteringViewController" bundle:nil];
    registeringViewController.lockEmailField = YES;
    [self.tabBarController  presentViewController:registeringViewController animated:NO completion:nil];
}
-(void)duplicateAccount{
//    NSLog(@"Duplicate Account");
        [self logOutSeequ:^(BOOL completion) {
                if (completion) {
                    [self ShowDefaultMessageWithText:@"You have logged in on another device."];
                }
        }];
        
}

// This will be called only after confirming your settings
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
{
    NSLog(@"JSC: didRegisterUserNotificationSettings");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // There is also a built in method to find out if the user has appropriate settings, you might want to use that instead if you just want to know what the setting is
    [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"alerts_allowed"];
}

- (NSMutableArray*) CreateTabBarControllers {
    NSMutableArray* viewControllers = [NSMutableArray arrayWithCapacity:5];
    
	[viewControllers addObject:self.contacts];
    [viewControllers addObject:self.messages];
    [viewControllers addObject:self.browser];
    [viewControllers addObject:self.recent];
    //[viewControllers addObject:self.settings];
    [viewControllers addObject:self.takes];
    
    return viewControllers;
}

- (void) creatMessagesBadge {
    NSArray *arrayContactsMessageBadge_ = [[NSUserDefaults standardUserDefaults] objectForKey:@"contactsMessageBadge"];
    NSMutableArray *arrayContactsMessageBadge = [NSMutableArray arrayWithArray:arrayContactsMessageBadge_];
    if (arrayContactsMessageBadge) {
        for (NSDictionary *dict in arrayContactsMessageBadge) {
            int missCount = [[dict objectForKey:@"badge"] integerValue];
            [Common SetMissedWithSeequID:[dict objectForKey:@"from"] Type:2 MissedCount:missCount];
        }
        int missedObject = [Common GetMissedMessages];
        if (missedObject !=0) {
            [self SetMessageTabBadgValue:[NSString stringWithFormat:@"%d", missedObject]];
        }
    }
}

-(void)didSelectBadgView:(TBIDefaultBadgView*)badg {
    if (badg == contactBadgView) {
        [self.tabBarController setSelectedIndex:0];
        return;
    }
    
    if (badg == recentBadgView) {
        [self.tabBarController setSelectedIndex:3];
        return;
    }
    
    if (badg == messageBadgView) {
        [self.tabBarController setSelectedIndex:2];
        return;
    }
}
-(void)RegisterCommand:(BOOL)commmand{
        registerCommand=commmand;
}
- (void) PreparingAccount {
    [Common GetProfileInfoByPTID:[[Common sharedCommon] SeequID] withActivityBadgCount:YES];
    SeequActivityViewController *activityViewController = [self.recent.viewControllers objectAtIndex:0];
    [activityViewController refresh];
}

- (void) UpdateContactTabBadgValue {
    int missedCounts = [Common GetMissedMessages];
    [self SetContactTabBadgValue:[NSString stringWithFormat:@"%d", missedCounts]];
}

- (void) UpdateRecentTabBadgValue {
    int missedCounts = [Common GetAllMissedsCalls];
    [self SetRecentTabBadgValue:[NSString stringWithFormat:@"%d", missedCounts]];
}

- (void) SetContactTabBadgValue:(NSString*)value {
    if (value.intValue == 0) {
        [contactBadgView SetText:nil];
    } else {
        [contactBadgView SetText:value];
        contactBadgView.center = CGPointMake(57, 17);
    }
}

- (void) SetRecentTabBadgValue:(NSString*)value {
    NSLog(@"DEBUG: [UI] {SetRecentTabBadgValue} - %@", value);
    if (value.intValue == 0) {
        [recentBadgView SetText:nil];
    } else {
        [recentBadgView SetText:value];
        recentBadgView.center = CGPointMake(250, 17);
    }
}

- (void) SetMessageTabBadgValue:(NSString*)value {
    NSLog(@"DEBUG: [UI] {SetMessageTabBadgValue} - %@", value);
    if (value.intValue == 0) {
        [messageBadgView SetText:nil];
    } else {
        [messageBadgView SetText:value];
        [self.tabBarController.tabBarView addSubview:messageBadgView];
        messageBadgView.center = CGPointMake(121, 17);
    }
}

- (void) IncrementContactTabBadg {
    [contactBadgView IncrementBagdValue];
    contactBadgView.center = CGPointMake(57, 17);
    [self.tabBarController.tabBarView addSubview:contactBadgView];
}

- (void) IncrementRecentTabBadg {
    NSLog(@"DEBUG: [UI] {IncrementRecentTabBadg}");
    [recentBadgView IncrementBagdValue];
    recentBadgView.center = CGPointMake(250, 17);
    [self.tabBarController.tabBarView addSubview:recentBadgView];
}

- (void) IncrementMessageTabBadg {
    NSLog(@"DEBUG: [UI] {IncrementMessageTabBadg}");
    [messageBadgView IncrementBagdValue];
    messageBadgView.center = CGPointMake(121, 17);
    [self.tabBarController.tabBarView addSubview:messageBadgView];
}

- (int) GetRecentTabBadgValue {
    try {
        int value = [[recentBadgView GetValue] intValue];
        
        return value;
    } catch (NSException *exception) {
        NSLog(@"Not int value");
    }
    
    return 0;
}

- (BOOL) IsIPAddressChanged {
    NSString *address = [[Reachability localWiFiIPAddress] copy];

    if(!address && !lastIPAddress)
        return FALSE;

    if(address && lastIPAddress)
    {
        if([address isEqualToString: lastIPAddress])
            return FALSE;
    }
    
    if(address)
        lastIPAddress = [address copy];
    else
        lastIPAddress = nil;

    return TRUE;
}

- (BOOL) CheckWiFiIP {

    NSString *address = [[Reachability localWiFiIPAddress] copy];
    if(address)
    {
        if(!([address isEqualToString: lastWiFIAdress]))
        {
            if(lastWiFIAdress != NULL){
                [self onNetworkEvent:NULL];
            }

            lastWiFIAdress = [address copy];
            return true;
        }
    }
   
    return FALSE;
}


- (rtmp_manager_t*) Get_RTMP_Manager {
    return manager;
}

- (void) Set_RTMP_Manager:(rtmp_manager_t*)rtmp_manager {
    manager = rtmp_manager;
}

- (int) Restart_RTMP {
    @autoreleasepool {
        
        BOOL isRegistered = [[NSUserDefaults standardUserDefaults] boolForKey:@"autologin"];
        NSString *username = [[Common sharedCommon] SeequID];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"pass"];

        if (isRegistered && username && password) {
            
            RSLogRTMP(@"[RE-REGISTER] | RTMP re-registering");
            if (!manager) {
                NSString *udidstr;
                
                if (![[NSUserDefaults standardUserDefaults] objectForKey:@"kUDID"]) {
                    udidstr = [XMPPStream generateUUID];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:udidstr forKey:@"kUDID"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                } else {
                    udidstr = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUDID"];
                }
                
                const char *udid =[udidstr cStringUsingEncoding:[NSString defaultCStringEncoding]];
                NSString* rtmpUrl = TBI_null;
                
#if RTMP_WITHOUT_HANDSHAKE



  //              rtmpUrl = [NSString stringWithFormat:@"rtmp://192.168.0.135:1945/seequ"/*, [Common getBaseRTMPLink]*/];
        rtmpUrl = [NSString stringWithFormat:@"rtmp://uvc.protime.tv:1945/seequ"/*, [Common getBaseRTMPLink]*/];


#else
                rtmpUrl = [NSString stringWithFormat:@"rtmp://%@/seequ", [Common getBaseRTMPLink]];
#endif //RTMP_WITHOUT_HANDSHAKE

                manager = create_rtmp_manager(udid, [udidstr length],[rtmpUrl UTF8String]);

                prepare_rtmp_manager(manager, [[Common getBaseSIPLink] UTF8String], [username UTF8String], [password UTF8String]);

                if(start_rtmp_manager(manager) < 0){
                    NSLog(@"[RE-REGISTER] | RTMP re-register failed.");
                    return 0;
                }
                
                [TBIVideoConsumer sharedVideoConsumer];
                
                [[idoubs2AppDelegate sharedInstance].soundService setSpeakerEnabled: 0];
                
                return 1;
            } else {
                if(restart_rtmp_manager(manager))
                    return 1;
            }
#if XMPP_ON
            AccountEntity *accountEntity = [[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"];
            if (accountEntity) {
                XMPPStream* xmppStream = [[[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] XMPPHandler] xmppStream];
                if (accountEntity.accountState != Online || ![xmppStream isConnected]) {
                    [accountEntity goToState:Online];
                }
            }
#endif
        }
    }
   NSLog(@"[SYSTEM][RTMP-MANAGER] | Restart failed.");
    return -2;
}

-(void) signOutXmpp:(NSString*)name{
    AccountEntity *accountEntity = [[UserEntity sharedUserEntity].listOfAccounts objectForKey:name];
    if (!accountEntity) {
        return;
    }
    
    [[[[[UserEntity sharedUserEntity].listOfAccounts objectForKey:name] XMPPHandler] xmppStream] removeDelegate:self];
    
    if ([[[accountEntity XMPPHandler] xmppStream] isConnected]) {
        [accountEntity goToState:Offline];
        [[[accountEntity XMPPHandler] xmppStream] removeDelegate:self];
    }

}

#if XMPP_ON
- (void) RegisterXMPP {
    //// XMPP CHAT
    NSArray *accounts = [[UserEntity sharedUserEntity].listOfAccounts allValues];
    if ([accounts count] != 0) {
        [[accounts objectAtIndex:0] goToState:Offline];
        [[[accounts objectAtIndex:0] XMPPHandler] disconnectFromStream];
        
        [[UserEntity sharedUserEntity].listOfAccounts removeAllObjects];
    }
    
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_PASSWORD"];
    NSString *user = [NSString stringWithFormat:@"%@@im.protime.tv", [[Common sharedCommon] SeequID]];
    
    CoreUser* cUser = [[CoreUser alloc] initCoreUserWithUsername:user andPassword:password];
    CoreServer* cServer = [[CoreServer alloc] initCoreServerWithHost:@"im.protime.tv" andPort:@"5222"];
    
    AccountEntity* aEntity = [[AccountEntity alloc] initAccountWithUserCredentials:cUser
                                                                    ServerSettings:cServer
                                                                     ProxySettings:nil
                                                                      DefaultState:YES
                                                                    andAccountName:@"protime"];
    
    [[UserEntity sharedUserEntity] addAccount:aEntity];
    
    XMPPManager *xmpp_manager = [XMPPManager sharedXMPPManager];
    [[[[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] XMPPHandler] xmppStream] addDelegate:xmpp_manager];
    
    SeequActivityViewController *activityViewController = [self.recent.viewControllers objectAtIndex:0];
    
    if ([activityViewController respondsToSelector:@selector(initXMPPRoster)]) {
        [activityViewController initXMPPRoster];
    }
    
    BOOL isOnlineVisibility = [[NSUserDefaults standardUserDefaults] boolForKey:@"online"];
    if (isOnlineVisibility) {
        [aEntity goToState:Online];
    } else {
        [aEntity goToState:Away];
    }
    
    UINavigationController *nav = [self.tabBarController.viewControllers objectAtIndex:0];
    SeequContactsViewController *contactsViewController = (SeequContactsViewController*)[nav.viewControllers objectAtIndex:0];
    [contactsViewController setFetchedResultsController:nil];
    [contactsViewController fetchedResultsController];
}
#endif //XMPP_ON

- (void) onMissedEvent:(NSNotification*)notification {
    [[idoubs2AppDelegate sharedInstance] updateBadge];
}

- (void) onAuthenticationProblem:(NSNotification*)notification {
    NSLog(@"JSC: There was an authentication problem");
    if ([self.tabBarController.presentedViewController isKindOfClass:[RegisteringViewController class]]) {
        return;
    }
        if (manager) {
                rtmp_manager_send_unregister(manager);
        }
    
    [self signOut];
    
    [self ShowRegisterView];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    DeviceToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    DeviceToken = [DeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];    
    
	[[NSUserDefaults standardUserDefaults] setObject:DeviceToken forKey:@"DeviceToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError ==== %@", error.description);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");

    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    //MediaSessionMgr::SetBackgroundState(tsk_true);
}
- (int) SendRTMPRegister {
    
    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall] || [[idoubs2AppDelegate sharedInstance].videoService.outgoingCallView superview]) {
        NSString *username = [[Common sharedCommon] SeequID];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"pass"];
    
        rtmp_manager_send_register([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager],
                                                           (char*)[[Common getBaseSIPLink] UTF8String],
                                                            (char*)[username UTF8String],
                                                            (char*)[password UTF8String]);
    
    }
    return 0;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    NSLog(@"JSC: applicationDidEnterBackground");
//    _wasInBackground = YES;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"push"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateBadge];
    
    bgTask = [application beginBackgroundTaskWithName:@"backgroundTask" expirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        NSLog(@"JSC: backgroundTask %d ending...", bgTask);
        if( manager )
        {
            [[RTMPChatManager sharedRTMPManager] stopResend];
            rtmp_manager_send_unregister(manager);
            stop_rtmp_manager(manager);
            registerCommand = TRUE;
        }
        
        // iOS 8 dispatch_block_cancel(loop);
        [self cancelTimer];
        
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    if(manager) {
        rtmp_manager_set_appstate(manager, tbi_true);
    }
    
#if XMPP_ON
    [self performSelectorInBackground:@selector(signOut) withObject:nil];
#endif
    
    
//  In iOS 8 and later, voice-over-IP (VoIP) apps register for UIRemoteNotificationTypeVoIP push notifications instead of using this method. Using push notifications eliminates the need for a timeout handler to check in with the VoIP service. Instead, when a calls arrives for the user, the VoIP service sends a VoIP push notification to the user’s device. Upon receiving this notification, the device launches or wakes the app as needed so that it can handle the incoming call.
    
//  In iOS 7 and earlier, VoIP apps use this method to install a handler whose job is to maintain the app’s network connection with a VoIP server. This handler is guaranteed to be called before the specified timeout value but may be called at a slightly different time interval in order to better align execution of your handler with other system tasks, and thereby save power. Your handler has a maximum of 10 seconds to perform any needed tasks and exit. If it does not exit before time expires, the app is suspended.

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
    NSLog(@"JSC - setKeepAliveTimeout:600");
    [application setKeepAliveTimeout:600 handler:^{
        NSLog(@"JSC Ping");
    }];
#endif
    
}

- (void) signOut {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        NSLog(@"JSC: signOut");
        [self signOutXmpp:@"protime"];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"DEBUG: [Background] applicationWillEnterForeground");

    if(bgTask != UIBackgroundTaskInvalid) {
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
    
    [application clearKeepAliveTimeout];
    
    if(!manager)
    {
        registerCommand = YES;
    }
    else
    {
        rtmp_manager_set_appstate(manager, tbi_false);
    }

// iOS 8
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), loop);
    [self startTimer];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"DEBUG: applicationDidBecomeActive");
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
//    if (!_wasInBackground) return;
    
    if ([_sleepTimer isValid]) {
            [_sleepTimer invalidate];
    }
       [self.videoService.ringTimer invalidate];
    [self.soundService stopRingTone];
    
    NetworkStatus internetStatus = [internetReach currentReachabilityStatus];
    bIsNetworkReachable = (internetStatus != NotReachable);

    [NSThread detachNewThreadSelector:@selector(ResetNotificationBadgesCount) toTarget:[Common sharedCommon] withObject:nil];
    
    if (self.videoService.rtmp_call_state == RTMP_CALL_EVENT_TYPE_INCOMING) {
        [self.soundService playRingTone];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autologin"]) {
        NSArray *accounts = [[UserEntity sharedUserEntity].listOfAccounts allValues];
        if ([accounts count] != 0) {
            AccountEntity* aEntity = [accounts objectAtIndex:0];
            [aEntity goToState:Online];
        } else {
#if XMPP_ON
            [self RegisterXMPP];
#endif //XMPP_ON
        }
    }
    
    if([idoubs2AppDelegate sharedInstance].AudioUnitPlugin_.interruptionState == kAudioSessionEndInterruption){
        if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
            if(![lastGsmEvent isEqualToString: CTCallStateConnected]){
                if(manager->isHold){
                    [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ stopRecordAndPlayAudio:[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]];
                    rtmp_manager_send_unhold([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]);
                    dispatch_after(difftime(DISPATCH_TIME_NOW, 2*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ initAudioPlugin:[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]];
                        [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ startRecordAndPlayAudio];
                        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView setVideoState:VideoViewState_NORMAL Animation:NO];
                    });
                }
            }
        }
    }
//    _wasInBackground = NO;
    [self performSelectorInBackground:@selector( updateBadge) withObject:nil];
}


-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url
 sourceApplication:(NSString *)source annotation:(id)annotation {
        if ([[DBSession sharedSession] handleOpenURL:url]) {
                if ([[DBSession sharedSession] isLinked]) {
                        NSLog(@"App linked successfully!");
                        // At this point you can start making API calls
                }
                return YES;
        }
        // Add whatever other url handling code your app requires here
        return NO;
}


 -(int) getMissedRecentCount{
     int count = 0;
         count=[[ActivityStorage sharedInstance] getMissedRequestCount];
         
  
     count +=[[ActivityStorage sharedInstance] getMissedCallCount];
     return count;
 }

-(int) updateApplicationBadgeCount{
    int count = [Common GetMissedMessages];
    
    count +=[self getMissedRecentCount];
    
    

   // [Common ge]
    [UIApplication sharedApplication].applicationIconBadgeNumber = count;
    return count;
}

-(void) updateBadge{
    
    int messageBadgeNumber=[Common GetMissedMessages];
    int recentBadgeNumber=[self getMissedRecentCount];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self SetMessageTabBadgValue:[NSString stringWithFormat:@"%d", messageBadgeNumber]];
        [self SetRecentTabBadgValue:[NSString stringWithFormat:@"%d", recentBadgeNumber]];
        [UIApplication sharedApplication].applicationIconBadgeNumber = messageBadgeNumber+ recentBadgeNumber;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [Common UpdateBadgeNumber:[UIApplication sharedApplication].applicationIconBadgeNumber];
        });
        
    });
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (manager) {
        if(rtmp_manager_send_unregister(manager)){
            NSLog(@"JSC: Finished unregistering RTMP Manager");
        };
    }
}

- (void) registerForCalls {
    
    [idoubs2AppDelegate sharedInstance].callCenter = [[CTCallCenter alloc] init];
    NSLog(@"registering for call center events");
    [[idoubs2AppDelegate sharedInstance].callCenter setCallEventHandler: ^(CTCall* call) {
        
        if ([call.callState isEqualToString: CTCallStateConnected]) {

        } else if ([call.callState isEqualToString: CTCallStateDialing]) {
                if ([[idoubs2AppDelegate sharedInstance].videoService isInCall] || [[idoubs2AppDelegate sharedInstance].videoService.outgoingCallView superview]) {
                        rtmp_manager_send_hold([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]);
                }

        }
        else if ([call.callState isEqualToString: CTCallStateDisconnected]) {
            if ([[idoubs2AppDelegate sharedInstance].videoService isInCall] || [[idoubs2AppDelegate sharedInstance].videoService.outgoingCallView superview]) {
                    if (manager->isHold && [[UIApplication sharedApplication] applicationState]==UIApplicationStateBackground) {
                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                   if([[UIApplication sharedApplication]applicationState]==UIApplicationStateBackground){
                                           [self inHoldPush];
                                   }
                           });
                }
            }
        }
        else if ([call.callState isEqualToString: CTCallStateIncoming]) {
            if ([[idoubs2AppDelegate sharedInstance].videoService isInCall] || [[idoubs2AppDelegate sharedInstance].videoService.outgoingCallView superview]) {
                rtmp_manager_send_hold([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]);
                   
            }
        }
        
        [idoubs2AppDelegate sharedInstance].gsm_callState = call.callState;
        lastGsmEvent = [call.callState copy];
        
        NSLog(@"\n****************=============**************** \n\n callEventHandler: %@ \n\n ****************=============****************\n", call.callState);
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    NSLog(@"Received Silent push");
    NSString *devToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
    NSLog(@"DeviceToken - %@",devToken);
    if(devToken){
        NSString *rstring = [Common RegisterPushNotificationWithDeviceToken:devToken registerForce:NO];
        NSLog(@"{RegisterPushNotificationWithDeviceToken}-%@",rstring);
    }
    
    if(registerCommand == TRUE){
        NSLog(@"Restarting RTMP  ");
        [self Restart_RTMP];
    }
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
        self.sleepTimer=[NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(rtmpSleep) userInfo:nil repeats:NO];
    }
    
    handler(UIBackgroundFetchResultNewData);

}

-(void)rtmpSleep {
    NSLog(@"{RTMP SLEEP}");
    id application =[UIApplication sharedApplication];
    UIApplicationState state = [application applicationState];
    if (state==UIApplicationStateBackground) {
        if( manager )
        {   [[RTMPChatManager sharedRTMPManager] stopResend];
            rtmp_manager_send_unregister(manager);
            stop_rtmp_manager(manager);
            registerCommand = TRUE;
            [self.soundService stopRingTone];
        }
    }else{
        [_sleepTimer invalidate];
    }
#if XMPP_ON
        [self performSelector:@selector(signOut) withObject:nil afterDelay:540];
#endif
    
}
-(void)inHoldPush{
        UILocalNotification *onHoldNotification=[[UILocalNotification alloc] init];
        onHoldNotification.alertAction=@"Launch";
        onHoldNotification.alertBody=@"You have a held call";
        onHoldNotification.soundName=@"";
        onHoldNotification.repeatInterval=0;
        [[UIApplication sharedApplication] presentLocalNotificationNow:onHoldNotification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UILocalNotification* localNotif = [[UILocalNotification alloc] init];
    localNotif.userInfo = userInfo;

    NSLog(@"[PUSH][RCV] {didReceiveRemoteNotification} - %@", userInfo);
    
    [self application:application didReceiveLocalNotification:localNotif];
    
    return;
    
    switch ([UIApplication sharedApplication].applicationState) {
        case UIApplicationStateActive:
            break;
        case UIApplicationStateBackground:
            break;
        case UIApplicationStateInactive: {
            NSString *status = [userInfo objectForKey:@"status"];
            
            self.messageFromNotification = NO;
            
            if ([status isEqualToString:@"Message"]) {
                self.messageFromNotification = YES;
                self.pushMessageUserName = [userInfo objectForKey:@"from"];
                
                ContactObject *obj = [[ContactStorage sharedInstance] GetContactObjectBySeequId:self.pushMessageUserName];
                self.messageNavigationTitle = [obj displayName];
                
                [self.contacts popToRootViewControllerAnimated:NO];
                self.tabBarController.selectedIndex = 1;
            } else {
                if ([status isEqualToString:@"Call"]) {
                    if (manager && LAST_RTMP_EVENT_TYPE != RTMP_CALL_EVENT_TYPE_INCOMING) {
                        [self performSelectorOnMainThread:@selector(ShowPreperViewController) withObject:nil waitUntilDone:YES];
                    }
                } else {
                    NSDictionary *dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:[userInfo objectForKey:@"from"], @"SEEQUID", @"REFRESH", @"type", nil];
                    [Common postNotificationWithName:@"REQUEST" object:dictPostNotification];
                    self.tabBarController.selectedIndex = 3;
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void) ShowPreperViewController {
    if ([idoubs2AppDelegate sharedInstance].tabBarController.presentedViewController) {
        self.preparForCallAnswerViewController = [[PreparForCallAnswerViewController alloc] initWithNibName:@"PreparForCallAnswerViewController" bundle:nil];
        [[idoubs2AppDelegate sharedInstance].tabBarController.presentedViewController presentViewController:[idoubs2AppDelegate sharedInstance].preparForCallAnswerViewController animated:NO completion:nil];
    } else {
        self.preparForCallAnswerViewController = [[PreparForCallAnswerViewController alloc] initWithNibName:@"PreparForCallAnswerViewController" bundle:nil];
        [[idoubs2AppDelegate sharedInstance].tabBarController presentViewController:[idoubs2AppDelegate sharedInstance].preparForCallAnswerViewController animated:NO completion:nil];
    }
}
///@todo levon refactor  dirty  code !!!!
- (void) ClosePreperViewController {
    if ([idoubs2AppDelegate sharedInstance].tabBarController.presentedViewController ) {
        if ( [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex == 4) {
            [[idoubs2AppDelegate sharedInstance].tabBarController.presentedViewController dismissViewControllerAnimated:NO completion:^{
                
            }];
            [[idoubs2AppDelegate sharedInstance].tabBarController setSelectedIndex:0];
        }

    } else if ( [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex == 4) {
          
        [[idoubs2AppDelegate sharedInstance].tabBarController setSelectedIndex:0];
    
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification_ {
    
    NSDictionary *userInfo = notification_.userInfo;
    
    switch ([UIApplication sharedApplication].applicationState) {
        case UIApplicationStateActive:
            break;
        case UIApplicationStateBackground:
            break;
        case UIApplicationStateInactive: {
            NSString *status = [userInfo objectForKey:@"status"];
            
            self.messageFromNotification = NO;
            
            if ([status isEqualToString:@"Message"]) {
                self.messageFromNotification = YES;
                self.messageFromLocalNotification = YES;
                self.pushMessageUserName = [userInfo objectForKey:@"from"];

                ContactObject *obj = [[ContactStorage sharedInstance] GetContactObjectBySeequId:self.pushMessageUserName];
                self.messageNavigationTitle = [obj displayName];
                [self.messages popToRootViewControllerAnimated:NO];
                [idoubs2AppDelegate RefreshTab];
                self.tabBarController.selectedIndex = 1;
                NSLog(@"[PUSH][RCV][info] message - from.id:%@, from:%@", self.pushMessageUserName, self.messageNavigationTitle);
            } else {
                if ([status isEqualToString:@"Call"]) {
                    NSLog(@"[PUSH][RCV][info] call - from.id:%@", [userInfo objectForKey:@"from"]);
                    if (manager && LAST_RTMP_EVENT_TYPE != RTMP_CALL_EVENT_TYPE_INCOMING) {
                        [self performSelectorOnMainThread:@selector(ShowPreperViewController) withObject:nil waitUntilDone:YES];
                    }
                } else {
                    NSDictionary *dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:[userInfo objectForKey:@"from"], @"SEEQUID", @"REFRESH", @"type", nil];
                    [Common postNotificationWithName:@"REQUEST" object:dictPostNotification];
                    self.tabBarController.selectedIndex = 3;
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void) RegisterForPush {
    @autoreleasepool {
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
        int regCount = 0;
        while (regCount < 10) {
            if(![Common NSStringisNullOrEmpty:deviceToken]) {
                NSString *error_message = [Common RegisterPushNotificationWithDeviceToken:deviceToken registerForce:NO];
                
                if ([error_message isEqualToString:@"OK"]) {
                    break;
                }
            } else {
                [NSThread sleepForTimeInterval:1.0];
                regCount++;
            }
        }
    }
}

- (void) SendPushWithDict {
    @autoreleasepool {
        
        while (true) {
            if ([self.arrayPushes count]) {
                NSDictionary *dict = [self.arrayPushes objectAtIndex:0];
                [self.arrayPushes removeObjectAtIndex:0];
                NSString *SeequID = [dict objectForKey:@"SeequID"];
                NSString *message = [dict objectForKey:@"message"];
                NSString *status = [dict objectForKey:@"status"];
                
                [Common SendPushNotificationTo:SeequID withText:message Status:status];
            }
            
            [NSThread sleepForTimeInterval:1.0];
        }
    }
}

- (int) checkNetworkStatus
{
	// called after network status changes
	int retVal = 0;
	
	NetworkStatus internetStatus = [internetReach currentReachabilityStatus];
	
	switch (internetStatus) {
		case NotReachable: {
			NSLog(@"The internet is down.");
			break;
		}
		case ReachableViaWiFi: {
			NSLog(@"The internet is working via WIFI.");
			retVal = 1;
			break;
		}
		case ReachableViaWWAN: {
			NSLog(@"The internet is working via WWAN.");
			retVal = 2;
			break;
		}
	}	
	return retVal;
}
#if defined(XMPP)==1 && XMPP
- (void)createEditableCopyOfDatabaseIfNeededWithName
{
	NSString *databaseName = @"Servers.plist";
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    
	// Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL success;
	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:databasePath];
	
	// If the database already exists then return without doing anything
	if(success) return;
	
	// If not then proceed to copy the database from the application to the users filesystem
	
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Servers.plist"];
	
	// Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];	
	[fileManager release];
}
#endif

#pragma mark -
#pragma mark UITabBarControllerDelegate methods


// Optional UITabBarControllerDelegate method.

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if(self.tabBarController.selectedIndex == 0 || self.tabBarController.selectedIndex == 4){
        // reset badge number
       [self updateBadge];
    }
}
-(void) showCamera {
//       UINavigationController *navController = (UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:index];
}

-(void)didSelectControllerWithIndex:(int)index onCurrentCell:(BOOL)isCurrent {
    if(index ==  4) {
        
    } else if (isCurrent) {
        UINavigationController *navController = (UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:index];
        if (navController && [navController respondsToSelector:@selector(popToRootViewControllerAnimated:)]) {
            [navController popToRootViewControllerAnimated:YES];
        }
    }
}

-(void)didDoubleClickedFromUser:(NSString *)user {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didDoubleClickedFromUser:) object:nil];
    
    self.showProfile = !self.showProfile;
    [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView setShowProfile:self.showProfile];
    
    if (self.showProfile) {
        if ([self.videoService.showVideoView isVideoState]) {
            [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Video_Selected];
        } else {
            [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Audio_Selected];
        }
//        [self didClickedOnLastTab];
        [self performSelector:@selector(didDoubleClickedFromUser:) withObject:@"NO" afterDelay:3.0];
    } else {
        if ([self.videoService.showVideoView isVideoState]) {
            [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Video];
        } else {
            [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Audio];
        }
        
        if ([user isEqualToString:@"YES"]) {
            [videoService.showVideoView setVideoState:VideoViewState_TAB_MENU Animation:YES];
        }
    }
}

-(void)didSelectShowCallMenu {
    if ([videoService.showVideoView isVideoState]) {
        [videoService.showVideoView setVideoState:VideoViewState_TAB_MENU Animation:YES];
    } else {
        [videoService.showVideoView setVideoState:VideoViewState_NORMAL Animation:YES];
    }
}

-(void)didClickedOnLastTab {
    dispatch_async(dispatch_get_main_queue(), ^{
        SeequVideoRecorerViewController*  videoRecorder = [[SeequVideoRecorerViewController alloc] initWithType:SeequRecorderTypeNone];
  //      videoRecorder.captureDelegate =self;
        videoRecorder.devicePosition = AVCaptureDevicePositionBack;
        [self.tabBarController presentViewController:videoRecorder animated:YES completion:nil];
        
    });
}

- (void) didRotateInterfaceOrientation:(NSNotification *)notification {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait: {
            [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Default];
            //            self.tabBarController.tabBarView = [SegmentDemoViewController segmentDemo1TabBar];
            break;
        }
        case UIDeviceOrientationLandscapeRight:
        case UIDeviceOrientationLandscapeLeft: {
            [idoubs2AppDelegate ChangeTabBarWithType:tabBar_Type_Landscape];
            break;
        }
    }
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    BOOL isRegistered = [[NSUserDefaults standardUserDefaults] boolForKey:@"autologin"];
    if (!isRegistered) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    switch (tabBarController.selectedIndex) {
        case 0: {
            return UIInterfaceOrientationMaskPortrait;
        }
            break;
        case 1: {
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }
            break;
        case 2: {
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }
            break;
        case 3: {
            return UIInterfaceOrientationMaskPortrait;
        }
            break;
        case 4: {
            return UIInterfaceOrientationMaskPortrait;
        }
            break;
        default:
            break;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

+(idoubs2AppDelegate*) sharedInstance{
	return ((idoubs2AppDelegate*) [[UIApplication sharedApplication] delegate]);
}

-(BOOL) isConnected{
	return (registerCommand == NO);
}

-(char*)getCodecList{
    NetworkStatus internetStatus = [internetReach currentReachabilityStatus];
    
    char* codecs = 0;
    int phoneVer = rtmp_manager_get_phone_version();
    
    switch (internetStatus)
    {
        case ReachableViaWiFi:
        {
            if(phoneVer == iPod4 || phoneVer==iPhone4v5 || phoneVer == iPhone4v6){
                codecs = (char*)IPHONE4_WIFI_SUPPORTED_AUDIO_CODECS_LIST;
                
            }else
                codecs = (char*)IPHONE5_WIFI_SUPPORTED_AUDIO_CODECS_LIST;
        }
            break;
        case ReachableViaWWAN: {
            if(phoneVer == iPod4 || phoneVer==iPhone4v5 || phoneVer == iPhone4v6){
                codecs = (char*)IPHONE4_WWAN_SUPPORTED_AUDIO_CODECS_LIST;
                
            }else{
                codecs = (char*)IPHONE5_WWAN_SUPPORTED_AUDIO_CODECS_LIST;
            }
            break;
        }
    }
    
    return codecs;
}

-(int)getFrameCount {
    NetworkStatus internetStatus = [internetReach currentReachabilityStatus];
    if (internetStatus == ReachableViaWiFi)
        return WIFI_SUPPORTED_AUDIO_FRAME_COUNT;
    
    return WWAN_SUPPORTED_AUDIO_FRAME_COUNT;
}

+ (void) RTMP_Call_To:(NSString*)call_number Call_Type:(NSString*)callType_ {
    
    if (![[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager] || ![[idoubs2AppDelegate sharedInstance] isConnected]) {
        return;
    }
    
   //[idoubs2AppDelegate  RTMP_Call_To:@"62887002" Call_Type:@"video"];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:call_number, @"call_number",
                                                                      callType_, @"callType", nil];


    [NSThread detachNewThreadSelector:@selector(RTMP_Call_To_Asynchronously:)
                             toTarget:[idoubs2AppDelegate sharedInstance]
                           withObject:dict];
}

- (void) RTMP_Call_To_Asynchronously:(NSDictionary*)dict {
    NSString *call_number = [dict objectForKey:@"call_number"];
    NSString *callType_ = [dict objectForKey:@"callType"];
    
    NetworkStatus internetStatus = [internetReach currentReachabilityStatus];
    int internet_type = [[self dataNetworkTypeFromStatusBar] intValue];
    char* codecs = (char*)[self getCodecList];
    int frameCount = [self getFrameCount];
    
    NSString *fullname = [[Common sharedCommon].contactObject displayName];
    rtmp_manager_send_call([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager],(char*)[fullname UTF8String],
                           (char *)[call_number UTF8String],
                           (char *)[callType_ UTF8String], codecs, frameCount, internetStatus, internet_type);
}

+ (void) RTMP_Accept_Call {
    [NSThread detachNewThreadSelector:@selector(RTMP_Accept_Call_Asynchronously)
                             toTarget:[idoubs2AppDelegate sharedInstance]
                           withObject:nil];
}

- (void) RTMP_Accept_Call_Asynchronously {
    @autoreleasepool {
        @synchronized(self) {
            if(manager){
                NetworkStatus internetStatus = [internetReach currentReachabilityStatus];
                int internet_type = [[self dataNetworkTypeFromStatusBar] intValue];
                char* codecs = (char*)[self getCodecList];
                int frameCount = [self getFrameCount];
                
                rtmp_manager_send_accept(manager, codecs, frameCount, internetStatus,internet_type);
            }
        }
    }
}

+ (void) RTMP_Hangup_Call {
    
    [[idoubs2AppDelegate sharedInstance].videoService.showVideoView CancelTimerForEndCall];
    
    [NSThread detachNewThreadSelector:@selector(RTMP_Hangup_Call_Asynchronously)
                             toTarget:[idoubs2AppDelegate sharedInstance]
                           withObject:nil];
}

- (void) RTMP_Hangup_Call_Asynchronously {
    @autoreleasepool {
        @synchronized(self) {
            NSLog(@"RTMP_Hangup_Call_Asynchronously");
            [[idoubs2AppDelegate sharedInstance].AudioUnitPlugin_ stopRecordAndPlayAudio:manager];
            rtmp_manager_send_hangup(manager);
        }
    }
}

+ (void) RTMP_Decline_Call {
    [NSThread detachNewThreadSelector:@selector(RTMP_Decline_Call_Asynchronously)
                             toTarget:[idoubs2AppDelegate sharedInstance]
                           withObject:nil];
}

- (void) RTMP_Decline_Call_Asynchronously {
    @autoreleasepool {
        @synchronized(self) {
            rtmp_manager_send_decline(manager);
        }
    }
}
-(void)changeLoadingViewMessage:(NSString*)message{
        self.labelTitle.text=message;
        [self.activityIndicatorViewLoading stopAnimating];
}


- (void) ShowLoadingViewWithMessage:(NSString*)message {
    self.viewLoading.frame = self.window.frame;
    self.labelTitle.text = message;
    [self.window addSubview:self.viewLoading];
    [self.activityIndicatorViewLoading startAnimating];
    CGFloat result = [[UIScreen mainScreen] bounds].size.height;
    self.activityIndicatorViewLoading.center = CGPointMake(160, result/2 - 20);
    self.labelTitle.center = CGPointMake(160, result/2 + 20);
}

- (void) HideLoadingView {
        if([self.activityIndicatorViewLoading isAnimating]){
            [self.activityIndicatorViewLoading stopAnimating];
        }
    [self.viewLoading removeFromSuperview];
}

- (void)observeBeginEditing:(NSNotification *)note {
    currentFirstResponder_ = note.object;
}

- (void)observeEndEditing:(NSNotification *)note {
    if (currentFirstResponder_ == note.object) {
        currentFirstResponder_ = nil;
    }
}

- (void) HideKeyboard
{
    if (currentFirstResponder_) {

        [currentFirstResponder_ resignFirstResponder];
    }
}

- (void) RefreshTabNoStatic {
    [idoubs2AppDelegate RefreshTab];
}

+ (void) RefreshTab {
    [idoubs2AppDelegate sharedInstance].refreshingTab = YES;
    int selIndex = [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex;
    if (selIndex == 0) {
        [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 4;
    } else {
        [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 0;
    }
    [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = selIndex;

    [idoubs2AppDelegate sharedInstance].refreshingTab = NO;
}

+ (void) ChangeTabBarWithType:(tabBar_Type)type {
    if ([idoubs2AppDelegate sharedInstance].videoService.isOnHold) {
        type = tabBar_Type_OnHold;
    }
    
    switch (type) {
        case tabBar_Type_Default: {
            [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView segmentDemo1TabBar];
        }
            break;
        case tabBar_Type_Landscape: {
//            [idoubs2AppDelegate sharedInstance].tabBarController.tabBarView = [SegmentDemoViewController segmentDemo1TabBarLandscape];
//            [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView segmentDemo1TabBar];
        }
            break;
        case tabBar_Type_Audio: {
            [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView segmentDemoAudioTabBar];
        }
            break;
        case tabBar_Type_Audio_Selected: {
            [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView segmentDemoAudioSelectedTabBar];
        }
            break;
        case tabBar_Type_Video: {
            [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView segmentDemoVideoTabBar];
        }
            break;
        case tabBar_Type_Video_Selected: {
            [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView segmentDemoVideoSelectedTabBar];
        }
            break;
        case tabBar_Type_OnHold: {
            [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView segmentDemoOnHoldTabBar];
        }
            break;
        default:
            break;
    }
    
    if ([idoubs2AppDelegate sharedInstance].videoService.showVideoView.videoViewState == VideoViewState_HIDE && type != tabBar_Type_Default) {
        [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView StartAnimation];
    }
    
    [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView addSubview:[idoubs2AppDelegate sharedInstance]->contactBadgView];
    [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView addSubview:[idoubs2AppDelegate sharedInstance]->recentBadgView];
    [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView addSubview:[idoubs2AppDelegate sharedInstance]->messageBadgView];
    [[idoubs2AppDelegate sharedInstance].tabBarController.tabBarView setSelectedIndex:[idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex];
    
    [idoubs2AppDelegate sharedInstance].callType = (int)type;
    [Common postNotificationWithName:kCallStateChange object:[NSNumber numberWithInt:[idoubs2AppDelegate sharedInstance].callType]];
    
    if ([[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
        [idoubs2AppDelegate sharedInstance].videoService.showVideoView.imageViewNetworkStatus.hidden = NO;
//        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView ShowRemotProfileImage:NO];
    } else {
        [idoubs2AppDelegate sharedInstance].videoService.showVideoView.imageViewNetworkStatus.hidden = YES;
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView ShowRemotProfileImage:YES];
        [idoubs2AppDelegate sharedInstance].videoService.showVideoView.openGlView.hidden = YES;
    }
}

- (void) ShowDefaultMessageWithText:(NSString*)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
}

- (void) ShowLocalPushForMessageWithSeequID:(NSString*)seequID withPushText:(NSString *)localPushText andStatus:(NSString*)status{
    ContactObject *contactObject = [Common getContactObjectWithSeequID:seequID];
    if (contactObject) {
        NSDictionary *dict = [Common GetUserDetailsByPTID:seequID];
        contactObject = [[ContactObject alloc] initWithSeequID:seequID];
        [contactObject SetUserInfoWithDictionary:dict];
        
        UILocalNotification* localNotif = [[UILocalNotification alloc] init];
        if (localNotif) {
            localNotif.alertAction = @"Launch";
            localNotif.alertBody =[NSString  stringWithFormat:@"%@ %@%@", contactObject.FirstName, contactObject.LastName,localPushText];
            localNotif.soundName = @"default";
            localNotif.repeatInterval = 0;
            
            localNotif.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:status, @"status", seequID, @"from", nil];
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
//            RSLog(@"[SYSTEM] Local Notification - %@", localNotif.alertBody);
        }
    }
}

- (NSNumber *) dataNetworkTypeFromStatusBar {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSNumber *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    return [dataNetworkItemView valueForKey:@"dataNetworkType"];
}

+ (id<ChatManager>) getChatManager{
#if (XMPP_ON==1)
    return [XMPPManager sharedXMPPManager];
#else
    return [RTMPChatManager sharedRTMPManager];
#endif //(XMPP_ON==1)
}


-(void)logOutSeequ:(myCompletion)completion{
        [self ShowLoadingViewWithMessage:@"log Out..."];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
                [Common UnRegisterPushNotificationWithDeviceToken:deviceToken];
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"autologin"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IDENTITY_IMPI"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IDENTITY_PASSWORD"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IDENTITY_IMPU"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pass"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"defaultTabBar"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kUDID"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"firstLogin"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"autorisation_problem"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if ([DBSession sharedSession].isLinked) {
                        [[DBSession sharedSession] unlinkAll];
                }
                if ([[idoubs2AppDelegate sharedInstance].rtmpEvents count] > 0 ) {
                        [[idoubs2AppDelegate sharedInstance].rtmpEvents removeAllObjects];
                }
                   [[RTMPChatManager sharedRTMPManager] stopResend];
                
                if ([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]) {
                        rtmp_manager_send_unregister([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]);
                        stop_rtmp_manager([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]);
                }
                [[idoubs2AppDelegate sharedInstance] Set_RTMP_Manager:nil];
                [[idoubs2AppDelegate sharedInstance] RegisterCommand:YES];
                
                [[idoubs2AppDelegate sharedInstance].seequPresentation popToRootViewControllerAnimated:NO];
                [[idoubs2AppDelegate sharedInstance].contacts popToRootViewControllerAnimated:NO];
                [[UIApplication sharedApplication] unregisterForRemoteNotifications];
                
                [self HideLoadingView];
                [[idoubs2AppDelegate sharedInstance].tabBarController presentViewController:[idoubs2AppDelegate sharedInstance].seequPresentation animated:NO completion:nil];
                if (completion) {
                         completion(YES);
                }
               
        });
        
}
- (DBRestClient *)getDropboxClient
{
        if (_dropboxClient == nil && [DBSession sharedSession] != nil) {
                _dropboxClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
                [_dropboxClient setDelegate:self];
        }
        return _dropboxClient;
}
-(void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath{
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:srcPath error:&error];
        if (error) {
                NSLog(@"restClient removeItemAtPath erroe-%@",[error description]);
        }
}
-(void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error{
        NSLog(@"Dropbox upload File Failed With Error -%@",[error description]);
}

//- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
//{
//    __block BOOL newData = NO;
//    [[PASync syncClient] syncWithUpdate:^(CBLReplication *replication) {
//        if (replication.total > 0) {
//            newData = YES;
//        }
//    } completion:^(NSString *state) {
//        if (newData) {
//            // Increment the app badge
//            application.applicationIconBadgeNumber++;
//            completionHandler(UIBackgroundFetchResultNewData);
//        } else {
//            completionHandler(UIBackgroundFetchResultNoData);
//        }
//    }];
//}

dispatch_source_t CreateDispatchTimer(double interval, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

- (void)startTimer
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    double secondsToFire = 1.000f;
    
    forceRegister = FALSE;
    lastIPAddress = [Reachability localWiFiIPAddress];
    __block NSTimeInterval lastSucceedRegisterTime = 0;
    __block tbi_bool_t bIsRegisterStart = tbi_false;
    
    _timer = CreateDispatchTimer(secondsToFire, queue, ^{
        
        if(bIsNetworkReachable)
        {
            if( ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground) || forceRegister )
            {
                forceRegister = FALSE;
                
                NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
                if(lastSucceedRegisterTime == 0)
                    lastSucceedRegisterTime = currentTime;
                
                if(manager && !registerCommand)
                {
                    uint64_t currentTimeMS = TBI_time_epoch();
                    uint64_t rtmpLastPingTime = rtmp_manager_get_lastrcvtime(manager);
                    if( ( (currentTimeMS - rtmpLastPingTime > PING_CHECKING_TIMEOUT) /* || !rtmp_manager_is_connected(manager) */ || [self IsIPAddressChanged]) )
                    {
                        NSLog(@"registerationThread: No ping from server about %lld sec", currentTimeMS - rtmpLastPingTime);
                        registerCommand = TRUE;
                    }
                }
                BOOL isInCall=[[idoubs2AppDelegate sharedInstance].videoService isInCall];
                if(registerCommand && !( isInCall && self.isChangeFrom3GToWIFI))
                {
                    
                    bIsReceivedRegResponse = NO;
                    if(!bIsRegisterStart || (currentTime - lastSucceedRegisterTime > 5))
                    {
                        if([self Restart_RTMP])
                        {
                            lastSucceedRegisterTime = [[NSDate date] timeIntervalSince1970];
                            bIsRegisterStart = tbi_true;
                        }
                    }
                }
                else
                {
                    bIsRegisterStart = tbi_false;
                }
            }
        }
        
    });
}

- (void)cancelTimer
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application
{
    NSLog(@"**************************** applicationProtectedDataDidBecomeAvailable:(UIApplication *)application *************************");
}
@end

