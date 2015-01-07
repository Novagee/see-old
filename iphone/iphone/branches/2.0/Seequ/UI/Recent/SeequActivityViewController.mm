//
//  SeequActivityViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/12/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//
#import "ActivityStorage.h"
#import "SeequActivityCell.h"
#import "SeequActivityViewController.h"
#import "SeequContactsViewController.h"
#import "SeequContactProfileViewController.h"
#import "idoubs2AppDelegate.h"
#import "NavigationBar.h"
#import "BackBarButton.h"
#import "Common.h"
#import <AudioToolbox/AudioToolbox.h>


@interface SeequActivityViewController ()

@end

@implementation SeequActivityViewController

@synthesize videoViewState;
@synthesize fetchedController=_fetchedController;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewOrientationChange:) name:kVideoViewOrientationChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRequestEvent:) name:@"REQUEST" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecentEvent) name:@"Recent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"Refresh" object:nil];
    
    arrayRequests = nil;
    arrayRecents = nil;
    xmppRoster = nil;
    lastRequestsSyncTime = [[ActivityStorage sharedInstance] getLastRequestTime];
    lastRecentsSyncTime = [[ActivityStorage sharedInstance] getLastCallTime];
    isOnThread_Recent = NO;
    isOnThread_Requests = NO;
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void) initXMPPRoster {
    if (!arrayRequests) {
        arrayRequests = [[NSMutableArray alloc] init];
    }
    
    if (!xmppRoster) {
        xmppRoster = [[XMPPRoster alloc] initWithStream:[[[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] XMPPHandler] xmppStream] rosterStorage:self];
        [xmppRoster addDelegate:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
 [self.MyTableView registerClass:[SeequActivityCell class] forCellReuseIdentifier:@"SeequActivityCell"];
        _fetchedController=[self getFetchedResultsController];
    [self onButtonFilter:self.buttonAll];

	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.MyTableView.bounds.size.height, self.view.frame.size.width, self.MyTableView.bounds.size.height)];
		view.delegate = self;
		[self.MyTableView addSubview:view];
		_refreshHeaderView = view;
	}
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleActivity.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];

    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"seequButtonClear.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(onButtonClear:)];
    
    self.navigationItem.rightBarButtonItem = backBarButton;
    [self setPredicateForSegmentType];
    [self refresh];
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
    ///@todo Gor needs to change hard codeid numbers to get width/height and define  
    int diff =[[UIScreen mainScreen] bounds].size.height==568?88:0;
    //    int diff = 0;
//    CGSize result = [[UIScreen mainScreen] bounds].size;
//    if(result.height == 568) {
//        diff = 88;
//    }

    
    CGRect frame = CGRectZero;
    switch (state) {
        case VideoViewState_NONE:
        case VideoViewState_NORMAL:
        case VideoViewState_NORMAL_MENU:
        case VideoViewState_HIDE: {
            frame = CGRectMake(0, 33, 320, self.view.frame.size.height - 33);
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
- (NSFetchedResultsController *)getFetchedResultsController
{
	if (_fetchedController == nil) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSManagedObjectContext* mContext = [CoreDataManager managedObjectContextForMainThread];
		NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([ActivityCoreData class])
                                                          inManagedObjectContext:mContext];
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:NO];
//                NSPredicate *predicate=[NSPredicate predicateWithFormat:@"status.subscription=%@",@"both"];
      		NSArray *sortDescriptors = @[sd1];
                
		[fetchRequest setEntity:entity];
//                [fetchRequest setPredicate:predicate];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
                
		NSError *error = nil;
                _fetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                         managedObjectContext:mContext
                                                                           sectionNameKeyPath:nil
                                                                                    cacheName:nil];
		[_fetchedController setDelegate:self];
                
		
		if (![_fetchedController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
	}
	
	return _fetchedController;
}
-(void)setPredicateForSegmentType{
        NSPredicate *predicate;
        NSError *error;
        switch (segmentType) {
                case Activity_Segment_Type_All:{
                        predicate=nil;
                
                }
                        break;
                case Activity_Segment_Type_Recent:{
                        predicate=[NSPredicate predicateWithFormat:@"type=%@",@"callLog"];
                }
                        break;
                case Activity_Segment_Type_Requests:{
                        predicate=[NSPredicate predicateWithFormat:@"type=%@",@"request"];
                }
                        break;
                default:
                        break;
        }
        [_fetchedController.fetchRequest setPredicate:predicate];
        [_fetchedController performFetch:&error];
        [self.MyTableView reloadData];
        
}
- (void) onContactObjectUpdateEvent:(NSNotification*)notification {
    ContactObject* eargs = [notification object];
    BOOL have_change = NO;
    
    if (eargs) {
        for (ContactObject *object in arrayRecents) {
            if ([object.SeequID isEqualToString:eargs.SeequID]) {
                [Common TransferContactInformation:eargs To:object];
                have_change = YES;
            }
        }

        for (ContactObject *object in arrayRequests) {
            if ([object.SeequID isEqualToString:eargs.SeequID]) {
                [Common TransferContactInformation:eargs To:object];
                have_change = YES;
            }
        }
    }

    if (have_change) {
        [self.MyTableView reloadData];
    }
}
//-(void) setMissedCallCount {
//}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
  
//  if (badgCount != -1) {
//    [self performSelectorInBackground:@selector(setMissedCallCount) withObject:nil];
//        int badgCount = [self CalculateBadgCount];
//        [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(SetRecentTabBadgValue:) withObject:[NSString stringWithFormat:@"%d", badgCount] waitUntilDone:YES];
////    }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[ActivityStorage sharedInstance] updateCallsStatus];
                [[idoubs2AppDelegate sharedInstance] performSelectorInBackground:@selector(updateBadge) withObject:nil ];
        });
        

}

