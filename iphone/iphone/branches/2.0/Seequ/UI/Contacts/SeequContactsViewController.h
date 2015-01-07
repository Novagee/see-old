//
//  SeequContactsViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 9/26/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MulticastDelegate.h"
#import "UserEntity.h"
#import "AccountEntity.h"
#import "XMPPvCardTempModule.h"
#import "XMPPManager.h"
#import "ContactObject.h"
#import <AddressBook/AddressBook.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "BackBarButton.h"
#import "ContactStorage.h"
#import "CoreDataManager.h"
#import "UserInfoCoreData.h"

typedef enum Segment_Type {
	Segment_Type_Phone,
    Segment_Type_My_Seequ,
    Segment_Type_Favorites
}
Segment_Type;

@interface SeequContactsViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, ContactObjectDelegate,UITableViewDelegate,UITableViewDataSource> {
    
    BackBarButton *settingsBarButton;
    BackBarButton *searchBarButton;
    id <XMPPRosterStorage> xmppRosterStorage;
    XMPPStream *xmppStream;
    XMPPRoster *xmppRoster;
    NSArray *sections;
    
    NSMutableArray *arrayContacts;
    NSMutableArray *arrayFavorites;
    NSMutableArray *arrayAddressBook;
    NSMutableArray *sectionsArray;
    Segment_Type segmentType;
    
    NSMutableArray *cachedContactList;
    
    ABAddressBookRef addressBook;
    
    int device_version;
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
    
    ContactObject *selectedContactObject;
    BOOL reloadTable;
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *MyTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *MySearchBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonPhone;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonMySeequ;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonFavorites;
@property (nonatomic,strong)  NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,assign) BOOL isForGroup;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (NSFetchedResultsController *)getFetchedResultsController;
- (void) setFetchedResultsController:(NSFetchedResultsController *)fetched;
- (void) onVideoViewChange:(NSNotification*)notification;
- (void) onSelectContact:(NSNotification*)notification;
//- (void) onContactListUpdate:(NSNotification*)notification;
//- (void) onContactObjectUpdate:(NSNotification*)notification;
//- (void) ContactObjectWithDictionary:(NSArray*)array;
- (IBAction) onButtonFilter:(id)sender;
- (IBAction) onButtonSearch:(id)sender;
//- (IBAction) onButtonAdd:(id)sender;
- (void) filterContacts;
- (NSMutableArray*) configureSectionsWithArray:(NSMutableArray*)array;
- (ContactObject*) CheckObjectInArrayWithPT:(NSString*)seequID;
- (NSIndexPath*) FindIndexPathWithPT:(NSString*)seequID;
- (NSMutableArray*) ArrayWithSearchText:(NSString*)text onArray:(NSArray*)base_array;
- (NSInteger) IndexForTitle:(NSString*)text;
- (NSMutableArray*) ArrayAddressBook;
- (void) LoadAddressBook;
- (void) SyncroniseAddressBookFromServer;
- (ContactObject*) ObjectFromAddressBookArrayWithFirstName:(NSString*)first LastName:(NSString*)last;
- (NSMutableArray*) AllContacts;
//- (void) ReloadTableViewData;
- (void) ReplaseContactObject:(ContactObject*)object;
- (NSMutableArray*) GetContactList;
-(void) updateCreateGroupButtonState:(BOOL) flag;
-(UserInfoCoreData*) getObjectAtIndexPath:(NSIndexPath*) path;
-(void)updatePredicate;
@end