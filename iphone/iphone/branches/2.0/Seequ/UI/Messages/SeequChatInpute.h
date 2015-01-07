//
//  ChatInpute.h
//  SeequChatInpute
//
//  Created by Grigori Jlavyan on 4/2/14.
//  Copyright (c) 2014 Grigori Jlavyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequMessageImageControl.h"


typedef enum {
    MessageViewNormalState,
    MessageViewLandscapeCallState,
}SeequSendMessageViewState ;

@protocol SeequChatInputeDelegate <NSObject>
@optional
-(void) messageViewDidChangeFrame:(CGFloat)deltaHeight withTextViewHeight:(CGFloat)textviewHeight;
-(void) pressButtonCamera;
-(void) pressButtonSendMessage;
-(void) onButtonVideo;
-(void) deleteAttachment;
-(void) editMedia:(BOOL)forMediaTypeVideo;
@end

@interface SeequChatInpute : UIView <UITextViewDelegate,SeequMessageImageControldelegate>{
    CGFloat deltaHeight;
    CGFloat textViewHeight;
    
    UIButton *buttonVideo;
}
@property(nonatomic,retain)UITextView *textview;
@property(nonatomic,retain)SeequMessageImageControl *imageControl;
@property(nonatomic,assign)id<SeequChatInputeDelegate> messageDelegate;
@property(nonatomic,assign)SeequSendMessageViewState messageViewState;
@property (nonatomic,retain) UIButton *buttonCamera;
@property (nonatomic,retain) UIButton *buttonSendMessage;
@property (nonatomic,assign) CGFloat originalHeight;


-(void)setImage:(UIImage *)image forVideo:(BOOL)isVideo;

-(CGFloat) getControlTextHeight:(CGFloat) width;

-(void) removeAttachment:(BOOL) update;
@end
