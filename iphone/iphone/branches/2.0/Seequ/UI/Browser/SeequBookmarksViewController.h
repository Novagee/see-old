//
//  SeequBookmarksViewController.h
//  ProTime
//
//  Created by Norayr on 02/20/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequBrowserHistoryViewController.h"
#import "BackBarButton.h"

@protocol SeequBookmarksDelegate;

@interface SeequBookmarksViewController : UIViewController {
    id<SeequBookmarksDelegate> __unsafe_unretained _delegate;
    
    BackBarButton *actionBarButton;
    NSMutableArray *arrayOfFolder;
    NSMutableArray *arrayOfBookMarks;
    
    NSString *bookMarksPath;
}

@property (nonatomic, assign) id<SeequBookmarksDelegate> seequBookmarksDelegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *buttonEdit;
@property (strong, nonatomic) IBOutlet UIButton *buttonNewFolder;

- (void) onButtonDone:(id)sender;
- (IBAction)onButtonEdit:(id)sender;
- (IBAction)onButtonNewFolder:(id)sender;
- (void) ChangeButtonStateByEdit:(BOOL)edit ShowNewFolder:(BOOL)show;

- (void) CreateArroyOfFolderList;

@end

@protocol SeequBookmarksDelegate <NSObject>

- (void) didSelectHistoryItem:(SeequBookmarksViewController*)history withDictionary:(NSDictionary*)dict;

@end