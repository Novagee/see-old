    //
//  SeequBrowserViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/19/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequBrowserViewController.h"
#import "SeequSearchResultsViewController.h"
#import "SeequAddBookmarkViewController.h"
#import "idoubs2AppDelegate.h"
#import "NavigationBar.h"
#import "BackBarButton.h"
#import "Common.h"
#import "XMPPManager.h"
#import "config.h"
#import "NJKWebViewProgressView.h"
#define SAVED_LINKS_COUNT_LIMIT 200

NSString *completeRPCURL = @"webviewprogressproxy:///complete";
static const float initialProgressValue = 0.1;
static const float beforeInteractiveMaxProgressValue = 0.5;
static const float afterInteractiveMaxProgressValue = 0.9;

@interface SeequBrowserViewController ()

@end

@implementation SeequBrowserViewController


@synthesize viewTopBar;
@synthesize imageViewNavBG;
@synthesize imageViewSearchBG;
@synthesize imageViewLockIcon;
@synthesize webView;
@synthesize buttonBack;
@synthesize buttonForward;
@synthesize buttonAction;
@synthesize buttonBookMark;
@synthesize buttonPageNumbers;
@synthesize lblPageNumbers;
@synthesize lblPageTitle;
@synthesize isInSession;
@synthesize isInLoading;
@synthesize IsFinishedOrFaild;
@synthesize isGoBackOrForwardPressed;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)init
{
    self = [super init];
    if (self) {
        _maxLoadCount = _loadingCount = 0;
        _interactive = NO;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    [[idoubs2AppDelegate getChatManager] addDelegate:self];

    isShow = YES;
    self.isInSession = NO;
    self.webViewHeader.headerDelegate = self;

    self.webView = [[SeequWebView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height - 44) header:self.webViewHeader];

    self.webView.seequDelegate = self;
    [self.view addSubview:self.webView];
    [self.webView setBackgroundColor:[UIColor colorWithHue:0.630 saturation:0.065 brightness:0.545 alpha:1]];
    self.webView.delegate = self;
    self.webView.tag = 1;
    
    [self.webViewHeader setURL:@"http://www.cnn.com"];
    
    [self didEnterGo:self.webViewHeader withUrl:[self.webViewHeader getURL]];
    
    arrayWebDict = [[NSMutableArray alloc] init];
    arrayWebViews = [[NSMutableArray alloc] init];

    [arrayWebViews addObject:self.webView];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CNNi",@"title", @"http://cnn.com",@"link", nil];
    [arrayWebDict addObject:dict];
    [[NSUserDefaults standardUserDefaults] setObject:arrayWebDict forKey:@"WebsArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.buttonDone.hidden = YES;
    self.buttonNewPage.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewChange:)
                                                 name:kVideoViewChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBrowser_Link:)
                                                 name:BROWSER_LINK
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBrowser_Session:)
                                                 name:BROWSER_SESSION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(onButtonAction:)
                                                name:@"pressBuddybutton"
                                                object:nil];
    
    self.webView.frame = CGRectMake(0, 44, 320, self.view.frame.size.height - 44);
    suggestionTableView = [[SearchSuggestionTableView alloc] initWithFrame:self.webView.frame];
    suggestionTableView.suggestionDelegate = self;
    
    predictiveURLsTableView = [[PredictiveURLsTableView alloc] initWithFrame:self.webView.frame];
    predictiveURLsTableView.predictiveDelegate = self;
    CGContextRef ref = UIGraphicsGetCurrentContext();
    if(ref){
        [[self.view layer] renderInContext:UIGraphicsGetCurrentContext()];
    }
    CGFloat progressBarHeight = 3.5f;
    CGRect webViewHeaderBounds = self.webViewHeader.bounds;
    CGRect barFrame = CGRectMake(0, webViewHeaderBounds.size.height - progressBarHeight, webViewHeaderBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    [self.webViewHeader addSubview:_progressView];
    self.webViewHeader.webView = self.webView;
     
    
}

-(void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
}

-(void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data {
        NSString *alldata = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"alldata == %@", alldata);
}

-(void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
    NSLog(@"connectionDidFinishLoading");
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.hidden = YES;
    isShow = YES;
    
    if ([idoubs2AppDelegate sharedInstance].urlReq) {
        urlForReload = [[idoubs2AppDelegate sharedInstance].urlReq.URL absoluteString];
        [self.webView loadRequest:[idoubs2AppDelegate sharedInstance].urlReq];
        isLoading = YES;
        [idoubs2AppDelegate sharedInstance].urlReq = nil;
    }
    //[self.view setNeedsLayout];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!isClickOnPageControll) {
        [self.pageControl setFrame:CGRectMake(0, 370, 320, 36)];
        [self.tabBarController.view addSubview:self.pageControl];
        self.pageControl.hidden = YES;
    }

  //  [self setVideoViewState:videoViewState Animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.pageControl.hidden = YES;
    [[idoubs2AppDelegate getChatManager] removeDelegate:self];

    if (![[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
        [[idoubs2AppDelegate sharedInstance].soundService setSpeakerEnabled:OutputVoiceState_Speaker];
    }
}

- (IBAction)onButtonBack:(id)sender{
    isLinkFromSession = NO;
    [webView stopLoading];
    [SeequWebView setFirst:NO];
    if(0 > self.webView.scrollView.contentOffset.y > -self.webViewHeader.frame.size.height ){
        isGoBackOrForwardPressed = YES;
    }
    [webView goBack];
    [self SetBrowserButtons];
}

- (IBAction)onButtonForward:(id)sender{
    isLinkFromSession = NO;
    [webView stopLoading];
    [SeequWebView setFirst:NO];
    if(0 > self.webView.scrollView.contentOffset.y > -self.webViewHeader.frame.size.height ){
        isGoBackOrForwardPressed = YES;
    }
    [webView goForward];
    [self SetBrowserButtons];
}

- (IBAction)onButtonAction:(id)sender {
    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
        if (self.isInSession) {
            RSLogUI(@"[Browser][Buddy] Deactivated");
            self.isInSession = NO;
            [[idoubs2AppDelegate getChatManager] SendSessionDisconnectionRequestTo:[idoubs2AppDelegate sharedInstance].videoService.contactObject.SeequID];
            [self.buttonAction setBackgroundImage:[UIImage imageNamed:@"SeequButtonWebAction.png"] forState:UIControlStateNormal];
        } else {
            RSLogUI(@"[Browser][Buddy] Ativated");
            self.isInSession = YES;
            [[idoubs2AppDelegate getChatManager] SendSessionConnectionRequestTo:[idoubs2AppDelegate sharedInstance].videoService.contactObject.SeequID];
            [self.buttonAction setBackgroundImage:[UIImage imageNamed:@"seequButtonWebActionConnected.png"] forState:UIControlStateNormal];
            NSString *currentURL = webView.request.URL.absoluteString;
            if (currentURL && [currentURL isKindOfClass:[NSString class]] && currentURL.length) {
                [[idoubs2AppDelegate getChatManager] SendLinkWithLink:currentURL to:[idoubs2AppDelegate sharedInstance].videoService.contactObject.SeequID];
            }
        }
        
        NSNotification *notif = [NSNotification notificationWithName:@"BROWSER_SESSION" object:[NSNumber numberWithBool:self.isInSession]];
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView onBrowser_Session:notif];
    } else {
        NSString *text = [self.webViewHeader getTitle];
        NSString *url;
        if([[self.webViewHeader getURL] rangeOfString:@"http"].location ==! NSNotFound){
             url = [self.webViewHeader getURL];
        }else{
            url = [NSString stringWithFormat:@"%@%@",[self.webViewHeader strHttp], [self.webViewHeader getURL]];
        
        }
        //NSString *url = [NSString stringWithFormat:@"%@%@",[self.webViewHeader strHttp], [self.webViewHeader getURL]];
        if([self.webViewHeader strSlash]){
            url = [NSString stringWithFormat:@"%@/",url];
        }
        seequUIActivityItemProvider *ActivityProvider = [[seequUIActivityItemProvider alloc] init];
        ActivityProvider.url = url;
        ActivityProvider.text = text;
        NSArray *activityItems = @[ActivityProvider];
        
        BookmarkUIActivity *bookmarkActivity = [[BookmarkUIActivity alloc] initWithType:Activity_Type_Bookmark];
        BookmarkUIActivity *messageActivity = [[BookmarkUIActivity alloc] initWithType:Activity_Type_Message];
        
        
        RSLogUI(@"[BROWSER] Share Menu Clicked - URL:%@", url);
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[bookmarkActivity, messageActivity]];
        [activityView setExcludedActivityTypes:
         @[UIActivityTypeAssignToContact,
           UIActivityTypePrint,
           UIActivityTypeSaveToCameraRoll,
           UIActivityTypePostToWeibo,
           UIActivityTypePostToVimeo,
           UIActivityTypePostToTencentWeibo,
           UIActivityTypeAddToReadingList,
           UIActivityTypePostToFlickr]];

        
        [self.tabBarController presentViewController:activityView animated:YES completion:^{
        }];
            }
}

