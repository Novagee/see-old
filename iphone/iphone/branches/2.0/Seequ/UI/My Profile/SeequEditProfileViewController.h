//
//  EditProfileViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/6/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequBadgStatusViewController.h"
#import "SeequSecondLanguageViewController.h"
#import "SeequChooserListViewController.h"
#import "SeequStateListViewController.h"
#import "SeequCountryListViewController.h"
#import "AviaryPickerController.h"


@interface SeequEditProfileViewController : UIViewController <SeequBadgStatusViewControllerDelegate, SeequSecondLanguageViewControllerDelegate, SeequChooserListViewControllerDelegate, SeequStateListViewControllerDelegate, SeequCountryListViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, UITextFieldDelegate,AviaryPickerDelegate> {
    UIImagePickerController *piker;
    
    NSMutableArray *arrayInternet;
    NSMutableArray *arrayContactInformation;
    
    UITextView *textViewIntroduction;
    UITextView *textViewBio;
    
    NSString *badgStatus;
    int chooseLanguageTag;
    
    BOOL isChangeProfileImage;
    BOOL isChangeBadgeStatus;
    BOOL isChangeMainFields;
    BOOL isChangeLanguage;
    BOOL isChangedInternetInfo;
    BOOL isChangedContactInfo;
    BOOL isChangedSocialInfo;
    BOOL isEditing;
    BOOL isLocationChanged;
    
    UIButton *selectedButton;
    NSIndexPath *selectedIndexPath;
    UITextField *selectedTextField;
    UITextView *selectedTextView;
    NSDictionary *selectedStateDictionary;

    NSMutableArray *arrayInternetInfo;
    NSMutableArray *arrayContactInfo;
    NSMutableArray *arraySocialInfo;
    
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}


@property (nonatomic, assign) int videoViewState;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *MyTableView;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textFieldFirstName;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textFieldLastName;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textFieldSpecialist;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textFieldCompany;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewMasterBadg;


@property (strong, nonatomic) IBOutlet UITableView *viewFooter;


@property (strong, nonatomic) IBOutlet UIView *viewIndicator;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (IBAction) onButtonCancel:(id)sender;
- (IBAction) onButtonSave:(id)sender;
- (IBAction) onButtonChooseImage:(id)sender;
- (IBAction) onButtomSelectBadgeStatus:(id)sender;

- (void) onButtonDelete:(id)sender event:(id)event;

- (void) onButtonChooseInternetHeader:(id)sender event:(id)event;
- (void) onButtonChooseContactHeader:(id)sender event:(id)event;
- (void) onButtonChooseSocialHeader:(id)sender event:(id)event;


//- (void) SetLanguageWithTag:(int)tag Language:(NSString*)language;
- (NSIndexPath*) CreateIndexPathFromEvent:(id)event;

//- (void) SetLocation;
//- (void) SetLanguages;
- (void) SaveChanges;

- (void) SendProfileChangeXMPPMessage;
- (void) ShowMessageOnMainThread:(NSString*)message;

- (UITextView*) CreateTextViewWithText:(NSString*)text;

@end