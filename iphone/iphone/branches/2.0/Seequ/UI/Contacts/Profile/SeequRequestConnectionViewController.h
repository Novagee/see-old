//
//  SeequRequestConnectionViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/16/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"
#import "UserEntity.h"
#import "XMPPRoster.h"

@interface SeequRequestConnectionViewController : UIViewController <XMPPRosterStorage> {
    XMPPRoster *xmppRoster;

    int videoViewState;
    int scrollHeight;
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
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelLocation;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelRatings;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelReviews;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textViewNote;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewTextBG;
@property (strong, nonatomic) IBOutlet UILabel *labelRegistrationDate;


- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (IBAction)onButtonCancel:(id)sender;
- (IBAction)onButtonSend:(id)sender;
- (void) UpdateUI;
- (void) setRatingStars:(int)stars;
- (void) SendConnectionRequest;
- (void) SendXMPPAddBuddyRequest;
- (void) HideLoadingView;

@end