- (IBAction)onButtonBookMark:(id)sender {
    SeequBookmarksViewController *controller = [[idoubs2AppDelegate sharedInstance].seequBookmarks.viewControllers objectAtIndex:0];
    controller.seequBookmarksDelegate = self;
    [self.tabBarController presentViewController:[idoubs2AppDelegate sharedInstance].seequBookmarks animated:YES completion:nil];
}

- (IBAction)onButtonPageNumbers:(id)sender {
    return;
    
    [UIView beginAnimations:@"frame" context:nil];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    isClickOnPageControll = YES;
    
    self.buttonNewPage.hidden = NO;
    self.buttonDone.hidden = NO;
    self.pageControl.hidden = NO;
    self.labelPageLinkEditMod.hidden = NO;
    self.labelPageNameEditMod.hidden = NO;
    
    webView.scrollView.scrollEnabled = NO;

    self.labelPageNameEditMod.text = self.lblPageTitle.text;
    
    self.buttonBack.hidden = YES;
    self.buttonBookMark.hidden = YES;
    self.buttonAction.hidden = YES;
    self.buttonForward.hidden = YES;
    
//    self.scroll.contentSize = CGSizeMake(arrayWebViews.count*320, self.view.frame.size.height - 44);
//    self.scroll.backgroundColor = [UIColor grayColor];
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//    [UIView setAnimationDuration:0.3];
//    SeequWebView *web;
//    for (int i = arrayWebViews.count-1; i>-1; i--) {
//        web = [arrayWebViews objectAtIndex:i];
//        [web setFrame:CGRectMake(i*320+70, 59, 320 - 140, self.view.frame.size.height - 170)];
//    }
//    
//    [UIView commitAnimations];
//    self.webView.frame = CGRectMake(40, 80, self.view.frame.size.width - 80, self.view.frame.size.height - 160);
    self.webView.transform = CGAffineTransformMakeScale(0.65, 0.7);
    
    [UIView commitAnimations];
}

- (IBAction)onButtonDone:(id)sender {
    isClickOnPageControll = NO;
    
    self.buttonNewPage.hidden = YES;
    self.buttonDone.hidden = YES;
    self.pageControl.hidden = YES;
    self.labelPageLinkEditMod.hidden = YES;
    self.labelPageNameEditMod.hidden = YES;
    
    webView.scrollView.scrollEnabled = YES;
    
    self.buttonBack.hidden = NO;
    self.buttonBookMark.hidden = NO;
    self.buttonAction.hidden = NO;
    self.buttonForward.hidden = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    
    self.webView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    
    [UIView commitAnimations];
    

}

- (IBAction)onButtonNewPage:(id)sender {
    SeequWebView *web = [[SeequWebView alloc] init];
    web.seequDelegate = self;
//    if (self.pageControl.currentPage<arrayWebViews.count) {
//        [arrayWebViews insertObject:web atIndex:self.pageControl.currentPage+1];
//        [web setFrame:self.webView.frame];
//    } else {
//        [arrayWebViews addObject:web];
//        [web setFrame:self.webView.frame];
//    }
    [web setBackgroundColor:[UIColor colorWithHue:0.630 saturation:0.065 brightness:0.545 alpha:1]];
    web.delegate = self;
    web.scalesPageToFit = YES;
    web.tag = 1;
    
    [self AddWebViewToScrollView:web];
    self.webView = web;
    
    self.pageControl.numberOfPages++;
}

- (IBAction)onButtonVideo:(id)sender {

}

- (void) didClickBookmark:(BookmarkUIActivity*)bookmarkUIActivity Bookmark:(NSArray*)bookmark {
    [self.tabBarController presentViewController:[idoubs2AppDelegate sharedInstance].seequAddBookmark animated:YES completion:^{
        
    }];
}

- (void) onVideoViewChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    videoViewState = (VideoViewState)[eargs intValue];
    
    [self setVideoViewState:videoViewState Animated:YES];
}

