//
//  SeequWebView.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 11/30/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@protocol SeequWebViewDelegate;

@interface SeequWebView : UIWebView {
    id<SeequWebViewDelegate> __unsafe_unretained _delegate;

    UITextField *txtField;
}

@property (nonatomic, assign) id<SeequWebViewDelegate> seequDelegate;
@property (nonatomic, assign) int resourceCount;
@property (nonatomic, assign) int resourceCompletedCount;
@property (strong, nonatomic) UIView *headerView;
@property BOOL pinHeader;


- (id) initWithFrame:(CGRect)newFrame header:(UIView *)header;
- (void) menuItemSearchInSeequ:(id)sender;
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
+ (void)setFirst:(BOOL)value;


//- (void)setPinHeader:(BOOL)newValue;


@end

@protocol SeequWebViewDelegate <NSObject>

@optional

- (void) didClickOnSearchInSeequ:(SeequWebView*)seequWebView withText:(NSString*)text;
- (void) webView:(SeequWebView*)webView didReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources;

@end