//
//  SeequMessageItemCell.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 1/24/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import "SeequMessageItemCell.h"
#import "Common.h"
#import "idoubs2AppDelegate.h"
#import "CDMessageOwner.h"

#define MESSAGE_FONT_SIZE 15
#define MESSAGE_VIDEO_INDICATOR_VIEW_TAG  2014
static BOOL _recognizerHandler=NO;
static NSString* ownSeequId = nil;
@interface SeequMessageItemCell ()
@property (nonatomic,retain) UIActivityIndicatorView* activityIndicator;
@property (nonatomic,retain) CDMessage* message;
@property (nonatomic,retain) UIImage* messageImage;
@end
@implementation SeequMessageItemCell

@synthesize imageViewCellBG;
@synthesize activityIndicator;
@synthesize delegate;
@synthesize isEditable;
@synthesize touchGesture;
@synthesize message =_message;
@synthesize  messageImage = _messageImage;
@synthesize needToDelete = _needToDelete;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.isEditable = NO;
        self.accessoryType =UITableViewCellAccessoryNone;
        if (!ownSeequId) {
            ownSeequId = [[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_IMPI"];
        }
        
    }
    return self;
}
///@note  this workaround  made  because  possible  bug  in the  IOS7
-(void) setTextField{
    if (self.messageText) {
        [self.messageText removeFromSuperview];
        self.messageText = nil;
    }
    self.messageText = [[UITextView alloc] init];
    self.messageText.backgroundColor = [UIColor clearColor];
    self.messageText.dataDetectorTypes =UIDataDetectorTypeLink;
    [self addSubview:_messageText];
    self.messageText.delegate=self;
    self.messageText.editable=NO;
    self.messageText.exclusiveTouch=YES;
    self.messageText.scrollEnabled=NO;
    [self.messageText sizeToFit];
 //   [self.messageText addGestureRecognizer:touchGesture];
    
    self.messageText.font=[UIFont fontWithName:@"Helvetica" size:MESSAGE_FONT_SIZE];
}

- (void)awakeFromNib {
    [super awakeFromNib];
//    touchGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
//    touchGesture.delegate=self;
    [self setTextField];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.imageButton addSubview:activityIndicator];
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    activityIndicator.hidesWhenStopped = YES;
    ///@todo delete
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectImage:) name:@"ContactObjectImageMessage" object:nil];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageLoadStarted:) name:@"ImageLoadStarted" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageLoadFinished:) name:@"ImageLoadFinished" object:nil];
    self.accessoryView.backgroundColor = [UIColor clearColor];
    self.messageText.contentInset = UIEdgeInsetsMake(-5, -5, 0, 0);
    
}

//-(void) imageLoadStarted:(NSNotification *)notif {
//    MessageItem*  item = [notif object];
//    if ([item isEqual:self.messageItem]) {
//        [self.activityIndicator startAnimating];
//    }
//}
//
//-(void) imageLoadFinished:(NSNotification *)notif {
////    MessageItem*  item = [notif object];
////    if ([item isEqual:self.messageItem]) {
////        [self setActivityStarted];
////        [self setMessagePhoto:self.messageItem.messageImage];
////    }
//}
//
//
//- (void) onContactObjectImage:(NSNotification *)notif {
//    NSDictionary *dict = [notif object];
/////@todo
////    if ([[dict objectForKey:@"seequID"] isEqualToString:self.messageItem.contactID]) {
////        self.userImage = [dict objectForKey:@"image"];
////        
////    }
//}


- (UIImage*) getThumbImage:(UIImage*)img {
    int imageWeight = ((TUMB_IMAGE_HEIGHT/2)*img.size.width)/img.size.height;
    int imageHeight = 100;
    
        if (imageWeight > [self TUMB_IMAGE_MAX_WIDTH_PORTRAIT]) {
            imageWeight = [self TUMB_IMAGE_MAX_WIDTH_PORTRAIT];
            imageHeight = (imageWeight*img.size.height)/img.size.width;
        }
    UIImage *newImage = [self imageWithImage:img scaledToSize:CGSizeMake(imageWeight, imageHeight)];
    return  newImage;
}

- (UIImage *)imageWithImage:(UIImage *)image_ scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image_ drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void) setMessagePhoto {
    [self.imageButton setImage:nil forState:UIControlStateNormal];
    Message_Type  type =[self.message.messageType integerValue];
    if (type == Message_Type_Image||type == Message_Type_Video || type == Message_Type_Video_Response || type == Message_Type_Double_Take) {

        self.messageImage =[UIImage imageWithData:self.message.thumbnail ];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageButton setBackgroundImage:self.messageImage forState:UIControlStateNormal];
            if (type != Message_Type_Image) {
                [self.imageButton setImage:[UIImage imageNamed:@"seequPlayVideo"] forState:UIControlStateNormal];
            }
            [self setNeedsLayout];
        });
    }

