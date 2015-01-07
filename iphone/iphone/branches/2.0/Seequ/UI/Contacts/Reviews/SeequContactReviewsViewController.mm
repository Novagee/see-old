//
//  SeequContactReviewsViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 9/29/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequContactReviewsViewController.h"
#import "SeequWriteAReviewViewController.h"
#import "SeequReportAbuseViewController.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"
#import "NavigationBar.h"
#import "BackBarButton.h"


#define STAR_IMAGE_TAG 88


@interface SeequContactReviewsViewController ()

@end

@implementation SeequContactReviewsViewController

@synthesize contactObj;
@synthesize videoViewState;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self UpdateUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectUpdate:) name:@"ContactObjectProfileDataUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewOrientationChange:) name:kVideoViewOrientationChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectUpdateEvent:) name:kContactObjectUpdateNotification object:nil];

    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.labelRatings.text = [NSString stringWithFormat:@"%d Ratings", self.contactObj.ratingCount];
	
    ((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleReviews.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack:)];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    
//    BackBarButton *actionBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequActionButton.png"]
//                                                                    style:UIBarButtonItemStylePlain
//                                                                   target:self
//                                                                   action:@selector(onButtonAction:)];
//    
//    self.navigationItem.rightBarButtonItem = actionBarButton;
    
    if ([[Common sharedCommon].contactObject.SeequID isEqualToString:self.contactObj.SeequID]) {
        self.viewButtonsBG.hidden = YES;
        self.MyTableView.frame = CGRectMake(0, 90, 320, self.MyTableView.frame.size.height + 35);
    }
    
    self.scrollViewContent.contentSize = CGSizeMake(320, 367);
    if (UIInterfaceOrientationIsPortrait([idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation)) {
        [self setVideoViewState:self.videoViewState Animated:NO];
    }
}

- (void) onVideoViewChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    videoViewState = (VideoViewState)[eargs intValue];
}

- (void) onVideoViewOrientationChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    Video_InterfaceOrientation = (UIInterfaceOrientation)[eargs intValue];
    
    [self setVideoViewState:self.videoViewState Animated:YES];
}

- (void) setVideoViewState:(int)state Animated:(BOOL)animated {
    if ([[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
        if (UIInterfaceOrientationIsLandscape(Video_InterfaceOrientation)) {
            state = VideoViewState_HIDE;
        }
    } else {
        state = VideoViewState_HIDE;
    }

    videoViewState = state;

    int diff = 0;
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 568) {
        diff = 88;
    }

    CGRect frame = CGRectZero;
    switch (state) {
        case VideoViewState_NONE:
        case VideoViewState_NORMAL:
        case VideoViewState_NORMAL_MENU:
        case VideoViewState_HIDE: {
            frame = self.view.frame;
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 271 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 271 - diff));
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 179 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 179 - diff));
        }
            break;
        default:
            break;
    }
    
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        self.scrollViewContent.contentSize = frame.size;
        if (animated) {
            [UIView beginAnimations:@"scrollFrame" context:nil];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.3];
        }
        self.scrollViewContent.frame = frame;
        int tableOriginY;
        if ([[Common sharedCommon].contactObject.SeequID isEqualToString:self.contactObj.SeequID]) {
            tableOriginY = 90;
        } else {
            tableOriginY = 125;
        }
        self.MyTableView.frame = CGRectMake(0, tableOriginY, 320, frame.size.height - tableOriginY);
        if (animated) {
            [UIView commitAnimations];
        }
    }    
}

- (void) onContactObjectUpdateEvent:(NSNotification*)notification {
        NSString *seequId= [notification object];
    
    if (seequId) {
        if ([self.contactObj.SeequID isEqualToString:seequId]) {
            self.contactObj =[[ContactStorage sharedInstance] GetContactObjectBySeequId:seequId];
            [self UpdateUI];
        }
    }
}

