//
//  SeequWebViewHeader.m
//  ProTime
//
//  Created by Norayr on 03/21/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import "SeequWebViewHeader.h"
#import "idoubs2AppDelegate.h"

#define mainScreenHeight [[UIScreen mainScreen] bounds].size.height
#define SMALL_VIDEO_WIDTH 117
#define SMALL_VIDEO_HEIGHT 82
#define widthg_diff 4



@interface SeequWebViewHeader (Private)
- (void) beginURLAnimationForPortrait:(BOOL)animate;
- (void) endURLAnimationForPortrait:(BOOL)animate;

- (void) beginSearchAnimationForPortrait:(BOOL)animate;
- (void) endSearchAnimationForPortrait:(BOOL)animate;

- (void) beginURLAnimationForLandscape:(BOOL)animate;
- (void) endURLAnimationForLandscape:(BOOL)animate;

- (void) beginSearchAnimationForLandscape:(BOOL)animate;
- (void) endSearchAnimationForLandscape:(BOOL)animate;

- (void) beginVideoAnimationForLandscape:(BOOL)animate;
- (void) endVideoAnimationForLandscape:(BOOL)animate;
@end

@implementation SeequWebViewHeader (Private)

- (void) beginURLAnimationForPortrait:(BOOL)animate {
    NSLog(@"beginURLAnimationForPortrait");
    @synchronized(self) {
    
    self.buttonVideo.frame = CGRectMake(320, self.buttonVideo.frame.origin.y, self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, 0, 320 - self.imageViewWebHeaderUrl3.frame.origin.x, self.imageViewWebHeaderBlackLine.frame.size.height);
    self.frame = CGRectMake(0, self.frame.origin.y, 320, self.frame.size.height);
    
    if (animate) {
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.2];
    }
    
    self.imageViewWebHeaderUrl2.frame = CGRectMake(self.imageViewWebHeaderUrl1.frame.origin.x + self.imageViewWebHeaderUrl1.frame.size.width, self.imageViewWebHeaderUrl2.frame.origin.y,
                                                   165, self.imageViewWebHeaderUrl2.frame.size.height);
    self.imageViewWebHeaderUrl3.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x + self.imageViewWebHeaderUrl2.frame.size.width, self.imageViewWebHeaderUrl3.frame.origin.y,
                                                   self.imageViewWebHeaderUrl3.frame.size.width, self.imageViewWebHeaderUrl3.frame.size.height);
    self.textFieldUrl.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x - 10, self.textFieldUrl.frame.origin.y, self.imageViewWebHeaderUrl2.frame.size.width + 50 - widthg_diff, self.textFieldUrl.frame.size.height);
    
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, 0, 320 - self.imageViewWebHeaderUrl3.frame.origin.x, self.imageViewWebHeaderBlackLine.frame.size.height);
    
    self.imageViewWebHeaderSearch1.alpha = 0.0;
    self.imageViewWebHeaderSearch2.alpha = 0.0;
    self.imageViewWebHeaderSearch3.alpha = 0.0;
    
    self.textFieldSearch.alpha = 0.0;
    
    self.buttonCancel.frame = CGRectMake(320 - self.buttonCancel.frame.size.width - 5, self.buttonCancel.frame.origin.y, self.buttonCancel.frame.size.width, self.buttonCancel.frame.size.height);
        self.buttonCancel.tag = 1111;
    if (animate) {
        [UIView commitAnimations];
    }
    }
}

- (void) endURLAnimationForPortrait:(BOOL)animate {
    NSLog(@"endURLAnimationForPortrait");
    self.buttonVideo.frame = CGRectMake(320, self.buttonVideo.frame.origin.y, self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, 0, 320 - self.imageViewWebHeaderUrl3.frame.origin.x, self.imageViewWebHeaderBlackLine.frame.size.height);
    self.frame = CGRectMake(0, self.frame.origin.y, 320, self.frame.size.height);

    if (animate) {
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.2];
    }
    
    self.imageViewWebHeaderUrl2.frame = CGRectMake(self.imageViewWebHeaderUrl1.frame.origin.x + self.imageViewWebHeaderUrl1.frame.size.width, self.imageViewWebHeaderUrl2.frame.origin.y,
                                                   125, self.imageViewWebHeaderUrl2.frame.size.height);
    self.imageViewWebHeaderUrl3.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x + self.imageViewWebHeaderUrl2.frame.size.width, self.imageViewWebHeaderUrl3.frame.origin.y,
                                                   self.imageViewWebHeaderUrl3.frame.size.width, self.imageViewWebHeaderUrl3.frame.size.height);
    self.textFieldUrl.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x - 10, self.textFieldUrl.frame.origin.y, self.imageViewWebHeaderUrl2.frame.size.width + 50 - widthg_diff, self.textFieldUrl.frame.size.height);
    
    self.imageViewWebHeaderSearch1.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, self.imageViewWebHeaderSearch1.frame.origin.y,
                                                      self.imageViewWebHeaderSearch1.frame.size.width, self.imageViewWebHeaderSearch1.frame.size.height);
    self.imageViewWebHeaderSearch2.frame = CGRectMake(self.imageViewWebHeaderSearch1.frame.origin.x + self.imageViewWebHeaderSearch1.frame.size.width, self.imageViewWebHeaderSearch1.frame.origin.y,
                                                      55, self.imageViewWebHeaderSearch2.frame.size.height);
    self.imageViewWebHeaderSearch3.frame = CGRectMake(self.imageViewWebHeaderSearch2.frame.origin.x + self.imageViewWebHeaderSearch2.frame.size.width, self.imageViewWebHeaderSearch3.frame.origin.y,
                                                      self.imageViewWebHeaderSearch3.frame.size.width, self.imageViewWebHeaderSearch3.frame.size.height);
    self.textFieldSearch.frame = CGRectMake(self.imageViewWebHeaderSearch2.frame.origin.x - 10, self.textFieldSearch.frame.origin.y, self.imageViewWebHeaderSearch2.frame.size.width + 20, self.textFieldSearch.frame.size.height);
    
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, 0, 320 - self.imageViewWebHeaderUrl3.frame.origin.x, self.imageViewWebHeaderBlackLine.frame.size.height);
    
    self.imageViewWebHeaderSearch1.alpha = 1.0;
    self.imageViewWebHeaderSearch2.alpha = 1.0;
    self.imageViewWebHeaderSearch3.alpha = 1.0;
    
    self.textFieldSearch.alpha = 1.0;
    
    self.buttonCancel.frame = CGRectMake(320, self.buttonCancel.frame.origin.y, self.buttonCancel.frame.size.width, self.buttonCancel.frame.size.height);
    
    if (animate) {
        [UIView commitAnimations];
    }
}

