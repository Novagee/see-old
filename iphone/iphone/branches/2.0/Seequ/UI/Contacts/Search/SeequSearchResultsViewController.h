//
//  SeequSearchResultsViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/3/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"
#import "EGORefreshTableFooterView.h"


@interface SeequSearchResultsViewController : UIViewController <ContactObjectDelegate, UITextFieldDelegate> {
    NSMutableArray *sectionsArray;
    NSMutableArray *arraySearchResults;
    UIActivityIndicatorView *activityIndicatorView;
    
    BOOL isShow;
    BOOL isOnSearchThread;
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
    EGORefreshTableFooterView *refreshFooterView;
    BOOL _reloading;

}



@property (strong, nonatomic) IBOutlet UIView *viewSearch;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, assign) int videoViewState;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textFieldSearch;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *MyTableView;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (void) GoBack:(id)sender;
- (NSIndexPath*) FindIndexPathWithPT:(NSString*)seequID;
- (void) ShowAlertWithMessage:(NSString*)text;
- (void) StopActivityIndicatorView;
- (NSInteger) IndexForTitle:(NSString*)text;
- (IBAction) onButtonstartSearch:(id)sender;
- (void) SearchTextFieldChange;

@end