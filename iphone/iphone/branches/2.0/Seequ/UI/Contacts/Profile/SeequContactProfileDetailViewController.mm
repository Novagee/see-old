//
//  SeequContactProfileDetailViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 9/28/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequContactProfileDetailViewController.h"
#import "SeequContactConnectionsViewController.h"
#import "SeequContactReviewsViewController.h"
#import "SeequContactTopicsViewController.h"
#import "SeequRequestConnectionViewController.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"
#import "NavigationBar.h"
#import "BackBarButton.h"


#define SUBVIEWS_TAG 77
#define STAR_IMAGE_TAG 88


@interface SeequContactProfileDetailViewController ()

@end

@implementation SeequContactProfileDetailViewController

@synthesize contactObj;
@synthesize videoViewState;
@synthesize accessToConnections;

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
    if(IS_IOS_7){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    // Do any additional setup after loading the view from its nib.

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectEvent:) name:kContactObjectChangeNotification object:nil];

    [self UpdateUI];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewOrientationChange:) name:kVideoViewOrientationChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectUpdateEvent:) name:kContactObjectUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onXMPPStatusEvent:) name:kXMPPStatusChangeNotification object:nil];

    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

}


-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setVideoViewState:self.videoViewState Animated:YES];
    [self UpdateUI];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.labelRatings.text = [NSString stringWithFormat:@"%d Ratings", self.contactObj.ratingCount];

	((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleProfileDetails.png"];
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
    [self UpdateButtonsState];

    [NSThread detachNewThreadSelector:@selector(GetConnectionsOnSeequCountAsync) toTarget:self withObject:nil];
    
    SeequContactsViewController *cont_controller = [[idoubs2AppDelegate sharedInstance].contacts.viewControllers objectAtIndex:0];
    ContactObject *obj = [cont_controller CheckObjectInArrayWithPT:self.contactObj.SeequID];

    if (!obj) {
        self.buttonHeader.enabled = NO;
        self.buttonConnectionsOnSeequ.enabled = NO;
    }
    
    [self updateFooterButtonsYPosition:self.scrollViewDetails.frame.size.height - 30];    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (UIInterfaceOrientationIsPortrait([idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation)) {
        [self setVideoViewState:self.videoViewState Animated:NO];
    }
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
            NSLog(@"VideoViewState_HIDE");
            self.viewHeader.frame = CGRectMake(0, 0, 320, 76);
            [self.view addSubview:self.viewHeader];
            frame = self.view.frame;
            frame.origin.y = 76;
            frame.size.height -= 76;
            self.scrollViewDetails.contentSize = CGSizeMake(320, self.viewDetails.frame.size.height - 80);
            self.viewDetails.frame = CGRectMake(0, 0, 320, self.viewDetails.frame.size.height);

            [self updateFooterButtonsYPosition:self.scrollViewDetails.frame.size.height - 30];
        }
            break;
        case VideoViewState_TAB: {
            self.viewHeader.frame = CGRectMake(0, 0, 320, 76);
            [self.scrollViewDetails addSubview:self.viewHeader];
            self.scrollViewDetails.contentSize = CGSizeMake(320, self.viewDetails.frame.size.height + 76);
            self.viewDetails.frame = CGRectMake(0, 76, 320, self.viewDetails.frame.size.height);
            frame = CGRectMake(0, self.view.frame.size.height - 271 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 271 - diff));
            CGFloat delta = ([[UIScreen mainScreen] bounds].size.height == 568)?  96:0;
            [self updateFooterButtonsYPosition:frame.size.height -delta];
        }
            break;
        case VideoViewState_TAB_MENU: {
            NSLog(@"VideoViewState_TAB_MENU");

            self.viewHeader.frame = CGRectMake(0, 0, 320, 76);
            [self.scrollViewDetails addSubview:self.viewHeader];
            self.scrollViewDetails.contentSize = CGSizeMake(320, self.viewDetails.frame.size.height + 76);
            self.viewDetails.frame = CGRectMake(0, 76, 320, self.viewDetails.frame.size.height);
            frame = CGRectMake(0, self.view.frame.size.height - 179 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 179 - diff));

            [self updateFooterButtonsYPosition:self.scrollViewDetails.contentSize.height - 106];
        }
            break;
        default:
            break;
    }
    
    if (!CGRectEqualToRect(frame, CGRectZero)) {
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
}