- (void)keyboardWillShow:(NSNotification *)notif {
    if (![predictiveURLsTableView superview]) {
        if (![self.webViewHeader.textFieldUrl.text hasPrefix:@"http://"] && ![self.webViewHeader.textFieldUrl.text hasPrefix:@"https://"]) {
            strHttp = [self.webViewHeader strHttp];
            self.webViewHeader.textFieldUrl.text = [NSString stringWithFormat:@"%@%@", strHttp, self.webViewHeader.textFieldUrl.text];;
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
//    [self.webViewHeader onButtonCancel:nil];
}

- (void) setVideoViewState:(int)state Animated:(BOOL)animated {
    CGRect frame = CGRectZero;
    
    switch (state) {
        case VideoViewState_NONE:
        case VideoViewState_NORMAL:
        case VideoViewState_NORMAL_MENU:
        case VideoViewState_HIDE: {
            frame = CGRectMake(0, 44, 320, self.view.frame.size.height - 44);
            self.viewTopBar.frame = CGRectMake(0, 0, 320, 44);
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, 160, 320, self.view.frame.size.height - 160);
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, 252, 320, self.view.frame.size.height - 252);
        }
            break;
        default:
            break;
    }
    
    [self changeViewByOrientation:self.interfaceOrientation];
    [self UpdateViewHeader:self.interfaceOrientation Video:YES];
    [self UpdateViewTopBar:self.interfaceOrientation];
    
    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall] && videoViewState == VideoViewState_HIDE && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        if ([[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
            [self.webViewHeader setCallState:WebViewHeaderCallState_Video];
        } else {
            [self.webViewHeader setCallState:WebViewHeaderCallState_Audio];
        }
    } else {
        if (![[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
            [self.webViewHeader setCallState:WebViewHeaderCallState_None];
        } else {
            if ((state == VideoViewState_TAB || state == VideoViewState_TAB_MENU) && [[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
                [self.webViewHeader setCallState:WebViewHeaderCallState_CallMenu];
            }
        }
    }
    
    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
        if (self.isInSession) {
            [self.buttonAction setBackgroundImage:[UIImage imageNamed:@"seequButtonWebActionConnected.png"] forState:UIControlStateNormal];
        } else {
            [self.buttonAction setBackgroundImage:[UIImage imageNamed:@"SeequButtonWebAction.png"] forState:UIControlStateNormal];
        }
    } else {
        [self.buttonAction setBackgroundImage:[UIImage imageNamed:@"SeequButtonBookMark.png"] forState:UIControlStateNormal];
        self.isInSession = NO;
    }
}

- (void) onBrowser_Session:(NSNotification*)notification {
    BOOL connect = [[notification object] boolValue];
    NSLog(@"[BROWSER][Buddy][RCV] %s", connect ? "Enable" : "Disable");
    
    if (connect) {
        if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
            self.isInSession = YES;
            
            if (videoViewState == VideoViewState_NORMAL || videoViewState == VideoViewState_NORMAL_MENU || (![[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState])) {
                [[idoubs2AppDelegate sharedInstance].videoService.showVideoView setVideoState:VideoViewState_TAB Animation:YES];
            }
            if ([idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex != 2) {
                [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 2;
            }
        }
    } else {
        self.isInSession = NO;
    }
    
    if (self.isInSession) {
        [self.buttonAction setBackgroundImage:[UIImage imageNamed:@"seequButtonWebActionConnected.png"] forState:UIControlStateNormal];
    } else {
        [self.buttonAction setBackgroundImage:[UIImage imageNamed:@"SeequButtonWebAction.png"] forState:UIControlStateNormal];
    }
}

- (void) onBrowser_Link:(NSNotification*)notification {
    if (!self.isInSession) {
        return;
    }
    //[self.webView stopLoading];
    
    isLinkFromSession = YES;
    NSString *url_Str = [notification object];
    url_Str = [url_Str stringByReplacingOccurrencesOfString:@"BROWSER_LINK: " withString:@""];
    NSLog(@"[BROWSER][Buddy][RCV] URL - %@", url_Str);
    urlForReload = url_Str;
    
    NSURL *url = [NSURL URLWithString:url_Str];
    self.webViewHeader.textFieldUrl.text = url_Str;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    if(!isInLoading){
        isInLoading =YES;
    [self.webView loadRequest:request];
    }
    isLoading = YES;
}

- (IBAction)pageControlClick:(id)sender {
//    int page = self.pageControl.currentPage;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView_ {
    int page = scrollView_.contentOffset.x/scrollView_.frame.size.width;
    self.pageControl.currentPage = page;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView_ {
    int page = scrollView_.contentOffset.x/scrollView_.frame.size.width;
    self.pageControl.currentPage = page;
}

- (void) SetBrowserButtons {
    if (webView.canGoForward) {
        [buttonForward setBackgroundImage:[UIImage imageNamed:@"SeequButtonWebNextPageEnable.png"] forState:UIControlStateNormal];
        buttonForward.enabled = YES;
    } else{
        [buttonForward setBackgroundImage:[UIImage imageNamed:@"SeequButtonWebNextPageDisable.png"] forState:UIControlStateNormal];
        buttonForward.enabled = NO;
    }
    
    if (webView.canGoBack) {
        [buttonBack setBackgroundImage:[UIImage imageNamed:@"SeequButtonWebPrevousPageEnable.png"] forState:UIControlStateNormal];
        buttonBack.enabled = YES;
    } else {
        [buttonBack setBackgroundImage:[UIImage imageNamed:@"SeequButtonWebPrevousPageDisable.png"] forState:UIControlStateNormal];
        buttonBack.enabled = NO;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)myWebView {
    NSLog(@"[BROWSER][WEB] {webViewDidStartLoad}");
   [self performSelectorOnMainThread:@selector(webViewDidStartLoadLink:) withObject:myWebView waitUntilDone:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)myWebView {
    NSLog(@"[BROWSER][WEB] {webViewDidFinishLoad}");
    [self performSelectorOnMainThread:@selector(webViewDidFinishLoadLink:) withObject:myWebView waitUntilDone:YES];
}

- (void)webView:(UIWebView *)myWebView didFailLoadWithError:(NSError *)error {
    NSLog(@"[BROWSER][WEB][ERR] %@", error.description);
    if (error.code == NSURLErrorCancelled) return;
    [self performSelectorOnMainThread:@selector(webViewDidFailLoadLink:) withObject:myWebView waitUntilDone:YES];
}

#pragma mark -
#pragma mark SeequWebViewHeader Delegate Methods
#pragma mark -

- (void) didBeginEditingURL:(SeequWebViewHeader*)webHeader {
    
    @synchronized(self){
        [self.webView textFieldShouldBeginEditing:webHeader.textFieldUrl];

    //    [self.webView setPinHeader:YES];
        isGoPressed = NO;
        
        static BOOL first = YES;
        
        if (!first) {
           // [self.webView stopLoading];
            
        }
        [self.webViewHeader setRightViewState:RightViewState_Clear];
        first = NO;
    }
}

- (void) didEndEditingURL:(SeequWebViewHeader*)webHeader {
    @synchronized(self){

        [self.webView textFieldShouldEndEditing:webHeader.textFieldUrl];

    //    [self.webView setPinHeader:NO];
        if (!isGoPressed) {
            NSString *currentURL = webView.request.URL.absoluteString;
            if (![predictiveURLsTableView superview] && currentURL && [currentURL isKindOfClass:[NSString class]] && currentURL.length) {
                [self.webViewHeader setURL:currentURL];
            }
        }
        
        isGoPressed = NO;
        if([predictiveURLsTableView superview] == nil){
            [self.webViewHeader setRightViewState:RightViewState_Reload];
        }else{
            [self.webViewHeader setRightViewState:RightViewState_Clear];
        }
    }
   
    if([predictiveURLsTableView superview] == nil){
        [self.webViewHeader onButtonCancel:nil];
        self.webViewHeader.textFieldUrl.text = [self.webViewHeader setedUrl];
    }
    
}

- (void) didBeginEditingSearch:(SeequWebViewHeader*)webHeader {
    [self.webView textFieldShouldBeginEditing:webHeader.textFieldSearch];
    
//    [self.webView setPinHeader:YES];
      webView.scrollView.scrollEnabled = NO;
}

- (void) didEndEditingSearch:(SeequWebViewHeader*)webHeader {
    [self.webView textFieldShouldEndEditing:webHeader.textFieldSearch];

//    [self.webView setPinHeader:NO];
}

- (void) didEnterGo:(SeequWebViewHeader*)webHeader withUrl:(NSString*)url_string {
    [self.webViewHeader.textFieldUrl resignFirstResponder];
    [webHeader setURL:url_string];
    [self LoadUrlString:url_string];
    [predictiveURLsTableView removeFromSuperview];
}

- (void) LoadUrlString:(NSString*)url_string {
    if (url_string.length) {
        if ([self urlIsValiad:url_string]) {
            NSURL *url;
            NSString *stringUrl;
            
            if([url_string rangeOfString:@"http"].location ==! NSNotFound){
              stringUrl = url_string;
            }else{
                stringUrl = [NSString stringWithFormat:@"http://%@", url_string];
            }
            
            urlForReload = stringUrl;
            url = [NSURL URLWithString:stringUrl];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            [webView loadRequest:request];
            isGoPressed = YES;
            isLinkFromSession = NO;
            [self resignFirstResponder];
            
            IsFinishedOrFaild = NO;
 
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                            message:@"Invalid url."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void) didEnterSearch:(SeequWebViewHeader*)suggestionView withText:(NSString*)text {
    [self didSelectSearchString:suggestionTableView Text:text];
}

- (void) didStopLoading:(SeequWebViewHeader*)webHeader State:(RightViewState)state {
    switch (state) {
        case RightViewState_None:
        case RightViewState_Stop: {
            [self.webView stopLoading];
            [self.webViewHeader setRightViewState:RightViewState_Reload];
        }
            break;
        case RightViewState_Reload: {
            [self.webView stopLoading];
            [self didEnterGo:self.webViewHeader withUrl:[self.webViewHeader getURL]];
            [self.webViewHeader setRightViewState:RightViewState_Stop];
        }
            break;
        case RightViewState_Clear: {
            [self.webView stopLoading];
            self.webViewHeader.textFieldUrl.text = @"";
            [self.webViewHeader.textFieldUrl becomeFirstResponder];
        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark SearchSuggestionTableView Delegate Methods
#pragma mark -

- (void) didScrallTableView:(SearchSuggestionTableView*)suggestionView UIInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([suggestionView isKindOfClass:[SearchSuggestionTableView class]]) {
        NSString *searchtext = self.webViewHeader.textFieldSearch.text;
        [self.webViewHeader.textFieldSearch resignFirstResponder];
        self.webViewHeader.textFieldSearch.text = searchtext;
    } else {
        if ([suggestionView isKindOfClass:[PredictiveURLsTableView class]]) {
            [self.webViewHeader.textFieldUrl resignFirstResponder];            
        }
    }
}

- (void) didChangeSearchText:(SeequWebViewHeader*)webHeader Text:(NSString*)text {
    
    [suggestionTableView setSearchText:text];
    self.webView.scrollView.scrollEnabled = NO;
    suggestionTableView.hidden = NO;
}

- (void) didChangeUrlText:(SeequWebViewHeader*)webHeader Text:(NSString*)text {
    if (![predictiveURLsTableView superview]) {
        [self.view addSubview:predictiveURLsTableView];
        webView.scrollView.scrollEnabled = NO;
        
    }
    
    CGRect frame = self.webView.frame;
    frame.origin.y += self.webViewHeader.frame.size.height;
    //frame.size.height -= self.webViewHeader.frame.size.height;


//    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
//        frame.size.height -= 167;
//    } else {
//        frame.size.height -= 161;
//    }

    predictiveURLsTableView.frame = frame;
    
    [predictiveURLsTableView setBeginOfURL:text];
}

- (void) didEndBeginSearchAnimation:(SeequWebViewHeader*)webHeader {
    //if (self.webViewHeader.textFieldSearch.isEditing) {
        [self.view addSubview:suggestionTableView];
        CGRect frame = self.webView.frame;
        frame.origin.y += self.webViewHeader.frame.size.height;
        frame.size.height -= self.webViewHeader.frame.size.height;
        
//        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
//            frame.size.height -= 167;
//        } else {
//            frame.size.height -= 161;
//
        suggestionTableView.frame = frame;
    if(self.webViewHeader.textFieldSearch.editing){
        suggestionTableView.hidden = YES;
    }
    
    
     //}
}

- (void) didEndEndSearchAnimation:(SeequWebViewHeader*)webHeader {
    [suggestionTableView removeFromSuperview];
    [predictiveURLsTableView removeFromSuperview];
}

- (void) didSelectSearchString:(SearchSuggestionTableView*)webHeader Text:(NSString*)text {
    self.webViewHeader.textFieldSearch.text = text;

    text = [text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *url_string = [NSString stringWithFormat:@"http://www.bing.com/search?q=%@", text];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    urlForReload = url_string;
    NSURL *url;
    url = [NSURL URLWithString:url_string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [webView loadRequest:request];
    isLoading = YES;
    isGoPressed = YES;
    isLinkFromSession = NO;
    [suggestionTableView removeFromSuperview];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self.webViewHeader setHeaderState:SeequWebViewHeaderState_Landscape Animated:YES];
    } else {
        [self.webViewHeader setHeaderState:SeequWebViewHeaderState_Portrait Animated:YES];
    }
    [self.webViewHeader onButtonCancel:nil];
}


- (void) didClickCancel:(SeequWebViewHeader*)webHeader {
    [predictiveURLsTableView removeFromSuperview];
    self.webView.scrollView.scrollEnabled = YES;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(self.webViewHeader.frame.size.height, 0.0f, 20, 0.0f);
    [[suggestionTableView arrayList] removeAllObjects];
    [suggestionTableView reloadData];
    webHeader.textFieldSearch.text = @"";

    
}

- (void) didSelectPredictiveURL:(PredictiveURLsTableView*)predictiveURLsTableView URL:(NSString*)urlstring Title:(NSString*)title_ {
    
    
    

     [self.webViewHeader.textFieldUrl resignFirstResponder];
    
    [self.webViewHeader setURL:urlstring];
    [self LoadUrlString:urlstring];
    //self.webViewHeader.textFieldSearch.text = urlstring;
    [self.webViewHeader setTitle:title_];
   

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    isLoading = YES;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self.webViewHeader setHeaderState:SeequWebViewHeaderState_Landscape Animated:YES];
    } else {
        [self.webViewHeader setHeaderState:SeequWebViewHeaderState_Portrait Animated:YES];
    }
    [self.webViewHeader onButtonCancel:nil];
}

- (void) didClickVideo:(SeequWebViewHeader *)webHeader {
    if ([[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView setVideoState:VideoViewState_TAB_MENU Animation:YES];
    } else {
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView setVideoState:VideoViewState_NORMAL Animation:YES];
    }
}

- (void)changeViewByOrientation:(UIInterfaceOrientation)interfaceOrientation {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait: {
            [self viewInportraitMode];
            break;
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            [self viewInportraitMode];
            break;
        }
        case UIInterfaceOrientationLandscapeRight: {
            [self viewInLandscapeMode];
            break;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            [self viewInLandscapeMode];
            break;
        }
    }
}


- (void) viewInLandscapeMode {
    idoubs2AppDelegate *appDelegate = [idoubs2AppDelegate sharedInstance];
    int land_x_coord = 47;
    self.imageViewNavBG.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, 40);
    [self.imageViewNavBG setImage:[UIImage imageNamed:@"seequNavigationDefaultBGLandscape.png"]];
    self.lblPageNumbers.center = CGPointMake(appDelegate.window.frame.size.height - land_x_coord + 1, 21);
}

- (void) viewInportraitMode{
    idoubs2AppDelegate *appDelegate = [idoubs2AppDelegate sharedInstance];
    int port_x_coord = 33;
    
    self.imageViewNavBG.frame = CGRectMake(0, 0, 320, 44);
    [self.imageViewNavBG setImage:[UIImage imageNamed:@"seequNavigationDefaultBG.png"]];
    self.lblPageNumbers.center = CGPointMake(appDelegate.window.frame.size.width - port_x_coord + 1, 23);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self changeViewByOrientation:toInterfaceOrientation];
    [self.webViewHeader setOrientation:toInterfaceOrientation];
    
    if ([suggestionTableView superview]) {
        if (self.webViewHeader.textFieldSearch.isEditing) {
            [self didEndBeginSearchAnimation:self.webViewHeader];
            suggestionTableView.hidden = NO;
        } else {
            [self didScrallTableView:suggestionTableView UIInterfaceOrientation:toInterfaceOrientation];
        }
    }
    [self.view setNeedsLayout];
    
}

///@todo levon  eliminate  all  layout changes  from other methods
-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    idoubs2AppDelegate *appDelegate = [idoubs2AppDelegate sharedInstance];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat versionDiff = 0;
    versionDiff = 20;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if ([appDelegate.videoService isInCall] && (videoViewState != VideoViewState_HIDE &&videoViewState != VideoViewState_PREVIEW)&&[appDelegate.videoService.showVideoView isVideoState]) {
            self.viewTopBar.frame = CGRectMake(SMALL_VIDEO_HEIGHT, 0, [[UIScreen mainScreen] bounds].size.height - SMALL_VIDEO_HEIGHT*2, self.viewTopBar.frame.size.height);
            self.buttonBack.frame = CGRectMake(0, 0, 64, 44);
            self.buttonForward.frame = CGRectMake(self.viewTopBar.frame.size.width/2 - self.buttonForward.frame.size.width/2, -2 , 64, 44);
            self.buttonAction.frame = CGRectMake(self.viewTopBar.frame.size.width - self.buttonAction.frame.size.width, -2, 64, 44);
            self.buttonBookMark.hidden = YES;
            self.buttonPageNumbers.hidden = YES;
            versionDiff = 0;
        } else {
            self.buttonBookMark.hidden = NO;
            self.buttonPageNumbers.hidden = NO;
            self.viewTopBar.frame = CGRectMake(0, versionDiff, [[UIScreen mainScreen] bounds].size.height, self.viewTopBar.frame.size.height);
            self.buttonBack.frame = CGRectMake(30, 0, 64, 44);
            self.buttonForward.frame = CGRectMake(self.viewTopBar.frame.size.width/4 - self.buttonForward.frame.size.width/2 + 16, 0, 64, 44);
            self.buttonAction.frame = CGRectMake(self.viewTopBar.frame.size.width/2 - self.buttonAction.frame.size.width/2, -2, 64, 44);
            self.buttonBookMark.frame = CGRectMake(self.viewTopBar.frame.size.width*(3.0/4.0) - self.buttonBookMark.frame.size.width/2, 0, 64, 44);
            self.buttonPageNumbers.frame = CGRectMake(self.viewTopBar.frame.size.width - 21 - 9 - 16, 9, 21, 21);
        }
//        self.webView.frame = CGRectMake(0, self.viewTopBar.frame.size.height + versionDiff, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - self.viewTopBar.frame.size.height -versionDiff);
    
         self.webView.frame = CGRectMake(0, self.viewTopBar.frame.size.height + versionDiff, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width - self.viewTopBar.frame.size.height );
        
        
        CGRect frame = self.webView.frame;
        frame.origin.y += self.webViewHeader.frame.size.height;
        frame.size.height -= self.webViewHeader.frame.size.height;
        predictiveURLsTableView.frame = frame;
        
    } else {
                
        self.buttonBookMark.hidden = NO;
        self.buttonPageNumbers.hidden = NO;
        self.viewTopBar.frame = CGRectMake(0, versionDiff, 320, self.viewTopBar.frame.size.height);
        self.buttonBack.frame = CGRectMake(0, 0, 64, 44);
        self.buttonForward.frame = CGRectMake(self.viewTopBar.frame.size.width/5, 0, 64, 44);
        self.buttonAction.frame = CGRectMake(self.viewTopBar.frame.size.width/2 - self.buttonAction.frame.size.width/2, 0, 64, 44);
        self.buttonBookMark.frame = CGRectMake(self.viewTopBar.frame.size.width*(3.0/4.0) - self.buttonBookMark.frame.size.width/2, 0, 64, 44);
        self.buttonPageNumbers.frame = CGRectMake(self.viewTopBar.frame.size.width - 21 - 17, 11 , 21, 21);
        
        ////////
        
        CGFloat originY = 0;
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 568) {
            originY = 88;
        }
        CGRect frame;
        if (videoViewState == VideoViewState_TAB) {
            frame = CGRectMake(0, self.view.frame.size.height - 271 - originY , 320, self.view.frame.size.height - (self.view.frame.size.height - 271 - originY));
        } else if (videoViewState == VideoViewState_TAB_MENU) {
            frame = CGRectMake(0, self.view.frame.size.height - 179 - originY, 320, self.view.frame.size.height - (self.view.frame.size.height - 179 - originY));
        } else {
            //frame = CGRectMake(0, self.viewTopBar.frame.size.height + versionDiff, self.view.frame.size.width, self.view.frame.size.height - self.viewTopBar.frame.size.height);
            frame = CGRectMake(0, self.viewTopBar.frame.size.height + versionDiff, self.view.frame.size.width, self.view.frame.size.height - self.viewTopBar.frame.size.height);

        }
        
        self.webView.frame = frame;
        if(predictiveURLsTableView.superview){
            CGRect frame = self.webView.frame;
            frame.origin.y += self.webViewHeader.frame.size.height;
            frame.size.height -= self.webViewHeader.frame.size.height;
            predictiveURLsTableView.frame = frame;        }
    }
    
    self.imageViewNavBG.frame = CGRectMake(0, 0, viewTopBar.frame.size.width, viewTopBar.frame.size.height);
}
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//
//    [self UpdateViewTopBar:self.interfaceOrientation];
//
//    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
//        self.hidesBottomBarWhenPushed = YES;
//    } else {
//        self.hidesBottomBarWhenPushed = NO;
//    }
//    
////    [idoubs2AppDelegate RefreshTab];
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setButtonDone:nil];
    [self setButtonNewPage:nil];
    [self setLabelPageLinkEditMod:nil];
    [self setLabelPageNameEditMod:nil];
    [self setPageControl:nil];
    [self setButtonVideo:nil];
    [self setWebViewHeader:nil];
    [super viewDidUnload];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    switch (navigationType) {
        case UIWebViewNavigationTypeLinkClicked: {
            RSLogUI(@"[BROWSER][WEB][Navigation] - Link Clicked");
            isLinkFromSession = NO;
////            if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
//                [[XMPPManager sharedXMPPManager] SendTextMessage:[NSString stringWithFormat:@"BROWSER_LINK: %@", request.URL.absoluteString] to:[idoubs2AppDelegate sharedInstance].videoService.contactObject.SeequID];
////            }
            NSURL* url = request.URL;
            NSString* strUrl = [NSString stringWithFormat:@"%@",url];
            [self.webViewHeader setURL:strUrl];
            [SeequWebView setFirst:NO];
            IsFinishedOrFaild = NO;

        }
            break;
        case UIWebViewNavigationTypeFormSubmitted: {
           RSLogUI(@"[BROWSER][WEB][Navigation] Type - Form Submitted");
            isLinkFromSession = NO;
                    }
            break;
        case UIWebViewNavigationTypeBackForward: {
            RSLogUI(@"[BROWSER][WEB][Navigation] Type - Back Forward");
            isLinkFromSession = NO;

        }
            break;
        case UIWebViewNavigationTypeReload: {
            RSLogUI(@"[BROWSER][WEB][Navigation] Type - Reload");
            isLinkFromSession = NO;

        }
            break;
        case UIWebViewNavigationTypeFormResubmitted: {
            RSLogUI(@"[BROWSER][WEB][Navigation] Type - Form Resubmitted");
            isLinkFromSession = NO;

        }
            break;
        case UIWebViewNavigationTypeOther: {
            RSLogUI(@"[BROWSER][WEB][Navigation] Type - Other");
            if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
//                [[XMPPManager sharedXMPPManager] SendTextMessage:[NSString stringWithFormat:@"BROWSER_LINK: %@", request.URL.absoluteString] to:[idoubs2AppDelegate sharedInstance].videoService.contactObject.SeequID];
                //[self.webView stopLoading];
                //return NO;
            }
        }
            break;
            
        default:
            break;
    }
    RSLogUI(@"[BROWSER][WEB][Navigation] URL - %@", request.URL.absoluteString);
    [self SetBrowserButtons];
    
   
    if ([request.URL.absoluteString isEqualToString:completeRPCURL]) {
        [self completeProgress];
        return NO;
    }
    
    BOOL ret = YES;
    
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:aWebView.request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    
    BOOL isHTTP = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"];
    if (ret && !isFragmentJump && isHTTP && isTopLevelNavigation) {
        _currentURL = request.URL;
        [self reset];
    }
    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
        if (!isLinkFromSession && self.isInSession) {
            [[idoubs2AppDelegate getChatManager] SendLinkWithLink:[_currentURL absoluteString] to:[idoubs2AppDelegate sharedInstance].videoService.contactObject.SeequID];
           
        }
    } else {
        self.isInSession = NO;
    }
    

     return YES;
}

