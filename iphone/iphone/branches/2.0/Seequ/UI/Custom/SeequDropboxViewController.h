//
//  SeequDropboxViewControllerViewController.h
//  ProTime
//
//  Created by Grigori Jlavyan on 7/28/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequViewForDragToDropbox.h"

#define DRAGGING_VIEW_HEIGHT 60
#define DRAGGING_VIEW_WIDTH  60

@protocol  SeequDropboxViewControllerDelegate;

@interface SeequDropboxViewController : UIViewController
@property (nonatomic,retain) NSString *rootPath;
@property (nonatomic,retain) NSArray *activityArray;
@property (nonatomic,weak) id<SeequDropboxViewControllerDelegate> delegate;
@property (nonatomic) bool isfromSeequImagePicker;
@end
@protocol SeequDropboxViewControllerDelegate <NSObject>

- (void)dropboxViewControllerDidCancel:(SeequDropboxViewController*)viewController;


@end
