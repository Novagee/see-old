//
//  SeequViewForDragToDropbox.m
//  ProTime
//
//  Created by Grigori Jlavyan on 7/29/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequViewForDragToDropbox.h"
#define DRAGGING_VIEW_HEIGHT 60
#define DRAGGING_VIEW_WIDTH  60
@implementation SeequViewForDragToDropbox

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
            imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            self.layer.masksToBounds=YES;
            imageView.contentMode=UIViewContentModeScaleAspectFill;
            imageView.userInteractionEnabled=YES;
            imageView.layer.cornerRadius=imageView.frame.size.height/4;
            imageView.layer.masksToBounds=YES;
            imageView.layer.borderWidth=0;
            imageView.layer.shadowColor=[UIColor grayColor].CGColor;
            [self addSubview:imageView];
    }
    return self;
}
-(void)setImage:(UIImage *)image{
        imageView.image=image;
}

-(void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	nowPoints = [[touches anyObject] locationInView:self];
        self.alpha=0.7;
        imageView.layer.borderWidth=1;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
        [UIView beginAnimations:@"drag" context:nil];
        [UIView setAnimationDuration:0.2];
                CGPoint _touchedPoints = [[touches anyObject] locationInView:self];
                CGPoint _newPoints     = CGPointMake(self.center.x + (_touchedPoints.x - nowPoints.x),
                                                     self.center.y + (_touchedPoints.y - nowPoints.y));

                CGFloat _midX = CGRectGetMidX(self.bounds);
                CGFloat _midY = CGRectGetMidY(self.bounds);
                CGSize _superviewBoundsSize = self.superview.frame.size;
            
                if (_newPoints.x > _superviewBoundsSize.width  - _midX)
                {
                        _newPoints.x = _superviewBoundsSize.width - _midX;
                }
                else if (_newPoints.x < _midX)
                {
         
                        _newPoints.x = _midX;
                }
                
                if (_newPoints.y > _superviewBoundsSize.height  - _midY)
                {
                        _newPoints.y = _superviewBoundsSize.height -_midY;
                        if ([self.delegate respondsToSelector:@selector(dragViewMovedToBottomBorder)]) {
                                [self.delegate dragViewMovedToBottomBorder];
                        }
                        
                }
                else if (_newPoints.y < _midY)
                {
                        _newPoints.y = _midY;
                        if ([self.delegate respondsToSelector:@selector(dragViewMovedToTopBorder)]) {
                                [self.delegate dragViewMovedToTopBorder];
                        }
                        
                }
                else if(_newPoints.y>_midY && _newPoints.y <_superviewBoundsSize.height  - _midY &&(self.center.y==_midY || self.center.y==_superviewBoundsSize.height -_midY)){
                        if ([self.delegate respondsToSelector:@selector(dragViewMovedFromTopOrBottomBorders)]) {
                                [self.delegate dragViewMovedFromTopOrBottomBorders];
                        }
                }
                                self.center = _newPoints;

                [self.delegate dragViewDraggedToPoint:self.center];
        [UIView commitAnimations];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
        self.alpha=1;
        imageView.layer.borderWidth=0;
        [self.delegate dragViewTouchesEnded];
}
-(void)drageViewDropid{
        [UIView beginAnimations:@"drop" context:nil];
        [UIView setAnimationDuration:0.5];
        self.alpha=0;
        [UIView commitAnimations];
}


@end