//    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
//    dispatch_async(myQueue, ^{
//        if ([weakSelf.message.isGroup boolValue]) {
//            if (weakSelf.message.senderFromGroup.) {
//                []
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if
//                [weakSelf.imageButton setBackgroundImage:image forState:UIControlStateNormal];
//                   weakSelf.imageButton.enabled = YES;
//                [weakSelf updateImage];
//            });
//            
//            
//        } else {
//            //    [self.imageButton setBackgroundImage:nil forState:UIControlStateNormal];
//            [weakSelf.imageButton setBackgroundColor:[UIColor darkGrayColor]];
//            weakSelf.imageButton.enabled = NO;
//            [weakSelf.imageButton setImage:nil forState:UIControlStateNormal];
//            if (weakSelf.messageItem.type == Message_Type_Video ||weakSelf.messageItem.type == Message_Type_Video_Response||self.messageItem.type == Message_Type_Double_Take) {
//                ///@todo set video image
//                weakSelf.imageButton.enabled = YES;
//                //            [self.imageButton setBackgroundColor:[UIColor clearColor]];
//                //            [self.imageButton setBackgroundImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf.imageButton setBackgroundColor:[UIColor clearColor]];
//                    [weakSelf.imageButton setBackgroundImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
//                });
//                
//            }
//        }
//    });

//    dispatch_async(myQueue, ^{
//        if (_message.se) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf.imageButton setBackgroundImage:image forState:UIControlStateNormal];
////                if(weakSelf.messageItem.type==Message_Type_Double_Take||weakSelf.messageItem.type==Message_Type_Video||weakSelf.messageItem.type==Message_Type_Video_Response){
////                    [weakSelf.imageButton setImage:[UIImage imageNamed:@"seequPlayVideo"] forState:UIControlStateNormal];
////                }else{
////                    [weakSelf.imageButton setImage:nil forState:UIControlStateNormal];
////                    
////                }
//                weakSelf.imageButton.enabled = YES;
//                [weakSelf updateImage];
//            });
//            
//            
//        } else {
//            //    [self.imageButton setBackgroundImage:nil forState:UIControlStateNormal];
//            [weakSelf.imageButton setBackgroundColor:[UIColor darkGrayColor]];
//            weakSelf.imageButton.enabled = NO;
//            [weakSelf.imageButton setImage:nil forState:UIControlStateNormal];
//            if (weakSelf.messageItem.type == Message_Type_Video ||weakSelf.messageItem.type == Message_Type_Video_Response||self.messageItem.type == Message_Type_Double_Take) {
//                ///@todo set video image
//                weakSelf.imageButton.enabled = YES;
//                //            [self.imageButton setBackgroundColor:[UIColor clearColor]];
//                //            [self.imageButton setBackgroundImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf.imageButton setBackgroundColor:[UIColor clearColor]];
//                    [weakSelf.imageButton setBackgroundImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
//                });
//                
//            }
//        }
//    });
}
//
-(void) setActivityStarted {
    
    (![_message.isSend boolValue] && [_message.isNative boolValue])?[self.activityIndicator startAnimating]:[self.activityIndicator stopAnimating];
}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//    
//    // Configure the view for the selected state
//}

