//
//  SeequContactProfileViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 9/27/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//
#import "ActivityStorage.h"
#import "SeequContactProfileViewController.h"
#import "SeequContactProfileDetailViewController.h"
#import "SeequRingBackViewController.h"
#import "SeequRequestConnectionViewController.h"
#import "SeequRequestReviewViewController.h"
#import "SeequSendMessageViewController.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"
#import <QuartzCore/QuartzCore.h> /* cornerRadius... */
#import "NavigationBar.h"
#import "BackBarButton.h"
#import "UserStatusCoreData.h"


#define STAR_IMAGE_TAG 88


@interface SeequContactProfileViewController ()

@end

@implementation SeequContactProfileViewController

@synthesize contactObj;
@synthesize videoViewState;
@synthesize accessToConnections;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.accessToConnections = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(IS_IOS_7){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    // Do any additional setup after loading the view from its nib.
    [self UpdateUI];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewOrientationChange:) name:kVideoViewOrientationChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onXMPPStatusEvent:) name:kXMPPStatusChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectEvent:) name:kContactObjectChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectUpdateEvent:) name:kContactObjectUpdateNotification object:nil];

    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

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
//        UIButton *contactDetail=[UIButton buttonWithType:UIButtonTypeCustom];
//        [contactDetail addTarget:self action:@selector(oncontactDetail) forControlEvents:UIControlEventTouchDown];
//        [contactDetail setImage:[UIImage imageNamed:@"defaultSeequBackButton.png"] forState:UIControlStateSelected];
//        [contactDetail setImage:[UIImage imageNamed:@"defaultSeequBackButton.png"] forState:UIControlStateNormal];
        BackBarButton *contactDetail=[[BackBarButton alloc] initWithImage:[UIImage imageNamed: @"ProfileContactdetail.png" ] style:UIBarButtonItemStylePlain target:self action:@selector(onButtonContactDetail:)];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
        self.navigationItem.rightBarButtonItem=contactDetail;
        self.profileDetailView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"profileDetailViewBackground.png"]];
        self.profileDetailView.hidden=YES;
        
        
//    BackBarButton *actionBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequActionButton.png"]
//                                                                  style:UIBarButtonItemStylePlain
//                                                                 target:self
//                                                                 action:@selector(onButtonAction:)];

//    self.navigationItem.rightBarButtonItem = actionBarButton;
     
    [self UpdateButtonsState];
    
    screen_diff = 0;
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 568) {
        screen_diff = 88;
    }
    
    int statusBarHeight = 0;

    if (self.view.frame.size.height == 386 || self.view.frame.size.height == 387 || self.view.frame.size.height == 474 || self.view.frame.size.height == 475) {
        statusBarHeight = 20;
    }
    
    self.scrollView.contentSize = CGSizeMake(320, 367 + screen_diff + statusBarHeight);
    self.textViewDescription.frame = CGRectMake(112, 83, 200, 107 + screen_diff);
    self.viewFooter.frame = CGRectMake(0, self.view.frame.size.height - self.viewFooter.frame.size.height, 320, 169);
    self.textViewDescription.frame = CGRectMake(self.textViewDescription.frame.origin.x, self.textViewDescription.frame.origin.y, self.textViewDescription.frame.size.width, self.viewFooter.frame.origin.y - self.textViewDescription.frame.origin.y - 11);
