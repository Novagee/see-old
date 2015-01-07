//
//  SeequContactConnectionsViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 9/28/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequContactConnectionsViewController.h"
#import "SeequContactProfileViewController.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"
#import "ContactCell.h"
#import "NavigationBar.h"
#import "BackBarButton.h"

@interface SeequContactConnectionsViewController ()

@end

@implementation SeequContactConnectionsViewController

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
    if(IS_IOS_7){
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.MyTableView.sectionIndexBackgroundColor=[UIColor clearColor];
    }
    [self.MySearchBar setPlaceholder:@"Search List"];
    // Do any additional setup after loading the view from its nib.
    self.MyTableView.tableHeaderView = self.MySearchBar;
    arrayContacts = [[NSMutableArray alloc] init];
    
    [self UpdateUI];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewOrientationChange:) name:kVideoViewOrientationChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectUpdateEvent:) name:kContactObjectUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onXMPPStatusEvent:) name:kXMPPStatusChangeNotification object:nil];
    
//    [NSThread detachNewThreadSelector:@selector(GetContactConnections) toTarget:self withObject:nil];
    self.MySearchBar.tintColor = [UIColor colorWithWhite:0.3 alpha:1.0];

    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleConnections.png"];
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
//            frame = self.view.frame;
            frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 271 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 271 - diff));
//            self.scrollViewContent.frame = frame;
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 179 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 179 - diff));
//            self.scrollViewContent.frame = frame;
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
            tableOriginY = 73;
        } else {
            tableOriginY = 105;
        }
        self.MyTableView.frame = CGRectMake(0,self.buttonAll.frame.origin.y +self.buttonAll.frame.size.height , 320, frame.size.height - tableOriginY);
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (void) onContactObjectUpdateEvent:(NSNotification*)notification {
  NSString *seequId = [notification object];
    
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
    [self onButtonFilter:self.buttonAll];
    self.labelDisplayName.text = [NSString stringWithFormat:@"%@ %@", self.contactObj.FirstName, self.contactObj.LastName];
    
    SeequContactsViewController *contactsViewController = [[idoubs2AppDelegate sharedInstance].contacts.viewControllers objectAtIndex:0];
    
    if (contactsViewController && [contactsViewController isKindOfClass:[SeequContactsViewController class]]) {
        ContactObject *obj = [contactsViewController CheckObjectInArrayWithPT:self.contactObj.SeequID];
        if (!obj) {
            self.contactObj.isOnline = online_Status_Away;
        } else {
            self.contactObj.isOnline = obj.isOnline;
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


    [self setOnlineStatus:self.contactObj.isOnline];
    self.labelSpecialist.text = self.contactObj.specialist;
    self.labelCompany.text = self.contactObj.company;
    
    if (self.contactObj.badgeStatus) {
        NSString *imageName = [NSString stringWithFormat:@"ProfileBadgeStatus%@.png", self.contactObj.badgeStatus];
        [self.imageViewSeequStatus setImage:[UIImage imageNamed:imageName]];
    }
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) GetContactConnections {
    @autoreleasepool {
        NSDictionary *dictionary;
        NSString *error_msg = [Common GetAllUsersBySeequID:self.contactObj.SeequID];
        
        if (error_msg) {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                                message:error_msg
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            }
        } else {
            NSDictionary *return_values = [dictionary objectForKey:@"return_values"];
            NSArray *array = [return_values objectForKey:@"users"];

            SeequContactsViewController *contactsViewController = [[idoubs2AppDelegate sharedInstance].contacts.viewControllers objectAtIndex:0];

            for (NSDictionary *dict in array) {
                if (dict) {
                    NSString *seequID = [dict objectForKey:@"seeQuId"];
                    ContactObject *obj = [[ContactObject alloc] initWithSeequID:seequID];
                    obj.contactType = Contact_Type_Seequ_Contact;
                    [obj SetUserInfoWithDictionary:dict];
                    
                    NSData *imageData;
                    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2) {
                        //Retina display
                        imageData = [Common GetLastCatchedImageWithSeequID:seequID Height:IMAGE_HEIGHT*2];
                    } else {
                        imageData = [Common GetLastCatchedImageWithSeequID:seequID Height:IMAGE_HEIGHT];
                    }
                    
                    if (imageData) {
                        obj.image = [[UIImage alloc] initWithData:imageData];
                    } else {
                        obj.image = [Common GetImageByPTID:seequID andHeight:IMAGE_HEIGHT];
                    }
                    
                    if (contactsViewController && [contactsViewController isKindOfClass:[SeequContactsViewController class]]) {
                        ContactObject *obj_ = [contactsViewController CheckObjectInArrayWithPT:obj.SeequID];
                        if (!obj_) {
                            obj.isOnline = online_Status_Away;
                        } else {
                            obj.isOnline = obj_.isOnline;
                        }
                    }
                    
                    [arrayContacts addObject:obj];
                    [Common AddContactObjectToCommonArray:obj];
                }
            }
            
            [self ReplaceForMySeequContacts:arrayContacts];
            [self performSelectorOnMainThread:@selector(RefreshList) withObject:nil waitUntilDone:YES];
        }
        
        [self.viewLoading performSelectorOnMainThread:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
    }
}

- (void) RefreshList {
    [self filterContactsWithSegment_Type:connectionType];
    [self.MyTableView reloadData];
}
/*
- (void) onButtonAction:(id)sender {
    //    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share this Profile"
    //                                                             delegate:self
    //                                                    cancelButtonTitle:@"Cancel"
    //                                               destructiveButtonTitle:nil
    //                                                    otherButtonTitles:@"Email", @"SMS", @"Facebook", @"Twitter", nil];
    //    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}
*/
- (void) setRatingStars:(int)stars {
    return;
    for (int i = 0; i < stars; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(276 - (stars*12)/2 + i * 12, 33, 12, 11)];
        starImageView.image = [UIImage imageNamed:@"contactRatingStar.png"];
        
        [self.view addSubview:starImageView];
    }
}

