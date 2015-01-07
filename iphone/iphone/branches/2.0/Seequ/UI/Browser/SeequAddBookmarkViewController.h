//
//  SeequAddBookmarkViewController.h
//  ProTime
//
//  Created by Norayr on 04/29/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequBookmarkFoldersViewController.h"

@protocol AddBookmarkDelegate;

@interface SeequAddBookmarkViewController : UITableViewController <BookmarkFoldersDelegate, UITextFieldDelegate> {
    id<AddBookmarkDelegate> __weak __delegate;
    
    NSString *defaultPath;
}


@property (nonatomic, assign) id<AddBookmarkDelegate> addBookmarkDelegate;
@property (nonatomic, retain) NSString *defaultPath;
@property (nonatomic, retain) NSString *selectedPath;
@property (nonatomic, retain) NSString *navTitle;
@property (nonatomic, retain) NSArray *arrayEditBookMark;
@property (nonatomic, assign) int indexEditBookMark;
@property (nonatomic, retain) NSArray *activityItems;
@property (strong, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (strong, nonatomic) IBOutlet UITextField *textFieldURL;


- (void) onButtonCancel:(id)sender;
- (void) onButtonSave:(id)sender;

@end

@protocol AddBookmarkDelegate <NSObject>

- (void)didFinishSeequAddBookmarkViewController:(SeequAddBookmarkViewController*)viewController;

@end