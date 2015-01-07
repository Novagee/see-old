//
//  SeequDoubleTakeSettingsCell.h
//  ProTime
//
//  Created by Grigori Jlavyan on 3/18/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"
@interface SeequDoubleTakeSettingsCell : UITableViewCell
-(void)updateCell:(ContactObject *)object needToDoubleTake:(BOOL)needDoubletake;
- (void)updateCellForMutedMembers:(ContactObject*)object;
@end
