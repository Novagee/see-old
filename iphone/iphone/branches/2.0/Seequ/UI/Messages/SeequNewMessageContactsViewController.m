//
//  SeequNewMessageContactsViewController.m
//  ProTime
//
//  Created by Norayr on 06/07/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import "SeequNewMessageContactsViewController.h"
#import "SeequContactsViewController.h"
#import "idoubs2AppDelegate.h"
#import "ContactCell.h"
#import "BookmarkUIActivity.h"

@interface SeequNewMessageContactsViewController ()

@end

@implementation SeequNewMessageContactsViewController
@synthesize isFromForwardCalled;

@synthesize seequContactsDelegate = _delegate;
@synthesize videoViewState;
@synthesize fetchedController=_fetchedController;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallStateChange:) name:kCallStateChange object:nil];
        isFromForwardCalled = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(IS_IOS_7){
        self.edgesForExtendedLayout=UIRectEdgeAll;
         self.MyTableView.sectionIndexBackgroundColor=[UIColor clearColor];
           }
    // Do any additional setup after loading the view from its nib.
//    if ([[UIScreen mainScreen] bounds].size.height == 568) {
//        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"seequMessagesBG-568@2x.png"]]];
//    } else {
//        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"seequMessagesBG.png"]]];
//    }
    BOOL flag = !isFromForwardCalled &&[[idoubs2AppDelegate sharedInstance].videoService isInCall];
    SearchBar = [[SearchBarWithCallButton alloc] initWithFrame:CGRectMake(0, 0, 320, 44) ShowCallButton:flag];
    SearchBar.delegate = self;
    
    self.MyTableView.tableHeaderView = SearchBar;
        _fetchedController=[self getFetchedResultsController];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setVideoViewState:self.videoViewState Animated:YES];
    
    
    if ([[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
        [SearchBar setCallButtonType:CallButtonType_Video];
    } else {
        [SearchBar setCallButtonType:CallButtonType_Audio];
    }
        [self.navigationController setToolbarHidden:YES];
}

- (void) onVideoViewChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    self.videoViewState = (VideoViewState)[eargs intValue];
    
    [self setVideoViewState:self.videoViewState Animated:YES];
}