- (void) beginSearchAnimationForPortrait:(BOOL)animate {
    NSLog(@"beginSearchAnimationForPortrait");
        self.buttonVideo.frame = CGRectMake(320, self.buttonVideo.frame.origin.y, self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    self.frame = CGRectMake(0, self.frame.origin.y, 320, self.frame.size.height);

    if (animate) {
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(beginSearchAnimationFinished)];
        [UIView setAnimationDuration:0.2];
    } else {
        [self beginSearchAnimationFinished];
    }
    
    self.imageViewWebHeaderUrl1.frame = CGRectMake(self.imageViewWebHeaderUrl1.frame.origin.x - self.imageViewWebHeaderSearch1.frame.origin.x, self.imageViewWebHeaderUrl1.frame.origin.y,
                                                   self.imageViewWebHeaderUrl1.frame.size.width, self.imageViewWebHeaderUrl1.frame.size.height);
    self.imageViewWebHeaderUrl2.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x - self.imageViewWebHeaderSearch1.frame.origin.x, self.imageViewWebHeaderUrl2.frame.origin.y,
                                                   self.imageViewWebHeaderUrl2.frame.size.width, self.imageViewWebHeaderUrl2.frame.size.height);
    self.imageViewWebHeaderUrl3.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x - self.imageViewWebHeaderSearch1.frame.origin.x, self.imageViewWebHeaderUrl3.frame.origin.y,
                                                   self.imageViewWebHeaderUrl3.frame.size.width, self.imageViewWebHeaderUrl3.frame.size.height);
    self.textFieldUrl.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x - 20, self.textFieldUrl.frame.origin.y, self.textFieldUrl.frame.size.width, self.textFieldUrl.frame.size.height);
    
    self.imageViewWebHeaderSearch1.frame = CGRectMake(0, self.imageViewWebHeaderSearch1.frame.origin.y, self.imageViewWebHeaderSearch1.frame.size.width, self.imageViewWebHeaderSearch1.frame.size.height);
    self.imageViewWebHeaderSearch2.frame = CGRectMake(self.imageViewWebHeaderSearch1.frame.size.width, self.imageViewWebHeaderSearch1.frame.origin.y, 200, self.imageViewWebHeaderSearch2.frame.size.height);
    self.imageViewWebHeaderSearch3.frame = CGRectMake(self.imageViewWebHeaderSearch2.frame.origin.x + self.imageViewWebHeaderSearch2.frame.size.width, self.imageViewWebHeaderSearch3.frame.origin.y,
                                                      self.imageViewWebHeaderSearch3.frame.size.width, self.imageViewWebHeaderSearch3.frame.size.height);
    
    self.textFieldSearch.frame = CGRectMake(self.imageViewWebHeaderSearch2.frame.origin.x - 10, self.textFieldSearch.frame.origin.y, self.imageViewWebHeaderSearch2.frame.size.width + 25, self.textFieldSearch.frame.size.height);
    
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderSearch3.frame.origin.x + self.imageViewWebHeaderSearch3.frame.size.width, self.imageViewWebHeaderBlackLine.frame.origin.y,
                                                        320 - (self.imageViewWebHeaderSearch3.frame.origin.x + self.imageViewWebHeaderSearch3.frame.size.width), self.imageViewWebHeaderBlackLine.frame.size.height);
    
    self.buttonCancel.frame = CGRectMake(320 - self.buttonCancel.frame.size.width - 5, self.buttonCancel.frame.origin.y, self.buttonCancel.frame.size.width, self.buttonCancel.frame.size.height);
    
    if (animate) {
        [UIView commitAnimations];
    }
}

- (void) endSearchAnimationForPortrait:(BOOL)animate {
    NSLog(@"endSearchAnimationForPortrait");
    
    self.buttonVideo.frame = CGRectMake(320, self.buttonVideo.frame.origin.y, self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    self.frame = CGRectMake(0, self.frame.origin.y, 320, self.frame.size.height);

    if (animate) {
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(endSearchAnimationFinished)];
        [UIView setAnimationDuration:0.2];
    } else {
        [self endSearchAnimationFinished];
    }
    
    self.imageViewWebHeaderUrl1.frame = CGRectMake(0, self.imageViewWebHeaderUrl1.frame.origin.y, self.imageViewWebHeaderUrl1.frame.size.width, self.imageViewWebHeaderUrl1.frame.size.height);
    self.imageViewWebHeaderUrl2.frame = CGRectMake(self.imageViewWebHeaderUrl1.frame.origin.x + self.imageViewWebHeaderUrl1.frame.size.width, self.imageViewWebHeaderUrl2.frame.origin.y,
                                                   125, self.imageViewWebHeaderUrl2.frame.size.height);
    self.imageViewWebHeaderUrl3.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x + self.imageViewWebHeaderUrl2.frame.size.width, self.imageViewWebHeaderUrl3.frame.origin.y,
                                                   self.imageViewWebHeaderUrl3.frame.size.width, self.imageViewWebHeaderUrl3.frame.size.height);
    self.textFieldUrl.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x - 10, self.textFieldUrl.frame.origin.y, self.imageViewWebHeaderUrl2.frame.size.width + 50 - widthg_diff, self.textFieldUrl.frame.size.height);
    
    self.imageViewWebHeaderSearch1.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, self.imageViewWebHeaderSearch1.frame.origin.y,
                                                      self.imageViewWebHeaderSearch1.frame.size.width, self.imageViewWebHeaderSearch1.frame.size.height);
    self.imageViewWebHeaderSearch2.frame = CGRectMake(self.imageViewWebHeaderSearch1.frame.origin.x + self.imageViewWebHeaderSearch1.frame.size.width, self.imageViewWebHeaderSearch1.frame.origin.y,
                                                      55, self.imageViewWebHeaderSearch2.frame.size.height);
    self.imageViewWebHeaderSearch3.frame = CGRectMake(self.imageViewWebHeaderSearch2.frame.origin.x + self.imageViewWebHeaderSearch2.frame.size.width, self.imageViewWebHeaderSearch3.frame.origin.y,
                                                      self.imageViewWebHeaderSearch3.frame.size.width, self.imageViewWebHeaderSearch3.frame.size.height);
    self.textFieldSearch.frame = CGRectMake(self.imageViewWebHeaderSearch2.frame.origin.x - 10, self.textFieldSearch.frame.origin.y, self.imageViewWebHeaderSearch2.frame.size.width + 20, self.textFieldSearch.frame.size.height);
    
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(320, self.imageViewWebHeaderBlackLine.frame.origin.y, self.imageViewWebHeaderBlackLine.frame.size.width, self.imageViewWebHeaderBlackLine.frame.size.height);
    
    self.buttonCancel.frame = CGRectMake(320, self.buttonCancel.frame.origin.y, self.buttonCancel.frame.size.width, self.buttonCancel.frame.size.height);
    
    if (animate) {
        [UIView commitAnimations];
    }
    
