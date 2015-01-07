//
//  SeequChangePasswordViewController.m
//  ProTime
//
//  Created by Grigori Jlavyan on 7/28/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//


#import "SeequChangePasswordViewController.h"
#import "BackBarButton.h"
#import "idoubs2AppDelegate.h"

#define warningViewHeignht  45

@interface SeequChangePasswordViewController ()<UIAlertViewDelegate>

@end

@implementation SeequChangePasswordViewController

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
        if(IS_IOS_7){
                self.edgesForExtendedLayout=UIRectEdgeNone;
        }
        
        
        self.navigationItem.title=@"Change Password";
        BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(GoBack)];
        
        self.navigationItem.leftBarButtonItem = backBarButton;
        
        
        // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (IBAction)onSaveButton:(id)sender {
        NSString *errorstring;
        errorstring=[Common validatePwd:self.Password.text];
        if (!self.Password.text.length || !self.confirmPassword.text.length) {
                [self showWarningViewWithWarningText:@"Please specify password"];
                return;
        }
        if (errorstring && errorstring.length>0) {
                [self showWarningViewWithWarningText:errorstring];
                return;
        }
        if (![self.Password.text isEqualToString:self.confirmPassword.text]) {
                [self showWarningViewWithWarningText:@"Passwords do not match."];
                return;
                
        }
        [self hideWarningView];
        if (self.Password.isFirstResponder) {
                [self.Password resignFirstResponder];
        }
        if (self.confirmPassword.isFirstResponder) {
                [self.confirmPassword resignFirstResponder];
        }
        [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Password Change..."];
        [NSThread detachNewThreadSelector:@selector(setNewPassword) toTarget:self withObject:nil];
}
-(void)setNewPassword{
     NSString *errorString=[Common changePassword:self.Password.text];
        [[idoubs2AppDelegate sharedInstance] HideLoadingView];
        if (errorString) {
                [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:errorString];
        }else{
                UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Seequ" message:@"We have sent you confirmation Email. Please follow instructions in email to confirm your authority." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
        }
}
-(void)GoBack{
        [self.navigationController popViewControllerAnimated:YES];
}
-(void)showWarningViewWithWarningText:(NSString*)text{
        self.warningLabel.text=text;
        if (self.warningView.hidden) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                [UIView setAnimationDuration:0.3];
                self.warningView.hidden=NO;
                self.warningView.frame=CGRectMake(self.warningView.frame.origin.x,self.warningView.frame.origin.y+warningViewHeignht, self.warningView.frame.size.width, self.warningView.frame.size.height);
                self.fieldsView.frame=CGRectMake(self.fieldsView.frame.origin.x, self.fieldsView.frame.origin.y+warningViewHeignht, self.fieldsView.frame.size.width, self.fieldsView.frame.size.height);
                [UIView commitAnimations];
        }
        
}
-(void)hideWarningView{
        self.warningLabel.text=@"";
        if (!self.warningView.hidden) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                [UIView setAnimationDuration:0.3];
                self.warningView.hidden=YES;
                self.warningView.frame=CGRectMake(self.warningView.frame.origin.x,self.warningView.frame.origin.y-warningViewHeignht, self.warningView.frame.size.width, self.warningView.frame.size.height);
                self.fieldsView.frame=CGRectMake(self.fieldsView.frame.origin.x, self.fieldsView.frame.origin.y-warningViewHeignht, self.fieldsView.frame.size.width, self.fieldsView.frame.size.height);
                [UIView commitAnimations];
        }
}
#pragma UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
        if(buttonIndex==alertView.cancelButtonIndex){
                [[idoubs2AppDelegate sharedInstance] logOutSeequ:nil];
        }
}
@end
