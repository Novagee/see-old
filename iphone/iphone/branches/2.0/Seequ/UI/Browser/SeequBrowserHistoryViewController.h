//
//  SeequBrowserHistoryViewController.h
//  ProTime
//
//  Created by Norayr on 02/20/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequBrowserHistoryListViewController.h"


@protocol SeequBrowserHistoryDelegate; 

@interface SeequBrowserHistoryViewController : UIViewController <SeequBrowserHistoryListDelegate, UIActionSheetDelegate> {
    NSMutableArray *arrayHistory;
    id<SeequBrowserHistoryDelegate> __unsafe_unretained _delegate;
}

@property (nonatomic, assign) id<SeequBrowserHistoryDelegate> seequBrowserHistoryDelegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void) GoBack:(id)sender;
- (void) onButtonDone:(id)sender;
- (IBAction)onButtonClear:(id)sender;

- (NSMutableArray*) CreateHistoryArray;

@end

@protocol SeequBrowserHistoryDelegate <NSObject>

@optional

- (void) didSelectHistoryItem:(SeequBrowserHistoryViewController*)history withDictionary:(NSDictionary*)dict;

@end