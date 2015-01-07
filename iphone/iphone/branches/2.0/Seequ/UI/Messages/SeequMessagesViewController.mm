
//
//  SeequMessagesViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/19/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequMessagesViewController.h"
#import "SeequContactsViewController.h"
#import "idoubs2AppDelegate.h"
#import "NavigationBar.h"
#import "BackBarButton.h"
#import "ContactCell.h"
#import "MessageItem.h"
#import "TBIDefaultBadgView.h"
#import "SeequMessagesCell.h"
#import "SeequEditGroupViewController.h"
#import "RTMPChatManager.h"
#import "CoreDataManager.h"
#import "CDMessageOwner.h"
#import "MessageCoreDataManager.h"
#import "ContactStorage.h"
#import "CDGroup.h"

#import "NewMessageViewController.h"

@implementation UINavigationBar (customNav)
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width,46);
    return newSize;
}
@end

@interface SeequMessagesViewController ()<SeequEditGroupViewControllerDelegate, NSFetchedResultsControllerDelegate>{
    BOOL isInRotate;
    BackBarButton *newBarButton;
    NSFetchedResultsController *fetchedResultsController;

}
@property (nonatomic,retain) UIButton*  editButton;

@end

@implementation SeequMessagesViewController
@synthesize editButton;

- (void)awakeFromNib {
    [super awakeFromNib];
    isInRotate= NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectImage:) name:@"ContactObjectImageMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallStateChange:) name:kCallStateChange object:nil];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    self.edgesForExtendedLayout=UIRectEdgeAll;
    // Do any additional setup after loading the view from its nib.
    if ([[UIScreen mainScreen] bounds].size.height == 568) {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"seequMessagesBG-568@2x.png"]]];
    } else {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"seequMessagesBG.png"]]];
    }
    [self.MyTableView registerClass:[SeequMessagesCell class] forCellReuseIdentifier:@"SeequMessagesCell"];
    SearchBar = [[SearchBarWithCallButton alloc] initWithFrame:CGRectMake(0, 0, 320, 44) ShowCallButton:[[idoubs2AppDelegate sharedInstance].videoService isInCall]];
    SearchBar.delegate = self;
    
    self.MyTableView.tableHeaderView = SearchBar;
    videoViewState = VideoViewState_NONE;
    arrayFinish = nil;
    arraySearch = nil;
    
    newBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"SeequButtonWriteMessage.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(onButtonNewMessage:)];
    self.navigationItem.rightBarButtonItem = newBarButton;
    
    self.navigationController.navigationBar.translucent = NO;
    [self createNavigationBarItems];
    self.MyTableView.allowsSelectionDuringEditing=YES;

  fetchedResultsController = [self fetchedResultsController];
 //    [self creatmessagesTable];
 self.MyTableView.allowsSelectionDuringEditing=YES;
}




-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    isInRotate = YES;
}
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    isInRotate = NO;
}

