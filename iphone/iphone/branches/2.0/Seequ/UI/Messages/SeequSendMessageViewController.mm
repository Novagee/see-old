//
//  SeequSendMessageViewController.m
//  ProTime
//
//  Created by Karen on 10/24/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "SeequRingBackViewController.h"
//#import "ChatCoreDataStorage.h"
#import "SeequSendMessageViewController.h"
#import "SeequContactProfileViewController.h"
#import <AviarySDK/AviarySDK.h>
#import "TestFlight.h"
#import "NavigationBar.h"
#import "idoubs2AppDelegate.h"
#import "DAKeyboardControl.h"
#import "GalleryCellInfo.h"
#import "SeequWebView.h"
#import "SeequMessageItemCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SeequMPViewController.h"
#import "SeequVideoRecorerViewController.h"
#import "GalleryViewController.h"
#import "NSDate+DEFetchedGroupByString.h"
#import "MessageCoreDataManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CDGroup.h"
#import "RTMPChatManager.h"
#import "SeequDTViewController.h"

#define DELIVERED_VIEW_TAG 22
#define SHEET_OK_THANKS 11
#define SHEET_CHOOSE_ATTACHEMENT_TYPE 2015
#define SHEET_EDIT_IMAGE 2016
#define SHEET_EDIT_VIDEO 2017
#define DOUBLE_TAKE_PERMISSION @"Double Take Persission"
#define DOUBLE_TAKE_PERMISSIONTAG  2018
#define NO_INTERNET_CONNECTION_TAG 2019
#define VIEW_CALL_MENU_HEIGHT 59
#define VideoViewState_TAB_MENU_TABLE_HEIGHT 206
#define VideoViewState_TAB_TABLE_HEIGHT 114

@implementation UINavigationBar (customNav)
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width,46);
    return newSize;
}
@end


@interface SeequSendMessageViewController () <AFPhotoEditorControllerDelegate ,UIWebViewDelegate,SeequChatInputeDelegate,UIVideoEditorControllerDelegate,  CaptureSessionManagerDelegate,NSFetchedResultsControllerDelegate>{
    MPMoviePlayerController* moviePlayerController;
    NSMutableArray*  arrayForDelete;
    BOOL isInRotate;
    BOOL isFromEdit;
    BOOL isVideoResponse;
    Message_Type message_Type;
    UIImagePickerController* _imagePicker;
    BOOL isAlwaysDoubleTake;
    CGFloat messageFieldMaxHeight;
    UIVideoEditorController *videoEditor;
    NSFetchedResultsController *fetchedResultsController;
    BOOL isInserted;

}
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@property (nonatomic,assign) BOOL needToRefresh;
@property (nonatomic,assign) BOOL needToUpdate;
@property (nonatomic,retain) NSArray*  imageArray;
@property (nonatomic,retain) MessageItem* videoMessageItem;
@property (nonatomic,retain) NSIndexPath* currentIndexPath;
@property (nonatomic,retain) NSString* dt_url;
@property (nonatomic,assign) CGFloat keyboardHeight;
@property (nonatomic,assign) BOOL isAppeared;


@end


#define MESSAGE_CELL_IDENTIFIER @"SeequMessagesCell"

@implementation SeequSendMessageViewController

@synthesize tableMessages;
@synthesize viewSendMessage;
@synthesize textFieldSendMessage;
@synthesize stringNavigationTitle;
@synthesize stringUserId;
@synthesize userImage;
@synthesize videoViewState;
@synthesize callType;
@synthesize needToRefresh = _needToRefresh;
@synthesize imageArray;
@synthesize videoForSend;
@synthesize videoMessageItem;
@synthesize alertCheckboxButton;
@synthesize messageOwner;
@synthesize currentIndexPath;
@synthesize dt_url;
@synthesize keyboardHeight = _keyboardHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        videoViewState = VideoViewState_NONE;
        _needToRefresh = YES;
        arrayForDelete = [[NSMutableArray alloc] init];
        isInRotate = NO;
        isFromEdit = NO;
        _keyboardHeight = 0;
        isVideoResponse = NO;
        _isAppeared = NO;
        messageFieldMaxHeight = 50;
        isInserted = NO;
    }
    
    return self;
}

-(BOOL)shouldReceiveMessage:(NSString *)ptID {
    if (isShow) {
        if (![ptID isEqualToString:self.stringUserId]) {
            return NO;
        } else {
            return YES;
        }
    }
    
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    self.edgesForExtendedLayout=UIRectEdgeAll;
    // Do any additional setup after loading the view from its nib.
    isShow = YES;
    imageForSend = nil;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTextFieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallStateChange:) name:kCallStateChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageSendedFromActivity:) name:@"MessageSendedFromActivity" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessage:) name:kTBIMessageEventArgsName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewMessage:) name:kNewTextMessage object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectImage:) name:@"ContactObjectImage" object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doneButtonClick:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupState:) name:@"UpdateGroupState" object:nil];
    
    [self.tableMessages registerNib:[UINib nibWithNibName:@"SeequMessageItemCell"
                                                   bundle:[NSBundle mainBundle]]
             forCellReuseIdentifier:MESSAGE_CELL_IDENTIFIER];
    self.viewSendMessage = [[SeequChatInpute alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    viewSendMessage.messageDelegate = self;
    self.buttonCamera = self.viewSendMessage.buttonCamera;
    [self.view addSubview:self.viewSendMessage];
    self.view.keyboardTriggerOffset = self.viewSendMessage.bounds.size.height;
    self.textFieldSendMessage = self.viewSendMessage.textview;
    
    
    
    //    [NSThread detachNewThreadSelector:@selector(readMessagesFromHistory) toTarget:self withObject:nil];
    
    [[idoubs2AppDelegate getChatManager] addDelegate:self];
    
    self.viewCallMenu.frame = CGRectMake(0, -60, 320, 59);
    if (![self.messageOwner.isGroup boolValue]) {
        buttonTitle = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonTitle setBackgroundColor:[UIColor clearColor]];
        [buttonTitle setBackgroundImage:[UIImage imageNamed:@"SeequMessageTitleButtonBGDown.png"] forState:UIControlStateNormal];
        [buttonTitle setTitle:self.stringNavigationTitle forState:UIControlStateNormal];
        [buttonTitle.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0]];
        [buttonTitle setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [buttonTitle.titleLabel setShadowOffset:CGSizeMake(0, -0.7f)];
        buttonTitle.frame = CGRectMake(60, 2, 200, 40);
        [buttonTitle addTarget:self action:@selector(onButtonShowCallMenu:) forControlEvents:UIControlEventTouchDown];
        [self.navigationController.navigationBar addSubview:buttonTitle];

    } else {
        self.navigationItem.title =self.stringNavigationTitle;
        if (![self.messageOwner.groupInfo.state boolValue] && ![self.messageOwner.groupInfo.groupOwner.seeQuId isEqualToString:[Common sharedCommon].contactObject.SeequID]) {
            self.viewSendMessage.textview.editable = NO;
            self.viewSendMessage.buttonCamera.enabled = NO;
            self.viewSendMessage.buttonSendMessage.enabled = NO;
        }

    }
 
    
    defaultBadgView = [[TBIDefaultBadgView alloc] init];
    defaultBadgView.center = CGPointMake(28, -6);
    defaultBadgView.transform = CGAffineTransformMakeScale(0.6, 0.6);
    [self createBarButtonItems];
    [self updateViewController];
    self.viewCallMenu.hidden=YES;
    self.viewDeleteMessage.hidden=YES;
     fetchedResultsController = [self fetchedResultsController];
    
  

}

-(void) updateGroupState:(NSNotification*) notification {
    NSArray*  arr = (NSArray*)notification.object;
    if (self.messageOwner.isGroup) {
        for (NSDictionary* dd in arr) {
            NSString* groupId = [dd objectForKey:@"roomId"];
            if ([self.messageOwner.groupInfo.groupId isEqualToString:groupId]) {
                CDGroup* group = [[MessageCoreDataManager sharedManager] getGroupByGroupId:groupId];
                if (![group.state boolValue]) {
                    self.viewSendMessage.textview.editable = NO;
                    self.viewSendMessage.buttonCamera.enabled = NO;
                    self.viewSendMessage.buttonSendMessage.enabled = NO;
                }
            }
        }
    }
}
#pragma mark SeequChatInputDelegate

-(void) pressButtonCamera {
    if (imageForSend) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Image attachment"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Edit", @"Remove", @"Retake", nil];
        sheet.tag = SHEET_EDIT_IMAGE;
        sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [sheet showFromTabBar:[idoubs2AppDelegate sharedInstance].tabBarController.tabBar];
    } else if (videoForSend) {
        NSString*  retakeString= [[idoubs2AppDelegate sharedInstance].videoService isInCall]?nil: @"Retake";
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Video attachment"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles: @"Remove", retakeString, nil];
        sheet.tag = SHEET_EDIT_VIDEO;
        sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [sheet showFromTabBar:[idoubs2AppDelegate sharedInstance].tabBarController.tabBar];
    } else {
//        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Seequ"
//                                                           delegate:self
//                                                  cancelButtonTitle:@"Cancel"
//                                             destructiveButtonTitle:nil
//                                                  otherButtonTitles:@"Send photo", @"Send video",@"Send double take", nil];
//        sheet.tag = SHEET_CHOOSE_ATTACHEMENT_TYPE;
//        sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
//        [sheet showFromTabBar:[idoubs2AppDelegate sharedInstance].tabBarController.tabBar];
//        //
//        //        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        //        NSString *documentsDirectory = [paths objectAtIndex:0];
//        //        NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/vid1.mp4"];
//        //        NSURL* url = [NSURL URLWithString:tempPath];
//        //        moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
//        //        [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
        if (![[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
            //                        AviaryPickerController * imagePicker = [AviaryPickerController new];
            //                        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            //                        imagePicker.showsCameraControls = NO;
            //                        imagePicker.avDelegate = self;
            //
            //                        [self.tabBarController presentViewController:imagePicker animated:YES completion:nil];
                SeequVideoRecorerViewController*  videoRecorder = [[SeequVideoRecorerViewController alloc] initWithType:SeequRecorderTypePhoto];
                videoRecorder.captureDelegate =self;
                videoRecorder.devicePosition = AVCaptureDevicePositionBack;
                message_Type = Message_Type_Image;
            
                [self.tabBarController presentViewController:videoRecorder animated:YES completion:nil];
                
           } else {
            AviaryPickerController * imagePicker = [AviaryPickerController new];
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            imagePicker.avDelegate = self;
            [self.tabBarController presentViewController:imagePicker animated:YES completion:nil];
            
        }

        
    }
    
}

-(void) onButtonVideo{
    if ([[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView setVideoState:VideoViewState_TAB_MENU Animation:YES];
    } else {
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView setVideoState:VideoViewState_NORMAL Animation:YES];
    }
    
}

-(void) onVideoPlayerStateChange {
    switch (moviePlayerController.playbackState) {
        case    MPMoviePlaybackStateStopped:
        case    MPMoviePlaybackStatePlaying:
        case    MPMoviePlaybackStatePaused:
        case    MPMoviePlaybackStateInterrupted:
        case    MPMoviePlaybackStateSeekingForward:
        case    MPMoviePlaybackStateSeekingBackward:{
            NSLog(@"move player  state %d",moviePlayerController.playbackState);
        }
            
            break;
            
        default:
            break;
    }
}
-(void)doneButtonClick:(NSNotification*)aNotification{
    [moviePlayerController.view removeFromSuperview];
}
-(void) createBarButtonItems {
    
    backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(onButtonBack:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    [backBarButton.customView addSubview:defaultBadgView];
    UIButton*  button =  [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* im = [UIImage imageNamed:@"seequButtonEdit.png"];
    UIImage* im1 = [UIImage imageNamed:@"seequButtonDone.png"];
    button.frame = CGRectMake(0, 0, im.size.width, im.size.height);
    [button setBackgroundImage:im forState:UIControlStateNormal];
    [button setBackgroundImage:im1 forState:UIControlStateSelected];
    [button addTarget:self action:@selector(onButtonEdit:) forControlEvents:UIControlEventTouchUpInside];
    self.buttonEdit=button;
    UIBarButtonItem*  item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem =item;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak SeequSendMessageViewController* weakSelf = self;
    
    [self.view addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        /*
         Try not to call "self" inside this block (retain cycle).
         But if you do, make sure to remove DAKeyboardControl
         when you are done with the view controller by calling:
         [self.view removeKeyboardControl];
         */
        
        CGRect toolBarFrame =weakSelf.viewSendMessage.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        if (weakSelf.isAppeared) {
            weakSelf.keyboardHeight = 0;
        } else {
            weakSelf.keyboardHeight = weakSelf.view.frame.size.height - keyboardFrameInView.origin.y;
        }
        
        
        //        [self updateViewController];
        int diff = 48;
        if (UIInterfaceOrientationIsLandscape(weakSelf.interfaceOrientation)) {
            diff = 42;
        }else
                weakSelf.keyboardHeight=weakSelf.keyboardHeight+diff;
        
        if (toolBarFrame.origin.y < weakSelf.view.frame.size.height - diff) {
            weakSelf.viewSendMessage.frame = toolBarFrame;
            //            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            //                CGRect tableViewFrame = tableMessages.frame;
            //                if (toolBarFrame.origin.y > 0) {
            //                    tableViewFrame = CGRectMake(tableViewFrame.origin.x, 44, tableViewFrame.size.width, toolBarFrame.origin.y - 44);
            //                }
            //
            //                tableMessages.frame = tableViewFrame;
            //            } else {
            //                [self updateViewController];
            //            }
            
            if (opening) {
                NSArray* arr =weakSelf.tableMessages.visibleCells;
                NSIndexPath* indexPath = nil;
                if (arr && arr.count) {
                    indexPath = [weakSelf.tableMessages indexPathForCell:[arr objectAtIndex:arr.count-1]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf keyboardDidShow:nil];
                    if (arr && arr.count) {
                        [weakSelf.tableMessages scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    }
                });
            }
            [weakSelf
             .view setNeedsLayout];
        }
    }constraintBasedActionHandler:nil];

    buttonTitle.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self updateViewController];
    _isAppeared = YES;
    [self AddKeyboardScrolling];
    if (!buttonTitle.superview) {
        [self.navigationController.navigationBar addSubview:buttonTitle];
    }
    [self.viewSendMessage.textview resignFirstResponder];
    
    
    if ([idoubs2AppDelegate sharedInstance].refreshingTab)
        return;
    isShow = YES;
    
    [idoubs2AppDelegate sharedInstance].messageFromNotification = NO;
    [idoubs2AppDelegate sharedInstance].messageFromLocalNotification = NO;
    
    [self UpdateCallButtons];
    
    self.navigationController.navigationItem.title = self.stringNavigationTitle;
    int sections = fetchedResultsController.sections.count -1;
    if (sections < 0) {
        return;
    }
    id<NSFetchedResultsSectionInfo>sectionInfo=[fetchedResultsController.sections objectAtIndex:sections];
    int rows = sectionInfo.numberOfObjects -1;
    if (rows < 0) {
        return;
    }
    NSIndexPath* indexPath =[NSIndexPath indexPathForRow:rows inSection:sections];
    [self.tableMessages scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}

-(void) removeMisseds{
    __weak SeequSendMessageViewController*  weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [Common RemoveMissedWithSeequID:weakSelf.stringUserId Type:2];
            [Common removeBadgeOnCurrentUser:weakSelf.stringUserId];
    });
    
}
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.stringUserId) {
        [self performSelectorInBackground:@selector(removeMisseds) withObject:nil];

    }
    
    
    isShow = YES;
    _isAppeared = NO;

    
    if ([idoubs2AppDelegate sharedInstance].ReplyWithMessageNumber) {
        [idoubs2AppDelegate sharedInstance].ReplyWithMessageNumber = nil;
        
        [textFieldSendMessage becomeFirstResponder];
    }
    
    if ([idoubs2AppDelegate sharedInstance].messageFromActivity) {
        [idoubs2AppDelegate sharedInstance].messageFromActivity = NO;
        
        self.viewSendMessage.textview.text = [idoubs2AppDelegate sharedInstance].messageFromActivityText;
        if ([idoubs2AppDelegate sharedInstance].messageFromActivityImage) {
            imageForSend = [idoubs2AppDelegate sharedInstance].messageFromActivityImage;
            [self.viewSendMessage setImage:imageForSend forVideo:NO];
            fromLibrary=YES;
            [self.buttonCamera setBackgroundImage:[UIImage imageNamed:@"seequMessageCameraAtachedIcon.png"] forState:UIControlStateNormal];
            [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSend.png"] forState:UIControlStateNormal];
        }
            if ([idoubs2AppDelegate sharedInstance].messageFromActivityVideoPath) {
                    videoUrl=[NSURL fileURLWithPath:[idoubs2AppDelegate sharedInstance].messageFromActivityVideoPath];
                    fromLibrary=YES;
                    message_Type = Message_Type_Video;
                    videoForSend =[NSData dataWithContentsOfFile:[idoubs2AppDelegate sharedInstance].messageFromActivityVideoPath];
                    UIImage *image=[Common getVideoThumbnail:videoUrl];
                    [self.viewSendMessage setImage:image forVideo:YES];
                    [self.buttonCamera setBackgroundImage:[UIImage imageNamed:@"seequMessageCameraAtachedIcon.png"] forState:UIControlStateNormal];
                    [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSend.png"] forState:UIControlStateNormal];
            }
        if(![self.viewSendMessage.textview isFirstResponder]){
            [self.viewSendMessage.textview becomeFirstResponder];
        }
        
    }
    if (_needToScroll) {
        int sections = fetchedResultsController.sections.count -1;
        if (sections < 0) {
            return;
        }
        id<NSFetchedResultsSectionInfo>sectionInfo=[fetchedResultsController.sections objectAtIndex:sections];
        int rows = sectionInfo.numberOfObjects -1;
        if (rows < 0) {
            return;
        }
        NSIndexPath* indexPath =[NSIndexPath indexPathForRow:rows inSection:sections];
//        [self.tableMessages scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [self performSelector:@selector(scrolltoIndexPath:) withObject:indexPath afterDelay:0.1 ];
        _needToScroll = NO;
    }
    
    
}

-(CGFloat) calculateMessageFieldMaxHeight:(UIInterfaceOrientation) orientation{
    return  UIInterfaceOrientationIsLandscape(orientation)?self.view.frame.size.width -  _keyboardHeight :self.view.frame.size.width -  _keyboardHeight;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.view removeKeyboardControl];

    if (buttonTitle.superview) {
        [buttonTitle removeFromSuperview];
    }
    
    [idoubs2AppDelegate sharedInstance].messageFromActivityImage = nil;
    [idoubs2AppDelegate sharedInstance].messageFromActivityVideoPath=nil;
    [idoubs2AppDelegate sharedInstance].messageFromActivityText = @"";
    if ([idoubs2AppDelegate sharedInstance].refreshingTab)
        return;
    
    isShow = NO;
    
    [self.textFieldSendMessage resignFirstResponder];
    [super viewWillDisappear:animated];

    
}

