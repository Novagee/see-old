//
//  MyProfileViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/1/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "MyProfileViewController.h"
#import "idoubs2AppDelegate.h"
#import "SeequSettingsViewController.h"
#import "SeequEditProfileViewController.h"

#import "SeequContactReviewsViewController.h"
#import "SeequContactConnectionsViewController.h"
#import "NavigationBar.h"
#import "BackBarButton.h"
#import "Common.h"


@interface MyProfileViewController ()

@end

@implementation MyProfileViewController

@synthesize videoViewState;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(IS_IOS_7){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewChange:)
                                                 name:kVideoViewChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewOrientationChange:)
                                                 name:kVideoViewOrientationChangeNotification
                                               object:nil];

    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    [self creatInfoList];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	((NavigationBar*) self.navigationController.navigationBar).titleImage = nil;
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    self.navigationItem.title = @"My Profile";

    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack:)];
    
    BackBarButton *settingsBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"seequButtonSettings.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(onButtonSettings:)];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backBarButton, settingsBarButton, nil];
    
//    BackBarButton *actionBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequActionButton.png"]
//                                                                      style:UIBarButtonItemStylePlain
//                                                                     target:self
//                                                                     action:@selector(onButtonAction:)];
    
    BackBarButton *editBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"seequButtonEdit.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(onButtonEdit:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:editBarButton, nil];
    [self creatInfoList];

    if (UIInterfaceOrientationIsPortrait([idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation)) {
        [self setVideoViewState:self.videoViewState Animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void) onVideoViewChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    self.videoViewState = (VideoViewState)[eargs intValue];
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
            
            frame = CGRectMake(0, 0, self.scrollViewDetails.frame.size.width, self.view.frame.size.height);
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 271 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 271 - diff));
//            self.scrollViewDetails.frame = frame;
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 179 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 179 - diff));
//            self.scrollViewDetails.frame = frame;
        
        }
            break;
        default:
            break;
    }

    if (animated) {
        [UIView beginAnimations:@"scrollFrame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3];
    }
    self.scrollViewDetails.frame = frame;
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void) creatInfoList {
    [self removeObjectsFromScroll];
    [self UpdateUI];
    
    Common *common = [Common sharedCommon];
    self.imageViewProfile.image = common.contactObject.image;
    self.imageViewBadgeStatus.image = [UIImage imageNamed:[NSString stringWithFormat:@"ProfileBadgeStatus%@.png",common.contactObject.badgeStatus]];
//    [self setRatingStars:ceilf(common.contactObject.ratingValue)];
    self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@", common.contactObject.FirstName, common.contactObject.LastName];
    self.labelSpecialist.text = common.contactObject.specialist;
    self.labelCompany.text = common.contactObject.company;
    
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    if (common.contactObject.City && [common.contactObject.City length]) {
        [arr addObject:common.contactObject.City];
    }
    if (common.contactObject.state.stateAbbrev && [common.contactObject.state.stateAbbrev length] ) {
        [arr addObject:common.contactObject.state.stateAbbrev];
    } else if(common.contactObject.state.stateName && [common.contactObject.state.stateName length] ) {
        [arr addObject:common.contactObject.state.stateName];
    }
    if (common.contactObject.country.countryName && [common.contactObject.country.countryName length]) {
        [arr addObject:common.contactObject.country.countryName];
    }
    NSString* str = [arr componentsJoinedByString:@", "];
    self.labelLocation.text = str;
    
    self.labelRatings.text = [NSString stringWithFormat:@"%d Ratings",common.contactObject.ratingCount];
    self.labelReviews.text = [NSString stringWithFormat:@"%d Rewievs",common.contactObject.reviewCount];
    self.labelReviewsCount.text = [NSString stringWithFormat:@"%d", common.contactObject.reviewCount];
    self.labelConnectionsOnSeequCount.text = [NSString stringWithFormat:@"%d", common.contactObject.connectionCount];
    self.labelTopicsCount.text = [NSString stringWithFormat:@"%d", common.contactObject.topicCount];
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onButtonSettings:(id)sender {
    SeequSettingsViewController *settingsViewController = [[SeequSettingsViewController alloc] initWithNibName:@"SeequSettingsViewController" bundle:nil];
    settingsViewController.videoViewState = self.videoViewState;
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (void) onButtonEdit:(id)sender {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
    //    SeequEditProfileViewController *editProfileViewController = [[SeequEditProfileViewController alloc] init];
        SeequEditProfileViewController *editProfileViewController = [[SeequEditProfileViewController alloc] initWithNibName:@"SeequEditProfileViewController" bundle:nil];

        editProfileViewController.videoViewState = self.videoViewState;
        [self.tabBarController presentViewController:editProfileViewController animated:YES completion:nil];
    }
}

- (void) onButtonAction:(id)sender {
    
}

- (IBAction)onButtonReviews:(id)sender {
    SeequContactReviewsViewController *reviewsViewController = [[SeequContactReviewsViewController alloc] initWithNibName:@"SeequContactReviewsViewController" bundle:nil];
    reviewsViewController.contactObj = [Common sharedCommon].contactObject;
    reviewsViewController.videoViewState = self.videoViewState;
    [self.navigationController pushViewController:reviewsViewController animated:YES];
}

- (IBAction)onButtonConnectionsOnSeequ:(id)sender {
    SeequContactConnectionsViewController *connectionsViewController = [[SeequContactConnectionsViewController alloc] initWithNibName:@"SeequContactConnectionsViewController" bundle:nil];
    connectionsViewController.contactObj = [Common sharedCommon].contactObject;
    connectionsViewController.videoViewState = self.videoViewState;
    [self.navigationController pushViewController:connectionsViewController animated:YES];
}

- (IBAction)onButtonTopics:(id)sender {
}

- (void) setRatingStars:(int)stars {
    for (int i = 0; i < stars; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(276 - (stars*12)/2 + i * 12, 16, 12, 11)];
        starImageView.image = [UIImage imageNamed:@"contactRatingStar.png"];
        [self.scrollViewDetails addSubview:starImageView];
    }
}