-(void) createNavigationBarItems{
    ((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
    
 
    self.navigationItem.title = @"Messages";
    /////////////////////
    UIButton*  button =  [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* im = [UIImage imageNamed:@"seequButtonEdit.png"];
    UIImage* im1 = [UIImage imageNamed:@"seequButtonDone.png"];
    button.frame = CGRectMake(0, 0, im.size.width, im.size.height);
    [button setBackgroundImage:im forState:UIControlStateNormal];
    [button setBackgroundImage:im1 forState:UIControlStateSelected];
    [button addTarget:self action:@selector(onButtonEdit:) forControlEvents:UIControlEventTouchUpInside];
    self.editButton = button;
    
    UIBarButtonItem*  item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem =item;

    ///@todo levon from willappear ...  need to  test  befor delelte
//    self.navigationItem.title = @"Messages";
//    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
//        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView.messageBadgView SetText:nil];
//    }
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];

    if ([idoubs2AppDelegate sharedInstance].messageFromNotification) {
        SeequSendMessageViewController *sendMessageViewController = [[SeequSendMessageViewController alloc] initWithNibName:@"SeequSendMessageViewController" bundle:nil];
 
        sendMessageViewController.stringNavigationTitle = [idoubs2AppDelegate sharedInstance].messageNavigationTitle;
        sendMessageViewController.stringUserId = [idoubs2AppDelegate sharedInstance].pushMessageUserName;
        
        [Common RemoveMissedWithSeequID:[idoubs2AppDelegate sharedInstance].pushMessageUserName Type:2];
        [Common removeBadgeOnCurrentUser:[idoubs2AppDelegate sharedInstance].pushMessageUserName];
        ContactObject *object = [[ContactStorage sharedInstance] GetContactObjectBySeequId:[idoubs2AppDelegate sharedInstance].pushMessageUserName];
        sendMessageViewController.userImage = nil;
        if (object) {
            sendMessageViewController.userImage = object.image;
        }
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        CDMessageOwner* messageOwner = [[MessageCoreDataManager sharedManager] getMessageOwner:sendMessageViewController.stringUserId context:moc];
        UserInfoCoreData*  userInfo = [[ContactStorage sharedInstance] getUserInfoBySeequId:sendMessageViewController.stringUserId];
        if([messageOwner.isGroup boolValue] == YES){
            sendMessageViewController.stringNavigationTitle = messageOwner.name;
        } else {
            NSString*  str = [NSString stringWithFormat:@"Must be exist  qith  seequID = %@",sendMessageViewController.stringUserId];
            NSAssert(userInfo,str);
        }
        if (messageOwner == nil) {
            [[MessageCoreDataManager sharedManager] insertEmptyMessageOwner:sendMessageViewController.stringUserId  isGroup:NO object:userInfo];
            messageOwner =[[MessageCoreDataManager sharedManager] getMessageOwner:sendMessageViewController.stringUserId context:moc];
            NSAssert(messageOwner, @"Must  be created");
        }
        sendMessageViewController.messageOwner = messageOwner;
        sendMessageViewController.videoViewState = videoViewState;
        sendMessageViewController.needToScroll = YES;
        [self.navigationController pushViewController:sendMessageViewController animated:NO];
        return;
    }
    
    if ([idoubs2AppDelegate sharedInstance].ReplyWithMessageNumber) {
        SeequSendMessageViewController *sendMessageViewController = [[SeequSendMessageViewController alloc] initWithNibName:@"SeequSendMessageViewController" bundle:nil];
        sendMessageViewController.stringUserId = [idoubs2AppDelegate sharedInstance].ReplyWithMessageNumber;
       
        sendMessageViewController.stringNavigationTitle = [idoubs2AppDelegate sharedInstance].messageNavigationTitle;
        sendMessageViewController.stringUserId = [idoubs2AppDelegate sharedInstance].ReplyWithMessageNumber;
        sendMessageViewController.videoViewState = videoViewState;
        
        [Common RemoveMissedWithSeequID:[idoubs2AppDelegate sharedInstance].ReplyWithMessageNumber Type:2];
        ContactObject *object = [[ContactStorage sharedInstance] GetContactObjectBySeequId:[idoubs2AppDelegate sharedInstance].ReplyWithMessageNumber];
        sendMessageViewController.userImage = nil;
        if (object) {
            sendMessageViewController.userImage = object.image;
        }
        CDMessageOwner* messageOwner = [[MessageCoreDataManager sharedManager] getMessageOwner:sendMessageViewController.stringUserId context:moc];
        UserInfoCoreData*  userInfo = [[ContactStorage sharedInstance] getUserInfoBySeequId:sendMessageViewController.stringUserId];
        NSAssert(userInfo, @"Must be exist");
        if (messageOwner == nil) {
            [[MessageCoreDataManager sharedManager] insertEmptyMessageOwner:sendMessageViewController.stringUserId  isGroup:NO object:userInfo];
            messageOwner =[[MessageCoreDataManager sharedManager] getMessageOwner:sendMessageViewController.stringUserId context:moc];
            NSAssert(messageOwner, @"Must  be created");
        }
        sendMessageViewController.messageOwner = messageOwner;
        sendMessageViewController.needToScroll = YES;

        [self.navigationController pushViewController:sendMessageViewController animated:NO];
        return;
    }
    
    if ([idoubs2AppDelegate sharedInstance].messageFromActivity) {
        SeequSendMessageViewController *sendMessageViewController = [[SeequSendMessageViewController alloc] initWithNibName:@"SeequSendMessageViewController" bundle:nil];
        sendMessageViewController.stringUserId = [idoubs2AppDelegate sharedInstance].messageFromActivityTo;
        
        sendMessageViewController.stringNavigationTitle = [idoubs2AppDelegate sharedInstance].messageNavigationTitle;
        sendMessageViewController.stringUserId = [idoubs2AppDelegate sharedInstance].messageFromActivityTo;
        sendMessageViewController.videoViewState = videoViewState;
        
        [Common RemoveMissedWithSeequID:[idoubs2AppDelegate sharedInstance].messageFromActivityTo Type:2];
        [Common removeBadgeOnCurrentUser:[idoubs2AppDelegate sharedInstance].messageFromActivityTo];
   
        ContactObject *object = [[ContactStorage sharedInstance] GetContactObjectBySeequId:[idoubs2AppDelegate sharedInstance].messageFromActivityTo];
        
        sendMessageViewController.userImage = nil;
        if (object) {
            sendMessageViewController.userImage = object.image;
        }
        CDMessageOwner* messageOwner = [[MessageCoreDataManager sharedManager] getMessageOwner:sendMessageViewController.stringUserId context:moc];
        UserInfoCoreData*  userInfo = [[ContactStorage sharedInstance] getUserInfoBySeequId:sendMessageViewController.stringUserId];
        NSAssert(userInfo, @"Must be exist");
        if (messageOwner == nil) {
            [[MessageCoreDataManager sharedManager] insertEmptyMessageOwner:sendMessageViewController.stringUserId  isGroup:NO object:userInfo];
            messageOwner =[[MessageCoreDataManager sharedManager] getMessageOwner:sendMessageViewController.stringUserId context:moc];
            NSAssert(messageOwner, @"Must  be created");
        }
        sendMessageViewController.messageOwner = messageOwner;
        sendMessageViewController.needToScroll = YES;

        [self.navigationController pushViewController:sendMessageViewController animated:NO];
        return;
    }
    
    [self setVideoViewState:videoViewState Animated:YES];
}

- (void) onVideoViewChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    videoViewState = (VideoViewState)[eargs intValue];
    if (self.isViewLoaded && self.view.window) {
        [self setVideoViewState:videoViewState Animated:YES];

    }
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
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
//                [SearchBar setLength:([[UIScreen mainScreen] bounds].size.height - SMALL_VIDEO_HEIGHT*2) ShowCallButton:[[idoubs2AppDelegate sharedInstance].videoService isInCall]];
                SearchBar.isCallVisible = [[idoubs2AppDelegate sharedInstance].videoService isInCall];
            }
        }
            break;
        case VideoViewState_HIDE:
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            //    [SearchBar setLength:[[UIScreen mainScreen] bounds].size.height ShowCallButton:[[idoubs2AppDelegate sharedInstance].videoService isInCall]];
                SearchBar.isCallVisible = [[idoubs2AppDelegate sharedInstance].videoService isInCall];
            } else {
             //   [SearchBar setLength:[[UIScreen mainScreen] bounds].size.width ShowCallButton:NO];
                SearchBar.isCallVisible = NO;
            }
        default:
            break;
    }
    