- (void) refresh {
    if (!isOnThread_Recent) {
        isOnThread_Recent = YES;
        [NSThread detachNewThreadSelector:@selector(StartDownloadRecents)
                                 toTarget:self
                               withObject:nil];
    }
    
    if (!isOnThread_Requests) {
        isOnThread_Requests = YES;
            [NSThread detachNewThreadSelector:@selector(StartDownloadRequests)
                                     toTarget:self
                                   withObject:nil];
    }
}

- (void) onRequestEvent:(NSNotification*)notification {
//    NSDictionary *dict = [notification object];
//    if (dict && [dict objectForKey:@"type"] && [[dict objectForKey:@"type"] isKindOfClass:[NSString class]]) {
        if (!isOnThread_Requests) {
            isOnThread_Requests = YES;
                [NSThread detachNewThreadSelector:@selector(StartDownloadRequests)
                                         toTarget:self
                                       withObject:nil];
        }
//    }
}
-(void)onRecentEvent{
        if (!isOnThread_Recent) {
                isOnThread_Recent = YES;
                [NSThread detachNewThreadSelector:@selector(StartDownloadRecents)
                                         toTarget:self
                                       withObject:nil];
        }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMyTableView:nil];
    [self setButtonAll:nil];
    [self setButtonRecent:nil];
    [self setButtonRequests:nil];
    [super viewDidUnload];
}

- (IBAction)onButtonFilter:(id)sender {
    UIButton *button = (UIButton*)sender;
    
    switch (button.tag) {
        case 1: {
            segmentType = Activity_Segment_Type_All;
            [self.buttonAll setBackgroundImage:[UIImage imageNamed:@"segActivityAllSel.png"] forState:UIControlStateNormal];
            [self.ButtonRecent setBackgroundImage:[UIImage imageNamed:@"segActivityCalls.png"] forState:UIControlStateNormal];
            [self.ButtonRequests setBackgroundImage:[UIImage imageNamed:@"segActivityRequests.png"] forState:UIControlStateNormal];
        }
            break;
        case 2: {
            segmentType = Activity_Segment_Type_Recent;
            [self.buttonAll setBackgroundImage:[UIImage imageNamed:@"segActivityAll.png"] forState:UIControlStateNormal];
            [self.ButtonRecent setBackgroundImage:[UIImage imageNamed:@"segActivityCallsSel.png"] forState:UIControlStateNormal];
            [self.ButtonRequests setBackgroundImage:[UIImage imageNamed:@"segActivityRequests.png"] forState:UIControlStateNormal];
        }
            break;
        case 3: {
            segmentType = Activity_Segment_Type_Requests;
            [self.buttonAll setBackgroundImage:[UIImage imageNamed:@"segActivityAll.png"] forState:UIControlStateNormal];
            [self.ButtonRecent setBackgroundImage:[UIImage imageNamed:@"segActivityCalls.png"] forState:UIControlStateNormal];
            [self.ButtonRequests setBackgroundImage:[UIImage imageNamed:@"segActivityRequestsSel.png"] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    
//    [self filterContactsWithSegment_Type:segmentType];
        [self setPredicateForSegmentType];
//    int badgCount = [self CalculateBadgCount];
//    if (badgCount != -1) {
//        [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(SetRecentTabBadgValue:) withObject:[NSString stringWithFormat:@"%d", badgCount] waitUntilDone:YES];
//    }
}

- (void)onButtonClear:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Clear History"
                                              otherButtonTitles:nil];
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Clearing..."];
        [NSThread detachNewThreadSelector:@selector(CLearAllActivitys) toTarget:self withObject:nil];
    }
}