-(void) updateImage {
     if ([self.message.senderContact.seequId isEqualToString:[Common sharedCommon].contactObject.SeequID]) {
        if ( self.messageImage) {
            self.imageButton.frame = CGRectMake(self.frame.size.width - self.messageImage.size.width - 55, 5,self.messageImage.size.width, self.messageImage.size.height);
        }
        
    } else {
            self.imageButton.frame = CGRectMake(80, 5, self.messageImage.size.width, self.messageImage.size.height);
        
    }
    
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated {
    if ([self.message.isNative boolValue]) {
        self.labelDate.hidden = editing;
        self.acceptedImageView.hidden = editing;
        self.checkButton.hidden = !editing;
        self.avatarBorder.hidden = NO;
        self.avatarButton.hidden = NO;
        
    } else {
        self.avatarBorder.hidden = editing;
        self.avatarButton.hidden = editing;
        self.checkButton.hidden = !editing;
        self.labelDate.hidden = NO;
        self.acceptedImageView.hidden = YES;
        
    }
    if (!self.needToDelete) {
        [self.checkButton setBackgroundImage:[UIImage imageNamed:@"SeequButtonUncheck.png"] forState:UIControlStateNormal];
    } else {
        [self.checkButton setBackgroundImage:[UIImage imageNamed:@"SeequButtonCheck.png"] forState:UIControlStateNormal];
    }
    
}



-(void) layoutSubviews {
    [super layoutSubviews];
    CGFloat origin =0;
    Message_Type type = [_message.messageType intValue];
    if (type == Message_Type_Image ||
        type == Message_Type_Video||
        type == Message_Type_Video_Response||
        type == Message_Type_Double_Take) {
        origin += 105;
        self.imageButton.hidden = NO;
        
    } else {
        self.imageButton.hidden = YES;
    }
    if([_message.isNative boolValue]){
        self.avatarBorder.frame = CGRectMake(self.frame.size.width -45, 3, 40, 40);
        self.avatarButton.frame = CGRectMake(self.frame.size.width -43, 5, 36, 36);
        self.labelDate.frame = CGRectMake(0, 3, 50, 18);
        
    } else {
        self.avatarBorder.frame = CGRectMake(5, 3, 40, 40);
        self.avatarButton.frame = CGRectMake(7, 5, 36, 36);
        self.labelDate.frame = CGRectMake(self.frame.size.width -50, 3, 50, 18);
        
    }
    [self updateImage];
    //    NSLog(@"--------------- %@ -------------------------",NSStringFromCGRect(self.imageButton.frame));
    
    self.activityIndicator.frame = self.imageButton.bounds;
    
    
    self.messageText.frame = CGRectMake(52, origin, self.frame.size.width - 100, [SeequMessageItemCell getStringHeight:_message.textMessage forWidth:self.frame.size.width -115] + 20);
    
    
}
- (int) TUMB_IMAGE_MAX_WIDTH_PORTRAIT {
    return [[UIScreen mainScreen] bounds].size.width - 105;
}

- (int) TUMB_IMAGE_MAX_WIDTH_LANDSCAPE {
    return [[UIScreen mainScreen] bounds].size.height - 105;
}

+ (CGFloat)getStringHeight:(NSString*)string forWidth:(int)width {
    UIFont *font_ = [UIFont fontWithName:@"Helvetica" size:MESSAGE_FONT_SIZE];
    CGSize textSize_ = [string sizeWithFont:font_
                          constrainedToSize:CGSizeMake(width, FLT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
    return textSize_.height;
}


+(CGFloat) heightForItem:(CDMessage *)item {
    CGFloat height = 0;
    if([item.messageType intValue] == Message_Type_Image ||[item.messageType intValue] == Message_Type_Video ||
       [item.messageType intValue] == Message_Type_Video_Response||[item.messageType intValue] == Message_Type_Double_Take){
        height = 110;
    }
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat width ;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        width= [idoubs2AppDelegate sharedInstance].window.frame.size.height - 115;
    } else {
        width= [idoubs2AppDelegate sharedInstance].window.frame.size.width - 115;
    }
    if (item.textMessage) {
        NSString *trimmed = [item.textMessage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (trimmed.length) {
            height += [SeequMessageItemCell getStringHeight:trimmed forWidth:width]+20;
        }

    }
    
        return  (height < 47)? 47:height;
    
}

#pragma mark -

- (IBAction)onImageClicked:(id)sender {
    if ([self.message.messageType integerValue] == Message_Type_Image) {
        [self.delegate didSelectImage:self.message];
    } else {
        [self.delegate didSelectVideo:self.message];
    }
    
}

- (IBAction)checkMessageItem:(id)sender {
    self.needToDelete = !self.needToDelete;
    [self.delegate didselectItem:self.message select:self.needToDelete];
    if (!self.needToDelete) {
        [self.checkButton setBackgroundImage:[UIImage imageNamed:@"SeequButtonUncheck.png"] forState:UIControlStateNormal];
    } else {
        [self.checkButton setBackgroundImage:[UIImage imageNamed:@"SeequButtonCheck.png"] forState:UIControlStateNormal];
    }
    
}

//-(void) getUserImage{
//    dispatch_queue_t myQueue = dispatch_queue_create("Photo QUEUE",NULL);
//    dispatch_async(myQueue, ^{
//        if (!self.userImage) {
//            if (self.messageItem.coreMessage.isGroup/* && !self.messageItem.me*/) {
//                self.userImage = [Common GetImageByPTID:self.messageItem.coreMessage.senderFromGroup.seeQuId  andHeight:48];
//
//            } else {
//                self.userImage = [Common GetImageByPTID:self.messageItem.contactID andHeight:48];
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.avatarButton setBackgroundImage:self.userImage forState:UIControlStateNormal];
//            });
//
//        }
//    });
//
//    
//}

-(void) setUserImage {
    __weak SeequMessageItemCell* weakSekf = self;
    if ([_message.isNative boolValue]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UserInfoCoreData* me = [[ContactStorage sharedInstance] getUserInfoBySeequId:ownSeequId];
            UIImage * ownImage =[UIImage imageWithData:me.userImage];
            
            [weakSekf.avatarButton setBackgroundImage:ownImage forState:UIControlStateNormal];
        });
    } else if ([_message.isGroup boolValue]) {
        if (_message.senderFromGroup.userImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSekf.avatarButton setBackgroundImage:[UIImage imageWithData:_message.senderFromGroup.userImage] forState:UIControlStateNormal];
            });
        } else {
            
        }
    } else {
        if (_message.senderContact.userInfo.userImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSekf.avatarButton setBackgroundImage:[UIImage imageWithData:_message.senderContact.userInfo.userImage] forState:UIControlStateNormal];
            });
        } else {
            
        }

        
    }
            
 
}