//    [self UpdateInterfaceOrientation:self.interfaceOrientation];
    [self.view setNeedsLayout];

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
    
    call_type = (int)type;
}

- (void) onContactObjectImage:(NSNotification*)notification {
    [self.MyTableView reloadData];
}


- (void) creatmessagesTable {
    [NSThread detachNewThreadSelector:@selector(CreatMessageList) toTarget:self withObject:nil];
}


- (IBAction) onButtonEdit:(id)sender {
    ///@todo Gor when arrayFinish.count==0 stopping editing mod
    UIButton*  button = (UIButton*)sender;
    BOOL editing=!button.selected;
    if (fetchedResultsController.sections.count == 0) {
        editing=NO;
    }
    
    
    [button setSelected:editing];
//    [self UpdateEditButtonState:sender];
        [self.MyTableView setEditing:editing animated:YES];
    [self.MyTableView reloadData];
}

- (void) didClickOnCallButton:(SearchBarWithCallButton*)searchBar {
    if ([[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView setVideoState:VideoViewState_TAB_MENU Animation:YES];
    } else {
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView setVideoState:VideoViewState_NORMAL Animation:YES];
    }
}

- (IBAction) onButtonNewMessage:(id)sender {
    //    SeequNewMessageContactsViewController *viewController = [[SeequNewMessageContactsViewController alloc] initWithNibName:@"SeequNewMessageContactsViewController" bundle:nil];
    //    viewController.seequContactsDelegate = self;
    //    viewController.videoViewState = videoViewState;
    //    [self.tabBarController presentViewController:viewController animated:YES completion:nil];
    SeequEditGroupViewController *viewController = [[SeequEditGroupViewController alloc] init];
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:viewController];
    viewController.delegate = self;
    [self.tabBarController presentViewController:nc animated:YES completion:^{
    }];
}

