//
//  UICollectionViewWaterfallCell.m
//  Demo
//
//  Created by Nelson on 12/11/27.
//  Copyright (c) 2012年 Nelson. All rights reserved.
//

#import "SeequTakesCollectionViewCell.h"

@implementation SeequTakesCollectionViewCell


@synthesize imageView = _imageView;
@synthesize likeButton = _likeButton;
@synthesize commentButton = _commentButton;
@synthesize videoPlayButton = _videoPlayButton;
@synthesize bigLikeButton = _bigLikeButton;
@synthesize lableForBigLikeButton = _lableForBigLikeButton;
@synthesize lableForCommentButton = _lableForCommentButton;
@synthesize lableForLikeButton =_lableForLikeButton;
@synthesize  delegate;
#pragma mark - Accessors



#pragma mark - Life Cycle
- (void)dealloc {
	
}

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _imageView.image = [UIImage imageNamed:@"decorationImage"];
        
        [_imageView.layer setCornerRadius:11.0f];
        [_imageView.layer setMasksToBounds:YES];
        _imageView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:_imageView];
        
//        _likeButton = [[UIButton alloc] initWithFrame:CGRectZero];
//        [_likeButton addTarget:self action:@selector(onButtonLikeClicked) forControlEvents:UIControlEventTouchUpInside];
//        //[likeButton setBackgroundImage:[UIImage imageNamed:@"takesCellLikeButton"] forState:UIControlEventAllEvents];
//        [_likeButton setImage:[UIImage imageNamed:@"takesCellLikeButton"] forState:UIControlStateNormal];
//        //likeButton.backgroundColor = [UIColor greenColor];
//        [self.contentView addSubview:_likeButton];
//        
//        
//        _commentButton = [[UIButton alloc] initWithFrame:CGRectZero];
//        [_commentButton addTarget:self action:@selector(onButtonCommentClicked) forControlEvents:UIControlEventTouchUpInside];
//        [_commentButton setImage:[UIImage imageNamed:@"takesCellCommentButton"] forState:UIControlStateNormal];
//       // commentButton.backgroundColor = [UIColor blueColor];
//        [self.contentView addSubview:_commentButton];
        
        _videoPlayButton = [[UIImageView alloc]initWithFrame:CGRectZero];
        _videoPlayButton.image = [UIImage imageNamed:@"videoPlayButton" ];
        [self.contentView addSubview:_videoPlayButton];
        
//        _lableForBigLikeButton = [[UILabel alloc] initWithFrame:CGRectZero];
//        [_lableForBigLikeButton setFont:[UIFont systemFontOfSize:12]];
//        _lableForBigLikeButton.backgroundColor = [UIColor clearColor];
//        //_lableForBigLikeButton.backgroundColor = [UIColor redColor];
//        _lableForBigLikeButton.textColor = [UIColor whiteColor];
//        ///@todo Toros
//        [_lableForBigLikeButton setText:@"333"];
//        ///
//        
//        [self.contentView addSubview:_lableForBigLikeButton];
//        
//        _lableForLikeButton = [[UILabel alloc] initWithFrame:CGRectZero];
//        [_lableForLikeButton setFont:[UIFont systemFontOfSize:12]];
//        _lableForLikeButton.backgroundColor = [UIColor clearColor];
//        _lableForLikeButton.textColor = [UIColor whiteColor];
//        ///@todo Toros
//        [_lableForLikeButton setText:@"333"];
//        ///
//        [self.contentView addSubview:_lableForLikeButton];
//        
//        _lableForCommentButton = [[UILabel alloc] initWithFrame:CGRectZero];
//        [_lableForCommentButton setFont:[UIFont systemFontOfSize:12]];
//        _lableForCommentButton.backgroundColor = [UIColor clearColor];
//        self.lableForCommentButton.textColor = [UIColor whiteColor];
//        ///@todo Toros
//        _lableForCommentButton.text = @"3";
//        ///
//        [self.contentView addSubview:_lableForCommentButton];
//        _bigLikeButton = [[UIButton alloc] initWithFrame:CGRectZero];
//        //[BigLikeButton setBackgroundImage:[UIImage imageNamed:@"bigLikeButtonForTakesCell"] forState:UIControlStateNormal];
//        [_bigLikeButton setImage:[UIImage imageNamed:@"bigLikeButtonForTakesCell"] forState:UIControlStateNormal];
//       [_bigLikeButton addTarget:self action:@selector(onBigLikeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_bigLikeButton];
    }
	return self;
}
-(void) layoutSubviews {
    _imageView.frame = self.contentView.bounds;
    
    _videoPlayButton.frame = CGRectMake(self.contentView.bounds.size.width - VIDEO_PLAY_BUTTON_WIDTH_HEIGHT - BUTTON_INSET/2, BUTTON_INSET, VIDEO_PLAY_BUTTON_WIDTH_HEIGHT, VIDEO_PLAY_BUTTON_WIDTH_HEIGHT);
    
    _likeButton.frame = CGRectMake(BUTTON_INSET, self.contentView.bounds.size.height - LIKE_BUTTON_HEIGHT - BUTTON_INSET, LIKE_BUTTON_WIDTH, LIKE_BUTTON_HEIGHT);
    
    _lableForLikeButton.frame = CGRectMake(_likeButton.frame.size.width + 2 * BUTTON_INSET, self.contentView.bounds.size.height - BUTTONS_LABLE_HEIGHT - BUTTON_INSET, BUTTONS_LABLE_WIDTH, BUTTONS_LABLE_HEIGHT);
    
    _commentButton.frame = CGRectMake(_likeButton.frame.size.width + BUTTONS_LABLE_WIDTH + 3 * BUTTON_INSET, self.contentView.bounds.size.height -
                                          COMMENT_BUTTON_HEIGHT - BUTTON_INSET, COMMENT_BUTTON_WIDTH, COMMENT_BUTTON_HEIGHT);
    
   _lableForCommentButton.frame = CGRectMake(_likeButton.frame.size.width + _lableForLikeButton.frame.size.width + _commentButton.frame.size.width + 4 * BUTTON_INSET ,self.contentView.bounds.size.height - BUTTONS_LABLE_HEIGHT - BUTTON_INSET, BUTTONS_LABLE_WIDTH, BUTTONS_LABLE_HEIGHT);
    
    
    _bigLikeButton.frame = CGRectMake(self.contentView.bounds.size.width - BIG_LIKE_BUTTON_WIDTH  - BUTTON_INSET, self.contentView.bounds.size.height - BUTTONS_LABLE_HEIGHT - BIG_LIKE_BUTTON_HEIGHT - 2 * BUTTON_INSET , BIG_LIKE_BUTTON_WIDTH, BIG_LIKE_BUTTON_HEIGHT);
    
    _lableForBigLikeButton.frame = CGRectMake(self.contentView.bounds.size.width - BUTTONS_LABLE_WIDTH - BUTTON_INSET, self.contentView.bounds.size.height - BUTTONS_LABLE_HEIGHT -  BUTTON_INSET, BUTTONS_LABLE_WIDTH, BUTTONS_LABLE_HEIGHT);

    
}
-(void)onButtonLikeClicked{
    
    [delegate onClickLikeButton];
}

-(void)onButtonCommentClicked{
    [delegate onClickCommentButton];
}
- (void) onBigLikeButtonClicked{
    [delegate onClickBigLikeButton];
}

@end