- (void) CLearAllActivitys {
    NSString *error_message = [Common CleareAllActivitys];
    
    if (error_message) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
            [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(ShowDefaultMessageWithText:) withObject:error_message waitUntilDone:YES];
        }
    } else {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kREQUESTS"];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kRECENTS"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        [arrayRequests removeAllObjects];
//        [arrayRecents removeAllObjects];
            [[ActivityStorage sharedInstance] deleteActivityFromStorage];
        
        [self.MyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(SetRecentTabBadgValue:) withObject:nil waitUntilDone:YES];
        
    }
    
    [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(HideLoadingView) withObject:nil waitUntilDone:YES];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Number of rows it should expect should be based on the section

        id<NSFetchedResultsSectionInfo>sectionInfo=[_fetchedController.sections objectAtIndex:section];
        return sectionInfo.numberOfObjects;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        return nil;

}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SeequActivityCell";
    SeequActivityCell *cell=[[SeequActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    ContactObject *obj;
        ActivityCoreData *activity=[_fetchedController objectAtIndexPath:indexPath];
        obj=[ActivityStorage contactObjectFromActivityStorage:activity];
    [cell updateCell:obj];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactObject *obj;

        ActivityCoreData *activity=[_fetchedController objectAtIndexPath:indexPath];
        obj=[ActivityStorage contactObjectFromActivityStorage:activity];

    if (obj.isRecent) {
        SeequContactProfileViewController *profileViewController = [[SeequContactProfileViewController alloc] initWithNibName:@"SeequContactProfileViewController" bundle:nil];
        profileViewController.contactObj =[[ContactStorage sharedInstance] GetContactObjectBySeequId:obj.SeequID];
        profileViewController.videoViewState = self.videoViewState;
        profileViewController.accessToConnections = YES;
        [self.navigationController pushViewController:profileViewController animated:YES];
    } else {
        if (obj.requestStatus == Request_Status_Ringback ||
            obj.requestStatus == Request_Status_Review ||
            obj.requestStatus == Request_Status_Connection ||
            obj.requestStatus == Request_Status_Recived_Connection_Accepted ||
            obj.requestStatus == Request_Status_Recived_Connection_Declined ||
            obj.requestStatus == Request_Status_Recived_Review_Accepted ||
            obj.requestStatus == Request_Status_Recived_Review_Declined ||
            obj.requestStatus == Request_Status_Recived_Ringback_Accepted ||
            obj.requestStatus == Request_Status_Recived_Ringback_Declined) {
            SeequRequestViewController *reqViewController = [[SeequRequestViewController alloc] initWithNibName:@"SeequRequestViewController" bundle:nil];
            reqViewController.delegate = self;
            reqViewController.contactObj = obj;
            reqViewController.videoViewState = self.videoViewState;
            [self.navigationController pushViewController:reqViewController animated:YES];
        } else {
            if (obj.requestStatus == Request_Status_For_Connection ||
                obj.requestStatus == Request_Status_For_Ringback ||
                obj.requestStatus == Request_Status_For_Review ||
                obj.requestStatus == Request_Status_Connection_Accepted ||
                obj.requestStatus == Request_Status_Review_Accepted ||
                obj.requestStatus == Request_Status_Ringback_Accepted ||
                obj.requestStatus == Request_Status_Connection_Declined ||
                obj.requestStatus == Request_Status_Review_Declined ||
                obj.requestStatus == Request_Status_Ringback_Declined)
            {
                SeequContactProfileViewController *controller = [[SeequContactProfileViewController alloc] initWithNibName:@"SeequContactProfileViewController" bundle:nil];
                controller.contactObj =[[ContactStorage sharedInstance] GetContactObjectBySeequId:obj.SeequID];;
                controller.videoViewState = self.videoViewState;
                controller.accessToConnections = YES;
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
    }
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
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

    NSLog (@"presence.fromStr: %@", presence.fromStr);
    NSLog (@"presence.from.user: %@", presence.from.user);
    
    if (!isOnThread_Requests) { //  && [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex == 3
        isOnThread_Requests = YES;
        [NSThread detachNewThreadSelector:@selector(StartDownloadRequests)
                                 toTarget:self
                               withObject:nil];
    }
}

#pragma NSFetchedResultsController delegate
//-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
//        [self.MyTableView performSelectorOnMainThread:@selector(beginUpdates) withObject:nil waitUntilDone:YES];
//}
//
//-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
//        switch (type) {
//                 case NSFetchedResultsChangeInsert:{
//                         [self.MyTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//                }
//                        break;
//                case NSFetchedResultsChangeDelete:{
//                        [self.MyTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//                }
//                        break;
//                default:
//                        break;
//        }
//        
//        
//        
//}
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
        @synchronized(self.MyTableView)
        {
                [self.MyTableView reloadData];
        }

}
#pragma mark ContactObject Delegate


- (void) didGetUserInfo:(ContactObject *)contactsObj withDict:(NSDictionary *)dict {
    
    ContactObject *obj = [[ContactStorage sharedInstance] GetContactObjectBySeequId:contactsObj.SeequID];
    if (obj) {
        contactsObj.contactType = obj.contactType;
    }

}

#pragma mark ContactObject Delegate


//- (void) didGetUserInfo:(ContactObject *)contactsObj withDict:(NSDictionary *)dict {
//    UINavigationController *nav = [[idoubs2AppDelegate sharedInstance].tabBarController.viewControllers objectAtIndex:0];
//    SeequContactsViewController *controller = [nav.viewControllers objectAtIndex:0];
//    
//    ContactObject *obj = [controller CheckObjectInArrayWithPT:contactsObj.SeequID];
//    if (obj) {
//        contactsObj.contactType = obj.contactType;
//        return;
//    }
//}
//
//- (void) didGetUserImage:(ContactObject*)contactsObj Image:(UIImage*)image {
//    switch (contactsObj.contactType) {
//        case Contact_Type_Seequ_Contact: {
//        }
//            break;
//        case Contact_Type_Recent: {
//            if (segmentType == Activity_Segment_Type_Recent) {
//                [self SetRecentImageWithContactObject:contactsObj];
//            }
//        }
//            break;
//        case Contact_Type_Request_Connection: {
//            if (segmentType == Activity_Segment_Type_Requests) {
//                [self SetRequestImageWithContactObject:contactsObj];
//            }
//        }
//            break;
//        default:
//            break;
//    }
//}
//
//- (ContactObject*) CheckObjectInRequestsArray:(ContactObject*)obj {
//    for (ContactObject *obj_ in arrayRequests) {
//        if (obj == obj_) {
//            return obj;
//        }
//    }
//    
//    return nil;
//}
//
//- (ContactObject*) CheckObjectInRequestsArrayWithContactObject:(ContactObject*)contactObj {
//    for (ContactObject *obj in arrayRequests) {
//        if ([obj.SeequID isEqualToString:contactObj.SeequID] && obj.contactType == contactObj.contactType) {
//            return obj;
//        }
//    }
//    
//    return nil;
//}
//
//- (void) SetSeequContactImageWithPT:(NSString*)seequID {
//    
//}
//
//- (void) SetRecentImageWithPT:(NSString*)seequID {
//    
//}
//
//- (void) SetRecentImageWithContactObject:(ContactObject*)contactsObj {
//    NSInteger row = 0;
//    NSIndexPath *indexPath = nil;
//    for (ContactObject *obj in arrayRecents) {
//        if ([obj.SeequID isEqualToString:contactsObj.SeequID]) {
//            indexPath = [NSIndexPath indexPathForRow:row inSection:0];
//            
//            break;
//        }
//        row++;
//    }
//    
//    if (indexPath) {
//        UITableViewCell *cell = [self.MyTableView cellForRowAtIndexPath:indexPath];
//        if (cell) {
//            if (contactsObj.image) {
//                cell.imageView.image = contactsObj.image;
//                [self.MyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
//            } else {
//                cell.imageView.image = [UIImage imageNamed:@"GenericContact.png"];
//            }
//        }
//    }
//}

//- (void) SetRequestImageWithContactObject:(ContactObject*)contactsObj {
//    NSInteger row = 0;
//    NSIndexPath *indexPath = nil;
//    for (ContactObject *obj in arrayRequests) {
//        if ([obj.SeequID isEqualToString:contactsObj.SeequID]) {
//            indexPath = [NSIndexPath indexPathForRow:row inSection:0];
//            
//            break;
//        }
//        row++;
//    }
//    
//    if (indexPath) {
//        UITableViewCell *cell = [self.MyTableView cellForRowAtIndexPath:indexPath];
//        if (cell) {
//            if (contactsObj.image) {
//                cell.imageView.image = contactsObj.image;
//                [self.MyTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
//            } else {
//                cell.imageView.image = [UIImage imageNamed:@"GenericContact.png"];
//            }
//        }
//    }
//}

#pragma mark SeequConnectionRequestDelegate methods

- (void) SeequConnectionRequest:(SeequRequestViewController*)controller didAcceptWithContactObject:(ContactObject*)contactObj {
    if (controller.contactObj.requestStatus == Request_Status_Review) {
        SeequWriteAReviewViewController *reviewViewController = [[SeequWriteAReviewViewController alloc] initWithNibName:@"SeequWriteAReviewViewController" bundle:nil];
        reviewViewController.delegate = self;
        reviewViewController.contactObj = contactObj;
        reviewViewController.videoViewState = videoViewState;
        [self.tabBarController presentViewController:reviewViewController animated:YES completion:nil];
        
        return;
    }

    [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Processing..."];
    
    requestViewController = controller;
    requestContactObject = contactObj;
    
    [NSThread detachNewThreadSelector:@selector(AcceptRequestAsynchronously) toTarget:self withObject:nil];
    
    return;
    
//    if (controller.contactObj.requestStatus == Request_Status_Review) {
//        SeequWriteAReviewViewController *reviewViewController = [[SeequWriteAReviewViewController alloc] initWithNibName:@"SeequWriteAReviewViewController" bundle:nil];
//        reviewViewController.delegate = self;
//        reviewViewController.contactObj = contactObj;
//        reviewViewController.videoViewState = videoViewState;
//        [self.tabBarController presentModalViewController:reviewViewController animated:YES];
//        
//        return;
//    }
//    
//    NSString *error_message = [Common UpdateRequestWithID:controller.contactObj.ID
//                                                     Date:[[NSDate date] timeIntervalSince1970]
//                                                   Status:@"Accepted"];
//
//    if (error_message) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
//                                                        message:error_message
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        
//        [alert show];
//        [self.navigationController popToRootViewControllerAnimated:YES];
//        
//        return;
//    }
//    
//    NSDictionary *push_dict = nil;
//    switch (controller.contactObj.requestStatus) {
//        case Request_Status_Ringback: {
//            [self ChangeContactObjectsRequestStatus:controller.contactObj RequestStatus:Request_Status_Recived_Ringback_Accepted];
//            [[idoubs2AppDelegate sharedInstance].videoService CallWithContactObject:controller.contactObj Video:YES];
//            push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:controller.contactObj.SeequID, @"SeequID",
//                         [NSString stringWithFormat:@"%@ %@ accepted your request to Ringback.", controller.contactObj.FirstName, controller.contactObj.LastName], @"message",
//                         @"Ringback", @"status", nil];
//        }
//            break;
//        case Request_Status_Review: {
//            [self ChangeContactObjectsRequestStatus:controller.contactObj RequestStatus:Request_Status_Recived_Review_Accepted];
//            SeequWriteAReviewViewController *reviewViewController = [[SeequWriteAReviewViewController alloc] initWithNibName:@"SeequWriteAReviewViewController" bundle:nil];
//            reviewViewController.contactObj = contactObj;
//            reviewViewController.videoViewState = videoViewState;
//            [self.tabBarController presentModalViewController:reviewViewController animated:YES];
//            push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:reviewViewController.contactObj.SeequID, @"SeequID",
//                         [NSString stringWithFormat:@"%@ %@ accepted your request to Review.", reviewViewController.contactObj.FirstName, reviewViewController.contactObj.LastName], @"message",
//                         @"Review", @"status", nil];
//        }
//            break;
//        default: {
//            [self ChangeContactObjectsRequestStatus:controller.contactObj RequestStatus:Request_Status_Recived_Connection_Accepted];
//            XMPPJID *jid = [XMPPJID jidWithUser:contactObj.SeequID
//                                         domain:@"im.protime.tv"
//                                       resource:nil];
//            
//            [self initXMPPRoster];
//            [xmppRoster acceptBuddyRequest:jid];
//            [[XMPPManager sharedXMPPManager] SendTextMessage:@"*#===REFRESH===#*" to:contactObj.SeequID MessageID:nil];
//            push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:controller.contactObj.SeequID, @"SeequID",
//                         [NSString stringWithFormat:@"%@ %@ accepted your request to Connection.", controller.contactObj.FirstName, controller.contactObj.LastName], @"message",
//                         @"Connection", @"status", nil];
//        }
//            break;
//    }
//    
//    if (push_dict) {
//        [[idoubs2AppDelegate sharedInstance].arrayPushes addObject:push_dict];
//    }
//    
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    [self.MyTableView reloadData];
//    int badgCount = [self CalculateBadgCount];
//    if (badgCount != -1) {
//        [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(SetRecentTabBadgValue:) withObject:[NSString stringWithFormat:@"%d", badgCount] waitUntilDone:YES];
//    }
}

- (void) AcceptRequestAsynchronously {
    @autoreleasepool {
        NSString *error_message = [Common UpdateRequestWithID:requestViewController.contactObj.ID
                                                         Date:[[NSDate date] timeIntervalSince1970]
                                                       Status:@"Accepted"];
        
        [self performSelectorOnMainThread:@selector(EndOfAcceptRequestWithErrorMessage:) withObject:error_message waitUntilDone:YES];
    }
}

- (void) EndOfAcceptRequestWithErrorMessage:(NSString*)error_msg {
    if (error_msg) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                            message:error_msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[idoubs2AppDelegate sharedInstance] HideLoadingView];
        
        return;
    }

    NSDictionary *push_dict = nil;
    switch (requestViewController.contactObj.requestStatus) {
        case Request_Status_Ringback: {
            [self ChangeContactObjectsRequestStatus:requestViewController.contactObj RequestStatus:Request_Status_Recived_Ringback_Accepted];
            [[idoubs2AppDelegate sharedInstance].videoService CallWithContactObject:requestViewController.contactObj Video:NO];
            push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:requestViewController.contactObj.SeequID, @"SeequID",
                         [NSString stringWithFormat:@"%@ %@ accepted your request to Ringback.", requestViewController.contactObj.FirstName, requestViewController.contactObj.LastName], @"message",
                         @"Ringback", @"status", nil];
            NSLog(@"[PUSH][SEND] <RequestRingback> - from:%@ %@, status:Accepted", requestViewController.contactObj.FirstName, requestViewController.contactObj.LastName);
        }
            break;
        case Request_Status_Review: {
            [self ChangeContactObjectsRequestStatus:requestViewController.contactObj RequestStatus:Request_Status_Recived_Review_Accepted];
            SeequWriteAReviewViewController *reviewViewController = [[SeequWriteAReviewViewController alloc] initWithNibName:@"SeequWriteAReviewViewController" bundle:nil];
            reviewViewController.contactObj = requestContactObject;
            reviewViewController.videoViewState = videoViewState;
            [self.tabBarController presentViewController:reviewViewController animated:YES completion:nil ];
            push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:reviewViewController.contactObj.SeequID, @"SeequID",
                         [NSString stringWithFormat:@"%@ %@ accepted your request to Review.", reviewViewController.contactObj.FirstName, reviewViewController.contactObj.LastName], @"message",
                         @"Review", @"status", nil];
        }
            break;
        default: {
            [self ChangeContactObjectsRequestStatus:requestViewController.contactObj RequestStatus:Request_Status_Recived_Connection_Accepted];
//            XMPPJID *jid = [XMPPJID jidWithUser:requestContactObject.SeequID
//                                         domain:@"im.protime.tv"
//                                       resource:nil];
//            
//            [self initXMPPRoster];
//            [xmppRoster acceptBuddyRequest:jid];
//            [[XMPPManager sharedXMPPManager] SendTextMessage:@"*#===REFRESH===#*" to:requestContactObject.SeequID MessageID:nil];
            push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:requestViewController.contactObj.SeequID, @"SeequID",
                         [NSString stringWithFormat:@"%@ %@ accepted your request to Connection.", requestViewController.contactObj.FirstName, requestViewController.contactObj.LastName], @"message",
                         @"Connection", @"status", nil];
            NSLog(@"[PUSH][SEND] <RequestConnection> - from:%@ %@, status:Accepted", requestViewController.contactObj.FirstName, requestViewController.contactObj.LastName);
        }
            break;
    }
    
    if (push_dict) {
        [[idoubs2AppDelegate sharedInstance].arrayPushes addObject:push_dict];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.MyTableView reloadData];
    int badgCount = [self CalculateBadgCount];
    if (badgCount != -1) {
        [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(SetRecentTabBadgValue:) withObject:[NSString stringWithFormat:@"%d", badgCount] waitUntilDone:YES];
    }
    
    [[idoubs2AppDelegate sharedInstance] HideLoadingView];
}

