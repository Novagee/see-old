//
//  SeequRequestConnectionViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/16/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequRequestConnectionViewController.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"
#import "RTMPChatManager.h"

#define STAR_IMAGE_TAG 88


@interface SeequRequestConnectionViewController ()

@end

@implementation SeequRequestConnectionViewController

@synthesize contactObj;
@synthesize videoViewState;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self UpdateUI];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewOrientationChange:) name:kVideoViewOrientationChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectUpdateEvent:) name:kContactObjectUpdateNotification object:nil];
    
    if([[idoubs2AppDelegate sharedInstance].videoService isInCall]){
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView setVideoState:VideoViewState_HIDE Animation:YES];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textViewNote becomeFirstResponder];
    if(IS_IOS_7){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }

    scrollHeight = 201;
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 568) {
        scrollHeight = 289;
        self.imageViewTextBG.frame = CGRectMake(0, 76, 320, 199 + 14);
        [self.imageViewTextBG setImage:[UIImage imageNamed:@"profileRequestConnectionNoteBG568.png"]];
        self.textViewNote.frame = CGRectMake(14, 123 - 14, 291, 152 + 14);
    }
    
    self.scrollViewContent.contentSize = CGSizeMake(320, scrollHeight);
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yy"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:NSTimeInterval(self.contactObj.registrationDate/1000.0)];
    NSString *retVal = [dateFormatter stringFromDate:date];
    self.labelRegistrationDate.text = retVal;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (UIInterfaceOrientationIsPortrait([idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation)) {
        [self setVideoViewState:self.videoViewState Animated:NO];
    }
}

- (void) onVideoViewChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    self.videoViewState = (VideoViewState)[eargs intValue];
}

- (void) onVideoViewOrientationChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    Video_InterfaceOrientation = (UIInterfaceOrientation)[eargs intValue];
    
    [self setVideoViewState:self.videoViewState Animated:YES];
}

- (void) setVideoViewState:(int)state Animated:(BOOL)animated {
    if ([[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
        if (UIInterfaceOrientationIsLandscape(Video_InterfaceOrientation)) {
            state = VideoViewState_HIDE;
        }
    } else {
        state = VideoViewState_HIDE;
    }

    videoViewState = state;

    int diff = 0;
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 568) {
        diff = 88;
    }
    int delta=0;
    
    if (IS_IOS_7) {
        delta=20;
    }

    CGRect frame = CGRectZero;
    switch (state) {
        case VideoViewState_NONE:
        case VideoViewState_NORMAL:
        case VideoViewState_NORMAL_MENU:
        case VideoViewState_HIDE: {
            frame = CGRectMake(0, 44+delta, 320, 201 + diff);
            if (state == VideoViewState_HIDE) {
                if (![UIApplication sharedApplication].statusBarHidden) {
                    
                        self.view.frame = CGRectMake(0, 20-delta, 320, 460 + diff);
                }
            }
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 271 - 48 - diff, 320,  (self.view.frame.size.height - 271 - 48 - diff) + 64);
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 179 - 48 - diff, 320,  (self.view.frame.size.height - 179 - 48 - diff) + 64);
        }
            break;
        default:
            break;
    }
    
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        if (animated) {
            [UIView beginAnimations:@"scrollFrame" context:nil];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.3];
        }
        self.scrollViewContent.frame = frame;
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (void) onContactObjectUpdateEvent:(NSNotification*)notification {
    NSString *seequId = [notification object];
    
    if (seequId) {
        if ([self.contactObj.SeequID isEqualToString:seequId]) {
                [[ContactStorage sharedInstance] GetContactObjectBySeequId:seequId];
                [self UpdateUI];
        }
    }
}

