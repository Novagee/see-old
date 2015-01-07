//
//  SeequWebView.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 11/30/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//
#import "idoubs2AppDelegate.h"
#import "SeequWebView.h"

@interface UIWebView ()
-(id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource;
-(void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource;
-(void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource;

@end

static BOOL first = NO;

@implementation SeequWebView

@synthesize seequDelegate = _delegate;
@synthesize resourceCount;
@synthesize resourceCompletedCount;
@synthesize headerView;
@synthesize pinHeader = _pinHeader;

- (id)initWithFrame:(CGRect)newFrame header:(UIView *)header {
    if(self = [super init]) {
        
       // self.frame = newFrame;
        self.scalesPageToFit = YES;        
        self.headerView = header;
        
        [self.scrollView setDelegate:self];
        
        //self.scrollView.contentInset = UIEdgeInsetsMake(self.headerView.frame.size.height, 0.0f, 0.0f, 0.0f);
        self.scrollView.contentInset = UIEdgeInsetsMake(self.headerView.frame.size.height, 0.0f, 20.0f, 0.0f);
        self.headerView.frame = CGRectMake(0, 0, self.headerView.frame.size.width, -self.headerView.frame.size.height);
        self.frame = newFrame;
        
        
        [self.scrollView addSubview:self.headerView];

        // Initialization code
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Search in seequ" action:@selector(menuItemSearchInSeequ:)];
        
        [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
    }
    
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self.scrollView setZoomScale:1];
}

- (void)setPinHeader:(BOOL)newValue {
    return;
    float numberOfPointsOfHeaderVisible = MAX(0, -self.scrollView.contentOffset.y);
        if (newValue == YES) {
            // if the header is only partially visible or not at all, we need to animate it into place right away
            if (numberOfPointsOfHeaderVisible < self.headerView.frame.size.height) {
                [UIView animateWithDuration:0.2 animations:^ {
                    CGRect headerFrame = self.headerView.frame;
                    headerFrame.origin.y = MAX(-self.headerView.frame.size.height, self.scrollView.contentOffset.y);
                    self.headerView.frame = headerFrame;
                    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(MAX(self.headerView.frame.size.height, -self.scrollView.contentOffset.y), 0, 0, 0);
                }];
            }
        }
        
        // pinHeader == NO, move back to original position, reset scroll indicator positions
        else {
            [UIView animateWithDuration:0.2 animations:^ {
                self.headerView.frame = CGRectMake(self.headerView.frame.origin.x, 0, self.headerView.frame.size.width, -self.headerView.frame.size.height);
                float bottomOfHeaderView = MAX(0, -self.scrollView.contentOffset.y);
                self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(bottomOfHeaderView, 0, 0, 0);
            }];
        }
        
        _pinHeader = newValue;

 
}

- (BOOL)pinHeader {
    return _pinHeader;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [super scrollViewDidScroll:scrollView];
    
    if (txtField.isEditing) {
        [txtField resignFirstResponder];
        CGRect frameOfAddressBar = CGRectMake(0, -self.headerView.frame.size.height, self.frame.size.width, self.headerView.frame.size.height);
        
        self.scrollView.contentInset = UIEdgeInsetsMake(frameOfAddressBar.size.height, 0, 0, 0);
        [self.scrollView setContentOffset:CGPointMake(0, frameOfAddressBar.origin.y) animated:NO];
    }

    dispatch_async(dispatch_get_main_queue(), ^{


        
        CGRect headerFrame = self.headerView.frame;
        if(([idoubs2AppDelegate sharedInstance].videoService.showVideoView.videoViewState==VideoViewState_TAB ||
           [idoubs2AppDelegate sharedInstance].videoService.showVideoView.videoViewState==VideoViewState_TAB_MENU)&& UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
            headerFrame.origin.x = scrollView.contentOffset.x+SMALL_VIDEO_HEIGHT;
        }else{
            headerFrame.origin.x = scrollView.contentOffset.x;
        }
        
        self.headerView.frame = headerFrame;
        
        
        if (scrollView.contentOffset.y < 0) {
            
            UIEdgeInsets insects = scrollView.scrollIndicatorInsets;
            
            insects.top = -scrollView.contentOffset.y;
            
            scrollView.scrollIndicatorInsets = insects;
            
        }
        
        
       
    });
    
    if (first) {
        
        if(0 > self.scrollView.contentOffset.y && self.scrollView.contentOffset.y > - self.headerView.frame.size.height){
            self.scrollView.contentInset = UIEdgeInsetsMake(-self.scrollView.contentOffset.y, 0, 20, 0.0f);
        }
        if(self.scrollView.contentOffset.y > 0){
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0.0f);
        }
        if(scrollView.contentOffset.y < - self.headerView.frame.size.height){
            
            
            self.scrollView.contentInset = UIEdgeInsetsMake(self.headerView.frame.size.height, 0.0f, 20, 0.0f);
        }
        
        
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;{
    first = YES;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [super scrollViewDidZoom:scrollView];

//    [self setPinHeader:YES];

    CGRect visibleRect;
    visibleRect.origin = scrollView.contentOffset;
    visibleRect.size = scrollView.bounds.size;
        self.headerView.frame = CGRectMake(visibleRect.origin.x + (scrollView.frame.size.width - self.headerView.frame.size.width)/2,
                                           -self.headerView.frame.origin.y, self.headerView.frame.size.width, -self.headerView.frame.size.height);
        
        // anchor the header at the top of the screen
        if (_pinHeader) {
            CGRect headerFrame = self.headerView.frame;
            headerFrame.origin.y = MAX(-self.headerView.frame.size.height, scrollView.contentOffset.y);
            self.headerView.frame = headerFrame;
            self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(MAX(self.headerView.frame.size.height, -scrollView.contentOffset.y), 0, 0, 0);
        }
        
        self.headerView.frame = CGRectMake(self.scrollView.contentOffset.x, self.headerView.frame.origin.y, self.headerView.frame.size.width, self.headerView.frame.size.height);

   
    
}

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(menuItemSearchInSeequ:) ||
        action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (void) menuItemSearchInSeequ:(id)sender {
    
    // The JS File
    NSString *filePath  = [[NSBundle mainBundle] pathForResource:@"HighlightedString" ofType:@"js" inDirectory:@""];
    NSData *fileData    = [NSData dataWithContentsOfFile:filePath];
    NSString *jsString  = [[NSMutableString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    [self stringByEvaluatingJavaScriptFromString:jsString];
    
    // The JS Function
    NSString *startSearch   = [NSString stringWithFormat:@"getHighlightedString()"];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
    
    NSString *selectedText   = [NSString stringWithFormat:@"selectedText"];
    NSString * highlightedString = [self stringByEvaluatingJavaScriptFromString:selectedText];
    
    if ([_delegate respondsToSelector:@selector(didClickOnSearchInSeequ:withText:)]) {
        [_delegate didClickOnSearchInSeequ:self withText:highlightedString];
    }    
}

-(id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource {
    [super webView:view identifierForInitialRequest:initialRequest fromDataSource:dataSource];
    return [NSNumber numberWithInt:resourceCount++];
}

- (void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource {
    [super webView:view resource:resource didFailLoadingWithError:error fromDataSource:dataSource];
    resourceCompletedCount++;
    if ([_delegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)]) {
        [_delegate webView:self didReceiveResourceNumber:resourceCompletedCount totalResources:resourceCount];
    }
}

-(void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource {
    [super webView:view resource:resource didFinishLoadingFromDataSource:dataSource];
    resourceCompletedCount++;
    if ([_delegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)]) {
        [_delegate webView:self didReceiveResourceNumber:resourceCompletedCount totalResources:resourceCount];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    txtField = textField;
    
    CGRect frameOfAddressBar = CGRectMake(0, -self.headerView.frame.size.height, self.frame.size.width, self.headerView.frame.size.height);
    
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.scrollView setContentOffset:CGPointMake(0, frameOfAddressBar.origin.y) animated:NO];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    txtField = textField;

    CGRect frameOfAddressBar = CGRectMake(0, -self.headerView.frame.size.height, self.frame.size.width, self.headerView.frame.size.height);
    
    self.scrollView.contentInset = UIEdgeInsetsMake(frameOfAddressBar.size.height, 0, 0, 0);
    [self.scrollView setContentOffset:CGPointMake(0, frameOfAddressBar.origin.y) animated:NO];
    
    return YES;
}

+ (void) setFirst:(BOOL)value{
    first = value;
}

@end