//
//  SearchBarWithCallButton.m
//  ProTime
//
//  Created by Norayr on 07/16/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import "SearchBarWithCallButton.h"

@implementation SearchBarWithCallButton


@synthesize delegate = _delegate;
@synthesize isCallVisible = _isCallVisible;

- (id)initWithFrame:(CGRect)frame ShowCallButton:(BOOL)show
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //self.backgroundColor = [UIColor redColor];
        // Initialization code
        
        buttonCall = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width, 0, 59, 44)];
        [buttonCall setBackgroundImage:[UIImage imageNamed:@"seequSearchAudioButton.png"] forState:UIControlStateNormal];
        [buttonCall addTarget:self
                       action:@selector(onButtonCall:)
             forControlEvents:UIControlEventTouchUpInside];
        buttonCall.hidden = YES;
        [self addSubview:buttonCall];
        
        imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        [imageView1 setImage:[UIImage imageNamed:@"seequSearchBG1.png"]];
        [self addSubview:imageView1];

        imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        [imageView2 setImage:[UIImage imageNamed:@"seequSearchBG2.png"]];
        [self addSubview:imageView2];

        imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        [imageView3 setImage:[UIImage imageNamed:@"seequSearchBG3.png"]];
        [self addSubview:imageView3];
        
        searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
        [searchTextField setBackgroundColor:[UIColor clearColor]];

        [searchTextField setReturnKeyType:UIReturnKeySearch];
        searchTextField.delegate = self;
        [searchTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self addSubview:searchTextField];
        
        [self setLength:frame.size.width ShowCallButton:show];
        
        // For textField1
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(SearchTextFieldChange)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:searchTextField];        
    }
    
    return self;
}

-(void) setIsCallVisible:(BOOL)isCallVisible_ {
    _isCallVisible = isCallVisible_;
    [self setNeedsLayout];
}
-(void) layoutSubviews {
    
   // self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, length, self.frame.size.height);
    
    if (_isCallVisible) {
        imageView2.frame = CGRectMake(imageView1.frame.size.width, 0, self.frame.size.width - imageView1.frame.size.width - imageView3.frame.size.width - buttonCall.frame.size.width, 44);
    } else {
        imageView2.frame = CGRectMake(imageView1.frame.size.width, 0, self.frame.size.width - imageView1.frame.size.width - imageView3.frame.size.width, 44);
    }
    
    CGRect frame = CGRectMake(imageView2.frame.origin.x + imageView2.frame.size.width, 0, imageView3.frame.size.width, 44);
    imageView3.frame = frame;
    searchTextField.frame = CGRectMake(imageView2.frame.origin.x, 7, imageView2.frame.size.width + 30, 30);
    if (_isCallVisible) {
        buttonCall.frame = CGRectMake(self.frame.size.width - 59, 0, 59, 44);
        buttonCall.hidden = NO;
    } else {
        buttonCall.frame = CGRectMake(self.frame.size.width, 0, 59, 44);
        buttonCall.hidden = YES;
    }

}

- (void) onButtonCall:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didClickOnCallButton:)]) {
        [self.delegate didClickOnCallButton:self];
    }
}

- (void) setLength:(int)length ShowCallButton:(BOOL)show {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, length, self.frame.size.height);
    
    if (show) {
        imageView2.frame = CGRectMake(imageView1.frame.size.width, 0, length - imageView1.frame.size.width - imageView3.frame.size.width - buttonCall.frame.size.width, 44);
    } else {
        imageView2.frame = CGRectMake(imageView1.frame.size.width, 0, length - imageView1.frame.size.width - imageView3.frame.size.width, 44);
    }
    
    CGRect frame = CGRectMake(imageView2.frame.origin.x + imageView2.frame.size.width, 0, imageView3.frame.size.width, 44);
    imageView3.frame = frame;
    searchTextField.frame = CGRectMake(imageView2.frame.origin.x, 7, imageView2.frame.size.width + 30, 30);
    if (show) {
        buttonCall.frame = CGRectMake(length - 59, 0, 59, 44);
        buttonCall.hidden = NO;
    } else {
        buttonCall.frame = CGRectMake(length, 0, 59, 44);
        buttonCall.hidden = YES;
    }
}

- (void) setCallButtonType:(CallButtonType)type {
    switch (type) {
        case CallButtonType_NONE:
        case CallButtonType_Audio: {
            [buttonCall setBackgroundImage:[UIImage imageNamed:@"seequSearchAudioButton.png"] forState:UIControlStateNormal];
        }
            break;
        case CallButtonType_Video: {
            [buttonCall setBackgroundImage:[UIImage imageNamed:@"seequSearchVideoButton.png"] forState:UIControlStateNormal];
        }
            break;
        case CallButtonType_Hold: {
            [buttonCall setBackgroundImage:[UIImage imageNamed:@"tabOnHold.png"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (void) SearchTextFieldChange {
    if ([self.delegate respondsToSelector:@selector(didChangeSearchText:SearchText:)]) {
        [self.delegate didChangeSearchText:self SearchText:searchTextField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

- (void) hideKeyboard {
    [searchTextField resignFirstResponder];
}

@end