- (void) setVideoViewState:(int)state Animated:(BOOL)animated {
    if (![[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
        state = VideoViewState_HIDE;
        videoViewState = state;
    }
    
    switch (state) {
        case VideoViewState_NONE:
        case VideoViewState_NORMAL:
        case VideoViewState_NORMAL_MENU: {
        }
            break;
        case VideoViewState_TAB:
        case VideoViewState_TAB_MENU: {
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && [[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
                //[SearchBar setLength:([[UIScreen mainScreen] bounds].size.height - SMALL_VIDEO_HEIGHT*2) ShowCallButton:YES];
                SearchBar.isCallVisible = YES;
            }
        }
            break;
        case VideoViewState_HIDE:
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && [[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
                 
               // [SearchBar setLength:[[UIScreen mainScreen] bounds].size.height ShowCallButton:!isFromForwardCalled];
                SearchBar.isCallVisible = !isFromForwardCalled;
                
            } else {
               // [SearchBar setLength:[[UIScreen mainScreen] bounds].size.width ShowCallButton:NO];
                SearchBar.isCallVisible = NO;
            }
        default:
            break;
    }
    
    [self UpdateInterfaceOrientation:self.interfaceOrientation];
    
    [self.MyTableView reloadData];
}

- (void) onCallStateChange:(NSNotification*)notification {
    tabBar_Type type = (tabBar_Type)[[notification object] integerValue];
    
    switch (type) {
        case tabBar_Type_Default: {
        }
            break;
        case tabBar_Type_Landscape: {
        }
            break;
        case tabBar_Type_Audio:
        case tabBar_Type_Audio_Selected: {
            [SearchBar setCallButtonType:CallButtonType_Audio];
        }
            break;
        case tabBar_Type_Video:
        case tabBar_Type_Video_Selected: {
            [SearchBar setCallButtonType:CallButtonType_Video];
        }
            break;
        case tabBar_Type_OnHold: {
            [SearchBar setCallButtonType:CallButtonType_Hold];
        }
            break;
        default:
            break;
    }
}

- (IBAction)onButtonCancel:(id)sender {
    if ([_delegate respondsToSelector:@selector(didFinishSeequAddBookmarkViewController:)]) {
        [_delegate performSelector:@selector(didFinishSeequAddBookmarkViewController:) withObject:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:NO];
    }

 
}

- (void) didClickOnCallButton:(SearchBarWithCallButton*)searchBar {
    if ([[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView setVideoState:VideoViewState_TAB_MENU Animation:YES];
    } else {
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView setVideoState:VideoViewState_NORMAL Animation:YES];
    }
}
#pragma NSFetchedResultsController delegate

- (NSFetchedResultsController *)getFetchedResultsController
{
//	if (_fetchedController == nil) {
//		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//		NSManagedObjectContext* mContext = [CoreDataManager managedObjectContext];
//		NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([UserInfoCoreData class])
//                                                          inManagedObjectContext:mContext];
//		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:@selector(caseInsensitiveCompare:)];
//                NSPredicate *predicate=[NSPredicate predicateWithFormat:@"status.subscription=%@",@"both"];
//      		NSArray *sortDescriptors = @[sd1];
//                
//		[fetchRequest setEntity:entity];
//                [fetchRequest setPredicate:predicate];
//		[fetchRequest setSortDescriptors:sortDescriptors];
//		[fetchRequest setFetchBatchSize:10];
//                
//		NSError *error = nil;
//                _fetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
//                                                                         managedObjectContext:mContext
//                                                                           sectionNameKeyPath:@"firstName.stringGroupByFirstInitial"
//                                                                                    cacheName:nil];
//		[_fetchedController setDelegate:self];
//                
//		
//		if (![_fetchedController performFetch:&error])
//		{
//			NSLog(@"Error performing fetch: %@", error);
//		}
//	}
//	
//	return _fetchedController;
    if (_fetchedController == nil) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSManagedObjectContext* mContext = [CoreDataManager managedObjectContextForMainThread];
		NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([UserInfoCoreData class])
												  inManagedObjectContext:mContext];
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        //		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        //            NSString* str1 = (NSString*)obj1;
        //
        //            str1 = [str1 stringGroupByFirstInitial];
        //            NSString* str2 = (NSString*)obj2;
        //            str2 = [str2 stringGroupByFirstInitial];
        //            if (![str1 isEqualToString:@"#"] && ![str2 isEqualToString:@"#"]) {
        //                return [((NSString*)obj1) caseInsensitiveCompare:((NSString*)obj2)];
        //            } else if (![str1 isEqualToString:@"#"]) {
        //                return NSOrderedAscending;
        //            } else if (![str2 isEqualToString:@"#"]) {
        //                return NSOrderedDescending;
        //            } else {
        //                return NSOrderedSame;
        //            }
        //
        //        }];
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"firstName.length >0 && status.subscription=%@",@"both"];
        NSArray *sortDescriptors = @[sd1];
        
		[fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
        
		NSError *error = nil;
        _fetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:mContext
                                                                          sectionNameKeyPath:@"firstName.stringGroupByFirstInitial"
                                                                                   cacheName:nil];
		[_fetchedController setDelegate:self];
        
		
		if (![_fetchedController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
	}
	
	return _fetchedController;

}
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
        [self performSelectorOnMainThread:@selector(reloadTabel) withObject:nil waitUntilDone:NO];
}
-(void)reloadTabel{
        [self.MyTableView reloadData];
}
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        return [_fetchedController.sections count ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        id<NSFetchedResultsSectionInfo>sectionInfo=[_fetchedController.sections objectAtIndex:section];
        return sectionInfo.numberOfObjects;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        return [[_fetchedController sectionIndexTitles] objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    //    ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //    if (cell == nil) {
    ContactCell *cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //    }
    
    // Set up the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;
        UserInfoCoreData *userInfo=[_fetchedController objectAtIndexPath:indexPath];
        
        ContactObject *obj=[[ContactStorage sharedInstance] GetContactObjectBySeequId:userInfo.seeQuId];
        //First get the dictionary object
//    if (sectionsArray.count > indexPath.section) {
//        NSMutableArray *array = [sectionsArray objectAtIndex:indexPath.section];
//        if (array.count > indexPath.row) {
//            ContactObject *obj = [array objectAtIndex:indexPath.row];
        
            [cell setContactObject:obj];
            
//            if ([[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState] && (self.videoViewState == VideoViewState_TAB || self.videoViewState == VideoViewState_TAB_MENU)) {
//                [cell setInterfaceOrientation:self.interfaceOrientation Video:YES];
//            } else {
//                [cell setInterfaceOrientation:self.interfaceOrientation Video:NO];
//            }
//        } else {
//            NSLog(@"if (array.count > indexPath.row) {");
//        }
//    } else {
//        NSLog(@"if (sectionsArray.count > indexPath.section) {");
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        UserInfoCoreData *userInfo=[_fetchedController objectAtIndexPath:indexPath];
    ContactObject *contactObject = [[ContactStorage sharedInstance] GetContactObjectBySeequId:userInfo.seeQuId];
    if (contactObject.contactType != Contact_Type_NON) {
        if (contactObject.contactType != Contact_Type_Address_Book) {
            if ([_delegate respondsToSelector:@selector(didSelectContact:Contact:)]) {
                
               [_delegate didSelectContact:self Contact:contactObject];
            }
        }
    }
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }
}

//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {  // tell table which section corresponds to section title/index (e.g. "B",1))
//    
//    return [self IndexForTitle:title];
//}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(IS_IOS_7){
        //UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
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

//- (NSInteger) IndexForTitle:(NSString*)text {
//    @synchronized(sectionsArray) {
//        NSInteger index = 0;
//        for (NSMutableArray *array in sectionsArray) {
//            ContactObject *obj = [array objectAtIndex:0];
//            
//            NSString *compositeName = [obj CompositeName];
//            if (compositeName && [compositeName isKindOfClass:[NSString class]] && compositeName.length && [[[compositeName substringToIndex:1] uppercaseString] isEqualToString:text]) {
//                return index;
//            }
//            
//            index++;
//        }
//    }
//    
//    return -1;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [SearchBar hideKeyboard];
}

//- (NSMutableArray*)configureSectionsWithArray:(NSMutableArray*)array {
//	// Get the current collation and keep a reference to it.
//	UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
//	
//	NSInteger index, sectionTitlesCount = [[collation sectionTitles] count];
//	
//	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
//	
//	for (index = 0; index < sectionTitlesCount; index++) {
//		NSMutableArray *array = [[NSMutableArray alloc] init];
//		[newSectionsArray addObject:array];
//	}
//	
//	for (ContactObject *obj in array) {
//        if (!obj.isNameSeted || obj.contactType == Contact_Type_Request_Connection) {
//            continue;
//        }
//        
//        NSInteger sectionNumber;
//        
//        sectionNumber = [collation sectionForObject:obj collationStringSelector:@selector(displayName)];
//		
//		// Get the array for the section.
//		NSMutableArray *sectionTimeZones = [newSectionsArray objectAtIndex:sectionNumber];
//		
//		//  Add the Person to the section.
//		[sectionTimeZones addObject:obj];
//	}
//	
//	index = 0;
//	
//	while (index < [newSectionsArray count]) {
//		NSMutableArray *marray = [newSectionsArray objectAtIndex:index];
//		if (![marray count]) {
//			[newSectionsArray removeObject:marray];
//		} else {
//			index++;
//		}
//	}
//	
//	// Now that all the data's in place, each section array needs to be sorted.
//	for (index = 0; index < [newSectionsArray count]; index++) {
//		
//		NSMutableArray *timeZonesArrayForSection = [newSectionsArray objectAtIndex:index];
//		
//		// If the table view or its contents were editable, you would make a mutable copy here.
//		NSArray *sortedTimeZonesArrayForSection;
//		
//        sortedTimeZonesArrayForSection = [collation sortedArrayFromArray:timeZonesArrayForSection collationStringSelector:@selector(displayName)];
//        
//		// Replace the existing array with the sorted array.
//		[newSectionsArray replaceObjectAtIndex:index withObject:sortedTimeZonesArrayForSection];
//	}
//	
//    return newSectionsArray;
//}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    NSArray *arrayCells = [self.MyTableView visibleCells];
    
    for (ContactCell *cell in arrayCells) {
        if ([[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState] && (self.videoViewState == VideoViewState_TAB || self.videoViewState == VideoViewState_TAB_MENU)) {
            [cell setInterfaceOrientation:toInterfaceOrientation Video:YES];
        } else {
            [cell setInterfaceOrientation:toInterfaceOrientation Video:NO];
        }
    }
    
 }

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIInterfaceOrientation or = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(or)) {
        if ([[idoubs2AppDelegate sharedInstance].videoService isInCall] && (videoViewState != VideoViewState_HIDE &&videoViewState != VideoViewState_PREVIEW) && [[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
            BOOL flag = [[idoubs2AppDelegate sharedInstance].videoService isInCall] && !isFromForwardCalled;
            if (flag) {
              //  [SearchBar setLength:([[UIScreen mainScreen] bounds].size.height - SMALL_VIDEO_HEIGHT*2) ShowCallButton:flag];
            } else {
              //  [SearchBar setLength:[[UIScreen mainScreen] bounds].size.height ShowCallButton:flag];
            }
            SearchBar.isCallVisible = flag;

        
        } else {
            BOOL flag = [[idoubs2AppDelegate sharedInstance].videoService isInCall] && !isFromForwardCalled;
           // [SearchBar setLength:[[UIScreen mainScreen] bounds].size.height ShowCallButton:flag];
            SearchBar.isCallVisible = flag;

        }
    } else {
        ///@note  levon  old implementation with  call  button  in portrait mode ...  need  to review  and make  proper decision
        /**
         [SearchBar setLength:[[UIScreen mainScreen] bounds].size.width ShowCallButton:[[idoubs2AppDelegate sharedInstance].videoService isInCall]];
         
         */
     //   [SearchBar setLength:[[UIScreen mainScreen] bounds].size.width ShowCallButton:NO];
        SearchBar.isCallVisible = NO;

    }

}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if ([_delegate isKindOfClass:[BookmarkUIActivity class]]) {
        return;
    }
    [self UpdateInterfaceOrientation:self.interfaceOrientation];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        if ([_delegate performSelector:@selector(setHidesBottomBarWhenPushed:)]) {
        //    [(UIViewController*)_delegate setHidesBottomBarWhenPushed:YES];
        }
    
    } else {
        if ([_delegate performSelector:@selector(setHidesBottomBarWhenPushed:)]) {
        //    [(UIViewController*)_delegate setHidesBottomBarWhenPushed:NO];
        }

    }
    
    if ([_delegate respondsToSelector:@selector(didRotateInterfaceOrientation:)]) {
        [_delegate didRotateInterfaceOrientation:self.interfaceOrientation];
    }
}

