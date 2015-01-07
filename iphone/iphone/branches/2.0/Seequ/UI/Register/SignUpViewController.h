//
//  SignUpViewController.h
//  ProTime
//
//  Created by Norayr on 5/25/11.
//  Copyright 2011 doubango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RamkaView.h"
#import "AviaryPickerController.h"


@interface SignUpViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate , UIImagePickerControllerDelegate,AviaryPickerDelegate,UITextFieldDelegate> {
    UITextField *firstNameTxt,*lastNameTxt,*emailTxt,*passwordTxt,*confirmPasswordTxt;
    
    UIButton *regButton;
    UIButton *takePhotoButton;
    UIImageView *proImageView;
    UIImageView *proImageViewRamka;
    int currentTextFieldTag;
    
    UILabel *lblFirstName;
    UILabel *lblLastName;
    UILabel *lblEmail;
    UILabel *lblPassword;
    UILabel *lblVerify;
    
    UIImageView *textFieldBGSmallCells;
    UIImageView *textFieldBGLargCells;
    UILabel *lblImageError;
    UILabel *lblFieldError;

    
    UIView *viewWarning;
    
    BOOL isPhoneTaked;
    BOOL isErrorField;
    
    UIImagePickerController *piker;
    
    RamkaView *maskView;
    UIView *indicatorView;
    UIActivityIndicatorView *indicator;
}

@property (nonatomic, strong) IBOutlet UITextField *firstNameTxt;
@property (nonatomic, strong) IBOutlet UITextField *lastNameTxt;
@property (nonatomic, strong) IBOutlet UITextField *emailTxt;
@property (nonatomic, strong) IBOutlet UITextField *passwordTxt;
@property (nonatomic, strong) IBOutlet UITextField *confirmPasswordTxt;

@property (nonatomic, strong) IBOutlet UIButton *regButton;
@property (nonatomic, strong) IBOutlet UIButton *takePhotoButton;

@property (nonatomic, strong) IBOutlet UILabel *lblFirstName;
@property (nonatomic, strong) IBOutlet UILabel *lblLastName;
@property (nonatomic, strong) IBOutlet UILabel *lblEmail;
@property (nonatomic, strong) IBOutlet UILabel *lblPassword;
@property (nonatomic, strong) IBOutlet UILabel *lblVerify;

@property (nonatomic, strong) IBOutlet UIImageView *proImageView;
@property (nonatomic, strong) IBOutlet UIImageView *proImageViewRamka;
@property (nonatomic, strong) IBOutlet UILabel *lblImageError;
@property (nonatomic, strong) IBOutlet UILabel *lblFieldError;
@property (weak, nonatomic) IBOutlet UILabel *lblPasswordError;

@property (nonatomic, strong) IBOutlet UIImageView *textFieldBGSmallCells;
@property (nonatomic, strong) IBOutlet UIImageView *textFieldBGLargCells;

@property (nonatomic, strong) IBOutlet UIView *viewWarning;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *indicatorView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicator;

- (IBAction) Reg_ProTime_Account:(id)sender;
- (IBAction) Take_Photo:(id)sender;
//- (IBAction) CloseCamera:(id)sender;
//- (IBAction) TakePicture:(id)sender;
//- (IBAction) TakePhotoFromLibrary:(id)sender;
//- (IBAction) SwitchCamera:(id)sender;

- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
- (BOOL) validateFields;
- (void) animateTextField:(UITextField*)textField up:(BOOL)up;

//- (void) GoToAccountActivateWithSeequID:(NSString*)pt_ID;
- (void) ShowMessageWithText:(NSString*)text;

@end