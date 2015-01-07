//
//  SeequSwitchWithTitleCell.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 12/30/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeequSwitchWithTitleCell : UITableViewCell
@property (nonatomic,retain) IBOutlet UILabel*  title;
@property (nonatomic,retain) IBOutlet UISwitch* switcher;
@property (nonatomic,retain) IBOutlet UITextField* textField;
@property (nonatomic,assign) BOOL isEditable;
@end