-(void) didEditGroup:(SeequGroupInfo *)group new:(BOOL)flag {
  //  [groups addObject:group];
    SeequSendMessageViewController *sendMessageViewController = nil;
    CDMessageOwner* owner = nil;
    CDGroup* cdGroup = nil;
    UserInfoCoreData* userInfo= nil;
    BOOL isGroup = group.members.count >1;
    NSString*  ownerId = isGroup?group.groupID:[group.members objectAtIndex:0];
    NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];

    if (!isGroup) {
        owner = [[MessageCoreDataManager sharedManager] getMessageOwner:[group.members objectAtIndex:0] context:moc];
        userInfo = [[ContactStorage sharedInstance] getUserInfoBySeequId:[group.members objectAtIndex:0]];
        NSAssert(userInfo, @"must be exist");
    } else {
        cdGroup = [[MessageCoreDataManager sharedManager] getGroupByGroupId:group.groupID];
        NSAssert(cdGroup, @"Must be exist");
        owner = [[MessageCoreDataManager sharedManager] getMessageOwner:group.groupID context:moc];
    }
    
    if (owner == nil) {
        id obj  = nil;
        if (isGroup) {
            obj = cdGroup;
        } else {
            obj =  userInfo;
        }
        
        [[MessageCoreDataManager sharedManager] insertEmptyMessageOwner:ownerId  isGroup:group.members.count>1 object:obj];
        owner =[[MessageCoreDataManager sharedManager] getMessageOwner:ownerId context:moc];
        NSAssert(owner, @"Must  be created");
    }
    sendMessageViewController = [[SeequSendMessageViewController alloc] initWithNibName:@"SeequSendMessageViewController" bundle:nil];
    sendMessageViewController.messageOwner = owner;
    sendMessageViewController.videoViewState = videoViewState;
    if(isGroup) {
        
        sendMessageViewController.groupInfo = group;
        sendMessageViewController.stringNavigationTitle = group.name;
        sendMessageViewController.videoViewState = videoViewState;
        sendMessageViewController.stringUserId = group.groupID;

    } else {
        NSAssert(group.members.count == 1, @"Must be only  one  member");
        
        sendMessageViewController.stringUserId = [group.members objectAtIndex:0];
        ContactObject* contactObj = [[ContactStorage sharedInstance] GetContactObjectBySeequId:[group.members objectAtIndex:0]];
        sendMessageViewController.stringNavigationTitle = group.name;

        sendMessageViewController.userImage = [contactObj.image copy];
    }
    
    [self.navigationController pushViewController:sendMessageViewController animated:YES];
    
    
  
}

