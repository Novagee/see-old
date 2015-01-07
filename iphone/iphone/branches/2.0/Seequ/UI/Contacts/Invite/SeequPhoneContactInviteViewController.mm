//
//  SeequPhoneContactInviteViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 12/14/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequPhoneContactInviteViewController.h"
#import "idoubs2AppDelegate.h"
#import "NavigationBar.h"
#import "BackBarButton.h"


#define actionSheetButtonTitleSMS @"SMS"
#define actionSheetButtonTitleEmail @"Email"


@interface SeequPhoneContactInviteViewController ()

@end

@implementation SeequPhoneContactInviteViewController


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
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    if(IS_IOS_7){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    // Do any additional setup after loading the view from its nib.

    if (!self.contactObj.imageExist) {
        self.imageViewProfile.image = [UIImage imageNamed:@"GenericContact.png"];
    } else {
        if (self.contactObj.image) {
            self.imageViewProfile.image = self.contactObj.image;
        } else {
            self.imageViewProfile.image = [UIImage imageNamed:@"GenericContact.png"];
        }
    }

    self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@", self.contactObj.FirstName, self.contactObj.LastName];
    self.labelSpecialist.text = self.contactObj.company;
    
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
    
	((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleInvite.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack:)];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    self.scrollViewContent.contentSize = CGSizeMake(320, 367);
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
            [UIView beginAnimations:@"scrollFrame" context:nil];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.3];
        }
        self.scrollViewContent.frame = frame;
        if (animated) {
            [UIView commitAnimations];
        }
    }

}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onButtonInvite:(id)sender {
    UIActionSheet *actionSheetInvite = [[UIActionSheet alloc] initWithTitle:@"Invite by"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:nil];

    if ([MFMailComposeViewController canSendMail] && [self.contactObj HaveEmailAddress]) {
        [actionSheetInvite addButtonWithTitle:actionSheetButtonTitleEmail];
    }

    if ([MFMessageComposeViewController canSendText] && [self.contactObj HavePhoneNumber]) {
        [actionSheetInvite addButtonWithTitle:actionSheetButtonTitleSMS];
    }

    actionSheetInvite.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheetInvite.tag = 1;
    [actionSheetInvite showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)onButtonRingBack:(id)sender {
    UIActionSheet *actionSheetInvite = [[UIActionSheet alloc] initWithTitle:@"Ringback by"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:nil];
    
    if ([MFMailComposeViewController canSendMail] && [self.contactObj HaveEmailAddress]) {
        [actionSheetInvite addButtonWithTitle:actionSheetButtonTitleEmail];
    }
    
    if ([MFMessageComposeViewController canSendText] && [self.contactObj HavePhoneNumber]) {
        [actionSheetInvite addButtonWithTitle:actionSheetButtonTitleSMS];
    }
    
    actionSheetInvite.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheetInvite.tag = 2;
    [actionSheetInvite showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if ([buttonTitle isEqualToString:actionSheetButtonTitleEmail]) {
            if (![MFMailComposeViewController canSendMail]) {
                return;
            }
            
            NSMutableArray *arrayRecipients = [[NSMutableArray alloc] init];
            for (AddressBookItem *item in self.contactObj.arrayAddressBookItems) {
                if (item.itemType == Item_Type_EMail) {
                    [arrayRecipients addObject:item.value];
                }
            }
            
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setMessageBody:@"Hey, you should get Seequ." isHTML:NO];
            [picker setSubject:@"Seequ Invitation"];
            [picker setToRecipients:arrayRecipients];
            [self.tabBarController presentViewController:picker animated:YES completion:nil];
            
            return;
        }
        
        if ([buttonTitle isEqualToString:actionSheetButtonTitleSMS]) {
            if (![MFMessageComposeViewController canSendText]) {
                return;
            }
            
            NSMutableArray *arrayRecipients = [[NSMutableArray alloc] init];
            for (AddressBookItem *item in self.contactObj.arrayAddressBookItems) {
                if (item.itemType == Item_Type_Phone_Number) {
                    [arrayRecipients addObject:item.value];
                }
            }
            
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate = self;
            [picker setBody:@"Hey, you should get Seequ."];
            [picker setRecipients:arrayRecipients];
            [self.tabBarController presentViewController:picker animated:YES completion:nil];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLabelDisplayName:nil];
    [self setLabelSpecialist:nil];
    [self setLabelLocation:nil];
    [self setImageViewProfile:nil];
    [self setScrollViewContent:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
