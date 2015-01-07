//
//  TBIDefaultBadgView.h
//  ProTime
//
//  Created by Artak on 6/3/11.
//  Copyright 2011 doubango. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BadgViewDelegate;

@interface TBIDefaultBadgView : UIView {
//    id<BadgViewDelegate> __weak _delegate;
    UILabel *lblText;
    UIImageView *imgViewLeft;
    UIImageView *imgViewMiddle;
    UIImageView *imgViewRight;
}

@property (nonatomic, assign) id<BadgViewDelegate> delegate;

- (void)SetText:(NSString*)text;
- (NSString*)GetValue;
- (void)IncrementBagdValue;
- (void)DecrementBagdValue;


@end

@protocol BadgViewDelegate <NSObject>

@optional

-(void)didSelectBadgView:(TBIDefaultBadgView*)badg;

@end