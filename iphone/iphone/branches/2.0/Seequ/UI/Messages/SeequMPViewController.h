//
//  SeequMPViewController.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 2/24/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"
#import "MessageItem.h"

@interface SeequMPViewController : UIViewController
@property (nonatomic,retain) NSURL*  url;
@property (nonatomic,assign) id<CaptureSessionManagerDelegate> delegate;
@property (nonatomic,assign) BOOL isResponse;
@property (nonatomic,retain) MessageItem* messageItem;
@end
