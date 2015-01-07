//
//  SeequContactProfileViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 9/27/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"
#import "UserEntity.h"
#import "XMPPRoster.h"

@interface SeequContactProfileViewController : UIViewController <UIActionSheetDelegate, XMPPRosterStorage> {
    XMPPRoster *xmppRoster;
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
    int screen_diff;
    int status_bar_diff;
}

@property (nonatomic, strong) ContactObject *contactObj;
@property (nonatomic, assign) int videoViewState;
@property (weak, nonatomic) IBOutlet UIView *profileDetailView;


@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewSeequStatus;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewContactOnlineStatus;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelSessionCount;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewSessinoCountBG;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelSpecialist;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelCompany;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelLocation;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textViewDescription;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewFooter;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewdetail;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonAddToMySeequ;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonAddToFavorites;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonRemoveFavorite;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonRequestReview;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonConnectionRequested;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonVoiceCall;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonCameraCall;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonMessage;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonRingback;
@property (weak, nonatomic) IBOutlet UIButton *ButtonRemoveContact;
@property (weak, nonatomic) IBOutlet UIButton *buttonAddContact;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIButton *unMuteButton;
@property (nonatomic, assign) BOOL accessToConnections;



- (void) setVideoViewState:(int)state Animated:(BOOL)animated;
- (void) UpdateUI;
- (IBAction)onButtonContactDetail:(id)sender;
- (IBAction)onButtonVoiceCall:(id)sender;
- (IBAction)onButtonCameraCall:(id)sender;
- (IBAction)onButtonMessage:(id)sender;
- (IBAction)onButtonRingback:(id)sender;
- (IBAction)onButtonAddToMySeequ:(id)sender;
- (IBAction)onButtonAddToFavorites:(id)sender;
- (IBAction)onButtonRemoveFavorite:(id)sender;
- (IBAction)onButtonRequestReview:(id)sender;
- (IBAction)onButtonConnectionRequested:(id)sender;
- (IBAction)onButtonDisconnect:(id)sender;
- (IBAction)onButtonMute:(id)sender;
- (IBAction)onButtonUnMute:(id)sender;
- (void) GoBack:(id)sender;
- (void) setSessionCount:(int)count;
- (void) setRatingStars:(int)stars;
- (void) setOnlineStatus:(online_Status)online;
- (void) onButtonAction:(id)sender;
- (void) UpdateButtonsState;
- (void) AddToFavorites;
- (void) RemoveFavorite;
- (void) HideLoadingView;


@end