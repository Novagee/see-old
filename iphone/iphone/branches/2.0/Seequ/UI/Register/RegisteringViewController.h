#import <UIKit/UIKit.h>


@interface RegisteringViewController : UIViewController <UITextFieldDelegate,UIAlertViewDelegate> {
	UIActivityIndicatorView *activityIndicatorView;
	UITextField *account;
	UITextField *password;
	UIView *removeView;
	IBOutlet UILabel *lblRegistrationProgress;
	IBOutlet UIView *maskView;
	NSString *databasePath;
    BOOL isLoginXMPP;
    NSTimer *xmppRegTimer;
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) IBOutlet UITextField *account;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIView *removeView;

@property (nonatomic, strong) IBOutlet UILabel *lblRegistrationProgress;
@property (nonatomic, strong) IBOutlet UIView *maskView;
@property (nonatomic, assign) BOOL lockEmailField;


- (IBAction) SignInButtonClick: (id)sender;
//- (IBAction) SignUpButtonClick: (id)sender;
- (IBAction) ForgotPasswordButtonClick:(id)sender;

- (void) initDefaultsSetingsWithUser:(NSString*)user Password:(NSString*)pass;
- (void) StartSIPRegistration;
- (void) SendForgotPassword;

- (void) HideMaskView;
- (void) PreparingAccount;
- (BOOL) canWriteH264Hardware;
- (NSString*) getWorkingDir;
//- (void) PrepearSeequIDByMail:(NSString*)mail;
#if XMPP_ON
- (void) RegisterXMPP;
#endif //XMPP_ON
//- (void) OnXMPPAuthenticationEvent;
//- (void) OnXMPPNotAuthenticationEvent;
- (void) ShowMessageWithText:(NSString*)text;

@end