- (IBAction)onButtonFilter:(id)sender {
    UIButton *button = (UIButton*)sender;
    
    switch (button.tag) {
        case 1: {
            connectionType = Connection_Type_All;
            [self.buttonAll setBackgroundImage:[UIImage imageNamed:@"segConnectionsAllSel.png"] forState:UIControlStateNormal];
            [self.buttonCommon setBackgroundImage:[UIImage imageNamed:@"segConnectionsCommon.png"] forState:UIControlStateNormal];
        }
            break;
        case 2: {
            connectionType = Connection_Type_Common;
            [self.buttonAll setBackgroundImage:[UIImage imageNamed:@"segConnectionsAll.png"] forState:UIControlStateNormal];
            [self.buttonCommon setBackgroundImage:[UIImage imageNamed:@"segConnectionsCommonSel.png"] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    
    [self filterContactsWithSegment_Type:connectionType];
    [self.MyTableView reloadData];
}

- (void) filterContactsWithSegment_Type:(Connection_Type)conn_Type {
    switch (conn_Type) {
        case Connection_Type_All: {
            sectionsArray = [self configureSectionsWithArray:arrayContacts];
        }
            break;
        case Connection_Type_Common: {
            NSMutableArray *array = [self CompareArraysWithArray:arrayContacts];
            sectionsArray = [self configureSectionsWithArray:array];
        }
            break;
            
        default:
            break;
    }
}

- (NSMutableArray*) CompareArraysWithArray:(NSMutableArray*)array {
    SeequContactsViewController *contactsViewController = [[idoubs2AppDelegate sharedInstance].contacts.viewControllers objectAtIndex:0];
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    for (ContactObject *object in array) {
        ContactObject *obj = [contactsViewController CheckObjectInArrayWithPT:object.SeequID];
        
        if (obj) {
            [returnArray addObject:obj];
        }
    }
    
    return returnArray;
}

- (void) ReplaceForMySeequContacts:(NSMutableArray*)array {
    SeequContactsViewController *contactsViewController = [[idoubs2AppDelegate sharedInstance].contacts.viewControllers objectAtIndex:0];
    
    for (int i = 0; i < array.count; i++) {
        ContactObject *object = [array objectAtIndex:i];
        ContactObject *obj = [contactsViewController CheckObjectInArrayWithPT:object.SeequID];
        
        if (obj) {
            [array replaceObjectAtIndex:i withObject:obj];
        }
    }
}

- (NSMutableArray*)configureSectionsWithArray:(NSArray*)array {
	// Get the current collation and keep a reference to it.
	UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
	
	NSInteger index, sectionTitlesCount = [[collation sectionTitles] count];
	
	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
	
	for (index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray *array_ = [[NSMutableArray alloc] init];
		[newSectionsArray addObject:array_];
	}
	
	for (ContactObject *obj in array) {
        if (!obj.isNameSeted || obj.contactType == Contact_Type_Request_Connection) {
            continue;
        }
        
        NSInteger sectionNumber;
        
        sectionNumber = [collation sectionForObject:obj collationStringSelector:@selector(displayName)];
		
		// Get the array for the section.
		NSMutableArray *sectionTimeZones = [newSectionsArray objectAtIndex:sectionNumber];
		
		//  Add the Person to the section.
		[sectionTimeZones addObject:obj];
	}
	
	index = 0;
	
	while (index < [newSectionsArray count]) {
		NSMutableArray *marray = [newSectionsArray objectAtIndex:index];
		if (![marray count]) {
			[newSectionsArray removeObject:marray];
		} else {
			index++;
		}
	}
	
	// Now that all the data's in place, each section array needs to be sorted.
	for (index = 0; index < [newSectionsArray count]; index++) {
		
		NSMutableArray *timeZonesArrayForSection = [newSectionsArray objectAtIndex:index];
		
		// If the table view or its contents were editable, you would make a mutable copy here.
		NSArray *sortedTimeZonesArrayForSection;
		
        sortedTimeZonesArrayForSection = [collation sortedArrayFromArray:timeZonesArrayForSection collationStringSelector:@selector(displayName)];
        
		// Replace the existing array with the sorted array.
		[newSectionsArray replaceObjectAtIndex:index withObject:sortedTimeZonesArrayForSection];
	}
	
    return newSectionsArray;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  [sectionsArray count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Number of rows it should expect should be based on the section
    if ([sectionsArray count] > section) {
        NSMutableArray *array = [sectionsArray objectAtIndex:section];
        return [array count];
    } else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([sectionsArray count] > section) {
        ABPersonSortOrdering sort = ABPersonGetSortOrdering();
        NSMutableArray *array = [sectionsArray objectAtIndex:section];
        ContactObject *obj = [array objectAtIndex:0];
        
        if (sort == kABPersonSortByFirstName) {
            if (obj.FirstName && [obj.FirstName isKindOfClass:[NSString class]] && obj.FirstName.length) {
                return [[obj.FirstName substringToIndex:1] uppercaseString];
            } else {
                return @"#";
            }
        } else {
            if (obj.LastName && [obj.LastName isKindOfClass:[NSString class]] && obj.LastName.length) {
                return [[obj.LastName substringToIndex:1] uppercaseString];
            } else {
                return @"#";
            }
        }
        
    } else {
        return nil;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    //    ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //    if (cell == nil) {
    ContactCell *cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //    }
    
    // Set up the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //First get the dictionary object
    if (sectionsArray.count > indexPath.section) {
        NSMutableArray *array = [sectionsArray objectAtIndex:indexPath.section];
        if (array.count > indexPath.row) {
            ContactObject *obj = [array objectAtIndex:indexPath.row];
            
            [cell setContactObject:obj];
        } else {
            NSLog(@"if (array.count > indexPath.row) {");
        }
    } else {
        NSLog(@"if (sectionsArray.count > indexPath.section) {");
    }
    
    return cell;

}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = [sectionsArray objectAtIndex:indexPath.section];
    ContactObject *obj = [array objectAtIndex:indexPath.row];
    if([obj.SeequID isEqualToString:[Common sharedCommon].SeequID]){
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSMutableArray *array = [sectionsArray objectAtIndex:indexPath.section];
    ContactObject *obj = [array objectAtIndex:indexPath.row];
    SeequContactProfileViewController *profileViewController = [[SeequContactProfileViewController alloc] initWithNibName:@"SeequContactProfileViewController" bundle:nil];
    profileViewController.contactObj = obj;
    profileViewController.accessToConnections = NO;
    [self.navigationController pushViewController:profileViewController animated:YES];
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
////	if(letUserSelectRow)
////		return indexPath;
////	else
//		return nil;
//}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    return [collation sectionTitles];
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(IS_IOS_7){
       // UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, -5, 320, 30)];
        sectionTitle.text = [self tableView:tableView titleForHeaderInSection:section];
        sectionTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        //        sectionTitle.shadowColor = [UIColor colorWithWhite:0 alpha:0.4];
        //        sectionTitle.shadowOffset = CGSizeMake(1, 1);
        //sectionTitle.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [sectionTitle setTextColor:[UIColor whiteColor]];
        headerView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"seequSectionTabelHeader"]];
        [headerView addSubview:sectionTitle];
        return headerView;
    }
    else{
        return nil;
    }
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 23.3;
}


#pragma mark -
#pragma mark UISearchBar Delegate Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.MySearchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.MySearchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText && [searchText length]) {
        NSMutableArray *array = [self ArrayWithSearchText:searchText onArray:arrayContacts];
        sectionsArray = [self configureSectionsWithArray:array];
    } else {
        sectionsArray = [self configureSectionsWithArray:arrayContacts];
    }
    if(searchText.length == 0){
        [self.MySearchBar setPlaceholder:@"Search List"];
    }
    [self.MyTableView reloadData];
    
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
    [self.MySearchBar setText:@""];
}

- (NSMutableArray*) ArrayWithSearchText:(NSString*)text onArray:(NSArray*)base_array {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (text && [text length]) {
        for (ContactObject *obj in base_array) {
            NSString *displayName = [obj.displayName stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            NSComparisonResult result = [displayName compare:text options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [text length])];
            if (result == NSOrderedSame) {
                [array addObject:obj];
                
                continue;
            }
            
            result = [obj.FirstName compare:text options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [text length])];
            if (result == NSOrderedSame) {
                [array addObject:obj];
                
                continue;
            }
            
            result = [obj.LastName compare:text options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [text length])];
            if (result == NSOrderedSame) {
                [array addObject:obj];
            }
        }
    }
    
    return array;
}

- (void)viewDidUnload {
    [self setMySearchBar:nil];
    [self setMyTableView:nil];
    [self setImageViewProfile:nil];
    [self setButtonAll:nil];
    [self setButtonCommon:nil];
    [self setLabelDisplayName:nil];
    [self setLabelCompany:nil];
    [self setLabelSpecialist:nil];
    [self setImageViewContactOnlineStatus:nil];
    [self setImageViewSeequStatus:nil];
    [self setViewLoading:nil];
    [self setIndicatorView:nil];
    [self setLabelLocation:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
