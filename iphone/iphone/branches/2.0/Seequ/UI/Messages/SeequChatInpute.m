//
//  ChatInpute.m
//  SeequChatInpute
//
//  Created by Grigori Jlavyan on 4/2/14.
//  Copyright (c) 2014 Grigori Jlavyan. All rights reserved.
//

#import "SeequChatInpute.h"
#import "Common.h"

#define imageViewSize 65
#define cameraButtonWith 33
#define sendButtonWith 61
#define inset 5
#define smalVideoWith 82
#define minTextViewHeight 50
@interface SeequChatInpute () {
    CGFloat imageHeight;
}
@property (nonatomic,assign) CGFloat maxHeight;
@end

@implementation SeequChatInpute

@synthesize originalHeight;
@synthesize maxHeight;
@synthesize messageViewState;
@synthesize  buttonCamera = _buttonCamera;
@synthesize buttonSendMessage = _buttonSendMessage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageHeight = 0;
        _buttonCamera=[UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonCamera addTarget:self action:@selector(onButtonCamera) forControlEvents:UIControlEventTouchUpInside];
        UIImage*image = [UIImage imageNamed:@"seequMessageCameraIcon.png"];
        _buttonCamera.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [_buttonCamera setBackgroundImage:image forState:UIControlStateNormal];
        [self addSubview:_buttonCamera];
        _buttonSendMessage=[UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonSendMessage addTarget:self action:@selector(onButtonSendMessage) forControlEvents:UIControlEventTouchUpInside];
        image =[UIImage imageNamed:@"SeequButtonMessageSendOK.png"] ;
        [_buttonSendMessage setBackgroundImage: image forState:UIControlStateNormal];
        _buttonSendMessage.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [self addSubview:_buttonSendMessage];
        buttonVideo=[UIButton buttonWithType:UIButtonTypeCustom ];
        [buttonVideo setBackgroundImage:[UIImage imageNamed:@"seequButtonVideoOnMessage"] forState:UIControlStateNormal];
        [buttonVideo addTarget:self action:@selector(pressButtonVideo) forControlEvents:UIControlEventTouchUpInside];
        buttonVideo.frame=CGRectZero;
        buttonVideo.hidden=YES;
        [self addSubview:buttonVideo];
        self.originalHeight = frame.size.height;
        self.imageControl=[[SeequMessageImageControl alloc] initWithFrame:CGRectZero];
        self.imageControl.imageControldelegate=self;
        self.imageControl.hidden=YES;
        self.textview=[[UITextView alloc] init];
        deltaHeight=0;
        self.maxHeight = 95;
        self.textview.delegate=self;
        self.textview.scrollEnabled=YES;
        self.backgroundColor=[UIColor colorWithWhite:0.9 alpha:1];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.textview.backgroundColor=[UIColor whiteColor];
        self.textview.autocorrectionType = UITextAutocorrectionTypeYes;
        self.textview.textAlignment = NSTextAlignmentLeft;
        self.textview.font = [UIFont systemFontOfSize:15];
        self.textview.showsHorizontalScrollIndicator=NO;
        self.textview.textContainerInset = UIEdgeInsetsMake(inset,inset,inset,inset);
        self.textview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        textViewHeight=[self textViewHeightForAttributedText:self.textview.attributedText andWidth:self.textview.frame.size.width];
        textViewHeight = textViewHeight < 48?48:textViewHeight;
        [self addSubview:self.textview];
        self.autoresizesSubviews = YES;
        self.autoresizingMask =UIViewAutoresizingFlexibleWidth;
    }
    return self;
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
}

