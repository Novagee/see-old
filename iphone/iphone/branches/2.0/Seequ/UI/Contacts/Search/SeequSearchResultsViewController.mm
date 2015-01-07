//
//  SeequSearchResultsViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/3/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//
#import "ContactStorage.h"
#import "SeequSearchResultsViewController.h"
#import "SeequContactProfileViewController.h"
#import "SeequContactsViewController.h"
#import "SeequInviteViewController.h"
#import "idoubs2AppDelegate.h"
#import "NavigationBar.h"
#import "BackBarButton.h"
#import "ContactCell.h"
#import "Common.h"

#define  SEARCH_STEP_COUNT 30

@interface SeequSearchResultsViewController (){
    int startCount;
    int totalCount;
    NSOperationQueue *operationQueue;

}

@end

@implementation SeequSearchResultsViewController

@synthesize searchText;
@synthesize videoViewState;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        startCount = 1;
        totalCount =  0;
    }
    return self;
}


-(void) startSearch {
    [activityIndicatorView startAnimating];
    self.MyTableView.scrollEnabled = NO;

    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(DownloadSeequContactsOperation:) object:nil];
    [operationQueue addOperation:operation];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    if(IS_IOS_7){
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.MyTableView.sectionIndexBackgroundColor=[UIColor clearColor];
    }
    
    // Do any additional setup after loading the view from its nib.
    operationQueue = [[NSOperationQueue alloc] init];
    isOnSearchThread = NO;
    self.MyTableView.tableHeaderView = self.viewHeader;
    arraySearchResults = [[NSMutableArray alloc] init];
    sectionsArray = [[NSMutableArray alloc] init];
    
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.hidesWhenStopped = YES;
    
    if (self.searchText) {
        self.textFieldSearch.text = self.searchText;
        [activityIndicatorView startAnimating];
        [self startSearch];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewChange:)
                                                 name:kVideoViewChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewOrientationChange:)
                                                 name:kVideoViewOrientationChangeNotification
                                               object:nil];
    // For textField1
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(SearchTextFieldChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.textFieldSearch];
    
    [self.textFieldSearch becomeFirstResponder];
    if (refreshFooterView == nil) {
        refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:CGRectMake(0.0f, [self tableViewHeight], 320.0f, 600.0f)];
		refreshFooterView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
		[self.MyTableView addSubview:refreshFooterView];
        refreshFooterView.hidden = [self.MyTableView contentSize].height < self.MyTableView.frame.size.height;
		self.MyTableView.showsVerticalScrollIndicator = YES;
    }

}

-(void) updateFooterView{
    if(([self.MyTableView contentSize].height < self.MyTableView.frame.size.height) ||startCount >= totalCount){
        refreshFooterView.hidden = YES;
    } else {
        refreshFooterView.hidden = NO;
    }
     refreshFooterView.frame = CGRectMake(0.0f, [self tableViewHeight], 320.0f, 600.0f);
    NSLog(@"%@", NSStringFromCGRect(refreshFooterView.frame));
}

- (float)tableViewHeight {
    // return height of table view
    return [self.MyTableView contentSize].height;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    
	((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleSearchResults.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack:)];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
    rightBarButton.enabled = NO;

    BackBarButton *addBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"SeequInviteButton.png"]
                                                  style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(onButtonAdd:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addBarButton, rightBarButton,  nil];
    
   
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
            frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
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
        [UIView beginAnimations:@"scrollFrame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3];
        self.MyTableView.frame = frame;
        [UIView commitAnimations];
    }
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) DownloadSeequContactsOperation:(id)object {
    NSInvocationOperation* operation = (NSInvocationOperation*)object;
    NSString* text = self.textFieldSearch.text;
    NSMutableArray *array;
    NSNumber* totalNumber;
    @synchronized(self){

    //    NSString *error_description = [Common SearchContactsWithText:text ReturnedArray:&array];
        if (operation.isCancelled) {
            return;
        }
        NSString *error_description = [Common SearchContactsWithText:text ReturnedArray:&array start:startCount limit:SEARCH_STEP_COUNT total:&totalNumber];
        if (operation.isCancelled) {
            return;
        }
        
        if (totalCount >= 0 && [totalNumber intValue] > startCount) {
            startCount += SEARCH_STEP_COUNT;
            totalCount = [totalNumber intValue];
        } else {
            totalCount = -1;
        }
        
        [self performSelectorOnMainThread:@selector(StopActivityIndicatorView)
                               withObject:nil
                            waitUntilDone:YES];

        if (error_description) {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                [self performSelectorOnMainThread:@selector(ShowAlertWithMessage:)
                                       withObject:error_description
                                    waitUntilDone:NO];
            }
            
            isOnSearchThread = NO;
            
            return;
        }
        [arraySearchResults addObjectsFromArray:array];
        
        if (self.view.superview) {
            if (arraySearchResults) {
                UINavigationController *ctrl = [self.tabBarController.viewControllers objectAtIndex:0];
                SeequContactsViewController *contactsViewController = [ctrl.viewControllers objectAtIndex:0];
                
                for (int index = 0; index < [arraySearchResults count]; index++) {
                    ContactObject *obj = [arraySearchResults objectAtIndex:index];
                    
                    ContactObject *obj_ = [contactsViewController CheckObjectInArrayWithPT:obj.SeequID];
                    if (obj_) {
                        obj.isOnline = obj_.isOnline;
                        obj.contactType = obj_.contactType;
                        obj.image = obj_.image;
                    }
                }
                
                [self configureSectionsWithArray:arraySearchResults];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.MyTableView reloadData];
                    
                    [self updateFooterView];
                });
                
                for (int index = 0; index < [arraySearchResults count]; index++) {
                    ContactObject *obj = [arraySearchResults objectAtIndex:index];
                    if (obj.imageExist && !obj.image) {
                        obj.delegate = self;
                        [NSThread detachNewThreadSelector:@selector(StartGetingImage)
                                                 toTarget:obj
                                               withObject:nil];
                    }
                }
            } else {
                [self performSelectorOnMainThread:@selector(ShowAlertWithMessage:)
                                       withObject:@"No matches found."
                                    waitUntilDone:NO];
            }
        }
    }
    
    isOnSearchThread = NO;
}

