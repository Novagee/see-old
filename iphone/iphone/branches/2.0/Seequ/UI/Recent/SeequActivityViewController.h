//
//  SeequActivityViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/12/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequRequestViewController.h"
#import "SeequWriteAReviewViewController.h"
#import "UserEntity.h"
#import "XMPPRoster.h"
#import "ContactObject.h"
#import "EGORefreshTableHeaderView.h"

typedef enum Activity_Segment_Type {
	Activity_Segment_Type_All,
    Activity_Segment_Type_Recent,
    Activity_Segment_Type_Requests
}
Activity_Segment_Type;

@interface SeequActivityViewController : UIViewController <XMPPRosterStorage, ContactObjectDelegate, SeequRequestDelegate, SeequWriteAReviewDelegate, EGORefreshTableHeaderDelegate, UIActionSheetDelegate,NSFetchedResultsControllerDelegate> {
    SeequRequestViewController *requestViewController;
    ContactObject *requestContactObject;
    
    XMPPRoster *xmppRoster;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;

    Activity_Segment_Type segmentType;
    
    NSMutableArray *arrayAll;
    NSMutableArray *arrayRequests;
    NSMutableArray *arrayRecents;
    
    BOOL isOnThread_Recent;
    BOOL isOnThread_Requests;

    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
    
    NSTimeInterval lastRequestsSyncTime;
    NSTimeInterval lastRecentsSyncTime;
}

@property (nonatomic, assign) int videoViewState;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *MyTableView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonAll;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *ButtonRecent;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *ButtonRequests;
@property (nonatomic,retain) NSFetchedResultsController *fetchedController;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (void) refresh;
- (IBAction)onButtonFilter:(id)sender;
- (void) onButtonClear:(id)sender;
- (void) CLearAllActivitys;
- (void) onVideoViewChange:(NSNotification*)notification;
- (void) onRequestEvent:(NSNotification*)notification;
- (void) initXMPPRoster;
- (ContactObject*) CheckObjectInRequestsArrayWithContactObject:(ContactObject*)contactObj;
- (void) SetRecentImageWithContactObject:(ContactObject*)contactsObj;
- (void) SetRequestImageWithContactObject:(ContactObject*)contactsObj;
- (void) StartDownloadRecents;
- (void) EndDownloadRecents;
- (void) StartDownloadRequests;
- (void) EndDownloadRequests;
//- (UILabel*) LabelDateWithDate:(NSTimeInterval)date;
- (NSMutableArray*) CreateAllRequestsArray;
- (int) CalculateBadgCount;
- (void) reloadTableViewDataSource;
- (void) doneLoadingTableViewData;
- (BOOL) checkRequestObjectWithID:(int)reqID;
- (void) SetRequestArray;
- (void) SetRecentArray;
- (void) ChangeContactObjectsRequestStatus:(ContactObject*)object RequestStatus:(Request_Status)status;
- (void) AcceptRequestAsynchronously;
- (void) EndOfAcceptRequestWithErrorMessage:(NSString*)error_msg;
- (void) DeclineRequestAsynchronously;
- (void) EndOfDeclineRequestWithErrorMessage:(NSString*)error_msg;

@end