- (void) UpdateInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        //int status_bar_height = [[UIApplication sharedApplication] statusBarFrame].size.height;
        int status_bar_height = 20;
        if (self.view.frame.size.height == 460 || self.view.frame.size.height == 548) {
            status_bar_height = 0;
        }
 
        self.imageViewNavigationBar.frame = CGRectMake(0, status_bar_height, [[UIScreen mainScreen] bounds].size.width, 44);
        self.MyTableView.frame = CGRectMake(0, status_bar_height + 44, [[UIScreen mainScreen] bounds].size.width, self.view.frame.size.height - 44 - status_bar_height);
        
        if (self.videoViewState == VideoViewState_TAB) {
            self.MyTableView.frame = CGRectMake(0, 44 + 116 + status_bar_height - 20, [[UIScreen mainScreen] bounds].size.width, self.view.frame.size.height - 44 - 116 - status_bar_height + 20);
            
           
        } else {
            if (self.videoViewState == VideoViewState_TAB_MENU) {
                 self.MyTableView.frame = CGRectMake(0, 44 + 116 + 92 + status_bar_height - 20, [[UIScreen mainScreen] bounds].size.width, self.view.frame.size.height - 44 - 116 - 92 - status_bar_height + 20);
                
            }
        }
        ///@note  levon   hides  the  call button  as requested  in  SeequSEEQU-613  
     //   [SearchBar setLength:SearchBar.frame.size.width ShowCallButton:[[idoubs2AppDelegate sharedInstance].videoService isInCall]];
       // [SearchBar setLength:SearchBar.frame.size.width ShowCallButton:NO];
        SearchBar.isCallVisible = NO;

    } else {
        
        switch (self.videoViewState) {
            case VideoViewState_HIDE:
            case VideoViewState_NORMAL:
            case VideoViewState_NORMAL_MENU:
            case VideoViewState_NONE: {
                int status_bar_height = 0;
                if(IS_IOS_7)
                     status_bar_height = 20;
                    self.imageViewNavigationBar.frame = CGRectMake(0,status_bar_height, [[UIScreen mainScreen] bounds].size.height, 44);
                self.MyTableView.frame = CGRectMake(0, 44 + status_bar_height, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - 44 -status_bar_height);
            }
                break;
            default: {
                self.imageViewNavigationBar.frame = CGRectMake(SMALL_VIDEO_HEIGHT, 0, [[UIScreen mainScreen] bounds].size.height - SMALL_VIDEO_HEIGHT*2, 44);
                self.MyTableView.frame = CGRectMake(SMALL_VIDEO_HEIGHT, 44, [[UIScreen mainScreen] bounds].size.height - SMALL_VIDEO_HEIGHT*2, [[UIScreen mainScreen] bounds].size.width - 44);
            }
                break;
        }
    }
    
    self.labelMySeequ.center = CGPointMake(self.imageViewNavigationBar.frame.origin.x + self.imageViewNavigationBar.frame.size.width/2, self.imageViewNavigationBar.frame.origin.y + self.imageViewNavigationBar.frame.size.height/2);
    self.buttonCancel.center = CGPointMake(self.imageViewNavigationBar.frame.origin.x + self.imageViewNavigationBar.frame.size.width - self.buttonCancel.frame.size.width/2 - 7, self.imageViewNavigationBar.frame.origin.y + self.imageViewNavigationBar.frame.size.height/2);
}

