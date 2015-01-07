//
//  SeequSettingsViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/4/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequSettingsViewController.h"
#import "SeequMuteMembersViewController.h"
#import "SeequReportAProblemViewController.h"
#import "SeequTermsPrivacyViewController.h"
#import "SeequHelpViewController.h"
#import "SeequAboutViewController.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"
#import "NavigationBar.h"
#import "BackBarButton.h"
#import "SeequDevelopmentSettingsViewController.h"
#import "SeequDoubleTakeSettingsViewController.h"
#import "SeequPresentationViewController.h"
#import "SeequChangePasswordViewController.h"
#import "SeequBillingViewController.h"


@interface SeequSettingsViewController ()

@end

@implementation SeequSettingsViewController

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
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    if(IS_IOS_7){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    // Do any additional setup after loading the view from its nib.
#ifdef RSDEBUG
    
    arrayTexts = [[NSArray alloc] initWithObjects:
                  @"                  Profile Visible",
                  @"                  Audio Call on Speaker",
                  @"                  Headset on Proximity",
                  @"                  Mute",
                  @"Development",
                  @"Billing",
                  @"Double take",
                  @"Muted Members",
                  @"Help",
                  @"Make a Suggestion",
                  @"Report a Problem",
                  @"Terms, Privacy & Acceptable Use",
                  @"Change Password",
                  @"Log Out",
                  @"About",nil];
#else
    arrayTexts = [[NSArray alloc] initWithObjects:
                  @"                  Profile Visible",
                  @"                  Audio Call on Speaker",
                  @"                  Headset on Proximity",
                  @"                  Mute",
                  @"Billing",
                  @"Double take",
                  @"Muted Members",
                  @"Help",
                  @"Make a Suggestion",
                  @"Report a Problem",
                  @"Terms, Privacy & Acceptable Use",
                  @"Change Password",
                  @"Log Out",
                  @"About", nil];
    
#endif
    
    self.MyTableView.tableHeaderView = self.viewHeader;
    Common *common = [Common sharedCommon];
    self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@", common.contactObject.FirstName, common.contactObject.LastName];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewChange:)
                                                 name:kVideoViewChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewOrientationChange:)
                                                 name:kVideoViewOrientationChangeNotification
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	((NavigationBar*) self.navigationController.navigationBar).titleImage = nil;
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    self.navigationItem.title = @"Settings";
    
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack:)];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    if (UIInterfaceOrientationIsPortrait([idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation)) {
        [self setVideoViewState:self.videoViewState Animated:NO];
    }
    [self.MyTableView reloadData];
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
            frame = CGRectMake(0, 0, 320, 367 + diff);
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
        if (animated) {
            [UIView beginAnimations:@"tableFrame" context:nil];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.3];
        }
        self.MyTableView.frame = frame;
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrayTexts.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    if (indexPath.row < 4) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UISwitch *switch_ = [[UISwitch alloc] init];
        [switch_ addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [switch_ setOnTintColor:[UIColor colorWithRed:112.0/255.0 green:173.0/255.0 blue:192.0/255.0 alpha:1]];
        switch_.tag = indexPath.row;
        switch_.center = CGPointMake(50, 25);
        [cell addSubview:switch_];
        
        switch (indexPath.row) {
           
            case 0: {
                [switch_ setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"online"]];
            }
                break;
//            case 4: {
//                [switch_ setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"RememberPassword"]];
//            }
//                break;
            case 1: {
                [switch_ setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"DefaultAudioOutputInAudioCall"]];
            }
                break;
            case 2: {
                [switch_ setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"ProximityAudioOutputChange"]];
            }
                break;
            case 3: {
                [switch_ setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"Mute"]];
            }
                break;
            default:
                break;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Set up the cell...
    
    //First get the dictionary object
    NSString *text = [arrayTexts objectAtIndex:indexPath.row];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];

    if ([text isEqualToString:@"Development"] && [userDef boolForKey:DEVELOPER_MODE]) {
        cell.textLabel.textColor = [UIColor greenColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    cell.textLabel.text = text;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
//    NSMutableArray *array = [sectionsArray objectAtIndex:indexPath.section];
//    ContactObject *obj = [array objectAtIndex:indexPath.row];
//    
//    SeequContactProfileViewController *profileViewController = [[SeequContactProfileViewController alloc] initWithNibName:@"SeequContactProfileViewController" bundle:nil];
//    profileViewController.contactObj = obj;
//    [self.navigationController pushViewController:profileViewController animated:YES];

    NSString *text = [arrayTexts objectAtIndex:indexPath.row];
    
    if ([text isEqualToString:@"Development"]) {
        
        SeequDevelopmentSettingsViewController*  controller = [[SeequDevelopmentSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:controller animated:YES];
    } else if([text isEqualToString:@"Muted Members"]) {
        SeequMuteMembersViewController *blockedMembersViewController = [[SeequMuteMembersViewController alloc] initWithFrame:self.view.frame];
        [self.navigationController pushViewController:blockedMembersViewController animated:YES];
    } else if ([text isEqualToString:@"Report a Problem"]) {
        SeequReportAProblemViewController *reportAProblemViewController = [[SeequReportAProblemViewController alloc] initWithNibName:@"SeequReportAProblemViewController" bundle:nil];
        [self.tabBarController presentViewController:reportAProblemViewController animated:YES completion:^{
            
        }];
    } else if ([text isEqualToString:@"Terms, Privacy & Acceptable Use"]) {
        SeequTermsPrivacyViewController *termsPrivacyViewController = [[SeequTermsPrivacyViewController alloc] initWithNibName:@"SeequTermsPrivacyViewController" bundle:nil];
        termsPrivacyViewController.videoViewState = self.videoViewState;
        [self.navigationController pushViewController:termsPrivacyViewController animated:YES];
    } else if ([text isEqualToString:@"About"]) {
        SeequAboutViewController *aboutViewController = [[SeequAboutViewController alloc] initWithNibName:@"SeequAboutViewController" bundle:nil];
        aboutViewController.videoViewState = self.videoViewState;
        [self.navigationController pushViewController:aboutViewController animated:YES];
    } else  if ([text isEqualToString:@"Help"]) {
        SeequHelpViewController *helpViewController = [[SeequHelpViewController alloc] initWithNibName:@"SeequHelpViewController" bundle:nil];
        [self.navigationController pushViewController:helpViewController animated:YES];
    }else if ([text isEqualToString:@"Double take"]){
        SeequDoubleTakeSettingsViewController* doubleTakeViewController=[[SeequDoubleTakeSettingsViewController alloc] initWithNibName:@"SeequDoubleTakeSettingsViewController" bundle:nil];
        [self.navigationController pushViewController:doubleTakeViewController animated:YES ];
    }else if ([text isEqualToString:@"Log Out"]){
            //            [NSUserDefaults resetStandardUserDefaults];
            [[idoubs2AppDelegate sharedInstance] logOutSeequ:nil];
            
    }else if ([text isEqualToString:@"Change Password"]){
        SeequChangePasswordViewController *changePasswordViewController=[[SeequChangePasswordViewController alloc] initWithNibName:@"SeequChangePasswordViewController" bundle:nil];
            [self.navigationController pushViewController:changePasswordViewController animated:YES];
    } else if([text isEqualToString:@"Billing"]){
        SeequBillingViewController*  billingViewCOntroller = [[SeequBillingViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:billingViewCOntroller animated:YES];
    }

    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (IBAction) switchValueChanged:(id)sender {
    UISwitch *switch_ = (UISwitch*)sender;
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];

    switch (switch_.tag) {
        case 0: {
            [userDef setBool:switch_.on forKey:@"online"];
        }
            break;
        case 1: {
             [userDef setBool:switch_.on forKey:@"DefaultAudioOutputInAudioCall"];
        }
            break;
        case 2: {
            [userDef setBool:switch_.on forKey:@"ProximityAudioOutputChange"];
        }
            break;
        case 3: {
           [userDef setBool:switch_.on forKey:@"Mute"];
            [Common BlockRequests:switch_.on];
        }
            break;
       
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLabelDisplayName:nil];
    [self setViewHeader:nil];
    [self setMyTableView:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
