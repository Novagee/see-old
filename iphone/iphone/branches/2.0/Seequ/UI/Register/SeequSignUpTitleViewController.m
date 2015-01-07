//
//  SeequCreateMembershipViewController.m
//  ProTime
//
//  Created by Karen on 10/18/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//
#import "Common.h"
#import "SeequSignUpTitleViewController.h"
#import "SeequSignUpMembershipViewController.h"
#import "NavigationBar.h"
#import "BackBarButton.h"

@interface SeequSignUpTitleViewController ()

@end

@implementation SeequSignUpTitleViewController

@synthesize fieldTitle;
@synthesize fieldCompany;
@synthesize dictPersonData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    if(IS_IOS_7){
    self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    ((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleSignUp.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    BackBarButton *nextBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"SeequNavigationButtonNext.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoNext)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
    
    fieldCompany.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"company"];
    fieldTitle.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"title"];
    self.textViewStatus.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"status"];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"status"] isEqualToString:@""]) {
        self.labelStatus.hidden = NO;
        self.labelStatus.text = @"*Status";
    } else {
        self.labelStatus.hidden = YES;
    }
    
    if(IS_IPHONE_5) {
//        [self.imageViewStatus setImage:[UIImage imageNamed:@"SeequSignUpStatusBG568@2x.png"]];
        self.imageViewStatus.frame = CGRectMake(8, 61, 304, 92 + 88);
        self.textViewStatus.frame = CGRectMake(20, 70, 280, 77 + 88);
    }
}

- (void) GoBack {
    [[NSUserDefaults standardUserDefaults] setObject:fieldCompany.text forKey:@"company"];
    [[NSUserDefaults standardUserDefaults] setObject:fieldTitle.text forKey:@"title"];
    [[NSUserDefaults standardUserDefaults] setObject:self.textViewStatus.text forKey:@"status"];

    [self.fieldCompany resignFirstResponder];
    [self.fieldTitle resignFirstResponder];
    [self.textViewStatus resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) GoNext {
    if ([self validateFields]) {
        [self hideRedAlertView];
        [[NSUserDefaults standardUserDefaults] setObject:fieldCompany.text forKey:@"company"];
        [[NSUserDefaults standardUserDefaults] setObject:fieldTitle.text forKey:@"title"];
        [[NSUserDefaults standardUserDefaults] setObject:self.textViewStatus.text forKey:@"status"];
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              self.fieldTitle.text,@"title",
                              self.fieldCompany.text,@"company",
                              self.textViewStatus.text,@"status", nil];
        SeequSignUpMembershipViewController *signUpMembershipViewController = [[SeequSignUpMembershipViewController alloc] initWithNibName:@"SeequSignUpMembershipViewController" bundle:nil];
        signUpMembershipViewController.dictPersonData = self.dictPersonData;
        signUpMembershipViewController.dictIntroduction = dict;
        [self.navigationController pushViewController:signUpMembershipViewController animated:YES];
    } else{
        [self showRedAlertView];
    }
    [self.fieldCompany resignFirstResponder];
    [self.fieldTitle resignFirstResponder];
    [self.textViewStatus resignFirstResponder];
}

-(BOOL)validateFields{
    NSString *errorMessage;
    if (self.textViewStatus.text.length && self.fieldTitle.text.length) {
        return YES;
    } else {
        if (!self.textViewStatus.text.length && !self.fieldTitle.text.length) {
            errorMessage = @"*Empty Title and Status fields";
        } else
            if (!self.textViewStatus.text.length) {
                errorMessage = @"*Empty Status field";
            } else {
                errorMessage = @"*Empty Title field";
            }
        self.labelError.text = errorMessage;
        return NO;
    }
}

- (void)showRedAlertView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    self.viewWarning.center = CGPointMake(160, 19);
    self.viewMain.center = CGPointMake(160, 248);
    [UIView commitAnimations];
}

- (void)hideRedAlertView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    self.viewWarning.center = CGPointMake(160, -20);
    self.viewMain.center = CGPointMake(160, 208);
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (!self.textViewStatus.text.length) {
        self.labelStatus.hidden = NO;
        self.labelStatus.text = @"*Status";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self GoNext];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    self.labelStatus.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextViewStatus:nil];
    [self setLabelStatus:nil];
    [self setViewWarning:nil];
    [self setLabelError:nil];
    [self setViewMain:nil];
    [self setImageViewStatus:nil];
    [super viewDidUnload];
}
@end
