//
//  PLSegmentCell.m
//  PlutoLand
//
//  Created by xu xhan on 7/22/10.
//  Copyright 2010 xu han. All rights reserved.
//

#import "PLSegmentCell.h"

#define ANIMATION_DURATION 1.0f

@implementation PLSegmentCell
@synthesize delegate;

-(id)initWithNormalImage:(UIImage*)anormal selectedImage:(UIImage*)ahover frame:(CGRect)aframe
{
	self =  [super initWithFrame:aframe];
	imageNormal = [[UIImageView alloc] initWithImage:anormal];
	imageHover = [[UIImageView alloc] initWithImage:ahover];	 
	[self addSubview:imageNormal];
	[self addSubview:imageHover];
	self.selected = NO;
    timer = nil;
    
	return self;	
}


-(id)initWithNormalImage:(UIImage *)anormal selectedImage:(UIImage *)ahover startPoint:(CGPoint)apoint
{
	CGRect rect = CGRectMake(apoint.x, apoint.y, anormal.size.width, anormal.size.height);
	return [self initWithNormalImage:anormal selectedImage:ahover frame:rect];
}

-(id)initWithImage:(UIImage *)image background:(UIImage *)BG selectedBackground:(UIImage *)selectedBG frame:(CGRect)aframe{
    self = [super initWithFrame:aframe];
    if (self) {
        UIImage *myResizableImage = [BG resizableImageWithCapInsets:UIEdgeInsetsMake(5., 5., 5., 5.)];
        imageNormal = [[UIImageView alloc] initWithImage:myResizableImage];
        myResizableImage = [selectedBG resizableImageWithCapInsets:UIEdgeInsetsMake(5., 5., 5., 5.)];
        imageHover = [[UIImageView alloc] initWithImage:myResizableImage];
        imageTitle = [[UIImageView alloc] initWithImage:image];
        imageHover.frame = CGRectMake(0, 0, aframe.size.width, aframe.size.height);
        imageNormal.frame = CGRectMake(0, 0, aframe.size.width, aframe.size.height);
        imageTitle.frame = CGRectMake(aframe.size.width/2 -image.size.width/2,
                                                    aframe.size.height/2 - image.size.height/2,
                                      image.size.width, image.size.height);
        imageNormal.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        imageHover.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        
      [self addSubview:imageNormal];
      [self addSubview:imageHover];
        [self addSubview:imageTitle];
        self.selected = NO;
        


    }
    return self;
}


#pragma mark -
#pragma mark OverWrite for default select action and state property


- (void)setSelected:(BOOL)value
{
	[super setSelected:value];
	imageNormal.hidden = value;
	imageHover.hidden = !value;
    [self bringSubviewToFront:imageTitle];
}

- (void) StartAnimationWithImage:(UIImage*)image {
    if (timer) {
        return;
    }
    
    imgNormal = imageNormal.image;
    imgHover = imageHover.image;
    imgDefault = image;
    
    [self timerCallback];
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                             target:self
                                           selector:@selector(timerCallback)
                                           userInfo:nil
                                            repeats:YES];
}

- (void) StopAnimation {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}
-(void) longPress:(UILongPressGestureRecognizer*) rec {
    NSLog(@"long press");
    if (!self.selected) {
        [self.delegate didLongPressed:self];
    }
    
}

- (void) timerCallback {
    [self performSelector:@selector(animateImageTo) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(animateImageFrom) withObject:nil afterDelay:2.0];
}

- (void) animateImageTo {
    [UIView transitionWithView:imageNormal.hidden ? imageHover : imageNormal
                      duration:ANIMATION_DURATION
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if (imageNormal.hidden) {
                            imageHover.image = imgDefault;
                        } else {
                            imageNormal.image = imgDefault;
                        }
                    } completion:NULL];
}

- (void) animateImageFrom {
    [UIView transitionWithView:imageNormal.hidden ? imageHover : imageNormal
                      duration:ANIMATION_DURATION
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if (imageNormal.hidden) {
                            imageHover.image = imgNormal;
                        } else {
                            imageNormal.image = imgHover;
                        }
                    } completion:NULL];
}

- (void) dealloc {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}


@end