-(void) pressButtonVideo {
    [self.messageDelegate onButtonVideo];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.messageViewState== MessageViewNormalState) {
        buttonVideo.hidden=YES;
        buttonVideo.frame=CGRectZero;
        CGFloat tempWidth = self.frame.size.width - 4*inset - _buttonCamera.frame.size.width - _buttonSendMessage.frame.size.width;
        CGFloat tempHeight = [self textViewHeightForAttributedText:self.textview.attributedText andWidth:tempWidth] + imageHeight;
        tempHeight =tempHeight < minTextViewHeight ? minTextViewHeight:tempHeight;
        tempHeight = tempHeight > maxHeight? maxHeight :tempHeight;
        self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height - tempHeight, self.frame.size.width,tempHeight);
        _buttonCamera.frame=CGRectMake(self.frame.origin.x+inset,self.frame.size.height-_buttonCamera.frame.size.height-inset -3, _buttonCamera.frame.size.width, _buttonCamera.frame.size.height );
        _buttonSendMessage.frame=CGRectMake(self.frame.size.width-_buttonSendMessage.frame.size.width-inset, self.frame.size.height-_buttonCamera.frame.size.height-inset -2, _buttonSendMessage.frame.size.width, _buttonCamera.frame.size.height);
        self.textview.frame = CGRectZero;
        self.textview.frame=CGRectMake(_buttonCamera.frame.size.width + 2*inset, 8 , tempWidth, self.frame.size.height - 16);
    }else{
        buttonVideo.hidden=NO;
        CGFloat tempWidth = self.frame.size.width - 2*smalVideoWith - 3*inset -  _buttonSendMessage.frame.size.width;
        CGFloat tempHeight = [self textViewHeightForAttributedText:self.textview.attributedText andWidth:tempWidth] + imageHeight;
        tempHeight =tempHeight < minTextViewHeight ? minTextViewHeight:tempHeight;
        tempHeight = tempHeight > maxHeight? maxHeight :tempHeight;
        self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height - tempHeight, self.frame.size.width,tempHeight);
        buttonVideo.frame=CGRectMake(self.frame.size.width-smalVideoWith,self.frame.size.height-self.originalHeight,smalVideoWith, self.originalHeight);
        _buttonCamera.frame=CGRectMake(self.frame.origin.x+smalVideoWith -inset-_buttonCamera.frame.size.width,self.frame.size.height-_buttonCamera.frame.size.height-inset, _buttonCamera.frame.size.width, _buttonCamera.frame.size.height);
        _buttonSendMessage.frame=CGRectMake(self.frame.size.width-_buttonSendMessage.frame.size.width-inset-smalVideoWith, self.frame.size.height-_buttonCamera.frame.size.height-inset, _buttonSendMessage.frame.size.width, _buttonCamera.frame.size.height);
        self.textview.frame=CGRectMake(smalVideoWith + inset,8,tempWidth, self.frame.size.height - 16);
    }
    if (!self.imageControl.hidden ||self.textview.text.length) {
        [_buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSend.png"] forState:UIControlStateNormal];
    }else{
        [_buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSendOK.png"] forState:UIControlStateNormal];
    }
    NSLog(@" the  size of  control %@" , NSStringFromCGRect(self.frame));
}

- (void)textViewDidChange:(UITextView *)textView{
    if (self.textview.text.length || !self.imageControl.hidden) {
        [_buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSend.png"] forState:UIControlStateNormal];
    } else {
        [_buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSendOK.png"] forState:UIControlStateNormal];
    }
    CGFloat newHeight=[self textViewHeightForAttributedText:self.textview.attributedText andWidth:self.textview.frame.size.width];
    if (newHeight < minTextViewHeight) {
        newHeight = minTextViewHeight;
    }
    if ((newHeight > self.textview.frame.size.height )  && newHeight <= textViewHeight) {
        deltaHeight = 0;
        textViewHeight=newHeight;
    } else {
        deltaHeight=newHeight-textViewHeight;
        textViewHeight=newHeight;
    }
    
    if (deltaHeight!=0) {
        NSLog(@"delta height %f",deltaHeight);
        [self setNeedsLayout];
    }
}
-(CGFloat) calculateTextWidth:(CGFloat) width {
    if (self.messageViewState== MessageViewNormalState){
        return  width - 4*inset -sendButtonWith - cameraButtonWith;
    } else {
        return  width - 4*inset -sendButtonWith - cameraButtonWith -smalVideoWith;
    }
}
-(CGFloat) getControlTextHeight:(CGFloat) width{
    ///@todo get proper width  depend  on  state
    CGFloat realWidth = [self calculateTextWidth:width];
    return [self textViewHeightForAttributedText:self.textview.attributedText andWidth:realWidth] +2*inset;
}
-(void)onButtonCamera{
    [self.messageDelegate pressButtonCamera];
}
-(void)onButtonSendMessage{
    [_buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSendOK.png"] forState:UIControlStateNormal];
    [self.imageControl setNeedsLayout];
    [self.messageDelegate pressButtonSendMessage];
}

-(void) removeAttachment:(BOOL) update{
    imageHeight = 0;
    self.textview.textContainerInset=UIEdgeInsetsMake(inset, inset, inset, inset);
    deltaHeight=self.imageControl.frame.size.height;
    if (update) {
        [self.messageDelegate deleteAttachment];
        
    }
    self.imageControl.hidden = YES;
    [self setNeedsLayout];
    
}
#pragma SeequMessageImageControldelegate
-(void)pressDeleteButton{
    [self removeAttachment:YES];
}
-(void)pressEditButton:(BOOL)forMediaTypeVideo{
    [self.messageDelegate editMedia:forMediaTypeVideo];
}
-(void)setImage:(UIImage *)image forVideo:(BOOL)isVideo{
    self.imageControl.frame=CGRectMake(2, 2, imageViewSize,imageViewSize);
    self.imageControl.imageView.image=image;
    self.imageControl.isVideo=isVideo;
    imageHeight = 75;
    self.imageControl.hidden = NO;
    [self.imageControl setNeedsLayout];
    self.textview.textContainerInset=UIEdgeInsetsMake(75, inset, inset, inset);
    deltaHeight=self.imageControl.frame.size.height;
    [self.textview addSubview:self.imageControl];
    [self setNeedsLayout];
}
///@todo  gor  NEVER  aloc  UItext field to calculate  text height
-(CGFloat)textViewHeightForAttributedText: (NSAttributedString*)text andWidth: (CGFloat)width {
    UITextView *calculationView = [[UITextView alloc] init];
    //  calculationView.textContainerInset = UIEdgeInsetsMake(inset,inset,inset,inset);
    [calculationView setAttributedText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    CGSize resultSize = CGSizeMake(width, size.height + imageHeight);
    return resultSize.height;
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (sender.contentOffset.x != 0) {
        CGPoint offset = sender.contentOffset;
        offset.x = 0;
        sender.contentOffset = offset;
    }
}
@end
