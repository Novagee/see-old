//
//  SeequPhoneContactInviteViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 12/14/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SeequPhoneContactInviteViewController : UIViewController <UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate> {
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, strong) ContactObject *contactObj;
@property (nonatomic, assign) int videoViewState;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollViewContent;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelSpecialist;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelLocation;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (void) GoBack:(id)sender;
- (IBAction)onButtonInvite:(id)sender;
- (IBAction)onButtonRingBack:(id)sender;

@end