- (void) UpdateUI {
    self.viewMainFields.frame = CGRectMake(0, 0, 320, 198);
    [self.scrollViewDetails addSubview:self.viewMainFields];
    
    Common *common= [Common sharedCommon];
    scrollContentSizeY = 162 - 50;
    [self.scrollViewDetails addSubview:[self CreateSectionHeaderWithText:@"Intraduction"]];
    scrollContentSizeY += 23;

    scrollContentSizeY = [self CreateSummaryWithText:common.contactObject.introduction
                                               Views:common.contactObject.arrayReviews.count
                                              Joined:(int)(([[NSDate date] timeIntervalSince1970] - common.contactObject.registrationDate/1000.0)/86400.0)];
//    [self.scrollViewDetails addSubview:[self CreateSectionHeaderWithText:@"Bio"]];
//    scrollContentSizeY += 23;
//    
//    scrollContentSizeY = [self CreateBioWithText:common.contactObject.biography];
    
    [self.scrollViewDetails addSubview:[self CreateSectionHeaderWithText:@"Languages"]];
    scrollContentSizeY += 23;
    
    scrollContentSizeY = [self CreateLanguages];
    
    [self.scrollViewDetails addSubview:[self CreateSectionHeaderWithText:@"Internet"]];
    scrollContentSizeY += 23;
    
    scrollContentSizeY = [self CreateInformationWithArray:common.contactObject.arrayInternetInfo];
    
    [self.scrollViewDetails addSubview:[self CreateSectionHeaderWithText:@"Contact Information"]];
    scrollContentSizeY += 23;

    scrollContentSizeY = [self CreateInformationWithArray:common.contactObject.arrayContactInfo];

    [self.scrollViewDetails addSubview:[self CreateSectionHeaderWithText:@"Social Information"]];
    scrollContentSizeY += 23;

    scrollContentSizeY = [self CreateInformationWithArray:common.contactObject.arraySocialInfo];
    
    [self.scrollViewDetails setContentSize:CGSizeMake(320, scrollContentSizeY)];
}

