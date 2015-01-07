//
//  IncomingCallingView.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 11/8/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"

@protocol IncomingCallViewDelegate;

@interface IncomingCallingView : UIView {
//    id<IncomingCallViewDelegate> __weak _delegate;
    int diff_retina;
}

@property (nonatomic, assign) id<IncomingCallViewDelegate> delegate;

- (id) initWithContactObject:(ContactObject*)contactObject Video:(BOOL)video;
- (void) setRatingStars:(int)stars Video:(BOOL)video;
- (void) onButtonAnswerWithCamera:(id)sender;
- (void) onButtonAnswerWithVoiceOnly:(id)sender;
- (void) onButtonAnswer:(id)sender;
- (void) onButtonReplyWithMessage:(id)sender;
- (void) onButtonDeclineCall:(id)sender;

@end

@protocol IncomingCallViewDelegate <NSObject>

@optional

- (void) didClickOnAnswerWithCamera;
- (void) didClickOnAnswerWithVoiceOnly;
- (void) didClickOnAnswer;
- (void) didClickOnReplyWithMessage;
- (void) didClickOnDeclineCall;

@end