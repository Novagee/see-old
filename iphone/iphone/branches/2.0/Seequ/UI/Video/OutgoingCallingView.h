//
//  CallingView.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/1/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"

@protocol OutgoingCallViewDelegate;

@interface OutgoingCallingView : UIView {
//    id<OutgoingCallViewDelegate> __weak _delegate;
    int diff_retina;
    UILabel *labelCallingState;
}

@property (nonatomic, assign) id<OutgoingCallViewDelegate> delegate;

- (id) initWithContactObject:(ContactObject*)contactObject Video:(BOOL)video;
- (void) onButtonEndCall:(id)sender;
- (void) setRatingStars:(int)stars;
- (void) setCallingStateText:(NSString*)text;

@end

@protocol OutgoingCallViewDelegate <NSObject>

@optional

- (void) didClickOnEndCall;

@end