- (void) SeequConnectionRequest:(SeequRequestViewController*)controller didDeclineWithContactObject:(ContactObject*)contactObj {
    [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Processing..."];
    
    requestViewController = controller;
    requestContactObject = contactObj;
    
    [NSThread detachNewThreadSelector:@selector(DeclineRequestAsynchronously) toTarget:self withObject:nil];
    
    return;

//    
//    
//    NSString *error_message = [Common UpdateRequestWithID:controller.contactObj.ID
//                                                     Date:[[NSDate date] timeIntervalSince1970]
//                                                   Status:@"Declined"];
//    
//    if (error_message) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
//                                                        message:error_message
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        
//        [alert show];
//        [self.navigationController popToRootViewControllerAnimated:YES];
//        
//        return;
//    }
//    
//    NSDictionary *push_dict = nil;    
//    switch (controller.contactObj.requestStatus) {
//        case Request_Status_Ringback: {
//            [self ChangeContactObjectsRequestStatus:controller.contactObj RequestStatus:Request_Status_Recived_Ringback_Declined];
//            push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:controller.contactObj.SeequID, @"SeequID",
//                         [NSString stringWithFormat:@"%@ %@ declined your request to Ringback.", controller.contactObj.FirstName, controller.contactObj.LastName], @"message",
//                         @"Ringback", @"status", nil];
//        }
//            break;
//        case Request_Status_Review: {
//            [self ChangeContactObjectsRequestStatus:controller.contactObj RequestStatus:Request_Status_Recived_Review_Declined];
//            push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:controller.contactObj.SeequID, @"SeequID",
//                         [NSString stringWithFormat:@"%@ %@ declined your request to Review.", controller.contactObj.FirstName, controller.contactObj.LastName], @"message",
//                         @"Review", @"status", nil];
//        }
//            break;
//        default: {
//            [self ChangeContactObjectsRequestStatus:controller.contactObj RequestStatus:Request_Status_Recived_Connection_Declined];
//            XMPPJID *jid = [XMPPJID jidWithUser:contactObj.SeequID
//                                         domain:@"im.protime.tv"
//                                       resource:nil];
//            [self initXMPPRoster];
//            [xmppRoster rejectBuddyRequest:jid];
//            push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:controller.contactObj.SeequID, @"SeequID",
//                         [NSString stringWithFormat:@"%@ %@ declined your request to Connection.", controller.contactObj.FirstName, controller.contactObj.LastName], @"message",
//                         @"Connection", @"status", nil];
//        }
//            break;
//    }
//
//    if (push_dict) {
//        [[idoubs2AppDelegate sharedInstance].arrayPushes addObject:push_dict];
//    }
//    
//    [self.MyTableView reloadData];
//    int badgCount = [self CalculateBadgCount];
//    if (badgCount != -1) {
//        [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(SetRecentTabBadgValue:) withObject:[NSString stringWithFormat:@"%d", badgCount] waitUntilDone:YES];
//    }
}

- (void) DeclineRequestAsynchronously {
    @autoreleasepool {
        NSString *error_message = [Common UpdateRequestWithID:requestViewController.contactObj.ID
                                                         Date:[[NSDate date] timeIntervalSince1970]
                                                       Status:@"Declined"];
        
        [self performSelectorOnMainThread:@selector(EndOfDeclineRequestWithErrorMessage:) withObject:error_message waitUntilDone:YES];
    }
}

- (void) EndOfDeclineRequestWithErrorMessage:(NSString*)error_msg {
    
    if (error_msg) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                            message:error_msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[idoubs2AppDelegate sharedInstance] HideLoadingView];

        return;
    }
    
    NSDictionary *push_dict = nil;
    switch (requestViewController.contactObj.requestStatus) {
        case Request_Status_Ringback: {
            [self ChangeContactObjectsRequestStatus:requestViewController.contactObj RequestStatus:Request_Status_Recived_Ringback_Declined];
            push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:requestViewController.contactObj.SeequID, @"SeequID",
                         [NSString stringWithFormat:@"%@ %@ declined your request to Ringback.", requestViewController.contactObj.FirstName, requestViewController.contactObj.LastName], @"message",
                         @"Ringback", @"status", nil];
            NSLog(@"[PUSH][SEND] <RequestRingback> - from:%@ %@, status:Declined", requestViewController.contactObj.FirstName, requestViewController.contactObj.LastName);
        }
            break;
        case Request_Status_Review: {
            [self ChangeContactObjectsRequestStatus:requestViewController.contactObj RequestStatus:Request_Status_Recived_Review_Declined];
            push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:requestViewController.contactObj.SeequID, @"SeequID",
                         [NSString stringWithFormat:@"%@ %@ declined your request to Review.", requestViewController.contactObj.FirstName, requestViewController.contactObj.LastName], @"message",
                         @"Review", @"status", nil];
        }
            break;
        default: {
            [self ChangeContactObjectsRequestStatus:requestViewController.contactObj RequestStatus:Request_Status_Recived_Connection_Declined];
//            XMPPJID *jid = [XMPPJID jidWithUser:requestContactObject.SeequID
//                                         domain:@"im.protime.tv"
//                                       resource:nil];
//            [self initXMPPRoster];
//            [xmppRoster rejectBuddyRequest:jid];
            push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:requestViewController.contactObj.SeequID, @"SeequID",
                         [NSString stringWithFormat:@"%@ %@ declined your request to Connection.", requestViewController.contactObj.FirstName, requestViewController.contactObj.LastName], @"message",
                         @"Connection", @"status", nil];
            NSLog(@"[PUSH][SEND] <RequestConnection> - from:%@ %@, status:Declined", requestViewController.contactObj.FirstName, requestViewController.contactObj.LastName);
        }
            break;
    }
    
    if (push_dict) {
        [[idoubs2AppDelegate sharedInstance].arrayPushes addObject:push_dict];
    }
    
    [self.MyTableView reloadData];
