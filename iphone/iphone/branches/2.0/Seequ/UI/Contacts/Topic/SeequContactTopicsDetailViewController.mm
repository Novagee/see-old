//
//  SeequContactTopicsDetailViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/9/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequContactTopicsDetailViewController.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"
#import "NavigationBar.h"
#import "BackBarButton.h"


#define STAR_IMAGE_TAG 88


@interface SeequContactTopicsDetailViewController ()

@end

@implementation SeequContactTopicsDetailViewController

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
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleTopicDetails.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack:)];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    
//    BackBarButton *actionBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequActionButton.png"]
//                                                                    style:UIBarButtonItemStylePlain
//                                                                   target:self
//                                                                   action:@selector(onButtonAction:)];
//    
//    self.navigationItem.rightBarButtonItem = actionBarButton;

    self.scrollViewContent.contentSize = CGSizeMake(320, 367);
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

    CGRect frame = CGRectZero;
    switch (state) {
        case VideoViewState_NONE:
        case VideoViewState_NORMAL:
        case VideoViewState_NORMAL_MENU:
        case VideoViewState_HIDE: {
            frame = CGRectMake(0, 0, 320, 367);
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 271, 320, self.view.frame.size.height - (self.view.frame.size.height - 271));
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 179, 320, self.view.frame.size.height - (self.view.frame.size.height - 179));
        }
            break;
        default:
            break;
    }
    
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        self.scrollViewContent.contentSize = frame.size;
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
            self.contactObj = [[ContactStorage sharedInstance] GetContactObjectBySeequId:seequId];
            [self UpdateUI];
        }
    }
}

- (void) UpdateUI {
    self.imageViewProfile.image = self.contactObj.image;
    [self setRatingStars:ceilf(self.contactObj.ratingValue)];
    self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@", self.contactObj.FirstName, self.contactObj.LastName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onXMPPStatusEvent:) name:kXMPPStatusChangeNotification object:nil];
    
    [self setOnlineStatus:self.contactObj.isOnline];
    self.labelSpecialist.text = self.contactObj.specialist;
    self.labelCompany.text = self.contactObj.company;
    
    if (self.contactObj.badgeStatus) {
        NSString *imageName = [NSString stringWithFormat:@"ProfileBadgeStatus%@.png", self.contactObj.badgeStatus];
        [self.imageViewSeequStatus setImage:[UIImage imageNamed:imageName]];
    }
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onButtonAction:(id)sender {
    //    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share this Profile"
    //                                                             delegate:self
    //                                                    cancelButtonTitle:@"Cancel"
    //                                               destructiveButtonTitle:nil
    //                                                    otherButtonTitles:@"Email", @"SMS", @"Facebook", @"Twitter", nil];
    //    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void) onXMPPStatusEvent:(NSNotification*)notification {
    NSDictionary* eargs = [notification object];
    
    if (eargs) {
        NSString *seequID = [eargs objectForKey:@"SeequID"];
        
        if ([self.contactObj.SeequID isEqualToString:seequID]) {
            online_Status online = (online_Status)[[eargs objectForKey:@"Status"] intValue];
            [self setOnlineStatus:online];
        }
    }
}

- (void) setOnlineStatus:(online_Status)online {
    if (!self.imageViewContactOnlineStatus) {
        self.imageViewContactOnlineStatus = [[UIImageView alloc] initWithFrame:CGRectMake(222, 20, 7, 6)];
    }
    
    switch (online) {
        case online_Status_Online: {
            [self.imageViewContactOnlineStatus setImage:[UIImage imageNamed:@"contactOnlineLabel.png"]];
        }
            break;
        case online_Status_Offline: {
            [self.imageViewContactOnlineStatus setImage:[UIImage imageNamed:@"contactOffLineLabel.png"]];
        }
            break;
        case online_Status_Away: {
            [self.imageViewContactOnlineStatus setImage:[UIImage imageNamed:@"contactAwayLabel.png"]];
        }
            break;
        default:
            break;
    }
}

- (void) setRatingStars:(int)stars {
    for (UIImageView *imageView in self.view.subviews) {
        if (imageView.tag == STAR_IMAGE_TAG) {
            [imageView removeFromSuperview];
        }
    }

    for (int i = 0; i < stars; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(276 - (stars*12)/2 + i * 12, 33, 12, 11)];
        starImageView.tag = STAR_IMAGE_TAG;
        starImageView.image = [UIImage imageNamed:@"contactRatingStar.png"];
        
        [self.view addSubview:starImageView];
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
    [self setImageViewContactOnlineStatus:nil];
    [self setImageViewSeequStatus:nil];
    [self setScrollViewContent:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end