- (void) updateFooterButtonsYPosition:(int)y {
    if (scrollContentSizeY  < self.scrollViewDetails.frame.size.height ) {
        self.buttonDisconnect.center = CGPointMake(80, y);
        self.buttonAddToMySeequ.center = CGPointMake(80, y);
        self.buttonBlockRequests.center = CGPointMake(240, y);
    } else {
        self.buttonDisconnect.center = CGPointMake(80, scrollContentSizeY - 30);
        self.buttonAddToMySeequ.center = CGPointMake(80, scrollContentSizeY - 30);
        self.buttonBlockRequests.center = CGPointMake(240, scrollContentSizeY - 30);
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

- (IBAction) onButtonReviews:(id)sender {
    SeequContactReviewsViewController *reviewsViewController = [[SeequContactReviewsViewController alloc] initWithNibName:@"SeequContactReviewsViewController" bundle:nil];
    reviewsViewController.contactObj = self.contactObj;
    reviewsViewController.videoViewState = self.videoViewState;
    [self.navigationController pushViewController:reviewsViewController animated:YES];
}

- (IBAction) onButtonConnectionsOnSeequ:(id)sender {
    SeequContactConnectionsViewController *connectionsViewController = [[SeequContactConnectionsViewController alloc] initWithNibName:@"SeequContactConnectionsViewController" bundle:nil];
    connectionsViewController.contactObj = self.contactObj;
    connectionsViewController.videoViewState = self.videoViewState;
    [self.navigationController pushViewController:connectionsViewController animated:YES];
}

- (IBAction) onButtonTopics:(id)sender {
    SeequContactTopicsViewController *topicsViewController = [[SeequContactTopicsViewController alloc] initWithNibName:@"SeequContactTopicsViewController" bundle:nil];
    topicsViewController.contactObj = self.contactObj;
    topicsViewController.videoViewState = self.videoViewState;
    [self.navigationController pushViewController:topicsViewController animated:YES];
}

- (IBAction) onButtonDisconnect:(id)sender {
    RSLogUI(@"[ContactProfileDetails] Disconnect clicked");
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        
#if XMPP_ON
        if (![idoubs2AppDelegate sharedInstance].xmppRoster) {
            [idoubs2AppDelegate sharedInstance].xmppRoster = [[XMPPRoster alloc] initWithStream:[[[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] XMPPHandler] xmppStream] rosterStorage:nil];
        }
        
        XMPPJID *jid = [XMPPJID jidWithUser:self.contactObj.SeequID
                                     domain:@"im.protime.tv"
                                   resource:nil];
        
        [[idoubs2AppDelegate sharedInstance].xmppRoster removeBuddy:jid];

        UINavigationController *ctrl = [self.tabBarController.viewControllers objectAtIndex:0];
        SeequContactsViewController *contactsViewController = [ctrl.viewControllers objectAtIndex:0];
        NSMutableArray *m_array = [contactsViewController AllContacts];
        [m_array removeObject:self.contactObj];
#else
        [[idoubs2AppDelegate getChatManager] RemoveBuddy:self.contactObj.SeequID];
#endif //XMPP_ON
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction) onButtonBlockRequests:(id)sender {
}

- (IBAction)onButtonAddToMySeequ:(id)sender {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        SeequRequestConnectionViewController *requestConnectionViewController = [[SeequRequestConnectionViewController alloc] initWithNibName:@"SeequRequestConnectionViewController" bundle:nil];
        requestConnectionViewController.contactObj = self.contactObj;
        [self.tabBarController presentViewController: requestConnectionViewController animated:YES completion:nil];
    }
}

- (void) setRatingStars:(int)stars {
    return;
    for (UIImageView *imageView in self.viewHeader.subviews) {
        if (imageView.tag == STAR_IMAGE_TAG) {
            [imageView removeFromSuperview];
        }
    }

    for (int i = 0; i < stars; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(276 - (stars*12)/2 + i * 12, 16, 12, 11)];
        starImageView.tag = STAR_IMAGE_TAG;
        starImageView.image = [UIImage imageNamed:@"contactRatingStar.png"];
        
        [self.viewHeader addSubview:starImageView];
    }
}