//    int badgCount = [self CalculateBadgCount];
//    if (badgCount != -1) {
//        [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(SetRecentTabBadgValue:) withObject:[NSString stringWithFormat:@"%d", badgCount] waitUntilDone:YES];
//    }
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[idoubs2AppDelegate sharedInstance] HideLoadingView];
}

- (void) didSendReview:(SeequWriteAReviewViewController *)seequWriteAReviewViewController {
    seequWriteAReviewViewController.contactObj.requestStatus = Request_Status_Recived_Review_Accepted;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.MyTableView reloadData];
    int badgCount = [self CalculateBadgCount];
    if (badgCount != -1) {
        [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(SetRecentTabBadgValue:) withObject:[NSString stringWithFormat:@"%d", badgCount] waitUntilDone:YES];
    }
    
    NSDictionary *push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:seequWriteAReviewViewController.contactObj.SeequID, @"SeequID",
                 [NSString stringWithFormat:@"%@ %@ accepted your request to Review.", seequWriteAReviewViewController.contactObj.FirstName, seequWriteAReviewViewController.contactObj.LastName], @"message",
                 @"Ringback", @"status", nil];
    [[idoubs2AppDelegate sharedInstance].arrayPushes addObject:push_dict];
}

- (void) StartDownloadRecents {
    @autoreleasepool {
          [NSThread sleepForTimeInterval:1.5];
          lastRecentsSyncTime = [[ActivityStorage sharedInstance] getLastCallTime];
          [Common GetRecentCallsWithDate:lastRecentsSyncTime ];
          [self PrepareRecents];
  
            
 }
}

