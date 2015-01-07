//
//  SeequDropboxTreeTableViewCell.m
//  ProTime
//
//  Created by Grigori Jlavyan on 8/6/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequDropboxTreeTableViewCell.h"  

#define COLOR_FILES_TITLE [UIColor colorWithRed:0.4 green:0.357 blue:0.325 alpha:1]
#define COLOR_FILES_TITLE_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:1]
#define COLOR_FILES_COUNTER [UIColor colorWithRed:0.608 green:0.376 blue:0.251 alpha:1]
#define COLOR_FILES_COUNTER_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:0.35]
#define FONT_FILES_TITLE [UIFont fontWithName:@"HelveticaNeue" size:14.0f]
#define FONT_FILES_COUNTER [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f]

@implementation SeequDropboxTreeTableViewCell

@synthesize backgroundImageView;
@synthesize iconButton;
@synthesize titleTextField;
@synthesize countLabel;
@synthesize treeItem;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
            backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"copymove-cell-bg"]];
            [backgroundImageView setContentMode:UIViewContentModeTopRight];
            [self setBackgroundView:backgroundImageView];
            [self setSelectionStyle:UITableViewCellSelectionStyleNone];
            iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [iconButton setFrame:CGRectMake(5,10,30,30)];
            [iconButton setAdjustsImageWhenHighlighted:NO];
            [iconButton addTarget:self action:@selector(iconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [iconButton setImage:[UIImage imageNamed:@"FolderIcon.png"] forState:UIControlStateNormal];
            
            [self.contentView addSubview:iconButton];
            
            titleTextField = [[UITextField alloc] init];
            [titleTextField setFont:FONT_FILES_TITLE];
            [titleTextField setTextColor:COLOR_FILES_TITLE];
            [titleTextField.layer setShadowColor:COLOR_FILES_TITLE_SHADOW.CGColor];
            [titleTextField.layer setShadowOffset:CGSizeMake(0, 1)];
            [titleTextField.layer setShadowOpacity:1.0f];
            [titleTextField.layer setShadowRadius:0.0f];
            
            [titleTextField setUserInteractionEnabled:NO];
            [titleTextField setBackgroundColor:[UIColor clearColor]];
            [titleTextField sizeToFit];
            [titleTextField setFrame:CGRectMake(40,20,100,titleTextField.frame.size.height)];
            [self.contentView addSubview:titleTextField];
            [self.layer setMasksToBounds:YES];
            countLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 10, 30, 30)];
            [countLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
            [countLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"itemCounter"]]];
            [countLabel setTextAlignment:NSTextAlignmentCenter];
            [countLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
            [countLabel setFont:FONT_FILES_COUNTER];
            [countLabel setTextColor:[UIColor blackColor]];
            [countLabel setShadowColor:COLOR_FILES_COUNTER_SHADOW];
            [countLabel setShadowOffset:CGSizeMake(0, 1)];
            [self setAccessoryView:countLabel];
            [self.accessoryView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
        [super setSelected:selected animated:animated];
	
        // Configure the view for the selected state
}

- (void)setLevel:(NSInteger)level {
	CGRect rect;
	
	rect = iconButton.frame;
	rect.origin.x = 5+20 * level;
	iconButton.frame = rect;
	
	rect = titleTextField.frame;
	rect.origin.x = 40+20 * level;
	titleTextField.frame = rect;
}


@end
