//
//  SignUpViewController.m
//  ProTime
//
//  Created by Norayr on 5/25/11.
//  Copyright 2011 doubango. All rights reserved.
//

#import "SignUpViewController.h"
#import "idoubs2AppDelegate.h"
#import "UIImage+Operations.h"
#import "Common.h"
#import <QuartzCore/QuartzCore.h>
#import "CJSONDeserializer.h"
#import "NavigationBar.h"
#import "BackBarButton.h"
#import "SeequSignUpTitleViewController.h"
#import "AviaryPickerController.h"
#import <AviarySDK/AviarySDK.h>
#import "SeequSignUpMembershipViewController.h"

#import "SeequVideoRecorerViewController.h"

@interface SignUpViewController ()<AFPhotoEditorControllerDelegate,SeequVideoRecorerViewControllerDelegate>

@end


@implementation SignUpViewController


@synthesize firstNameTxt;
@synthesize lastNameTxt;
@synthesize emailTxt;
@synthesize passwordTxt;
@synthesize confirmPasswordTxt;
@synthesize regButton;
@synthesize takePhotoButton;
@synthesize proImageView;
@synthesize proImageViewRamka;

@synthesize lblFirstName;
@synthesize lblLastName;
@synthesize lblEmail;
@synthesize lblPassword;
@synthesize lblVerify;

@synthesize textFieldBGSmallCells;
@synthesize textFieldBGLargCells;
@synthesize lblImageError;
@synthesize lblFieldError;
@synthesize lblPasswordError;

@synthesize viewWarning;
@synthesize scrollView;

@synthesize indicatorView;
@synthesize indicator;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    // Do any additional setup after loading the view from its nib.
    currentTextFieldTag = 1;
    isPhoneTaked = NO;
    if (IS_IOS_7){
    self.edgesForExtendedLayout=UIRectEdgeNone;

    }
//    UIImagePickerController *_piker = [[UIImagePickerController alloc] init];
//    [self presentViewController:_piker animated:YES completion:nil];
//    [_piker release];
//    [_piker dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ((NavigationBar*) self.navigationController.navigationBar).hidden = NO;
    
    ((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleSignUp.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    BackBarButton *nextBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"SeequNavigationButtonNext.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(Reg_ProTime_Account:)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification object:self.view.window];    
    
    self.scrollView.contentSize = CGSizeMake(320, 416);
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    currentTextFieldTag = 1;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil]; 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) Reg_ProTime_Account:(id)sender {
    if ([self validateFields] == YES) {
        [self hideRedAlertView];
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [reachability currentReachabilityStatus];
        if (networkStatus==NotReachable) {
            [self performSelectorOnMainThread:@selector(ShowMessageWithText:) withObject:@"Internet connection problem, please try again later." waitUntilDone:YES];
        }else{
        indicatorView.hidden = NO;
        [self.navigationController.view addSubview:indicatorView];
        [indicator startAnimating];
        [NSThread detachNewThreadSelector:@selector(startReg) toTarget:self withObject:nil];   
        }
    } else{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3];
        self.viewWarning.center = CGPointMake(160, 19);
        self.scrollView.center = CGPointMake(160, 248);
        [UIView commitAnimations];
    }

    [self.firstNameTxt resignFirstResponder];
    [self.lastNameTxt resignFirstResponder];
    [self.emailTxt resignFirstResponder];
    [self.passwordTxt resignFirstResponder];
    [self.confirmPasswordTxt resignFirstResponder];
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 320, 416) animated:YES];
}

- (void) startReg {
    NSString *retval = nil;
 
    NSString *error_message = [Common GetSeequIDByEmail:self.emailTxt.text SeequID:&retval];
    [indicator stopAnimating];
    [indicatorView removeFromSuperview];
    if (!error_message) {
//        [self performSelectorOnMainThread:@selector(ShowMessageWithText:) withObject:@"This email is already in use." waitUntilDone:YES];
//        error_message=@"Existing account";
        self.viewWarning.hidden = NO;
        self.lblFieldError.hidden = NO;
        [self showRedAlertView];
        self.textFieldBGLargCells.image = [UIImage imageNamed:@"SeequLargCellsBgError.png"];
        self.lblEmail.textColor = [UIColor redColor];
        self.lblFieldError.text = @"* This email is already in use.";
        isErrorField = YES;
    }else if ([error_message isEqualToString:@"Account does not exist"]){
//        else {
        [self performSelectorOnMainThread:@selector(goNextStep:) withObject:error_message waitUntilDone:YES];
    }else{
        self.viewWarning.hidden = NO;
        self.lblFieldError.hidden = NO;
        [self showRedAlertView];
        self.lblFieldError.text = error_message;
        isErrorField = YES;    }
}

