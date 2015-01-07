//
//  NavigationBar.m
//  Protime
//
//  Created by Norayr Harutyunyan on 1/13/11.
//  Copyright 2011 Be-Interactive. All rights reserved.
//

#import "NavigationBar.h"


@implementation NavigationBar

@synthesize backgroundImage, titleImage;

- (void) drawRect:(CGRect) rect {

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
	if (backgroundImage) {
		[backgroundImage drawInRect:CGRectMake(0, 0, screenSize.width, screenSize.height)];
	}
	
	if (titleImage) {
		[titleImage drawInRect:CGRectMake(screenSize.width/2 - titleImage.size.width/2, screenSize.height/2 - titleImage.size.height/2, titleImage.size.width,titleImage.size.height )];
	}
}


@end