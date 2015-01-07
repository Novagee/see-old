//
//  SeequWebViewHeader.h
//  ProTime
//
//  Created by Norayr on 03/21/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequWebView.h"

typedef enum SeequWebViewHeaderState {
	SeequWebViewHeaderState_None,
    SeequWebViewHeaderState_Portrait,
    SeequWebViewHeaderState_Portrait_Link_Edit,
    SeequWebViewHeaderState_Portrait_Search,
    SeequWebViewHeaderState_Landscape,
    SeequWebViewHeaderState_Landscape_Link_Edit,
    SeequWebViewHeaderState_Landscape_Search,
}
SeequWebViewHeaderState;

typedef enum WebViewHeaderCallState {
	WebViewHeaderCallState_None,
    WebViewHeaderCallState_Audio,
    WebViewHeaderCallState_Video,
    WebViewHeaderCallState_CallMenu,
}
WebViewHeaderCallState;

typedef enum RightViewState {
	RightViewState_None,
    RightViewState_Stop,
    RightViewState_Reload,
    RightViewState_Clear
}
RightViewState;


@protocol SeequWebViewHeaderDelegate;

@interface SeequWebViewHeader : UIView <UITextFieldDelegate> {
    id<SeequWebViewHeaderDelegate> __unsafe_unretained _delegate;

    UIInterfaceOrientation interfaceOrientation;
    SeequWebViewHeaderState headerState;
    WebViewHeaderCallState callState;
    RightViewState rightViewState;
    NSString *strHttp;
    BOOL clearButtonPressed;
    
    NSString *lastSearchString;
    NSString* setedUrl;
    NSString *strSlash;
}

@property (nonatomic, assign) id<SeequWebViewHeaderDelegate> headerDelegate;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewWebHeaderUrl1;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewWebHeaderUrl2;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewWebHeaderUrl3;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewWebHeaderSearch1;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewWebHeaderSearch2;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewWebHeaderSearch3;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewWebHeaderBlackLine;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewProgress;

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

@property (strong, nonatomic) IBOutlet UITextField *textFieldUrl;
@property (strong, nonatomic) IBOutlet UITextField *textFieldSearch;

@property (strong, nonatomic) IBOutlet UIButton *buttonCancel;
@property (strong, nonatomic) IBOutlet UIButton *buttonVideo;
@property(nonatomic) SeequWebView *webView;


- (IBAction)onButtonCancel:(id)sender;
- (IBAction)onButtonVideo:(id)sender;
- (IBAction)onButtonStopReload:(id)sender;

- (void) onCallStateChange:(NSNotification*)notification;

- (void) setHeaderState:(SeequWebViewHeaderState)state Animated:(BOOL)animated;
- (void) ChangeStateToDefaultAnimated:(BOOL)animated;
- (void) beginSearchAnimationFinished;
- (void) endSearchAnimationFinished;
- (void) setTitle:(NSString*)title;
- (NSString*) getTitle;
- (void) setURL:(NSString*)url;
- (NSString*) getURL;
- (void) setOrientation:(UIInterfaceOrientation)interfaceOrientation_;
- (void) setCallState:(WebViewHeaderCallState)callState_;
- (void) setRightViewState:(RightViewState)rightViewState;
- (NSString*)strHttp;
- (NSString*)setedUrl;
- (NSString*)strSlash;
@end

@protocol SeequWebViewHeaderDelegate <NSObject>

@optional

- (void) didBeginEditingURL:(SeequWebViewHeader*)webHeader;
- (void) didEndEditingURL:(SeequWebViewHeader*)webHeader;
- (void) didBeginEditingSearch:(SeequWebViewHeader*)webHeader;
- (void) didEndEditingSearch:(SeequWebViewHeader*)webHeader;

- (void) didEnterGo:(SeequWebViewHeader*)webHeader withUrl:(NSString*)url;
- (void) didEnterSearch:(SeequWebViewHeader*)webHeader withText:(NSString*)text;
- (void) didChangeSearchText:(SeequWebViewHeader*)webHeader Text:(NSString*)text;
- (void) didChangeUrlText:(SeequWebViewHeader*)webHeader Text:(NSString*)text;
- (void) didEndBeginSearchAnimation:(SeequWebViewHeader*)webHeader;
- (void) didEndEndSearchAnimation:(SeequWebViewHeader*)webHeader;

- (void) didClickVideo:(SeequWebViewHeader*)webHeader;
- (void) didClickCancel:(SeequWebViewHeader*)webHeader;

- (void) didStopLoading:(SeequWebViewHeader*)webHeader State:(RightViewState)state;

@end