- (void) UpdateUI {
    self.imageViewProfile.image = self.contactObj.image;
    [self setRatingStars:ceilf(self.contactObj.ratingValue)];
    self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@", self.contactObj.FirstName, self.contactObj.LastName];
    self.labelSpecialist.text = self.contactObj.specialist;
    self.labelCompany.text = self.contactObj.company;
    self.labelReviews.text = [NSString stringWithFormat:@"%d Reviews", self.contactObj.reviewCount];
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    if (self.contactObj.City && [self.contactObj.City length]) {
        [arr addObject:self.contactObj.City];
    }
    if (self.contactObj.state.stateAbbrev && [self.contactObj.state.stateAbbrev length] ) {
        [arr addObject:self.contactObj.state.stateAbbrev];
    } else if(self.contactObj.state.stateName && [self.contactObj.state.stateName length] ) {
        [arr addObject:self.contactObj.state.stateName];
    }
    if (self.contactObj.country.countryName && [self.contactObj.country.countryName length]) {
        [arr addObject:self.contactObj.country.countryName];
    }
    NSString* str = [arr componentsJoinedByString:@", "];
    self.labelLocation.text = str;

    if (self.contactObj.badgeStatus) {
        NSString *imageName = [NSString stringWithFormat:@"ProfileBadgeStatus%@.png", self.contactObj.badgeStatus];
        [self.imageViewSeequStatus setImage:[UIImage imageNamed:imageName]];
    }
}

- (void) setRatingStars:(int)stars {
    for (UIImageView *imageView in self.scrollViewContent.subviews) {
        if (imageView.tag == STAR_IMAGE_TAG) {
            [imageView removeFromSuperview];
        }
    }

    for (int i = 0; i < stars; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(276 - (stars*12)/2 + i * 12, 16, 12, 11)];
        starImageView.tag = STAR_IMAGE_TAG;
        starImageView.image = [UIImage imageNamed:@"contactRatingStar.png"];
        
        [self.scrollViewContent addSubview:starImageView];
    }
}

- (void) setItemStars:(int)stars viewCell:(UITableViewCell*)cell {
    for (int i = 0; i < 5; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15 + i * 14, 55, 14, 13)];
        if (i < stars) {
            starImageView.image = [UIImage imageNamed:@"reviewsItemStarSel.png"];
        } else {
            starImageView.image = [UIImage imageNamed:@"reviewsItemStar.png"];
        }
        
        [cell addSubview:starImageView];
    }
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onButtonAction:(id)sender {
    //    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share this Profile"
    //                                                             delegate:self
    //                                                    cancelButtonTitle:@"Cancel"
    //                                               destructiveButtonTitle:nil
    //                                                    otherButtonTitles:@"Email", @"SMS", @"Facebook", @"Twitter", nil];
    //    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLabelDisplayName:nil];
    [self setLabelSpecialist:nil];
    [self setLabelCompany:nil];
    [self setLabelLocation:nil];
    [self setLabelRatings:nil];
    [self setLabelReviews:nil];

    [self setImageViewProfile:nil];
    [self setImageViewSeequStatus:nil];
    [self setViewButtonsBG:nil];
    [self setMyTableView:nil];
    [self setScrollViewContent:nil];
    [super viewDidUnload];
}
- (IBAction)onButtonWriteAReview:(id)sender {
    SeequWriteAReviewViewController *writeAReviewViewController = [[SeequWriteAReviewViewController alloc] initWithNibName:@"SeequWriteAReviewViewController" bundle:nil];
    writeAReviewViewController.contactObj = self.contactObj;
    writeAReviewViewController.videoViewState = self.videoViewState;
    [self.tabBarController presentViewController:writeAReviewViewController animated:YES completion:nil];
}

- (IBAction)onButtonReportAbuse:(id)sender {
    SeequReportAbuseViewController *reportAbuseViewController = [[SeequReportAbuseViewController alloc] initWithNibName:@"SeequReportAbuseViewController" bundle:nil];
    reportAbuseViewController.contactObj = self.contactObj;
    reportAbuseViewController.videoViewState = self.videoViewState;
    [self.tabBarController presentViewController:reportAbuseViewController animated:YES completion:nil];
}

