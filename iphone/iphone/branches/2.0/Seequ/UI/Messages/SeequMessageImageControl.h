//
//  SeequMessageImageControl.h
//  SeequChatInpute
//
//  Created by Grigori Jlavyan on 4/9/14.
//  Copyright (c) 2014 Grigori Jlavyan. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SeequMessageImageControldelegate <NSObject>
-(void)pressDeleteButton;
-(void)pressEditButton:(BOOL)forMediaTypeVideo;
@end
@interface SeequMessageImageControl : UIView
@property (nonatomic,assign) id<SeequMessageImageControldelegate> imageControldelegate ;
@property(nonatomic,retain)UIImageView *imageView;
@property(nonatomic) BOOL isVideo;
@end
