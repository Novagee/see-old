//
//  SeequEditGroup1ViewController.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 5/21/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequEditGroupViewController.h"
#import "ContactObject.h"
#import "Common.h"
#import "idoubs2AppDelegate.h"
#import "ContactCell.h"
#import "TBISoundService.h"
#import "RTMPChatManager.h"
#import "Common.h"
#import "ContactStorage.h"
#import "MessageCoreDataManager.h"


@interface SeequEditGroupViewController (){
    UIButton* createButton;
    
}
@property NSMutableArray* selectedContacts;
@end

@implementation SeequEditGroupViewController

@synthesize groupInfo = _groupInfo;
@synthesize delegate = _delegate;
@synthesize selectedContacts = _selectedContacts;

-(id) init {
    self = [super initWithNibName:@"SeequContactsViewController" bundle:nil];
    if (self) {
        self.isForGroup = YES;
        _selectedContacts = [[NSMutableArray alloc] init];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isForGroup = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectUpdate:) name:@"ContactObjectProfileDataUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactListUpdate:) name:kContactListNotification object:nil];
  
    arrayContacts = [[NSMutableArray alloc] init];
    arrayFavorites = [[NSMutableArray alloc] init];
    sectionsArray = [[NSMutableArray alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autologin"]) {
//        [self onContactListUpdate:nil];
    }
    
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Recipients";
    UIButton*  button =  [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* im = [UIImage imageNamed:@"defaultSeequCancelButton"];
    button.frame = CGRectMake(0, 0, im.size.width, im.size.height);
    [button setBackgroundImage:im forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onButtonBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem*  item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem =item;
    
    createButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* im1 = [UIImage imageNamed:@"defaultSeequAddButton.png"];
    createButton.frame = CGRectMake(0, 0, im1.size.width, im1.size.height);
    [createButton setBackgroundImage:im1 forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(onCreate:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*  item1 = [[UIBarButtonItem alloc] initWithCustomView:createButton];
    self.navigationItem.rightBarButtonItem = item1;
    self.MyTableView.allowsMultipleSelectionDuringEditing = YES;
    self.MyTableView.editing = YES;
    
    self.navigationController.navigationBar.translucent = YES;
    
    [self.navigationController.navigationBar setBackgroundImage: [UIImage imageNamed:@"seequNavigationDefaultBG.png"] forBarMetrics:UIBarMetricsDefault];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (IS_IOS_7) {
        [self.MyTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
        [self.MyTableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    }
//    [fetchedResultsController setDelegate:self];
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autologin"]) {
//        [NSThread detachNewThreadSelector:@selector(SendContactUpdateRequest) toTarget:self withObject:nil];
//    }
    
    createButton.enabled =self.MyTableView.indexPathsForSelectedRows.count !=0;

}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.MyTableView.editing = YES;
}

-(NSString*) getRecipientsName:(NSArray*) arr {
    NSMutableArray* temp = [[NSMutableArray alloc] init];
    for (UserInfoCoreData* info in arr) {
        [temp addObject:[NSString stringWithFormat:@"%@ %@",info.firstName, info.lastName]];
    }
    return [temp componentsJoinedByString:@","];
}

-(void) onCreate:(id) sender {
    _groupInfo = [[SeequGroupInfo alloc] initWithName:@""];
    _groupInfo.groupID =GROUP_ID;
    ContactObject* ob =[Common sharedCommon].contactObject;
    _groupInfo.ownerID = ob.SeequID;
    //[idoubs2AppDelegate sharedInstance].sqliteService
    NSArray* receivers = [self getSelectedContacts];
    _groupInfo.name = [self getRecipientsName:receivers];
    
    BOOL  flag  = [[idoubs2AppDelegate getChatManager] createGroup:_groupInfo.name groupId:_groupInfo.groupID];
    if (!flag) {
        ///@todo levon needs to  add  error and alerting
        return;
    }
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
   [dict setObject:_groupInfo.groupID forKey:@"roomId"];
    [dict setObject:_groupInfo.name forKey:@"roomName"];
    [dict setObject:_groupInfo.ownerID forKey:@"inviter"];
    NSMutableArray* temp = [[NSMutableArray alloc] init];
    for (UserInfoCoreData* info in receivers) {
        [temp addObject:info.seeQuId];
    }
    [dict setObject:temp forKey:@"participants"];
    _groupInfo.members = temp;

    [[MessageCoreDataManager sharedManager] insertGroupFromDictionary:dict];
     [[idoubs2AppDelegate getChatManager] joinGroups:[NSArray arrayWithObject:_groupInfo.groupID]];
    ///@todo levon needs to  remove  name  as  unnecessary
    flag = [[idoubs2AppDelegate getChatManager] invite:_groupInfo.name groupId:_groupInfo.groupID members:receivers];
    if (!flag) {
        ///@todo levon needs to  add  error and alerting
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [_delegate didEditGroup:self.groupInfo new:YES];

    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)onButtonBack:(id) sender {
    
    [self  dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.MyTableView.frame = self.view.bounds;
}

-(void) updateCreateGroupButtonState:(BOOL)flag {
    createButton.enabled = flag;
}

-(NSArray*) getSelectedContacts{
    NSArray* array = [self.MyTableView indexPathsForSelectedRows];
    NSMutableArray*  arr = [[NSMutableArray alloc] init];
    
    for (NSIndexPath* indexPath in array) {
        UserInfoCoreData*  obj = [self getObjectAtIndexPath:indexPath];
        [arr addObject:obj];
    }
    return  [NSArray arrayWithArray:arr];
}

-(NSString*) getSelectedInfoPredicat{
    NSString* predicat = @"";
    for (UserInfoCoreData* userInfo  in _selectedContacts) {
       //  UserInfoCoreData* userInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (predicat.length == 0) {
            predicat = [predicat stringByAppendingString:[NSString stringWithFormat:@"seeQuId = \"%@\"",userInfo.seeQuId]];
        } else {
            predicat = [predicat stringByAppendingString:[NSString stringWithFormat:@" || seeQuId = \"%@\"",userInfo.seeQuId]];
        }
    }
    if (predicat.length) {
        predicat = [predicat stringByAppendingString:@" || "];
    }
    return  predicat;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSError *error;
    NSPredicate *predicate;
    NSString* selectedUsrs = [self getSelectedInfoPredicat];

    if (searchText && [searchText length]) {
        NSString* tmp = [NSString stringWithFormat:@"%@ status.subscription=\"%@\" && firstName CONTAINS[cd] \"%@\"",selectedUsrs,@"both",searchText];
        
        predicate=[NSPredicate predicateWithFormat:tmp];
    }else{
         NSString* tmp = [NSString stringWithFormat:@"%@ status.subscription=\"%@\" ",selectedUsrs,@"both"];
        predicate=[NSPredicate predicateWithFormat:tmp];
    }
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Erroor-%@",[error description]);
    }
    [self.MyTableView reloadData];
    for (UserInfoCoreData* obj in _selectedContacts) {
        [self.MyTableView selectRowAtIndexPath:[self.fetchedResultsController indexPathForObject:obj] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }

}
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.MyTableView.editing = YES;
    NSLog(@"sdlkfjlskdjflskjdflkjslkdfjlskdjflskjdlfkjslkdf");
}

-(void)updatePredicate{
    [super updatePredicate];
    for (UserInfoCoreData* obj in _selectedContacts) {
        [self.MyTableView selectRowAtIndexPath:[self.fetchedResultsController indexPathForObject:obj] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [super controllerDidChangeContent:controller];
    for (UserInfoCoreData* obj in _selectedContacts) {
        [self.MyTableView selectRowAtIndexPath:[self.fetchedResultsController indexPathForObject:obj] animated:NO scrollPosition:UITableViewScrollPositionNone];
    };
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    UserInfoCoreData* info =[self.fetchedResultsController objectAtIndexPath:indexPath];
    [_selectedContacts addObject: info];
}
-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didDeselectRowAtIndexPath:indexPath];
    UserInfoCoreData* info =[self.fetchedResultsController objectAtIndexPath:indexPath];
    [_selectedContacts removeObject:info];

}



@end