#pragma mark -
#pragma mark SeequWebView Delegate Methods
#pragma mark -

- (void) didClickOnSearchInSeequ:(SeequWebView*)seequWebView withText:(NSString*)text {
    RSLogUI(@"[BROWSER] - Searche cliced");
    SeequSearchResultsViewController *viewController = [[SeequSearchResultsViewController alloc] initWithNibName:@"SeequSearchResultsViewController" bundle:nil];
    viewController.searchText = text;
    viewController.videoViewState = videoViewState;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)webView:(SeequWebView *)_webView didReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources {
    if (resourceNumber == totalResources) {
        _webView.resourceCount = 0;
        _webView.resourceCompletedCount = 0;
        self.webViewHeader.imageViewProgress.frame = CGRectMake(10, 22, 0, 0);
    }
}

- (void) UpdateViewHeader:(UIInterfaceOrientation)interfaceOrientation Video:(BOOL)video {
    idoubs2AppDelegate *appDelegate = [idoubs2AppDelegate sharedInstance];
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        if ([appDelegate.videoService isInCall] &&(videoViewState != VideoViewState_HIDE &&videoViewState != VideoViewState_PREVIEW) && [[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
            self.webView.frame = CGRectMake(0, 40, [[UIScreen mainScreen] bounds].size.height, 320 - 40);
//            [self.webViewHeader setHeaderState:SeequWebViewHeaderState_Landscape Animated:NO];
            [self.webViewHeader setOrientation:interfaceOrientation];
        } else {
            if ([appDelegate.videoService isInCall] && (videoViewState == VideoViewState_HIDE||videoViewState == VideoViewState_PREVIEW) && [[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
                self.webView.frame = CGRectMake(0, 40, [[UIScreen mainScreen] bounds].size.height, 320 - 60);
//                [self.webViewHeader setHeaderState:SeequWebViewHeaderState_Landscape Animated:NO];
            } else {
                self.webView.frame = CGRectMake(0, 40, [[UIScreen mainScreen] bounds].size.height, 320 - 60);
                [self.webViewHeader setHeaderState:SeequWebViewHeaderState_Landscape Animated:NO];
            }
        }
    } else {
        int state = videoViewState;
        if (![[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
            state = VideoViewState_HIDE;
            videoViewState = state;
        }
        
        int diff = 0;
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 568) {
            diff = 88;
        }
        
        CGRect frame;
        if (state == VideoViewState_TAB) {
            frame = CGRectMake(0, self.view.frame.size.height - 271 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 271 - diff));
        } else {
            if (state == VideoViewState_TAB_MENU) {
                frame = CGRectMake(0, self.view.frame.size.height - 179 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 179 - diff));
            } else {
                frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44);
            }
        }
        
        [UIView beginAnimations:@"webFrame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3];
        [self.webView setFrame:frame];
//        self.webView.frame = frame;
        [UIView commitAnimations];

        if ([appDelegate.videoService isInCall] && videoViewState == VideoViewState_HIDE) {
//            [self.webViewHeader setHeaderState:SeequWebViewHeaderState_Portrait Animated:NO];
        } else {
//            [self.webViewHeader setHeaderState:SeequWebViewHeaderState_Portrait Animated:NO];
        }
    }
    
    [self.webViewHeader setOrientation:interfaceOrientation];    
    if ([predictiveURLsTableView superview]) {
        [self didChangeUrlText:self.webViewHeader Text:self.webViewHeader.textFieldUrl.text];
    }
}

- (void) UpdateViewTopBar:(UIInterfaceOrientation)interfaceOrientation {
    idoubs2AppDelegate *appDelegate = [idoubs2AppDelegate sharedInstance];
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        if ([appDelegate.videoService isInCall] && (videoViewState != VideoViewState_HIDE &&videoViewState != VideoViewState_PREVIEW) && [appDelegate .videoService.showVideoView isVideoState]) {
            self.viewTopBar.frame = CGRectMake(SMALL_VIDEO_HEIGHT, 0, [[UIScreen mainScreen] bounds].size.height - SMALL_VIDEO_HEIGHT*2, self.viewTopBar.frame.size.height);
            self.buttonBack.frame = CGRectMake(0, 0, 64, 44);
            self.buttonForward.frame = CGRectMake(self.viewTopBar.frame.size.width/2 - self.buttonForward.frame.size.width/2, -2, 64, 44);
            self.buttonAction.frame = CGRectMake(self.viewTopBar.frame.size.width - self.buttonAction.frame.size.width, -2, 64, 44);
            self.buttonBookMark.hidden = YES;
            self.buttonPageNumbers.hidden = YES;
        } else {
            self.buttonBookMark.hidden = NO;
            self.buttonPageNumbers.hidden = NO;
            self.viewTopBar.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, self.viewTopBar.frame.size.height);
            self.buttonBack.frame = CGRectMake(30, 0, 64, 44);
            self.buttonForward.frame = CGRectMake(self.viewTopBar.frame.size.width/4 - self.buttonForward.frame.size.width/2 + 16, 0, 64, 44);
            self.buttonAction.frame = CGRectMake(self.viewTopBar.frame.size.width/2 - self.buttonAction.frame.size.width/2, -2, 64, 44);
            self.buttonBookMark.frame = CGRectMake(self.viewTopBar.frame.size.width*(3.0/4.0) - self.buttonBookMark.frame.size.width/2, 0, 64, 44);
            self.buttonPageNumbers.frame = CGRectMake(self.viewTopBar.frame.size.width - 21 - 9 - 16, 9, 21, 21);
        }
    } else {
        self.buttonBookMark.hidden = NO;
        self.buttonPageNumbers.hidden = NO;
        self.viewTopBar.frame = CGRectMake(0, 0, 320, self.viewTopBar.frame.size.height);
        self.buttonBack.frame = CGRectMake(0, 0, 64, 44);
        self.buttonForward.frame = CGRectMake(self.viewTopBar.frame.size.width/5, 0, 64, 44);
        self.buttonAction.frame = CGRectMake(self.viewTopBar.frame.size.width/2 - self.buttonAction.frame.size.width/2, 0, 64, 44);
        self.buttonBookMark.frame = CGRectMake(self.viewTopBar.frame.size.width*(3.0/4.0) - self.buttonBookMark.frame.size.width/2, 0, 64, 44);
        self.buttonPageNumbers.frame = CGRectMake(self.viewTopBar.frame.size.width - 21 - 17, 11, 21, 21);
    }
    
    self.imageViewNavBG.frame = CGRectMake(0, 0, viewTopBar.frame.size.width, viewTopBar.frame.size.height);
}