//    NSLog(@"self.viewFooter.frame: %@", NSStringFromCGRect(self.viewFooter.frame));
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (UIInterfaceOrientationIsPortrait([idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation)) {
        [self setVideoViewState:self.videoViewState Animated:NO];
    }
}
-(void)viewWillLayoutSubviews{
        [super viewWillLayoutSubviews];
         self.imageViewProfile.frame=CGRectMake(0,0, self.view.frame.size.width,self.viewFooter.frame.origin.y);
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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

- (IBAction) onButtonMute:(id)sender {
        [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Mute..."];
        [NSThread detachNewThreadSelector:@selector(Mute) toTarget:self withObject:nil];
        
}
-(void)Mute{
        NSString *error_message=[Common AddMuteUserWithSeequId:self.contactObj.SeequID];
        if (error_message) {
                [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:error_message];
        }else{
               if (![[ContactStorage sharedInstance] IsUserAvailable:self.contactObj.SeequID]) {
                NSMutableDictionary *userInfo=[[NSMutableDictionary alloc] initWithDictionary:[Common GetUserDetailsByPTID:self.contactObj.SeequID]];
                [userInfo setValue:[NSString stringWithFormat:@"%@",[NSNumber numberWithBool:YES]] forKey:@"isMute"];
                [[ContactStorage sharedInstance] InsertContactFromDictionary:userInfo];
              }else{
                [[ContactStorage sharedInstance] setIsUserMute:self.contactObj.SeequID isMute:YES];
              }
        }
       [self performSelectorOnMainThread:@selector(HideLoadingView) withObject:nil waitUntilDone:YES];
        [self hideProfileDetailView];
}

- (IBAction)onButtonUnMute:(id)sender{
        [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"UnMute..."];
        [NSThread detachNewThreadSelector:@selector(unMute) toTarget:self withObject:nil];
        
}
-(void)unMute{
        NSString *error_message=[Common RemoveMuteUserWithSeequId:self.contactObj.SeequID];
        if (error_message) {
                [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:error_message];
                
        }else{
                [[ContactStorage sharedInstance] setIsUserMute:self.contactObj.SeequID isMute:NO];
        }
        [self performSelectorOnMainThread:@selector(HideLoadingView) withObject:nil waitUntilDone:YES];       [self hideProfileDetailView];
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

    CGRect frame = CGRectZero;
    
    switch (state) {
        case VideoViewState_NONE:
        case VideoViewState_NORMAL:
        case VideoViewState_NORMAL_MENU:
        case VideoViewState_HIDE: {
            frame = self.view.frame;
            self.viewFooter.frame = CGRectMake(0, self.view.frame.size.height - self.viewFooter.frame.size.height, 320, 169);
            self.textViewDescription.frame = CGRectMake(self.textViewDescription.frame.origin.x, self.textViewDescription.frame.origin.y, self.textViewDescription.frame.size.width, self.viewFooter.frame.origin.y - self.textViewDescription.frame.origin.y - 11);
//            NSLog(@"self.viewFooter.frame: %@", NSStringFromCGRect(self.viewFooter.frame));
            self.scrollView.scrollEnabled = NO;
            
            if (self.viewFooter.frame.origin.y == 266) {
                self.viewFooter.frame = CGRectMake(0, 286, 320, 169);
            } else {
                if (self.viewFooter.frame.origin.y == 266 - 88) {
                    self.viewFooter.frame = CGRectMake(0, 286 - 88, 320, 169);
                }
            }
            
            
            frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.view.frame.size.height);
        }
            
            
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 271 - screen_diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 271 - screen_diff));
            self.scrollView.scrollEnabled = YES;
//            self.scrollView.frame = frame;

        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 179 - screen_diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 179 - screen_diff));
            self.scrollView.scrollEnabled = YES;
//            self.scrollView.frame = frame;
        }
            break;
        default:
            break;
    }
    
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        if (animated) {
            [UIView beginAnimations:@"TableFrame" context:nil];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.3];
        }
        
        self.scrollView.frame = frame;
        if (animated) {
            [UIView commitAnimations];
        }
    }

    [self UpdateButtonsState];
}

- (IBAction)onButtonVoiceCall:(id)sender {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        [[idoubs2AppDelegate sharedInstance].videoService CallWithContactObject:self.contactObj Video:NO];
    }
}

- (IBAction)onButtonCameraCall:(id)sender {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        [[idoubs2AppDelegate sharedInstance].videoService CallWithContactObject:self.contactObj Video:YES];
    }
}

- (IBAction)onButtonMessage:(id)sender {
    [idoubs2AppDelegate sharedInstance].messageFromNotification = YES;
    [idoubs2AppDelegate sharedInstance].messageFromLocalNotification = YES;
    [idoubs2AppDelegate sharedInstance].pushMessageUserName = self.contactObj.SeequID;
    
    [idoubs2AppDelegate sharedInstance].messageNavigationTitle = [self.contactObj displayName];
    [[idoubs2AppDelegate sharedInstance].messages popToRootViewControllerAnimated:NO];
    [idoubs2AppDelegate RefreshTab];
    self.tabBarController.selectedIndex = 1;
    
    return;
}