-(void) updateCell:(CDMessage *)message_ {
    self.message = message_;
    UIView* videoIndicator = [self.imageButton viewWithTag:MESSAGE_VIDEO_INDICATOR_VIEW_TAG];
    if (self.imageButton && videoIndicator) {
        [videoIndicator removeFromSuperview];
    }
//    self.messageItem = item;
    [self setUserImage];
    [self performSelectorInBackground:@selector(setMessagePhoto) withObject:nil];
 
    [self setTextField];
     if ([_message.isNative boolValue]) {
        [self.imageViewCellBG setImage:[UIImage imageNamed:@"SeequMessageGrayBG.png"]];
        if ([_message.senderContact.isGroup boolValue]) {
            self.acceptedImageView.hidden = YES;

        } else {
            self.acceptedImageView.hidden = NO;
            if ([_message.isDelivered boolValue]) {
                [self.acceptedImageView setImage:[UIImage imageNamed:@"messageDelivered.png"]];
            } else {
                [self.acceptedImageView setImage:[UIImage imageNamed:@"messageNotDelivered.png"]];
            }
        }
        
    } else {
        [imageViewCellBG setImage:[UIImage imageNamed:@"SeequMessageBlueBG.png"]];
        self.acceptedImageView.hidden = YES;
        
    }
    
    NSDateFormatter* sChatDate = [[NSDateFormatter alloc] init];
    [sChatDate setDateFormat:@"hh:mm"];
    self.labelDate.text = [sChatDate stringFromDate:_message.date];
    
    // detect  the type  of  message (link or not)
// JSC   NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
// JSC   NSArray *matches = nil;
    
    if (_message.textMessage) {
//   JSC     matches =[detect matchesInString:_message.textMessage options:0 range:NSMakeRange(0, [_message.textMessage length])];
    }
    [self.messageText setText:_message.textMessage];
//    self.imageButton.backgroundColor = [UIColor darkGrayColor];
//    [self.imageButton setBackgroundImage:nil forState:UIControlStateNormal];
//     self.imageButton.enabled = NO;
//    if (_messageItem.needToLoading) {
//        [_messageItem loadFile];
//    }
//    if (item.type == Message_Type_Video ||item.type == Message_Type_Video_Response||item.type == Message_Type_Double_Take) {
//        [_messageItem loadFile];
//
//        UIImageView*  videoIndicatorView = [[UIImageView alloc] initWithFrame:self.imageButton.bounds];
//        videoIndicatorView.tag = MESSAGE_VIDEO_INDICATOR_VIEW_TAG;
//        ///@todo  levon  init  with  video play  image
//        [self.imageButton addSubview: videoIndicatorView];
//        [self.activityIndicator setColor:[UIColor grayColor]];
//    }
    [self setActivityStarted];
    
    
}



- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:))
    {
        return [super canPerformAction:action withSender:sender] ;
    }
    
    return NO;
}
-(BOOL)canBecomeFirstResponder{
    return YES;
}
+(void) setRecognizerHandler:(BOOL) flag{
    _recognizerHandler = flag;
}

+(BOOL) recognizerHandler {
    return _recognizerHandler;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [SeequMessageItemCell recognizerHandler];
}
- (void) handleTapFrom: (UILongPressGestureRecognizer *)recognizer
{
    [self.delegate touchTextview:recognizer];
}

@end