- (void) UpdateEditButtonState:(id)sender {
    UIButton*  button = (UIButton*)sender;
    [button setSelected:!button.selected];
 }

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [fetchedResultsController.sections count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo>sectionInfo=[fetchedResultsController.sections objectAtIndex:section];
    return sectionInfo.numberOfObjects;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"SeequMessagesCell";
    
    SeequMessagesCell *cell = (SeequMessagesCell*)[tableView dequeueReusableCellWithIdentifier: identifier];
    CDMessageOwner *obj=[fetchedResultsController objectAtIndexPath:indexPath];
    cell.editable = self.MyTableView.isEditing;
    [cell updateCellInfo:obj];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
//    
//    if (segmentControl.selectedIndex == 1) {
//            return NO;
//    }
    
    return YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    CDMessageOwner* messageOwner = [fetchedResultsController objectAtIndexPath:indexPath];
    
    SeequSendMessageViewController *sendMessageViewController = [[SeequSendMessageViewController alloc] initWithNibName:@"SeequSendMessageViewController" bundle:nil];
    sendMessageViewController.stringUserId = messageOwner.seequId;
    sendMessageViewController.stringNavigationTitle = messageOwner.name;
    ContactObject *object = [Common getContactObjectWithSeequID:messageOwner.seequId];
     sendMessageViewController.userImage = [object.image copy];
     sendMessageViewController.videoViewState = videoViewState;
    sendMessageViewController.messageOwner = messageOwner;
     sendMessageViewController.callType = call_type;
    [self.navigationController pushViewController:sendMessageViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 62;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.MyTableView.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CDMessageOwner* messageOwner = [fetchedResultsController objectAtIndexPath:indexPath];
        if (messageOwner.groupInfo) {
            if ([messageOwner.groupInfo.groupOwner.seeQuId isEqualToString:[Common sharedCommon].contactObject.SeequID]) {
                [[RTMPChatManager sharedRTMPManager] destroyGroups:[NSArray arrayWithObject:messageOwner.seequId]];

            } else {
                [[RTMPChatManager sharedRTMPManager] leaveGroup:messageOwner.seequId];

            }
        }
        [[MessageCoreDataManager sharedManager] deleteMessageOwner:messageOwner];
        int badgeCount = [Common getCurrentUserBadgeValue:messageOwner.seequId];
        if (badgeCount > 0) {
            [Common RemoveMissedWithSeequID:messageOwner.seequId Type:2];
            [Common removeBadgeOnCurrentUser:messageOwner.seequId];
        }
        
//        if (segmentControl.selectedIndex == 0) {
//            MessageItem *item = [arrayFinish objectAtIndex:indexPath.row];
// //           if (item.badge>0) {
//                [Common RemoveMissedWithSeequID:item.contactID Type:2];
// //               item.badge = 0;
//                [Common removeBadgeOnCurrentUser:item.contactID];
////            }
//            [arrayFinish removeObjectAtIndex:indexPath.row];
//            @synchronized (self) {
//                [arraySearch removeObjectAtIndex:indexPath.row];
//            }
//            [self.MyTableView reloadData];
//            [[idoubs2AppDelegate sharedInstance].sqliteService deleteMessagesWithSeequID:item.contactID];
//            
//            if (!arrayFinish.count) {
//                [self.editButton setSelected:NO];
//                
//                [self.MyTableView setEditing:NO animated:YES];
//                [self.MyTableView reloadData];
//            }

//        } else {
//            SeequGroupInfo* info = [groups objectAtIndex:indexPath.row];
//            [[idoubs2AppDelegate sharedInstance].sqliteService removeGroup:info.groupID];
//            [[RTMPChatManager sharedRTMPManager] destroyGroups:[NSArray arrayWithObject:info.groupID]];
//            [groups removeObject:info];
//        }
    }
    [self.MyTableView reloadData];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [SearchBar hideKeyboard];
}

#pragma mark -
#pragma mark SearchBarWithCallButton Delegate Methods
#pragma mark -

- (void) didChangeSearchText:(SearchBarWithCallButton*)searchBar SearchText:(NSString*)text {
   
    NSError *error;
    if (text && [text length]) {
 
        NSPredicate* predicate=[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@",text];
        [fetchedResultsController.fetchRequest setPredicate:predicate];
    } else {
        [fetchedResultsController.fetchRequest setPredicate:nil];
    }
    [fetchedResultsController performFetch:&error];
    [self.MyTableView reloadData];


}

- (NSMutableArray*) ArrayWithSearchText:(NSString*)text {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSString *text_ = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    @synchronized (self) {
        if (text_ && [text_ length]) {
            for (MessageItem *obj in arraySearch) {
                NSComparisonResult result = [obj.firstName compare:text_ options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [text_ length])];
                if (result == NSOrderedSame) {
                    [array addObject:obj];
                } else {
                    NSComparisonResult result = [obj.lastName compare:text_ options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [text_ length])];
                    if (result == NSOrderedSame) {
                        [array addObject:obj];
                    } else {
                        NSString *firstAndLastName = [NSString stringWithFormat:@"%@ %@",obj.firstName, obj.lastName];
                        NSComparisonResult result = [firstAndLastName compare:text options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [text length])];
                        if (result == NSOrderedSame) {
                            [array addObject:obj];
                        }
                    }
                }
            }
        } else {
            return arraySearch;
        }
    }
    
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
    NSArray * sortedArray = [array sortedArrayUsingDescriptors:descriptors];
    
    return [NSMutableArray arrayWithArray:sortedArray];
}

///@todo levon UpdateInterfaceOrientation needs  to be elimintated and  ALL  layout changes  have  to  be implemented  ONLY in  ***layoutSubviews metods
-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.MyTableView reloadData];

}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.MyTableView reloadData];
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SearchBar hideKeyboard];
}

