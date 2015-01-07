//
//  SeequEditFolderViewController.h
//  ProTime
//
//  Created by Norayr on 04/30/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequBookmarkFoldersViewController.h"

@interface SeequEditFolderViewController : UITableViewController <BookmarkFoldersDelegate, UITextFieldDelegate> {
    
}

@property (strong, nonatomic) IBOutlet UITextField *textFieldFolderName;
@property (nonatomic, retain) NSString *beginFolderPath;
@property (nonatomic, retain) NSString *selectedPath;
@property (nonatomic, retain) NSString *folderName;

- (void) onButtonBack:(id)sender;

@end
