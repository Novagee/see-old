//
//  RamkaView.h
//  Rect
//
//  Created by comp1 on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kDefaultStrokeColor [UIColor clearColor]
#define kDefaultRectColor   [UIColor whiteColor]
#define kDefaultStrokeWidth 1.0
#define kDefaultCornerRadius 7.0


@interface RamkaView : UIView {
	UIColor     *strokeColor; 
	UIColor     *rectColor; 
	CGFloat     strokeWidth; 
	CGFloat     cornerRadius;
    int distance;
}

@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *rectColor;
@property CGFloat strokeWidth;
@property CGFloat cornerRadius;
@property int distance;

@end