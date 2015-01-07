//
//  SeequContactsViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 9/26/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//
#import "SeequAddFavoriteViewController.h"
#import "SeequContactsViewController.h"
#import "SeequContactProfileViewController.h"
#import "SeequPhoneContactInviteViewController.h"
#import "SeequSearchResultsViewController.h"
#import "SeequInviteViewController.h"
#import "MyProfileViewController.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"
#import "NavigationBar.h"
#import "ContactCell.h"
#import "Common.h"
#import "ContactStorage.h"
#import "CoreDataManager.h"
#import "UserInfoCoreData.h"
#import "NSString+DEFetchedGroupByString-1.h"
#define actionSheetButtonTitleSMS @"SMS"
#define actionSheetButtonTitleEmail @"Email"

@interface SeequContactsViewController ()

@end

@implementation SeequContactsViewController
@synthesize fetchedResultsController=_fetchedResultsController;
static void AddressBookExternalChangeCallback (ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
	SeequContactsViewController *self_ = (__bridge SeequContactsViewController*)context;
    [NSThread detachNewThreadSelector:@selector(LoadAddressBook) toTarget:self_ withObject:nil];
}
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isForGroup = NO;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIDevice *device = [UIDevice currentDevice];
    char System_Versio[256];
    int d_sv;
    int d_ssv;
    
    strcpy(System_Versio, [[device systemVersion] UTF8String]);
    sscanf(System_Versio, "%d.%d.%d", &device_version, &d_sv, &d_ssv);

//    [self LoadAddressBook];
//    if (addressBook) {
//        ABAddressBookRegisterExternalChangeCallback(addressBook, AddressBookExternalChangeCallback, (__bridge_retained  void *)self);
//    }

    arrayContacts = [[NSMutableArray alloc] init];
    arrayFavorites = [[NSMutableArray alloc] init];
    sectionsArray = [[NSMutableArray alloc] init];
    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autologin"]) {
