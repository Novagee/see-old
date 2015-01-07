//
//  BackBarButton.m
//  DrinkingBuddy
//
//  Created by Asatur Galstyan on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BackBarButton.h"


@implementation BackBarButton


- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {

    self = [super init];
    
	if (self) {
		self.image = image;
		self.style = style;
		self.target = target;
		self.action = action;
		
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
		[btn setImage:image forState:UIControlStateNormal];
		[btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		self.customView = btn;	
    }
    
    return self;
}


@end