- (void)goNextStep:(NSString*)retval {
//    [indicator stopAnimating];
//    [indicatorView removeFromSuperview];
//    if (retval == nil) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                        message:@"Oops, something went wrong with the sign up process. Please try again later."
//                                                       delegate:nil
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:@"OK", nil];
//        [alert show];
//        self.navigationController.navigationItem.leftBarButtonItem.enabled = YES;
//        [self touchesBegan:nil withEvent:nil];
//        return;
//    } else
//    if ([retval isEqualToString:@"Account doesn't exist"]) {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              self.firstNameTxt.text,@"firstName",
                              self.lastNameTxt.text,@"lastName",
                              self.emailTxt.text,@"email",
                              self.passwordTxt.text,@"password",
                              self.proImageView.image,@"image",nil];
        NSDictionary *dictIntroduction = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @"",@"title",
                              @"",@"company",
                              @"",@"status", nil];

        
        SeequSignUpMembershipViewController *signUpMembershipViewController = [[SeequSignUpMembershipViewController alloc] initWithNibName:@"SeequSignUpMembershipViewController" bundle:nil];
        signUpMembershipViewController.dictPersonData = dict;
        signUpMembershipViewController.dictIntroduction = dictIntroduction;
        [self.navigationController pushViewController:signUpMembershipViewController animated:YES];
        
        
//        SeequSignUpTitleViewController *controller = [[SeequSignUpTitleViewController alloc] initWithNibName:@"SeequSignUpTitleViewController" bundle:nil];
//        controller.dictPersonData = dict;
//        [self.navigationController pushViewController:controller animated:YES];
        isErrorField = NO;
//    }
//    else
//    if([retval isEqualToString:@"Existing account"]) {
//        self.viewWarning.hidden = NO;
//        self.lblFieldError.hidden = NO;
//        [self showRedAlertView];
//        self.textFieldBGLargCells.image = [UIImage imageNamed:@"SeequLargCellsBgError.png"];
//        self.lblEmail.textColor = [UIColor redColor];
//        self.lblFieldError.text = @"* This email is already in use.";
//        isErrorField = YES;
//    }else
//    [self performSelectorOnMainThread:@selector(ShowMessageWithText:) withObject:@"Internet connection problem please try again later." waitUntilDone:YES];    
}

- (void)showRedAlertView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    self.viewWarning.center = CGPointMake(160, 19);
    self.scrollView.center = CGPointMake(160, 248);
    [UIView commitAnimations];
}

- (void)hideRedAlertView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    self.viewWarning.center = CGPointMake(160, -25);
    self.scrollView.center = CGPointMake(160, 208);
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Take Photo for profile

- (IBAction) Take_Photo:(id)sender {
    __weak SignUpViewController* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        SeequVideoRecorerViewController*  videoRecorder = [[SeequVideoRecorerViewController alloc] initWithType:SeequRecorderTypePhoto];
        videoRecorder.captureDelegate =weakSelf;
        videoRecorder.devicePosition = AVCaptureDevicePositionBack;
         videoRecorder.forProfile = YES;
        [weakSelf presentViewController:videoRecorder animated:YES completion:nil];
        
    });

   
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"info--------------------------------------%@", info);
    
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    //    float rads = 0;
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *TakedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        TakedImage = [UIImage rotateImage:TakedImage byDegrees:0];
        
        if (TakedImage.size.height > TakedImage.size.width) {
            TakedImage = [self imageByCropping:TakedImage toRect:CGRectMake(0, 80, TakedImage.size.width, TakedImage.size.width)];
        } else {
            TakedImage = [self imageByCropping:TakedImage toRect:CGRectMake(80, 0, TakedImage.size.height, TakedImage.size.height)];
        }
        
        TakedImage = [UIImage rotateImage:TakedImage byDegrees:180];
        TakedImage = [UIImage imageWithCGImage:TakedImage.CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
        
        [self.proImageView setImage:TakedImage];
        isPhoneTaked = YES;
        self.proImageViewRamka.hidden = NO;
        
        maskView = [[RamkaView alloc] initWithFrame:CGRectMake(0, 0, 78, 79)];
        [self.proImageView.layer setMask:maskView.layer];
	    
//        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
	//create a context to do our clipping in
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	//create a rect with the size we want to crop the image to
	//the X and Y here are zero so we start at the beginning of our
	//newly created context
	CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
	CGContextClipToRect( currentContext, clippedRect);
	
	//create a rect equivalent to the full size of the image
	//offset the rect by the X and Y we want to start the crop
	//from in order to cut off anything before them
	CGRect drawRect = CGRectMake(rect.origin.x * -1,
								 rect.origin.y * -1,
								 imageToCrop.size.width,
								 imageToCrop.size.height);
	
	//draw the image to our clipped context using our offset rect
	CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
	
	//pull the image from our cropped context
	UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	
	//Note: this is autoreleased
	return cropped;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        for (UITextField *txtField in self.scrollView.subviews) {
            NSLog(@"txtField.tag === %d",txtField.tag);
            NSLog(@"currentTextFieldTag === %d",currentTextFieldTag);
            if (txtField.tag  == currentTextFieldTag+1) {
                [txtField becomeFirstResponder];
//                [self animateTextField: textField up: YES];
                currentTextFieldTag = txtField.tag;
                break;
            }
        }
    } else {
        if(textField.returnKeyType == UIReturnKeyDone) {
            [self Reg_ProTime_Account:self];
        }
    }
        