-(CGSize) getWindowSize{
    UIInterfaceOrientation orientation =[ UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    }
    return [[UIScreen mainScreen] bounds].size;
}

///@todo workarround needs  to be solved, but in case of  strange  call  of  view appearance  need to exist
-(CGFloat) calculateOffset{
    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall] && (videoViewState == VideoViewState_HIDE||videoViewState == VideoViewState_TAB) && (isInRotate||isFromEdit) && !IS_IOS_7) {
        return 46;
    }
    return 0;
}

-(void) updateViewController {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat delta = IS_IOS_7?-48:self.tableMessages.frame.origin.y;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if ([[idoubs2AppDelegate sharedInstance].videoService isInCall] &&(videoViewState != VideoViewState_HIDE &&videoViewState != VideoViewState_PREVIEW) && [[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
            self.navigationController.navigationBar.frame = CGRectMake(SMALL_VIDEO_HEIGHT, self.navigationController.navigationBar.frame.origin.y, [[UIScreen mainScreen] bounds].size.height - SMALL_VIDEO_HEIGHT*2, self.navigationController.navigationBar.frame.size.height);
            self.tableMessages.frame = CGRectMake(SMALL_VIDEO_HEIGHT, [self calculateOffset], [[UIScreen mainScreen] bounds].size.height - SMALL_VIDEO_HEIGHT*2, self.viewSendMessage.frame.origin.y -delta);//[[UIScreen mainScreen] bounds].size.width -self.navigationController.navigationBar.frame.size.height - delta
            NSLog(@"current view frame  is  %@", NSStringFromCGRect(self.view.frame));
        }else {
            
            self.navigationController.navigationBar.frame = CGRectMake(0, self.navigationController.navigationBar.frame.origin.y, [[UIScreen mainScreen] bounds].size.height, self.navigationController.navigationBar.frame.size.height);
            if (!isForEditing) {
                self.tableMessages.frame = CGRectMake(0, [self calculateOffset], [[UIScreen mainScreen] bounds].size.height ,self.viewSendMessage.frame.origin.y -delta);
            }else
                self.tableMessages.frame = CGRectMake(0, [self calculateOffset], [[UIScreen mainScreen] bounds].size.height ,self.viewDeleteMessage.frame.origin.y -delta); //20 -  status bar  height;
            //          NSLog(@"the frame of  viewsendMessage is %@",NSStringFromCGRect(self.viewSendMessage.frame));
        }
        
        
        
    } else {
        
        if (![[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
            videoViewState = VideoViewState_HIDE;
        }
        
        CGRect frame = self.tableMessages.frame;
        
        int statusBarHeight = 0;
        
        if (self.view.frame.size.height == 386 || self.view.frame.size.height == 387 || self.view.frame.size.height == 474 || self.view.frame.size.height == 475) {
            statusBarHeight = 20;
        }
        
        int originY = 0;
        
        if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
            if(isInRotate && !IS_IOS_7)
                originY += 44;
            if (videoViewState == VideoViewState_TAB) {
                originY += 116;
            } else {
                if (videoViewState == VideoViewState_TAB_MENU) {
                    originY += 208;
                } else {
                    if (videoViewState != VideoViewState_HIDE &&
                        videoViewState != VideoViewState_PREVIEW) {
                        [self.textFieldSendMessage resignFirstResponder];
                    }
                }
            }
        }
        
        frame.origin.y = originY + statusBarHeight;
        frame.origin.x = 0;
        frame.size.width = 320;
        
        if (IS_IOS_7) {
            delta = 46;
        } else {
            delta = 0;
        }
        
        if (!isForEditing) {
            frame.size.height = self.viewSendMessage.frame.origin.y - frame.origin.y + delta;
        } else {
            frame.size.height = self.viewDeleteMessage.frame.origin.y - frame.origin.y + delta;
        }
        //        [UIView beginAnimations:@"tableFrame" context:nil];
        //        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
        //        [UIView setAnimationDuration:0.3];
        self.tableMessages.frame = frame;
        //        [UIView commitAnimations];
        
        self.navigationController.navigationBar.frame = CGRectMake(0, self.navigationController.navigationBar.frame.origin.y, [[UIScreen mainScreen] bounds].size.width, self.navigationController.navigationBar.frame.size.height);
        
    }
    
    isFromEdit = NO;
    
    buttonTitle.center = CGPointMake(self.navigationController.navigationBar.frame.size.width/2, self.navigationController.navigationBar.frame.size.height/2);
    CGFloat origin_Y = (self.viewCallMenu.tag != 0)?self.tableMessages.frame.origin.y:-60;
    
    self.viewCallMenu.frame = CGRectMake(self.tableMessages.frame.origin.x,origin_Y, tableMessages.frame.size.width, 59);
    self.buttonVoiceCall.frame = CGRectMake(0, 0, self.viewCallMenu.frame.size.width/2-1, self.buttonVoiceCall.frame.size.height);
    self.buttonVideoCall.frame = CGRectMake(self.viewCallMenu.frame.size.width/2, 0, self.viewCallMenu.frame.size.width/2, self.buttonVideoCall.frame.size.height);
    //    self.viewDeleteMessage.frame =CGRectMake(0, self.viewDeleteMessage.frame.origin.y, [self getWindowSize].width,self.viewDeleteMessage.frame.size.height);
}

-(void) updateLayoutNormalState{
    UIInterfaceOrientation orientation =[ UIApplication sharedApplication].statusBarOrientation;
    CGFloat delta = IS_IOS_7?-48:self.tableMessages.frame.origin.y;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        
        self.navigationController.navigationBar.frame = CGRectMake(0, self.navigationController.navigationBar.frame.origin.y, [[UIScreen mainScreen] bounds].size.height, self.navigationController.navigationBar.frame.size.height);
        NSLog(@"the frame of navigation bar %@",NSStringFromCGRect(self.navigationController.navigationBar.frame));
        if (!isForEditing) {
            self.tableMessages.frame = CGRectMake(0, [self calculateOffset], [[UIScreen mainScreen] bounds].size.height ,self.viewSendMessage.frame.origin.y -delta);
        }else {
            self.tableMessages.frame = CGRectMake(0, [self calculateOffset], [[UIScreen mainScreen] bounds].size.height ,self.viewDeleteMessage.frame.origin.y -delta); //20 -  status bar  height;
            //          NSLog(@"the frame of  viewsendMessage is %@",NSStringFromCGRect(self.viewSendMessage.frame));
        }
        
    } else {
        
        if (![[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
            videoViewState = VideoViewState_HIDE;
        }
        
        CGRect frame = self.tableMessages.frame;
        
        int statusBarHeight = 0;
        
        if (self.view.frame.size.height == 386 || self.view.frame.size.height == 387 || self.view.frame.size.height == 474 || self.view.frame.size.height == 475) {
            statusBarHeight = 20;
        }
        
        int originY = 0;
        
        if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
            if(isInRotate && !IS_IOS_7)
                originY += 44;
            if (videoViewState == VideoViewState_TAB) {
                originY += 116;
            } else {
                if (videoViewState == VideoViewState_TAB_MENU) {
                    originY += 208;
                } else {
                    if (videoViewState != VideoViewState_HIDE &&
                        videoViewState != VideoViewState_PREVIEW) {
                        [self.textFieldSendMessage resignFirstResponder];
                    }
                }
            }
        }
        
        frame.origin.y = originY + statusBarHeight;
        frame.origin.x = 0;
        frame.size.width = 320;
        
        if (IS_IOS_7) {
            delta = 46;
        } else {
            delta = 0;
        }
        
        if (!isForEditing) {
            frame.size.height = self.viewSendMessage.frame.origin.y - frame.origin.y + delta;
        } else {
            frame.size.height = self.viewDeleteMessage.frame.origin.y - frame.origin.y + delta;
        }
        //        [UIView beginAnimations:@"tableFrame" context:nil];
        //        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
        //        [UIView setAnimationDuration:0.3];
        self.tableMessages.frame = frame;
        //        [UIView commitAnimations];
        
        self.navigationController.navigationBar.frame = CGRectMake(0, self.navigationController.navigationBar.frame.origin.y, [[UIScreen mainScreen] bounds].size.width, self.navigationController.navigationBar.frame.size.height);
        
    }
    
}

-(void) updateNavigationControllerFrame{
    CGFloat originX = 0;
    CGFloat width;
    UIInterfaceOrientation orientation =[ UIApplication sharedApplication].statusBarOrientation;
    switch (videoViewState) {
        case VideoViewState_NONE:
        case VideoViewState_HIDE:{
            originX = 0;
            
        }
            break;
        case VideoViewState_TAB: {
            originX = SMALL_VIDEO_HEIGHT;
        }
            break;
        default:
            break;
    }
    if (UIInterfaceOrientationIsLandscape(orientation)){
        width =[[UIScreen mainScreen] bounds].size.height - originX*2;
    } else{
        width =[[UIScreen mainScreen] bounds].size.width ;
    }
    
    self.navigationController.navigationBar.frame = CGRectMake(originX, self.navigationController.navigationBar.frame.origin.y,width, self.navigationController.navigationBar.frame.size.height);
    buttonTitle.frame = CGRectMake(self.navigationController.navigationBar.frame.size.width/2 - buttonTitle.frame.size.width/2 , self.navigationController.navigationBar.frame.size.height/2 - buttonTitle.frame.size.height/2, buttonTitle.frame.size.width, buttonTitle.frame.size.height);
    [self UpdateViewCallMenuFrame];
}

-(CGFloat) getFooterHeight{
    UIInterfaceOrientation orientation =[ UIApplication sharedApplication].statusBarOrientation;
    CGFloat delta  = (_keyboardHeight)? _keyboardHeight -self.tabBarController.tabBar.frame.size.height: 0;
    if (UIInterfaceOrientationIsLandscape(orientation)){
        if (isForEditing) {
            return self.viewDeleteMessage.frame.size.height + delta;
        }   else {
            return self.viewSendMessage.frame.size.height + delta;
        }
    } else {
        if (isForEditing) {
            return self.viewDeleteMessage.frame.size.height  + self.tabBarController.tabBar.frame.size.height + delta;
        }   else {
            if (IS_IOS_7) {
                return self.viewSendMessage.frame.size.height + self.tabBarController.tabBar.frame.size.height + delta;
                
            } else {
                return self.viewSendMessage.frame.size.height  + delta;
            }
        }
        
        
    }
    
}

-(void) updateTableViewFrame{
    CGFloat originX = 0;
    CGFloat originY = 0;
    CGFloat width;
    CGFloat height;
    CGFloat tabMenuHeight = 0;
    UIInterfaceOrientation orientation =[ UIApplication sharedApplication].statusBarOrientation;
    
    
    switch (videoViewState) {
        case VideoViewState_NONE:
        case VideoViewState_HIDE:{
            originX = 0;
        }
            break;
        case VideoViewState_TAB_MENU:{
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                originY = VideoViewState_TAB_MENU_TABLE_HEIGHT;
                tabMenuHeight  = VideoViewState_TAB_MENU_TABLE_HEIGHT;
                
            } else {
                originX = SMALL_VIDEO_HEIGHT;
            }
        }
            break;
            
        case VideoViewState_TAB:{
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                originY = VideoViewState_TAB_TABLE_HEIGHT;
                tabMenuHeight  = VideoViewState_TAB_TABLE_HEIGHT;
            }  else {
                originX = SMALL_VIDEO_HEIGHT;
            }
            
        }
            break;
            
        default:
            break;
    }
    self.tableMessages.scrollIndicatorInsets   = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableMessages.contentInset = UIEdgeInsetsMake(self.tableMessages.contentInset.top, self.tableMessages.contentInset.left, 0, self.tableMessages.contentInset.right);
    CGFloat delta =UIInterfaceOrientationIsLandscape(orientation)?0 :originX;
    if (UIInterfaceOrientationIsLandscape(orientation)){
        width =[[UIScreen mainScreen] bounds].size.height - originX*2;
        
        NSLog(@"%@",NSStringFromCGPoint(self.tableMessages.contentOffset));
    } else{
        width =[[UIScreen mainScreen] bounds].size.width ;
    }
    if (!isForEditing) {
        height = self.viewSendMessage.frame.origin.y - delta -tabMenuHeight;
        
    } else {
        
        height = self.viewDeleteMessage.frame.origin.y - delta;
    }
    
    
    self.tableMessages.frame = CGRectMake(originX, originY, width,height);
    self.tableMessages.clipsToBounds = YES;
    
    NSLog(@"contentInset - %f", self.tableMessages.contentInset.bottom );
    
    
}