//    [self.textFieldSearch resignFirstResponder];
}

- (void) beginURLAnimationForLandscape:(BOOL)animate {
    NSLog(@"beginURLAnimationForLandscape");
    
    self.buttonVideo.frame = CGRectMake(mainScreenHeight, self.buttonVideo.frame.origin.y, self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, 0, mainScreenHeight - self.imageViewWebHeaderUrl3.frame.origin.x, self.imageViewWebHeaderBlackLine.frame.size.height);
    if (callState == WebViewHeaderCallState_Audio || callState == WebViewHeaderCallState_Video) {
        self.buttonVideo.frame = CGRectMake(mainScreenHeight - self.buttonVideo.frame.size.width,
                                            self.buttonVideo.frame.origin.y,
                                            self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    } else {
        if (callState == WebViewHeaderCallState_CallMenu) {
            self.buttonVideo.frame = CGRectMake(mainScreenHeight - SMALL_VIDEO_HEIGHT*2 - self.buttonVideo.frame.size.width,
                                                self.buttonVideo.frame.origin.y,
                                                self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
            self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, 0,
                                                                mainScreenHeight - SMALL_VIDEO_HEIGHT*2 - self.imageViewWebHeaderUrl3.frame.origin.x - self.imageViewWebHeaderUrl3.frame.size.width,
                                                                self.imageViewWebHeaderBlackLine.frame.size.height);
        }
    }

    if (animate) {
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.2];
    }
    
    int urlFieldWidth = mainScreenHeight - 215;
    
    if (callState == WebViewHeaderCallState_None) {
        urlFieldWidth = mainScreenHeight - 155;
        self.buttonCancel.frame = CGRectMake(mainScreenHeight - self.buttonCancel.frame.size.width - 5, self.buttonCancel.frame.origin.y, self.buttonCancel.frame.size.width, self.buttonCancel.frame.size.height);
    } else {
        if (callState == WebViewHeaderCallState_CallMenu) {
            self.frame = CGRectMake(SMALL_VIDEO_HEIGHT, self.frame.origin.y, mainScreenHeight - SMALL_VIDEO_HEIGHT*2, self.frame.size.height);
            urlFieldWidth = urlFieldWidth - SMALL_VIDEO_HEIGHT - 20;
        } else {
            self.buttonCancel.frame = CGRectMake(mainScreenHeight - self.buttonCancel.frame.size.width - 5 - self.buttonVideo.frame.size.width,
                                                 self.buttonCancel.frame.origin.y,
                                                 self.buttonCancel.frame.size.width, self.buttonCancel.frame.size.height);
        }
    }
    
    self.imageViewWebHeaderUrl2.frame = CGRectMake(self.imageViewWebHeaderUrl1.frame.origin.x + self.imageViewWebHeaderUrl1.frame.size.width,
                                                   self.imageViewWebHeaderUrl2.frame.origin.y,
                                                   urlFieldWidth, self.imageViewWebHeaderUrl2.frame.size.height);
    
//    self.imageViewWebHeaderUrl2.frame = CGRectMake(self.imageViewWebHeaderUrl1.frame.origin.x + self.imageViewWebHeaderUrl1.frame.size.width,
//                                                   self.imageViewWebHeaderUrl2.frame.origin.y,
//                                                   mainScreenHeight - 170, self.imageViewWebHeaderUrl2.frame.size.height);

    self.imageViewWebHeaderUrl3.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x + self.imageViewWebHeaderUrl2.frame.size.width,
                                                   self.imageViewWebHeaderUrl3.frame.origin.y,
                                                   self.imageViewWebHeaderUrl3.frame.size.width, self.imageViewWebHeaderUrl3.frame.size.height);
    
    self.textFieldUrl.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x - 10,
                                         self.textFieldUrl.frame.origin.y
                                         , self.imageViewWebHeaderUrl2.frame.size.width + 50 - widthg_diff, self.textFieldUrl.frame.size.height);
   
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width,
                                                        0, mainScreenHeight- self.imageViewWebHeaderUrl3.frame.origin.x - self.imageViewWebHeaderUrl3.frame.size.width,
                                                        self.imageViewWebHeaderBlackLine.frame.size.height);
    
    self.imageViewWebHeaderSearch1.alpha = 0.0;
    self.imageViewWebHeaderSearch2.alpha = 0.0;
    self.imageViewWebHeaderSearch3.alpha = 0.0;
    
    self.textFieldSearch.alpha = 0.0;
    
    if (animate) {
        [UIView commitAnimations];
    }
}

