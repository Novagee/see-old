//
//  SearchBarWithCallButton.h
//  ProTime
//
//  Created by Norayr on 07/16/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum CallButtonType {
	CallButtonType_NONE,
    CallButtonType_Audio,
    CallButtonType_Video,
    CallButtonType_Hold
}
CallButtonType;


@protocol SearchBarDelegate;

@interface SearchBarWithCallButton : UIView <UITextFieldDelegate> {
//    id<SearchBarDelegate> __weak _delegate;

    UIButton *buttonCall;
    
    UIImageView *imageView1;
    UIImageView *imageView2;
    UIImageView *imageView3;
    
    UITextField *searchTextField;
}

@property (nonatomic, assign) id<SearchBarDelegate> delegate;
@property (nonatomic,assign) BOOL isCallVisible;

- (id)initWithFrame:(CGRect)frame ShowCallButton:(BOOL)show;
- (void) onButtonCall:(id)sender;
- (void) setLength:(int)length ShowCallButton:(BOOL)show;
- (void) setCallButtonType:(CallButtonType)type;
- (void) hideKeyboard;

@end

@protocol SearchBarDelegate <NSObject>

@optional

- (void) didClickOnCallButton:(SearchBarWithCallButton*)searchBar;
- (void) didChangeSearchText:(SearchBarWithCallButton*)searchBar SearchText:(NSString*)text;

@end