//
//  SeequInviteViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/3/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequInviteViewController.h"
#import "SeequRingBackViewController.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"
#import "NavigationBar.h"
#import "BackBarButton.h"

@interface SeequInviteViewController ()

@end

@implementation SeequInviteViewController

@synthesize email;
@synthesize videoViewState;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.email = nil;
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
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleInvite.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack:)];
    
    self.navigationItem.leftBarButtonItem = backBarButton;    

    self.scrollViewContent.contentSize = CGSizeMake(320, 367);
    if (UIInterfaceOrientationIsPortrait([idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation)) {
        [self setVideoViewState:self.videoViewState Animated:NO];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.email) {
        self.textFieldEMail.text = self.email;
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
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onButtonInvite:(id)sender {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
      
        if (self.textFieldEMail.text && self.textFieldEMail.text.length && [Common validateEmail:self.textFieldEMail.text]) {
            [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Sending Invitation e-mail."];
            [self.textFieldEMail resignFirstResponder];
            [NSThread detachNewThreadSelector:@selector(SendInvotationWithEmail) toTarget:self withObject:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                            message:@"Please enter valid email address"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (IBAction)onButtonRingBack:(id)sender {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        if (self.textFieldEMail.text && self.textFieldEMail.text.length && [Common validateEmail:self.textFieldEMail.text]) {
            [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Sending Ringback to e-mail."];
            [self.textFieldEMail resignFirstResponder];
            [NSThread detachNewThreadSelector:@selector(SendRingbackWithEmail) toTarget:self withObject:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                            message:@"Please enter valid email address"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (IBAction)onButtonAdd:(id)sender {
}

- (void) SendRingbackWithEmail {
    NSString *error_message = [Common SendRingbackEmailWithEmail:self.textFieldEMail.text SeequID:[Common sharedCommon].contactObject.SeequID];
    
    if (error_message) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
            [[idoubs2AppDelegate sharedInstance]ShowDefaultMessageWithText:error_message];
        }
    }else{
            [[idoubs2AppDelegate sharedInstance] changeLoadingViewMessage:@"Ringback is sent"];
    }
            
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self HideLoadingView];
        });
}

- (void) SendInvotationWithEmail {
    NSString *error_message = [Common SendInvitationEmailWithEmail:self.textFieldEMail.text SeequID:[Common sharedCommon].contactObject.SeequID];

    if (error_message) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
            [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:error_message];
        }
    }else{
            [[idoubs2AppDelegate sharedInstance]  changeLoadingViewMessage:@"Invitation is sent"];
    }
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self HideLoadingView];
        });
}

- (void) HideLoadingView {
    [[idoubs2AppDelegate sharedInstance] HideLoadingView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextFieldEMail:nil];
    [self setScrollViewContent:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
