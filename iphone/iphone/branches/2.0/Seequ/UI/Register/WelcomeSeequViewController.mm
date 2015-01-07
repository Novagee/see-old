//
//  WelcomeSeequViewController.m
//  ProTime
//
//  Created by Karen on 10/18/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

//#define BASE_LINK @"http://192.168.0.222:8080/seequ/"


#import "WelcomeSeequViewController.h"
#import "RegisteringViewController.h"
#import "idoubs2AppDelegate.h"
#import "CJSONDeserializer.h"
#import "NavigationBar.h"
#import "BackBarButton.h"

@interface WelcomeSeequViewController ()

@end

@implementation WelcomeSeequViewController

@synthesize scroll;
@synthesize pageControl;
@synthesize lblPageName;
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

    arrayPageName = [[NSMutableArray alloc] initWithObjects:
                     @"Page 1",
                     @"Page 2",
                     @"Page 3",
                     @"Page 4",
                     @"Page 5", nil];
    
    arrayImages = [[NSMutableArray alloc] initWithObjects:
                   @"ExampleImage.png",
                   @"ExampleImage.png",
                   @"ExampleImage.png",
                   @"ExampleImage.png",
                   @"ExampleImage.png",nil];
    pageControl.numberOfPages = arrayImages.count;
    
    self.lblPageName.text = [arrayPageName objectAtIndex:0];
    [self createScroll];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];    
    self.navigationController.navigationBar.hidden = YES;
    firstName = [self.dictPersonData objectForKey:@"firstName"];
    lastName = [self.dictPersonData objectForKey:@"lastName"];
    email = [self.dictPersonData objectForKey:@"email"];
    password = [self.dictPersonData objectForKey:@"password"];
    title = [self.dictIntroduction objectForKey:@"title"];
    title = [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    title = [title stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    
    company = [self.dictIntroduction objectForKey:@"company"];
    company = [company stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    company = [company stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    
    status = [self.dictIntroduction objectForKey:@"status"];
    status = [status stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    status = [status stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
}

- (void)createScroll {
    scroll.contentSize = CGSizeMake(320*arrayPageName.count, 372);
    for (int i = 0; i<arrayPageName.count; i++) {
        NSString *pageName = [arrayPageName objectAtIndex:i];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*320, 170, 320, 30)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:pageName];
        [label setTextColor:[UIColor blackColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:20]];

        [scroll addSubview:label];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int page = scrollView.contentOffset.x/scrollView.frame.size.width;
    pageControl.currentPage = page;
    self.lblPageName.text = [arrayPageName objectAtIndex:page];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    int page = scrollView.contentOffset.x/scrollView.frame.size.width;
    pageControl.currentPage = page;
    self.lblPageName.text = [arrayPageName objectAtIndex:page];
}


- (IBAction)onClickPageControl:(id)sender {
    int page = pageControl.currentPage;
    CGRect frame = scroll.frame;
    frame.origin.x = page * scroll.frame.size.width;
    frame.origin.y = 0;
    [scroll scrollRectToVisible:frame animated:YES];
    self.lblPageName.text = [arrayPageName objectAtIndex:page];
}

- (IBAction)onButtonFinish:(id)sender {
    [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Creating Account..."];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSThread detachNewThreadSelector:@selector(CreateAccount)
                             toTarget:self
                           withObject:nil];
}



- (void) CreateAccount {
    @autoreleasepool {
        NSString*  tomcatBase = [Common getBaseTomcatLink];
        NSString *regUrl = [NSString stringWithFormat:@"%@/user/create?",tomcatBase];
        
        NSData *dataObj = UIImageJPEGRepresentation([self.dictPersonData objectForKey:@"image"], 1.0);
        NSString *string = [NSString stringWithFormat:@"%@email=%@&password=%@&firstName=%@&lastName=%@", regUrl, email, password, firstName, lastName];
        string = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        company = [@"&company=" stringByAppendingString:company];
        string = [string stringByAppendingString:company];
        
        status = [@"&introduction=" stringByAppendingString:status];
        string = [string stringByAppendingString:status];
        
        title = [@"&title=" stringByAppendingString:title];
        string = [string stringByAppendingString:title];
        
        
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
     NSString * retValu= [Common LoginWithSeequID:email
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
