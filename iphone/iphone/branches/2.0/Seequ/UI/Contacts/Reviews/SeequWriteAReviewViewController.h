//
//  SeequWriteAReviewViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/12/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"


@protocol SeequWriteAReviewDelegate;


@interface SeequWriteAReviewViewController : UIViewController {
//    id<SeequWriteAReviewDelegate> __weak _delegate;

    UIImageView *imageViewStars[5];
    
    int rate;
    BOOL isRated;

    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, assign) id<SeequWriteAReviewDelegate> delegate;


@property (nonatomic, strong) ContactObject *contactObj;
@property (nonatomic, assign) int videoViewState;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewContent;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewSeequStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (weak, nonatomic) IBOutlet UILabel *labelSpecialist;
@property (weak, nonatomic) IBOutlet UILabel *labelCompany;
@property (weak, nonatomic) IBOutlet UILabel *labelTapAStarToRate;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewContactOnlineStatus;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldReview;


- (void) setVideoViewState:(int)state Animated:(BOOL)animated;
- (void) UpdateUI;
- (void) singleTapGestureCaptured:(UITapGestureRecognizer *)gesture;
- (IBAction)onButtonCancel:(id)sender;
- (IBAction)onButtonSend:(id)sender;


- (void) RateWithStar:(int)stars;
- (void) setOnlineStatus:(online_Status)online;
- (void) send_Rating_Request;
- (void) HideLoadingView;
- (void) ShowErrorMessageWithMessage:(NSString*)message;

@end

@protocol SeequWriteAReviewDelegate <NSObject>

@optional

- (void) didSendReview:(SeequWriteAReviewViewController*)seequWriteAReviewViewController;

@end