- (BOOL) urlIsValiad: (NSString *) url
{
    NSString *regex = @"(([a-zA-Z][0-9a-zA-Z+\\-\\.]*:)?/{0,2}[0-9a-zA-Z;/?:@&=+$\\.\\-_!~*'()%]+)?(#[0-9a-zA-Z;/?:@&=+$\\.\\-_!~*'()%]+)?";
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([regextest evaluateWithObject: url] == YES) {
        NSLog(@"[BROWSER][WEB] URL is valid!");
    } else {
        NSLog(@"[BROWSER][WEB] URL is not valid!");
    }
        
    return [regextest evaluateWithObject:url];
}

- (void) webViewDidStartLoadLink:(UIWebView*)web {
    NSLog(@"[BROWSER][WEB] - Start Loading Link (%@)", web.request.URL.absoluteString);
    isLoading = YES;
    isInLoading = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    buttonBack.enabled = (web.canGoBack);
    buttonForward.enabled = (web.canGoForward);
//    NSString *page_title = [web stringByEvaluatingJavaScriptFromString: @"document.title"];
//    
//    [self.webViewHeader setTitle:page_title];
    [self.webViewHeader setRightViewState:RightViewState_Stop];
    _loadingCount++;
    _maxLoadCount = fmax(_maxLoadCount, _loadingCount);
    [self startProgress];
}