-(void) updateFooterFrame{
    
    CGFloat kHeight = _keyboardHeight > self.tabBarController.tabBar.frame.size.height ? _keyboardHeight - self.tabBarController.tabBar.frame.size.height:0;
    UIInterfaceOrientation orientation =[ UIApplication sharedApplication].statusBarOrientation;
    [self UpdateViewDeleteMessagesHeader:orientation];
    if (!isForEditing) {
        if(([[idoubs2AppDelegate sharedInstance].videoService isInCall]) &&
           UIInterfaceOrientationIsLandscape(orientation)){
            self.viewSendMessage.messageViewState = MessageViewLandscapeCallState;
        } else {
            if(self.viewSendMessage.messageViewState != MessageViewNormalState ) {
                self.viewSendMessage.messageViewState = MessageViewNormalState;
                [self.viewSendMessage setNeedsLayout];
            }
            
        }
        
//        BOOL flag = !IS_IOS_7 && UIInterfaceOrientationIsPortrait(orientation);
        CGFloat delta = (((_keyboardHeight< self.tabBarController.tabBar.frame.size.height) && UIInterfaceOrientationIsLandscape(orientation)) )?0:self.tabBarController.tabBar.frame.size.height;
//        if (flag) {
//            delta =  0;
//        }
        self.viewSendMessage.frame =CGRectMake(self.view.frame.origin.x ,
                                               self.view.frame.size.height - self.viewSendMessage.frame.size.height -kHeight- delta,
                                               self.view.frame.size.width,self.viewSendMessage.frame.size.height);
        NSLog(@"self.viewSendMessage.frame  after %@",NSStringFromCGRect(self.viewSendMessage.frame ));
    } else {
//        BOOL flag = !IS_IOS_7 && UIInterfaceOrientationIsPortrait(orientation);
        CGFloat delta = (((_keyboardHeight< self.tabBarController.tabBar.frame.size.height) && UIInterfaceOrientationIsLandscape(orientation)) )?0:self.tabBarController.tabBar.frame.size.height;
//        if (flag) {
//            delta =  0;
//        }
        self.viewSendMessage.frame =CGRectMake(self.view.frame.origin.x,
                                               self.view.frame.size.height ,
                                               self.view.frame.size.width,self.viewSendMessage.frame.size.height);
        self.viewDeleteMessage.frame = CGRectMake(self.view.frame.origin.x,
                                                  self.view.frame.size.height - self.viewDeleteMessage.frame.size.height-kHeight- delta,
                                                  self.view.frame.size.width, self.viewDeleteMessage.frame.size.height);
        
        
    }
}

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}

-(void) toMasterView {
    
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self updateNavigationControllerFrame];
    [self updateFooterFrame];
    [self updateTableViewFrame];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"seequMessagesBG-568@2x.png"]]];
            [self.view sendSubviewToBack:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"seequMessagesBG.png"] ]];
        } else {
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"seequMessagesBG.png"]]];
        }
    } else {
        
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
    }
    
    
    
}



