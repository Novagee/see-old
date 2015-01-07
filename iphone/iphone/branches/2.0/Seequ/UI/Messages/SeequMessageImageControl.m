//
//  SeequMessageImageControl.m
//  SeequChatInpute
//
//  Created by Grigori Jlavyan on 4/9/14.
//  Copyright (c) 2014 Grigori Jlavyan. All rights reserved.
//

#import "SeequMessageImageControl.h"
#define deleteButtonWidth 20
#define deleteButtonHeigth 20
#define insets 3
@interface SeequMessageImageControl (){
    UIButton *deleteButton;
    BOOL deleted;
    UIButton *editButton;
}
@end

@implementation SeequMessageImageControl


- (id)initWithFrame:(CGRect)frame
{   self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor colorWithWhite:0.90 alpha:1];
        deleted=NO;
        self.imageView=[[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        deleteButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"delete_icon"]  forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(onDeleteButton)  forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteButton];
        editButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [editButton setBackgroundColor:[UIColor clearColor]];
        [editButton addTarget:self action:@selector(onButtonEdit) forControlEvents:UIControlEventTouchDown];
        [self addSubview:editButton];
        // Initialization code
    }
    return self;
}
-(void)layoutSubviews{
    if (!deleted) {
        self.imageView.frame=CGRectMake(insets, insets, self.frame.size.width-2*insets, self.frame.size.height-2*insets);
        deleteButton.frame=CGRectMake(self.imageView.frame.size.width-10,0, deleteButtonWidth, deleteButtonHeigth);
        editButton.frame=CGRectMake(0, 0, 2*deleteButtonWidth, 2*deleteButtonHeigth);
        editButton.center=self.imageView.center;
        
    }
    [self setEditButtonState];
    deleted=NO;
}
///@todo GOR rewrite
-(void)onDeleteButton{
    self.frame=CGRectZero;
    self.imageView.frame=CGRectZero;
    deleteButton.frame=CGRectZero;
    deleted=YES;
    [self.imageControldelegate pressDeleteButton];
}
-(void)onButtonEdit{
    [self.imageControldelegate pressEditButton:self.isVideo];
}
-(void)setEditButtonState{
    if(self.isVideo){
        [editButton setBackgroundImage:[UIImage imageNamed:@"seequPlayVideo" ] forState:UIControlStateNormal];
    }else{
        [editButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
}
@end
