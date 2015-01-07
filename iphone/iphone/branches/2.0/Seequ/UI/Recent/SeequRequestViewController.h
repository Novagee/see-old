//
//  SeequRequestViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/13/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"

@protocol SeequRequestDelegate;

@interface SeequRequestViewController : UIViewController {
//    id<SeequRequestDelegate> __weak _delegate;

    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, assign) id<SeequRequestDelegate> delegate;
@property (nonatomic, strong) ContactObject *contactObj;
@property (nonatomic, assign) int videoViewState;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollViewContent;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelSpecialist;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelCompany;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelLocation;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewSeequStatus;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewContactOnlineStatus;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelSessionCount;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewSessinoCountBG;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textViewDescription;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textViewNote;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelRequestType;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewFooter;
@property (strong, nonatomic) IBOutlet UIButton *buttonAccept;
@property (strong, nonatomic) IBOutlet UIButton *buttonDecline;


- (void) setVideoViewState:(int)state Animated:(BOOL)animated;
- (void) UpdateUI;
- (void) GoBack:(id)sender;
- (IBAction) onButtonContactDetail:(id)sender;
- (IBAction) onButtonAccept:(id)sender;
- (IBAction) onButtonDecline:(id)sender;

- (void) setSessionCount:(int)count;
- (void) setRatingStars:(int)stars;
- (void) setOnlineStatus:(online_Status)online;

@end

@protocol SeequRequestDelegate <NSObject>

@optional

- (void) SeequConnectionRequest:(SeequRequestViewController*)controller didAcceptWithContactObject:(ContactObject*)contactsObj;
- (void) SeequConnectionRequest:(SeequRequestViewController*)controller didDeclineWithContactObject:(ContactObject*)contactsObj;

@end