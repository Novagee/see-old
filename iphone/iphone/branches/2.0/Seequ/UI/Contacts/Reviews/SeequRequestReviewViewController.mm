//
//  SeequRequestReviewViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 12/4/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequRequestReviewViewController.h"
#import "idoubs2AppDelegate.h"
#import "XMPPManager.h"


@interface SeequRequestReviewViewController ()

@end

@implementation SeequRequestReviewViewController


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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewChange:)
                                                 name:kVideoViewChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewOrientationChange:)
                                                 name:kVideoViewOrientationChangeNotification
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textViewDescription becomeFirstResponder];

    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 568) {
        self.imageViewTextBG.frame = CGRectMake(0, 0, 320, 293);
        [self.imageViewTextBG setImage:[UIImage imageNamed:@"seequRingBackBG568.png"]];
        self.textViewDescription.frame = CGRectMake(14, 83 - 44, 291, 232);
        self.scrollViewContent.contentSize = CGSizeMake(320, 416 + 88);
    } else {
        self.scrollViewContent.contentSize = CGSizeMake(320, 416);
    }
    
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
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 179 - 49 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 179 - diff) + 49);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButtonCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onButtonSend:(id)sender {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Sending Request."];
        [self.textViewDescription resignFirstResponder];
        
        [NSThread detachNewThreadSelector:@selector(SendRequestReview) toTarget:self withObject:nil];
    }
}

- (void) SendRequestReview {
    @autoreleasepool {
        
        NSString *error_message = [Common AddRequestWithSeequID:self.contactObj.SeequID
                                                           Date:[[NSDate date] timeIntervalSince1970]
                                                           Name:@"Review"
                                                        Content:self.textViewDescription.text];

        if (error_message) {
            [self performSelectorOnMainThread:@selector(HideLoadingView) withObject:nil waitUntilDone:YES];
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(ShowDefaultMessageWithText:) withObject:error_message waitUntilDone:YES];
            }
            
            return;
        }
        
        [NSThread sleepForTimeInterval:3.0];
        [self performSelectorOnMainThread:@selector(SendXMPPMessageForRefresh) withObject:nil waitUntilDone:YES];
        NSDictionary *dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:@"REVIEW", @"type", nil];
        [Common postNotificationWithName:@"REQUEST" object:dictPostNotification];
    }
    
    [self performSelectorOnMainThread:@selector(HideLoadingView) withObject:nil waitUntilDone:YES];    
}

- (void) HideLoadingView {
    [self.contactObj UpdateProfileDataAsynchronously];
    [[idoubs2AppDelegate sharedInstance] HideLoadingView];
    [self dismissViewControllerAnimated:YES completion:nil ];
}

- (void) SendXMPPMessageForRefresh {
    [[idoubs2AppDelegate getChatManager] SendTextMessage:@"*#===REVIEW===#*" to:self.contactObj.SeequID MessageID:MESSAGE_ID AddToResendList:NO];
}

- (void)viewDidUnload {
    [self setTextViewDescription:nil];
    [self setImageViewTextBG:nil];
    [self setScrollViewContent:nil];
    [super viewDidUnload];
}

@end