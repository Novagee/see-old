//
//  SeequSwitchWithTitleCell.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 12/30/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import "SeequSwitchWithTitleCell.h"

@implementation SeequSwitchWithTitleCell
@synthesize switcher;
@synthesize title;
@synthesize textField;
@synthesize isEditable = _isEditable;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) setIsEditable:(BOOL)isEditable {
    _isEditable = isEditable;
    textField.hidden = !_isEditable;
    switcher.hidden = _isEditable;
    
}
@end