-(void) pressButtonSendMessage {
    NSLog(@"sendButton  Pressed");
    if ([[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [self SendTextMessage:self.textFieldSendMessage.text];
        [self onTextFieldChange:nil];
        if(videoForSend || imageForSend){
            [self.viewSendMessage pressDeleteButton];
        }
        [self.viewSendMessage setNeedsLayout];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                        message:@"The network connection appears to be down.Do you want to  send  message  later?"
                                                       delegate:self
                                              cancelButtonTitle:@"NO"
                                              otherButtonTitles:@"YES", nil];
        
        alert.tag = NO_INTERNET_CONNECTION_TAG;
        
        [alert show];

    }
    
  
    
}

-(void) deleteAttachment {
    NSLog(@"deleteAttachment  Pressed");
    videoForSend = nil;
    imageForSend = nil;
    [self.buttonCamera setBackgroundImage:[UIImage imageNamed:@"seequMessageCameraIcon.png"] forState:UIControlStateNormal];
    [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSendOK.png"] forState:UIControlStateNormal];
    
}




- (void) AddKeyboardScrolling {
//    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
//        /*
//         Try not to call "self" inside this block (retain cycle).
//         But if you do, make sure to remove DAKeyboardControl
//         when you are done with the view controller by calling:
//         [self.view removeKeyboardControl];
//         */
//        
//        CGRect toolBarFrame =viewSendMessage.frame;
//        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
//        if (isAppeared) {
//            keyboardHeight = 0;
//        } else {
//            keyboardHeight = self.view.frame.size.height - keyboardFrameInView.origin.y;
//        }
//        
//        
//        [self.view setNeedsLayout];
//        //        [self updateViewController];
//        int diff = 48;
//        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
//            diff = 42;
//        }else
//            if(!IS_IOS_7)
//                keyboardHeight=keyboardHeight+diff;
//        
//        if (toolBarFrame.origin.y < self.view.frame.size.height - diff) {
//            self.viewSendMessage.frame = toolBarFrame;
//            NSLog(@" the  rect is   %@", NSStringFromCGRect(toolBarFrame));
//            //            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
//            //                CGRect tableViewFrame = tableMessages.frame;
//            //                if (toolBarFrame.origin.y > 0) {
//            //                    tableViewFrame = CGRectMake(tableViewFrame.origin.x, 44, tableViewFrame.size.width, toolBarFrame.origin.y - 44);
//            //                }
//            //
//            //                tableMessages.frame = tableViewFrame;
//            //            } else {
//            //                [self updateViewController];
//            //            }
//        }
//    }];
}

- (void) onContactObjectImage:(NSNotification *)notif {
    NSDictionary *dict = [notif object];
    
    if ([[dict objectForKey:@"seequID"] isEqualToString:self.stringUserId]) {
        self.userImage = [dict objectForKey:@"image"];
        
        NSArray *arrayCells = [self.tableMessages visibleCells];
        
        for (UITableViewCell *cell in arrayCells) {
            for (UIButton *buttonImageView in cell.subviews) {
                if (buttonImageView.tag == 11) {
                    [buttonImageView setBackgroundImage:self.userImage forState:UIControlStateNormal];
                    
                    break;
                }
            }
        }
    }
}

- (void) onTextFieldChange:(NSNotification*) notification {
    if (textFieldSendMessage.text.length) {
        [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSend.png"] forState:UIControlStateNormal];
    } else {
        [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSendOK.png"] forState:UIControlStateNormal];
    }
}


//- (void)creatMessagesTable {
//    arrayAllMessageItem = [[NSMutableArray alloc] init];
//    
//    for (NSString *key in arrayCurrentUserAllHistory) {
//        TBIMessageDetailsObject *obj = [arrayCurrentUserAllHistory objectForKey:key];
//        MessageItem *item = nil;
//        if ((obj.type == Message_Type_Video)||(obj.type == Message_Type_Video_Response)||(obj.type == Message_Type_Double_Take)) {
//            item = [[MessageItem alloc] initWithMessageDetailsObject:obj
//                                                         Orientation:self.interfaceOrientation
//                                                               video:nil save:NO];
//            
//        } else {
//            item = [[MessageItem alloc] initWithMessageDetailsObject:obj
//                                                         Orientation:self.interfaceOrientation
//                                                               Image:nil save:NO];
//        }
//        item.delegate = self;
//        [arrayAllMessageItem addObject:item];
//    }
//    
//    ARRAY = [self SortArrayByDay:arrayAllMessageItem];
//    
//    if (isShow) {
//        [self.tableMessages reloadData];
//    }
//    
//    [self tableRectToVizibleAnimate:YES];
//}

- (NSMutableArray*) SortArrayByDay:(NSMutableArray*)array {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date"  ascending:YES];
    NSArray *sorted_array = [array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    array = [[NSMutableArray alloc] initWithArray:sorted_array];
    NSMutableArray *ret_array = [[NSMutableArray alloc] init];
    
    int current_day = 0;
    
    for (MessageItem *item in array) {
        int message_day = item.date/86400;
        
        if (current_day != message_day) {
            current_day = message_day;
            NSMutableArray *array_day = [[NSMutableArray alloc] init];
            [array_day addObject:item];
            [ret_array addObject:array_day];
        } else {
            NSMutableArray *array_day = [ret_array lastObject];
            
            if (array_day) {
                [array_day addObject:item];
            }
        }
    }
    
    return ret_array;
}



- (void) UpdateMessageItemWithMessageID:(NSString*)messageID {
//    BOOL found = NO;
//    for (NSArray *array in ARRAY) {
//        for (MessageItem *item in array) {
//            if ([item.messageID isEqualToString:messageID]) {
//                item.delivered = YES;
//                found = YES;
//                
//                break;
//            }
//        }
//        
//        if (found) {
//            break;
//        }
//    }
}

- (IBAction)onButtonSendMessage:(id)sender {
    if ([[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [self SendTextMessage:self.textFieldSendMessage.text];
        [self onTextFieldChange:nil];
        
    } else {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    }
}

- (void) onButtonBack:(id)sender {
    fetchedResultsController.delegate = nil;
    fetchedResultsController = nil;
    [NSFetchedResultsController deleteCacheWithName:nil]; 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kVideoViewChangeNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
   
    
}

- (IBAction) onButtonEdit:(id)sender {
    
      UIButton* button = (UIButton*) sender;
    
    isFromEdit = YES;
    [self.textFieldSendMessage resignFirstResponder];
    self.viewSendMessage.frame = CGRectMake(0, self.view.frame.size.height - self.viewSendMessage.frame.size.height, self.viewSendMessage.frame.size.width, self.viewSendMessage.frame.size.height);
    
     if (self.viewCallMenu.tag == 1) {
        [self onButtonShowCallMenu:nil];
    }
    if (!isForEditing) {
        
         isForEditing = YES;
        //        if (isShow) {
        //            [self.tableMessages reloadData];
        //       }
        if (arrayForDelete.count>0) {
            self.buttonDelete.enabled = YES;
        } else {
            self.buttonDelete.enabled = NO;
        }
    } else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(showViewSendMessage)];
        [UIView setAnimationDuration:0.3];
        
        [UIView commitAnimations];
        [self resetAllMessagesFromEditing];
        isForEditing = NO;
        //        if (isShow) {
        //            [self.tableMessages reloadData];
        //        }
        
        
    }
    [self.tableMessages setEditing:isForEditing animated:YES];
    [self.tableMessages reloadData];
    [self.buttonEdit setSelected:YES];
    if (sender) {
        [button setSelected:isForEditing];
    }else
        [self.buttonEdit setSelected:NO];
    
    [self.view setNeedsLayout];
    // [self.ed setBackgroundImage:[UIImage imageNamed:@"seequButtonDone"]  forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    // setBackgroundImage:[UIImage imageNamed:@"seequButtonDone"] forState:UIControlStateNormal
}

-(void) resetAllMessagesFromEditing{

    [arrayForDelete removeAllObjects];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView{
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:
                      @"document.body.innerHTML"];
    NSLog(@"%@",html);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:
                      @"document.body.innerHTML"];
    NSLog(@"%@",html);
}

- (IBAction)onButtonVideo:(id)sender {
    if ([[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView setVideoState:VideoViewState_TAB_MENU Animation:YES];
    } else {
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView setVideoState:VideoViewState_NORMAL Animation:YES];
    }
}
-(void)editMedia:(BOOL)forMediaTypeVideo{
    if (forMediaTypeVideo) {
        videoEditor=[[UIVideoEditorController alloc] init];
        [videoEditor setDelegate:self];
        videoEditor.videoPath=[videoUrl path];
        [self.tabBarController presentViewController:videoEditor animated:YES completion:nil];
    }else{
        [self launchPhotoEditorWithImage:imageForSend highResolutionImage:imageForSend controller:self.tabBarController];
    }
}

- (IBAction)onButtonVoiceCall:(id)sender {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        ContactObject *obj = [[ContactStorage sharedInstance] GetContactObjectBySeequId:self.stringUserId];
        NSAssert(obj, @"Must be found");
        [[idoubs2AppDelegate sharedInstance].videoService CallWithContactObject:obj Video:NO];
            
    }
    
    if (self.viewCallMenu.tag == 1) {
        [self onButtonShowCallMenu:nil];
    }
}

- (IBAction)onButtonRingback:(id)sender {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        SeequRingBackViewController *ringBackViewController = [[SeequRingBackViewController alloc] initWithNibName:@"SeequRingBackViewController" bundle:nil];
        
        ContactObject *obj = [[ContactStorage sharedInstance] GetContactObjectBySeequId:self.stringUserId];
        ringBackViewController.contactObj = obj;
        ringBackViewController.videoViewState = self.videoViewState;
        [self.tabBarController presentViewController:ringBackViewController animated:YES completion:nil];
        
    }
}

- (IBAction)onButtonCamera:(id)sender {
}

-(void) setCallMenuVisible:(NSNumber*) isVisisble{
    self.viewCallMenu.hidden=[isVisisble boolValue];
}

- (void) onButtonShowCallMenu:(id)sender {
    if (self.viewCallMenu.tag == 0) {
        [self.textFieldSendMessage resignFirstResponder];
        //        self.viewSendMessage.frame = CGRectMake(0, self.view.frame.size.height - self.viewSendMessage.frame.size.height, self.viewSendMessage.frame.size.width, self.viewSendMessage.frame.size.height);
        
        //        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        //            CGRect tableViewFrame = tableMessages.frame;
        //            tableViewFrame = CGRectMake(tableViewFrame.origin.x, 44, tableViewFrame.size.width, self.viewSendMessage.frame.origin.y - 44);
        //            tableMessages.frame = tableViewFrame;
        //        } else {
        //            [self UpdateTableFrameForPortraitAndScrallTable:NO];
        //        }
    }
    if (isForEditing) {
        [self onButtonEdit:nil];
    }
        NSString* subscr = [[ContactStorage sharedInstance] GetUserSubscriptionBySeequId:self.stringUserId];
        BOOL flag = [subscr isEqualToString:@"both"];

        if(!flag){
                for(UIView *view in self.viewCallMenu.subviews){
                        if ([view isKindOfClass:[UIButton class]]) {
                                UIButton *button=(UIButton *)view;
                                button.enabled=NO;
                        }
                }
        }
        
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    //    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
    if (self.viewCallMenu.tag == 0) {
        
        self.viewCallMenu.frame = CGRectMake(self.tableMessages.frame.origin.x, self.tableMessages.frame.origin.y, self.viewCallMenu.frame.size.width, 59);
        self.viewCallMenu.tag = 1;
        //self.viewCallMenu.hidden=NO;
        [self performSelector:@selector(setCallMenuVisible:) withObject:[NSNumber numberWithBool:NO] afterDelay:.05];
        
        [buttonTitle setBackgroundImage:[UIImage imageNamed:@"SeequMessageTitleButtonBGUp.png"] forState:UIControlStateNormal];
    } else {
        self.viewCallMenu.frame = CGRectMake(self.tableMessages.frame.origin.x, -60, self.viewCallMenu.frame.size.width, 59);
        self.viewCallMenu.tag = 0;
        [self performSelector:@selector(setCallMenuVisible:) withObject:[NSNumber numberWithBool:YES] afterDelay:.10];
        // self.viewCallMenu.hidden=YES;
        
        [buttonTitle setBackgroundImage:[UIImage imageNamed:@"SeequMessageTitleButtonBGDown.png"] forState:UIControlStateNormal];
    }
    //    } else {
    //        if (self.viewCallMenu.tag == 0) {
    //            self.viewCallMenu.frame = CGRectMake(0, 0, 320, 59);
    //            self.viewCallMenu.tag = 1;
    //            [buttonTitle setBackgroundImage:[UIImage imageNamed:@"SeequMessageTitleButtonBGUp.png"] forState:UIControlStateNormal];
    //        } else {
    //            self.viewCallMenu.frame = CGRectMake(0, -60, 320, 59);
    //            self.viewCallMenu.tag = 0;
    //            [buttonTitle setBackgroundImage:[UIImage imageNamed:@"SeequMessageTitleButtonBGDown.png"] forState:UIControlStateNormal];
    //        }
    //    }
    
    [UIView commitAnimations];
}



- (void)showViewDeleteMessage {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    [self UpdateViewDeleteMessagesHeader:self.interfaceOrientation];
    [UIView commitAnimations];
}

- (void)showViewSendMessage {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    //    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
    //        CGFloat diff=IS_IOS_7?46:0;
    //        self.viewSendMessage.frame = CGRectMake(0, self.view.frame.size.height - 48-diff, 320, 48);
    //    } else {
    //        self.viewSendMessage.frame = CGRectMake(0, self.view.frame.size.height - 42, [[UIScreen mainScreen] bounds].size.height, 42);
    //    }
    [UIView commitAnimations];
}

- (void) SendTextMessage:(NSString*)text {
      
    if(text.length > 0 || imageForSend || videoForSend) {
        NSMutableDictionary*  dictionary  =[[NSMutableDictionary alloc] init];
        NSString*  seequ_id =self.stringUserId? stringUserId:self.groupInfo.groupID;
        [dictionary setObject:seequ_id forKey:@"to"];
        [dictionary setObject:MESSAGE_ID forKey:@"msgId"];
        [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"isDelivered"];
        if (!text || !text.length) {
            text = @" ";
        }
        [dictionary setObject:text forKey:@"msg"];
        [dictionary setObject:self.messageOwner.isGroup forKey:@"isGroup"];
        [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"isSend"];
        [dictionary setObject:[NSDate date] forKey:@"date"];
        

     
        

        if(!text)
            text = @"";
        if(imageForSend){
            NSString *image_Name = [NSString stringWithFormat:@"image_name_%@_t.png", [dictionary objectForKey:@"msgId"]];
            NSString *url = [NSString stringWithFormat:@"https://us-east.manta.joyent.com/seequ/stor/%@/%@", seequ_id, image_Name];
            [dictionary setObject:url forKey:@"url"];
            [dictionary setObject:[NSNumber numberWithInt:Message_Type_Image] forKey:@"msgType"];
            if(!fromLibrary){///@todo Levon
                NSData *jpeg = [NSData dataWithData:UIImageJPEGRepresentation(imageForSend, 1.0)];
                CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
                CFDictionaryRef dict = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
                NSDictionary *metadata = CFBridgingRelease(dict);
                CFRelease(source);
                NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
                NSMutableDictionary *EXIFDictionary = [metadataAsMutable objectForKey:(__bridge NSString *)kCGImagePropertyExifDictionary];
                if(!EXIFDictionary) {
                    EXIFDictionary = [NSMutableDictionary dictionary];
                }
                [EXIFDictionary setObject:@"Seequ" forKey:(__bridge NSString*)kCGImagePropertyExifLensMake];
                [EXIFDictionary setObject:@"Seequ" forKey:(__bridge NSString*)kCGImagePropertyExifUserComment];
                [metadataAsMutable setObject:EXIFDictionary forKey:(__bridge NSString*)kCGImagePropertyExifDictionary];
                
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
                [library writeImageDataToSavedPhotosAlbum:jpeg metadata:(NSDictionary*)metadataAsMutable completionBlock:nil];
            }
            ///@todo write  to file photo
             NSString *imageToSaveFolder = [Common makeFolderIfNotExist:seequ_id];
            if (!imageToSaveFolder) {
                NSAssert(NO, @"Must  be saved");
            }
            
            NSString *imagePath = [imageToSaveFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_image.png", [dictionary objectForKey:@"msgId"]]];
            imageForSend=[self changeImageSize:imageForSend];
            NSData *imageData = UIImagePNGRepresentation(imageForSend);
            [imageData writeToFile:imagePath options:NSAtomicWrite error:nil];
            UIImage* thumb = [Common getThumbImage:imageForSend];
            [[MessageCoreDataManager sharedManager] addMessageForSend:dictionary thumbnail:thumb ];
            SeequMessageObject* info = [[SeequMessageObject alloc] init];
            info.msgId = [dictionary objectForKey:@"msgId"];
            info.from =seequ_id;
            info.image =imageForSend;
            info.msg = text;
            info.url = url;
            info.type = Message_Type_Image;
            if([info.from rangeOfString:@"groupid"].location == NSNotFound) {
                info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
            } else {
                info.from_name = self.groupInfo.name;
            }

            [Common performSelectorInBackground:@selector(sendMessageWithImageFile:) withObject:info];
        } else if(videoForSend) {
            if (isVideoResponse) {
                [dictionary setObject:[NSNumber numberWithInt:Message_Type_Video_Response] forKey:@"msgType"];
                isVideoResponse = NO;
            } else {
               [dictionary setObject:[NSNumber numberWithInt:message_Type] forKey:@"msgType"];
            }
            
            if(!fromLibrary){
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoUrl]){
                    [library writeVideoAtPathToSavedPhotosAlbum:videoUrl
                                                completionBlock:^(NSURL *assetURL, NSError *error){
                                                    
                                                }
                     
                     ];}
            }
            UIImage*  thumbnail =[Common getVideoThumbnail:videoUrl];
            NSString *videoName = [NSString stringWithFormat:@"video_name_%@.mp4", [dictionary objectForKey:@"msgId"]];
            NSString *url = [NSString stringWithFormat:@"https://us-east.manta.joyent.com/seequ/stor/%@/%@", seequ_id, videoName];
            [dictionary setObject:url forKey:@"url"];
//////////////////////////////////////////////////////////////////////////////
            [Common saveVideoToFolder:videoForSend contact:seequ_id message:[dictionary objectForKey:@"msgId"]];
            SeequMessageObject* info = [[SeequMessageObject alloc] init];
            info.msgId = [dictionary objectForKey:@"msgId"];
            info.from =seequ_id;
            info.videoData =videoForSend;
            info.msg = text;
            info.thumbnail = thumbnail;
            info.type  = (Message_Type)[[dictionary objectForKey:@"msgType"] integerValue];
            info.url = url;
            info.url_dt = self.dt_url?self.dt_url:@"";
            if([info.from rangeOfString:@"groupid"].location == NSNotFound) {
                info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
            } else {
                info.from_name = self.groupInfo.name;
            }
       

            self.dt_url = nil;
            
            
            NSString*  folder = (info.type == Message_Type_Double_Take)?[Common makeDTFolder]:[Common makeFolderIfNotExist:seequ_id];
            NSString *thePath = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_video.mp4", info.msgId]];
            [info.videoData writeToFile:thePath options:NSAtomicWrite error:nil];
            NSURL* url1 = [NSURL fileURLWithPath:thePath ];
            UIImage* t = [Common getVideoThumbnail:url1];
            [[MessageCoreDataManager sharedManager] addMessageForSend:dictionary thumbnail:t];

            [Common performSelectorInBackground:@selector(sendMessageWithVideoFile:) withObject:info];

        } else {
            [dictionary setObject:[NSNumber numberWithInt:Message_Type_Text] forKey:@"msgType"];
            if ([text rangeOfString:DOUBLE_TAKE_REJECT].location == NSNotFound) {
                [[MessageCoreDataManager sharedManager] addMessageForSend:dictionary thumbnail:nil];
            }
            ///@todo  needs  to  eliminate XMPP  and refactor  the  function to have concrete return value
            RTMPChatManager* manager = (RTMPChatManager*)[idoubs2AppDelegate getChatManager];
            SeequMessageObject* info = [[SeequMessageObject alloc] init];
            info.msgId = [dictionary objectForKey:@"msgId"];
            info.from =seequ_id;
            info.msg = text;
            info.type = Message_Type_Text;
            if([info.from rangeOfString:@"groupid"].location == NSNotFound) {
                info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
            } else {
                info.from_name = self.groupInfo.name;
            }

            [ manager sendTextMessage:info AddToResendList:YES];
        }
        
        
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Seequ"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"OK", @"Thank you", nil];
        sheet.tag = SHEET_OK_THANKS;
        sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [sheet showFromTabBar:[idoubs2AppDelegate sharedInstance].tabBarController.tabBar];
    }
    
    self.textFieldSendMessage.text = @"";
    [self.buttonCamera setBackgroundImage:[UIImage imageNamed:@"seequMessageCameraIcon.png"] forState:UIControlStateNormal];
    [self.viewSendMessage removeAttachment:YES];
}
- (void)didFinish:(SeequVideoRecorerViewController *)controller Image:(UIImage *)img HighResolutionImage:(UIImage *)himg fromLibrary:(BOOL)library {
    //
    fromLibrary=library;
    
    
    [controller.captureManager finish];
    
    NSLog(@"img.size.actual: %@", NSStringFromCGSize(img.size));
    
    imageForSend = img;
    [self.buttonCamera setBackgroundImage:[UIImage imageNamed:@"seequMessageCameraAtachedIcon.png"] forState:UIControlStateNormal];
    [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSend.png"] forState:UIControlStateNormal];
    
    [self.viewSendMessage setImage:img forVideo:NO];
    
    
    //    NSLog(@"img.size.modified: %@", NSStringFromCGSize(img.size));
    //    [self launchPhotoEditorWithImage:img highResolutionImage:img controller:controller];
    
}
-(UIImage*)changeImageSize:(UIImage*)image{
        if (image.size.width > 800 || image.size.height > 800) {
                if (image.size.width > image.size.height) {
                        int newHeight = (image.size.height*800)/image.size.width;
                        image = [SeequSendMessageViewController imageWithImage:image scaledToSize:CGSizeMake(800, newHeight)];
                } else {
                        int newWidth = (image.size.width*800)/image.size.height;
                        image = [SeequSendMessageViewController imageWithImage:image scaledToSize:CGSizeMake(newWidth, 800)];
                }
        }
        return image;
}

-(void) didChangeRecorderType:(SeequRecorderType)type {
    switch (type) {
        case SeequRecorderTypeDoubleTake:
            message_Type = Message_Type_Double_Take;
            break;
        case SeequRecorderTypePhoto:
            message_Type = Message_Type_Image;
            break;
        case SeequRecorderTypeVideo:
            message_Type = Message_Type_Video;
            
        default:
            break;
    }
}

- (void)didFinish1:(AviaryPickerController *)controller Image:(UIImage *)img HighResolutionImage:(UIImage *)himg {
    [controller dismissViewControllerAnimated:NO completion:^{
        //[controller.captureManager.previewLayer removeFromSuperlayer];
        
    }];
    
    
    NSLog(@"img.size.actual: %@", NSStringFromCGSize(img.size));
    
    if (img.size.width > 800 || img.size.height > 800) {
        if (img.size.width > img.size.height) {
            int newHeight = (img.size.height*800)/img.size.width;
            img = [SeequSendMessageViewController imageWithImage:img scaledToSize:CGSizeMake(800, newHeight)];
        } else {
            int newWidth = (img.size.width*800)/img.size.height;
            img = [SeequSendMessageViewController imageWithImage:img scaledToSize:CGSizeMake(newWidth, 800)];
        }
    }
    
    NSLog(@"img.size.modified: %@", NSStringFromCGSize(img.size));
    [self launchPhotoEditorWithImage:img highResolutionImage:img controller:self.tabBarController];
    
}
-(void)didfinishPick:(AviaryPickerController *)controller video:(NSURL *)videoURL{
//    [controller dismissViewControllerAnimated:NO completion:nil];
//    self.videoForSend = [NSData dataWithContentsOfURL:videoURL];
//    fromLibrary=YES;
//    videoUrl=videoURL;
//    UIImage *image=[self getVideoThumbnail:videoURL];
//    [self.viewSendMessage setImage:image forVideo:YES];
//    [self.buttonCamera setBackgroundImage:[UIImage imageNamed:@"seequMessageCameraAtachedIcon.png"] forState:UIControlStateNormal];
//    [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSend.png"] forState:UIControlStateNormal];
}



#pragma mark - Photo Editor Creation and Presentation
- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage controller:(UIViewController*) vc
{
    //    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    // Initialize the photo editor and set its delegate
    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:editingResImage];
    [photoEditor setDelegate:self];
    
    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    //    // If a high res image is passed, create the high res context with the image and the photo editor.
    //    if (highResImage) {
    //        [self setupHighResContextForPhotoEditor:photoEditor withImage:highResImage];
    //    }
    
    // Present the photo editor.
    [vc presentViewController:photoEditor animated:YES completion:nil];
}

- (void) setPhotoEditorCustomizationOptions
{
    // Set Tool Order
    NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFFrames, kAFStickers, kAFEnhance, kAFOrientation, kAFCrop, kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme, kAFSharpness];
    [AFPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set Custom Crop Sizes
    [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:NO];
    NSDictionary * fourBySix = @{kAFCropPresetHeight : @(4.0f), kAFCropPresetWidth : @(6.0f)};
    NSDictionary * fiveBySeven = @{kAFCropPresetHeight : @(5.0f), kAFCropPresetWidth : @(7.0f)};
    NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
    [AFPhotoEditorCustomization setCropToolPresets:@[fourBySix, fiveBySeven, square]];
    
    // Set Supported Orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray * supportedOrientations = @[@(UIInterfaceOrientationPortrait), @(UIInterfaceOrientationPortraitUpsideDown), @(UIInterfaceOrientationLandscapeLeft), @(UIInterfaceOrientationLandscapeRight)];
        [AFPhotoEditorCustomization setSupportedIpadOrientations:supportedOrientations];
    }
}

