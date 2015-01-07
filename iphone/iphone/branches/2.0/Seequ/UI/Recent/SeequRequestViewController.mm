//
//  SeequRequestViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/13/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//
#import "ActivityStorage.h"
#import "SeequRequestViewController.h"
#import "SeequContactProfileDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "idoubs2AppDelegate.h"
#import "NavigationBar.h"
#import "BackBarButton.h"


#define STAR_IMAGE_TAG 88


@interface SeequRequestViewController ()

@end

@implementation SeequRequestViewController

@synthesize contactObj;
@synthesize videoViewState;
@synthesize buttonAccept;
@synthesize buttonDecline;

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

    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    if(IS_IOS_7){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    // Do any additional setup after loading the view from its nib.

    [self UpdateUI];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewOrientationChange:) name:kVideoViewOrientationChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectUpdateEvent:) name:kContactObjectUpdateNotification object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = nil;
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack:)];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    self.buttonAccept.enabled = NO;
    self.buttonDecline.enabled = NO;
    
    if (self.contactObj.requestStatus == Request_Status_Connection ||
        self.contactObj.requestStatus == Request_Status_Review ||
        self.contactObj.requestStatus == Request_Status_Ringback) {
        self.buttonAccept.enabled = YES;
        self.buttonDecline.enabled = YES;
    }
    
    switch (self.contactObj.requestStatus) {
        case Request_Status_Ringback:
        case Request_Status_Recived_Ringback_Accepted:
        case Request_Status_Recived_Ringback_Declined: {
            [self.buttonAccept setBackgroundImage:[UIImage imageNamed:@"ActivityRequestRingbackButton.png"] forState:UIControlStateNormal];
            [self.labelRequestType setText:@"Ringback Request"];
            self.navigationItem.title = @"Ringback Request";
            
            if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
                self.buttonAccept.enabled = NO;
                self.buttonDecline.enabled = NO;
            }
        }
            break;
        case Request_Status_Review:
        case Request_Status_Recived_Review_Accepted:
        case Request_Status_Recived_Review_Declined: {
            [self.buttonAccept setBackgroundImage:[UIImage imageNamed:@"ActivityRequestReviewButton.png"] forState:UIControlStateNormal];
            [self.labelRequestType setText:@"Review Request"];
            self.navigationItem.title = @"Review Request";
        }
            break;
        default: {
            [self.buttonAccept setBackgroundImage:[UIImage imageNamed:@"ActivityRequestAcceptButton.png"] forState:UIControlStateNormal];
            [self.labelRequestType setText:@"Seequ Connection Request"];
            self.navigationItem.title = @"Connection Request";
        }
            break;
    }
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 568) {
        self.scrollViewContent.contentSize = CGSizeMake(320, 367 + 88);
        self.textViewNote.frame = CGRectMake(0, 215, 320, 152 + 88);
    } else {
        self.scrollViewContent.contentSize = CGSizeMake(320, 367);
        self.textViewNote.frame = CGRectMake(0, 215, 320, 152);
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (UIInterfaceOrientationIsPortrait([idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation)) {
        [self setVideoViewState:self.videoViewState Animated:NO];
    }
}

- (void) onVideoViewChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    videoViewState = (VideoViewState)[eargs intValue];
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

    if (self.contactObj.requestStatus == Request_Status_Ringback) {
        if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
            self.buttonAccept.enabled = NO;
            self.buttonDecline.enabled = NO;
        }
    }
    
    int diff = 0;
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 568) {
        diff = 88;
    }

    CGRect frame = CGRectZero;
    switch (state) {
        case VideoViewState_NONE:
        case VideoViewState_NORMAL:
        case VideoViewState_NORMAL_MENU:
        case VideoViewState_HIDE: {
            frame = CGRectMake(0, 0, 320, 367 + diff);
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 271 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 271 - diff));
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 179 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 179 - diff));
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
    
    self.viewFooter.frame = CGRectMake(0, self.scrollViewContent.contentSize.height - 51, 320, 51);
}

- (void) onContactObjectUpdateEvent:(NSNotification*)notification {
                NSString *seequId= [notification object];
    
    if (seequId) {
        if ([self.contactObj.SeequID isEqualToString:seequId]) {
                NSString * subscriptio =[[ContactStorage sharedInstance] GetUserSubscriptionBySeequId:self.contactObj.SeequID];
                if (![subscriptio isEqualToString:@"both"]) {
                        [self.navigationController popViewControllerAnimated:YES];
                }
                
//           ActivityCoreData *activity=[[ActivityStorage sharedInstance] getRequestFromStorageById:self.contactObj.ID];
//                if (activity) {
//                        self.contactObj=[ActivityStorage contactObjectFromActivityStorage:activity];
//                }
                
                
            [self UpdateUI];
        }
    }
}

