//
//  CustomImageView.m
//  ProTime
//
//  Created by Norayr on 10/08/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import "CustomImageView.h"

@implementation CustomImageView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if ([_delegate respondsToSelector:@selector(didChangeFrame:)]) {
        [_delegate didChangeFrame:self];
    }
}

@end