//
//  SeequViewForDragToDropbox.h
//  ProTime
//
//  Created by Grigori Jlavyan on 7/29/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SeequViewForDragDelegate <NSObject>
-(void)dragViewDraggedToPoint:(CGPoint)newPoint;
-(void)dragViewTouchesEnded;
-(void)dragViewMovedToBottomBorder;
-(void)dragViewMovedToTopBorder;
-(void)dragViewMovedFromTopOrBottomBorders;
@end
@interface SeequViewForDragToDropbox : UIView<UIGestureRecognizerDelegate>{
        CGPoint nowPoints ;
        UIImageView *imageView;
}
@property (nonatomic)id<SeequViewForDragDelegate> delegate;
-(void)setImage:(UIImage*)image;
-(void)drageViewDropid;
@end
