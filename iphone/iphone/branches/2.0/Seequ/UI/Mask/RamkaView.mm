//
//  RamkaView.m
//  Rect
//
//  Created by comp1 on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RamkaView.h"


@implementation RamkaView


@synthesize strokeColor;
@synthesize rectColor;
@synthesize strokeWidth;
@synthesize cornerRadius;
@synthesize distance;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
		self.opaque = NO;
		self.strokeColor = kDefaultStrokeColor;
		self.backgroundColor = [UIColor clearColor];
		self.rectColor = kDefaultRectColor;
		self.strokeWidth = kDefaultStrokeWidth;
		self.cornerRadius = kDefaultCornerRadius;
        distance = 0;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect { 
	CGContextRef context = UIGraphicsGetCurrentContext();  
	CGContextSetLineWidth(context, strokeWidth); 
	CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor); 
	CGContextSetFillColorWithColor(context, self.rectColor.CGColor); 
    CGRect rrect = CGRectMake(self.frame.origin.x + distance, self.frame.origin.y + distance, self.frame.size.width - distance*2, self.frame.size.height - distance*2);
	CGFloat radius = cornerRadius;
	CGFloat width = CGRectGetWidth(rrect);
	CGFloat height = CGRectGetHeight(rrect); 
	// Make sure corner radius isn't larger than half the shorter side  
	if (radius > width/2.0)  
		radius = width/2.0;  
	if (radius > height/2.0)  
		radius = height/2.0;  
	CGFloat minx = CGRectGetMinX(rrect);
	CGFloat midx = CGRectGetMidX(rrect); 
	CGFloat maxx = CGRectGetMaxX(rrect); 
	CGFloat miny = CGRectGetMinY(rrect);  
	CGFloat midy = CGRectGetMidY(rrect); 
	CGFloat maxy = CGRectGetMaxY(rrect); 
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius); 
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius); 
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius); 
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);  
	CGContextClosePath(context);  
	CGContextDrawPath(context, kCGPathFillStroke);	
}



@end