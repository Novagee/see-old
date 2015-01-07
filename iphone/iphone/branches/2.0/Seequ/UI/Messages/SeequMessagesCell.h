//
//  SeequMessagesCell.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 2/2/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageItem.h"
#import "SeequGroupInfo.h"
#import "CDMessageOwner.h"


@interface SeequMessagesCell : UITableViewCell

@property (nonatomic,assign) BOOL editable;

-(void) updateGroupCell:(SeequGroupInfo*) item ;
-(void) updateCellInfo:(CDMessageOwner *)item;

@end