#pragma Photo Editor Delegate Methods

// This is called when the user taps "Done" in the photo editor.
- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    imageForSend = image;
    [self.buttonCamera setBackgroundImage:[UIImage imageNamed:@"seequMessageCameraAtachedIcon.png"] forState:UIControlStateNormal];
    [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSend.png"] forState:UIControlStateNormal];
    
    [self.viewSendMessage setImage:image forVideo:NO];
    //    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSelector:@selector(updateFF) withObject:nil afterDelay:1];
    [self.viewSendMessage setNeedsLayout];
}

-(void) updateFF {
    [self.view setNeedsLayout];
    
}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(UIImagePickerController *)imagePicker{
    if(!_imagePicker){
        _imagePicker = [[UIImagePickerController alloc]init];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    return _imagePicker;
}

#pragma ActionSheet Delegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == [actionSheet cancelButtonIndex])
        return;
    __weak SeequSendMessageViewController* weakSelf = self;
    switch (actionSheet.tag) {
        case SHEET_OK_THANKS:{
            switch (buttonIndex) {
                case 0: {
                    self.textFieldSendMessage.text = @"OK";
                    [self onButtonSendMessage:nil];
                }
                    break;
                case 1: {
                    self.textFieldSendMessage.text = @"Thank you";
                    [self onButtonSendMessage:nil];
                }
                    break;
                default:
                    break;
            }
            
        }
            break;
        case SHEET_CHOOSE_ATTACHEMENT_TYPE:{
            switch (buttonIndex) {
                case 0: {
                    if (![[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
                        //                        AviaryPickerController * imagePicker = [AviaryPickerController new];
                        //                        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                        //                        imagePicker.showsCameraControls = NO;
                        //                        imagePicker.avDelegate = self;
                        //
                        //                        [self.tabBarController presentViewController:imagePicker animated:YES completion:nil];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            SeequVideoRecorerViewController*  videoRecorder = [[SeequVideoRecorerViewController alloc] initWithType:SeequRecorderTypePhoto];
                            videoRecorder.captureDelegate = weakSelf;
                            videoRecorder.devicePosition = AVCaptureDevicePositionBack;
                            message_Type = Message_Type_Image;
                            [weakSelf.tabBarController presentViewController:videoRecorder animated:YES completion:nil];
                            
                        });
                    } else {
                            AviaryPickerController * imagePicker = [AviaryPickerController new];
                            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                            imagePicker.avDelegate = self;
                            [self.tabBarController presentViewController:imagePicker animated:YES completion:nil];
                        
                    }
                    
                }
                    break;
                case 1: {
                        if(![[idoubs2AppDelegate sharedInstance].videoService isInCall]){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                SeequVideoRecorerViewController*  videoRecorder = [[SeequVideoRecorerViewController alloc] initWithType:SeequRecorderTypeVideo];
                                videoRecorder.captureDelegate =weakSelf;
                                videoRecorder.devicePosition = AVCaptureDevicePositionFront;
                                message_Type = Message_Type_Video;
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                            [weakSelf.tabBarController presentViewController:videoRecorder animated:YES completion:nil];

                                    });
                                
                            });
                        }
//                        else{
//                            AviaryPickerController * imagePicker = [AviaryPickerController new];
//                            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//                            [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
//                            imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
//                            imagePicker.allowsEditing=NO;
//                            imagePicker.avDelegate = self;
//                            [self.tabBarController presentViewController:imagePicker animated:YES     completion:nil];
//                            
//                        }
                }
                    break;
                case 2: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SeequVideoRecorerViewController*  videoRecorder = [[SeequVideoRecorerViewController alloc] initWithType:SeequRecorderTypeDoubleTake];
                        videoRecorder.captureDelegate =weakSelf;
                        message_Type = Message_Type_Double_Take;
                        videoRecorder.devicePosition = AVCaptureDevicePositionFront;
                        
                        [weakSelf.tabBarController presentViewController:videoRecorder animated:YES completion:nil];
                    });
                }
                    break;
                default:
                    break;
            }
            
        }
            break;
        case SHEET_EDIT_IMAGE :{
            
            switch (buttonIndex) {
                case 0: {
                    // Initialize the photo editor and set its delegate
                    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:imageForSend];
                    [photoEditor setDelegate:self];
                    
                    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        [self setPhotoEditorCustomizationOptions];
                    });
                    
                    //    // If a high res image is passed, create the high res context with the image and the photo editor.
                    //    if (highResImage) {
                    //        [self setupHighResContextForPhotoEditor:photoEditor withImage:highResImage];
                    //    }
                    
                    // Present the photo editor.
                    [self.tabBarController presentViewController:photoEditor animated:YES completion:nil];
                }
                    break;
                case 1: {
                    imageForSend = nil;
                    [self.viewSendMessage removeAttachment:YES];
                    [self.buttonCamera setBackgroundImage:[UIImage imageNamed:@"seequMessageCameraIcon.png"] forState:UIControlStateNormal];
                    [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSendOK.png"] forState:UIControlStateNormal];
                }
                    break;
                case 2: {
                    if (![[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            SeequVideoRecorerViewController*  videoRecorder = [[SeequVideoRecorerViewController alloc] initWithType:SeequRecorderTypePhoto];
                            videoRecorder.captureDelegate =weakSelf;
                            videoRecorder.devicePosition = AVCaptureDevicePositionBack;
                            [weakSelf.tabBarController presentViewController:videoRecorder animated:YES completion:nil];
                            
                        });
                        
                    } else {
                        AviaryPickerController * imagePicker = [AviaryPickerController new];
                        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                        imagePicker.avDelegate = self;
                        
                        [self.tabBarController presentViewController:imagePicker animated:YES completion:nil];
                    }
                }
                    break;
                default:
                    break;
            }
            
            
            //////////////////////////
            
            
        }
            break;
        case SHEET_EDIT_VIDEO :{
            
            switch (buttonIndex) {
                case 0: {
                    videoForSend = nil;
                    [self.viewSendMessage removeAttachment:YES];
                    [self.buttonCamera setBackgroundImage:[UIImage imageNamed:@"seequMessageCameraIcon.png"] forState:UIControlStateNormal];
                    [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSendOK.png"] forState:UIControlStateNormal];
                }
                    break;
                case 1: {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SeequVideoRecorerViewController*  videoRecorder = [[SeequVideoRecorerViewController alloc] initWithType:SeequRecorderTypeVideo];
                        videoRecorder.captureDelegate =weakSelf;
                        videoRecorder.devicePosition = AVCaptureDevicePositionFront;
                        [weakSelf.tabBarController presentViewController:videoRecorder animated:YES completion:nil];
                        
                    });
                    
                }
                    break;
                default:
                    break;
            }
            
            
            //////////////////////////
            
            
        }
            
            
        default:
            break;
    }
}
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            if([button.titleLabel.text isEqualToString:@"Send video"]||[button.titleLabel.text isEqualToString:@"Send double take"]){
                if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]){
                    button.enabled=NO;
//                    if(!IS_IOS_7){
                        button.titleLabel.textColor=[UIColor blackColor];
//                    }
                }else if(self.groupInfo &&[button.titleLabel.text isEqualToString:@"Send double take"]){
                        button.enabled=NO;
//                        if(!IS_IOS_7){
                                button.titleLabel.textColor=[UIColor blackColor];
//                        }
                }else{
                    button.enabled=YES;
                }
            }
        }
    }
    
}

-(void) captureFinished:(NSURL *)url fromLibrary:(BOOL)library {
    self.videoForSend = [NSData dataWithContentsOfURL:url];
    fromLibrary=library;
    videoUrl=url;
    UIImage *image=[Common getVideoThumbnail:url];
    [self.viewSendMessage setImage:image forVideo:YES];
    [self.buttonCamera setBackgroundImage:[UIImage imageNamed:@"seequMessageCameraAtachedIcon.png"] forState:UIControlStateNormal];
    [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSend.png"] forState:UIControlStateNormal];
    
}

-(void) takePhotoFinished:(UIImage *)image {
    imageForSend = image;
    [self.buttonCamera setBackgroundImage:[UIImage imageNamed:@"seequMessageCameraAtachedIcon.png"] forState:UIControlStateNormal];
    [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSend.png"] forState:UIControlStateNormal];
    
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    
    
    self.videoForSend = [NSData dataWithContentsOfURL:videoURL];
    [self.viewSendMessage setImage:[UIImage imageNamed:@"play_btn"] forVideo:NO];
    
    [self.buttonCamera setBackgroundImage:[UIImage imageNamed:@"seequMessageCameraAtachedIcon.png"] forState:UIControlStateNormal];
    [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSend.png"] forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:NO completion:^{
        [picker stopVideoCapture];
    }];
}
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [picker stopVideoCapture];
    }];
}

- (void) didReceiveMessage:(NSDictionary *)dict isExistingContact:(BOOL)isExist {
    //    NSString *path = [Common createEditableCopyOfFileWithFileName:@"xmpphistory.plist"];
    //    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    //    NSMutableDictionary *m_dictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    //    [arrayCurrentUserAllHistory addObject:dict];
    //    [m_dictionary setObject:arrayCurrentUserAllHistory forKey:self.stringUserId];
    //    [m_dictionary writeToFile:path atomically:NO];
    //
    //    MessageItem *item = [[MessageItem alloc] initWithDictionary:dict Orientation:self.interfaceOrientation];
    //    item.delegate = self;
    //    [arrayAllMessageItem addObject:item];
    //
    //    ARRAY = [self SortArrayByDay:arrayAllMessageItem];
    //
    //    if (isShow) {
    //        [self.tableMessages reloadData];
    //    }
    //    [self tableRectToVizibleAnimate:YES];
    //
    //
    //    if (!isShow) {
    //        NSString *from = [dict objectForKey:@"from"];
    //        [Common addBadgeOnCurrentUser:from];
    //
    //        [Common AddMissedWithSeequID:from Type:2];
    //
    //        if ([idoubs2AppDelegate sharedInstance].isMessagesView) {
    //            NSNotification *notification = [NSNotification notificationWithName:@"reLoadMessageTable" object:nil];
    //            [[NSNotificationCenter defaultCenter] postNotification:notification];
    //        }
    //    }
}

- (void)tableRectToVizibleAnimate:(BOOL)animate {
    //    if (!isShow) {
    //        return;
    //    }
//    
//    @try {
//        if (ARRAY.count > 0) {
//            NSArray *arr = [ARRAY objectAtIndex: ARRAY.count - 1];
//            if (arr.count) {
//                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:arr.count-1 inSection:ARRAY.count-1];
//                [self.tableMessages scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//            }
//        }
//    }
//    @catch (NSException *exception) {
//        NSLog(@"exception.description: %@", exception.description);
//    }
}

- (void)keyboardDidShow:(NSNotification *)notif {
    if (![self.navigationController.visibleViewController isEqual:self]) {
        return;
    }
    keyboardOpened = YES;
    [SeequMessageItemCell setRecognizerHandler:YES];
    NSLog(@"keyboardDidShow");
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        _keyboardHeight=161;
    }else
        _keyboardHeight =216;
    
    self.viewCallMenu.tag = 1;
    [self onButtonShowCallMenu:nil];
    
    if (self.navigationController.navigationBarHidden) {
        self.viewSendMessage.center = CGPointMake(self.viewSendMessage.center.x, self.view.frame.size.height - 182);
    } else {
        self.viewSendMessage.center = CGPointMake(self.viewSendMessage.center.x, self.view.frame.size.height - 190);
    }
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        CGRect frame = self.tableMessages.frame;
        frame.size.height = self.viewSendMessage.frame.origin.y - 44;
        
        if (self.navigationController.navigationBarHidden) {
            frame.origin.y = 44;
        } else {
            frame.origin.y = 0;
        }
        //
        //        if (!self.hidesBottomBarWhenPushed) {
        //            if ([[idoubs2AppDelegate sharedInstance].videoService isInCall] && videoViewState != VideoViewState_HIDE && [[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
        //                if (videoViewState == VideoViewState_TAB) {
        ////                    frame.size.height -= 115;
        //                }
        //            }
        //        }
        
        //        self.tableMessages.frame = frame;
        [self UpdateViewCallMenuFrame];
    }
    [self tableRectToVizibleAnimate:YES];
    [self.view setNeedsLayout];
    return;
}