#pragma ---------
#pragma mark Table view methods
#pragma ---------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Number of rows it should expect should be based on the section
    return self.contactObj.arrayReviews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    //    ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //    if (cell == nil) {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    NSDictionary *dict = [self.contactObj.arrayReviews objectAtIndex:indexPath.row];
    
    NSString *content = [dict objectForKey:@"content"];
    NSString *title = [dict objectForKey:@"title"];
    int ratingValue = [[dict objectForKey:@"ratingValue"] integerValue];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(55, 10, 250, 35)];
    [labelTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]];
    [labelTitle setNumberOfLines:2];
    [labelTitle setBackgroundColor:[UIColor clearColor]];
    [labelTitle setText:title];
    [cell addSubview:labelTitle];

    [self setItemStars:ratingValue viewCell:cell];

    if (content && [content isKindOfClass:[NSString class]] && content.length) {
        CGSize textSize = CGSizeMake(294, 5000.0f);
        CGSize size = [content sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:11] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
        UILabel *labelContent= [[UILabel alloc] initWithFrame:CGRectMake(13, 75, 294, size.height)];
        [labelContent setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
        [labelContent setNumberOfLines:0];
        [labelContent setBackgroundColor:[UIColor clearColor]];
        [labelContent setText:content];
        [cell addSubview:labelContent];
    }
    
    UIImageView *imageViewProfile = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//    imageViewProfile setImage:
    [cell addSubview:imageViewProfile];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSMutableArray *array = [sectionsArray objectAtIndex:indexPath.section];
//    selectedContactObject = [array objectAtIndex:indexPath.row];
//    if (selectedContactObject.contactType != Contact_Type_Address_Book) {
//        SeequContactProfileViewController *profileViewController = [[SeequContactProfileViewController alloc] initWithNibName:@"SeequContactProfileViewController" bundle:nil];
//        profileViewController.contactObj = selectedContactObject;
//        [self.navigationController pushViewController:profileViewController animated:YES];
//    } else {
//        UIActionSheet *actionSheetInvite = [[UIActionSheet alloc] initWithTitle:@"Invite by"
//                                                                       delegate:self
//                                                              cancelButtonTitle:@"Cancel"
//                                                         destructiveButtonTitle:nil
//                                                              otherButtonTitles:nil];
//        
//        if ([MFMailComposeViewController canSendMail] && [selectedContactObject HaveEmailAddress]) {
//            [actionSheetInvite addButtonWithTitle:actionSheetButtonTitleEmail];
//        }
//        
//        if ([MFMessageComposeViewController canSendText] && [selectedContactObject HavePhoneNumber]) {
//            [actionSheetInvite addButtonWithTitle:actionSheetButtonTitleSMS];
//        }
//        
//        actionSheetInvite.actionSheetStyle = UIActionSheetStyleBlackOpaque;
//        actionSheetInvite.tag = 2;
//        [actionSheetInvite showFromTabBar:self.tabBarController.tabBar];
//    }
//	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [self.contactObj.arrayReviews objectAtIndex:indexPath.row];

    NSString *content = [dict objectForKey:@"content"];
    if (content && [content isKindOfClass:[NSString class]] && content.length) {
        CGSize textSize = CGSizeMake(294, 5000.0f);
//      JSC - CGSize size = [content sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:11] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
        
        NSAttributedString *attributedText =
        [[NSAttributedString alloc] initWithString:content
         attributes:@{
            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:11]
         }];
        
        CGRect textRect = [attributedText boundingRectWithSize:CGSizeMake(textSize.width -10, 1000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        return 75 + textRect.size.height + 10;
    }
    
    return 75;
}

- (void) onContactObjectUpdate:(NSNotification*)notification {
    NSDictionary *dict_post = [notification object];
    
    if (dict_post) {
        NSString *seequID = [dict_post objectForKey:@"seequID"];

        if ([seequID isEqualToString:self.contactObj.SeequID]) {
            [self.MyTableView reloadData];
        }
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end