- (void) endURLAnimationForLandscape:(BOOL)animate {
    NSLog(@"endURLAnimationForLandscape");
    
    self.buttonVideo.frame = CGRectMake(mainScreenHeight, self.buttonVideo.frame.origin.y, self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, 0, mainScreenHeight - self.imageViewWebHeaderUrl3.frame.origin.x, self.imageViewWebHeaderBlackLine.frame.size.height);
    
    if (callState == WebViewHeaderCallState_Audio || callState == WebViewHeaderCallState_Video) {
        self.frame = CGRectMake(0, self.frame.origin.y, mainScreenHeight, self.frame.size.height);
        self.buttonVideo.frame = CGRectMake(mainScreenHeight - self.buttonVideo.frame.size.width,
                                            self.buttonVideo.frame.origin.y,
                                            self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    } else {
        if (callState == WebViewHeaderCallState_CallMenu) {
            self.buttonVideo.frame = CGRectMake(mainScreenHeight - SMALL_VIDEO_HEIGHT*2 - self.buttonVideo.frame.size.width,
                                                self.buttonVideo.frame.origin.y,
                                                self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
            self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, 0,
                                                                mainScreenHeight - SMALL_VIDEO_HEIGHT*2 - self.imageViewWebHeaderUrl3.frame.origin.x - self.imageViewWebHeaderUrl3.frame.size.width,
                                                                self.imageViewWebHeaderBlackLine.frame.size.height);
            self.imageViewWebHeaderSearch1.alpha = 0.0;
            self.imageViewWebHeaderSearch2.alpha = 0.0;
            self.imageViewWebHeaderSearch3.alpha = 0.0;
            
            self.textFieldSearch.alpha = 0.0;
        } else {
            self.frame = CGRectMake(0, self.frame.origin.y, mainScreenHeight, self.frame.size.height);
        }
    }
    
    if (animate) {
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.2];
    }
    
    int urlFieldWidth = mainScreenHeight - 300;
    
    if (callState == WebViewHeaderCallState_None) {
        urlFieldWidth = mainScreenHeight - 240;
    } else {
        if (callState == WebViewHeaderCallState_CallMenu) {
            self.frame = CGRectMake(SMALL_VIDEO_HEIGHT, self.frame.origin.y, mainScreenHeight - SMALL_VIDEO_HEIGHT*2, self.frame.size.height);
//            self.labelTitle.frame = CGRectMake(self.labelTitle.frame.origin.x, self.labelTitle.frame.origin.y, self.frame.size.width - self.buttonVideo.frame.size.width, self.labelTitle.frame.size.height);
            urlFieldWidth = self.frame.size.width - 90 - self.buttonVideo.frame.size.width - 3;
        } else {
            self.buttonCancel.frame = CGRectMake(mainScreenHeight - self.buttonCancel.frame.size.width - 5 - self.buttonVideo.frame.size.width,
                                                 self.buttonCancel.frame.origin.y,
                                                 self.buttonCancel.frame.size.width, self.buttonCancel.frame.size.height);
        }
    }

    self.imageViewWebHeaderUrl2.frame = CGRectMake(self.imageViewWebHeaderUrl1.frame.origin.x + self.imageViewWebHeaderUrl1.frame.size.width,
                                                   self.imageViewWebHeaderUrl2.frame.origin.y,
                                                   urlFieldWidth, self.imageViewWebHeaderUrl2.frame.size.height);
    
    self.imageViewWebHeaderUrl3.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x + self.imageViewWebHeaderUrl2.frame.size.width,
                                                   self.imageViewWebHeaderUrl3.frame.origin.y,
                                                   self.imageViewWebHeaderUrl3.frame.size.width, self.imageViewWebHeaderUrl3.frame.size.height);
    
    self.textFieldUrl.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x - 10,
                                         self.textFieldUrl.frame.origin.y,
                                         self.imageViewWebHeaderUrl2.frame.size.width + 50 - widthg_diff, self.textFieldUrl.frame.size.height);
    
    self.imageViewWebHeaderSearch1.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, self.imageViewWebHeaderSearch1.frame.origin.y,
                                                      self.imageViewWebHeaderSearch1.frame.size.width, self.imageViewWebHeaderSearch1.frame.size.height);
    self.imageViewWebHeaderSearch2.frame = CGRectMake(self.imageViewWebHeaderSearch1.frame.origin.x + self.imageViewWebHeaderSearch1.frame.size.width, self.imageViewWebHeaderSearch1.frame.origin.y,
                                                      100, self.imageViewWebHeaderSearch2.frame.size.height);
    self.imageViewWebHeaderSearch3.frame = CGRectMake(self.imageViewWebHeaderSearch2.frame.origin.x + self.imageViewWebHeaderSearch2.frame.size.width, self.imageViewWebHeaderSearch3.frame.origin.y,
                                                      self.imageViewWebHeaderSearch3.frame.size.width, self.imageViewWebHeaderSearch3.frame.size.height);
    self.textFieldSearch.frame = CGRectMake(self.imageViewWebHeaderSearch2.frame.origin.x - 10, self.textFieldSearch.frame.origin.y, self.imageViewWebHeaderSearch2.frame.size.width + 20, self.textFieldSearch.frame.size.height);
    
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width,
                                                        0, self.frame.size.width - self.imageViewWebHeaderUrl3.frame.origin.x - self.imageViewWebHeaderUrl3.frame.size.width,
                                                        self.imageViewWebHeaderBlackLine.frame.size.height);
    
    if (callState != WebViewHeaderCallState_CallMenu) {
        self.imageViewWebHeaderSearch1.alpha = 1.0;
        self.imageViewWebHeaderSearch2.alpha = 1.0;
        self.imageViewWebHeaderSearch3.alpha = 1.0;
        
        self.textFieldSearch.alpha = 1.0;
    }
    
    self.buttonCancel.frame = CGRectMake(mainScreenHeight, self.buttonCancel.frame.origin.y, self.buttonCancel.frame.size.width, self.buttonCancel.frame.size.height);
    
    if (animate) {
        [UIView commitAnimations];
    }
}