//	[textField resignFirstResponder];
	return NO;
}

#pragma mark -
#pragma mark Validation methods

-(BOOL)validateFields {
    self.lblImageError.hidden = YES;
    self.lblFieldError.hidden = YES;
    self.lblPasswordError.hidden=YES;
    NSString *errorStrFields = @"";
    NSString *errorStrImage = @"";
    NSString *errorStringPassword=@"";
    
    if ([firstNameTxt.text length] < 3) {
        NSLog(@"DEBUG: {SignUp}->[validateFields][ERR] - First Name is less than 3 chars");
        errorStrFields = [errorStrFields stringByAppendingString:@"First.Name "];
        self.textFieldBGSmallCells.image = [UIImage imageNamed:@"SeequSmallCellsBgError.png"];
        self.lblFirstName.textColor = [UIColor redColor];
    } else {
        if ([Common validateStr:firstNameTxt.text] == NO) {
            NSLog(@"DEBUG: {SignUp}->[validateFields][ERR] - Unsupported char");
            errorStrFields = [errorStrFields stringByAppendingString:@"First.Name "];
            self.textFieldBGSmallCells.image = [UIImage imageNamed:@"SeequSmallCellsBgError.png"];
            self.lblFirstName.textColor = [UIColor redColor];
        } else{
            self.textFieldBGSmallCells.image = [UIImage imageNamed:@"SeequSmallCellsBg.png"];
            self.lblFirstName.textColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1];
        }
    }
    if ([lastNameTxt.text length] < 3) {
        NSLog(@"DEBUG: {SignUp}->[validateFields][ERR] - Last Name is less than 3 chars");
        errorStrFields = [errorStrFields stringByAppendingString:@"Last.Name "];
        self.textFieldBGSmallCells.image = [UIImage imageNamed:@"SeequSmallCellsBgError.png"];
        self.lblLastName.textColor = [UIColor redColor];
    } else {
        if ([Common validateStr:lastNameTxt.text] == NO) {
            NSLog(@"DEBUG: {SignUp}->[validateFields][ERR] - Unsupported char");
            errorStrFields = [errorStrFields stringByAppendingString:@"Last.Name "];
            self.textFieldBGSmallCells.image = [UIImage imageNamed:@"SeequSmallCellsBgError.png"];
            self.lblLastName.textColor = [UIColor redColor];
        } else {
            self.textFieldBGSmallCells.image = [UIImage imageNamed:@"SeequSmallCellsBg.png"];
            self.lblLastName.textColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1];
        }
    }
    
    if ([Common validateEmail:emailTxt.text] == NO){
        NSLog(@"DEBUG: {SignUp}->[validateFields][ERR] - Incorrect email syntax");
        errorStrFields = [errorStrFields stringByAppendingString:@"Email "];
        self.textFieldBGLargCells.image = [UIImage imageNamed:@"SeequLargCellsBgError.png"];
        self.lblEmail.textColor = [UIColor redColor];
    } else {
        self.lblEmail.textColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1];
    }
    
    NSString *pass = [passwordTxt text];
    NSString *confPass = [confirmPasswordTxt text];
    errorStringPassword=[Common validatePwd:pass];
    
    if (errorStringPassword!=nil){
        NSLog(@"DEBUG: {SignUp}->[validateFields][ERR] - Main Pass doesn't meet requirements");
        errorStrFields = [errorStrFields stringByAppendingString:@"Password "];
        self.textFieldBGLargCells.image = [UIImage imageNamed:@"SeequLargCellsBgError.png"];
        self.lblPassword.textColor = [UIColor redColor];
        self.lblVerify.textColor = [UIColor redColor];
    } else {
        if (![pass isEqualToString:confPass]) {
            NSLog(@"DEBUG: {SignUp}->[validateFields][ERR] - Main and Confirmation Passes don't match");
            errorStrFields = [errorStrFields stringByAppendingString:@"Password "];
            self.textFieldBGLargCells.image = [UIImage imageNamed:@"SeequLargCellsBgError.png"];
            self.lblPassword.textColor = [UIColor redColor];
            self.lblVerify.textColor = [UIColor redColor];
        }
        else {
           self.textFieldBGLargCells.image = [UIImage imageNamed:@"SeequLargCellsBg.png"];
            self.lblPassword.textColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1];
            self.lblVerify.textColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1];
        }
    }
    
    if (!isPhoneTaked){
        NSLog(@"DEBUG: {SignUp}->[validateFields][ERR] - Profile Image is not detected");
        self.proImageViewRamka.hidden = YES;
        self.proImageView.image = [UIImage imageNamed:@"SeequButtonAddPhotoError.png"];
        errorStrImage = @"A Profile Image is required.";
    } else {
        self.proImageViewRamka.hidden = NO;
    }
    
    
    if (errorStrFields.length && ![errorStrFields isEqualToString:@" "]) {
        self.lblFieldError.hidden = NO;
        errorStrFields = [errorStrFields stringByReplacingOccurrencesOfString:@" " withString:@","];
        errorStrFields = [errorStrFields stringByReplacingOccurrencesOfString:@"." withString:@" "];
        errorStrFields = [errorStrFields substringToIndex:errorStrFields.length-1];
        NSArray *arr = [errorStrFields componentsSeparatedByString:@","];
        if (arr.count>1) {
            errorStrFields = @"";
            for (int i = 0; i<arr.count-1; i++) {
                NSString *str = [arr objectAtIndex:i];
                if (i > 0) {
                    errorStrFields = [errorStrFields stringByAppendingString:@","];
                }
                errorStrFields = [NSString stringWithFormat:@"%@%@",errorStrFields,str];
            }
            errorStrFields = [errorStrFields stringByAppendingString:@" and "];
            errorStrFields = [errorStrFields stringByAppendingString:[arr objectAtIndex:arr.count-1]];
        }
        self.lblFieldError.text = [NSString stringWithFormat:@"* Please enter a valid %@",errorStrFields];
        isErrorField = YES;
    }
       if (errorStrImage.length) {
        self.lblImageError.hidden = NO;
        self.lblImageError.text = [NSString stringWithFormat:@"* %@",errorStrImage];
        isErrorField = YES;
    } else{
        self.lblImageError.hidden = YES;
        self.lblFieldError.frame = CGRectMake(5, 0, 286, 21);
        isErrorField = NO;
    }
    if(errorStringPassword.length && ![errorStringPassword isEqualToString:@""]){
        self.lblPasswordError.hidden=NO;
        self.lblPasswordError.frame=CGRectMake(5, self.lblFieldError.frame.origin.y+12, 286, 21);
        self.lblPasswordError.text=[NSString stringWithFormat:@"* %@",errorStringPassword];
        isErrorField=YES;
    }else{
        self.lblPasswordError.hidden=YES;
    }
    
    if (errorStrImage.length || errorStrFields.length||errorStringPassword.length) {
        self.viewWarning.hidden = NO;
        isErrorField = YES;
        return NO;
    }
  
    return YES;
}