- (void) UpdateUI {
    self.imageViewProfile.frame=CGRectMake(0, 0, self.view.frame.size.width,self.labelRequestType.frame.origin.y);
    self.imageViewProfile.contentMode=UIViewContentModeScaleAspectFill;
    self.imageViewProfile.image = self.contactObj.image;
    [self setSessionCount:self.contactObj.SessionsCount];
    self.viewSessinoCountBG.layer.cornerRadius = 7.f;

        //    [self setRatingStars:ceilf(self.contactObj.ratingValue)];
    
//    SeequContactsViewController *contactsViewController = [[idoubs2AppDelegate sharedInstance].contacts.viewControllers objectAtIndex:0];
    
//    if (contactsViewController && [contactsViewController isKindOfClass:[SeequContactsViewController class]]) {
//        ContactObject *obj = [contactsViewController CheckObjectInArrayWithPT:self.contactObj.SeequID];
//        if (!obj) {
//            self.contactObj.isOnline = online_Status_Away;
//        } else {
//            self.contactObj.isOnline = obj.isOnline;
//        }
//    }
        
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

    [self setOnlineStatus:self.contactObj.isOnline];
    self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@", self.contactObj.FirstName, self.contactObj.LastName];
    self.textViewDescription.editable = NO;
    self.textViewDescription.text = self.contactObj.introduction;
    if (self.contactObj.badgeStatus) {
        NSString *imageName = [NSString stringWithFormat:@"ProfileBadgeStatus%@.png", self.contactObj.badgeStatus];
        [self.imageViewSeequStatus setImage:[UIImage imageNamed:imageName]];
    }
    self.textViewNote.text = [self.contactObj.content stringByAppendingString:@"\n\n\n"];
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) setSessionCount:(int)count {
    NSString *text = [NSString stringWithFormat:@"%d", count];
	CGSize textSize = CGSizeMake(500, 500.0f);
	CGSize size = [text sizeWithFont:self.labelSessionCount.font constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    self.labelSessionCount.frame = CGRectMake(self.labelSessionCount.center.x - size.width/2,
                                              self.labelSessionCount.frame.origin.y,
                                              size.width+2,
                                              size.height);
    
    self.viewSessinoCountBG.frame = CGRectMake(self.labelSessionCount.frame.origin.x - 3,
                                               self.labelSessionCount.frame.origin.y,
                                               self.labelSessionCount.frame.size.width + 6,
                                               self.labelSessionCount.frame.size.height);
    self.labelSessionCount.text = text;
}

- (void) setRatingStars:(int)stars {
    for (UIImageView *imageView in self.scrollViewContent.subviews) {
        if (imageView.tag == STAR_IMAGE_TAG) {
            [imageView removeFromSuperview];
        }
    }

    for (int i = 0; i < stars; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(58 - (stars*12)/2 + i * 12, 133, 12, 11)];
        starImageView.tag = STAR_IMAGE_TAG;
        starImageView.image = [UIImage imageNamed:@"contactRatingStar.png"];
        
        [self.scrollViewContent addSubview:starImageView];
    }
}

- (void) setOnlineStatus:(online_Status)online {
    switch (online) {
        case online_Status_Online: {
            [self.imageViewContactOnlineStatus setImage:[UIImage imageNamed:@"highlightedOnline.png"]];
        }
            break;
        case online_Status_Offline: {
            [self.imageViewContactOnlineStatus setImage:[UIImage imageNamed:@"highlightedOffline.png"]];
        }
            break;
        case online_Status_Away: {
            [self.imageViewContactOnlineStatus setImage:[UIImage imageNamed:@"highlightedUndefined.png"]];
        }
            break;
        default:
            break;
    }
}

- (IBAction) onButtonContactDetail:(id)sender {
    SeequContactProfileDetailViewController *profileDetailViewController = [[SeequContactProfileDetailViewController alloc] initWithNibName:@"SeequContactProfileDetailViewController" bundle:nil];
    profileDetailViewController.contactObj = self.contactObj;
    profileDetailViewController.videoViewState = self.videoViewState;
    profileDetailViewController.accessToConnections = YES;
    [self.navigationController pushViewController:profileDetailViewController animated:YES];
}

- (IBAction)onButtonAccept:(id)sender {
    NSLog(@"DEBUG: {RequestView}[onButtonAccept]");
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        self.buttonAccept.enabled = NO;
        self.buttonDecline.enabled = NO;

        if ([_delegate respondsToSelector:@selector(SeequConnectionRequest:didAcceptWithContactObject:)]) {
            [_delegate SeequConnectionRequest:self didAcceptWithContactObject:self.contactObj];
        }
    }
}

- (IBAction)onButtonDecline:(id)sender {
    NSLog(@"DEBUG: {RequestView}[onButtonAccept]");
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        self.buttonAccept.enabled = NO;
        self.buttonDecline.enabled = NO;
        if ([_delegate respondsToSelector:@selector(SeequConnectionRequest:didDeclineWithContactObject:)]) {
            [_delegate SeequConnectionRequest:self didDeclineWithContactObject:self.contactObj];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageViewProfile:nil];
    [self setViewSessinoCountBG:nil];
    [self setLabelSessionCount:nil];
    [self setLabelDisplayName:nil];
    [self setLabelSpecialist:nil];
    [self setLabelCompany:nil];
    [self setLabelLocation:nil];
    [self setImageViewContactOnlineStatus:nil];
    [self setImageViewSeequStatus:nil];
    [self setTextViewDescription:nil];
    [self setTextViewNote:nil];

    [self setLabelRequestType:nil];
    [self setScrollViewContent:nil];
    [self setViewFooter:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