- (void) beginSearchAnimationForLandscape:(BOOL)animate {
    NSLog(@"beginSearchAnimationForLandscape");
    
    self.buttonVideo.frame = CGRectMake(mainScreenHeight, self.buttonVideo.frame.origin.y, self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    if (callState != WebViewHeaderCallState_None) {
        self.buttonVideo.frame = CGRectMake(mainScreenHeight - self.buttonVideo.frame.size.width,
                                            self.buttonVideo.frame.origin.y,
                                            self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    }

    if (animate) {
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(beginSearchAnimationFinished)];
        [UIView setAnimationDuration:0.2];
    } else {
        [self beginSearchAnimationFinished];
    }
    
    self.imageViewWebHeaderUrl1.frame = CGRectMake(self.imageViewWebHeaderUrl1.frame.origin.x - self.imageViewWebHeaderSearch1.frame.origin.x, self.imageViewWebHeaderUrl1.frame.origin.y,
                                                   self.imageViewWebHeaderUrl1.frame.size.width, self.imageViewWebHeaderUrl1.frame.size.height);
    self.imageViewWebHeaderUrl2.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x - self.imageViewWebHeaderSearch1.frame.origin.x, self.imageViewWebHeaderUrl2.frame.origin.y,
                                                   self.imageViewWebHeaderUrl2.frame.size.width, self.imageViewWebHeaderUrl2.frame.size.height);
    self.imageViewWebHeaderUrl3.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x - self.imageViewWebHeaderSearch1.frame.origin.x, self.imageViewWebHeaderUrl3.frame.origin.y,
                                                   self.imageViewWebHeaderUrl3.frame.size.width, self.imageViewWebHeaderUrl3.frame.size.height);
    self.textFieldUrl.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x - 20, self.textFieldUrl.frame.origin.y, self.textFieldUrl.frame.size.width, self.textFieldUrl.frame.size.height);
    
    int urlFieldWidth = mainScreenHeight - 180;
    
    if (callState == WebViewHeaderCallState_None) {
        urlFieldWidth = mainScreenHeight - 120;
        self.buttonCancel.frame = CGRectMake(mainScreenHeight - self.buttonCancel.frame.size.width - 5, self.buttonCancel.frame.origin.y, self.buttonCancel.frame.size.width, self.buttonCancel.frame.size.height);
    } else {
        self.buttonCancel.frame = CGRectMake(mainScreenHeight - self.buttonCancel.frame.size.width - 5 - self.buttonVideo.frame.size.width,
                                             self.buttonCancel.frame.origin.y,
                                             self.buttonCancel.frame.size.width, self.buttonCancel.frame.size.height);
        self.buttonVideo.frame = CGRectMake(mainScreenHeight - self.buttonVideo.frame.size.width,
                                            self.buttonVideo.frame.origin.y,
                                            self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    }
    
    self.imageViewWebHeaderSearch1.frame = CGRectMake(0, self.imageViewWebHeaderSearch1.frame.origin.y, self.imageViewWebHeaderSearch1.frame.size.width, self.imageViewWebHeaderSearch1.frame.size.height);
    self.imageViewWebHeaderSearch2.frame = CGRectMake(self.imageViewWebHeaderSearch1.frame.size.width, self.imageViewWebHeaderSearch1.frame.origin.y, urlFieldWidth, self.imageViewWebHeaderSearch2.frame.size.height);
    self.imageViewWebHeaderSearch3.frame = CGRectMake(self.imageViewWebHeaderSearch2.frame.origin.x + self.imageViewWebHeaderSearch2.frame.size.width, self.imageViewWebHeaderSearch3.frame.origin.y,
                                                      self.imageViewWebHeaderSearch3.frame.size.width, self.imageViewWebHeaderSearch3.frame.size.height);
    
    self.textFieldSearch.frame = CGRectMake(self.imageViewWebHeaderSearch2.frame.origin.x - 10,
                                            self.textFieldSearch.frame.origin.y,
                                            self.imageViewWebHeaderSearch2.frame.size.width + 25, self.textFieldSearch.frame.size.height);
    
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderSearch3.frame.origin.x + self.imageViewWebHeaderSearch3.frame.size.width,
                                                        self.imageViewWebHeaderBlackLine.frame.origin.y,
                                                        mainScreenHeight - (self.imageViewWebHeaderSearch3.frame.origin.x + self.imageViewWebHeaderSearch3.frame.size.width), self.imageViewWebHeaderBlackLine.frame.size.height);
    if (animate) {
        [UIView commitAnimations];
    }
}

- (void) endSearchAnimationForLandscape:(BOOL)animate {
    NSLog(@"endSearchAnimationForLandscape");
    
    if (callState != WebViewHeaderCallState_None) {
        self.buttonVideo.frame = CGRectMake(mainScreenHeight - self.buttonVideo.frame.size.width,
                                            self.buttonVideo.frame.origin.y,
                                            self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    } else {
        self.buttonVideo.frame = CGRectMake(mainScreenHeight,
                                            self.buttonVideo.frame.origin.y,
                                            self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    }

    if (animate) {
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(endSearchAnimationFinished)];
        [UIView setAnimationDuration:0.2];
    } else {
        [self endSearchAnimationFinished];
    }
    
    int urlFieldWidth = mainScreenHeight - 300;
    
    if (callState == WebViewHeaderCallState_None) {
        urlFieldWidth = mainScreenHeight - 240;
    } else {
        self.buttonVideo.frame = CGRectMake(mainScreenHeight - self.buttonVideo.frame.size.width,
                                            self.buttonVideo.frame.origin.y,
                                            self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    }
    
    self.imageViewWebHeaderUrl1.frame = CGRectMake(0, self.imageViewWebHeaderUrl1.frame.origin.y, self.imageViewWebHeaderUrl1.frame.size.width, self.imageViewWebHeaderUrl1.frame.size.height);
    self.imageViewWebHeaderUrl2.frame = CGRectMake(self.imageViewWebHeaderUrl1.frame.origin.x + self.imageViewWebHeaderUrl1.frame.size.width, self.imageViewWebHeaderUrl2.frame.origin.y,
                                                   urlFieldWidth, self.imageViewWebHeaderUrl2.frame.size.height);
    self.imageViewWebHeaderUrl3.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x + self.imageViewWebHeaderUrl2.frame.size.width, self.imageViewWebHeaderUrl3.frame.origin.y,
                                                   self.imageViewWebHeaderUrl3.frame.size.width, self.imageViewWebHeaderUrl3.frame.size.height);
    self.textFieldUrl.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x - 10, self.textFieldUrl.frame.origin.y, self.imageViewWebHeaderUrl2.frame.size.width + 50 - widthg_diff, self.textFieldUrl.frame.size.height);
    
    self.imageViewWebHeaderSearch1.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, self.imageViewWebHeaderSearch1.frame.origin.y,
                                                      self.imageViewWebHeaderSearch1.frame.size.width, self.imageViewWebHeaderSearch1.frame.size.height);
    self.imageViewWebHeaderSearch2.frame = CGRectMake(self.imageViewWebHeaderSearch1.frame.origin.x + self.imageViewWebHeaderSearch1.frame.size.width, self.imageViewWebHeaderSearch1.frame.origin.y,
                                                      100, self.imageViewWebHeaderSearch2.frame.size.height);
    self.imageViewWebHeaderSearch3.frame = CGRectMake(self.imageViewWebHeaderSearch2.frame.origin.x + self.imageViewWebHeaderSearch2.frame.size.width, self.imageViewWebHeaderSearch3.frame.origin.y,
                                                      self.imageViewWebHeaderSearch3.frame.size.width, self.imageViewWebHeaderSearch3.frame.size.height);
    self.textFieldSearch.frame = CGRectMake(self.imageViewWebHeaderSearch2.frame.origin.x - 10, self.textFieldSearch.frame.origin.y, self.imageViewWebHeaderSearch2.frame.size.width + 20, self.textFieldSearch.frame.size.height);
    
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, 0, mainScreenHeight - self.imageViewWebHeaderUrl3.frame.origin.x, self.imageViewWebHeaderBlackLine.frame.size.height);
    
    self.buttonCancel.frame = CGRectMake(mainScreenHeight, self.buttonCancel.frame.origin.y, self.buttonCancel.frame.size.width, self.buttonCancel.frame.size.height);
    
    if (animate) {
        [UIView commitAnimations];
    }
}

