//
//  SeequBookmarkFoldersViewController.h
//  ProTime
//
//  Created by Norayr on 04/29/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//
#import "Common.h"
#import <UIKit/UIKit.h>

@protocol BookmarkFoldersDelegate;

@interface SeequBookmarkFoldersViewController : UITableViewController {
    id<BookmarkFoldersDelegate> __weak __delegate;

    NSMutableArray *arrayOfFolders;
}

@property (nonatomic, assign) id<BookmarkFoldersDelegate> bookmarkFoldersDelegate;
@property (nonatomic, retain) NSString *beginFolderPath;
@property (nonatomic, retain) NSString *selectedFolderPath;

- (void) onButtonBack:(id)sender;
- (void) CreateArroyOfFolderList;

@end

@protocol BookmarkFoldersDelegate <NSObject>

- (void)BookmarkFoldersViewController:(SeequBookmarkFoldersViewController*)viewController didSelectPath:(NSString*)path;

@end
