//
//  CustomImageView.h
//  ProTime
//
//  Created by Norayr on 10/08/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomImageViewDelegate;

@interface CustomImageView : UIImageView
@property (nonatomic, assign) id<CustomImageViewDelegate> delegate;
@end

@protocol CustomImageViewDelegate <NSObject>

@optional

- (void) didChangeFrame:(CustomImageView*)customImageView;

@end