- (void) beginVideoAnimationForLandscape:(BOOL)animate {
    NSLog(@"beginVideoAnimationForLandscape");
    
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, 0, 320 - self.imageViewWebHeaderUrl3.frame.origin.x, self.imageViewWebHeaderBlackLine.frame.size.height);
    
    if (animate) {
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.2];
    }
    
    self.imageViewWebHeaderUrl2.frame = CGRectMake(self.imageViewWebHeaderUrl1.frame.origin.x + self.imageViewWebHeaderUrl1.frame.size.width, self.imageViewWebHeaderUrl2.frame.origin.y,
                                                   165, self.imageViewWebHeaderUrl2.frame.size.height);
    self.imageViewWebHeaderUrl3.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x + self.imageViewWebHeaderUrl2.frame.size.width, self.imageViewWebHeaderUrl3.frame.origin.y,
                                                   self.imageViewWebHeaderUrl3.frame.size.width, self.imageViewWebHeaderUrl3.frame.size.height);
    self.textFieldUrl.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x - 10, self.textFieldUrl.frame.origin.y, self.imageViewWebHeaderUrl2.frame.size.width + 50 - widthg_diff, self.textFieldUrl.frame.size.height);
    
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, 0, 320 - self.imageViewWebHeaderUrl3.frame.origin.x, self.imageViewWebHeaderBlackLine.frame.size.height);
    
    self.imageViewWebHeaderSearch1.alpha = 0.0;
    self.imageViewWebHeaderSearch2.alpha = 0.0;
    self.imageViewWebHeaderSearch3.alpha = 0.0;
    
    self.textFieldSearch.alpha = 0.0;
    
    self.buttonVideo.frame = CGRectMake(320 - self.buttonVideo.frame.size.width, self.buttonVideo.frame.origin.y, self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    
    if (animate) {
        [UIView commitAnimations];
    }
}

- (void) endVideoAnimationForLandscape:(BOOL)animate {
    NSLog(@"endVideoAnimationForLandscape");
    
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, 0, 320 - self.imageViewWebHeaderUrl3.frame.origin.x, self.imageViewWebHeaderBlackLine.frame.size.height);
    
    if (animate) {
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.2];
    }
    
    self.imageViewWebHeaderUrl2.frame = CGRectMake(self.imageViewWebHeaderUrl1.frame.origin.x + self.imageViewWebHeaderUrl1.frame.size.width, self.imageViewWebHeaderUrl2.frame.origin.y,
                                                   125, self.imageViewWebHeaderUrl2.frame.size.height);
    self.imageViewWebHeaderUrl3.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x + self.imageViewWebHeaderUrl2.frame.size.width, self.imageViewWebHeaderUrl3.frame.origin.y,
                                                   self.imageViewWebHeaderUrl3.frame.size.width, self.imageViewWebHeaderUrl3.frame.size.height);
    self.textFieldUrl.frame = CGRectMake(self.imageViewWebHeaderUrl2.frame.origin.x - 10, self.textFieldUrl.frame.origin.y, self.imageViewWebHeaderUrl2.frame.size.width + 50 - widthg_diff, self.textFieldUrl.frame.size.height);
    
    self.imageViewWebHeaderBlackLine.frame = CGRectMake(self.imageViewWebHeaderUrl3.frame.origin.x + self.imageViewWebHeaderUrl3.frame.size.width, 0, 320 - self.imageViewWebHeaderUrl3.frame.origin.x, self.imageViewWebHeaderBlackLine.frame.size.height);
    
    self.imageViewWebHeaderSearch1.alpha = 1.0;
    self.imageViewWebHeaderSearch2.alpha = 1.0;
    self.imageViewWebHeaderSearch3.alpha = 1.0;
    
    self.textFieldSearch.alpha = 1.0;
    
    self.buttonVideo.frame = CGRectMake(320, self.buttonVideo.frame.origin.y, self.buttonVideo.frame.size.width, self.buttonVideo.frame.size.height);
    
    if (animate) {
        [UIView commitAnimations];
    }
}

@end

@implementation SeequWebViewHeader


@synthesize headerDelegate = _delegate;


- (void)awakeFromNib {
    [super awakeFromNib];

    interfaceOrientation = UIInterfaceOrientationPortrait;
    callState = WebViewHeaderCallState_None;
    
    lastSearchString = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FieldTextDidChange:)
                                                 name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCallStateChange:)
                                                 name:kCallStateChange
                                               object:nil];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"SeequButtonWebStopLoading.png"];
    [button setImage:image forState:UIControlStateNormal];
    button.bounds = CGRectMake(0, 0, 24, 24);
    [button addTarget:self action:@selector(onButtonStopReload:) forControlEvents:UIControlEventTouchUpInside];
    [self setInitialHeaderState];
    
    self.textFieldUrl.rightView = button;
    self.textFieldUrl.backgroundColor = [UIColor clearColor];
    
    self.textFieldUrl.rightViewMode = UITextFieldViewModeAlways;
}

- (id)init {
    
    self = [super init];
    if (self) {
        // Initialization code
        interfaceOrientation = UIInterfaceOrientationPortrait;
    }
    return self;
}

