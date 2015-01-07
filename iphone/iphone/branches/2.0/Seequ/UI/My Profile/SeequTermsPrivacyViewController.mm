//
//  SeequTermsPrivacyViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/6/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequTermsPrivacyViewController.h"
#import "idoubs2AppDelegate.h"
#import "NavigationBar.h"
#import "BackBarButton.h"

@interface SeequTermsPrivacyViewController ()

@end

@implementation SeequTermsPrivacyViewController

@synthesize videoViewState;
@synthesize segmentState;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.segmentState = nil;
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
    [self onButtonFilter:self.buttonTerms];

    self.scrollView.contentSize = CGSizeMake(320, 750);
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
    
	((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleTermsPrivacy.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack:)];
        
    self.navigationItem.leftBarButtonItem = backBarButton;
    if (UIInterfaceOrientationIsPortrait([idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation)) {
        [self setVideoViewState:self.videoViewState Animated:NO];
    }
    
    if (self.segmentState && [self.segmentState isKindOfClass:[NSString class]]) {
        if ([self.segmentState isEqualToString:@"P"]) {
            [self onButtonFilter:self.buttonPrivacy];
        } else {
            if ([self.segmentState isEqualToString:@"T"]) {
                [self onButtonFilter:self.buttonTerms];
            } else {
                if ([self.segmentState isEqualToString:@"U"]) {
                    [self onButtonFilter:self.buttonUse];
                }
            }
        }
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
            frame = CGRectMake(0, 33, 320, 334 + diff);
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
        self.scrollView.frame = frame;
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onButtonFilter:(id)sender {
    UIButton *button = (UIButton*)sender;
    
    switch (button.tag) {
        case 1: {
            termsPrivacyType = TermsPrivacy_Type_Terms;
            [self.buttonTerms setBackgroundImage:[UIImage imageNamed:@"segMyProfileTermsSel.png"] forState:UIControlStateNormal];
            [self.buttonPrivacy setBackgroundImage:[UIImage imageNamed:@"segMyProfilePrivacy.png"] forState:UIControlStateNormal];
            [self.buttonUse setBackgroundImage:[UIImage imageNamed:@"segMyProfileUse.png"] forState:UIControlStateNormal];
        }
            break;
        case 2: {
            termsPrivacyType = TermsPrivacy_Type_Privacy;
            [self.buttonTerms setBackgroundImage:[UIImage imageNamed:@"segMyProfileTerms.png"] forState:UIControlStateNormal];
            [self.buttonPrivacy setBackgroundImage:[UIImage imageNamed:@"segMyProfilePrivacySel.png"] forState:UIControlStateNormal];
            [self.buttonUse setBackgroundImage:[UIImage imageNamed:@"segMyProfileUse.png"] forState:UIControlStateNormal];
        }
            break;
        case 3: {
            termsPrivacyType = TermsPrivacy_Type_Use;
            [self.buttonTerms setBackgroundImage:[UIImage imageNamed:@"segMyProfileTerms.png"] forState:UIControlStateNormal];
            [self.buttonPrivacy setBackgroundImage:[UIImage imageNamed:@"segMyProfilePrivacy.png"] forState:UIControlStateNormal];
            [self.buttonUse setBackgroundImage:[UIImage imageNamed:@"segMyProfileUseSel.png"] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    
    //    [self filterContactsWithSegment_Type:searchType];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setButtonTerms:nil];
    [self setButtonPrivacy:nil];
    [self setButtonUse:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
