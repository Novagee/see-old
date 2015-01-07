//
//  WelcomeSeequViewController.h
//  ProTime
//
//  Created by Karen on 10/18/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeSeequViewController : UIViewController{
    UIScrollView *scroll;
    UIPageControl *pageControl;
    UILabel *lblPageName;
    NSMutableArray *arrayImages;
    NSMutableArray *arrayPageName;
    NSDictionary *dictPersonData;
    NSDictionary *dictIntroduction;
    
    NSString *firstName;
    NSString *lastName;
    NSString *email;
    NSString *password;
    NSString *title;
    NSString *company;
    NSString *status;
    
    UIView *indicatorView;
    UIActivityIndicatorView *indicator;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scroll;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UILabel *lblPageName;
@property (nonatomic, strong) NSDictionary *dictPersonData;
@property (nonatomic, strong) NSDictionary *dictIntroduction;

- (IBAction) onClickPageControl:(id)sender;
- (IBAction) onButtonFinish:(id)sender;

@end
