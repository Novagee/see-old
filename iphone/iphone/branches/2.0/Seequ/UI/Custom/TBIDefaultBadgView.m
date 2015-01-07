//
//  TBIDefaultBadgView.m
//  ProTime
//
//  Created by Artak on 6/3/11.
//  Copyright 2011 doubango. All rights reserved.
//

#import "TBIDefaultBadgView.h"


@implementation TBIDefaultBadgView

@synthesize delegate = _delegate;

- (id)init {
    self = [super init];
    
    if (self) {
        imgViewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 27)];
        imgViewLeft.image = [UIImage imageNamed:@"LeftBadge.png"];
        [self addSubview:imgViewLeft];
        
        imgViewMiddle = [[UIImageView alloc] initWithFrame:CGRectMake(13, 0, 4, 27)];
        imgViewMiddle.image = [UIImage imageNamed:@"MiddleBadge.png"];
        [self addSubview:imgViewMiddle];
        
        imgViewRight = [[UIImageView alloc] initWithFrame:CGRectMake(17, 0, 13, 27)];
        imgViewRight.image = [UIImage imageNamed:@"RigthBadge.png"];
        [self addSubview:imgViewRight];

        lblText = [[UILabel alloc] init];
        [lblText setBackgroundColor:[UIColor clearColor]];
        lblText.textAlignment = NSTextAlignmentCenter;
        [lblText setTextColor:[UIColor whiteColor]];
        [self addSubview:lblText];
        
        self.hidden = YES;
    }
    
    return self;
}

- (void)SetText:(NSString*)text {
    if (text == nil || !text || ![text length]) {
        lblText.text = @"0";
        self.hidden = YES;
        
        return;
    } else {
        if ([text isEqualToString:@"0"]) {
            self.hidden = YES;
        } else {
            self.hidden = NO;
        }
    }
    
    lblText.text = text;

    if (text && [text length] == 1) {
        [lblText setFont:[UIFont boldSystemFontOfSize:18]];
        lblText.frame = CGRectMake(0, 0, 26, 26);
        lblText.center = CGPointMake(13, 13);
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 26, 26);
        
        imgViewLeft.frame = CGRectMake(0, 0, 13, 26);
        imgViewMiddle.hidden = YES;
        imgViewRight.frame = CGRectMake(self.frame.size.width - 13, 0, 13, 26);
        
        return;
    }
    
    UIFont *font = [UIFont boldSystemFontOfSize:18];
    CGSize textSize = CGSizeMake(300, 24);
    CGSize size = [text sizeWithFont:font constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    lblText.frame = CGRectMake(0, 0, size.width, size.height);
    [lblText setFont:font];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width + 15, 26);
    lblText.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    imgViewLeft.frame = CGRectMake(0, 0, 13, 26);
    imgViewMiddle.frame = CGRectMake(13, 0, self.frame.size.width - 26, 26);
    imgViewMiddle.hidden = NO;
    imgViewRight.frame = CGRectMake(self.frame.size.width - 13, 0, 13, 26);
}

- (NSString*)GetValue {
    return lblText.text;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([_delegate respondsToSelector:@selector(didSelectBadgView:)])
	{
        self.alpha = 0.6;
	}
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.alpha = 1.0;
    if ([_delegate respondsToSelector:@selector(didSelectBadgView:)])
	{
		[_delegate didSelectBadgView:self];
	}	
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.alpha = 1.0;    
}

- (void)IncrementBagdValue {
    @try {
        int value = [lblText.text intValue];
        value++;
        [self SetText:[NSString stringWithFormat:@"%d", value]];
    }
    @catch (NSException *exception) {
        NSLog(@"Bagd value not number numeric.");
    }
    @finally {
    }
}

- (void)DecrementBagdValue {
    @try {
        int value = [lblText.text intValue];
        value--;
        [self SetText:[NSString stringWithFormat:@"%d", value]];
    }
    @catch (NSException *exception) {
        NSLog(@"Bagd value not number numeric.");
    }
    @finally {
    }
}


@end