//        [self onContactListUpdate:nil];
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewOrientationChange:) name:kVideoViewOrientationChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSelectContact:) name:kSelectContactNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectUpdate:) name:@"ContactObjectProfileDataUpdate" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactListUpdate:) name:kContactListNotification object:nil];
    
    
//    [NSThread detachNewThreadSelector:@selector(ReloadTableViewData) toTarget:self withObject:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.MySearchBar.tintColor = [UIColor colorWithWhite:0.3 alpha:1.0];
          searchBarButton = [[BackBarButton alloc] initWithImage:[UIImage  imageNamed:@"defaultSeequAddButton.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(onButtonSearch:)];
    
    self.navigationItem.leftBarButtonItem = searchBarButton;
    
    settingsBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"seequButtonSettings.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(onButtonSettings:)];
    [self.MyTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    [self.MyTableView setSectionIndexTrackingBackgroundColor:[UIColor whiteColor]];
    [self.MyTableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    
      _fetchedResultsController = [self getFetchedResultsController];
        
    self.navigationItem.rightBarButtonItem = settingsBarButton;
    self.searchDisplayController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [self onButtonFilter:self.buttonMySeequ];
    videoViewState = VideoViewState_NONE;
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

//     if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autologin"]) {
//        [NSThread detachNewThreadSelector:@selector(SendContactUpdateRequest) toTarget:self withObject:nil];
//    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
        [_fetchedResultsController setDelegate:self];
    
    if(!_isForGroup) {
        ((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
        ((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleContacts.png"];
        [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    }
        
        [self updatePredicate];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setVideoViewState:videoViewState Animated:NO];
      
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
        _fetchedResultsController.fetchRequest.predicate=nil;

}

- (void) onVideoViewChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    videoViewState = (VideoViewState)[eargs intValue];
}

- (void) onVideoViewOrientationChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    Video_InterfaceOrientation = (UIInterfaceOrientation)[eargs intValue];
    
    [self setVideoViewState:videoViewState Animated:YES];
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
    
    int statusBarHeight = 0;
    //NSLog(@"self.view.frame.size.height: %.0f", self.view.frame.size.height);
    if (self.view.frame.size.height == 386 || self.view.frame.size.height == 387 || self.view.frame.size.height == 474 || self.view.frame.size.height == 475) {
        statusBarHeight = 20;
    }
    
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
            frame = CGRectMake(0, 33, 320, 333 + diff + statusBarHeight);
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
            [UIView beginAnimations:@"TableFrame" context:nil];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.3];
        }
        self.MyTableView.frame = frame;
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (void) onSelectContact:(NSNotification*)notification {
    ContactObject* contact = [notification object];

    if (contact) {
        if ([self.navigationController.viewControllers count] == 2) {
            SeequContactProfileViewController *profileViewController = [self.navigationController.viewControllers objectAtIndex:1];
            if ([profileViewController.contactObj.SeequID isEqualToString:contact.SeequID]) {
                [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 0;
                
                return;
            }
        }
        
        [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 0;
        [self.navigationController popToRootViewControllerAnimated:NO];
        SeequContactProfileViewController *profileViewController = [[SeequContactProfileViewController alloc] initWithNibName:@"SeequContactProfileViewController" bundle:nil];
        profileViewController.contactObj = contact;
        profileViewController.videoViewState = videoViewState;
        profileViewController.accessToConnections = YES;
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

//- (void) onContactListUpdate:(NSNotification*)notification {
//    NSArray *array = [Common GetSavedContactList];
//    
//    for (NSDictionary *dict in array) {
//        if (dict) {
//            NSString *seequID = [dict objectForKey:@"seeQuId"];
//            ContactObject *contactObj = [[ContactObject alloc] initWithSeequID:seequID];
//            contactObj.contactType = Contact_Type_MY_Seequ_Contact;
//            [contactObj SetUserInfoWithDictionary:dict];
//            
//            [arrayContacts addObject:contactObj];
//            [Common AddContactObjectToCommonArray:contactObj];
//        }
//    }

//    [self.MyTableView reloadData];
    
//    [NSThread detachNewThreadSelector:@selector(ContactObjectWithDictionary:) toTarget:self withObject:array];
//}

//- (void) ContactObjectWithDictionary:(NSArray*)array {
//    @autoreleasepool {
//        for (int i = 0; i < arrayContacts.count; i++) {
//            ContactObject *contactObj = [arrayContacts objectAtIndex:i];
//            NSData *imageData;
//            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2) {
//                //Retina display
//                imageData = [Common GetLastCatchedImageWithSeequID:contactObj.SeequID Height:IMAGE_HEIGHT*2];
//            } else {
//                imageData = [Common GetLastCatchedImageWithSeequID:contactObj.SeequID Height:IMAGE_HEIGHT];
//            }
//            
//            if (imageData) {
//                contactObj.image = [[UIImage alloc] initWithData:imageData];
//            } else {
//                contactObj.image = [Common GetImageByPTID:contactObj.SeequID andHeight:IMAGE_HEIGHT];
//            }
//
//            [self.MyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
//        }

//        [self.MyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
//    }
//}
//- (void) onContactObjectUpdate:(NSNotification*)notification {
//    NSDictionary *dict_post = [notification object];
//    NSDictionary *dict = [dict_post objectForKey:@"dict"];
//    
//    if (dict) {
//        NSString *seequID = [dict_post objectForKey:@"seequID"];
//        
//        ContactObject *obj = [self CheckObjectInArrayWithPT:seequID];
//        
//        if (obj) {
//            [obj SetUserInfoWithDictionary:dict];
//            [self.MyTableView reloadData];
//        }
//    }
//}

- (void) filterContacts {
       if (device_version > 5) {
               if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                                        message:@"No access to Address Book"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
               }else {
                        sectionsArray = [self configureSectionsWithArray:arrayAddressBook];
                    }
                } else {
                    sectionsArray = [self configureSectionsWithArray:arrayAddressBook];
                
     }

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
                if (obj.FirstName && [obj.FirstName length]>0) {
                        result = [obj.FirstName compare:text options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [text length])];
                        if (result == NSOrderedSame) {
                                [array addObject:obj];
                                
                                continue;
                        }

                }
                if (obj.LastName &&[obj.LastName length]>0) {
                        result = [obj.LastName compare:text options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [text length])];
                        if (result == NSOrderedSame) {
                                [array addObject:obj];
                        }
                        
                }
        }
    }
    
    return array;
}

- (NSMutableArray*)configureSectionsWithArray:(NSMutableArray*)array {
	// Get the current collation and keep a reference to it.
	UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
	
	NSInteger index, sectionTitlesCount = [[collation sectionTitles] count];
	
	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
	
	for (index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[newSectionsArray addObject:array];
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

- (ContactObject*)CheckObjectInArrayWithPT:(NSString*)seequID {
    for (ContactObject *obj in arrayContacts) {
        if ([obj.SeequID isEqualToString:seequID]) {
            return obj;
        }
    }
    
    return nil;
}

- (void) ReplaseContactObject:(ContactObject*)object {
    for (int i = 0; i < arrayContacts.count; i++) {
        ContactObject *contObj = [arrayContacts objectAtIndex:i];
        
        if ([contObj.SeequID isEqualToString:object.SeequID]) {
            [arrayContacts replaceObjectAtIndex:i withObject:object];
            
            break;
        }
    }
}

- (NSMutableArray*) AllContacts {
    return arrayContacts;
}

#pragma mark ContactObject Delegate

//
//- (void) didGetUserInfo:(ContactObject *)contactsObj withDict:(NSDictionary *)dict {
//    if ([Common CheckFavoriteWithSeequID:contactsObj.SeequID]) {
//        contactsObj.isFavorite = YES;
//    }
//    
//    int index = 0;
//    for (ContactObject *object in [self ArrayAddressBook]) {
//        if ([object.SeequID isEqualToString:contactsObj.SeequID]) {
//            if (object.image) {
//                contactsObj.image = object.image;
//            }
//            [[self ArrayAddressBook] replaceObjectAtIndex:index withObject:contactsObj];
//            
//            break;
//        }
//        index++;
//    }
//
//    ContactObject *obj = [self CheckObjectInArrayWithPT:contactsObj.SeequID];
////    if (!obj) {
////        [arrayContacts addObject:contactsObj];
////    } else {
//    if(obj) {
//        [self ReplaseContactObject:contactsObj];
//    }
//
//    [self filterContactsWithSegment_Type:segmentType];
////    [self.MyTableView reloadData];
//}
//
//- (void) didGetUserImage:(ContactObject*)contactsObj Image:(UIImage*)image {
//    NSIndexPath *indexPath = [self FindIndexPathWithPT:contactsObj.SeequID];
//    if (indexPath) {
////        ContactCell *cell = (ContactCell*)[self.MyTableView cellForRowAtIndexPath:indexPath];
////        if (cell) {
////            if (contactsObj.image) {
////                cell.imageView.image = contactsObj.image;
////            } else {
////                cell.imageView.image = [UIImage imageNamed:@"GenericContact.png"];
////            }
//        
////        [self.MyTableView reloadData];
////        }
//    }
//}
//
#pragma mark NSFetchedResultsController Delegate



- (NSFetchedResultsController *)getFetchedResultsController
{ if (_fetchedResultsController == nil) {
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
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:mContext
                                                          sectionNameKeyPath:@"firstName.stringGroupByFirstInitial"
                                                                        cacheName:nil];
		[_fetchedResultsController setDelegate:self];
             
		
		if (![_fetchedResultsController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
	}
	
	return _fetchedResultsController;
}
//-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
//        [self.MyTableView performSelectorOnMainThread:@selector(beginUpdates) withObject:nil waitUntilDone:YES];
//        [self.MyTableView beginUpdates];
//}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

        switch (type) {
        case NSFetchedResultsChangeDelete: {
//                [self.MyTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//                UserInfoCoreData *obj=(UserInfoCoreData*)anObject;
//                [[NSNotificationCenter defaultCenter] postNotificationName:kContactObjectUpdateNotification object:obj.seeQuId ];
            
        }
            break;
        case NSFetchedResultsChangeInsert: {
//                [self.MyTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//                UserInfoCoreData *obj=(UserInfoCoreData*)anObject;
//                [[NSNotificationCenter defaultCenter] postNotificationName:kContactObjectUpdateNotification object:obj.seeQuId ];
              
                
        }
            break;
            case NSFetchedResultsChangeUpdate:{
//               [self performSelectorOnMainThread:@selector(fetchChange:) withObject:anObject waitUntilDone:NO];
//                    UserInfoCoreData *obj=(UserInfoCoreData*)anObject;
//                    NSLog(@"fetch change update object with SeequId %@",obj.seeQuId);
                    
            }
                    break;
        default:
            break;
    }
      UserInfoCoreData *obj=(UserInfoCoreData*)anObject;
      [[NSNotificationCenter defaultCenter] postNotificationName:kContactObjectUpdateNotification object:obj.seeQuId ];

}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
        @synchronized(self.MyTableView)
        {
                [self.MyTableView reloadData];
        }
}

                 
                 //-(void)fetchChange:(NSIndexPath*)indexPath{
//        UserInfoCoreData *obj=[_fetchedResultsController objectAtIndexPath:indexPath];
//        NSLog(@"fetch change update object with SeequId %@",obj.seeQuId);
//
//        [[NSNotificationCenter defaultCenter] postNotificationName:kContactObjectUpdateNotification object:obj.seeQuId ];
//}
//#endif //XMPP_ON

//#if (XMPP_ON == 0)
//- (BOOL) AddContact: (NSString*)seeQuId contactInfo:(NSDictionary*) dict {
//    if(!seeQuId || !dict)
//        return FALSE;
//    
//    [Common AddUserToSavedContactListWithSeequID:dict];
//    ContactObject *contactObj = [[ContactObject alloc] initWithSeequID:seeQuId];
//    contactObj.contactType = Contact_Type_MY_Seequ_Contact;
//    [contactObj SetUserInfoWithDictionary:dict];
//    
//    NSData *imageData;
//    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2) {
//        //Retina display
//        imageData = [Common GetLastCatchedImageWithSeequID:seeQuId Height:IMAGE_HEIGHT*2];
//    } else {
//        imageData = [Common GetLastCatchedImageWithSeequID:seeQuId Height:IMAGE_HEIGHT];
//    }
//    
//    if (imageData) {
//        [contactObj performSelectorOnMainThread:@selector(setImage:) withObject:[[UIImage alloc] initWithData:imageData] waitUntilDone:YES];
//    } else {
//        [contactObj performSelectorOnMainThread:@selector(setImage:) withObject:[Common GetImageByPTID:seeQuId andHeight:IMAGE_HEIGHT] waitUntilDone:YES];
//    }
//    
//    id<ChatManager> chatMng = [idoubs2AppDelegate getChatManager];
//    NSString *from = [NSString stringWithFormat:@"%@@im.protime.tv", seeQuId];
//    if([chatMng GetUserOnLineStatus:from])
//        contactObj.isOnline = online_Status_Online;
//    
//    [arrayContacts addObject:contactObj];
//    [Common AddContactObjectToCommonArray:contactObj];
//    
//    if ([[chatMng GetUserSubscription:from] isEqualToString:@"both"])
//        [Common postNotificationWithName:kContactObjectChangeNotification object:contactObj];
//    
//
//    NSDictionary *dict_notification = [[NSDictionary alloc] initWithObjectsAndKeys:seeQuId, @"SeequID",
//                                       [NSNumber numberWithInt:contactObj.isOnline], @"Status", nil];
//    [Common postNotificationWithName:kXMPPStatusChangeNotification object:dict_notification];
//
//    if (segmentType == Segment_Type_My_Seequ) {
//        [self filterContactsWithSegment_Type:segmentType];
////        [self.MyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
//    }
//    
//    return TRUE;
//}
//#endif //(XMPP_ON == 0)

//- (void) SendContactUpdateRequest {
//    @autoreleasepool {
//        @synchronized(self) {
//            double lastModDate = [[NSUserDefaults standardUserDefaults] doubleForKey:@"lastModDate"];
//            
//            NSDictionary *dictionary;
//            NSString *error_msg;
//            
//            if (lastModDate) {
//                error_msg = [Common GetUpdatedUsersBySeequID:[[Common sharedCommon] SeequID] LastModDate:lastModDate UserList:&dictionary];
//            } else {
//                error_msg = [Common GetAllUsersBySeequID:[[Common sharedCommon] SeequID] UserList:&dictionary Save:YES];
//            }
//            
//            if (!error_msg && dictionary) {
//                NSDictionary *return_values = [dictionary objectForKey:@"return_values"];
////                int contactCount = [[dictionary objectForKey:@"resultCount"] intValue];
//                
//                NSArray *array = [return_values objectForKey:@"users"];
//                
//                if (array && array.count) {
//                    NSArray *array_keys = [dictionary allKeys];
//                    double lastModDate = 0;
//                    
//                    if ([array_keys containsObject:@"lastModDate"]) {
//                        lastModDate = [[dictionary objectForKey:@"lastModDate"] doubleValue];
//                    } else {
//                        lastModDate = [[return_values objectForKey:@"lastModDate"] doubleValue];
//                    }
//
//                    [[NSUserDefaults standardUserDefaults] setDouble:lastModDate forKey:@"lastModDate"];
//                    [[NSUserDefaults standardUserDefaults] synchronize];
//                }
//                
//                for (NSDictionary *dict in array) {
//                    NSString *seeQuId = [dict objectForKey:@"seeQuId"];
//                    
//                    ContactObject *object = [self CheckObjectInArrayWithPT:seeQuId];
//                    
//                    if (object) {
//                        [object SetUserInfoWithDictionary:dict];
//                        object.contactType = Contact_Type_MY_Seequ_Contact;
//                    } else {
//#if XMPP_ON
//                        [Common AddUserToSavedContactListWithSeequID:dict];
//                        ContactObject *contactObj = [[ContactObject alloc] initWithSeequID:seeQuId];
//                        contactObj.contactType = Contact_Type_MY_Seequ_Contact;
//                        [contactObj SetUserInfoWithDictionary:dict];
//                        NSData *imageData;
//                        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2) {
//                            //Retina display
//                            imageData = [Common GetLastCatchedImageWithSeequID:seeQuId Height:IMAGE_HEIGHT*2];
//                        } else {
//                            imageData = [Common GetLastCatchedImageWithSeequID:seeQuId Height:IMAGE_HEIGHT];
//                        }
//                        
//                        if (imageData) {
//                            [contactObj performSelectorOnMainThread:@selector(setImage:) withObject:[[UIImage alloc] initWithData:imageData] waitUntilDone:YES];
//                        } else {
//                            [contactObj performSelectorOnMainThread:@selector(setImage:) withObject:[Common GetImageByPTID:seeQuId andHeight:IMAGE_HEIGHT] waitUntilDone:YES];
//                        }
//                        
//                        [arrayContacts addObject:contactObj];
//                        [Common AddContactObjectToCommonArray:contactObj];
//                        
//                        if (segmentType == Segment_Type_My_Seequ) {
//                            [self filterContactsWithSegment_Type:segmentType];
////                            [self.MyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
//                        }
//#else
//                        [self AddContact:seeQuId contactInfo:dict];
//#endif
//                    }
//                }
//                
////                if (contactCount && arrayContacts.count && arrayContacts.count != contactCount) {
////                    NSLog(@"Reload all contacts.");
////                    
////                    [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:@"lastModDate"];
////                    [self SendContactUpdateRequest];
////                }
//            }
//        }
//    }
//}

//- (void) fetchedResultsDelete:(NSString *)seequID {
//    ContactObject *obj = [self CheckObjectInArrayWithPT:seequID];
//    if (obj) {
//        obj.contactType = Contact_Type_Seequ_Contact;
//        [Common postNotificationWithName:kContactObjectChangeNotification object:obj];
//        [arrayContacts removeObject:obj];
//        [Common RemoveUserFromSavedContactListWithSeequID:seequID];
//        
//        if (segmentType == Segment_Type_My_Seequ) {
//            @synchronized(sectionsArray) {
//                sectionsArray = [self configureSectionsWithArray:arrayContacts];
//            }
//            
//            if ([NSThread currentThread] == [NSThread mainThread])
//                [self.MyTableView reloadData];
//            else
//                [self.MyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
//        }
//    }
//    else
//    {
//        obj = [[ContactObject alloc] initWithSeequID:seequID];
//        obj.contactType = Contact_Type_Seequ_Contact;
//        [Common postNotificationWithName:kContactObjectChangeNotification object:obj];
//    }
//}
//
//#if XMPP_ON
//- (void) fetchedResultsInsert:(XMPPUserCoreDataStorage *)user {
//    
//    NSString *seequID = user.jid.user;
//#else
//- (void) fetchedResultsInsert:(UserCoreDataStorage *)user {
//
//    NSString *seequID = [user.from substringWithRange: NSMakeRange(0, [user.from rangeOfString: @"@"].location)];
//#endif
//    
//    ContactObject *obj = [Common getContactObjectWithSeequID:seequID];
//    obj.delegate = self;
//    obj.contactType = Contact_Type_MY_Seequ_Contact;
//
//#if XMPP_ON
//    if ([user.subscription isEqualToString:@"none"])
//    {
//        obj.contactType = Contact_Type_Request_Connection;
//        obj.isOnline = online_Status_Away;
//        [Common postNotificationWithName:kContactObjectChangeNotification object:obj];
//    }
//#else
//    obj.contactType = Contact_Type_Request_Connection;
//    if([user.presence_type isEqualToString:@"available"])
//        obj.isOnline = online_Status_Online;
//    else if([user.presence_type isEqualToString:@"unavailable"])
//        obj.isOnline = online_Status_Offline;
//    else
//        obj.isOnline = online_Status_Away;
//    [Common postNotificationWithName:kContactObjectChangeNotification object:obj];
//#endif //XMPP_ON
//
//    int index = 0;
//    for (ContactObject *object in [self ArrayAddressBook]) {
//        if (obj.SeequID == object.SeequID) {
//            [[self ArrayAddressBook] replaceObjectAtIndex:index withObject:obj];
//            
//            break;
//        }
//        index++;
//    }
//    
//#if XMPP_ON
//    [NSThread detachNewThreadSelector:@selector(GetingFirstLastName)
//                             toTarget:obj
//                           withObject:nil];
//#endif //XMPP_ON
//}

-(void) setCellImage:(NSArray*) param{
    if(param.count) {
        ContactCell *cell = [param objectAtIndex:0];
        ContactObject *obj = [param objectAtIndex:1];
        [cell setOnlineStatus:obj.isOnline];
    }
}

//#if XMPP_ON
//- (void) fetchedResultsUpdate:(XMPPUserCoreDataStorage *)user {
//
//    NSString *seequID = user.jid.user;
//#else
//- (void) fetchedResultsUpdate:(UserCoreDataStorage *)user {
//
//    NSString *seequID = [user.from substringWithRange: NSMakeRange(0, [user.from rangeOfString: @"@"].location)];
//#endif
//    ContactObject *obj = [self CheckObjectInArrayWithPT:seequID];
//    
//    if (obj) {
//
//        if ([user.subscription isEqualToString:@"both"]) {
//            obj.contactType = Contact_Type_MY_Seequ_Contact;
//            [Common postNotificationWithName:kContactObjectChangeNotification object:obj];
//        }
//        
//#if XMPP_ON
//        if ([user isOnline]) {
//#else
//        if ([user.presence_type isEqualToString:@"available"]) {
//#endif //XMPP_ON
//            obj.isOnline = online_Status_Online;
//        } else {
//            obj.isOnline = online_Status_Offline;
//        }
//        
//        NSDictionary *dict_notification = [[NSDictionary alloc] initWithObjectsAndKeys:seequID, @"SeequID",
//                                           [NSNumber numberWithInt:obj.isOnline], @"Status", nil];
//
//        [Common postNotificationWithName:kXMPPStatusChangeNotification object:dict_notification];
//
//        NSIndexPath *indexPath = [self FindIndexPathWithPT:obj.SeequID];
//        if (indexPath) {
//            ContactCell *cell = (ContactCell*)[self.MyTableView cellForRowAtIndexPath:indexPath];
//            
//            if (cell) {
//#if XMPP_ON
//                [cell setOnlineStatus:obj.isOnline];
//#else
//                NSArray* param = [[NSArray alloc] initWithObjects:cell, obj, nil];
//                [self performSelectorOnMainThread:@selector(setCellImage:) withObject:param waitUntilDone:YES];
//#endif //XMPP_ON
//            }
//        } else {
//            if (segmentType == Segment_Type_My_Seequ) {
//                @synchronized(sectionsArray) {
//                    sectionsArray = [self configureSectionsWithArray:arrayContacts];
//                }
//                [self.MyTableView reloadData];
//            }
//        }
//    }
//}
//
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        if (segmentType==Segment_Type_Phone) {
                return [sectionsArray count];
        }else{
                return [_fetchedResultsController.sections count];
        }
        return 0;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        if (segmentType==Segment_Type_Phone) {
                if ([sectionsArray count] > section) {
                        NSMutableArray *array = [sectionsArray objectAtIndex:section];
                        return [array count];
                }
        }else{
                id<NSFetchedResultsSectionInfo>sectionInfo=[_fetchedResultsController.sections objectAtIndex:section];
                return sectionInfo.numberOfObjects;
        }
        return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        if(segmentType==Segment_Type_Phone){
                @try {
                        if (sectionsArray && [sectionsArray isKindOfClass:[NSMutableArray class]] && [sectionsArray count] > section) {
                                NSMutableArray *array = [sectionsArray objectAtIndex:section];
                                ContactObject *obj = [array objectAtIndex:0];
                                
                                if (ABPersonGetSortOrdering() == kABPersonSortByFirstName) {
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
                @catch (NSException *exception) {
                        return nil;
                }

        }else{
                id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
                return [sectionInfo name];
                
        }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
      cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Set up the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;

    //First get the dictionary object
//    if (sectionsArray.count > indexPath.section) {
//        NSMutableArray *array = [sectionsArray objectAtIndex:indexPath.section];
//        if (array.count > indexPath.row) {
//             *obj = [array objectAtIndex:indexPath.row];
//
        ContactObject *contact;
        if(segmentType==Segment_Type_Phone){
            if (sectionsArray.count > indexPath.section) {
                NSMutableArray *array = [sectionsArray objectAtIndex:indexPath.section];
                if (array.count > indexPath.row) {
                        contact=[array objectAtIndex:indexPath.row];
                }
            }
            cell.cellType = CellType_Phone;

            [cell setContactObject:contact];
            
        }else{
            UserInfoCoreData *obj=[_fetchedResultsController objectAtIndexPath:indexPath];
            //contact=[[ContactStorage sharedInstance] GetContactObjectBySeequId:obj.seeQuId];
            if (_isForGroup) {
                cell.cellType = CellType_Group;
            } else {
                cell.cellType = CellType_Seequ;
            }
            [cell updateCell:obj];

        }
//        [ContactStorage UserInfoToContactObject:obj contactObject:contact];
//            cell setOnlineStatus:[]
//        } else {
//            NSLog(@"if (array.count > indexPath.row) {");
//        }
//    } else {
//        NSLog(@"if (sectionsArray.count > indexPath.section) {");
//    }
    
    return cell;
}
    
-(void)updateCreateGroupButtonState:(BOOL)flag {
    NSAssert(false,@"this  function  must  be overriden in the  derived class!!");
}
    
-(UserInfoCoreData*) getObjectAtIndexPath:(NSIndexPath *)path {
    return  [_fetchedResultsController objectAtIndexPath:path];


}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

        if (segmentType!=Segment_Type_Phone) {
                UserInfoCoreData *userInfo=[_fetchedResultsController objectAtIndexPath: indexPath];
                selectedContactObject=[[ContactStorage sharedInstance] GetContactObjectBySeequId:userInfo.seeQuId];
        }else{
                NSMutableArray *array = [sectionsArray objectAtIndex:indexPath.section];
                selectedContactObject = [array objectAtIndex:indexPath.row];
        }
//    NSString *url_image = [Common putImageToSeequID:selectedContactObject.SeequID ImageData:UIImageJPEGRepresentation(selectedContactObject.image, 1.0) ImageName:@"test_name.jpg"];
    if (!_isForGroup) {
        if (selectedContactObject.contactType != Contact_Type_NON) {
            if (selectedContactObject.contactType != Contact_Type_Address_Book) {
                SeequContactProfileViewController *profileViewController = [[SeequContactProfileViewController alloc] initWithNibName:@"SeequContactProfileViewController" bundle:nil];
                profileViewController.contactObj = selectedContactObject;
                profileViewController.videoViewState = videoViewState;
                profileViewController.accessToConnections = YES;
                [self.navigationController pushViewController:profileViewController animated:YES];
            } else {
                SeequPhoneContactInviteViewController *controller = [[SeequPhoneContactInviteViewController alloc] initWithNibName:@"SeequPhoneContactInviteViewController" bundle:nil];
                controller.contactObj = selectedContactObject;
                controller.videoViewState = videoViewState;
                [self.navigationController pushViewController:controller animated:YES];
            }
        } else {
            if ([selectedContactObject.SeequID isEqualToString:[Common sharedCommon].contactObject.SeequID]) {
                [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 4;
            }
        }
        
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        BOOL flag = [self.MyTableView indexPathsForSelectedRows].count !=0;
        [self updateCreateGroupButtonState: flag];
    }
 
}
    
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isForGroup) {
        BOOL flag = [self.MyTableView indexPathsForSelectedRows].count !=0;

        [self updateCreateGroupButtonState: flag];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
            if(segmentType!=Segment_Type_Phone){
                    if ([[_fetchedResultsController sections] count]<3) {
                            return nil;
                    }
                    NSMutableArray *indices = [NSMutableArray array];
                    
                    id <NSFetchedResultsSectionInfo> sectionInfo;
                    
                    for( sectionInfo in [_fetchedResultsController sections] )
                    {
                            [indices addObject:[sectionInfo name]];
                    }
                    return indices;

                    
            }else{
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
            }
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {  // tell table which section corresponds to section title/index (e.g. "B",1))
        if (segmentType!=Segment_Type_Phone) {
                return [_fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
        }else{
                return [self IndexForTitle:title];
        }
}
- (NSInteger) IndexForTitle:(NSString*)text {
    @synchronized(sectionsArray) {
        NSInteger index = 0;
        for (NSMutableArray *array in sectionsArray) {
            ContactObject *obj = [array objectAtIndex:0];
            
            NSString *compositeName = [obj CompositeName];
            if (compositeName && [compositeName isKindOfClass:[NSString class]] && compositeName.length && [[[compositeName substringToIndex:1] uppercaseString] isEqualToString:text]) {
                return index;
            }
            
            index++;
        }
    }
    
    return -1;
}

    
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.MySearchBar resignFirstResponder];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (IBAction)onButtonFilter:(id)sender {
    UIButton *button = (UIButton*)sender;
        [self.MySearchBar setText:@""];
        [self.MySearchBar resignFirstResponder];
        switch (button.tag) {
        case 1: {
            if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
                [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
                return;
            } else {
                segmentType = Segment_Type_Phone;
                [self.buttonPhone setBackgroundImage:[UIImage imageNamed:@"segContactsPhoneSel.png"] forState:UIControlStateNormal];
                [self.buttonMySeequ setBackgroundImage:[UIImage imageNamed:@"segContactsMySeequ.png"] forState:UIControlStateNormal];
                [self.buttonFavorites setBackgroundImage:[UIImage imageNamed:@"segContactsFavorites.png"] forState:UIControlStateNormal];
                self.navigationItem.rightBarButtonItem = nil;
                self.navigationItem.leftBarButtonItem = nil;
                    if (![sectionsArray count]) {
                            [self LoadAddressBook];
                    }else{
                         sectionsArray = [self configureSectionsWithArray:arrayAddressBook];
                    }
            }
        }
            break;
        case 2: {
               segmentType = Segment_Type_My_Seequ;
            [self.buttonPhone setBackgroundImage:[UIImage imageNamed:@"segContactsPhone.png"] forState:UIControlStateNormal];
            [self.buttonMySeequ setBackgroundImage:[UIImage imageNamed:@"segContactsMySeequSel.png"] forState:UIControlStateNormal];
            [self.buttonFavorites setBackgroundImage:[UIImage imageNamed:@"segContactsFavorites.png"] forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem = settingsBarButton;
            self.navigationItem.leftBarButtonItem = searchBarButton;
        }
            break;
        case 3: {
            segmentType = Segment_Type_Favorites;
            [self.buttonPhone setBackgroundImage:[UIImage imageNamed:@"segContactsPhone.png"] forState:UIControlStateNormal];
            [self.buttonMySeequ setBackgroundImage:[UIImage imageNamed:@"segContactsMySeequ.png"] forState:UIControlStateNormal];
            [self.buttonFavorites setBackgroundImage:[UIImage imageNamed:@"segContactsFavoritesSel.png"] forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem = nil;
             self.navigationItem.leftBarButtonItem = searchBarButton;
        }
            break;
            
        default:
            break;
    }
        [self updatePredicate];
}
-(void)updatePredicate{
        NSPredicate *predicate;
        NSError *error;
        switch (segmentType) {
                case Segment_Type_My_Seequ:{
                    predicate=[NSPredicate predicateWithFormat:@"firstName.length >0 && status.subscription=%@",@"both"];
                }
                break;
                case Segment_Type_Favorites:{
                      predicate=[NSPredicate predicateWithFormat:@"firstName.length >0 && status.subscription=%@ && isFavorit=%@",@"both",[NSNumber numberWithBool:YES]];
                }
                default:
                  break;
        }
        [_fetchedResultsController.fetchRequest setPredicate:predicate];
        [_fetchedResultsController performFetch:&error];
        if(error){
                NSLog(@"Error-%@",[error description]);
        }
        [self.MyTableView reloadData];
}

- (IBAction) onButtonSearch:(id)sender {
    if ([[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
            if(segmentType==Segment_Type_Favorites){
                SeequAddFavoriteViewController *addFivorite=[[SeequAddFavoriteViewController alloc] initWithFrame:self.view.frame];
//                    addFivorite.fetchedController=_fetchedResultsController;
                    [self.navigationController pushViewController:addFivorite animated:NO];
            }else{
        SeequSearchResultsViewController *searchViewController = [[SeequSearchResultsViewController alloc] initWithNibName:@"SeequSearchResultsViewController" bundle:nil];
        searchViewController.searchText = nil;
        searchViewController.videoViewState = videoViewState;
        [self.navigationController pushViewController:searchViewController animated:YES];
            }
    } else {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    }
}

- (IBAction) onButtonSettings:(id)sender {
    MyProfileViewController *myProfileViewController = [[MyProfileViewController alloc] initWithNibName:@"MyProfileViewController" bundle:nil];
    myProfileViewController.videoViewState = videoViewState;
    [self.navigationController pushViewController:myProfileViewController animated:YES];
}

#pragma mark -
#pragma mark UISearchBar Delegate Methods
#pragma mark -

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.MySearchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.MySearchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
        NSError *error;
        NSPredicate *predicate;
    switch (segmentType) {
        case Segment_Type_Phone: {
            if (device_version > 5 && ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                                message:@"No access to Address Book"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                [alert show];
                
                break;
            }
            if (searchText && [searchText length]>0) {
                NSMutableArray *array = [self ArrayWithSearchText:searchText onArray:arrayAddressBook];
                sectionsArray = [self configureSectionsWithArray:array];
            } else {
                sectionsArray = [self configureSectionsWithArray:arrayAddressBook];
            }
        }
            break;
        case Segment_Type_My_Seequ: {
            if (searchText && [searchText length]) {
                  predicate=[NSPredicate predicateWithFormat:@"firstName.length >0 && status.subscription=%@ && firstName CONTAINS[cd] %@",@"both",searchText];
            }else{
                  predicate=[NSPredicate predicateWithFormat:@" firstName.length >0 && status.subscription=%@ ",@"both"];
            }
                [_fetchedResultsController.fetchRequest setPredicate:predicate];
                [_fetchedResultsController performFetch:&error];
        }
            break;
        case Segment_Type_Favorites: {
            if (searchText && [searchText length]) {
                    predicate=[NSPredicate predicateWithFormat:@"firstName.length >0 && status.subscription=%@ && isFavorit=%d && firstName CONTAINS[cd] %@ ",@"both",[[NSNumber numberWithBool:YES]integerValue],searchText];
                    
            }else{
                 predicate=[NSPredicate predicateWithFormat:@"firstName.length >0 && status.subscription=%@ && isFavorit=%d ",@"both",[[NSNumber numberWithBool:YES] integerValue]];
            }
                [_fetchedResultsController.fetchRequest setPredicate:predicate];
                [_fetchedResultsController performFetch:&error];
        }
            break;
            
        default:
            break;
    }
        if (error) {
                NSLog(@"Erroor-%@",[error description]);
        }
    [self.MyTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
    [self.MySearchBar setText:@""];
        switch (segmentType) {
                case Segment_Type_Favorites:
                case Segment_Type_My_Seequ:
                        [self updatePredicate];
                        break;
                case Segment_Type_Phone:
                        if ([arrayAddressBook count]>0) {
                                sectionsArray = [self configureSectionsWithArray:arrayAddressBook];
                                [self.MyTableView reloadData];
                        }

                        break;
                default:
                        break;
        }

}

- (NSIndexPath*) FindIndexPathWithPT:(NSString*)seequID {
    NSInteger section = 0;
    
    @synchronized(sectionsArray) {
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
    }

    return nil;
}

- (void) LoadAddressBook {
    @synchronized(arrayAddressBook) {
        [arrayAddressBook removeAllObjects];
         addressBook = ABAddressBookCreateWithOptions(nil, nil);
            if (device_version > 5) {
            if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                    if (granted && addressBook) {
                       [self LoadAddressBookElements];
                       [self filterContacts];
                       [self.MyTableView reloadData];
                    }
                });
            } else {
               
                
                if (addressBook) {
                    [self LoadAddressBookElements];
                }
            }
        } else {
            addressBook = ABAddressBookCreateWithOptions(nil, nil);
            
            if (addressBook) {
                [self LoadAddressBookElements];
            }
        }
    }
        ABAddressBookRegisterExternalChangeCallback(addressBook, AddressBookExternalChangeCallback, (__bridge_retained  void *)self);
        [self filterContacts];
        [self.MyTableView reloadData];
}

- (void) LoadAddressBookElements {
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                               CFArrayGetCount(people),
                                                               people);
        
    CFArraySortValues(peopleMutable,
                      CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                      (CFComparatorFunction) TBIAddressBookCompareByCompositeName,
                      (void*) ABPersonGetSortOrdering());
    
    // Create TBI contacts
    CFArrayApplyFunction(peopleMutable, CFRangeMake(0, CFArrayGetCount(peopleMutable)), TBIAddressBookCallbackForElements, (void*)self);
    
    CFRelease(peopleMutable);
    CFRelease(people);
    
    [NSThread detachNewThreadSelector:@selector(SyncroniseAddressBookFromServer)
                             toTarget:self
                           withObject:nil];
}

static void TBIAddressBookCallbackForElements(const void *value, void *context)
{
	SeequContactsViewController* self_ = (__bridge SeequContactsViewController*)context;
    
	const ABRecordRef* record = (const ABRecordRef*)value;
	ContactObject* contact = [[ContactObject alloc] initWithABRecordRef:record];
	if (contact) {
		[[self_ ArrayAddressBook] addObject: contact];
	}
}

static CFComparisonResult TBIAddressBookCompareByCompositeName(ABRecordRef person1, ABRecordRef person2, ABPersonSortOrdering ordering)
{
	CFStringRef displayName1 = ABRecordCopyCompositeName(person1);
	CFStringRef displayName2 = ABRecordCopyCompositeName(person2);
	CFComparisonResult result = kCFCompareEqualTo;
	
	switch([(__bridge NSString*)displayName1 compare: (__bridge NSString*)displayName2]){
		case NSOrderedAscending:
			result = kCFCompareLessThan;
			break;
		case NSOrderedSame:
			result = kCFCompareEqualTo;
			break;
		case NSOrderedDescending:
			result = kCFCompareGreaterThan;
			break;
	}
	
    CFBridgingRelease(displayName1);
    CFBridgingRelease(displayName2);
	
	return result;
}

- (NSMutableArray*) ArrayAddressBook {
    if (!arrayAddressBook) {
        arrayAddressBook = [[NSMutableArray alloc] init];
    }
    return arrayAddressBook;
}

- (void) SyncroniseAddressBookFromServer {
    @autoreleasepool {
        @synchronized([self ArrayAddressBook]) {
            NSMutableArray *array = [self ArrayAddressBook];
            NSMutableArray *arrayServerList = [[NSMutableArray alloc] init];
            
            for (ContactObject *object in array) {
                NSMutableArray *arrayPhoneList = [[NSMutableArray alloc] init];
                NSMutableArray *arrayEmailList = [[NSMutableArray alloc] init];
                
                for (AddressBookItem *item in object.arrayAddressBookItems) {
                    if (item.itemType == Item_Type_Phone_Number) {
                        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:item.value, @"phone", nil];
                        [arrayPhoneList addObject:dict];
                        continue;
                    }
                    
                    if (item.itemType == Item_Type_EMail) {
                        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:item.value, @"email", nil];
                        [arrayEmailList addObject:dict];
                    }
                }
                
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:object.FirstName, @"firstName",
                                      object.LastName, @"lastName",
                                      arrayEmailList, @"emailList",
                                      arrayPhoneList, @"phoneList", nil];
                [arrayServerList addObject:dict];
            }
            
            NSArray *arrayRetval = nil;
            
            BOOL retVal = NO;
            int req_count = 0;
            while (!retVal && req_count < 2) {
                retVal = [Common GetAddressBookSyncListWithArray:arrayServerList ReturnArray:&arrayRetval];
                req_count++;
            }
            
            if (!retVal) {
                return;
            }
            
            for (NSDictionary *dict in arrayRetval) {
                NSString *first = [dict objectForKey:@"firstName"];
                NSString *last = [dict objectForKey:@"lastName"];
                
                
                ContactObject *object = [self ObjectFromAddressBookArrayWithFirstName:first LastName:last];
                
                if (object) {
                    object.SeequID = [dict valueForKey:@"seeQuId"];
                    
                    ContactObject *seequ_object = [self CheckObjectInArrayWithPT:object.SeequID];
                    
                    if (seequ_object) {
                        
                        int index = 0;
                        for (ContactObject *obj in [self ArrayAddressBook]) {
                            if (obj == object) {
                                [[self ArrayAddressBook] replaceObjectAtIndex:index withObject:seequ_object];
                                
                                break;
                            }
                            index++;
                        }
                    } else {
                        [object SetUserInfoWithDictionary:dict];
                        object.isNameSeted = YES;
                        object.delegate = self;
                        object.imageExist = YES;
                        object.contactType = Contact_Type_Seequ_Contact;
                        
                        [NSThread detachNewThreadSelector:@selector(StartGetingImage)
                                                 toTarget:object
                                               withObject:nil];
                    }
                }
            }
        }
        
//        [self performSelectorOnMainThread:@selector(RefreshUI)
//                               withObject:nil
//                            waitUntilDone:YES];
    }
}

- (ContactObject*) ObjectFromAddressBookArrayWithFirstName:(NSString*)first LastName:(NSString*)last {
    NSMutableArray *array = [self ArrayAddressBook];
    for (ContactObject *object in array) {
        if ([[object.FirstName lowercaseString] isEqualToString:[first lowercaseString]] &&
            [[object.LastName lowercaseString] isEqualToString:[last lowercaseString]]) {
            return object;
        }
    }
    
    return nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

        if ([buttonTitle isEqualToString:actionSheetButtonTitleEmail]) {
            if (![MFMailComposeViewController canSendMail]) {
                return;
            }
            
            NSMutableArray *arrayRecipients = [[NSMutableArray alloc] init];
            for (AddressBookItem *item in selectedContactObject.arrayAddressBookItems) {
                if (item.itemType == Item_Type_EMail) {
                    [arrayRecipients addObject:item.value];
                }
            }

            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setMessageBody:@"Hey, you should get Seequ." isHTML:NO];
            [picker setSubject:@"Seequ Invitation"];
            [picker setToRecipients:arrayRecipients];
            [self.tabBarController presentViewController:picker animated:YES completion:nil ];
            
            return;
        }
        
        if ([buttonTitle isEqualToString:actionSheetButtonTitleSMS]) {
            if (![MFMessageComposeViewController canSendText]) {
                return;
            }
            
            NSMutableArray *arrayRecipients = [[NSMutableArray alloc] init];
            for (AddressBookItem *item in selectedContactObject.arrayAddressBookItems) {
                if (item.itemType == Item_Type_Phone_Number) {
                    [arrayRecipients addObject:item.value];
                }
            }

            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate = self;
            [picker setBody:@"Hey, you should get Seequ."];
            [picker setRecipients:arrayRecipients];
            [self.tabBarController presentViewController:picker animated:YES completion:nil ];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil ];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil ];
}

//- (void) RefreshUI {
//    [self filterContactsWithSegment_Type:segmentType];
////    [self.MyTableView reloadData];
//}

- (void) viewDidUnload {
    [self setButtonFavorites:nil];
    [self setButtonMySeequ:nil];
    [self setButtonPhone:nil];
    
    [self setMyTableView:nil];
    [self setMySearchBar:nil];
//    _fetchedResultsController=nil;
    [super viewDidUnload];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self setVideoViewState:videoViewState Animated:YES];
}

- (NSMutableArray*) GetContactList {
    return arrayContacts;
}

@end