- (IBAction)onButtonRingback:(id)sender {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        SeequRingBackViewController *ringBackViewController = [[SeequRingBackViewController alloc] initWithNibName:@"SeequRingBackViewController" bundle:nil];
        ringBackViewController.contactObj = self.contactObj;
        ringBackViewController.videoViewState = self.videoViewState;
        [self.tabBarController presentViewController:ringBackViewController animated:YES completion:nil];
    }
}

- (IBAction)onButtonAddToMySeequ:(id)sender {
    RSLogUI(@"[ContactProfile] \"Add to My Seequ\" clicked");
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        SeequRequestConnectionViewController *requestConnectionViewController = [[SeequRequestConnectionViewController alloc] initWithNibName:@"SeequRequestConnectionViewController" bundle:nil];
        requestConnectionViewController.contactObj = self.contactObj;
        [self.tabBarController presentViewController:requestConnectionViewController animated:YES completion:nil];
    }
}

- (IBAction)onButtonAddToFavorites:(id)sender {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Adding to favorites."];
        [NSThread detachNewThreadSelector:@selector(AddToFavorites) toTarget:self withObject:nil];
    }
}

- (IBAction)onButtonRemoveFavorite:(id)sender {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Removing from favorites."];
        [NSThread detachNewThreadSelector:@selector(RemoveFavorite) toTarget:self withObject:nil];
    }
}

- (IBAction)onButtonRequestReview:(id)sender {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        SeequRequestReviewViewController *viewController = [[SeequRequestReviewViewController alloc] initWithNibName:@"SeequRequestReviewViewController" bundle:nil];
        viewController.contactObj = self.contactObj;
        viewController.videoViewState = self.videoViewState;
        [self.tabBarController presentViewController:viewController animated:YES completion:nil];
    }
}

- (IBAction)onButtonConnectionRequested:(id)sender {
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onButtonAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share this Profile"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Email", @"SMS", @"Facebook", @"Twitter", nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex === %d", buttonIndex);
}

//- (void) onXMPPStatusEvent:(NSNotification*)notification {
//    NSDictionary* eargs = [notification object];
//    
//    if (eargs) {
//        NSString *seequID = [eargs objectForKey:@"SeequID"];
//        
//        if ([self.contactObj.SeequID isEqualToString:seequID]) {
//            online_Status online = (online_Status)[[eargs objectForKey:@"Status"] intValue];
//            [self setOnlineStatus:online];
//        }
//    }
//}

//- (void) onContactObjectEvent:(NSNotification*)notification {
//    NSString* seequId= [notification object];
//    
//    if (seequId) {
//        if ([self.contactObj.SeequID isEqualToString:seequId]) {
//            self.contactObj=[[ContactStorage sharedInstance] GetContactObjectBySeequId:seequId];
//            [self UpdateButtonsState];
//        }
//    }
//}

