#import "RegisteringViewController.h"
#import "idoubs2AppDelegate.h"
#import "SeequContactsViewController.h"
#import "SeequActivityViewController.h"
#import "CJSONDeserializer.h"
#import "SignUpViewController.h"
#import "Common.h"
#import "tsk_debug.h"
#import "XMPPManager.h"
#import "TestFlight.h"
#import "NavigationBar.h"
#import "BackBarButton.h"
#import "ActivityStorage.h"
#import "MessageCoreDataManager.h"
#import "CDMessageOwner.h"
#import "CDGroup.h"

@implementation RegisteringViewController


@synthesize activityIndicatorView;
@synthesize account;
@synthesize password;
@synthesize removeView;
@synthesize lblRegistrationProgress;
@synthesize maskView;
@synthesize lockEmailField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    if(IS_IOS_7){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }else{
      [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
	self.lblRegistrationProgress.text = @"Login in Progress.";
	
    [[idoubs2AppDelegate sharedInstance].window addSubview:self.maskView];
    self.maskView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnXMPPAuthenticationEvent:) name:kXMPPAuthenticateNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRTMPEvent:) name:@"Registration_is_ready" object:nil];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    ((NavigationBar*) self.navigationController.navigationBar).hidden = NO;
    ((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleSeequ.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    if (self.lockEmailField) {
        self.lockEmailField = NO;
        self.account.enabled = NO;
        self.account.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [imageView setImage:[UIImage imageNamed:@"seequNavigationDefaultBG.png"]];
        [self.view addSubview:imageView];
        
        UIImageView *imageViewtitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 68, 18)];
        [imageViewtitle setImage:[UIImage imageNamed:@"seequNavigationTitleSeequ.png"]];
        imageViewtitle.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
        [imageView addSubview:imageViewtitle];
        
        self.removeView.center = CGPointMake(self.removeView.center.x, self.removeView.center.y + 44);
    }
}


- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
    
	idoubs2AppDelegate *appDelegate = [idoubs2AppDelegate sharedInstance];
    
	int netStatus = [appDelegate checkNetworkStatus];
	
	if (!netStatus) {
		UIAlertView *internetAlert = [[UIAlertView alloc] initWithTitle:@"Check Internet"
                                                                        message:@"Please check your internet connection as the Seequ system does not seem to be accessible"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
		
		[internetAlert show];
        [self touchesBegan:nil withEvent:nil];
		self.activityIndicatorView.hidden = YES;
        
	} else {
		BOOL isRegistered = [[NSUserDefaults standardUserDefaults] boolForKey:@"autologin"];
		if (isRegistered) {
			NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
			NSString *pass = [[NSUserDefaults standardUserDefaults] objectForKey:@"pass"];
			
			self.account.text = user;
			self.password.text = pass;
			
			[self SignInButtonClick:nil];
			
			return;
		} else {
            [account becomeFirstResponder];
        }
	}
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) SignInButtonClick: (id)sender{
	[account resignFirstResponder];
	[password resignFirstResponder];
    
    [Common sharedCommon].login_failed_time = 0;
    
    int netStatus = [[idoubs2AppDelegate sharedInstance] checkNetworkStatus];
	
	if (!netStatus) {
		UIAlertView *internetAlert = [[UIAlertView alloc] initWithTitle:@"Check Internet"
                                                                        message:@"Please check your internet connection as the Seequ system does not seem to be accessible"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
		
		[internetAlert show];
		self.activityIndicatorView.hidden = YES;
        [self touchesBegan:nil withEvent:nil];
        
        return;
	}
    
	self.lblRegistrationProgress.text = @"Login in Progress.";
    
	if (self.account && [self.account.text length] && self.password && [self.password.text length]) {
        [self.activityIndicatorView startAnimating];
        self.maskView.hidden = NO;
        [NSThread detachNewThreadSelector:@selector(startReg) toTarget:self withObject:nil];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Empty email or password" 
                                                               delegate:nil									  
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
		[alert show];		
	}
}

- (void)startReg {
    if ([Common validateEmail:self.account.text]) {
        NSString *retval;
        
        NSString *error_message = [Common GetSeequIDByEmail:self.account.text SeequID:&retval];
        NSLog(@"DEBUG: [LOGIN] Start: user-%@, pass-%@", retval, self.password.text);
        if (error_message) {
            [self performSelectorOnMainThread:@selector(hideMaskView) withObject:nil waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(ShowMessageWithText:) withObject:error_message waitUntilDone:YES];
        } else {
                NSString *oldUser=[[NSUserDefaults standardUserDefaults] stringForKey:@"user"];
                if (oldUser) {
                        if(![oldUser isEqualToString:self.account.text]){
                                [[ContactStorage sharedInstance] deleteContactStorage];
                                [[ActivityStorage sharedInstance] deleteActivityFromStorage];
                                [[MessageCoreDataManager sharedManager] deleteEntity:[CoreDataManager managedObjectContext] andEntityName:NSStringFromClass([CDMessageOwner class])];
                                [[MessageCoreDataManager sharedManager] deleteEntity:[CoreDataManager managedObjectContext] andEntityName:NSStringFromClass([CDGroup class])];
                            [idoubs2AppDelegate sharedInstance].isRosterReceived = NO;
                        }
                        
                }

            [[NSUserDefaults standardUserDefaults] setObject:self.password.text forKey:@"IDENTITY_PASSWORD"];
            [[NSUserDefaults standardUserDefaults] setObject:retval forKey:@"IDENTITY_IMPI"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self performSelectorOnMainThread:@selector(goNextStep:) withObject:retval waitUntilDone:YES];
        }
    } else {
        [self performSelectorOnMainThread:@selector(hideMaskView) withObject:nil waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(ShowMessageWithText:) withObject:@"Not a valid email address." waitUntilDone:YES];
        return;
    }
}

- (void)goNextStep:(NSString *)retval{
    if (retval == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Oops, something went wrong with the login process. Please try again later."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [self hideMaskView];
        self.navigationController.navigationItem.leftBarButtonItem.enabled = YES;
        [self touchesBegan:nil withEvent:nil];
        
        return;
    } else if ([retval length] != 8) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Email or password is incorect."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [self hideMaskView];
        [self touchesBegan:nil withEvent:nil];
        
        return;
    }
    else {
        [self.activityIndicatorView startAnimating];
        self.maskView.hidden = NO;
        [self initDefaultsSetingsWithUser:retval Password:self.password.text];
        [self performSelector:@selector(StartSIPRegistration) withObject:nil afterDelay:1.0];
    }
}

- (void)hideMaskView{
    [self.activityIndicatorView stopAnimating];
    self.maskView.hidden = YES;
}

