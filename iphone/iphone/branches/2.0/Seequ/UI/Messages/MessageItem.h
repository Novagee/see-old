//
//  MessageItem.h
//  ProTime
//
//  Created by Karen on 10/25/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
#import "CDMessage.h"

@protocol MessageItemDelegate;

@interface MessageItem : NSObject <UIWebViewDelegate>{
//    id<MessageItemDelegate> __unsafe_unretained _delegate;
    
//    UIWebView *WebViewMessage;
//    UITextView *labelMessage;
    NSString *firstName;
    NSString *lastName;
    NSTimeInterval date;
    NSString *lastMessageText;
    NSString *contactID;
    int badge;
    BOOL imageExist;
    BOOL me;
    
    UIInterfaceOrientation interfaceOrientation;
}

@property (nonatomic, assign) id<MessageItemDelegate> delegate;
@property (nonatomic, assign) BOOL hasLink;
//@property (strong, nonatomic) UIWebView *WebViewMessage;
//@property (strong, nonatomic) UITextView *labelMessage;
@property (nonatomic, assign) NSTimeInterval date;
@property (strong, nonatomic) NSString *stringMessageText;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *lastMessageText;
@property (strong, nonatomic) NSString *contactID;
@property (strong, nonatomic) NSString *messageID;
@property (nonatomic,retain)  UIImage* messageImage;
//@property (assign, nonatomic) int badge;
@property (assign, nonatomic) BOOL imageExist;
@property (nonatomic, assign) BOOL me;
@property (nonatomic, assign) BOOL delivered;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL needToLoading;
@property (nonatomic, assign) BOOL neetToDelete;
@property (nonatomic, assign) Message_Type type;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *videoUrl;
@property (nonatomic, assign) BOOL responseDelivered;
@property (nonatomic, retain) CDMessage* coreMessage;
//@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIImage *thumbnail;

//- (id) initWithMessageDetailsObject:(TBIMessageDetailsObject*)obj Orientation:(UIInterfaceOrientation)orientation Image:(UIImage*)imageForSend save:(BOOL) flag;
//- (id) initWithMessageDetailsObject:(TBIMessageDetailsObject*)obj Orientation:(UIInterfaceOrientation)orientation video:(NSData*)videoForSend save:(BOOL) flag;
- (id) initWithCDMessage:(CDMessage*) message;
-(id) initWithType:(Message_Type)type_  image:(UIImage*) image_;
- (void) setImageToImageViewButton:(UIImage*)img;
- (void) enableImageViewButton;
- (void) setActivityIndicatorHide;
- (void) loadFileThread;
- (void) loadFile;

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;


@end

@protocol MessageItemDelegate <NSObject>

@optional

- (void) didClickedOnLink:(NSURLRequest*)request onItem:(MessageItem*)item;
- (void) didSendFile:(MessageItem*)item;
- (void) didLoadFile:(MessageItem*)item;
//- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end