- (void) UpdateUI {
    self.imageViewProfile.image = self.contactObj.image;
//    [self setRatingStars:ceilf(self.contactObj.ratingValue)];
    self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@", self.contactObj.FirstName, self.contactObj.LastName];
    self.labelSpecialist.text = self.contactObj.specialist;
    self.labelCompany.text = self.contactObj.company;
    self.labelRatings.text = [NSString stringWithFormat:@"%d Ratings", self.contactObj.ratingCount];
    self.labelReviews.text = [NSString stringWithFormat:@"%d Reviews", self.contactObj.reviewCount];
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    if (self.contactObj.City && [self.contactObj.City length]) {
        [arr addObject:self.contactObj.City];
    }
    if (self.contactObj.state.stateAbbrev && [self.contactObj.state.stateAbbrev length] ) {
        [arr addObject:self.contactObj.state.stateAbbrev];
    } else if(self.contactObj.state.stateName && [self.contactObj.state.stateName length] ) {
        [arr addObject:self.contactObj.state.stateName];
    }
    if (self.contactObj.country.countryName && [self.contactObj.country.countryName length]) {
        [arr addObject:self.contactObj.country.countryName];
    }
    NSString* str = [arr componentsJoinedByString:@", "];
    self.labelLocation.text = str;

    if (self.contactObj.badgeStatus) {
        NSString *imageName = [NSString stringWithFormat:@"ProfileBadgeStatus%@.png", self.contactObj.badgeStatus];
        [self.imageViewSeequStatus setImage:[UIImage imageNamed:imageName]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageViewProfile:nil];
    [self setLabelDisplayName:nil];
    [self setLabelSpecialist:nil];
    [self setLabelCompany:nil];
    [self setLabelLocation:nil];
    [self setLabelRatings:nil];
    [self setLabelReviews:nil];
    [self setTextViewNote:nil];
    [self setImageViewSeequStatus:nil];
    [self setImageViewTextBG:nil];
    [self setScrollViewContent:nil];

    [self setLabelRegistrationDate:nil];
    [super viewDidUnload];
}

- (IBAction)onButtonCancel:(id)sender {
    RSLogUI(@"[RequestConnectionView] onButtonCancel");

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onButtonSend:(id)sender {
    RSLogUI(@"[RequestConnectionView] onButtonSend");
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Sending Connection Request."];
        [self.textViewNote resignFirstResponder];
        
        [NSThread detachNewThreadSelector:@selector(SendConnectionRequest) toTarget:self withObject:nil];
    }
}

- (void) setRatingStars:(int)stars {
    for (UIImageView *imageView in self.scrollViewContent.subviews) {
        if (imageView.tag == STAR_IMAGE_TAG) {
            [imageView removeFromSuperview];
        }
    }

    for (int i = 0; i < stars; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(276 - (stars*12)/2 + i * 12, 60, 12, 11)];
        starImageView.tag = STAR_IMAGE_TAG;
        starImageView.image = [UIImage imageNamed:@"contactRatingStar.png"];
        
        [self.scrollViewContent addSubview:starImageView];
    }
}

#pragma mark -----XMPPRoster-----

- (id <XMPPUser>)myUserForXMPPStream:(XMPPStream *)xmppStream {
    return nil;
}

- (id <XMPPResource>)myResourceForXMPPStream:(XMPPStream *)xmppStream {
    return nil;
}

- (id <XMPPUser>)userForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)xmppStream {
    return nil;
}

- (id <XMPPResource>)resourceForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)xmppStream {
    return nil;
}

- (void)beginRosterPopulationForXMPPStream:(XMPPStream *)xmppStream {
}

- (void)endRosterPopulationForXMPPStream:(XMPPStream *)xmppStream {
}

- (void)handleRosterItem:(NSXMLElement *)item xmppStream:(XMPPStream *)xmppStream {
}

- (void)handlePresence:(XMPPPresence *)presence xmppStream:(XMPPStream *)xmppStream {
}

- (void)clearAllResourcesForXMPPStream:(XMPPStream *)xmppStream {
}

- (void)clearAllUsersAndResourcesForXMPPStream:(XMPPStream *)xmppStream {
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence {
}

- (void) SendConnectionRequest {
    @autoreleasepool {
        NSString *error_message = [Common AddRequestWithSeequID:self.contactObj.SeequID
                                                           Date:[[NSDate date] timeIntervalSince1970]
                                                           Name:@"Connection"
                                                        Content:self.textViewNote.text];
        
        if (error_message) {
            [self performSelectorOnMainThread:@selector(HideLoadingView) withObject:nil waitUntilDone:YES];
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(ShowDefaultMessageWithText:) withObject:error_message waitUntilDone:YES];
            }
            
            return;
        }
         [NSThread sleepForTimeInterval:3.0];


        NSLog(@"[PUSH][SEND] <RequestConnection> from:%@ %@ ", self.contactObj.FirstName, self.contactObj.LastName);

        [self performSelectorOnMainThread:@selector(SendXMPPAddBuddyRequest) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(HideLoadingView) withObject:nil waitUntilDone:YES];
        NSDictionary *dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONNECTION", @"type", nil];
        [Common postNotificationWithName:@"REQUEST" object:dictPostNotification];
    }
}

- (void) SendXMPPAddBuddyRequest {
    RTMPChatManager* man  = (RTMPChatManager*) [idoubs2AppDelegate getChatManager];
    SeequMessageObject* info = [[SeequMessageObject alloc] init];
    info.msg =@"*#===CONNECTION===#*";
    info.msgId = MESSAGE_ID;
    info.from = self.contactObj.SeequID;
    info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
    info.type = Message_Type_Connection;
    
    [man sendTextMessage:info AddToResendList:NO];

    
        
        
}

- (void) HideLoadingView {
    [self.contactObj UpdateProfileDataAsynchronously];
    [[idoubs2AppDelegate sharedInstance] HideLoadingView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end