- (void) removeObjectsFromScroll {
    for (UIView *view in self.scrollViewDetails.subviews) {
        [view removeFromSuperview];
    }
    for (UIImageView *imageView in self.scrollViewDetails.subviews) {
        [imageView removeFromSuperview];
    }
}

- (UIImageView*) CreateSectionHeaderWithText:(NSString*)text {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, scrollContentSizeY, 320, 23)];
    [imageView setImage:[UIImage imageNamed:@"contactProfileDetailsSectionBG.png"]];
    UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 320, 23)];
    [lblText setFont:[UIFont boldSystemFontOfSize:17]];
    [lblText setBackgroundColor:[UIColor clearColor]];
    [lblText setTextColor:[UIColor whiteColor]];
    [lblText setText:text];
    [imageView addSubview:lblText];
    
    return imageView;
}

- (int) CreateSummaryWithText:(NSString*)text Views:(int)viewCount Joined:(int)joinedCount {
    UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 23)];
    [lblText setFont:[UIFont systemFontOfSize:14]];
    
	CGSize textSize = CGSizeMake(lblText.frame.size.width, 5000.0f);
	CGSize size = [text sizeWithFont:lblText.font
                   constrainedToSize:textSize
                       lineBreakMode:NSLineBreakByWordWrapping];
    
    lblText.frame = CGRectMake(10, scrollContentSizeY + 5, 300, size.height);
    [lblText setBackgroundColor:[UIColor clearColor]];
    [lblText setTextColor:[UIColor blackColor]];
    [lblText setText:text];
    [lblText setNumberOfLines:0];
    [lblText setLineBreakMode:NSLineBreakByWordWrapping];
    [self.scrollViewDetails addSubview:lblText];
    
    scrollContentSizeY = scrollContentSizeY + 5 + size.height;
    
    UIImageView *imageViewLine = [[UIImageView alloc] initWithFrame:CGRectMake(20, scrollContentSizeY + 2.5, 279, 2)];
    [imageViewLine setImage:[UIImage imageNamed:@"contactProfileDetailsTextBreakLine.png"]];
    [self.scrollViewDetails addSubview:imageViewLine];
    
    self.labelReviewsCountInSection.text = [self CreateReviewsCountTextWithCount:viewCount];
    self.labelDateOfJoined.text = [self CreateJoinedDateTextWithDays:joinedCount];
    
    [self CalculateViewJoinedLabelsPositions];
    self.viewViewJoined.frame = CGRectMake(0, scrollContentSizeY + 3, 320, 26);
    [self.scrollViewDetails addSubview:self.viewViewJoined];
    
    scrollContentSizeY = scrollContentSizeY + 5 + 23;
    return scrollContentSizeY;
}

- (int)CreateBioWithText:(NSString*)text {
    UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 23)];
    [lblText setFont:[UIFont systemFontOfSize:14]];
    
	CGSize textSize = CGSizeMake(lblText.frame.size.width, 5000.0f);
	CGSize size = [text sizeWithFont:lblText.font
                   constrainedToSize:textSize
                       lineBreakMode:NSLineBreakByWordWrapping];
    
    lblText.frame = CGRectMake(10, scrollContentSizeY + 5, 300, size.height);
    [lblText setBackgroundColor:[UIColor clearColor]];
    [lblText setTextColor:[UIColor blackColor]];
    [lblText setText:text];
    [lblText setNumberOfLines:0];
    [lblText setLineBreakMode:NSLineBreakByWordWrapping];
    [self.scrollViewDetails addSubview:lblText];
    
    scrollContentSizeY = scrollContentSizeY + 10 + size.height;
    
    return scrollContentSizeY;
}

