//
//  MyProfileViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/1/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyProfileViewController : UIViewController {
    NSTimer *timer;
    int scrollContentSizeY;
    
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, assign) int videoViewState;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewMainFields;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewBadgeStatus;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelSpecialist;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelCompany;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelLocation;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelRatings;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelReviews;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelReviewsCount;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelConnectionsOnSeequCount;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelTopicsCount;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollViewDetails;

@property (strong, nonatomic) IBOutlet UIView *viewViewJoined;
@property (strong, nonatomic) IBOutlet UILabel *labelReviewsCountInSection;
@property (strong, nonatomic) IBOutlet UILabel *labelViewJoined;
@property (strong, nonatomic) IBOutlet UILabel *labelDateOfJoined;
@property (strong, nonatomic) IBOutlet UILabel *labelAgo;


- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (void) onButtonSettings:(id)sender;
- (void) onButtonEdit:(id)sender;
- (void) onButtonAction:(id)sender;

- (IBAction)onButtonReviews:(id)sender;
- (IBAction)onButtonConnectionsOnSeequ:(id)sender;
- (IBAction)onButtonTopics:(id)sender;

- (void) UpdateUI;
- (int) CreateSummaryWithText:(NSString*)text Views:(int)viewCount Joined:(int)joinedCount;
- (int) CreateBioWithText:(NSString*)text;
- (int) CreateLanguages;
- (int) CreateInformationWithArray:(NSArray*)array;
- (int) CreateInformationItemWithName:(NSString*)name Value:(NSString*)value;
- (void) CalculateViewJoinedLabelsPositions;
- (NSString*) CreateReviewsCountTextWithCount:(int)count;
- (NSString*) CreateJoinedDateTextWithDays:(int)day;

@end