- (void) webViewDidFinishLoadLink:(UIWebView*)web {
    @synchronized(self){
        NSLog(@"[BROWSER][WEB] - Finish Loading Link (%@)", web.request.URL.absoluteString);
        isLoading = NO;
        isInLoading = NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        buttonBack.enabled = (web.canGoBack);
        buttonForward.enabled = (web.canGoForward);
        [self.webViewHeader setTitle:[web stringByEvaluatingJavaScriptFromString: @"document.title"]];
        NSString *currentURL = web.request.URL.absoluteString;

        [self saveToHistoryWithTitle:[self.webViewHeader getTitle] Link:currentURL];

        [self.webViewHeader setURL:currentURL];
    
//    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
//        if (!isLinkFromSession && self.isInSession) {
//            [[idoubs2AppDelegate getChatManager] SendLinkWithLink:currentURL to:[idoubs2AppDelegate sharedInstance].videoService.contactObject.SeequID];
//        }
//    } else {
//        self.isInSession = NO;
//    }
//    
        [self SetBrowserButtons];
        self.webViewHeader.imageViewProgress.frame = CGRectMake(-260, 22, 0, 0);
        [self.webViewHeader setRightViewState:RightViewState_Reload];
        
        UIButton *button = (UIButton*)self.webViewHeader.textFieldUrl.rightView;
        UIImage *image = [UIImage imageNamed:@"SeequButtonWebReload.png"];
        [button setImage:image forState:UIControlStateNormal];
   // button.frame = CGRectMake(0, 0, 24, 24);
        
        _loadingCount--;
        [self incrementProgress];
        
        NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
        
        BOOL interactive = [readyState isEqualToString:@"interactive"];
        if (interactive) {
            _interactive = YES;
            NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@'; document.body.appendChild(iframe);  }, false);", completeRPCURL];
            [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
        }
        
        BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
        BOOL complete = [readyState isEqualToString:@"complete"];
        if (complete && isNotRedirect) {
            [self completeProgress];
        }
        
        
        if(!IsFinishedOrFaild){
            
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(self.webViewHeader.frame.size.height, 0.0f, 20, 0.0f);
            IsFinishedOrFaild = YES;
            NSString *script = @"scrollTo(0, 0)";
            [webView stringByEvaluatingJavaScriptFromString:script];
            
        }
        if( isGoBackOrForwardPressed){
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0.0f);
        }
        isGoBackOrForwardPressed = NO;
        
    }
}

