//
//  SeequMessageItemCell.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 1/24/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageItem.h"
#import "CDMessage.h"
@protocol SeequMessageItemCellDelegate <NSObject>
-(void) didSelectImage:(CDMessage*) item;
-(void) didSelectVideo:(CDMessage *)item;
-(void) didselectItem:(CDMessage*)item select:(BOOL) flag;
-(BOOL) touchTextview:(UILongPressGestureRecognizer *)recognizer;
@end


@interface SeequMessageItemCell : UITableViewCell<UITextViewDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageViewCellBG;
@property (strong, nonatomic) IBOutlet UIImageView *avatarBorder;
@property (strong, nonatomic) IBOutlet UIButton *avatarButton;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UIImageView *acceptedImageView;
@property (strong, nonatomic) UITextView *messageText;
@property (strong, nonatomic) IBOutlet UIButton *imageButton;
@property (strong, nonatomic) IBOutlet UIButton *checkButton;
@property (nonatomic) UILongPressGestureRecognizer *touchGesture;
@property (nonatomic,assign) BOOL needToDelete;




//@property ( nonatomic,retain) MessageItem*  messageItem;

@property (nonatomic,assign) id<SeequMessageItemCellDelegate> delegate;
@property (nonatomic,assign) BOOL isEditable;

- (IBAction)onImageClicked:(id)sender;
- (IBAction)checkMessageItem:(id)sender;
-(void) updateCell:(CDMessage*) item;

+(void)setRecognizerHandler:(BOOL) flag;
+(BOOL)recognizerHandler;

+(CGFloat) heightForItem:(CDMessage*) item;

@end
