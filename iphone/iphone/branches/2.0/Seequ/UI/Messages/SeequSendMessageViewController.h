//
//  SeequSendMessageViewController.h
//  ProTime
//
//  Created by Karen on 10/24/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPManager.h"
#import "Common.h"
#import "MessageItem.h"
#import "AviaryPickerController.h"
#import "BackBarButton.h"
#import "TBIDefaultBadgView.h"
#import "SeequMessageItemCell.h"
#import "CaptureSessionManager.h"
#import "SeequVideoRecorerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SeequChatInpute.h"
#import "SeequGroupInfo.h"
#import "CDMessageOwner.h"


@interface SeequSendMessageViewController : UIViewController <XMPPManagerDelegate,XMPPRosterStorage,MessageItemDelegate,UIWebViewDelegate, UIActionSheetDelegate,AviaryPickerDelegate,SeequMessageItemCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SeequVideoRecorerViewControllerDelegate,UIAlertViewDelegate> {
    UITableView *tableMessages;
    NSString *stringNavigationTitle;
    NSString *stringUserId;
//    NSMutableDictionary *arrayCurrentUserAllHistory;
//    NSMutableArray *arrayAllMessageItem;
//    NSMutableArray *arrayCurrentDateMessages;
//    NSMutableArray *ARRAY;
//    NSMutableArray *arrayIndexPath;
    NSURL *videoUrl;
    SeequChatInpute* viewSendMessage;
    Common *common;
    UIImage *userImage;
    BOOL isShow;
    BOOL isForEditing;
    BOOL keyboardOpened;
    BOOL fromLibrary;
    int videoViewState;
    UIButton *buttonTitle;
    UIImage *imageForSend;
    
    BackBarButton *backBarButton;
    TBIDefaultBadgView *defaultBadgView;
}

@property (nonatomic, strong) IBOutlet UITableView *tableMessages;
@property (nonatomic, strong) UIImage *userImage;
@property (nonatomic, strong)  UITextView* textFieldSendMessage;
@property (nonatomic, strong) SeequChatInpute* viewSendMessage;
@property (nonatomic,retain)  SeequGroupInfo* groupInfo;

@property (nonatomic, strong) NSString *stringNavigationTitle;
@property (nonatomic, strong) NSString *stringUserId;
@property (nonatomic, retain) NSData*  videoForSend;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelNavName;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewDeleteMessage;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonDelete;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonEdit;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonVideo;
@property (unsafe_unretained, nonatomic)  UIButton *buttonSendMessage;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewHeaderBG;
@property (nonatomic, assign) int videoViewState;
@property (nonatomic, assign) int callType;
@property (strong, nonatomic) IBOutlet UIView *viewCallMenu;
@property (strong, nonatomic) IBOutlet UIButton *buttonVoiceCall;
@property (strong, nonatomic) IBOutlet UIButton *buttonVideoCall;
@property (strong, nonatomic) IBOutlet UIButton *buttonBack;
@property (strong, nonatomic) IBOutlet UIButton *buttonCamera;
@property (nonatomic) UIButton * alertCheckboxButton;
@property (nonatomic,retain) CDMessageOwner* messageOwner;
@property (nonatomic,assign) BOOL needToScroll;


- (void) setVideoViewState:(int)state Animated:(BOOL)animated;
- (void) onCallStateChange:(NSNotification*)notification;

- (void) onButtonBack:(id)sender;
- (IBAction) onButtonEdit:(id)sender;
- (IBAction) onButtonVideo:(id)sender;
- (IBAction) onButtonVoiceCall:(id)sender;
- (IBAction) onButtonRingback:(id)sender;
- (IBAction) onButtonCamera:(id)sender;


- (void) onButtonShowCallMenu:(id)sender;

- (IBAction) onButtonSendMessage:(id)sender;
- (IBAction) onButtonDelete:(id)sender;
- (void) onContactObjectImage:(NSNotification *)notif;
- (void) UpdateTableFrameForPortraitAndScrallTable:(BOOL)scrall;
- (UIButton*) CreateUserImageButton;
- (void) onButtonUserImage:(id)sender;
- (NSMutableArray*) SortArrayByDay:(NSMutableArray*)array;
- (void) UpdateMessageItemWithMessageID:(NSString*)messageID;
- (void) UpdateViewCallMenuFrame;
- (void) UpdateCallButtons;
- (void) AddKeyboardScrolling;
- (void) CleareAllMessages;
- (void) sendMessageOnMainThreadWithMessageItem:(MessageItem*)item;
- (void) alertCheckboxButtonClicked;
- (void) dismissAlertView:(UIAlertView*)alertView;
@end