- (IBAction)ForgotPasswordButtonClick:(id)sender {
	[account resignFirstResponder];
	[password resignFirstResponder];
    
    int netStatus = [[idoubs2AppDelegate sharedInstance] checkNetworkStatus];
	
	if (!netStatus) {
		UIAlertView *internetAlert = [[UIAlertView alloc] initWithTitle:@"Check Internet"
                                                                message:@"Please check your internet connection as the Seequ system does not seem to be accessible"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
		
		[internetAlert show];
        [self touchesBegan:nil withEvent:nil];
        
        return;
	}
    
	if (self.account && [self.account.text length]) {
        if ([Common validateEmail:self.account.text]) {
            [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Sending recovery instructions"];
            [NSThread detachNewThreadSelector:@selector(SendForgotPassword) toTarget:self withObject:nil];
        } else {
            [self ShowMessageWithText:@"Not a valid email address."];
        }
    } else {
        [self ShowMessageWithText:@"Provide the registered email."];
    }
}

- (void) SendForgotPassword {
    @autoreleasepool {
        NSString *error_message = [Common SendResetPasswordWithEmail:self.account.text];
        
        if (error_message) {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                [self performSelectorOnMainThread:@selector(ShowMessageWithText:) withObject:error_message waitUntilDone:NO];
            }
        }
        
        [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(HideLoadingView) withObject:nil waitUntilDone:YES];        
    }
}

- (void) StartSIPRegistration {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autologin"]) {
        NSString * retValu = [Common LoginWithSeequID:[[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_IMPI"]
                                      Password:[[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_PASSWORD"]];
        BOOL isAuth =retValu?NO:YES;
            
        if (!isAuth) {
            [self performSelector:@selector(HideMaskView) withObject:nil afterDelay:1.0];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ."
                                                            message:retValu
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
            
            return;
        }
    }
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
        NSString *error_message = [Common RegisterPushNotificationWithDeviceToken:deviceToken registerForce:NO];
        if ([error_message isEqualToString:@"Dublicate User"]){
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Seequ" message:@"This user is already logged in from another device.By continuing log in on this device will automatically log out you from the second device." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                alert.tag=1;
                [alert show];
                return;
                
        }
    [[NSUserDefaults standardUserDefaults] setObject:self.account.text forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] setObject:self.password.text forKey:@"pass"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autologin"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"autorisation_problem"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"block_request"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
	[[idoubs2AppDelegate sharedInstance].soundService setSpeakerEnabled:1];
}

#if (XMPP_ON == 1)
- (void) RegisterXMPP {
    NSArray *accounts = [[UserEntity sharedUserEntity].listOfAccounts allValues];
    if ([accounts count] != 0) {
        [[accounts objectAtIndex:0] goToState:Offline];
        [[[accounts objectAtIndex:0] XMPPHandler] disconnectFromStream];
        
        [[UserEntity sharedUserEntity].listOfAccounts removeAllObjects];
    }
    
    NSString *pass = [[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_PASSWORD"];
    NSString *user = [NSString stringWithFormat:@"%@@im.protime.tv", [[Common sharedCommon] SeequID]];
    NSLog(@"user ==== %@",user);
    
    CoreUser* cUser = [[CoreUser alloc] initCoreUserWithUsername:user andPassword:pass];
    CoreServer* cServer = [[CoreServer alloc] initCoreServerWithHost:@"im.protime.tv" andPort:@"5222"];
    
    AccountEntity* aEntity = [[AccountEntity alloc] initAccountWithUserCredentials:cUser
                                                                    ServerSettings:cServer
                                                                     ProxySettings:nil
                                                                      DefaultState:YES
                                                                    andAccountName:@"protime"];
    
    [[UserEntity sharedUserEntity] addAccount:aEntity];
    XMPPManager *manager = [XMPPManager sharedXMPPManager];
    [[[[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] XMPPHandler] xmppStream] addDelegate:manager];
    
    SeequContactsViewController *contactsViewController = [[idoubs2AppDelegate sharedInstance].contacts.viewControllers objectAtIndex:0];
    
    [aEntity goToState:Online];
    
    [contactsViewController fetchedResultsController];
}

#endif //(XMPP_ON == 1)

#pragma mark -
#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        [self.password becomeFirstResponder];
    } else {
        [self SignInButtonClick:nil];
    }
	
	return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (account.editing)
        [account resignFirstResponder];
    if (password.editing)
        [password resignFirstResponder];
    
    if (self.navigationController) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        removeView.center = CGPointMake(removeView.center.x, 240);
        [UIView commitAnimations];
    }
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */
-(BOOL)shouldAutorotate{
    return  NO;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	[self.activityIndicatorView stopAnimating];
}

-(void) onRTMPEvent:(NSNotification*)notification {
    [self performSelectorOnMainThread:@selector(onRTMPEventOnMainThread:)
                           withObject:notification
                        waitUntilDone:NO];
    
    return;
}

-(void) onRTMPEventOnMainThread:(NSNotification*)notification {
    NSDictionary *userInfo = notification.object;
        RTMP_EVENT_TYPE rtmp_call_event = (RTMP_EVENT_TYPE)[[userInfo objectForKey:@"rtmp_call_event"] intValue];
        switch (rtmp_call_event) {
                case RTMP_EVENT_CONNECTED:
                        break;
                case RTMP_REG_EVENT_TYPE_REGISTRATION_SUCCESS: {
                        [NSThread detachNewThreadSelector:@selector(PreparingAccount)
                                                 toTarget:self
                                               withObject:nil];
                        
#if (XMPP_ON == 1)
                        [self RegisterXMPP];
#endif //(XMPP_ON == 1)
                        
                        [self.maskView setHidden:YES];
                        [self dismissViewControllerAnimated:NO completion:nil];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:self.account.text forKey:@"user"];
                        [[NSUserDefaults standardUserDefaults] setObject:self.password.text forKey:@"pass"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                }
                        break;
                case RTMP_EVENT_DISCONNECTED:
                case RTMP_REG_EVENT_TYPE_UNREGISTRATION_SUCCESS:
                case RTMP_REG_EVENT_TYPE_REGISTRATION_FAILURE: {
                        [self performSelector:@selector(HideMaskView) withObject:nil afterDelay:1.0];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ."
                                                                        message:@"Username or password is incorect."
                                                                       delegate:self
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                        [alert show];
                }
                        break;
                default:
                        break;
        }
}

-(void) OnXMPPAuthenticationEvent:(NSNotification*)notification {
    NSDictionary *dict = [notification object];
    if (dict) {
        BOOL isAuthenticated = [[dict objectForKey:@"Authenticate"] boolValue];
        if (!isAuthenticated) {
#if XMPP_ON
            [self RegisterXMPP];
#endif //XMPP_ON
            [self performSelector:@selector(HideMaskView) withObject:nil afterDelay:1.0];
        }
    }
}

- (void) PreparingAccount {
    @autoreleasepool {
//        NSDictionary *dictionary;
//        NSString *error_msg = [Common GetAllUsersBySeequID:[[Common sharedCommon] SeequID] UserList:&dictionary Save:YES];
//        
//        if (!error_msg && dictionary) {
//            NSDictionary *return_values = [dictionary objectForKey:@"return_values"];
//            double lastModDate = [[return_values objectForKey:@"lastModDate"] doubleValue];
//            [[NSUserDefaults standardUserDefaults] setDouble:lastModDate forKey:@"lastModDate"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            
//            [Common postNotificationWithName:kContactListNotification object:nil];            
//        }
  
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//               [Common GetAllUsersBySeequID:[Common sharedCommon].SeequID];
//        });


   
        int ignored_request_count = [Common GetProfileInfoByPTID:[[Common sharedCommon] SeequID] withActivityBadgCount:YES];
        [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(SetRecentTabBadgValue:) withObject:[NSString stringWithFormat:@"%d", ignored_request_count] waitUntilDone:YES];
        
//        [NSThread detachNewThreadSelector:@selector(RegisterForPush) toTarget:[idoubs2AppDelegate sharedInstance] withObject:nil];
        
        if ([idoubs2AppDelegate sharedInstance].isFromRemotNotification) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[idoubs2AppDelegate sharedInstance].tabBarController presentViewController:[idoubs2AppDelegate sharedInstance].preparForCallAnswerViewController animated:NO completion:nil];
            });
        }
    }
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid
                 xmppStream:(XMPPStream *)xmppStream {
	/*
	 *  Reloading just the changed row, if it is visible would be a better solution.
	 */
}

- (void) HideMaskView {
	self.maskView.hidden = YES;
}


- (void) initDefaultsSetingsWithUser:(NSString*)user Password:(NSString*)pass {
	NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
	NSString *proxy;
	int proxyport;
	NSString *realm;
	NSString *stun;
    
    NSString *displayname = [NSString stringWithFormat:@"%@ %@", [Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
    
    //  XMPP Default settings, must be on
    NSString *publicId = [userDef objectForKey:@"IDENTITY_IMPU"];
    if (!publicId) {
        [userDef setBool:YES forKey:@"online"];
        [userDef setBool:YES forKey:@"enable_h264"];
    }
    //    
    /////////////// NATT_HACK_AOR configuration begin
    [userDef setBool:false   forKey:@"NATT_HACK_AOR"];
    [userDef setInteger:500 forKey:@"NATT_HACK_AOR_TIMEOUT"];
    /////////////// NATT_HACK_AOR configuration end..
	
	BOOL isStun = YES;
	BOOL isProxy = YES;
	
	realm = @"sip.protime.tv";
	//setup proxy for TLS and (UDP,TCP)
	proxy = @"sip.protime.tv";
	proxyport = 5060;
	stun    = @"stun.voipdiscount.com";
	
	NSString *type = @"sip1.protime.tv";
    if([type isEqualToString:@"sip1.protime.tv"]) {
        realm = @"sip1.protime.tv";
        proxy = @"sip1.protime.tv";
        proxyport = 5060;
        stun    = @"numb.viagenie.ca";
        isStun = YES;
        isProxy = YES;}
    if([type isEqualToString:@"sip.protime.tv"]) {
        realm = @"sip.protime.tv";
        proxy = @"sip.protime.tv";
        proxyport = 5060;
        stun    = @"numb.viagenie.ca";
        isStun = YES;
        isProxy = YES;
    } else if([type isEqualToString:@"192.168.0.10"]){
        realm = @"192.168.0.10";
        //setup proxy for TLS and (UDP,TCP)
        proxy = @"192.168.0.10";
        proxyport = 5060;
        stun    = @"stun.ekiga.net";
        isStun = YES;
        isProxy = YES;
    } else if([type isEqualToString:@"hawkstream.com"]){
        realm = @"hawkstream.com";
        proxy = @"hawkstream.com";
        proxyport = 5060;
        stun    = @"numb.viagenie.ca";
        isStun = NO;
        isProxy = YES;
    }
	
	NSArray *filePaths =	NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *path = [filePaths objectAtIndex:0];
	
   // path =[[NSBundle mainBundle] pathForResource:@"h264dataRTP.h264" ofType:@""];
    
    NSLog(@"path---%@", path);
    
//    tsk_debug_set_Log_File_Name([path UTF8String]);    
	
	//configure identity
	publicId = [NSString stringWithFormat:@"sip:%@@%@",user,realm];
	//NSString *privateId = [NSString stringWithFormat:@"sip:%@@%@",user,realm];
	NSString *privateId = [NSString stringWithFormat:@"%@", user];
	NSString *passwordValue = [NSString stringWithFormat:@"%@",pass];
	
    //[userDef setObject:user          forKey:IDENTITY_DISPLAY_NAME];
    [userDef setObject:displayname forKey:@"IDENTITY_DISPLAY_NAME"];
	[userDef setObject:publicId      forKey:@"IDENTITY_IMPU"];                  // public id
	[userDef setObject:privateId     forKey:@"IDENTITY_IMPI"];                  // private id
	[userDef setObject:passwordValue forKey:@"IDENTITY_PASSWORD"];              // password
	[userDef setObject:realm         forKey:@"NETWORK_REALM"];                  // realm 
	[userDef setBool:NO              forKey:@"NETWORK_USE_EARLY_IMS"];          // 3GPP Early IMS
	
	// log //
	NSLog(@"publicId = %@",publicId);
	NSLog(@"privateId = %@",privateId);
	NSLog(@"passwordValue = %@",passwordValue);
	NSLog(@"realm = %@",realm);
	
	// configuration NATT
	[userDef setBool:isStun forKey:@"NATT_USE_STUN"];
	[userDef setBool:NO forKey:@"NATT_STUN_DISCO"];
	
	[userDef setObject:isStun?stun:@"" forKey:@"NATT_STUN_SERVER"];
	[userDef setInteger:isStun?3478:0 forKey:@"NATT_STUN_PORT"];
	
	// configuration network
	[userDef setBool:YES forKey:@"NETWORK_USE_WIFI"];
	[userDef setBool:YES forKey:@"NETWORK_USE_3G"];
    
	if(isProxy)
	{
		[userDef setObject:proxy forKey:@"NETWORK_PCSCF_HOST"];
		[userDef setInteger:proxyport forKey:@"NETWORK_PCSCF_PORT"];
	}
	
    [userDef setObject:@"TCP" forKey:@"NETWORK_TRANSPORT"];
	[userDef setObject:@"IPv4" forKey:@"NETWORK_IP_VERSION"];
	
	//security configuration
	///////////// test certificate
	//[userDef setBool:ipSec forKey:@"ip_sec_agree"];
	//[userDef setObject:@"0ddefcd" forKey:@"SECURITY_IMSAKA_OPID"];
	
	[userDef setBool:NO forKey:@"NETWORK_USE_SIGCOMP"];
	
	// configuration Qos
    
	[userDef setObject:@"none" forKey:@"QOS_PRECOND_STRENGTH"];
	[userDef setObject:@"none" forKey:@"QOS_PRECOND_TYPE"];
	[userDef setObject:@"Low" forKey:@"QOS_PRECOND_BANDWIDTH"];
	[userDef setObject:@"3600" forKey:@"QOS_SIP_SESSIONS_TIMEOUT"];
	
	// set codecs
	[userDef setBool:NO forKey:@"MEDIA_CODEC_USE_G729AB"];
	[userDef setBool:NO forKey:@"MEDIA_CODEC_USE_PCMA"];
    [userDef setBool:YES  forKey:@"MEDIA_CODEC_USE_SPEEX_WB"];
	[userDef setBool:NO  forKey:@"MEDIA_CODEC_USE_PCMU"];
	[userDef setBool:NO  forKey:@"MEDIA_CODEC_USE_SPEEX_NB"];
	[userDef setBool:NO  forKey:@"MEDIA_CODEC_USE_GSM"];
	[userDef setBool:NO  forKey:@"MEDIA_CODEC_USE_AMR_NB_OA"];
	[userDef setBool:NO  forKey:@"MEDIA_CODEC_USE_AMR_NB_BE"];
	[userDef setBool:NO  forKey:@"MEDIA_CODEC_USE_THEORA"];
	[userDef setBool:NO  forKey:@"MEDIA_CODEC_USE_H263"];
	[userDef setBool:NO  forKey:@"MEDIA_CODEC_USE_H263P"];
	[userDef setBool:NO  forKey:@"MEDIA_CODEC_USE_H264BP10"];
	[userDef setBool:NO  forKey:@"MEDIA_CODEC_USE_H264BP20"];
    [userDef setBool:NO  forKey:@"MEDIA_CODEC_USE_MP4VES"];

    [userDef setBool:YES  forKey:@"MEDIA_CODEC_USE_H264BP30"];
    [userDef setBool:NO forKey:@"MEDIA_CODEC_USE_VP8"];
    
    if ([userDef boolForKey:@"enable_h264"] && [self canWriteH264Hardware]) {
        [userDef setBool:YES  forKey:@"MEDIA_CODEC_USE_H264BP30"];
        [userDef setBool:NO forKey:@"MEDIA_CODEC_USE_VP8"];
    }
    
	[userDef synchronize];
}

- (BOOL) canWriteH264Hardware {
    NSString *path = [NSString stringWithFormat:@"%@/test.mp4", [self getWorkingDir]] ;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:path error:&error];
        if(error != nil) {
            NSLog(@"Error: file removing faild: %@", error);
            return NO;
        }
        
        NSLog(@"File successfully removed");
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeMPEG4 error:&error];
    NSParameterAssert(videoWriter);
    
    if(error != nil) {
        NSLog(@"Error: file removing faild: %@", error);
        
        return NO;
    }
    
    for (NSString *mediaType in videoWriter.availableMediaTypes) {
        if ([mediaType isEqualToString:@"vide"]) {
            // Add video input
            NSDictionary *videoCompressionProps = @{AVVideoAverageBitRateKey: @(250.0*1000.0),
                                                   AVVideoMaxKeyFrameIntervalKey: @12};
            
            NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                           //                                   AVVideoProfileLevelH264Baseline30, AVVideoProfileLevelKey,
                                           AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
                                           AVVideoWidthKey: @352,
                                           AVVideoHeightKey: @288,
                                           AVVideoCompressionPropertiesKey: videoCompressionProps};
            
            if ([videoWriter canApplyOutputSettings:videoSettings forMediaType:AVMediaTypeVideo]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (NSString*)getWorkingDir
{
    // Get the path to the documents directory and append the databaseName
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    return documentsDir;
}

- (void) ShowMessageWithText:(NSString*)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
#pragma UIAlertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
        if (alertView.tag==1) {
                switch (buttonIndex) {
                        case 0:{
                                self.account.text=@"";
                                self.password.text=@"";
                        }
                                        break;
                        case 1:{
                                NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
                                [Common RegisterPushNotificationWithDeviceToken:deviceToken registerForce:YES];
                                [NSThread detachNewThreadSelector:@selector(startReg) toTarget:self withObject:nil];
                                
                                
                        }
                                break;
                        default:
                                break;
                        }
               
            [self performSelectorOnMainThread:@selector(hideMaskView) withObject:nil waitUntilDone:YES];
  }
        
}
@end