- (int) CreateLanguages {
    BOOL haveLanguage = NO;
    NSString *language;
    int index = 15;
    Common *common = [Common sharedCommon];
    
    for (int i = 0; i < 4; i++) {
        switch (i) {
            case 0:
                language = common.contactObject.LanguagePrimary;
                break;
            case 1:
                language = common.contactObject.LanguageSecond;
                break;
            case 2:
                language = common.contactObject.LanguageThird;
                break;
            case 3:
                language = common.contactObject.LanguageFourth;
                break;
            default:
                break;
        }

        if (!language || language.length == 0 || [language isEqualToString:@"(select one)"]||[language isEqualToString:@"(null)"]) {
            continue;
        }
        
        NSString *labelLanguage = language;
        NSLog(@"%@",labelLanguage);

        haveLanguage = YES;
        language = [language stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        language = [language lowercaseString];
        NSLog(@"language name %@", labelLanguage);
        
        NSString *filePath = [Common FindFilePathWithFilename:@"LanguageList.plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        
        NSArray *array = [dict objectForKey:@"Item"];
        NSString *imageName = nil;
        for (int i = 0; i <  array.count; i++) {
            if ([labelLanguage isEqualToString:[[array objectAtIndex:i] objectAtIndex:0]]) {
                imageName = [[array objectAtIndex:i] objectAtIndex:1];
                break;
                
            }
                 
        }
   //     NSAssert(imageName, @"flag must  be initialized  in plist");
    //    NSString *imageName = [NSString stringWithFormat:@"flag_%@.png", language];
        
        UIImage* image = [UIImage imageNamed:imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        CGFloat tempWidth = image?image.size.width:30;
        CGFloat scaleFactor =  30/tempWidth;
        imageView.frame = CGRectMake(index, scrollContentSizeY + 10, image.size.width* scaleFactor, image.size.height*  scaleFactor);
        [self.scrollViewDetails addSubview:imageView];
        
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, scrollContentSizeY + 35, 60, 20)];
        lblName.center = CGPointMake(imageView.center.x, lblName.center.y);
        [lblName setFont:[UIFont systemFontOfSize:10]];
        [lblName setTextColor:[UIColor blackColor]];
        [lblName setTextAlignment:NSTextAlignmentCenter];
        [lblName setText:labelLanguage];
        [self.scrollViewDetails addSubview:lblName];
        
        index += 60;
    }
    
    if (haveLanguage) {
        return scrollContentSizeY + 60;
    } else {
        return scrollContentSizeY + 10;
    }
}

- (int) CreateInformationWithArray:(NSArray*)array {
    for (NSDictionary *dict in array) {
        NSString *name = [dict objectForKey:@"itemName"];
        NSString *value = [dict objectForKey:@"itemValue"];
        
        if (name && [name isKindOfClass:[NSString class]] && name.length &&
            value && [value isKindOfClass:[NSString class]] && value.length) {
            scrollContentSizeY += [self CreateInformationItemWithName:name Value:value];
        }
    }
    
    return scrollContentSizeY;
}

- (int) CreateInformationItemWithName:(NSString*)name Value:(NSString*)value {
    UIImageView *imageViewBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, scrollContentSizeY, 320, 36)];
    [imageViewBG setImage:[UIImage imageNamed:@"contactProfileDetailsDefaultCellBG.png"]];
    [self.scrollViewDetails addSubview:imageViewBG];
    
    UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(5, scrollContentSizeY + 5, 70, 26)];
    [lblHeader setBackgroundColor:[UIColor clearColor]];
    [lblHeader setFont:[UIFont systemFontOfSize:14]];
    [lblHeader setTextColor:[UIColor lightGrayColor]];
    [lblHeader setText:name];
    [lblHeader setTextAlignment:NSTextAlignmentLeft];
    [self.scrollViewDetails addSubview:lblHeader];
    
    UILabel *lblValue = [[UILabel alloc] initWithFrame:CGRectMake(80, scrollContentSizeY + 5, 230, 26)];
    [lblValue setBackgroundColor:[UIColor clearColor]];
    [lblValue setFont:[UIFont systemFontOfSize:14]];
    [lblValue setTextColor:[UIColor blackColor]];
    [lblValue setText:value];
    [lblValue setTextAlignment:NSTextAlignmentLeft];
    [self.scrollViewDetails addSubview:lblValue];

    return (int)imageViewBG.image.size.height;
}

