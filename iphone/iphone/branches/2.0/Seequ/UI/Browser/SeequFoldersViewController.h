//
//  SeequFoldersViewController.h
//  ProTime
//
//  Created by Norayr on 04/30/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackBarButton.h"

@protocol SeequFoldersDelegate;

@interface SeequFoldersViewController : UIViewController {
    id<SeequFoldersDelegate> __unsafe_unretained _delegate;

    BackBarButton *actionBarButton;

    NSMutableArray *arrayOfFolder;
    NSMutableArray *arrayOfBookMarks;
    
    NSString *bookMarksPath;
}

@property (nonatomic, assign) id<SeequFoldersDelegate> seequFoldersDelegate;
@property (nonatomic, retain) NSString *beginFolderPath;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *buttonEdit;
@property (strong, nonatomic) IBOutlet UIButton *buttonNewFolder;

- (void) onButtonDone:(id)sender;
- (void) onButtonBack:(id)sender;
- (IBAction)onButtonEdit:(id)sender;
- (IBAction)onButtonNewFolder:(id)sender;
- (void) CreateArroyOfFolderList;

@end

@protocol SeequFoldersDelegate <NSObject>

- (void) didSelectHistoryItem:(SeequFoldersViewController*)history withDictionary:(NSDictionary*)dict;

@end