#pragma mark -
#pragma mark SearchBarWithCallButton Delegate Methods
#pragma mark -

- (void) didChangeSearchText:(SearchBarWithCallButton*)searchBar SearchText:(NSString*)text {
        NSError *error;
        NSPredicate *predicate;

        if (text && [text length]) {
                predicate =[NSPredicate predicateWithFormat:@"status.subscription=%@ && %@ IN firstName",@"both",text];
        } else {
                predicate =[NSPredicate predicateWithFormat:@"status.subscription=%@ ",@"both"];
                }
        [_fetchedController.fetchRequest setPredicate:predicate];
        [_fetchedController performFetch:&error];
        if (error) {
                NSLog(@"Error- %@",[error description]);
        }
        [self.MyTableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
        NSError *error;
        NSPredicate *predicate;
        
    if (searchText && [searchText length]) {
        predicate =[NSPredicate predicateWithFormat:@"status.subscription=%@ && %@ IN firstName",@"both",searchText];
    } else {
        predicate =[NSPredicate predicateWithFormat:@"status.subscription=%@ ",@"both"];
    }
        [_fetchedController.fetchRequest setPredicate:predicate];
        [_fetchedController performFetch:&error];
        if (error) {
                NSLog(@"Error- %@",[error description]);
        }
    [self.MyTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
}

//- (NSMutableArray*) ArrayWithSearchText:(NSString*)text {
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    
//    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
//    
//    if (text && [text length]) {
//        for (ContactObject *obj in arrayContacts) {
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
//    
//    return array;
//}
- (void)viewWillLayoutSubviews{
    
    if ([[UIScreen mainScreen] bounds].size.height == 568) {
        [self.backgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"seequMessagesBG-568@2x.png"]]];
    } else {
        [self.backgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"seequMessagesBG.png"]]];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageViewNavigationBar:nil];
    [self setLabelMySeequ:nil];
    [self setButtonCancel:nil];
    [super viewDidUnload];
}
@end
