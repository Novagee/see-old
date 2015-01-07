//
//  SeequEditGroup1ViewController.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 5/21/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequContactsViewController.h"
#import "SeequGroupInfo.h"

@protocol SeequEditGroupViewControllerDelegate <NSObject>

-(void) didEditGroup:(SeequGroupInfo*) group new:(BOOL) flag;

@end

@interface SeequEditGroupViewController : SeequContactsViewController <UIAlertViewDelegate>


@property (nonatomic,retain) SeequGroupInfo*  groupInfo;
@property (nonatomic,assign) id<SeequEditGroupViewControllerDelegate> delegate;
@end
