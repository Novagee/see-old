//
//  SeequDropboxActivity.h
//  ProTime
//
//  Created by Grigori Jlavyan on 7/28/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequDropboxViewController.h"

@interface SeequDropboxActivity : UIActivity <SeequDropboxViewControllerDelegate>
@property (nonatomic, copy) NSArray *activityItems;
@property (nonatomic) BOOL isfromSeequImagePicker;
@end
