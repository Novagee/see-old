//
//  SeequCreateMembershipViewController.h
//  ProTime
//
//  Created by Karen on 10/18/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeequSignUpTitleViewController : UIViewController{
    UITextField *fieldTitle;
    UITextField *fieldCompany;
    NSDictionary *dictPersonData;
    NSString *stringTitle;
    NSString *stringCompany;
    NSString *stringStatus;
}

@property (nonatomic, strong) IBOutlet UITextField *fieldTitle;
@property (nonatomic, strong) IBOutlet UITextField *fieldCompany;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewMain;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textViewStatus;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelStatus;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewWarning;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelError;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewStatus;
@property (nonatomic, strong) NSDictionary *dictPersonData;

- (void) GoBack;
- (void) GoNext;

@end