- (void) webViewDidFailLoadLink:(UIWebView*)web {
    @synchronized(self){
    isLoading = NO;
    isInLoading = NO;
    [self SetBrowserButtons];
    NSString *currentURL = web.request.URL.absoluteString;
    [self.webViewHeader setURL:currentURL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    //    if (!self.tabBarController.modalViewController) {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
    //                                                        message:@"Seequ can't open the page."
    //                                                       delegate:nil
    //                                              cancelButtonTitle:@"OK"
    //                                              otherButtonTitles:nil];
    //        [alert show];
    //    }
    
    
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"seequweberrorpage" ofType:@"html"];
    //    NSString *html_string = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //
    //    NSURL *baseURL = [NSURL fileURLWithPath:path];
    //    [self.webView loadHTMLString:html_string baseURL:baseURL];
//        NSLog(@"[BROWSER][WEB] {webViewDidFailLoadLink}");
        [self.webView stopLoading];
        [self  resignFirstResponder];
        _loadingCount--;
        [self incrementProgress];
        
        NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
        
        BOOL interactive = [readyState isEqualToString:@"interactive"];
        if (interactive) {
            _interactive = YES;
            NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@'; document.body.appendChild(iframe);  }, false);", completeRPCURL];
            [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
        }
        
        BOOL isNotRedirect = _currentURL && [_currentURL isEqual:webView.request.mainDocumentURL];
        BOOL complete = [readyState isEqualToString:@"complete"];
        if (complete && isNotRedirect) {
            [self completeProgress];
        }
        
        if(!IsFinishedOrFaild){
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(self.webViewHeader.frame.size.height, 0.0f, 20, 0.0f);
            IsFinishedOrFaild = YES;
            NSString *script = @"scrollTo(0, 0)";
            [webView stringByEvaluatingJavaScriptFromString:script];
            
        }
        if( isGoBackOrForwardPressed){
            self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0.0f);
            
        }
        isGoBackOrForwardPressed = NO;
    }
    
    
}