- (void)PrepareRecents {
//    UINavigationController *nav = [[idoubs2AppDelegate sharedInstance].tabBarController.viewControllers objectAtIndex:0];
//    SeequContactsViewController *controller = [nav.viewControllers objectAtIndex:0];
//    
//    for (int index = 0; index < [arrayRecents count]; index++) {
//        ContactObject *obj = [arrayRecents objectAtIndex:index];
//        
//        ContactObject *objContact = [controller CheckObjectInArrayWithPT:obj.SeequID];
//        
//        if (objContact) {
//            obj.contactType = objContact.contactType;
//        } else {
//            obj.contactType = Contact_Type_Seequ_Contact;
//        }
//        
//        if (obj.imageExist && !obj.image) {
//            NSData *imageData;
//            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2) {
//                //Retina display
//                imageData = [Common GetLastCatchedImageWithSeequID:obj.SeequID Height:IMAGE_HEIGHT*2];
//            } else {
//                imageData = [Common GetLastCatchedImageWithSeequID:obj.SeequID Height:IMAGE_HEIGHT];
//            }
//            
//            if (imageData) {
//                obj.image = [[UIImage alloc] initWithData:imageData];
//            } else {
//                obj.delegate = self;
//                [NSThread detachNewThreadSelector:@selector(StartGetingImage)
//                                         toTarget:obj
//                                       withObject:nil];
//            }
//        }
//    }
//    
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ID" ascending:NO];
//    NSArray *sortDescriptors = @[sortDescriptor];
//    [arrayRecents sortUsingDescriptors:sortDescriptors];
    
//    [self performSelectorOnMainThread:@selector(EndDownloadRecents)
//                           withObject:nil
//                        waitUntilDone:NO];
        [self EndDownloadRecents];
        //    if (arrayRecents && arrayRecents.count) {
//        ContactObject *obj = [arrayRecents objectAtIndex:0];
//        lastRecentsSyncTime = obj.startTime + 1;
//    }
}