- (void) setOnlineStatus:(online_Status)online {
    switch (online) {
        case online_Status_Online: {
            [self.imageViewContactOnlineStatus setImage:[UIImage imageNamed:@"highlightedOnline.png"]];
        }
            break;
        case online_Status_Offline: {
            [self.imageViewContactOnlineStatus setImage:[UIImage imageNamed:@"highlightedOffline.png"]];
        }
            break;
        case online_Status_Away: {
            [self.imageViewContactOnlineStatus setImage:[UIImage imageNamed:@"highlightedUndefined.png"]];
        }
            break;
        default:
            break;
    }
}
-(NSArray*) collectContactLanguages{
    NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:4];

    if (self.contactObj.LanguagePrimary && self.contactObj.LanguagePrimary.length) {
        [arr addObject:self.contactObj.LanguagePrimary];
    }
    if (self.contactObj.LanguageSecond && self.contactObj.LanguageSecond.length) {
        [arr addObject:self.contactObj.LanguageSecond];
    }
    if (self.contactObj.LanguageThird && self.contactObj.LanguageThird.length) {
        [arr addObject:self.contactObj.LanguageThird];
    }
    if (self.contactObj.LanguageFourth && self.contactObj.LanguageFourth.length) {
        [arr addObject:self.contactObj.LanguageFourth];
    }
    return  [NSArray arrayWithArray:arr];
}
- (void) UpdateUI {
    self.imageViewProfile.image = self.contactObj.image;
    [self setRatingStars:ceilf(self.contactObj.ratingValue)];
    self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@", self.contactObj.FirstName, self.contactObj.LastName];
    self.labelSpecialist.text = self.contactObj.specialist;
    self.labelCompany.text = self.contactObj.company;
    self.labelReviews.text = [NSString stringWithFormat:@"%d Reviews", self.contactObj.reviewCount];
    self.labelReviewsCount.text = [NSString stringWithFormat:@"%d", self.contactObj.reviewCount];
    [self setOnlineStatus:self.contactObj.isOnline];
//    self.labelConnectionsOnSeequCount.text = [NSString stringWithFormat:@"%d", self.contactObj.connectionCount];
    
    if (self.contactObj.badgeStatus) {
        NSString *imageName = [NSString stringWithFormat:@"ProfileBadgeStatus%@.png", self.contactObj.badgeStatus];
        [self.imageViewSeequStatus setImage:[UIImage imageNamed:imageName]];
    }

    for (UIView *v in self.viewDetails.subviews) {
        if (v.tag == SUBVIEWS_TAG) {
            [v removeFromSuperview];
        }
    }
    
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
    
    
    scrollContentSizeY = 36;

    [self.viewDetails addSubview:[self CreateSectionHeaderWithText:@"Summary"]];
    scrollContentSizeY += 23;
    scrollContentSizeY = [self CreateSummaryWithText:self.contactObj.introduction
                                                Views:self.contactObj.arrayReviews.count
                                               Joined:(int)(([[NSDate date] timeIntervalSince1970] - self.contactObj.registrationDate/1000.0)/86400.0)];
//    [self.viewDetails addSubview:[self CreateSectionHeaderWithText:@"Bio"]];
//    scrollContentSizeY += 23;
//
//    scrollContentSizeY = [self CreateBioWithText:self.contactObj.biography];
    
    [self.viewDetails addSubview:[self CreateSectionHeaderWithText:@"Languages"]];
    scrollContentSizeY += 23;
    
    scrollContentSizeY = [self CreateLanguagesWithArray:[self collectContactLanguages]];
    
    if (self.contactObj.arrayInternetInfo && [self.contactObj.arrayInternetInfo isKindOfClass:[NSMutableArray class]] && self.contactObj.arrayInternetInfo.count) {
        [self.viewDetails addSubview:[self CreateSectionHeaderWithText:@"Internet"]];
        scrollContentSizeY += 23;
        
        scrollContentSizeY = [self CreateInformationWithArray:self.contactObj.arrayInternetInfo];
    }

    if (self.contactObj.arrayContactInfo && [self.contactObj.arrayContactInfo isKindOfClass:[NSMutableArray class]] && self.contactObj.arrayContactInfo.count) {
        [self.viewDetails addSubview:[self CreateSectionHeaderWithText:@"Contact Information"]];
        scrollContentSizeY += 23;
        
        scrollContentSizeY = [self CreateInformationWithArray:self.contactObj.arrayContactInfo];
    }

    if (self.contactObj.arraySocialInfo && [self.contactObj.arraySocialInfo isKindOfClass:[NSMutableArray class]] && self.contactObj.arraySocialInfo.count) {
        [self.viewDetails addSubview:[self CreateSectionHeaderWithText:@"Social Information"]];
        scrollContentSizeY += 23;
        
        scrollContentSizeY = [self CreateInformationWithArray:self.contactObj.arraySocialInfo];
    }
    
    scrollContentSizeY += 60;
    
    [self.scrollViewDetails setContentSize:CGSizeMake(320, scrollContentSizeY)];
    
    if (self.viewDetails.frame.size.height < scrollContentSizeY) {
        self.viewDetails.frame = CGRectMake(0, 0, 320, scrollContentSizeY);
    }
    [self updateFooterButtonsYPosition:self.scrollViewDetails.frame.size.height - 30];
}