- (void) onContactObjectUpdateEvent:(NSNotification*)notification {
    NSString *seequId=[notification object];
    
    if (seequId) {
        if ([self.contactObj.SeequID isEqualToString:seequId]) {
            self.contactObj =[[ContactStorage sharedInstance] GetContactObjectBySeequId:seequId] ;
            [self UpdateUI];
            [self UpdateButtonsState];
        }
    }
}
- (void) UpdateUI {
        int delta=0;
       if(IS_IOS_7){
               delta=20;
        }
    self.navigationItem.title=[NSString stringWithFormat:@"%@ %@",self.contactObj.FirstName,self.contactObj.LastName];
    self.imageViewProfile.contentMode=UIViewContentModeScaleAspectFill;
   
    self.imageViewProfile.image = self.contactObj.image;
    [self setSessionCount:self.contactObj.SessionsCount];
    self.viewSessinoCountBG.layer.cornerRadius = 7.f;
    [self setRatingStars:ceilf(self.contactObj.ratingValue)];
    
//    SeequContactsViewController *contactsViewController = [[idoubs2AppDelegate sharedInstance].contacts.viewControllers objectAtIndex:0];
//    
//    if (contactsViewController && [contactsViewController isKindOfClass:[SeequContactsViewController class]]) {
//        ContactObject *obj = [contactsViewController CheckObjectInArrayWithPT:self.contactObj.SeequID];
//        if (!obj) {
//            self.contactObj.isOnline = online_Status_Away;
//        } else {
//            self.contactObj.isOnline = obj.isOnline;
//        }
//    }
    
    [self setOnlineStatus:self.contactObj.isOnline];
    self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@", self.contactObj.FirstName, self.contactObj.LastName];
    self.textViewDescription.editable = NO;
    self.labelSpecialist.text = self.contactObj.specialist;
    self.labelCompany.text = self.contactObj.company;
//    self.textViewDescription.text = self.contactObj.introduction;
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

- (void) setSessionCount:(int)count {
    NSString *text = [NSString stringWithFormat:@"%d", count];
	CGSize textSize = CGSizeMake(500, 500.0f);
	CGSize size = [text sizeWithFont:self.labelSessionCount.font constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    self.labelSessionCount.frame = CGRectMake(58 - size.width/2,
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
    return;
    for (UIImageView *imageView in self.scrollView.subviews) {
        if (imageView.tag == STAR_IMAGE_TAG) {
            [imageView removeFromSuperview];
        }
    }

    for (int i = 0; i < stars; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.labelSessionCount.center.x - (stars*12)/2 + i * 12, 133, 12, 11)];
        starImageView.tag = STAR_IMAGE_TAG;
        starImageView.image = [UIImage imageNamed:@"contactRatingStar.png"];
        
        [self.scrollView addSubview:starImageView];
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

- (IBAction)onButtonContactDetail:(id)sender {
        if (self.profileDetailView.hidden) {
                [self showProfileDetailView];
        }else{
                [self hideProfileDetailView];
        }
        
//    SeequContactProfileDetailViewController *profileDetailViewController = [[SeequContactProfileDetailViewController alloc] initWithNibName:@"SeequContactProfileDetailViewController" bundle:nil];
//    profileDetailViewController.contactObj = self.contactObj;
//    profileDetailViewController.videoViewState = self.videoViewState;
//    profileDetailViewController.accessToConnections = self.accessToConnections;
//    [self.navigationController pushViewController:profileDetailViewController animated:YES];
}
-(void)showProfileDetailView{
        self.profileDetailView.hidden=NO;
        [UIView beginAnimations:@"showProfileDetailView" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.3];
        self.profileDetailView.frame=CGRectMake(0, 0, self.profileDetailView.frame.size.width
                                                , self.profileDetailView.frame.size.height);
        [UIView commitAnimations];
}
-(void)hideProfileDetailView{
        self.profileDetailView.hidden=YES;
        [UIView beginAnimations:@"showProfileDetailView" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3];
        self.profileDetailView.frame=CGRectMake(0, -50, self.profileDetailView.frame.size.width
                                                , self.profileDetailView.frame.size.height);
        [UIView commitAnimations];

}
- (IBAction) onButtonDisconnect:(id)sender {
        RSLogUI(@"[ContactProfileDetails] Disconnect clicked");
        if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
                [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
        } else {
                [[idoubs2AppDelegate getChatManager] RemoveBuddy:self.contactObj.SeequID];
                [self.navigationController popToRootViewControllerAnimated:YES];
        }
}

- (void) UpdateButtonsState {
    
    switch (self.contactObj.contactType) {
        case Contact_Type_Recent:
        case Contact_Type_MY_Seequ_Contact:
        case Contact_Type_Request_For_Ringback: {
            self.buttonVoiceCall.enabled = YES;
            self.buttonCameraCall.enabled = YES;
            self.buttonMessage.enabled = YES;
            self.buttonRingback.enabled = YES;

            self.buttonAddToMySeequ.hidden = YES;
           [self.buttonAddContact setHidden:YES];
           [self.ButtonRemoveContact setHidden:NO];
            self.buttonConnectionRequested.hidden = YES;
                self.buttonAddToFavorites.hidden=self.contactObj.isFavorite;
                self.buttonRemoveFavorite.hidden=!self.contactObj.isFavorite;
//            if ([Common CheckFavoriteWithSeequID:self.contactObj.SeequID]) {
//                self.buttonAddToFavorites.hidden = YES;
//                self.buttonRemoveFavorite.hidden = NO;
//            } else {
//                self.buttonAddToFavorites.hidden = NO;
//                self.buttonRemoveFavorite.hidden = YES;
//            }
//            self.buttonRequestReview.hidden = NO;
        }
            break;
        case Contact_Type_Seequ_Contact: {
            self.buttonVoiceCall.enabled = NO;
            self.buttonCameraCall.enabled = NO;
            self.buttonMessage.enabled = NO;
            self.buttonRingback.enabled = NO;
            
            self.buttonAddToMySeequ.hidden = NO;
            [self.buttonAddContact setHidden:NO];
            [self.ButtonRemoveContact setHidden:YES];
            self.buttonConnectionRequested.hidden = YES;
            self.buttonAddToFavorites.hidden = YES;
            self.buttonRemoveFavorite.hidden = YES;
            self.buttonRequestReview.hidden = YES;
        }
            break;
        case Contact_Type_Request_Connection:
        case Contact_Type_Request_For_Connection: {
            self.buttonVoiceCall.enabled = NO;
            self.buttonCameraCall.enabled = NO;
            self.buttonMessage.enabled = NO;
            self.buttonRingback.enabled = NO;

            self.buttonAddToMySeequ.hidden = YES;
            [self.buttonAddContact setHidden:NO];
            [self.ButtonRemoveContact setHidden:YES];
            self.buttonConnectionRequested.hidden = NO;
            self.buttonAddToFavorites.hidden = YES;
            self.buttonRemoveFavorite.hidden = YES;
            self.buttonRequestReview.hidden = YES;
        }
            break;
            
        default:
            break;
    }
        if ([[ContactStorage sharedInstance] IsUserAvailable:self.contactObj.SeequID]) {
                UserInfoCoreData *userInfo=[[ContactStorage sharedInstance] getUserInfoBySeequId:self.contactObj.SeequID];
                self.muteButton.hidden=[userInfo.isMute boolValue];
                self.unMuteButton.hidden=![userInfo.isMute boolValue];
        }else{
                self.muteButton.hidden=NO;
                self.unMuteButton.hidden=YES;
        }
    
    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
        self.buttonVoiceCall.enabled = NO;
        self.buttonCameraCall.enabled = NO;
    }
}

- (void) AddToFavorites {
    @autoreleasepool {
        NSString *error_message = [Common AddFavoriteWithSeequID:self.contactObj.SeequID];
        
        if (error_message) {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(ShowDefaultMessageWithText:) withObject:error_message waitUntilDone:YES];
            }
        } else {
            self.contactObj.isFavorite = YES;
            [[ContactStorage sharedInstance] setIsUserFavorit:self.contactObj.SeequID isFavorit:YES];
//            [Common addOrRemovecContactInFavoriteList:YES withSeequID:self.contactObj.SeequID];
        }
    }
    
    [self performSelectorOnMainThread:@selector(HideLoadingView) withObject:nil waitUntilDone:YES];
}