- (void) EndDownloadRecents {
        
//        if (segmentType == Activity_Segment_Type_Recent || segmentType == Activity_Segment_Type_All) {
//        [self.MyTableView reloadData];
//        int badgCount = [self CalculateBadgCount];
//        if (badgCount != -1) {
//            [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(SetRecentTabBadgValue:) withObject:[NSString stringWithFormat:@"%d", badgCount] waitUntilDone:YES];
//        }
//    }
        [self setTabBadgValue];
        [self updateLastActivityTimes];
    isOnThread_Recent = NO;
    
    if (!isOnThread_Requests) {
        [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:NO];
    }
}

- (void) StartDownloadRequests {
    @autoreleasepool {
        lastRequestsSyncTime = [[ActivityStorage sharedInstance] getLastRequestTime];
        [Common GetRequestsWithDate:lastRequestsSyncTime];
        [self PrepareRequests];
    }
}

- (void) PrepareRequests {
//    UINavigationController *nav = [[idoubs2AppDelegate sharedInstance].tabBarController.viewControllers objectAtIndex:0];
//    SeequContactsViewController *controller = [nav.viewControllers objectAtIndex:0];
//    
//    for (int index = 0; index < [arrayRequests count]; index++) {
//        ContactObject *obj = [arrayRequests objectAtIndex:index];
//        
//        ContactObject *objContact = [controller CheckObjectInArrayWithPT:obj.SeequID];
//        
//        if (objContact) {
//            obj.contactType = objContact.contactType;
//            obj.image = [objContact.image copy];
//        } else {
//            obj.contactType = Contact_Type_Seequ_Contact;
//            
//           
//            ContactObject *contactObj = [Common getContactObjectWithSeequID:obj.SeequID];
            

//            if (contactObj) {
//                obj.image = [contactObj.image copy];
//            }
//        }
//        
//        if (!obj.image) {
//            NSData *imageData;
//            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2) {
//                //Retina display
//                imageData = [Common GetLastCatchedImageWithSeequID:obj.SeequID Height:IMAGE_HEIGHT*2];
//            } else {
//                imageData = [Common GetLastCatchedImageWithSeequID:obj.SeequID Height:IMAGE_HEIGHT];
//            }
//            
//            if (imageData) {
//                obj.image = [[UIImage alloc] initWithData:imageData];
//            }
//        }
//    }

//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:NO];
//    NSArray *sortDescriptors = @[sortDescriptor];
//    [arrayRequests sortUsingDescriptors:sortDescriptors];
    
//    if (arrayRequests && arrayRequests.count) {
//        ContactObject *obj = [arrayRequests objectAtIndex:0];
////        lastRequestsSyncTime = obj.startTime + 1;
//    }
//
//    [self performSelectorOnMainThread:@selector(EndDownloadRequests)
//                           withObject:nil
//                        waitUntilDone:NO];
        [self EndDownloadRequests];
}

