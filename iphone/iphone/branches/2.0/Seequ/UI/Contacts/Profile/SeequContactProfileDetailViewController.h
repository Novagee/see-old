//
//  SeequContactProfileDetailViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 9/28/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"
#import "UserEntity.h"
#import "XMPPRoster.h"

@interface SeequContactProfileDetailViewController : UIViewController <XMPPRosterStorage> {
    int scrollContentSizeY;
    int videoViewState;

    XMPPRoster *xmppRoster;
    UIInterfaceOrientation Video_InterfaceOrientation;
}


@property (nonatomic, strong) ContactObject *contactObj;
@property (nonatomic, assign) int videoViewState;
@property (strong, nonatomic) IBOutlet UIButton *buttonHeader;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewHeader;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewDetails;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewSeequStatus;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewContactOnlineStatus;
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
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonDisconnect;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonBlockRequests;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonAddToMySeequ;
@property (strong, nonatomic) IBOutlet UIButton *buttonConnectionsOnSeequ;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorConnectionCount;

@property (strong, nonatomic) IBOutlet UIView *viewViewJoined;
@property (strong, nonatomic) IBOutlet UILabel *labelReviewsCountInSection;
@property (strong, nonatomic) IBOutlet UILabel *labelViewJoined;
@property (strong, nonatomic) IBOutlet UILabel *labelDateOfJoined;
@property (strong, nonatomic) IBOutlet UILabel *labelAgo;

@property (nonatomic, assign) BOOL accessToConnections;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (IBAction) onButtonTopics:(id)sender;
- (IBAction) onButtonConnectionsOnSeequ:(id)sender;
- (IBAction) onButtonReviews:(id)sender;
- (IBAction) onButtonDisconnect:(id)sender;
- (IBAction) onButtonBlockRequests:(id)sender;
- (IBAction) onButtonAddToMySeequ:(id)sender;


- (void) updateFooterButtonsYPosition:(int)y;
- (void) setRatingStars:(int)stars;
- (void) setOnlineStatus:(online_Status)online;
- (void) UpdateUI;
- (UIImageView*) CreateSectionHeaderWithText:(NSString*)text;
- (int) CreateSummaryWithText:(NSString*)text Views:(int)viewCount Joined:(NSTimeInterval)joinedCount;
- (int) CreateBioWithText:(NSString*)text;
- (int) CreateLanguagesWithArray:(NSArray*)array;
- (int) CreateInformationWithArray:(NSArray*)array;
- (int) CreateInformationItemWithName:(NSString*)name Value:(NSString*)value;
- (void) CalculateViewJoinedLabelsPositions;
- (NSString*) CreateReviewsCountTextWithCount:(int)count;
- (NSString*) CreateJoinedDateTextWithDays:(int)days;
- (void) GetConnectionsOnSeequCountAsync;

@end