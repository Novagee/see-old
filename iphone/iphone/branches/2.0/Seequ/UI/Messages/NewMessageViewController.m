//
//  NewMessageViewController.m
//  ProTime
//
//  Created by Jose Correa on 10/9/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "NewMessageViewController.h"

@interface NewMessageViewController ()
{
    CGSize keyboardSize;
}

@property (weak, nonatomic) IBOutlet UITextField *contactsTextField;
@property (weak, nonatomic) IBOutlet UIButton *contactsAddButton;
@property (weak, nonatomic) IBOutlet UIView *messageInputView;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@end

@implementation NewMessageViewController

- (void)viewDidLoad {
    self.messageInputView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = @{@"view": self.messageInputView};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[view]" options:0 metrics:nil views:views]];
    
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.messageInputView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self.view addConstraint:self.bottomConstraint];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

// became first responder
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextView:YES];
}

// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextView:NO];
}

// return NO to not change text
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

// called when clear button pressed. return NO to ignore (no notifications)
//- (BOOL)textFieldShouldClear:(UITextField *)textField
//{
//    
//}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (void) animateTextView:(BOOL) up
{
    const float movementDistance = keyboardSize.height; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    float movement= movement = (up ? -movementDistance : movementDistance);
    NSLog(@"***************MOVEMENT*********** %f",movement);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.messageInputView.frame = CGRectOffset(self.messageInputView.frame, 0, movement);
    [UIView commitAnimations];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"JSC: New Message View Contoller dismissed");
    }];
}

- (void)keyboardDidShow:(NSNotification *)sender {
    CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
    NSLog(@"JSC: keyboardDidShow");
    self.bottomConstraint.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);
    NSLog(@"JSC: bottomConstraint: %f", self.bottomConstraint.constant);
    [self.view layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    self.bottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
}
@end
