//
//  SeequReportAbuseViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/12/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"

@interface SeequReportAbuseViewController : UIViewController <UITextViewDelegate, UIScrollViewDelegate> {
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, strong) ContactObject *contactObj;
@property (nonatomic, assign) int videoViewState;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollViewContent;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewSeequStatus;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelSpecialist;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelCompany;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewContactOnlineStatus;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *TextFieldReview;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonSpam;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonInappCont;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textViewDescription;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;


- (void) setVideoViewState:(int)state Animated:(BOOL)animated;
- (void) UpdateUI;
- (IBAction)onButtonCancel:(id)sender;
- (IBAction)onButtonSend:(id)sender;
- (IBAction)onButtonFilter:(id)sender;
- (IBAction)onButtonBlockRequests:(id)sender;
- (IBAction)onButtonDisconnect:(id)sender;
- (IBAction)onButtonAcceptableUsePolicy:(id)sender;

@end