- (void) EndDownloadRequests {
       
      
//    if (segmentType == Activity_Segment_Type_Requests || segmentType == Activity_Segment_Type_All) {
//        [self.MyTableView reloadData];
//        int badgCount = [self CalculateBadgCount];
//        if (badgCount != -1) {
        
//            [Common SetMissedCallsCountToCash:[Common GetAllMissedCallsFromCash]];
//
//        }
//    }
        [self setTabBadgValue];
        [self updateLastActivityTimes];
        isOnThread_Requests = NO;

    if (!isOnThread_Recent) {
        [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:NO];
    }
}
-(void)updateLastActivityTimes{
     lastRequestsSyncTime = [[ActivityStorage sharedInstance] getLastRequestTime];
     lastRecentsSyncTime = [[ActivityStorage sharedInstance] getLastCallTime];
}
-(void)playIncoming{
        [[idoubs2AppDelegate sharedInstance].soundService vibrate];
        [[idoubs2AppDelegate sharedInstance].soundService playIncomingMessage];
}
-(void)setTabBadgValue{
        int missedRequest = [[ActivityStorage sharedInstance] getMissedRequestCount];
        int missedCalls = [[ActivityStorage sharedInstance] getMissedCallCount];
        int tabBadgeValue = [[idoubs2AppDelegate sharedInstance] GetRecentTabBadgValue];
        if ( (missedCalls+missedRequest) - tabBadgeValue > 0) {
                [self performSelector:@selector(playIncoming) withObject:nil];
        }
        [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(updateBadge) withObject:nil waitUntilDone:NO];
//        NSString *stringBadgValue=[NSString stringWithFormat:@"%d", (missedCalls+missedRequest)];
//        [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(SetRecentTabBadgValue:) withObject:stringBadgValue waitUntilDone:YES];
}
- (int) CalculateBadgCount {
    int ignored_request_count = 0;
    if (arrayRequests && arrayRequests.count) {
        for (ContactObject *object in arrayRequests) {
            switch (object.requestStatus) {
                case Request_Status_Connection:
                case Request_Status_Ringback:
                case Request_Status_Review: {
                    ignored_request_count++;
                }
                    break;
                default:
                    break;
            }
        }
    }
    int temp = [Common GetAllMissedCallsFromCash] -[[NSUserDefaults standardUserDefaults] integerForKey:kMISSEDCALL];
    ignored_request_count  += temp;

    return ignored_request_count;
}

- (BOOL) checkRequestObjectWithID:(int)reqID {
    for (ContactObject *object in arrayRequests) {
        if (object.ID == reqID) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	[self refresh];
}

- (void)doneLoadingTableViewData{
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.MyTableView];
	
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
        [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:NO];
    } else {
        [self reloadTableViewDataSource];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return [NSDate date]; // should return date data source was last changed
}

- (void) SetRequestArray {
}

- (void) SetRecentArray {
//    NSMutableArray *array;
//    
//    if (![Common GetAllRecentsFromCatch:&array]) {
//        if (array && array.count) {
//            arrayRecents = [[NSMutableArray alloc] initWithArray:array];
//            [self PrepareRecents];
//        }
//    }
}

- (void) ChangeContactObjectsRequestStatus:(ContactObject*)object RequestStatus:(Request_Status)status {
//    for (ContactObject *obj in arrayRequests) {
//        if ([obj.SeequID isEqualToString:object.SeequID]) {
            Contact_Type type ;
        Contact_Type old_type;
        
            switch (status) {
                    case Request_Status_Recived_Ringback_Accepted:{
                        type = Contact_Type_Request_Ringback_Accepted;
                        old_type=Contact_Type_Request_Ringback;
                    }
                            break;
                    case Request_Status_Recived_Ringback_Declined:{
                        type=Contact_Type_Request_For_Ringback;
                        old_type=Contact_Type_Request_Ringback;
                     }
                            break;
                            
                     case Request_Status_Recived_Connection_Accepted:{
                        type = Contact_Type_MY_Seequ_Contact;
                        old_type=Contact_Type_Request_Connection;
                    }
                            break;
                     case Request_Status_Recived_Connection_Declined: {
                            type = Contact_Type_Request_For_Connection;
                            old_type=Contact_Type_Request_Connection;
                        }
                            break;
        
                    default:{
                        ///@todo Gor needs  to  clarify
                        type = Contact_Type_NON;
                        old_type = Contact_Type_NON;
                        NSAssert(NO, @"this  situation  must  never  happens" );
                    }
                            break;
                }
        if (status) {
                NSMutableDictionary *requestsInfoDict=[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                [NSNumber numberWithInt:status],@"status",
                                                [NSNumber numberWithInt:type],@"type",
                                                object.SeequID,@"seeQuId",
                                                [NSNumber numberWithInt:old_type],@"old_type",nil];
                [[ActivityStorage sharedInstance] updateRequestWithDictionary:requestsInfoDict];
        }
        

        
//    [Common ChangeContactObjectsRequestStatus:object RequestStatus:status];
}

@end
