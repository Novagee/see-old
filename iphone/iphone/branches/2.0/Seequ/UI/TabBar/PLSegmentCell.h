//
//  PLSegmentCell.h
//  PlutoLand
//
//  Created by xu xhan on 7/22/10.
//  Copyright 2010 xu han. All rights reserved.
//

/*
 Usage: set selected value to change its state
 
---not sure! state return two status normal and selected
 
 */


#import <UIKit/UIKit.h>

@protocol PLSegmentCellDelegate;
@interface PLSegmentCell : UIControl {
	UIImageView *imageNormal;
	UIImageView *imageHover;
    UIImageView* imageTitle;
    
    NSTimer *timer;
    UIImage *imgNormal;
    UIImage *imgHover;
    UIImage *imgDefault;
}


-(id)initWithNormalImage:(UIImage*)anormal selectedImage:(UIImage*)ahover frame:(CGRect)aframe;

-(id)initWithNormalImage:(UIImage *)anormal selectedImage:(UIImage *)ahover startPoint:(CGPoint)apoint;

-(id) initWithImage:(UIImage *)image background:(UIImage*) BG selectedBackground:(UIImage *)selectedBG frame:(CGRect)aframe;

- (void) StartAnimationWithImage:(UIImage*)image;
- (void) StopAnimation;
- (void) timerCallback;
- (void) animateImageTo;
- (void) animateImageFrom;
-(void) longPress:(UILongPressGestureRecognizer*) rec;
@property (nonatomic,assign) id<PLSegmentCellDelegate> delegate;
@end

@protocol PLSegmentCellDelegate <NSObject>

-(void) didLongPressed:(PLSegmentCell*) cell;

@end


