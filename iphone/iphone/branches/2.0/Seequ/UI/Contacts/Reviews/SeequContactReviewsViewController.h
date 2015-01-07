//
//  SeequContactReviewsViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 9/29/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"


@interface SeequContactReviewsViewController : UIViewController {
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, strong) ContactObject *contactObj;
@property (nonatomic, assign) int videoViewState;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollViewContent;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewSeequStatus;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelSpecialist;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelCompany;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelLocation;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelRatings;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelReviews;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewButtonsBG;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *MyTableView;


- (void) setVideoViewState:(int)state Animated:(BOOL)animated;
- (void) UpdateUI;
- (IBAction) onButtonWriteAReview:(id)sender;
- (IBAction) onButtonReportAbuse:(id)sender;


- (void) setRatingStars:(int)stars;
- (void) setItemStars:(int)stars viewCell:(UITableViewCell*)cell;
- (void) onContactObjectUpdate:(NSNotification*)notification;

@end