- (void) onXMPPStatusEvent:(NSNotification*)notification {
    NSDictionary* eargs = [notification object];
    
    if (eargs) {
        NSString *seequID = [eargs objectForKey:@"SeequID"];
        
        if ([self.contactObj.SeequID isEqualToString:seequID]) {
            online_Status online = (online_Status)[[eargs objectForKey:@"Status"] intValue];
            [self setOnlineStatus:online];
        }
    }
}

- (void) onContactObjectEvent:(NSNotification*)notification {
    ContactObject* eargs = [notification object];
    
    if (eargs) {
        if ([self.contactObj.SeequID isEqualToString:eargs.SeequID]) {
            self.contactObj.contactType = eargs.contactType;
            [self UpdateButtonsState];
        }
    }
}

- (void) onContactObjectUpdateEvent:(NSNotification*)notification {
         NSString *seequId = [notification object];
    
    if (seequId) {
        if ([self.contactObj.SeequID isEqualToString:seequId]) {
            self.contactObj = [[ContactStorage sharedInstance] GetContactObjectBySeequId:seequId];
            [self UpdateUI];
            [self UpdateButtonsState];
        }
    }
}

- (UIImageView*) CreateSectionHeaderWithText:(NSString*)text {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, scrollContentSizeY, 320, 23)];
    imageView.tag = SUBVIEWS_TAG;
    [imageView setImage:[UIImage imageNamed:@"contactProfileDetailsSectionBG.png"]];
    UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 320, 23)];
    [lblText setFont:[UIFont boldSystemFontOfSize:17]];
    [lblText setBackgroundColor:[UIColor clearColor]];
    [lblText setTextColor:[UIColor whiteColor]];
    [lblText setText:text];
    [imageView addSubview:lblText];
    
    return imageView;
}