- (void) StopActivityIndicatorView {
    [activityIndicatorView stopAnimating];
    self.MyTableView.scrollEnabled = YES;
}

- (void) ShowAlertWithMessage:(NSString*)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark ContactObject Delegate

- (void) didGetUserInfo:(ContactObject*)contactsObj withDict:(NSDictionary*)dict {
    @synchronized (self) {
        NSIndexPath *indexPath = [self FindIndexPathWithPT:contactsObj.SeequID];
        if (indexPath) {
            ContactCell *cell = (ContactCell*)[self.MyTableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                if (contactsObj.image) {
                    cell.imageView.image = contactsObj.image;

                    [self.MyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                }
            }
        }
    }
}

- (void) didGetUserImage:(ContactObject*)contactsObj Image:(UIImage*)image {
    @synchronized (self) {
        NSIndexPath *indexPath = [self FindIndexPathWithPT:contactsObj.SeequID];
        if (indexPath) {
            ContactCell *cell = (ContactCell*)[self.MyTableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                if (contactsObj.image) {
                    cell.imageView.image = contactsObj.image;
                    
                    [self.MyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                }
            }
        }
    }
}

- (NSIndexPath*) FindIndexPathWithPT:(NSString*)seequID {
    NSInteger section = 0;
    
    for (NSArray *array in sectionsArray) {
        NSInteger row = 0;
        for (ContactObject *obj in array) {
            if ([obj.SeequID isEqualToString:seequID]) {
                return [NSIndexPath indexPathForRow:row inSection:section];
            }
            row++;
        }
        section++;
    }
    
    return nil;
}

- (NSMutableArray*) ArrayWithSearchText:(NSString*)text {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
//    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
//    
//    if (text && [text length]) {
//        for (ContactObject *obj in arraySearchResults) {
//            NSComparisonResult result = [obj.FirstName compare:text options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [text length])];
//            if (result == NSOrderedSame) {
//                [array addObject:obj];
//            } else {
//                NSComparisonResult result = [obj.LastName compare:text options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [text length])];
//                if (result == NSOrderedSame) {
//                    [array addObject:obj];
//                }
//            }
//        }
//    }
    
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (text && [text length]) {
        for (ContactObject *obj in arraySearchResults) {
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

- (void)configureSectionsWithArray:(NSMutableArray*)array {
	// Get the current collation and keep a reference to it.
	UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
	
	NSInteger index, sectionTitlesCount = [[collation sectionTitles] count];
	
	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
	
	for (index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[newSectionsArray addObject:array];
        //		[array release];
	}
	
	for (ContactObject *obj in array) {
        if (!obj.isNameSeted) {
            continue;
        }
		NSInteger sectionNumber = [collation sectionForObject:obj collationStringSelector:@selector(displayName)];
		
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
		NSArray *sortedTimeZonesArrayForSection = [collation sortedArrayFromArray:timeZonesArrayForSection collationStringSelector:@selector(displayName)];
		
		// Replace the existing array with the sorted array.
		[newSectionsArray replaceObjectAtIndex:index withObject:sortedTimeZonesArrayForSection];
	}
	
	sectionsArray = newSectionsArray;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionCount = [sectionsArray count];
    
    return sectionCount;
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
    
    static NSString *CellIdentifier = @"ContactSearchCell";
    
    ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Set up the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //First get the dictionary object
    NSMutableArray *array = [sectionsArray objectAtIndex:indexPath.section];
    ContactObject *obj = [array objectAtIndex:indexPath.row];
    
    [cell setContactObject:obj];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.textFieldSearch resignFirstResponder];
    NSMutableArray *array = [sectionsArray objectAtIndex:indexPath.section];
    ContactObject *obj = [array objectAtIndex:indexPath.row];
        if ([[ContactStorage sharedInstance] IsUserAvailable:obj.SeequID]) {
              obj=[[ContactStorage sharedInstance] GetContactObjectBySeequId:obj.SeequID];
        }
    SeequContactProfileViewController *profileViewController = [[SeequContactProfileViewController alloc] initWithNibName:@"SeequContactProfileViewController" bundle:nil];
    profileViewController.contactObj = obj;
    profileViewController.videoViewState = self.videoViewState;
    profileViewController.accessToConnections = NO;
    [self.navigationController pushViewController:profileViewController animated:YES];
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    return [collation sectionTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {  // tell table which section corresponds to section title/index (e.g. "B",1))
    return [self IndexForTitle:title];
}

- (NSInteger) IndexForTitle:(NSString*)text {
    NSInteger index = 0;
    for (NSMutableArray *array in sectionsArray) {
        ContactObject *obj = [array objectAtIndex:0];
        
        if ([[[obj.LastName substringToIndex:1] uppercaseString] isEqualToString:text]) {
            return index;
        }
        
        index++;
    }
    
    return -1;
}

- (IBAction)onButtonstartSearch:(id)sender {
    [self textFieldShouldReturn:self.textFieldSearch];
}

- (IBAction) onButtonAdd:(id)sender {
    SeequInviteViewController *inviteViewController = [[SeequInviteViewController alloc] initWithNibName:@"SeequInviteViewController" bundle:nil];
    inviteViewController.videoViewState = videoViewState;
    [self.navigationController pushViewController:inviteViewController animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.textFieldSearch resignFirstResponder];
    [self updateFooterView];

    if (scrollView.isDragging) {
        float endOfTable = [self endOfTableView:scrollView];
        if (refreshFooterView.state == EGOOPullRefreshPulling && endOfTable < 0.0f && endOfTable > -65.0f && !_reloading) {
			[refreshFooterView setState:EGOOPullRefreshNormal];
		} else if (refreshFooterView.state == EGOOPullRefreshNormal && endOfTable < -65.0f && !_reloading) {
			[refreshFooterView setState:EGOOPullRefreshPulling];
		}
	}

}

#pragma mark -
#pragma mark UITextField Delegate Methods
#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (isOnSearchThread) {
        return YES;
    }
    
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        if (textField.text && textField.text.length) {
            isOnSearchThread = YES;
            [operationQueue cancelAllOperations];
            [arraySearchResults removeAllObjects];
            [self configureSectionsWithArray:arraySearchResults];
            [self.MyTableView reloadData];
            [activityIndicatorView stopAnimating];
            totalCount = 0;
            startCount = 1;
            [self startSearch];
        }
        
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void) SearchTextFieldChange {
    [operationQueue cancelAllOperations];
    [arraySearchResults removeAllObjects];
    [self configureSectionsWithArray:arraySearchResults];
    [self.MyTableView reloadData];
    [activityIndicatorView stopAnimating];

    if (self.textFieldSearch.text.length>0) {
        totalCount = 0;
        startCount = 1;
            [self startSearch];
    } 
//    if (self.textFieldSearch.text && [self.textFieldSearch.text length]) {
//        NSMutableArray *array = [self ArrayWithSearchText:self.textFieldSearch.text];
//        [self configureSectionsWithArray:array];
//    } else {
//        [self configureSectionsWithArray:arraySearchResults];
//    }
//    
//    [self.MyTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
}

- (void)viewDidUnload {
    [self setTextFieldSearch:nil];
    [self setMyTableView:nil];
    [self setViewHeader:nil];
    
    [super viewDidUnload];
}

- (void) dealloc {
    for (ContactObject *obj in arraySearchResults) {
        obj.delegate = nil;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL) checkForFetchAbility {
    if (totalCount <0 ||startCount >= totalCount) {
        return NO;
    } else {
        return YES;
    }
    
}

///////////////////////////////////////

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    
    if ([self endOfTableView:scrollView] <= -65.0f && !_reloading && [self checkForFetchAbility]) {
        _reloading =  [self.MyTableView contentSize].height > self.MyTableView.frame.size.height;
        [refreshFooterView setState:EGOOPullRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        self.MyTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
        [UIView commitAnimations];
        [self startSearch];
        [self reloadTableViewDataSource];
      
	}
}

- (void)dataSourceDidFinishLoadingNewData{
	
	_reloading = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.MyTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
    
    if ([refreshFooterView state] != EGOOPullRefreshNormal) {
        [refreshFooterView setState:EGOOPullRefreshNormal];
        [refreshFooterView setCurrentDate];  //  should check if data reload was successful
    }
}

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	[self dataSourceDidFinishLoadingNewData];
}


- (void)repositionRefreshHeaderView {
    refreshFooterView.center = CGPointMake(160.0f, [self tableViewHeight] + 300.0f);
}

- (float)endOfTableView:(UIScrollView *)scrollView {
    return [self tableViewHeight] - scrollView.bounds.size.height - scrollView.bounds.origin.y;
}

- (void)reloadTableViewDataSource{
	//  should be calling your tableviews model to reload
	//  put here just for demo
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


@end
