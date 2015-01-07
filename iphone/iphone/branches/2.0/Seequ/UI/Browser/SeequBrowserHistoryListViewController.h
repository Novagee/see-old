//
//  SeequBrowserHistoryListViewController.h
//  ProTime
//
//  Created by Norayr on 02/20/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//
#import "Common.h"
#import <UIKit/UIKit.h>

@protocol SeequBrowserHistoryListDelegate;

@interface SeequBrowserHistoryListViewController : UIViewController <UIActionSheetDelegate> {
    id<SeequBrowserHistoryListDelegate> __unsafe_unretained _delegate;
}

@property (nonatomic, assign) id<SeequBrowserHistoryListDelegate> seequBrowserHistoryListDelegate;
@property (nonatomic, strong) NSMutableArray *arrayHistoryList;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void) GoBack:(id)sender;
- (void) onButtonDone:(id)sender;
- (IBAction)onButtonClear:(id)sender;

@end

@protocol SeequBrowserHistoryListDelegate <NSObject>

@optional

- (void) didSelectHistoryItem:(SeequBrowserHistoryListViewController*)historylist withDictionary:(NSDictionary*)dict;

@end
