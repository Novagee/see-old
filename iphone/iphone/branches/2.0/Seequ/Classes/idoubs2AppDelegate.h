#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import "RegisteringViewController.h"
#import <MapKit/MapKit.h>
#import "Reachability.h"
#import "TBIRTMP.h"
#import <HockeySDK/HockeySDK.h>

#import "ChatManager.h"

/////////
#import "PreparForCallAnswerViewController.h"
#import "SeequContactsViewController.h"
#import "TabBarVCDemoViewController.h"
#import "VideoService.h"
#import "TBISoundService.h"
#import "TBIDefaultBadgView.h"
#import "AudioUnitPlugin.h"
#import "TBIVideoProducer.h"
#import "TBIVideoConsumer.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <DropboxSDK/DropboxSDK.h>

typedef void(^myCompletion)(BOOL);

@class Reachability;

@interface idoubs2AppDelegate : NSObject <UIApplicationDelegate,UITabBarControllerDelegate, TBITabBarControllerDelegate, BadgViewDelegate, BITHockeyManagerDelegate, BITUpdateManagerDelegate,BITCrashManagerDelegate,DBRestClientDelegate> {

    UIWindow *window;
    TabBarVCDemoViewController *tabBarController;
    PreparForCallAnswerViewController *preparForCallAnswerViewController;
    VideoService *videoService;
    TBISoundService *soundService;
    UIView *currentFirstResponder_;
    
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
    
    TBIDefaultBadgView *contactBadgView;
    TBIDefaultBadgView *recentBadgView;
    TBIDefaultBadgView *messageBadgView;
    
    NSThread *threadPush;
    NSMutableArray *arrayPushes;
    
    BOOL isFromRemotNotification;
    BOOL messageFromNotification;
    NSString *pushMessageUserName;
    
    NSURLRequest *urlReq;

    rtmp_manager_t *manager;
    BOOL isBackgroundMode;

    NSString *recive_call_number;
    NSString *recive_call_state;
    NSString *flash_message;
	
//	UIBackgroundTaskIdentifier backgroundTask;
    UIBackgroundTaskIdentifier bgTask;
//	dispatch_block_t expirationHandler;
	BOOL multitaskingSupported;
	
    NSString *DeviceToken;

    BOOL audio;
    BOOL hasNewNetEvent;
    BOOL isNetworkChanged;
    
    void* taskRunWaitHandle;
    
    AudioUnitPlugin *AudioUnitPlugin_ ;
    
    
    TBIVideoProducer *controller;
    NetworkStatus lastNetStatus;
    NSString *lastWiFIAdress;
    BOOL registerCommand;
    BOOL bIsReceivedRegResponse;
    BOOL bIsNetworkReachable;
    enum RTMP_EVENT_TYPE LAST_RTMP_EVENT_TYPE;
    BOOL forceRegister;
    BOOL forceRegisterTime;

    NSString *gsm_callState;
    NSDate *systemTime;
    NSDate *networkTime;
    NSString *lastGsmEvent;

    NSString* lastIPAddress;
    
    BOOL endCallTimerStarted;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) TabBarVCDemoViewController *tabBarController;
@property (nonatomic, strong) VideoService *videoService;
@property (nonatomic, strong) TBISoundService *soundService;
@property (nonatomic, strong) PreparForCallAnswerViewController *preparForCallAnswerViewController;
@property (nonatomic, strong) IBOutlet UINavigationController *browser;
@property (nonatomic, strong) IBOutlet UINavigationController *contacts;
@property (nonatomic, strong) IBOutlet UINavigationController *messages;
@property (nonatomic, strong) IBOutlet UINavigationController *recent;
@property (nonatomic, strong) IBOutlet UINavigationController *settings;
@property (nonatomic, strong) IBOutlet UINavigationController *takes;
@property (nonatomic, strong) IBOutlet UINavigationController *seequPresentation;
@property (unsafe_unretained, nonatomic) IBOutlet UINavigationController *seequBookmarks;
@property (weak, nonatomic) IBOutlet UINavigationController *seequAddBookmark;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewLoading;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorViewLoading;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelTitle;

@property (nonatomic, strong) NSMutableArray *arrayPushes;

@property (nonatomic, retain) DBRestClient *dropboxClient;

