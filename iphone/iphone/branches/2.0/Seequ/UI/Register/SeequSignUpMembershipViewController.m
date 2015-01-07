//
//  SeequCreateMembership_2ViewController.m
//  ProTime
//
//  Created by Karen on 10/18/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequSignUpMembershipViewController.h"
#import "SeequTermsPrivacyViewController.h"
#import "ActivityStorage.h"
#import "MessageCoreDataManager.h"
#import "idoubs2AppDelegate.h"
#import "CDGroup.h"
#import "CDMessageOwner.h"
#import "CJSONDeserializer.h"
#import "NavigationBar.h"
#import "BackBarButton.h"
#import "Common.h"


@interface SeequSignUpMembershipViewController () {
    NSString *email;
    NSString *password;
}
- (void) CreateAccount;
- (void) RemoveMask;
@end

@implementation SeequSignUpMembershipViewController

@synthesize dictPersonData;
@synthesize dictIntroduction;

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
}

- (IBAction)onButtonLogIn:(id)sender {
        
        [self performSelectorOnMainThread:@selector(GoToAccountActivateWithSeequID)
                               withObject:nil
                            waitUntilDone:YES];
}

- (void) GoBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClickCreateMemberShip:(id)sender{
        /*
        locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[locationManager startUpdatingLocation];
         */
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Address Book Matching"
//                                                    message:@"Find your phone contacts on Seequ. All data is secure and protected."
//                                                   delegate:self
//                                          cancelButtonTitle:@"Don't Allow"
//                                          otherButtonTitles:@"Ok", nil];
//    alert.tag = 1;
//    [alert show];
        
        [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Creating Account..."];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [NSThread detachNewThreadSelector:@selector(CreateAccount)
                                 toTarget:self
                               withObject:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
                [[ContactStorage sharedInstance] deleteContactStorage];
                [[ActivityStorage sharedInstance] deleteActivityFromStorage];
                [[MessageCoreDataManager sharedManager] deleteEntity:[CoreDataManager managedObjectContext] andEntityName:NSStringFromClass([CDMessageOwner class])];
                [[MessageCoreDataManager sharedManager] deleteEntity:[CoreDataManager managedObjectContext] andEntityName:NSStringFromClass([CDGroup class])];
        });

        
}

