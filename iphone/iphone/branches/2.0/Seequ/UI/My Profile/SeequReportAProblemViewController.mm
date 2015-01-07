//
//  SeequReportAProblemViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/6/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequReportAProblemViewController.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"

@interface SeequReportAProblemViewController ()

@end

@implementation SeequReportAProblemViewController

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
    if(IS_IOS_7){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
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
        self.textViewDescription.frame = CGRectMake(14, 83 - 44, 291, self.textViewDescription.frame.size.height + 88);
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
            if(IS_IOS_7)
                frame = CGRectMake(0, 64, 320, 416 + diff);
            else
                frame = CGRectMake(0, 44, 320, 416 + diff);
//            if (state == VideoViewState_HIDE) {
//                if (![UIApplication sharedApplication].statusBarHidden) {
//                    self.view.frame = CGRectMake(0, 0, 320, 460 + diff);
//                }
//            }
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 320 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 320 - diff));
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 228 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 228 - diff));
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

- (void) onButtonCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onButtonSend:(id)sender {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextViewDescription:nil];
    [self setImageViewTextBG:nil];
    [self setScrollViewContent:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
