//
//  SeequRecorderTypeVIew.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 7/2/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@protocol SeequRecorderTypeViewDelegate <NSObject>

-(void) didChangeToState:(SeequRecorderType)type;

@end
@interface SeequRecorderTypeView : UIView

@property (nonatomic,assign) id<SeequRecorderTypeViewDelegate> delegate;
-(id) initWithFrame:(CGRect)frame state:(SeequRecorderType)type;

-(void) swipeLeft;
-(void) swipeRight;
@end