- (int) CreateSummaryWithText:(NSString*)text Views:(int)viewCount Joined:(NSTimeInterval)joinedCount {
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
    lblText.tag = SUBVIEWS_TAG;
    [self.viewDetails addSubview:lblText];
    
    scrollContentSizeY = scrollContentSizeY + 5 + size.height;

    UIImageView *imageViewLine = [[UIImageView alloc] initWithFrame:CGRectMake(20, scrollContentSizeY + 2.5, 279, 2)];
    [imageViewLine setImage:[UIImage imageNamed:@"contactProfileDetailsTextBreakLine.png"]];
    imageViewLine.tag = SUBVIEWS_TAG;
    [self.viewDetails addSubview:imageViewLine];
     
    self.labelReviewsCountInSection.text = [self CreateReviewsCountTextWithCount:viewCount];
    self.labelDateOfJoined.text = [self CreateJoinedDateTextWithDays:joinedCount];

    [self CalculateViewJoinedLabelsPositions];
    self.viewViewJoined.frame = CGRectMake(0, scrollContentSizeY + 3, 320, 26);
    [self.viewDetails addSubview:self.viewViewJoined];

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
    lblText.tag = SUBVIEWS_TAG;
    [self.viewDetails addSubview:lblText];
    
    scrollContentSizeY = scrollContentSizeY + 5 + size.height;
    
    return scrollContentSizeY;
}

- (int) CreateLanguagesWithArray:(NSArray*)array {
    
    NSString *language;
    int index = 15;
    for (language in array) {
        if ([language isEqualToString:@"German"]) {
            language = @"Germany";
        }
        
        
        
        NSString *filePath = [Common FindFilePathWithFilename:@"LanguageList.plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        
        NSArray *array = [dict objectForKey:@"Item"];
        NSString *imageName = nil;
        for (int i = 0; i <  array.count; i++) {
            if ([language isEqualToString:[[array objectAtIndex:i] objectAtIndex:0]]) {
                imageName = [[array objectAtIndex:i] objectAtIndex:1];
                break;
                
            }
            
        }

        UIImage* image = [UIImage imageNamed:imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        if (image) {
            CGFloat scrollfactor =  30/image.size.width;
            imageView.frame = CGRectMake(index, scrollContentSizeY + 10, image.size.width* scrollfactor, image.size.height*  scrollfactor);
        } else {
            imageView.frame = CGRectMake(index, scrollContentSizeY + 10, 24,24);
        }
   
        imageView.tag = SUBVIEWS_TAG;
        [self.viewDetails addSubview:imageView];
        
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, scrollContentSizeY + 35, 60, 20)];
        lblName.center = CGPointMake(imageView.center.x, lblName.center.y);
        [lblName setFont:[UIFont systemFontOfSize:10]];
        [lblName setTextColor:[UIColor blackColor]];
        [lblName setTextAlignment:NSTextAlignmentCenter];
        [lblName setText:language];
        lblName.tag = SUBVIEWS_TAG;
        [self.viewDetails addSubview:lblName];
        
        index += 60;
    }
    
    return scrollContentSizeY + 60;
}

- (int) CreateInformationWithArray:(NSArray*)array {
    for (NSDictionary *dict in array) {
        NSString *name = [dict objectForKey:@"itemName"];
        NSString *value = [dict objectForKey:@"itemValue"];
        
        if (name && [name isKindOfClass:[NSString class]] &&
            value && [value isKindOfClass:[NSString class]]) {
            scrollContentSizeY += [self CreateInformationItemWithName:name Value:value];
        }
    }
    
    return scrollContentSizeY;
}

- (int) CreateInformationItemWithName:(NSString*)name Value:(NSString*)value {
    UIImageView *imageViewBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, scrollContentSizeY, 320, 36)];
    [imageViewBG setImage:[UIImage imageNamed:@"contactProfileDetailsDefaultCellBG.png"]];
    imageViewBG.tag = SUBVIEWS_TAG;
    [self.viewDetails addSubview:imageViewBG];
    
    UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(5, scrollContentSizeY + 5, 70, 26)];
    [lblHeader setBackgroundColor:[UIColor clearColor]];
    [lblHeader setFont:[UIFont systemFontOfSize:14]];
    [lblHeader setTextColor:[UIColor lightGrayColor]];
    [lblHeader setText:name];
    [lblHeader setTextAlignment:NSTextAlignmentLeft];
    lblHeader.tag = SUBVIEWS_TAG;
    [self.viewDetails addSubview:lblHeader];
    
    UILabel *lblValue = [[UILabel alloc] initWithFrame:CGRectMake(80, scrollContentSizeY + 5, 230, 26)];
    [lblValue setBackgroundColor:[UIColor clearColor]];
    [lblValue setFont:[UIFont systemFontOfSize:14]];
    [lblValue setTextColor:[UIColor blackColor]];
    [lblValue setText:value];
    [lblValue setTextAlignment:NSTextAlignmentLeft];
    lblValue.tag = SUBVIEWS_TAG;
    [self.viewDetails addSubview:lblValue];
    
    return (int)imageViewBG.image.size.height;
}

