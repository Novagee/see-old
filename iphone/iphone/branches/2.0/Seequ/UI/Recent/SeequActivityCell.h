//
//  ActivityCell.h
//  ProTime
//
//  Created by Grigori Jlavyan on 2/19/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import "ContactObject.h"
#import <UIKit/UIKit.h>

@interface SeequActivityCell : UITableViewCell
-(void)updateCell:(ContactObject*)object;
@end