- (void) CalculateViewJoinedLabelsPositions {
    int currentXPosition = 0;
    CGSize textSize = [self.labelReviewsCountInSection.text sizeWithFont:self.labelReviewsCountInSection.font
                          constrainedToSize:CGSizeMake(5000, 40)
                              lineBreakMode:NSLineBreakByWordWrapping];

    self.labelReviewsCountInSection.frame = CGRectMake(10, 3, textSize.width, 20);
    currentXPosition = self.labelReviewsCountInSection.frame.origin.x + self.labelReviewsCountInSection.frame.size.width;
    
    textSize = [self.labelViewJoined.text sizeWithFont:self.labelViewJoined.font
                                     constrainedToSize:CGSizeMake(5000, 40)
                                         lineBreakMode:NSLineBreakByWordWrapping];
    
    self.labelViewJoined.frame = CGRectMake(currentXPosition + 3, 3, textSize.width, 20);
    currentXPosition = self.labelViewJoined.frame.origin.x + self.labelViewJoined.frame.size.width;
    
    textSize = [self.labelDateOfJoined.text sizeWithFont:self.labelDateOfJoined.font
                                       constrainedToSize:CGSizeMake(5000, 40)
                                           lineBreakMode:NSLineBreakByWordWrapping];
    
    self.labelDateOfJoined.frame = CGRectMake(currentXPosition + 3, 3, textSize.width, 20);
    currentXPosition = self.labelDateOfJoined.frame.origin.x + self.labelDateOfJoined.frame.size.width;

    textSize = [self.labelAgo.text sizeWithFont:self.labelAgo.font
                                       constrainedToSize:CGSizeMake(5000, 40)
                                           lineBreakMode:NSLineBreakByWordWrapping];
    
    self.labelAgo.frame = CGRectMake(currentXPosition + 3, 3, textSize.width, 20);
}

- (NSString*) CreateReviewsCountTextWithCount:(int)count {
    NSNumber *longNumber = [NSNumber numberWithInt:count];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setUsesGroupingSeparator:YES];
    [formatter setGroupingSeparator:@","];
    [formatter setGroupingSize:3];
    [formatter setMaximumFractionDigits:0];
    
    NSString *formattedNumber = [formatter stringFromNumber:longNumber];
    NSLog(@"The formatted number is %@", formattedNumber);
    
    return formattedNumber;
}

- (NSString*) CreateJoinedDateTextWithDays:(int)days {
    if (days > 365) {
        int years = (int)(days/365);
        int day = days - (years*365);
        
        return [NSString stringWithFormat:@"%dy %dd", years, day];
    }
    
    return [NSString stringWithFormat:@"%dd", days];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollViewDetails:nil];
    [self setLabelTopicsCount:nil];
    [self setLabelConnectionsOnSeequCount:nil];
    [self setLabelReviewsCount:nil];
    [self setLabelReviews:nil];
    [self setLabelRatings:nil];
    [self setLabelLocation:nil];
    [self setLabelCompany:nil];
    [self setLabelSpecialist:nil];
    [self setLabelDisplayName:nil];
    [self setImageViewProfile:nil];
    [self setImageViewBadgeStatus:nil];
    [self setViewMainFields:nil];
    [self setLabelReviewsCountInSection:nil];
    [self setLabelViewJoined:nil];
    [self setLabelDateOfJoined:nil];
    [self setLabelAgo:nil];
    [self setViewViewJoined:nil];
    [super viewDidUnload];
}

@end