- (void)keyboardWillHide:(NSNotification *)notif {
    if (![self.navigationController.visibleViewController isEqual:self]) {
        return;
    }
    [SeequMessageItemCell setRecognizerHandler:NO];
    
    NSLog(@"keyboardWillHide");
    keyboardOpened = NO;
    _keyboardHeight = 0;
    
    
    if (isShow) {
        [self.tableMessages reloadData];
    }
    [self.view setNeedsLayout];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textFieldSendMessage resignFirstResponder];
    
    return YES;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo>sectionInfo=[fetchedResultsController.sections objectAtIndex:section];
    return sectionInfo.numberOfObjects;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return nil;
//}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return nil;
//    id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
//    NSString *rawDateStr = [theSection name];
//    // Convert rawDateStr string to NSDate...
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
//    NSDate *date = [formatter dateFromString:rawDateStr];
//    
//    // Convert NSDate to format we want...
//    [formatter setDateFormat:@"d MMM"];
//    NSString *formattedDateStr = [formatter stringFromDate:date];
//    return formattedDateStr;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSString *rawDateStr = [theSection name];
    // Convert rawDateStr string to NSDate...
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    NSDate *date = [formatter dateFromString:rawDateStr];
    
    // Convert NSDate to format we want...
    [formatter setDateFormat:@"d MMM"];
    NSString *formattedDateStr = [formatter stringFromDate:date];

//
    return [self creatTableHeaderViewWithTitle:formattedDateStr];
    return nil;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CDMessage* messageObj = [fetchedResultsController objectAtIndexPath:indexPath];
    return [SeequMessageItemCell heightForItem:messageObj];
}

-(BOOL) isForDelete:(CDMessage*) message {
    for(CDMessage* m  in arrayForDelete) {
        if ([m.messageID isEqualToString:message.messageID]) {
            return YES;
        }
    }
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SeequMessageItemCell *cell = (SeequMessageItemCell*)[tableView dequeueReusableCellWithIdentifier: MESSAGE_CELL_IDENTIFIER];
    //
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    CDMessage *obj=[fetchedResultsController objectAtIndexPath:indexPath];
     cell.delegate = self;
 //   [cell updateCell1: obj];
    cell.needToDelete = [self isForDelete:obj];
    [cell updateCell:obj ];
    return cell;
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//    if (isEditing) {
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        UIButton *button = nil;
//        for (UIButton *btn in cell.subviews) {
//            if (btn.tag == 20 || btn.tag == 21) {
//                button = btn;
//                break;
//            }
//        }
//
//        if (!button) {
//            return;
//        }
//
//        if (!arrayIndexPath) {
//            arrayIndexPath = [[NSMutableArray alloc] init];
//        }
//
//        if (button.tag == 20) {
//            button.tag = 21;
//            [button setBackgroundImage:[UIImage imageNamed:@"SeequButtonCheck.png"] forState:UIControlStateNormal];
//            [arrayIndexPath addObject:indexPath];
//        } else {
//            button.tag = 20;
//            [button setBackgroundImage:[UIImage imageNamed:@"SeequButtonUncheck.png"] forState:UIControlStateNormal];
//            [arrayIndexPath removeObject:indexPath];
//        }
//
//        if (arrayIndexPath.count>0) {
//            self.buttonDelete.enabled = YES;
//        } else {
//            self.buttonDelete.enabled = NO;
//        }
//    }
//}
//


#pragma mark ************************************

- (UIView*)creatTableHeaderViewWithTitle:(NSString*)date {
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableMessages.frame.size.width, 20)];
    [labelTitle setBackgroundColor:[UIColor blackColor]];
    [labelTitle setTextColor:[UIColor whiteColor]];
    labelTitle.font = [UIFont boldSystemFontOfSize:14];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.text = [date capitalizedString];
    return labelTitle;
}

//- (void)onButtonCheck:(id)sender event:(id)_event{
//    UIButton *button = (UIButton*)sender;
//    NSIndexPath *indPath = [self CreateIndexPathFromEvent:_event];
//
//    if (!arrayIndexPath) {
//        arrayIndexPath = [[NSMutableArray alloc] init];
//    }
//
//    if (button.tag == 20) {
//        button.tag = 21;
//        [button setBackgroundImage:[UIImage imageNamed:@"SeequButtonCheck.png"] forState:UIControlStateNormal];
//        [arrayIndexPath addObject:indPath];
//    } else {
//        button.tag = 20;
//        [button setBackgroundImage:[UIImage imageNamed:@"SeequButtonUncheck.png"] forState:UIControlStateNormal];
//        [arrayIndexPath removeObject:indPath];
//    }
//    if (arrayIndexPath.count > 0) {
//        self.buttonDelete.enabled = YES;
//    } else {
//        self.buttonDelete.enabled = NO;
//    }
//}
//
- (IBAction)onButtonDelete:(id)sender {
    
    
    for (CDMessage* itemForDel in arrayForDelete) {
        
        [[MessageCoreDataManager sharedManager] deleteMessageWithMessageId: itemForDel.messageID];

    }
    [arrayForDelete removeAllObjects];
    self.buttonDelete.enabled = NO;

//    //    NSMutableArray *marrayMessageID = [[NSMutableArray alloc] init];
//    //
//    //    for (NSIndexPath *indexPath in arrayIndexPath) {
//    //        NSMutableArray *array = [ARRAY objectAtIndex:indexPath.section];
//    //        MessageItem *item = [array objectAtIndex:indexPath.row];
//    //
//    //        [marrayMessageID addObject:item.messageID];
//    //    }
//    
//    for (MessageItem* itemForDel in arrayForDelete) {
//        [[idoubs2AppDelegate sharedInstance].sqliteService deleteMessagesWithSeequID:itemForDel.contactID MessageID:itemForDel.messageID];
//        [arrayAllMessageItem removeObject:itemForDel];
//    }
//    ARRAY = [self SortArrayByDay:arrayAllMessageItem];
//    //    for (NSString *msgID in marrayMessageID) {
//    //        for (NSMutableArray *array in ARRAY) {
//    //            for (MessageItem *item in array) {
//    //                if ([item.messageID isEqualToString:msgID]) {
//    //                    for (MessageItem *msgItem in arrayAllMessageItem) {
//    //                        if ([msgItem.messageID isEqualToString:item.messageID]) {
//    //
//    //                            [[idoubs2AppDelegate sharedInstance].sqliteService deleteMessagesWithSeequID:item.contactID MessageID:item.messageID];
//    //
//    //                            [arrayAllMessageItem removeObject:msgItem];
//    //                            [array removeObject:item];
//    //
//    //                            if (!array.count) {
//    //                                [ARRAY removeObject:array];
//    //                            }
//    //
//    //                            found = YES;
//    //
//    //                            break;
//    //                        }
//    //                    }
//    //
//    //                    if (found) break;
//    //                }
//    //            }
//    //
//    //            if (found) break;
//    //        }
//    //
//    //        found = NO;
//    //    }
//    [arrayForDelete removeAllObjects];
//    if (isShow) {
//        [self.tableMessages reloadData];
//    }
//    [self tableRectToVizibleAnimate:YES];
//    self.buttonDelete.enabled = NO;
//    
//    [arrayIndexPath removeAllObjects];
}

- (NSIndexPath*) CreateIndexPathFromEvent:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableMessages];
    return [self.tableMessages indexPathForRowAtPoint: currentTouchPosition];
}

- (UILabel*) LabelWithText:(NSString*)text {
	UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 210, 0)];
	[lbl setTextAlignment:NSTextAlignmentLeft];
	[lbl setNumberOfLines:0];
	[lbl setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	lbl.text = text;
	UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
	CGSize textSize = CGSizeMake(210, 5000.0f);
    
//	JSC - CGSize size = [text sizeWithFont:font constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:text
     attributes:@
     {
     NSFontAttributeName: font
     }];
    
    CGRect rect = [attributedText boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
	lbl.frame = CGRectMake(50, 0, rect.size.width, rect.size.height);
	[lbl setBackgroundColor:[UIColor clearColor]];
    return lbl;
}

- (void) didClickedOnLink:(NSURLRequest*)request onItem:(MessageItem*)item {
    [self performSelectorOnMainThread:@selector(goToBrowser:) withObject:request waitUntilDone:YES];
}

-(void) removeItemFromImageArray:(NSString*) url {
    if (!imageArray) {
        self.imageArray = [self prepareDataForMessagePreview];
        
    } else {
        for(GalleryCellInfo* gInf in imageArray) {
            if ([gInf.item.url isEqualToString:url]) {
                NSMutableArray* arr = [NSMutableArray arrayWithArray:imageArray];
                [arr removeObject:gInf];
                self.imageArray = arr;
            }
        }
    }
}

-(void) addItemToImageArray:(MessageItem*) item {
    if (!imageArray) {
        self.imageArray = [self prepareDataForMessagePreview];
        
    } else {
        
        NSMutableArray* arr = [NSMutableArray arrayWithArray:imageArray];
        GalleryCellInfo* info = [[GalleryCellInfo alloc] init];
        NSLog(@"item.messageID %@",item.messageID);
        info.item = item;
        [arr addObject:info];
        
        self.imageArray = arr;
    }
    
}

-(BOOL)checkForImageInfoExistance:(CDMessage*) mess {
    for (GalleryCellInfo* inf in self.imageArray) {
        if ([inf.item.messageID isEqualToString:mess.messageID]) {
            return YES;
        }
    }
    return NO;
}

-(void) updateImageArray {
    int sections = fetchedResultsController.sections.count -1;
    if (sections < 0) {
        return;
    }
    id<NSFetchedResultsSectionInfo>sectionInfo=[fetchedResultsController.sections objectAtIndex:sections];
    int rows = sectionInfo.numberOfObjects -1;
    if (rows < 0) {
        return;
    }
    if (!self.imageArray) {
        [self prepareDataForMessagePreview];
    }
    NSMutableArray* array = [[NSMutableArray alloc] initWithArray:self.imageArray];
  
    for (id<NSFetchedResultsSectionInfo>sectionInfo in fetchedResultsController.sections) {
        for (CDMessage* mess in sectionInfo.objects) {
            if ([mess.messageType intValue] ==Message_Type_Image) {
                if ([self checkForImageInfoExistance:mess]) {
                    continue;
                }
                MessageItem* item = [[MessageItem alloc] initWithCDMessage:mess];
                GalleryCellInfo* info = [[GalleryCellInfo alloc] init];
                NSLog(@"item.messageID %@",item.messageID);
                info.item = item;
                [array addObject:info];
            }
            
        }
    }
    self.imageArray = array;
    
}

-(NSArray*) prepareDataForMessagePreview {
    NSMutableArray* array = [[NSMutableArray alloc] init];

    for (id<NSFetchedResultsSectionInfo>sectionInfo in fetchedResultsController.sections) {
        for (CDMessage* mess in sectionInfo.objects) {
            MessageItem* item = [[MessageItem alloc] initWithCDMessage:mess];
            if (item.type ==Message_Type_Image) {
                GalleryCellInfo* info = [[GalleryCellInfo alloc] init];
                NSLog(@"item.messageID %@",item.messageID);
                info.item = item;
                [array addObject:info];
            }

        }
    }

    if (array.count) {
        return array;
    }
    return nil;
//    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date"  ascending:YES];
//    NSArray *sorted_array = [arrayAllMessageItem sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
//    NSMutableArray* array = [[NSMutableArray alloc] init];
//    
//    for (MessageItem*  item in sorted_array) {
//        if (item.type ==Message_Type_Image) {
//            GalleryCellInfo* info = [[GalleryCellInfo alloc] init];
//            NSLog(@"item.messageID %@",item.messageID);
//            info.item = item;
//            [array addObject:info];
//        }
//    }
//    
//    if (array.count) {
//        return array;
//    }
//    return nil;
    
}

-(NSString*) getRelativePath:(NSString*) url {
    NSString* mainPath =@"https://us-east.manta.joyent.com/seequ/stor/";
    NSString * str =[url substringFromIndex:mainPath.length ];
    return str;
}


-(void) createCheckBoxView :(NSString*) checkboxText alert:(UIAlertView*) alert{
    UILabel *alertLabel =(IS_IOS_7)? [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 160, 45)]: [[UILabel alloc] initWithFrame:CGRectMake(70, 120, 160, 50)];
    [alertLabel setFont:[UIFont systemFontOfSize:12]];
    alertLabel.backgroundColor = [UIColor clearColor];
    alertLabel.text = checkboxText;
    if (!IS_IOS_7) {
        alertLabel.textColor = [UIColor whiteColor];
    }
    alertLabel.numberOfLines = 0;
    ///@todo  levon  Toros need  to  update  alertLabel  frame  depend  on it's  text
    [alertLabel sizeToFit];/// ???
    
    
    
    alertCheckboxButton = [UIButton buttonWithType:UIButtonTypeCustom];
    alertCheckboxButton.frame = (IS_IOS_7)?CGRectMake(0, 0, 25, 25):CGRectMake(25, 120, 25, 25);
    UIImage * alertButtonImageChecked= [UIImage imageNamed:@"SeequButtonCheck"];
    UIImage *alertButtonImageNormal = [UIImage imageNamed:@"SeequButtonUncheck"];
    [alertCheckboxButton setImage:alertButtonImageNormal forState:UIControlStateNormal];
    [alertCheckboxButton setImage:alertButtonImageChecked forState:UIControlStateSelected];
    [alertCheckboxButton addTarget:self action:@selector(alertCheckboxButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    // alertCheckboxButton.contentMode = UIViewContentModeScaleToFill;
    if (IS_IOS_7) {
        UIView * accessoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 60)];
        [accessoryView addSubview:alertLabel];
        [accessoryView addSubview:alertCheckboxButton];
        
        [alert setValue:accessoryView forKey:@"accessoryView"];
    } else {
        [alert addSubview:alertLabel];
        [alert addSubview:alertCheckboxButton];
        
    }
}