- (void) saveToHistoryWithTitle:(NSString*)title Link:(NSString*)link {
  
    if (!link || !link.length) {
        return;
    }
    
    if (!title || !title.length) {
        title = @"(no title)";
    }
    
    NSMutableDictionary *mDictHistory;
    NSDictionary *dictHistory = [[NSUserDefaults standardUserDefaults] objectForKey:HISTORY_KEY];
    NSTimeInterval current_time = [[NSDate date] timeIntervalSince1970];

    if (!dictHistory) {
        mDictHistory = [[NSMutableDictionary alloc] init];
    } else {
        mDictHistory = [[NSMutableDictionary alloc] initWithDictionary:dictHistory];
        
        if ([mDictHistory count] > SAVED_LINKS_COUNT_LIMIT) {
            NSTimeInterval last_time = current_time;
            NSString *key_for_remove = nil;
            for (NSString *key in mDictHistory) {
                NSDictionary *dict = [mDictHistory objectForKey:key];
                NSTimeInterval time = [[dict objectForKey:@"time"] doubleValue];
                
                if (last_time > time) {
                    last_time = time;
                    key_for_remove = key;
                }
            }
            
            if (key_for_remove) {
                [mDictHistory removeObjectForKey:key_for_remove];
               
            }
        }
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:title, @"title",
                          link, @"link",
                          [NSNumber numberWithDouble:current_time], @"time", nil];
    NSArray* urlWithoutHttpArry = [link componentsSeparatedByString:@"://"];
    NSString* urlWithoutHttp;
    NSString*urlWithoutWww;
    NSArray* urlWithoutWwwArray;
    if([urlWithoutHttpArry count] >= 2){
        urlWithoutHttp = urlWithoutHttpArry[1];
    }
    if ([urlWithoutHttp rangeOfString:@"www."].location == NSNotFound){
        urlWithoutWww = urlWithoutHttp;
    }else{
        urlWithoutWwwArray = [urlWithoutHttp componentsSeparatedByString:@"w."];
        if([urlWithoutWwwArray count] >= 2){
            urlWithoutWww = urlWithoutWwwArray[1];
        }
    }

    int day = (int)current_time/86400.0;
    
    NSString *key = [NSString stringWithFormat:@"%d%@", day, urlWithoutWww];
    [mDictHistory setObject:dict forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:mDictHistory forKey:HISTORY_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"[BROWSER][History][ADD] URL - %@", link);
    mDictHistory = nil;
    dictHistory = nil;
    
    
}


- (void) didSelectHistoryItem:(SeequBrowserHistoryViewController*)history withDictionary:(NSDictionary*)dict {
    [history dismissViewControllerAnimated:YES completion:nil];
    [webView stopLoading];
    
    NSString *link = [dict objectForKey:@"link"];
    if (!link) {
        link = [dict objectForKey:@"url"];
    }
    NSString *title = [dict objectForKey:@"title"];

    [self.webViewHeader setTitle:title];
    [self.webViewHeader setURL:link];
    urlForReload = link;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    [self LoadUrlString:link];
}

- (void) AddWebViewToScrollView:(SeequWebView*)web {
    for (int i = 0; i < arrayWebViews.count; i++) {
        SeequWebView *sweb = [arrayWebViews objectAtIndex:i];
        if (sweb == self.webView) {
            [arrayWebViews insertObject:web atIndex:(i+1)];
            web.frame = CGRectMake((i+1)*320, self.webView.frame.origin.y, self.webView.frame.size.width, self.webView.frame.size.height);
            
            break;
        }
    }
}
- (void)startProgress
{
    if (_progress < initialProgressValue) {
        [self setProgress:initialProgressValue];
    }
    
}
- (void)incrementProgress
{
    float progress = self.progress;
    float maxProgress = _interactive ? afterInteractiveMaxProgressValue : beforeInteractiveMaxProgressValue;
    float remainPercent = (float)_loadingCount / (float)_maxLoadCount;
    float increment = (maxProgress - progress) * remainPercent;
    progress += increment;
    progress = fmin(progress, maxProgress);
    [self setProgress:progress];

}
- (void)completeProgress
{
    [self setProgress:1.0];

}

- (void)setProgress:(float)progress
{
    // progress should be incremental only
    if (progress > _progress || progress == 0) {
        _progress = progress;
        [_progressView setProgress:progress animated:YES];
        if (_progressBlock) {
            _progressBlock(progress);
        }
    }
}
- (void)reset
{
    _maxLoadCount = _loadingCount = 0;
    _interactive = NO;
    [self setProgress:0.0];
}
@end
