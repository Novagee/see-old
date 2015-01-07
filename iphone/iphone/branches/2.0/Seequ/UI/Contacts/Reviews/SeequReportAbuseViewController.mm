//
//  SeequReportAbuseViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/12/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequReportAbuseViewController.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"


#define STAR_IMAGE_TAG 88


@interface SeequReportAbuseViewController ()

@end

@implementation SeequReportAbuseViewController

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
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.scrollViewContent.contentSize = CGSizeMake(320, 416);
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
            frame = CGRectMake(0, 44, 320, 416 + diff);
            if (state == VideoViewState_HIDE) {
                if (![UIApplication sharedApplication].statusBarHidden) {
                    self.view.frame = CGRectMake(0, 20, 320, 460 + diff);
                }
            }
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 271 - 49 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 271 - diff) + 49);
            self.scrollViewContent.contentSize = CGSizeMake(320, 416 - (self.view.frame.size.height - 271 - 49));
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 179 - 49 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 179 - diff) + 49);
            self.scrollViewContent.contentSize = CGSizeMake(320, 416 - (self.view.frame.size.height - 179 - 49));
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
    ContactObject* eargs = [notification object];
    
    if (eargs) {
        if ([self.contactObj.SeequID isEqualToString:eargs.SeequID]) {
            self.contactObj = eargs;
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
    self.scrollView.frame = CGRectMake(0, 73, 320, 343);
    self.scrollView.contentSize = CGSizeMake(320, 428);
    self.labelSpecialist.text = self.contactObj.specialist;
    self.labelCompany.text = self.contactObj.company;
    
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
    [self setImageViewContactOnlineStatus:nil];
    
    [self setTextFieldTitle:nil];
    [self setTextFieldReview:nil];
    [self setButtonSpam:nil];
    [self setButtonInappCont:nil];
    [self setTextViewDescription:nil];

    [self setScrollView:nil];
    [self setImageViewSeequStatus:nil];
    [self setScrollViewContent:nil];
    [super viewDidUnload];
}

- (IBAction)onButtonCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onButtonSend:(id)sender {
}

- (IBAction)onButtonFilter:(id)sender {
}

- (IBAction)onButtonBlockRequests:(id)sender {
}

- (IBAction)onButtonDisconnect:(id)sender {
}

- (IBAction)onButtonAcceptableUsePolicy:(id)sender {
}

- (void) setRatingStars:(int)stars {
    for (UIImageView *imageView in self.scrollViewContent.subviews) {
        if (imageView.tag == STAR_IMAGE_TAG) {
            [imageView removeFromSuperview];
        }
    }

    for (int i = 0; i < stars; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(276 - (stars*12)/2 + i * 12, 33, 12, 11)];
        starImageView.tag = STAR_IMAGE_TAG;
        starImageView.image = [UIImage imageNamed:@"contactRatingStar.png"];
        
        [self.scrollViewContent addSubview:starImageView];
    }
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
        self.imageViewContactOnlineStatus = [[UIImageView alloc] initWithFrame:CGRectMake(243, 62, 7, 6)];
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

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.scrollView.contentSize = CGSizeMake(320, 486);
    [self.scrollView scrollRectToVisible:CGRectMake(0, self.scrollView.contentSize.height - textView.frame.size.height, 320, textView.frame.size.height) animated:NO];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.scrollView.contentSize = CGSizeMake(320, 428);
}

- (void)textViewDidChange:(UITextView *)textView {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.textViewDescription resignFirstResponder];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end