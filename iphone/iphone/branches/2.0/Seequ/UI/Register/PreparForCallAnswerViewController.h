//
//  PreparForCallAnswerViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 2/7/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreparForCallAnswerViewController : UIViewController {
    IBOutlet UIActivityIndicatorView *indicatorView;
    
    NSTimer *timer;
}

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicatorView;

- (void) closeView;

@end
