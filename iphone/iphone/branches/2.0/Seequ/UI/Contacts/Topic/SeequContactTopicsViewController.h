//
//  SeequContactTopicsViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 9/29/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"

typedef enum Topics_Type {
	Topics_Type_Work,
    Topics_Type_Play
}
Topics_Type;

@interface SeequContactTopicsViewController : UIViewController {
    Topics_Type topicsType;

    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, strong) ContactObject *contactObj;
@property (nonatomic, assign) int videoViewState;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollViewContent;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewSeequStatus;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonWork;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonPlay;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelSpecialist;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelCompany;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewContactOnlineStatus;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;
- (void) UpdateUI;
- (void) setRatingStars:(int)stars;
- (void) GoBack:(id)sender;
- (void) onButtonAction:(id)sender;

- (IBAction)onButtonFilter:(id)sender;
- (IBAction)onButtonTopicDetail:(id)sender;

- (void) filterContactsWithSegment_Type:(Topics_Type)top_Type;

@end