- (void) didSelectVideo:(CDMessage *)message  {
    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]){
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"" message:@"Unfortunately it's impossible to watch videos during video call" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        
        alert.delegate = self;
        alert.tag = 5151;
        [alert show];
        [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:2.5];
        return;
        
    }
 
    SeequMPViewController*  mpConntroller = [[SeequMPViewController alloc] init];
    mpConntroller.delegate =self;
    MessageItem* item = [[MessageItem alloc] initWithCDMessage:message];
    mpConntroller.messageItem = item;
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    BOOL flag = YES;
     [userDef stringForKey:DOUBLE_TAKE_PERMISSION];
    //    if (item.type ==Message_Type_Double_Take &&!item.responseDelivered && !item.me) {
      dispatch_async(dispatch_get_main_queue(), ^{
        UInt32 doChangeDefaultRoute = 1;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    });
    
    if (item.type == Message_Type_Double_Take &&!item.responseDelivered && !item.me) {
        //     if (!value) {
        UserInfoCoreData *userInfo=[[ContactStorage sharedInstance] getUserInfoBySeequId:self.messageOwner.seequId];
        BOOL isAlwaysDTake =[userInfo.needToDoubleTake boolValue];
        
        if(!isAlwaysDTake){
            NSString*  appendTxt = IS_IOS_7?@"":@"\n\n\n\n";
            NSString*  str = [NSString stringWithFormat:@"To view this video user has requested a recording of your reaction.%@",appendTxt];
            UIAlertView* alert  = [[UIAlertView alloc] initWithTitle:@"Record Your DoubleTake" message:str delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.delegate  =  self;
            [self createCheckBoxView:[NSString stringWithFormat:@"always send doubleTakes to %@", stringNavigationTitle] alert:alert];
            alert.tag = DOUBLE_TAKE_PERMISSIONTAG;
            self.videoMessageItem =item;
            isAlwaysDoubleTake =  NO;
            
            [alert show];
        } else {
            NSString* folder = nil;
            if ([item.coreMessage.messageType integerValue] == Message_Type_Double_Take) {
                folder = [Common makeDTFolder];
            } else {
                folder = [Common makeFolderIfNotExist:item.contactID];
            }

            mpConntroller.isResponse =NO;
            NSString *videoPath  = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_video.mp4",item.messageID]];
            BOOL flag = [[NSFileManager defaultManager] fileExistsAtPath:videoPath];
            if (flag) {
                mpConntroller.url = [NSURL fileURLWithPath:videoPath];
            }  else {
                mpConntroller.url = [NSURL URLWithString:[Common getVideoDirectLink:[self getRelativePath: item.url]]];
            }
            [self presentViewController:mpConntroller animated:YES completion:^{
                
            }];
            
            
        }
        
    } else {
        if ([item.coreMessage.messageType intValue] == Message_Type_Video_Response) {
            SeequDTViewController* vc = [[SeequDTViewController alloc] init];
            vc.message = item.coreMessage;
            [self presentViewController:vc animated:YES completion:^{
                
            }];

        } else {
//        if (video) {
            mpConntroller.isResponse = (item.type == Message_Type_Video ||item.me||item.responseDelivered||flag);
            NSString* folder = nil;
            if ([item.coreMessage.messageType integerValue] == Message_Type_Double_Take) {
                folder = [Common makeDTFolder];
            } else {
                 folder = [Common makeFolderIfNotExist:item.contactID];
            }
            
            NSString *videoPath  = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_video.mp4",item.messageID]];
            BOOL flag = [[NSFileManager defaultManager] fileExistsAtPath:videoPath];
            if (flag) {
                mpConntroller.url = [NSURL fileURLWithPath:videoPath];
            }  else {
                mpConntroller.url = [NSURL URLWithString:[Common getVideoDirectLink:[self getRelativePath: item.url]]];
            }
            [self presentViewController:mpConntroller animated:YES completion:^{
                
            }];
        }

//        } else {
//            UIAlertView* uu = [[UIAlertView alloc] initWithTitle:@"ddd" message:@"aaa" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [uu show];
//        }
    }
    
}


- (void) alertCheckboxButtonClicked{
    UINavigationController *nav = [[idoubs2AppDelegate sharedInstance].tabBarController.viewControllers objectAtIndex:0];
    SeequContactsViewController *controller = [nav.viewControllers objectAtIndex:0];
     [controller CheckObjectInArrayWithPT:self.stringUserId];
    alertCheckboxButton.selected = !alertCheckboxButton.selected;
    //    if (alertCheckboxButton.selected == YES){
    //        [alertCheckboxButton setBackgroundImage:[UIImage imageNamed:@"SeequButtonCheck"] forState:UIControlStateNormal];
    //    }
    //    else{
    //         [alertCheckboxButton setBackgroundImage:[UIImage imageNamed:@"SeequButtonUncheck"] forState:UIControlStateSelected];
    //    }
    isAlwaysDoubleTake  = (alertCheckboxButton.selected == YES);
    
    
}

-(void)dismissAlertView:(UIAlertView*)alertView {
    [alertView dismissWithClickedButtonIndex:0 animated:NO];
    
    
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    
    
    if(!IS_IOS_7 && alertView.tag == 5151){
        [alertView setFrame:CGRectMake(10, 100, 300, 100)];
    }
}
#pragma mark UIAlertView delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    BOOL flag = NO;

    if (alertView.tag == NO_INTERNET_CONNECTION_TAG) {
        switch (buttonIndex ) {
            case 0:{
                [self.viewSendMessage removeAttachment:YES];
                self.viewSendMessage.textview.text = @"";
            }
                
                break;
                
            default:{
                [self SendTextMessage:self.textFieldSendMessage.text];
                [self onTextFieldChange:nil];
                if(videoForSend || imageForSend){
                    [self.viewSendMessage pressDeleteButton];
                }

            }
                break;
        }
        
    } else {
        switch (buttonIndex) {
            case 0:
                //            NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                //            [userDef setObject:@"NO" forKey:DOUBLE_TAKE_PERMISSION];
                self.videoMessageItem.responseDelivered = YES;
//   JSC             flag = YES;
                [self SendTextMessage:[NSString stringWithFormat:@"%@%@",DOUBLE_TAKE_REJECT,self.videoMessageItem.messageID]];
                [[MessageCoreDataManager sharedManager] deleteMessageWithMessageId:self.videoMessageItem.messageID];
                return;
                
//    JSC            break;
            case 1:
                //            NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                //            [userDef setObject:@"YES" forKey:DOUBLE_TAKE_PERMISSION];
                flag  = NO;
                if (isAlwaysDoubleTake == YES){
                    [alertCheckboxButton setBackgroundImage:[UIImage imageNamed:@"SeequButtonUncheck"] forState:UIControlStateSelected];
                    //alertCheckboxButton.selected = NO;
        
                    
                    [[ContactStorage sharedInstance] setNeedToDoubleTake:self.messageOwner.seequId needToDoubleTake:YES];
                    
                }
                
            default:
                break;
        }
        SeequMPViewController*  mpConntroller = [[SeequMPViewController alloc] init];
        mpConntroller.delegate =self;
        mpConntroller.messageItem = self.videoMessageItem;
        
        mpConntroller.isResponse = flag;
        mpConntroller.url = [NSURL URLWithString:[Common getVideoDirectLink:[self getRelativePath: self.videoMessageItem.url]]];
        [self presentViewController:mpConntroller animated:YES completion:^{
            
        }];
    }

}



#pragma mark  CaptureSessionManagerDelegate
-(void) didFinishWriteToFile:(NSURL *)url item:(MessageItem *)item closeVideo:(BOOL)flag {
    if (flag) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    videoUrl = url;
    self.videoForSend = [NSData dataWithContentsOfURL:url];
    isVideoResponse = YES;
    self.dt_url = item.url;

    [self onButtonSendMessage:nil];
    ///@todo here  update  status of responseDelivered;
    item.responseDelivered = YES;
}

-(int) getCurrentIndex:(CDMessage *)item {
    for (int i = 0; i < self.imageArray.count; ++i) {
        GalleryCellInfo* info = [imageArray objectAtIndex:i];
        if ([info.item.url isEqualToString:item.url] ) {
            return i;
        }
    }
    return 0;
}
- (void) didSelectImage:(CDMessage *)item {
    if (!imageArray) {
        self.imageArray = [self prepareDataForMessagePreview];
    }
    [self.viewSendMessage.textview resignFirstResponder];
    GalleryViewController*  vc = [GalleryViewController alloc];
    vc.assets = self.imageArray;
    vc.userName  = self.stringNavigationTitle;
    vc.selectedIndex = [self getCurrentIndex:item];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    UINavigationController*  nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nc animated:YES completion:nil];
    
}
-(void) didselectItem:(CDMessage *)item select:(BOOL)flag{
    if (flag) {
        [arrayForDelete addObject:item];
    } else {
        [arrayForDelete removeObject:item];
    }
    if (arrayForDelete.count>0) {
        self.buttonDelete.enabled = YES;
    } else {
        self.buttonDelete.enabled = NO;
    }
    
}

- (void) didSendFile:(MessageItem *)item {
    [self performSelectorOnMainThread:@selector(sendMessageOnMainThreadWithMessageItem:) withObject:item waitUntilDone:YES];
}

- (void) didLoadFile:(MessageItem*)item {
    [self.tableMessages reloadData];
}

- (void) sendMessageOnMainThreadWithMessageItem:(MessageItem*)item {
    NSString *message = [NSString stringWithFormat:@"*#IMAGE FILE#*%@*#IMAGE FILE#*%@", item.url, item.stringMessageText];
    
    [[idoubs2AppDelegate getChatManager] SendTextMessage:message to:self.stringUserId MessageID:item.messageID AddToResendList:YES];
    [self.tableMessages reloadData];
}

- (void)goToBrowser:(NSURLRequest *)request{
    [idoubs2AppDelegate sharedInstance].urlReq = request;
    self.tabBarController.selectedIndex = 2;
    
    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
        NSString *currentURL = request.URL.absoluteString;
        if (currentURL && [currentURL isKindOfClass:[NSString class]] && currentURL.length) {
            [[idoubs2AppDelegate getChatManager] SendLinkWithLink:currentURL to:[idoubs2AppDelegate sharedInstance].videoService.contactObject.SeequID];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    isInRotate = YES;
    //    CGFloat kHeight = keyboardHeight > self.tabBarController.tabBar.frame.size.height ? keyboardHeight - self.tabBarController.tabBar.frame.size.height:0;
    //
    //    CGFloat delta = ((keyboardHeight< self.tabBarController.tabBar.frame.size.height) && UIInterfaceOrientationIsLandscape(toInterfaceOrientation))?0:self.tabBarController.tabBar.frame.size.height;
    //
    //    CGFloat height = [self.viewSendMessage getControlTextHeight:UIInterfaceOrientationIsLandscape(toInterfaceOrientation)?568:320];
    //    CGFloat mHeight = [self calculateMessageFieldMaxHeight:toInterfaceOrientation];
    //    height = mHeight > height ? height:mHeight ;
    //    self.viewSendMessage.frame =CGRectMake(self.view.frame.origin.x ,
    //                                           self.view.frame.size.height - height -kHeight- delta,
    //                                           self.view.frame.size.width,height);
    
}
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    isInRotate = NO;
    
    
}




- (void) UpdateTableFrameForPortraitAndScrallTable:(BOOL)scrall {
    if (![[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
        videoViewState = VideoViewState_HIDE;
    }
    
    CGRect frame = self.tableMessages.frame;
    
    int statusBarHeight = 0;
    
    if (self.view.frame.size.height == 386 || self.view.frame.size.height == 387 || self.view.frame.size.height == 474 || self.view.frame.size.height == 475) {
        statusBarHeight = 20;
    }
    
    int originY = 0;
    
    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
        
        if ([idoubs2AppDelegate sharedInstance].videoService.showVideoView.videoViewState == VideoViewState_TAB) {
            originY = 96;
        } else {
            if ([idoubs2AppDelegate sharedInstance].videoService.showVideoView.videoViewState == VideoViewState_TAB_MENU) {
                originY = 188;
            } else {
                if ([idoubs2AppDelegate sharedInstance].videoService.showVideoView.videoViewState != VideoViewState_HIDE &&
                    [idoubs2AppDelegate sharedInstance].videoService.showVideoView.videoViewState != VideoViewState_PREVIEW) {
                    [self.textFieldSendMessage resignFirstResponder];
                }
            }
        }
    }
    
    frame.origin.y = originY + statusBarHeight;
    frame.origin.x = 0;
    frame.size.width = 320;
    if (!isForEditing) {
        frame.size.height = self.viewSendMessage.frame.origin.y - frame.origin.y;
    } else {
        frame.size.height = self.viewDeleteMessage.frame.origin.y - frame.origin.y;
    }
    
    self.tableMessages.frame = frame;
    
    if (scrall) {
        [self tableRectToVizibleAnimate:NO];
    }
    [self UpdateViewCallMenuFrame];
}

- (void) onVideoViewChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    
    videoViewState = (VideoViewState)[eargs intValue];
    if (self.isViewLoaded && self.view.window) {
        [self setVideoViewState:videoViewState Animated:YES];
        [self UpdateCallButtons];
        [self.view setNeedsLayout];
    }
    
    
}

- (void) setVideoViewState:(int)state Animated:(BOOL)animated {
    if (!_needToRefresh) {
        _needToRefresh = YES;
        return;
    }
}

- (void) updateVideoViewState:(int)state Animated:(BOOL)animated {
    //   [self UpdateInterfaceOrientation:self.interfaceOrientation];
    
    //    [self UpdateViewDeleteMessagesHeader:self.interfaceOrientation];
    
    //    for (MessageItem *item in arrayAllMessageItem) {
    //        [item setOrientation:self.interfaceOrientation];
    //    }
    
    if (isShow) {
        [self.tableMessages reloadData];
    }
}

- (void) onCallStateChange:(NSNotification*)notification {
    tabBar_Type type = (tabBar_Type)[[notification object] integerValue];
    
    [self callStateWithType:(int)type];
}

-(void) onNewMessage:(NSNotification*) notification {
    [defaultBadgView IncrementBagdValue];
}

