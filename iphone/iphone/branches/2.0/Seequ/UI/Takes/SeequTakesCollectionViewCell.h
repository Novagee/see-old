//
//  UICollectionViewWaterfallCell.h
//  Demo
//
//  Created by Nelson on 12/11/27.
//  Copyright (c) 2012年 Nelson. All rights reserved.
//

#import <UIKit/UIKit.h>
#define VIDEO_PLAY_BUTTON_WIDTH_HEIGHT 31
#define BUTTON_INSET 5
#define BIG_LIKE_BUTTON_WIDTH 21
#define BIG_LIKE_BUTTON_HEIGHT 19.5
#define LIKE_BUTTON_WIDTH 13
#define LIKE_BUTTON_HEIGHT 12
#define COMMENT_BUTTON_WIDTH 14
#define COMMENT_BUTTON_HEIGHT 11.5
#define BUTTONS_LABLE_HEIGHT 12
#define BUTTONS_LABLE_WIDTH 21

@protocol SeequTakesCollectionViewCellDelegate

@optional

- (void) onClickLikeButton;
- (void) onClickCommentButton;
- (void) onClickBigLikeButton;
@end

@interface SeequTakesCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIImageView *videoPlayButton;
@property (nonatomic, strong) UIButton * bigLikeButton;
@property (nonatomic, strong) UILabel *lableForBigLikeButton;
@property (nonatomic, strong) UILabel *lableForLikeButton;
@property (nonatomic, strong) UILabel *lableForCommentButton;
@property (nonatomic, weak)  id<SeequTakesCollectionViewCellDelegate> delegate;

-(void)onButtonLikeClicked;
-(void)onButtonCommentClicked;
-(void)onBigLikeButtonClicked;
@end