#pragma mark keyboard
#pragma mark -

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    currentTextFieldTag = textField.tag;
    if(!IS_IPHONE_5) {
        [self animateTextField: textField up: YES];
    }
}

- (void) animateTextField:(UITextField*)textField up:(BOOL)up {
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [self.scrollView scrollRectToVisible:CGRectMake(0, textField.frame.origin.y-textField.frame.size.height, 300,400)  animated:YES];
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notif {
//    [self animateTextField:nil up:YES];
    if (isErrorField) {
        self.scrollView.frame = CGRectMake(0, 40, 320, 416);
        self.scrollView.contentSize = CGSizeMake(320, 530);
    } else{
        self.scrollView.frame = CGRectMake(0, 0, 320, 416);
        self.scrollView.contentSize = CGSizeMake(320, 490);
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3];	
//    self.view.center = CGPointMake(160.0, 208);
//    regButton.center = CGPointMake(160.0, 326);
//    [UIView commitAnimations];

//    self.scrollView.frame = CGRectMake(0, 0, 320, 416);
//    self.scrollView.contentSize = CGSizeMake(320, 416);
}

- (void) ShowMessageWithText:(NSString*)text {
    [indicator stopAnimating];
    [indicatorView removeFromSuperview];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) setPhotoEditorCustomizationOptions
{
    // Set Tool Order
    NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFFrames, kAFStickers, kAFEnhance, kAFOrientation, kAFCrop, kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme, kAFSharpness];
    [AFPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set Custom Crop Sizes
    [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:NO];
    NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
    [AFPhotoEditorCustomization setCropToolPresets:@[square]];
}


- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage
{
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    // Initialize the photo editor and set its delegate
    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:editingResImage];
    [photoEditor setDelegate:self];
    
    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    //    // If a high res image is passed, create the high res context with the image and the photo editor.
    //    if (highResImage) {
    //        [self setupHighResContextForPhotoEditor:photoEditor withImage:highResImage];
    //    }
    
    // Present the photo editor.
    [self presentViewController:photoEditor animated:YES completion:nil];
}
- (void) didFinish:(SeequVideoRecorerViewController*)controller Image:(UIImage*)img HighResolutionImage:(UIImage*)himg fromLibrary:(BOOL)library {
    [controller dismissViewControllerAnimated:NO completion:^{
        //[controller.captureManager.previewLayer removeFromSuperlayer];
        [controller.captureManager finish];
    }];
    
    NSLog(@"img.size.actual: %@", NSStringFromCGSize(img.size));
    
    if (img.size.width > 800 || img.size.height > 800) {
        if (img.size.width > img.size.height) {
            int newHeight = (img.size.height*800)/img.size.width;
            img = [self imageWithImage:img scaledToSize:CGSizeMake(800, newHeight)];
        } else {
            int newWidth = (img.size.width*800)/img.size.height;
            img = [self imageWithImage:img scaledToSize:CGSizeMake(newWidth, 800)];
        }
    }
    ///@todo Gor clean  AFPhotoEditorController
    NSLog(@"img.size.modified: %@", NSStringFromCGSize(img.size));
    
    
    img = [UIImage rotateImage:img byDegrees:0];
    
    if (img.size.height > img.size.width) {
        img = [self imageByCropping:img toRect:CGRectMake(0, 80, img.size.width, img.size.width)];
    } else {
        img = [self imageByCropping:img toRect:CGRectMake(80, 0, img.size.height, img.size.height)];
    }
    
    img = [UIImage rotateImage:img byDegrees:180];
    img = [UIImage imageWithCGImage:img.CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
    
    [self.proImageView setImage:img];
    isPhoneTaked = YES;
    self.proImageViewRamka.hidden = NO;
    
    maskView = [[RamkaView alloc] initWithFrame:CGRectMake(0, 0, 78, 79)];
    [self.proImageView.layer setMask:maskView.layer];
    
    //    [self launchPhotoEditorWithImage:img highResolutionImage:img];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField!=firstNameTxt && textField!=lastNameTxt) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
          return NO;
    }
    return YES;
}


// This is called when the user taps "Done" in the photo editor.
- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    
    //    float rads = 0;
    UIImage *TakedImage = image;
    
    TakedImage = [UIImage rotateImage:TakedImage byDegrees:0];
    
    if (TakedImage.size.height > TakedImage.size.width) {
        TakedImage = [self imageByCropping:TakedImage toRect:CGRectMake(0, 80, TakedImage.size.width, TakedImage.size.width)];
    } else {
        TakedImage = [self imageByCropping:TakedImage toRect:CGRectMake(80, 0, TakedImage.size.height, TakedImage.size.height)];
    }
    
    TakedImage = [UIImage rotateImage:TakedImage byDegrees:180];
    TakedImage = [UIImage imageWithCGImage:TakedImage.CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
    
    [self.proImageView setImage:TakedImage];
    isPhoneTaked = YES;
    self.proImageViewRamka.hidden = NO;
    
    maskView = [[RamkaView alloc] initWithFrame:CGRectMake(0, 0, 78, 79)];
    [self.proImageView.layer setMask:maskView.layer];
	   
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
