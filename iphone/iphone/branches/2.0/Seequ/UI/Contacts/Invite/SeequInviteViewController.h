//
//  SeequInviteViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/3/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeequInviteViewController : UIViewController <UITextFieldDelegate> {
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, strong) NSString *email;
@property (nonatomic, assign) int videoViewState;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollViewContent;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textFieldEMail;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (void) GoBack:(id)sender;
- (IBAction)onButtonInvite:(id)sender;
- (IBAction)onButtonRingBack:(id)sender;
- (IBAction)onButtonAdd:(id)sender;
- (void) SendRingbackWithEmail;
- (void) SendInvotationWithEmail;
- (void) HideLoadingView;

@end