-(void) setInitialHeaderState{
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        headerState = SeequWebViewHeaderState_Landscape;
    } else {
        headerState = SeequWebViewHeaderState_Portrait;
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        if (textField == self.textFieldSearch) {
            [self setHeaderState:SeequWebViewHeaderState_Portrait_Search Animated:YES];
            self.textFieldSearch.text = lastSearchString;
            if ([_delegate respondsToSelector:@selector(didBeginEditingSearch:)]) {
                [_delegate didBeginEditingSearch:self];
            }
        } else {
            [self setHeaderState:SeequWebViewHeaderState_Portrait_Link_Edit Animated:YES];
            if ([_delegate respondsToSelector:@selector(didBeginEditingURL:)]) {
                [_delegate didBeginEditingURL:self];
            }
        }
    } else {
        if (textField == self.textFieldSearch) {
            [self setHeaderState:SeequWebViewHeaderState_Landscape_Search Animated:YES];
            self.textFieldSearch.text = lastSearchString;
            if ([_delegate respondsToSelector:@selector(didBeginEditingSearch:)]) {
                [_delegate didBeginEditingSearch:self];
            }
        } else {
            [self setHeaderState:SeequWebViewHeaderState_Landscape_Link_Edit Animated:YES];
            if ([_delegate respondsToSelector:@selector(didBeginEditingURL:)]) {
                [_delegate didBeginEditingURL:self];
            }
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.textFieldSearch) {
        lastSearchString = self.textFieldSearch.text;
        self.textFieldSearch.text = @"";
        if ([_delegate respondsToSelector:@selector(didEndEditingSearch:)]) {
            [_delegate didEndEditingSearch:self];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(didEndEditingURL:)]) {
            [_delegate didEndEditingURL:self];
        }
    }
    
    //return YES;
    if(![[self.webView stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"]){
        return NO;
    }else{
        return YES;
    }
    
}

- (void)FieldTextDidChange:(NSNotification *)notification {
    UITextField *textField = [notification object];
    
    if (textField == self.textFieldUrl) {
        if ([_delegate respondsToSelector:@selector(didChangeUrlText:Text:)]) {
            [_delegate didChangeUrlText:self Text:textField.text];
        }
    } else {
        if (textField == self.textFieldSearch) {
            if ([_delegate respondsToSelector:@selector(didChangeSearchText:Text:)]) {
                [_delegate didChangeSearchText:self Text:textField.text];
            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.textFieldUrl) {
        if ([_delegate respondsToSelector:@selector(didEnterGo:withUrl:)]) {
            [_delegate didEnterGo:self withUrl:self.textFieldUrl.text];
        }
        [self onButtonCancel:nil];
    } else {
        if ([_delegate respondsToSelector:@selector(didEnterSearch:withText:)]) {
            [_delegate didEnterSearch:self withText:self.textFieldSearch.text];
        }
    }
    
    return YES;
}

- (IBAction)onButtonCancel:(id)sender {
    [self ChangeStateToDefaultAnimated:YES];
    
    if ([_delegate respondsToSelector:@selector(didClickCancel:)]) {
        [_delegate didClickCancel:self];
    }
    UIButton *button = (UIButton *)sender;
    if(button.tag == 1111){
    self.textFieldUrl.text = setedUrl;
    [self setRightViewState:RightViewState_Reload];
        
    }
    self.textFieldSearch.text = @"";
    lastSearchString =@"";
    
    if (self.textFieldUrl.isEditing) {
        [self.textFieldUrl resignFirstResponder];
        return;
    }

    
        if (self.textFieldSearch.isEditing) {
        [self.textFieldSearch resignFirstResponder];
    }
    
}

- (IBAction)onButtonVideo:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickVideo:)]) {
        [_delegate didClickVideo:self];
    }

    [self ChangeStateToDefaultAnimated:NO];
}

- (IBAction)onButtonStopReload:(id)sender {
    if ([_delegate respondsToSelector:@selector(didStopLoading:State:)]) {
        [_delegate didStopLoading:self State:rightViewState];
    }
}