@property (nonatomic, assign) BOOL isFromRemotNotification;
@property (nonatomic, assign) BOOL messageFromNotification;
@property (nonatomic, assign) BOOL messageFromLocalNotification;
@property (nonatomic, assign) BOOL messageFromActivity;
@property (nonatomic, assign) BOOL isChangeFrom3GToWIFI;
@property (nonatomic, strong) NSString *messageFromActivityTo;
@property (nonatomic, strong) NSString *messageFromActivityText;
@property (nonatomic, strong) UIImage* messageFromActivityImage;
@property (nonatomic, strong) NSString *messageFromActivityVideoPath;

@property (nonatomic, strong) NSString *messageNavigationTitle;
@property (nonatomic, strong) NSString *pushMessageUserName;

@property (nonatomic, strong) NSURLRequest *urlReq;

@property (nonatomic, strong) NSString *ReplyWithMessageNumber;

@property (nonatomic, strong) AudioUnitPlugin *AudioUnitPlugin_;

@property (nonatomic, strong) NSString *DeviceToken;
@property (nonatomic, assign) BOOL audio;
@property (nonatomic, assign) BOOL showProfile;
@property (nonatomic, assign) BOOL refreshingTab;

@property (nonatomic, retain) XMPPRoster *xmppRoster;

@property (nonatomic, strong) CTCallCenter* callCenter;
@property (nonatomic, strong) NSString* gsm_callState;

@property (nonatomic, assign) int callType;
@property (nonatomic, retain)  NSTimer *sleepTimer;
@property (nonatomic, assign) BOOL isRosterReceived;
@property (nonatomic,retain) NSMutableArray* rtmpEvents;


- (void) ShowRegisterView;
- (rtmp_manager_t*) Get_RTMP_Manager;
- (void) Set_RTMP_Manager:(rtmp_manager_t*)rtmp_manager;
- (int) Restart_RTMP;
- (BOOL) isConnected;
+ (void) RTMP_Call_To:(NSString*)call_number Call_Type:(NSString*)callType;
- (void) RTMP_Call_To_Asynchronously:(NSDictionary*)dict;
+ (void) RTMP_Accept_Call;
- (void) RTMP_Accept_Call_Asynchronously;
+ (void) RTMP_Hangup_Call;
- (void) RTMP_Hangup_Call_Asynchronously;
+ (void) RTMP_Decline_Call;
- (void) RTMP_Decline_Call_Asynchronously;
- (BOOL) CheckWiFiIP;
- (BOOL) IsIPAddressChanged;
- (void) RegisterCommand:(BOOL)commmand;
-(void)logOutSeequ:(myCompletion)completion;

///////////////////

- (void) creatMessagesBadge;
+ (idoubs2AppDelegate*) sharedInstance;
- (int) checkNetworkStatus;
- (NSMutableArray*) CreateTabBarControllers;
- (void) UpdateContactTabBadgValue;
- (void) UpdateRecentTabBadgValue;
-(void) updateBadge;
- (void) SetContactTabBadgValue:(NSString*)value;
- (void) SetRecentTabBadgValue:(NSString*)value;
- (void) SetMessageTabBadgValue:(NSString*)value;
- (void) IncrementContactTabBadg;
- (void) IncrementRecentTabBadg;
- (void) IncrementMessageTabBadg;
- (int) GetRecentTabBadgValue;
- (void) RegisterForPush;
- (void) SendPushWithDict;
- (void) PreparingAccount;
- (void) showCamera;

- (DBRestClient *)getDropboxClient;

#if XMPP_ON
- (void) RegisterXMPP;
#endif //XMPP_ON
- (void) ShowPreperViewController;
- (void) ClosePreperViewController;
- (void) ShowLoadingViewWithMessage:(NSString*)message;
- (void) changeLoadingViewMessage:(NSString*)message;
- (void) HideLoadingView;
- (void) observeBeginEditing:(NSNotification *)note;
- (void) observeEndEditing:(NSNotification *)note;
- (void) HideKeyboard;
- (void) RefreshTabNoStatic;
+ (void) RefreshTab;
+ (void) ChangeTabBarWithType:(tabBar_Type)type;
- (void) ShowDefaultMessageWithText:(NSString*)text;
- (void) ShowLocalPushForMessageWithSeequID:(NSString*)seequID withPushText:(NSString *)localPushText andStatus:(NSString*)status;
- (int) SendRTMPRegister;
+ (id<ChatManager>) getChatManager;
@end