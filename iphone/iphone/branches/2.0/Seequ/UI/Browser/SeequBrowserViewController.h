//
//  SeequBrowserViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/19/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequWebView.h"
#import "SeequBookmarksViewController.h"
#import "SeequWebViewHeader.h"
#import "SearchSuggestionTableView.h"
#import "PredictiveURLsTableView.h"
#import "BookmarkUIActivity.h"
#import "NJKWebViewProgressView.h"
#import "seequUIActivityItemProvider.h"

typedef void (^NJKWebViewProgressBlock)(float progress);
@interface SeequBrowserViewController : UIViewController <UIScrollViewDelegate,NSURLConnectionDelegate,UIWebViewDelegate, SeequWebViewDelegate, SeequBookmarksDelegate, SeequWebViewHeaderDelegate, SuggestionTableViewDelegate, PredictiveURLsTableViewDelegate, BookmarkUIActivityDelegate> {
    UIView *viewTopBar;
    UIImageView *imageViewNavBG;
    UIImageView *imageViewSearchBG;
    UIImageView *imageViewLockIcon;
    SeequWebView *webView;
    SearchSuggestionTableView *suggestionTableView;
    PredictiveURLsTableView *predictiveURLsTableView;
    UIButton *buttonBack;
    UIButton *buttonForward;
    UIButton *buttonAction;
    UIButton *buttonBookMark;
    UIButton *buttonPageNumbers;
    UILabel *lblPageNumbers;
    UILabel *lblPageTitle;
    NSString *strHttp;
    NSMutableArray *arrayWebViews;
    NSMutableArray *arrayWebDict;
    BOOL isShow;
    BOOL isGoPressed;
    BOOL isClickOnPageControll;
    BOOL isLinkFromSession;
    BOOL isLoading;
    NSString *urlForReload;
    UIView *viewSuper;
    NSInteger ProgressSum;
    
    NSUInteger _loadingCount;
    NSUInteger _maxLoadCount;
    NSURL *_currentURL;
    BOOL _interactive;
    NJKWebViewProgressView *_progressView;
    
    int videoViewState;
   
}


@property (nonatomic, strong) IBOutlet UIView *viewTopBar;
@property (strong, nonatomic) IBOutlet SeequWebViewHeader *webViewHeader;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewNavBG;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewSearchBG;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewLockIcon;
@property (nonatomic, strong) SeequWebView *webView;
@property (nonatomic, strong) IBOutlet UIButton *buttonBack;
@property (nonatomic, strong) IBOutlet UIButton *buttonForward;
@property (nonatomic, strong) IBOutlet UIButton *buttonAction;
@property (nonatomic, strong) IBOutlet UIButton *buttonBookMark;
@property (nonatomic, strong) IBOutlet UIButton *buttonPageNumbers;
@property (nonatomic, strong) IBOutlet UILabel *lblPageNumbers;
@property (nonatomic, strong) IBOutlet UILabel *lblPageTitle;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonDone;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonNewPage;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelPageLinkEditMod;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelPageNameEditMod;
@property (unsafe_unretained, nonatomic) IBOutlet UIPageControl *pageControl;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonVideo;
@property (nonatomic, assign) BOOL isInSession;
@property (nonatomic, readonly) float progress;
@property (nonatomic, copy) NJKWebViewProgressBlock progressBlock;
@property (nonatomic,assign) BOOL isInLoading;
@property (nonatomic,assign) BOOL IsFinishedOrFaild;
@property (nonatomic,assign) BOOL isGoBackOrForwardPressed;


- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (IBAction)onButtonBack:(id)sender;
- (IBAction)onButtonForward:(id)sender;
- (IBAction)onButtonAction:(id)sender;
- (IBAction)onButtonBookMark:(id)sender;
- (IBAction)onButtonPageNumbers:(id)sender;
- (IBAction)onButtonDone:(id)sender;
- (IBAction)onButtonNewPage:(id)sender;
- (IBAction)onButtonVideo:(id)sender;
- (IBAction)pageControlClick:(id)sender;

- (void) onVideoViewChange:(NSNotification*)notification;
- (void) onBrowser_Session:(NSNotification*)notification;
- (void) onBrowser_Link:(NSNotification*)notification;
- (void) UpdateViewHeader:(UIInterfaceOrientation)interfaceOrientation Video:(BOOL)video;
- (void) UpdateViewTopBar:(UIInterfaceOrientation)interfaceOrientation;
- (void) LoadUrlString:(NSString*)url_string;

- (void) webViewDidStartLoadLink:(UIWebView*)web;
- (void) webViewDidFinishLoadLink:(UIWebView*)web;
- (void) webViewDidFailLoadLink:(UIWebView*)web;

- (void) saveToHistoryWithTitle:(NSString*)title Link:(NSString*)link;
- (void) AddWebViewToScrollView:(SeequWebView*)web;

@end