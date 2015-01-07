//
//  PLSegmentView.h
//  PlutoLand
//
//  Created by xu xhan on 7/22/10.
//  Copyright 2010 xu han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLSegmentCell.h"

@protocol PLSegmentViewDelegate<NSObject>

@optional

- (void)segmentClickedAtIndex:(int)index onCurrentCell:(BOOL)isCurrent;
- (void)segmentDoubleClicked;
- (void)segmentShowCallMenu;
- (void)segmentDidClickedOnLastTab;

@end


@class PLSegmentCell;
@protocol PLSegmentCellDelegate ;

@interface PLSegmentView : UIView<PLSegmentCellDelegate> {
	NSMutableArray* _items;
	UIImageView* _backgroundImageView;
	//BOOL _isMultyCellSelectable; //TODO:add a subClass then support this feature
	int _selectedIndex;
	
//	id<PLSegmentViewDelegate> __weak delegate;
    BOOL state_inCall;
    BOOL state_showProfile;
    CGFloat tabWidth;
    UIImage *imageAnimationBG;

}

@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, assign) int selectedIndex;
@property (nonatomic, assign) CGFloat tabWidth;
@property (nonatomic, assign) id<PLSegmentViewDelegate> delegate;

- (void)segmentDemo1TabBar;
- (void)segmentDemoVideoTabBar;
- (void)segmentDemoVideoSelectedTabBar;
- (void)segmentDemoAudioTabBar;
- (void)segmentDemoAudioSelectedTabBar;
- (void)segmentDemoOnHoldTabBar;
- (void)StartAnimation;
- (void)StopAnimation;

- (void)setupCellsByImagesName:(NSArray*)images selectedImagesName:(NSArray*)selectedImages offset:(CGSize)offset;

- (void)setupCellsByImagesName:(NSArray*)images selectedImagesName:(NSArray*)selectedImages offset:(CGSize)offset startPosition:(CGPoint)point;
- (void) setupCellsByImagesName:(NSArray *)images normalImage:(UIImage*) normalImage selectedImage:(UIImage*)selectedImage offset:(CGSize)offset;
- (void) setupCellsByImagesName:(NSArray *)images normalImage:(UIImage*) normalImage selectedImage:(UIImage*)selectedImage offset:(CGSize)offset startPosition:(CGPoint) point;
-(void) setupCellsByImagesName:(NSArray *)images normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage lastSelectedImage:(UIImage *)lastSelectedImage offset:(CGSize)offset startPosition:(CGPoint)point;

- (void)addCells:(NSArray*)cells;

- (void)addCell:(PLSegmentCell*)cell;
- (void) setInCall:(BOOL)inCall;
- (void) setShowProfile:(BOOL)showProfile;

@end