-(void) viewWillLayoutSubviews{
 
    [super viewWillLayoutSubviews];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
   
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if ([[idoubs2AppDelegate sharedInstance].videoService isInCall] &&(videoViewState != VideoViewState_HIDE &&videoViewState != VideoViewState_PREVIEW) && [[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
           
            [SearchBar setLength:([[UIScreen mainScreen] bounds].size.height - SMALL_VIDEO_HEIGHT*2) ShowCallButton:[[idoubs2AppDelegate sharedInstance].videoService isInCall]];
            self.navigationController.navigationBar.frame = CGRectMake(SMALL_VIDEO_HEIGHT, self.navigationController.navigationBar.frame.origin.y, [[UIScreen mainScreen] bounds].size.height - SMALL_VIDEO_HEIGHT*2, self.navigationController.navigationBar.frame.size.height);

        } else {
            //[SearchBar setLength:[[UIScreen mainScreen] bounds].size.height ShowCallButton:[[idoubs2AppDelegate sharedInstance].videoService isInCall]];
            SearchBar.isCallVisible =[[idoubs2AppDelegate sharedInstance].videoService isInCall];
        }
    } else {
      //  [SearchBar setLength:[[UIScreen mainScreen] bounds].size.width ShowCallButton:[[idoubs2AppDelegate sharedInstance].videoService isInCall]];
        SearchBar.isCallVisible = NO;
    }
    [self UpdateInterfaceOrientation:orientation];
 
    
//    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
//        self.hidesBottomBarWhenPushed = YES;
//    } else {
//        self.hidesBottomBarWhenPushed = NO;
//    }




}
//
///@todo workarround needs  to be solved, but in case of  strange  call  of  view appearance  need to exist
-(CGFloat) calculateOffset{
//    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall] && videoViewState == VideoViewState_HIDE && isInRotate && !IS_IOS_7 && ![UIApplication sharedApplication].statusBarHidden)
//    {
//        return 46;
//        
//    }
    return 0;
}

- (void) UpdateInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   // [self.MyTableView reloadData];
   
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        CGSize result = [[UIScreen mainScreen] bounds].size;

        if ([[idoubs2AppDelegate sharedInstance].videoService isInCall] &&(videoViewState != VideoViewState_HIDE &&videoViewState != VideoViewState_PREVIEW) && [[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
            self.navigationController.navigationBar.frame = CGRectMake(SMALL_VIDEO_HEIGHT, 0, result.height - SMALL_VIDEO_HEIGHT*2, self.navigationController.navigationBar.frame.size.height);
            self.MyTableView.frame = CGRectMake(SMALL_VIDEO_HEIGHT, [self calculateOffset] , self.view.frame.size.width - SMALL_VIDEO_HEIGHT*2, self.view.frame.size.height );
            self.imageViewTitle.frame = CGRectMake(self.navigationController.navigationBar.frame.size.width/2 - self.imageViewTitle.image.size.width/2,
                                                   self.navigationController.navigationBar.frame.size.height/2 - self.imageViewTitle.image.size.height/2,
                                                   self.imageViewTitle.image.size.width, self.imageViewTitle.image.size.height);
        } else {
            self.navigationController.navigationBar.frame = CGRectMake(0,self.navigationController.navigationBar.frame.origin.y, result.height, self.navigationController.navigationBar.frame.size.height);
            self.MyTableView.frame = CGRectMake(0, [self calculateOffset] , self.view.frame.size.width, self.view.frame.size.height );
            self.imageViewTitle.frame = CGRectMake(self.navigationController.navigationBar.frame.size.width/2 - self.imageViewTitle.image.size.width/2,
                                                   self.navigationController.navigationBar.frame.size.height/2 - self.imageViewTitle.image.size.height/2,
                                                   self.imageViewTitle.image.size.width, self.imageViewTitle.image.size.height);
        }
        
        self.buttonNewMessage.frame = CGRectMake(self.navigationController.navigationBar.frame.size.width - 45, 7, 37, 31);
    } else {
        self.navigationController.navigationBar.frame = CGRectMake(0, self.navigationController.navigationBar.frame.origin.y, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height);
        int state = videoViewState;
        if (![[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
            state = VideoViewState_HIDE;
        }
        
        int diff = 0;
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 568) {
            diff = 88;
        }
//  JSC      CGFloat delta = IS_IOS_7? 46:0;///@todo workarround Gor ios7/ios6
        CGFloat delta = 46;
        CGRect frame;
        if (state == VideoViewState_TAB) {
            frame = CGRectMake(0, self.view.frame.size.height - 271 - diff-delta, 320, self.view.frame.size.height - (self.view.frame.size.height - 271 - diff));
//              self.MyTableView.frame = frame;
        } else {
            if (state == VideoViewState_TAB_MENU) {
                frame = CGRectMake(0, self.view.frame.size.height - 179 - diff-delta, 320, self.view.frame.size.height - (self.view.frame.size.height - 179 - diff));
//                  self.MyTableView.frame = frame;
            } else {
                frame  = CGRectMake(0, [self calculateOffset], self.view.frame.size.width, self.view.frame.size.height -[self calculateOffset]);
//                self.MyTableView.frame = frame;
            }
        }
        CGRect tableFrame = CGRectMake(frame.origin.x , frame.origin.y , frame.size.width, frame.size.height );

        [UIView beginAnimations:@"tableFrame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3];
        
        self.MyTableView.frame = tableFrame;
        [UIView commitAnimations];
        
        self.navigationController.navigationBarHidden = NO;

        [SearchBar setLength:SearchBar.frame.size.width ShowCallButton:NO];
    }
    
    [self UpdateEditButtonState:self.buttonEdit];
}

- (void) didSendMessage:(SeequNewMessageViewController*)controller Contact:(ContactObject*)contactObject {
    [controller dismissViewControllerAnimated:NO completion:NO];
    
    SeequSendMessageViewController *sendMessageViewController = [[SeequSendMessageViewController alloc] initWithNibName:@"SeequSendMessageViewController" bundle:nil];
    sendMessageViewController.stringUserId = contactObject.SeequID;
    
    sendMessageViewController.stringUserId = contactObject.SeequID;
    sendMessageViewController.stringNavigationTitle = contactObject.displayName;
    sendMessageViewController.userImage = contactObject.image;
    sendMessageViewController.videoViewState = videoViewState;

    [self.navigationController pushViewController:sendMessageViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) didSelectContact:(SeequNewMessageContactsViewController *)controller Contact:(ContactObject *)contactObject {
    [controller dismissViewControllerAnimated:NO completion:NO];
    
    SeequSendMessageViewController *sendMessageViewController = [[SeequSendMessageViewController alloc] initWithNibName:@"SeequSendMessageViewController" bundle:nil];
    sendMessageViewController.stringUserId = contactObject.SeequID;
    sendMessageViewController.stringUserId = contactObject.SeequID;
    sendMessageViewController.stringNavigationTitle = contactObject.displayName;
    sendMessageViewController.userImage = contactObject.image;
    sendMessageViewController.videoViewState = videoViewState;

    [self.navigationController pushViewController:sendMessageViewController animated:YES];
}

- (void)viewDidUnload {
    [self setMyTableView:nil];
    [self setButtonEdit:nil];
    [self setImageViewTitle:nil];
    [self setButtonNewMessage:nil];
    [super viewDidUnload];
}


#pragma mark NSFetchedResultsController Delegate
- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSManagedObjectContext* mContext = [CoreDataManager managedObjectContext];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"CDMessageOwner"
												  inManagedObjectContext:mContext];
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"lastDate" ascending:NO];
        
        NSArray *sortDescriptors = @[sd1];
        NSPredicate* predicate=[NSPredicate predicateWithFormat:@"messages.@count !=0 || isGroup != 0"];
        [fetchRequest setPredicate:predicate];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
        
		NSError *error = nil;
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:mContext
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil];
		[fetchedResultsController setDelegate:self];
        
		
		if (![fetchedResultsController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
	}
	
	return fetchedResultsController;
}
//#endif XMPP_ON

- (void) setFetchedResultsController:(NSFetchedResultsController *)fetched {
    fetchedResultsController = fetched;
    fetchedResultsController.delegate  = self;
}


-(void) updateLastMessage:(CDMessageOwner*)anObject {
    [[MessageCoreDataManager sharedManager] updateMessageOwnerLastMessage:anObject];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.MyTableView;
    
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
        {
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            [self updateLastMessage:(CDMessageOwner*)anObject];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.MyTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.MyTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.MyTableView beginUpdates];
}
-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.MyTableView endUpdates];
    [self.MyTableView reloadData];
}
@end
