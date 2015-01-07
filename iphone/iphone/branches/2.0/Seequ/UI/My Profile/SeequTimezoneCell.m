//
//  SeequTimezoneCell.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 12/18/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import "SeequTimezoneCell.h"

@implementation SeequTimezoneCell

@synthesize value;
@synthesize cities;

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

@end
