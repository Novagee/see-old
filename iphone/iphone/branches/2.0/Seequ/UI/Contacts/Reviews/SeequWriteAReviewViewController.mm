//
//  SeequWriteAReviewViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/12/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequWriteAReviewViewController.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"


#define STAR_IMAGE_TAG 88


@interface SeequWriteAReviewViewController ()

@end

@implementation SeequWriteAReviewViewController

@synthesize delegate = _delegate;
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

    [self RateWithStar:0];
    isRated = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewOrientationChange:) name:kVideoViewOrientationChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectUpdateEvent:) name:kContactObjectUpdateNotification object:nil];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [self.scrollViewContent addGestureRecognizer:singleTap];
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture {
    CGPoint touchPoint=[gesture locationInView:self.scrollViewContent];

    for (int i = 0; i < 5; i++) {
        if (CGRectContainsPoint(imageViewStars[i].frame, touchPoint)) {
            [self RateWithStar:i];
            return;
        }
    }
    
    [self RateWithStar:-1];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textFieldTitle becomeFirstResponder];

    self.scrollViewContent.contentSize = CGSizeMake(320, 191);
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
            frame = CGRectMake(0, 44, 320, 191 + diff);
            if (state == VideoViewState_HIDE) {
                if (![UIApplication sharedApplication].statusBarHidden) {
                    self.view.frame = CGRectMake(0, 20, 320, 460 + diff);
                }
            }
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 320 - diff, 320, (191 - (self.view.frame.size.height - 320 - diff)) + 74 + diff);
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 228 - diff, 320, (191 - (self.view.frame.size.height - 228 - diff)) + 74 + diff);
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
        NSString *seequId= [notification object];
    
    if (seequId) {
        if ([self.contactObj.SeequID isEqualToString:seequId]) {
            self.contactObj =[[ContactStorage sharedInstance] GetContactObjectBySeequId:seequId];
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

- (void)viewDidUnload {
    [self setImageViewProfile:nil];
    [self setLabelDisplayName:nil];
    [self setLabelSpecialist:nil];
    [self setLabelCompany:nil];
    [self setImageViewContactOnlineStatus:nil];

    [self setTextFieldTitle:nil];
    [self setTextFieldReview:nil];
    [self setImageViewSeequStatus:nil];
    [self setLabelTapAStarToRate:nil];
    [self setScrollViewContent:nil];
    [super viewDidUnload];
}

- (IBAction)onButtonCancel:(id)sender {
    [self   dismissViewControllerAnimated:YES completion:nil ];
}

- (IBAction)onButtonSend:(id)sender {
    if (isRated && self.textFieldTitle.text.length && self.TextFieldReview.text.length) {
        [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Sending Review"];
        [self.textFieldTitle resignFirstResponder];
        [self.TextFieldReview resignFirstResponder];
        
        [NSThread detachNewThreadSelector:@selector(send_Rating_Request) toTarget:self withObject:nil];
        
        return;
    }
    
    if (!isRated) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                        message:@"Please add a rating to your review."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                        message:@"Empty field."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) RateWithStar:(int)stars {
    rate = stars;
    if (!imageViewStars[0]) {
        for (int i = 0; i < 5; i++) {
            imageViewStars[i] = [[UIImageView alloc] initWithFrame:CGRectMake(160 + i * 31, 126 - 44, 22, 21)];
            [imageViewStars[i] setImage:[UIImage imageNamed:@"reviewsStar.png"]];
            [self.scrollViewContent addSubview:imageViewStars[i]];
        }
        return;
    }
    
    for (int i = 0; i < 5; i++) {
        if (i <= stars) {
            [imageViewStars[i] setImage:[UIImage imageNamed:@"reviewsStarSel.png"]];
            isRated = YES;
        } else {
            [imageViewStars[i] setImage:[UIImage imageNamed:@"reviewsStar.png"]];
        }
    }
    
    if (stars == -1) {
        rate = 0;
        isRated = NO;
    }
}

- (void) setRatingStars:(int)stars {
    for (UIImageView *imageView in self.scrollViewContent.subviews) {
        if (imageView.tag == STAR_IMAGE_TAG) {
            [imageView removeFromSuperview];
        }
    }

    for (int i = 0; i < stars; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(276 - (stars*12)/2 + i * 12, 77 - 44, 12, 11)];
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

- (void) send_Rating_Request {
    @autoreleasepool {
        NSDictionary *dict;
        NSString *error_message = [Common send_Rating_RequestWithSeequID:self.contactObj.SeequID
                                                              Title:self.textFieldTitle.text
                                                            Content:self.TextFieldReview.text
                                                        RatingValue:(rate + 1)
                                                        ReturnDictionary:&dict];
        
        if (error_message) {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                [self performSelectorOnMainThread:@selector(ShowErrorMessageWithMessage:) withObject:error_message waitUntilDone:YES];
            }
            
            return;
        } else {
            self.contactObj.ratingCount++;
            self.contactObj.ratingValue = [[dict objectForKey:@"ratingValue"] floatValue];
            
            if (self.contactObj.ID) {
                error_message = [Common UpdateRequestWithID:self.contactObj.ID
                                                       Date:[[NSDate date] timeIntervalSince1970]
                                                     Status:@"Accepted"];
                
                if (error_message) {
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                        [self performSelectorOnMainThread:@selector(ShowErrorMessageWithMessage:) withObject:error_message waitUntilDone:YES];
                    }

                    return;
                }
            }
        }
        
        [self performSelectorOnMainThread:@selector(HideLoadingView) withObject:nil waitUntilDone:YES];        
    }
}

- (void) HideLoadingView {
    [self.contactObj UpdateProfileDataAsynchronously];
    [[idoubs2AppDelegate sharedInstance] HideLoadingView];
    [self dismissViewControllerAnimated:YES completion:nil];

    if ([_delegate respondsToSelector:@selector(didSendReview:)]) {
        [_delegate didSendReview:self];
    }
}

- (void) ShowErrorMessageWithMessage:(NSString*)message {
    [[idoubs2AppDelegate sharedInstance] HideLoadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end