- (void) RemoveFavorite {
    NSString *error_message = [Common RemoveFavoriteWithSeequID:self.contactObj.SeequID];
    
    if (error_message) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
            [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(ShowDefaultMessageWithText:) withObject:error_message waitUntilDone:YES];
        }
    } else {
        self.contactObj.isFavorite = NO;
        [[ContactStorage sharedInstance] setIsUserFavorit:self.contactObj.SeequID isFavorit:NO];
//        [Common addOrRemovecContactInFavoriteList:NO withSeequID:self.contactObj.SeequID];
    }
    
    [self performSelectorOnMainThread:@selector(HideLoadingView) withObject:nil waitUntilDone:YES];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

}

- (void) HideLoadingView {
  
    [[idoubs2AppDelegate sharedInstance] HideLoadingView];
    [self UpdateButtonsState];
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
    [self setButtonAddToMySeequ:nil];
    [self setButtonAddToFavorites:nil];
    [self setButtonRequestReview:nil];

    [self setButtonVoiceCall:nil];
    [self setButtonCameraCall:nil];
    [self setButtonMessage:nil];
    [self setButtonRingback:nil];
    [self setButtonConnectionRequested:nil];
    [self setButtonRemoveFavorite:nil];
    [self setScrollView:nil];
    [self setViewFooter:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