- (void) onCallStateChange:(NSNotification*)notification {
    tabBar_Type type = (tabBar_Type)[[notification object] integerValue];
    
    switch (type) {
        case tabBar_Type_Default: {
        }
            break;
        case tabBar_Type_Landscape: {
        }
            break;
        case tabBar_Type_Audio:
        case tabBar_Type_Audio_Selected: {
            [self.buttonVideo setBackgroundImage:[UIImage imageNamed:@"seequButtonAudioOnBrowser.png"] forState:UIControlStateNormal];
        }
            break;
        case tabBar_Type_Video:
        case tabBar_Type_Video_Selected: {
            [self.buttonVideo setBackgroundImage:[UIImage imageNamed:@"seequButtonVideoOnBrowser.png"] forState:UIControlStateNormal];
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

- (void) setHeaderState:(SeequWebViewHeaderState)state Animated:(BOOL)animated {
    if (headerState == state) {
        animated = NO;
    }
    
    [self ChangeStateToDefaultAnimated:NO];
    
    switch (state) {
        case SeequWebViewHeaderState_Portrait: {
            [self endURLAnimationForPortrait:animated];
        }
            break;
        case SeequWebViewHeaderState_Portrait_Link_Edit: {
            [self beginURLAnimationForPortrait:animated];
        }
            break;
        case SeequWebViewHeaderState_Portrait_Search: {
            [self beginSearchAnimationForPortrait:animated];
        }
            break;
        case SeequWebViewHeaderState_Landscape: {
            [self endURLAnimationForLandscape:animated];
        }
            break;
        case SeequWebViewHeaderState_Landscape_Link_Edit: {
            [self beginURLAnimationForLandscape:animated];
        }
            break;
        case SeequWebViewHeaderState_Landscape_Search: {
            if (callState != WebViewHeaderCallState_CallMenu) {
                [self beginSearchAnimationForLandscape:animated];
            }
        }
            break;
        default:
            break;
    }

    headerState = state;
}

- (void) ChangeStateToDefaultAnimated:(BOOL)animated {
    switch (headerState) {
        case SeequWebViewHeaderState_Portrait_Link_Edit: {
            [self endURLAnimationForPortrait:animated];
            headerState = SeequWebViewHeaderState_Portrait;
        }
            break;
        case SeequWebViewHeaderState_Portrait_Search: {
            [self endSearchAnimationForPortrait:animated];
            headerState = SeequWebViewHeaderState_Portrait;
        }
            break;
        case SeequWebViewHeaderState_Landscape_Link_Edit: {
            [self endURLAnimationForLandscape:animated];
            headerState = SeequWebViewHeaderState_Landscape;
        }
            break;
        case SeequWebViewHeaderState_Landscape_Search: {
            [self endSearchAnimationForLandscape:animated];
            headerState = SeequWebViewHeaderState_Landscape;
        }
            break;
        default:
            break;
    }
}

- (void) beginSearchAnimationFinished {
    if ([_delegate respondsToSelector:@selector(didEndBeginSearchAnimation:)]) {
        [_delegate didEndBeginSearchAnimation:self];
    }
}

- (void) endSearchAnimationFinished {
    if ([_delegate respondsToSelector:@selector(didEndEndSearchAnimation:)]) {
        [_delegate didEndEndSearchAnimation:self];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    NSString *prefixToRemove = @"http://";
    if ([self.textFieldUrl.text hasPrefix:prefixToRemove]) {
        self.textFieldUrl.text = [self.textFieldUrl.text substringFromIndex:[prefixToRemove length]];
    }
    
    prefixToRemove = @"https://";
    if ([self.textFieldUrl.text hasPrefix:prefixToRemove]) {
        self.textFieldUrl.text = [self.textFieldUrl.text substringFromIndex:[prefixToRemove length]];
    }
}

- (void) setTitle:(NSString*)title {
    self.labelTitle.text = title;
}

- (NSString*) getTitle {
    return self.labelTitle.text;
}

- (void) setURL:(NSString*)url {
    
    NSArray* splittedUrlArray ;
    if ([url rangeOfString:@"://"].location != NSNotFound) {
        splittedUrlArray = [url componentsSeparatedByString:@"://"];
        if([splittedUrlArray count] >= 2){
            strHttp = [NSString stringWithFormat:@"%@://", splittedUrlArray[0]];
            url = splittedUrlArray[1];
        }
    }
    
    if([url hasSuffix:@"/"]){
        url = [url substringToIndex:[url rangeOfString:@"/"].location];
        strSlash = @"/";
    }else{
        strSlash = nil;
    }
    if (![url hasSuffix:@"seequweberrorpage.html"] && !self.textFieldUrl.editing) {
        if ([url rangeOfString:@"www."].location == NSNotFound) {
            self.textFieldUrl.text = [NSString stringWithFormat:@"www.%@",url];
            setedUrl = [NSString stringWithFormat:@"www.%@",url];
        } else {
            self.textFieldUrl.text = url;
            setedUrl = url;
        }
    }
    RSLogUI(@"[BROWSER] AddressBar update - %@", url);
}

- (NSString*) getURL {
    return self.textFieldUrl.text;
}

- (void) setOrientation:(UIInterfaceOrientation)interfaceOrientation_ {
    interfaceOrientation = interfaceOrientation_;
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) && headerState == SeequWebViewHeaderState_Portrait_Search && callState == WebViewHeaderCallState_CallMenu) {
        [self endSearchAnimationForPortrait:NO];
        [self beginURLAnimationForPortrait:NO];
        [self.textFieldSearch resignFirstResponder];
        
        headerState = SeequWebViewHeaderState_Portrait_Link_Edit;
    }
    
    switch (headerState) {
        case SeequWebViewHeaderState_Portrait: {
            if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
                [self endURLAnimationForLandscape:YES];
                headerState = SeequWebViewHeaderState_Landscape;
            }
        }
            break;
        case SeequWebViewHeaderState_Portrait_Link_Edit: {
            if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
                [self beginURLAnimationForLandscape:YES];
                headerState = SeequWebViewHeaderState_Landscape_Link_Edit;
            }
        }
            break;
        case SeequWebViewHeaderState_Portrait_Search: {
            if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
                if (callState != WebViewHeaderCallState_CallMenu) {
                    [self beginSearchAnimationForLandscape:YES];
                    headerState = SeequWebViewHeaderState_Landscape_Search;
                } else {
                    [self beginURLAnimationForLandscape:YES];
                    headerState = SeequWebViewHeaderState_Landscape_Link_Edit;
                }
            }
        }
            break;
        case SeequWebViewHeaderState_Landscape: {
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
                [self endURLAnimationForPortrait:YES];
                headerState = SeequWebViewHeaderState_Portrait;
            }
        }
            break;
        case SeequWebViewHeaderState_Landscape_Link_Edit: {
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
                [self beginURLAnimationForPortrait:YES];
                headerState = SeequWebViewHeaderState_Portrait_Link_Edit;
            }
        }
            break;
        case SeequWebViewHeaderState_Landscape_Search: {
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
                [self beginSearchAnimationForPortrait:YES];
                headerState = SeequWebViewHeaderState_Portrait_Search;
            }
        }
            break;
        default:
            break;
    }
}

- (void) setCallState:(WebViewHeaderCallState)callState_ {
    callState = callState_;

    [self setHeaderState:headerState Animated:YES];
}

- (void) setRightViewState:(RightViewState)state {
    switch (state) {
        case RightViewState_None:
        case RightViewState_Stop:
        case RightViewState_Clear: {
            UIButton *button = (UIButton*)self.textFieldUrl.rightView;
            UIImage *image = [UIImage imageNamed:@"SeequButtonWebStopLoading.png"];
            [button setImage:image forState:UIControlStateNormal];
//            [button setBackgroundImage:image forState:UIControlStateNormal];
//            CGRect frame = button.frame;
//            frame.size = image.size;
//            button.frame = frame;
        }
            break;
        case RightViewState_Reload: {
            UIButton *button = (UIButton*)self.textFieldUrl.rightView;
            UIImage *image = [UIImage imageNamed:@"SeequButtonWebReload.png"];
            [button setImage:image forState:UIControlStateNormal];
//            [button setBackgroundImage:image forState:UIControlStateNormal];
//            CGRect frame = button.frame;
//            frame.size = image.size;
//            button.frame = frame;
        }
            break;
        default:
            break;
    }
    
    rightViewState = state;
}

- (void) setFrame:(CGRect)frame {
    if (frame.size.width == 160 || frame.size.width == 72)
        return;
    
    [super setFrame:frame];

    self.labelTitle.frame = CGRectMake(self.labelTitle.frame.origin.x, self.labelTitle.frame.origin.y,
                                       self.frame.size.width, self.labelTitle.frame.size.height);
}
-(NSString*)strHttp{
    return strHttp;
}

- (NSString*)setedUrl{
    return setedUrl;
}
- (NSString*)strSlash{
    return strSlash;
}
@end