//- (void) onMessage:(NSNotification*)notification {
//    NSDictionary *dict = (NSDictionary*)[notification object];
//    
//    int type = [[dict objectForKey:@"type"] integerValue];
//    TBIMessageDetailsObject *obj = [dict objectForKey:@"obj"];
//    
//    if (!obj || ![obj isKindOfClass:[TBIMessageDetailsObject class]]) {
//        return;
//    } else {
//        BOOL flag = ![obj.seequID isEqualToString: self.groupInfo.groupID];
//        if (![obj.seequID isEqualToString:self.stringUserId] &&!obj.delivered &&flag) {
//            [defaultBadgView IncrementBagdValue];
//            
//            //            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
//            //                [self.viewNavigationBar addSubview:defaultBadgView];
//            //                defaultBadgView.center = CGPointMake(49, 13);
//            //            } else {
//            //                [backBarButton.customView addSubview:defaultBadgView];
//            //                defaultBadgView.center = CGPointMake(40, 7);
//            //            }
//            
//            return;
//        }
//    }
//    
//    switch (type) {
//        case TBI_MESSAGE_EVENT_ITEM_ADDED: {
//            [self TBI_MESSAGE_EVENT_ITEM_ADDED:obj];
//        }
//            break;
//        case TBI_MESSAGE_EVENT_ITEM_DELETED: {
//            [self TBI_MESSAGE_EVENT_ITEM_DELETED:obj];
//        }
//            break;
//        case TBI_MESSAGE_EVENT_ITEM_UPDATE: {
//            [self TBI_MESSAGE_EVENT_ITEM_UPDATE:obj];
//        }
//            break;
//        case TBI_MESSAGE_EVENT_RESET: {
//            [self TBI_MESSAGE_EVENT_RESET];
//        }
//            break;
//            
//        default:
//            break;
//    }
//}


//- (void) TBI_MESSAGE_EVENT_ITEM_ADDED:(TBIMessageDetailsObject*)obj {
//    MessageItem *item;
//    if (obj.from) {
//        if (obj.type == Message_Type_Image) {
//            item = [[MessageItem alloc] initWithMessageDetailsObject:obj
//                                                         Orientation:self.interfaceOrientation
//                                                               Image:imageForSend save:YES];
//            imageForSend = nil;
//        } else if(obj.type == Message_Type_Video ||obj.type == Message_Type_Video_Response||obj.type == Message_Type_Double_Take) {
//            //          NSAssert(obj.type == Message_Type_Video||obj.type == Message_Type_Video_Response, @"Message type  must be Message_Type_Video");
//            item = [[MessageItem alloc] initWithMessageDetailsObject:obj
//                                                         Orientation:self.interfaceOrientation
//                                                               video:videoForSend save:YES];
//            self.videoForSend = nil;
//        } else {
//            item = [[MessageItem alloc] initWithMessageDetailsObject:obj
//                                                         Orientation:self.interfaceOrientation
//                                                               Image:nil save:NO];
//        }
//        
//        
//    } else {
//        if(obj.type == Message_Type_Video ||obj.type == Message_Type_Video_Response||obj.type == Message_Type_Double_Take){
//            item = [[MessageItem alloc] initWithMessageDetailsObject:obj
//                                                         Orientation:self.interfaceOrientation
//                                                               video:nil save:NO];
//        } else {
//            item = [[MessageItem alloc] initWithMessageDetailsObject:obj
//                                                         Orientation:self.interfaceOrientation
//                                                               Image:nil save:NO];
//        }
//    }
//    
//    item.delegate = self;
//    NSLog(@"arrayAllMessageItem count %d", arrayAllMessageItem.count);
//
//    if ([[idoubs2AppDelegate sharedInstance].sqliteService checkForMessageIDExisting:obj.messageID]) {
//        [arrayAllMessageItem addObject:item];
//        NSLog(@"arrayAllMessageItem1 count %d", arrayAllMessageItem.count);
//        
//        ARRAY = [self SortArrayByDay:arrayAllMessageItem];
//        [self addItemToImageArray:item];
//        //    if (isShow) {
//        [self.tableMessages reloadData];
//        //    }
//        [self tableRectToVizibleAnimate:YES];
//        
//        
//        if (!isShow && !obj.from && (obj.senderID && obj.senderID.length >0)) {
//            [Common addBadgeOnCurrentUser:obj.seequID];
//            
//            [Common AddMissedWithSeequID:obj.seequID Type:2];
//        }
//
//    }
//}

//- (void) TBI_MESSAGE_EVENT_ITEM_DELETED:(TBIMessageDetailsObject*)obj {
//    if (obj.type == Message_Type_Image) {
//        [self removeItemFromImageArray:obj.url];
//        
//    }
//}
//
//- (void) TBI_MESSAGE_EVENT_ITEM_UPDATE:(TBIMessageDetailsObject*)obj {
//    BOOL found = NO;
//    for (NSArray *array in ARRAY) {
//        for (MessageItem *item in array) {
//            if ([item.messageID isEqualToString:obj.messageID]) {
//                item.delivered = YES;
//                found = YES;
//                
//                break;
//            }
//        }
//        
//        if (found) {
//            [self.tableMessages reloadData];
//            break;
//        }
//    }
//}

- (void) TBI_MESSAGE_EVENT_RESET {
    
}

- (void) onMessageSendedFromActivity:(NSNotification*)notification {
    //    NSDictionary *dict = (NSDictionary*)[notification object];
    //
    //    NSString *seequID = [dict objectForKey:@"SeequID"];
    //    if ([self.stringUserId isEqualToString:seequID]) {
    //        NSDictionary *dictHistory = [dict objectForKey:@"dictHistory"];
    //        NSString *path = [Common createEditableCopyOfFileWithFileName:@"xmpphistory.plist"];
    //        NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    //        NSMutableDictionary *m_dictionary;
    //
    //        if (dictionary) {
    //            m_dictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    //        } else {
    //            m_dictionary = [[NSMutableDictionary alloc] init];
    //        }
    //
    //        arrayCurrentUserAllHistory = [m_dictionary objectForKey:self.stringUserId];
    //
    //        if (!arrayCurrentUserAllHistory) {
    //            arrayCurrentUserAllHistory = [[NSMutableArray alloc] init];
    //        }
    //
    //        MessageItem *item = [[MessageItem alloc] initWithDictionary:dictHistory Orientation:self.interfaceOrientation];
    //        item.delegate = self;
    //        [arrayAllMessageItem addObject:item];
    //
    //        ARRAY = [self SortArrayByDay:arrayAllMessageItem];
    //
    //        if (isShow) {
    //            [self.tableMessages reloadData];
    //        }
    //
    //        [self tableRectToVizibleAnimate:YES];
    //    }
}

- (void) callStateWithType:(int)type {
    switch (type) {
        case tabBar_Type_Default: {
        }
            break;
        case tabBar_Type_Landscape: {
        }
            break;
        case tabBar_Type_Audio:
        case tabBar_Type_Audio_Selected: {
            [self.buttonVideo setBackgroundImage:[UIImage imageNamed:@"seequButtonAudioOnMessage.png"] forState:UIControlStateNormal];
        }
            break;
        case tabBar_Type_Video:
        case tabBar_Type_Video_Selected: {
            [self.buttonVideo setBackgroundImage:[UIImage imageNamed:@"seequButtonVideoOnMessage.png"] forState:UIControlStateNormal];
        }
            break;
        case tabBar_Type_OnHold: {
            [self.buttonVideo setBackgroundImage:[UIImage imageNamed:@"tabOnHold.png"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (void) UpdateViewDeleteMessagesHeader:(UIInterfaceOrientation)interfaceOrientation {
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        if (isForEditing) {
            self.viewDeleteMessage.frame = CGRectMake(0, self.view.frame.size.height - 42, [self getWindowSize].width, 50);
            self.viewDeleteMessage.hidden=NO;
        } else {
            self.viewDeleteMessage.frame = CGRectMake(0, self.view.frame.size.height, [self getWindowSize].width, 50);
            self.viewDeleteMessage.hidden=YES;
        }
    } else {
        if (isForEditing) {
            CGFloat diff=IS_IOS_7?46:0;
            self.viewDeleteMessage.frame = CGRectMake(0, self.view.frame.size.height - 48-diff,[self getWindowSize].width, 50);
            self.viewDeleteMessage.hidden=NO;
        } else {
            self.viewDeleteMessage.frame = CGRectMake(0, self.view.frame.size.height, [self getWindowSize].width, 50);
            self.viewDeleteMessage.hidden=YES;
        }
    }
}

- (UIButton*) CreateUserImageButton {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(7, 5, 36, 36)];
    button.tag = 11;
    
    return button;
}

- (void) onButtonUserImage:(id)sender {
    if (!UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return;
    }
    
    UINavigationController *nav = [[idoubs2AppDelegate sharedInstance].tabBarController.viewControllers objectAtIndex:0];
    SeequContactsViewController *controller = [nav.viewControllers objectAtIndex:0];
    ContactObject *obj = [controller CheckObjectInArrayWithPT:self.stringUserId];
    if (obj) {
        SeequContactProfileViewController *profileViewController = [[SeequContactProfileViewController alloc] initWithNibName:@"SeequContactProfileViewController" bundle:nil];
        profileViewController.contactObj = obj;
        profileViewController.videoViewState = videoViewState;
        profileViewController.accessToConnections = YES;
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

- (void) UpdateViewCallMenuFrame {
    int viewCallMenu_Y = 0;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        if (self.viewCallMenu.tag == 0) {
            viewCallMenu_Y = -16;
        }
    } else {
        if (self.viewCallMenu.tag == 0) {
            viewCallMenu_Y = -60;
        }
    }
    
    self.viewCallMenu.frame = CGRectMake(self.navigationController.navigationBar.frame.origin.x, viewCallMenu_Y, self.navigationController.navigationBar.frame.size.width, VIEW_CALL_MENU_HEIGHT);
    NSLog(@"______________ %@ __________________",NSStringFromCGRect(self.viewCallMenu.frame));
    self.buttonVoiceCall.frame = CGRectMake(0, 0, self.viewCallMenu.frame.size.width/2-1, self.buttonVoiceCall.frame.size.height);
    self.buttonVideoCall.frame = CGRectMake(self.viewCallMenu.frame.size.width/2, 0, self.viewCallMenu.frame.size.width/2, self.buttonVideoCall.frame.size.height);
}

- (void) UpdateCallButtons {
    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
        self.buttonVoiceCall.enabled = NO;
        self.buttonVideoCall.enabled = NO;
    } else {
        self.buttonVoiceCall.enabled = YES;
        self.buttonVideoCall.enabled = YES;
    }
}

- (void) CleareAllMessages {
//    [arrayCurrentUserAllHistory removeAllObjects];
}



+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLabelNavName:nil];
    [self setViewDeleteMessage:nil];
    [self setButtonDelete:nil];
    [self setButtonEdit:nil];
    [self setButtonVideo:nil];
    [self setImageViewHeaderBG:nil];
    [self setButtonSendMessage:nil];
    [self setViewCallMenu:nil];
    [self setButtonVoiceCall:nil];
    [self setButtonVideoCall:nil];
    [self setButtonBack:nil];
    [self setButtonCamera:nil];
    [self.view removeKeyboardControl];
    fetchedResultsController.delegate = nil;
    fetchedResultsController = nil;
    
    [super viewDidUnload];
}

-(void) removeFromImageArray:(CDMessage*) mess {
     NSMutableArray* array = [[NSMutableArray alloc] initWithArray:self.imageArray];
    for (GalleryCellInfo* inf in array) {
        if ([inf.item.messageID isEqualToString:mess.messageID]) {
            [array removeObject:inf];
            self.imageArray = array;
            return;
        }
    }
  
}

- (void) dealloc {
    NSLog(@"dealloc SeequSendMessageViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    for (MessageItem *item in arrayAllMessageItem) {
//        item.delegate = nil;
//    }
//    
    [[idoubs2AppDelegate getChatManager] removeDelegate:self];
}
-(BOOL) touchTextview:(UILongPressGestureRecognizer *)recognizer{
    if ([self.textFieldSendMessage isFirstResponder]) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.3];
        [self.textFieldSendMessage resignFirstResponder];
        [UIView commitAnimations];
        return NO;
    }
    return YES;
}
#pragma UIVideoEditorControllerDelegate
-(void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath{
    NSURL*url=[[NSURL alloc] initFileURLWithPath:editedVideoPath];
    videoUrl=url;
    self.videoForSend = [NSData dataWithContentsOfURL:url];
    UIImage *image=[Common getVideoThumbnail:videoUrl];
    [self.viewSendMessage setImage:image forVideo:YES];
    [editor dismissViewControllerAnimated:YES completion:nil];
}
-(void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error{
    NSLog(@"fail edite video %@ ",error);
}
-(void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor{
    [editor dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark NSFetchedResultsController Delegate
- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSManagedObjectContext* mContext = [CoreDataManager managedObjectContext];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"CDMessage"
												  inManagedObjectContext:mContext];
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        
        NSArray *sortDescriptors = @[sd1];
        
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"senderContact.seequId=%@  && isMediaDownloaded = YES",messageOwner.seequId];
        [fetchRequest setPredicate:predicate];

		[fetchRequest setFetchBatchSize:10];
        
		NSError *error = nil;
        [NSFetchedResultsController deleteCacheWithName:@"SendMessageView"];
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:mContext
                                                                         sectionNameKeyPath:@"date.dateGroupBydays"
                                                                                  cacheName:@"SendMessageView"];
		[fetchedResultsController setDelegate:self];
        
		
		if (![fetchedResultsController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
	}
	
	return fetchedResultsController;
}
- (void) setFetchedResultsController:(NSFetchedResultsController *)fetched {
    fetchedResultsController = fetched;
    fetchedResultsController.delegate  = self;
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableMessages insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableMessages deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableMessages;
    switch(type) {
        case NSFetchedResultsChangeInsert:{
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            self.currentIndexPath = newIndexPath;
            isInserted = YES;
            [self updateImageArray];
        }
            break;
            
        case NSFetchedResultsChangeDelete:{
            CDMessage* mess = anObject;
            if ([mess.messageType intValue] == Message_Type_Image) {
                [self removeFromImageArray:mess];
            }
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

            break;
    }
}

-(void) scrolltoIndexPath:(NSIndexPath*) indexPath {
    [self.tableMessages scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableMessages endUpdates];
    if (isInserted) {
        [self performSelector:@selector(scrolltoIndexPath:) withObject:self.currentIndexPath afterDelay:0.3];
        isInserted = NO;
    }
  

}

-(void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableMessages beginUpdates];
}


@end