- (void) UpdateButtonsState {
    
    switch (self.contactObj.contactType) {
        case Contact_Type_Request_Connection:
        case Contact_Type_Recent:
        case Contact_Type_MY_Seequ_Contact: {
            self.buttonAddToMySeequ.hidden = YES;
            self.buttonDisconnect.hidden = NO;
            self.buttonBlockRequests.hidden = NO;
        }
            break;
        case Contact_Type_Seequ_Contact: {
            self.buttonAddToMySeequ.hidden = NO;
            self.buttonDisconnect.hidden = YES;
            self.buttonBlockRequests.hidden = NO;
        }
            break;
        case Contact_Type_Request_Accepted: {
            
        }
            break;
            
        default:
            break;
    }
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
    currentXPosition = self.labelAgo.frame.origin.x + self.labelAgo.frame.size.width;
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

- (void) GetConnectionsOnSeequCountAsync {
    @autoreleasepool {
        int contactCount = [Common GetContactCountWithSeequID:self.contactObj.SeequID];
        [self.activityIndicatorConnectionCount performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
        [self.labelConnectionsOnSeequCount performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%d", contactCount] waitUntilDone:YES];
    }
}

#pragma mark -----XMPPRoster-----

- (id <XMPPUser>)myUserForXMPPStream:(XMPPStream *)xmppStream {
    return nil;
}
- (id <XMPPResource>)myResourceForXMPPStream:(XMPPStream *)xmppStream {
    return nil;
}
- (id <XMPPUser>)userForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)xmppStream {
    return nil;
}
- (id <XMPPResource>)resourceForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)xmppStream {
    return nil;
}
- (void)beginRosterPopulationForXMPPStream:(XMPPStream *)xmppStream {
}
- (void)endRosterPopulationForXMPPStream:(XMPPStream *)xmppStream {
}
- (void)handleRosterItem:(NSXMLElement *)item xmppStream:(XMPPStream *)xmppStream {
}
- (void)handlePresence:(XMPPPresence *)presence xmppStream:(XMPPStream *)xmppStream {
}
- (void)clearAllResourcesForXMPPStream:(XMPPStream *)xmppStream {
}
- (void)clearAllUsersAndResourcesForXMPPStream:(XMPPStream *)xmppStream {
}
- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageViewProfile:nil];
    [self setLabelSpecialist:nil];
    [self setLabelCompany:nil];
    [self setLabelLocation:nil];
    [self setLabelDisplayName:nil];
    [self setLabelRatings:nil];
    [self setLabelReviews:nil];
    [self setLabelReviewsCount:nil];
    [self setLabelConnectionsOnSeequCount:nil];
    [self setLabelTopicsCount:nil];
    [self setScrollViewDetails:nil];
    [self setButtonBlockRequests:nil];
    [self setButtonDisconnect:nil];
    [self setButtonAddToMySeequ:nil];
    [self setImageViewSeequStatus:nil];
    [self setViewHeader:nil];
    [self setViewDetails:nil];
    [self setViewViewJoined:nil];
    [self setLabelReviewsCountInSection:nil];
    [self setLabelViewJoined:nil];
    [self setLabelDateOfJoined:nil];
    [self setLabelAgo:nil];
    [self setButtonConnectionsOnSeequ:nil];
    [self setActivityIndicatorConnectionCount:nil];
    [self setImageViewContactOnlineStatus:nil];
    [self setButtonHeader:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