- (IBAction)onClickTermsOfService:(id)sender{
    SeequTermsPrivacyViewController *controller = [[SeequTermsPrivacyViewController alloc] initWithNibName:@"SeequTermsPrivacyViewController" bundle:nil];
    controller.videoViewState = 0;
    controller.segmentState = @"T";
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)onClickPrivaciPolicy:(id)sender{
    SeequTermsPrivacyViewController *controller = [[SeequTermsPrivacyViewController alloc] initWithNibName:@"SeequTermsPrivacyViewController" bundle:nil];
    controller.videoViewState = 0;
    controller.segmentState = @"P";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
                [UIView beginAnimations:@"allertClick" context:nil];
                [UIView  setAnimationDuration:0.3];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                self.buttonCreateMembership.hidden=YES;
                self.buttonLogIn.hidden=NO;
                [UIView commitAnimations];
        }
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are You Sure?"
//                                                            message:@"Without access to your address book we cannot find your contacts already on the Seequ Network."
//                                                           delegate:self
//                                                  cancelButtonTitle:@"Don't Allow"
//                                                  otherButtonTitles:@"Allow", nil];
//            alert.tag = 2;
//            [alert show];
//        } else {
////            WelcomeSeequViewController *welcomeSeequ = [[WelcomeSeequViewController alloc] initWithNibName:@"WelcomeSeequViewController" bundle:nil];
////            NSLog(@"self.dictPersonData === %@",self.dictPersonData);
////            NSLog(@"self.dictIntroduction === %@",self.dictIntroduction);
////            welcomeSeequ.dictPersonData = self.dictPersonData;
////            welcomeSeequ.dictIntroduction = self.dictIntroduction;
////            [self.navigationController pushViewController:welcomeSeequ animated:YES];
//            [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Creating Account..."];
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//            [NSThread detachNewThreadSelector:@selector(CreateAccount)
//                                     toTarget:self
//                                   withObject:nil];
//        }
//    } else {
//        WelcomeSeequViewController *welcomeSeequ = [[WelcomeSeequViewController alloc] initWithNibName:@"WelcomeSeequViewController" bundle:nil];
//        NSLog(@"self.dictPersonData === %@",self.dictPersonData);
//        NSLog(@"self.dictIntroduction === %@",self.dictIntroduction);
//        welcomeSeequ.dictPersonData = self.dictPersonData;
//        welcomeSeequ.dictIntroduction = self.dictIntroduction;
//        [self.navigationController pushViewController:welcomeSeequ animated:YES];
      
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) CreateAccount {
    @autoreleasepool {
        NSString *firstName = [self.dictPersonData objectForKey:@"firstName"];
        NSString *lastName = [self.dictPersonData objectForKey:@"lastName"];
        email = [self.dictPersonData objectForKey:@"email"];
        password = [self.dictPersonData objectForKey:@"password"];
        NSString * title = [self.dictIntroduction objectForKey:@"title"];
        title = [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        title = [title stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        
        NSString *company = [self.dictIntroduction objectForKey:@"company"];
        company = [company stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        company = [company stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        
        NSString *status = [self.dictIntroduction objectForKey:@"status"];
        status = [status stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        status = [status stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        
        NSString *regUrl = [NSString stringWithFormat:@"%@/user/create?",[Common getBaseTomcatLink]];
        
        NSData *dataObj = UIImageJPEGRepresentation([self.dictPersonData objectForKey:@"image"], 1.0);
        NSString *string = [NSString stringWithFormat:@"%@email=%@&password=%@&firstName=%@&lastName=%@", regUrl, email, password, firstName, lastName];
        string = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        company = [@"&company=" stringByAppendingString:company];
        string = [string stringByAppendingString:company];
        
        status = [@"&introduction=" stringByAppendingString:status];
        string = [string stringByAppendingString:status];
        
        title = [@"&title=" stringByAppendingString:title];
        string = [string stringByAppendingString:title];
        string = [string stringByAppendingString:@"&country=244&city=Nashville&abbrev=42&timeZone=6"];
        
        
        NSLog(@"[SEND] {WelcomeSeequViewController}[CreateAccount] - %@", string);
        
        NSHTTPURLResponse * response;
        NSError * error;
        
        NSString *boundry = @"-----------------------------185291718831015";
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:string]];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry] forHTTPHeaderField:@"Content-Type"];
        
        
        NSMutableData *postData = [NSMutableData dataWithCapacity:[dataObj length] + 512];
        [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\"test.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:dataObj];
        [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [urlRequest setHTTPBody:postData];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        
        if (!data) {
            NSLog(@"[ERR] {WelcomeSeequViewController}[CreateAccount] - NO DATA");
            [self performSelectorOnMainThread:@selector(RemoveMask)
                                   withObject:nil
                                waitUntilDone:YES];
            
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Account Create Error.", @"title", @"Request time out.", @"message", nil];
            [self performSelectorOnMainThread:@selector(ShowMessageWithDict:)
                                   withObject:dict
                                waitUntilDone:YES];
            
            return;
        }
        
        NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        NSData *jsonData = [allData dataUsingEncoding:NSUTF32BigEndianStringEncoding];
        
        error = nil;
        NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
        
        NSLog(@"[RCV] {WelcomeSeequViewController}[CreateAccount] - %@", dictionary);
        if ([[dictionary objectForKey:@"success"] intValue] == 1) {
//                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Mail Verification" message:@"Verification email has been sent to your email address. Please verify and press Log In." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                 alert.tag=1;
//                [alert show];
                [self performSelectorOnMainThread:@selector(GoToAccountActivateWithSeequID)
                                       withObject:nil
                                    waitUntilDone:YES];
        } else {
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Account Create Error.", @"title", [dictionary objectForKey:@"message"], @"message", nil];
            [self performSelectorOnMainThread:@selector(ShowMessageWithDict:)
                                   withObject:dict
                                waitUntilDone:YES];
        }
        
        [self performSelectorOnMainThread:@selector(RemoveMask)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

- (void) GoToAccountActivateWithSeequID {
    NSString * retValu = [Common LoginWithSeequID:email
                                  Password:password];
        BOOL isAuth =retValu?NO:YES;
    
    if (!isAuth) {
        [self performSelector:@selector(RemoveMask) withObject:nil afterDelay:1.0];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ."
                                                        message:retValu
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    [self RemoveMask];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autologin"];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"pass"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    RegisteringViewController *controller = [[RegisteringViewController alloc] initWithNibName:@"RegisteringViewController" bundle:nil];
    controller.account.text = email;
    controller.password.text = password;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) ShowMessageWithDict:(NSDictionary*)dict {
    [self RemoveMask];
    NSString *alertTitle = [dict objectForKey:@"title"];
    NSString *message = [dict objectForKey:@"message"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void) RemoveMask {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[idoubs2AppDelegate sharedInstance] HideLoadingView];
}

@end
