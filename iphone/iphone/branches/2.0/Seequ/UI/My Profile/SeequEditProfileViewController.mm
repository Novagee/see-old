//
//  EditProfileViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/6/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequEditProfileViewController.h"
#import "idoubs2AppDelegate.h"
#import <AviarySDK/AviarySDK.h>
#import "Common.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Operations.h"
#import "ProfileFooterCell.h"
#import "AviaryPickerController.h"
#import "ProfileFooterInfo.h"
#import "SeequTimeZoneViewController.h"
#import "SeequTimeZoneInfo.h"
#import "SeequVideoRecorerViewController.h"

#define TEXT_VIEW_DIFF 25


@interface SeequEditProfileViewController () <AFPhotoEditorControllerDelegate,SeequTimeZoneViewControllerDelegate,ProfileFooterCellDelegate,SeequVideoRecorerViewControllerDelegate> {
    NSMutableArray* langArray;
    NSMutableArray* locatArray;
    NSArray* labelArray;
}
@property (nonatomic, strong) NSMutableArray * sessions;
@property (nonatomic, retain)    SeequCountry* selectedCountry;
@property (nonatomic, retain)    SeequState* selectedState; ///@note   the same  properties  as in country

@property (nonatomic,assign) BOOL isCountryListRefreshed;
@property (nonatomic,assign) BOOL isStateListRefreshed;

@property (nonatomic,retain) NSArray*  stateList;

@end

@implementation SeequEditProfileViewController


@synthesize viewIndicator;
@synthesize indicator;
@synthesize selectedCountry;
@synthesize selectedState;
@synthesize videoViewState;
@synthesize isCountryListRefreshed,isStateListRefreshed;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        
        isChangedInternetInfo = NO;
        isChangedContactInfo = NO;
        isChangedSocialInfo = NO;
        isLocationChanged = NO;
        isCountryListRefreshed = NO;
        isStateListRefreshed = NO;

        arrayInternetInfo = [[NSMutableArray alloc] initWithArray:[Common sharedCommon].contactObject.arrayInternetInfo];
        arrayContactInfo = [[NSMutableArray alloc] initWithArray:[Common sharedCommon].contactObject.arrayContactInfo];
        arraySocialInfo = [[NSMutableArray alloc] initWithArray:[Common sharedCommon].contactObject.arraySocialInfo];
        langArray = [[NSMutableArray alloc] init];
        labelArray = [NSArray arrayWithObjects:@"Primary", @"Second", @"Third", @"Fourth", nil];
        for (int i  = 0 ; i < labelArray.count; i++) {
            ProfileFooterInfo* inf = [[ProfileFooterInfo alloc] init];
            inf.name = [labelArray objectAtIndex:i];
            inf.value = @"";
            [self  SetLanguages:inf index:i];
            if (inf.value && inf.value.length > 0) {
                [langArray addObject:inf];

            }

        }
        locatArray =[[NSMutableArray alloc] init];
        NSArray* arr = [NSArray arrayWithObjects:@"Country", @"State", @"City", @"Time Zone", nil];
        for (int i  = 0 ; i < arr.count; i++) {
            ProfileFooterInfo* inf = [[ProfileFooterInfo alloc] init];
            inf.name = [arr objectAtIndex:i];
            inf.value = @"";
            [self  SetLocation:inf  index:i];
            [locatArray addObject:inf];
            
        }

    }
  
    return self;
}



-(void) updateCountries {
    NSArray* array = [Common GetAllCountries];
    isCountryListRefreshed = YES;
    [Common sharedCommon].arrayCountries = array;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onUpdateCountryList" object:array ];

}


-(void) updateStateList:(NSString*) countryID {
    NSArray* array =[Common GetStatesById:countryID];
    isStateListRefreshed = YES;
    self.selectedState = nil;
    self.stateList = array;

    [Common sharedCommon].arrayStates  = array;
  //  [Common postNotificationWithName:@"onUpdateStateList" object:array ];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onUpdateStateList" object:array ];
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    if(IS_IOS_7){
//        self.edgesForExtendedLayout=UIRectEdgeNone;
//    }
    // Do any additional setup after loading the view from its nib.
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 568) {
        self.viewIndicator.frame = CGRectMake(0, 0, 320, 548);
    }
    chooseLanguageTag = -1;
    selectedIndexPath = nil;
    badgStatus = [Common sharedCommon].contactObject.badgeStatus;
    
    self.MyTableView.tableHeaderView = self.viewHeader;
    self.MyTableView.tableFooterView = self.viewFooter;
    
  //  [self SetLanguages];
   // [self SetLocation];
    [self performSelectorInBackground:@selector(updateCountries) withObject:nil];
    [self setProfileData];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewChange:)
                                                 name:kVideoViewChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewOrientationChange:)
                                                 name:kVideoViewOrientationChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(keyboardWillShow:)
                                                    name:UIKeyboardWillShowNotification
                                                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    // Allocate Sessions Array
    NSMutableArray * sessions = [NSMutableArray new];
    [self setSessions:sessions];
    
    // Start the Aviary Editor OpenGL Load
    [AFOpenGLManager beginOpenGLLoad];
    ///register  footer  tableview  custom cell
    [self.viewFooter registerNib:[UINib nibWithNibName:@"ProfileFooterCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"CellFooter"];
}


////
- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGSize s = self.MyTableView.contentSize;
    self.MyTableView.contentSize = CGSizeMake(s.width, s.height + 255);
    
//    CGFloat keyboardTop = keyboardRect.origin.y;
//    CGRect newTextViewFrame = self.textview.frame;
//    
//    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
//    
//    // Get the duration of the animation.
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//    
//    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:animationDuration];
//    
//    textview.frame = newTextViewFrame;
//    
//    [UIView commitAnimations];
}
- (void)keyboardWillHide:(NSNotification *)notification {
    CGSize s = self.MyTableView.contentSize;
    self.MyTableView.contentSize = CGSizeMake(s.width, s.height - 255);

//    NSDictionary* userInfo = [notification userInfo];
//    
//    /*
//     Restore the size of the text view (fill self's view).
//     Animate the resize so that it's in sync with the disappearance of the keyboard.
//     */
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:animationDuration];
//    
//    //    textview.frame = self.view.bounds;
//    [self save];
//    
//    [UIView commitAnimations];
}

/////

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (selectedTextField) {
        [selectedTextField becomeFirstResponder];
    }
    if (selectedTextView) {
        [selectedTextView becomeFirstResponder];
    }

    if (UIInterfaceOrientationIsPortrait([idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation)) {
        [self setVideoViewState:self.videoViewState Animated:NO];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) onVideoViewChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    videoViewState = (VideoViewState)[eargs intValue];
}

- (void) onVideoViewOrientationChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    Video_InterfaceOrientation = (UIInterfaceOrientation)[eargs intValue];
    
    [self setVideoViewState:self.videoViewState Animated:YES];
}

- (void) setVideoViewState:(int)state Animated:(BOOL)animated {
    if ([[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
        if (UIInterfaceOrientationIsLandscape(Video_InterfaceOrientation)) {
            state = VideoViewState_HIDE;
        }
    } else {
        state = VideoViewState_HIDE;
    }

    videoViewState = state;

    int diff = 0;
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 568) {
        diff = 88;
    }
    
    CGRect frame = CGRectZero;
    switch (state) {
        case VideoViewState_NONE:
        case VideoViewState_NORMAL:
        case VideoViewState_NORMAL_MENU:
        case VideoViewState_HIDE: {
            frame = CGRectMake(0, 44, 320, 416 + diff);
            if (state == VideoViewState_HIDE) {
                if (![UIApplication sharedApplication].statusBarHidden) {
                    //self.view.frame = CGRectMake(0, 20, 320, 460 + diff);
                    if(IS_IOS_7){
                        self.view.frame = CGRectMake(0, 0, 320, 460 + diff);
                    } else{
                        self.view.frame = CGRectMake(0, 20, 320, 460 + diff);
                    }
                    
                }
            }
            if(IS_IOS_7){
               frame = CGRectMake(0, 64,  self.MyTableView.frame.size.width , self.view.frame.size.height);
                
            } else{
               frame = CGRectMake(0, 44,  self.MyTableView.frame.size.width , self.view.frame.size.height);
                
            }
           
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 320 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 320 - diff) + 20);
//            self.MyTableView.frame = frame;
    
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 228 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 228 - diff) + 20);
//            self.MyTableView.frame = frame;
        }
            break;
        default:
            break;
    }
    
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        if (animated) {
            [UIView beginAnimations:@"scrollFrame" context:nil];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.3];
        }
        self.MyTableView.frame = frame;
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (void) setProfileData {
    Common *common = [Common sharedCommon];
    self.imageViewProfile.image = common.contactObject.image;
    self.imageViewMasterBadg.image = [UIImage imageNamed:[NSString stringWithFormat:@"ProfileBadgeStatus%@.png",common.contactObject.badgeStatus]];
    
    self.textFieldFirstName.text = common.contactObject.FirstName;
    self.textFieldLastName.text = common.contactObject.LastName;
    self.textFieldSpecialist.text = common.contactObject.specialist;
    self.textFieldCompany.text = common.contactObject.company;
    textViewIntroduction = [self CreateTextViewWithText:common.contactObject.introduction];
    textViewBio = [self CreateTextViewWithText:common.contactObject.biography];
}

- (IBAction) onButtonCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction) onButtonSave:(id)sender {
    if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    } else {
        [self.view addSubview:self.viewIndicator];
        [self.indicator startAnimating];
        [self scrollViewDidScroll:nil];
        [selectedTextField resignFirstResponder];
        [selectedTextView resignFirstResponder];
        
        [NSThread detachNewThreadSelector:@selector(SaveChanges) toTarget:self withObject:nil];
    }
}

- (IBAction) onButtonChooseImage:(id)sender {
    __weak SeequEditProfileViewController* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        SeequVideoRecorerViewController*  videoRecorder = [[SeequVideoRecorerViewController alloc] initWithType:SeequRecorderTypePhoto];
        videoRecorder.captureDelegate =weakSelf;
        videoRecorder.devicePosition = AVCaptureDevicePositionBack;
        videoRecorder.forProfile = YES;

        [weakSelf presentViewController:videoRecorder animated:YES completion:nil];
        
    });

   
}




/////////////////////////////



- (void) setPhotoEditorCustomizationOptions
{
    // Set Tool Order
    NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFFrames, kAFStickers, kAFEnhance, kAFOrientation, kAFCrop, kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme,kAFSharpness];
    [AFPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set Custom Crop Sizes
    [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:NO];
    NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
    [AFPhotoEditorCustomization setCropToolPresets:@[square]];
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
- (void) didFinish:(SeequVideoRecorerViewController*)controller Image:(UIImage*)img HighResolutionImage:(UIImage*)himg  fromLibrary:(BOOL)library {
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
    
//    NSLog(@"img.size.modified: %@", NSStringFromCGSize(img.size));
//    ///@todo Gor clean  AFPhotoEditorController
    img = [UIImage rotateImage:img byDegrees:0];
//
    UIImage* im = nil;
    CGFloat delta = 0;
    if (img.size.height > img.size.width) {
        delta = img.size.height -img.size.width;
        im = [self imageByCropping:img toRect:CGRectMake(0, delta/2, img.size.width, img.size.width)];
    } else {
        delta = img.size.width -img.size.height;

        im = [self imageByCropping:img toRect:CGRectMake(delta/2, 0, img.size.height, img.size.height)];
    }
       img = [UIImage rotateImage:im byDegrees:180];
    img = [UIImage imageWithCGImage:img.CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
 
    
    [self.imageViewProfile setImage:img];
    isChangeProfileImage = YES;
    
    //    [self launchPhotoEditorWithImage:img highResolutionImage:img];

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
    
//    TakedImage = [UIImage rotateImage:TakedImage byDegrees:180];
//    TakedImage = [UIImage imageWithCGImage:TakedImage.CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
    
// JSC   [self.imageViewProfile setImage:image];
    [self.imageViewProfile setImage:TakedImage];
    isChangeProfileImage = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

////////////////////////////////
- (IBAction) onButtomSelectBadgeStatus:(id)sender {
    SeequBadgStatusViewController *badgStatusViewController = [[SeequBadgStatusViewController alloc] initWithNibName:@"SeequBadgStatusViewController" bundle:nil];
    badgStatusViewController.delegate = self;
    badgStatusViewController.BadgStatus = badgStatus;
    badgStatusViewController.videoViewState = self.videoViewState;
    [self presentViewController:badgStatusViewController animated:YES completion:^{
    }];
}

- (IBAction) CloseCamera:(id)sender {
    [piker dismissViewControllerAnimated:YES completion:^{
        
    }];}

- (IBAction) TakePicture:(id)sender {
    [piker takePicture];
}

- (IBAction) TakePhotoFromLibrary:(id)sender {
    [piker dismissViewControllerAnimated:NO completion:^{
        
    }];
    UIImagePickerController *pikerGalery = [[UIImagePickerController alloc] init];
    pikerGalery.delegate = self;
	pikerGalery.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:pikerGalery animated:YES completion:^{
        
    }];
}

- (IBAction) SwitchCamera:(id)sender {
    if (piker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerCameraDeviceFront]) {
            piker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            
        }
    } else {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerCameraDeviceRear]) {
            piker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    [picker dismissViewControllerAnimated:NO completion:^{
        
    }];
    
    //    float rads = 0;
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *TakedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        TakedImage = [UIImage rotateImage:TakedImage byDegrees:0];
        
        [self launchPhotoEditorWithImage:TakedImage highResolutionImage:TakedImage];
        
//        if (TakedImage.size.height > TakedImage.size.width) {
//            TakedImage = [self imageByCropping:TakedImage toRect:CGRectMake(0, 80, TakedImage.size.width, TakedImage.size.width)];
//        } else {
//            TakedImage = [self imageByCropping:TakedImage toRect:CGRectMake(80, 0, TakedImage.size.height, TakedImage.size.height)];
//        }
//        
//        TakedImage = [UIImage rotateImage:TakedImage byDegrees:180];
//        TakedImage = [UIImage imageWithCGImage:TakedImage.CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
//        
//        [self.imageViewProfile setImage:TakedImage];
//        isChangeProfileImage = YES;
//        isPhoneTaked = YES;
//        self.proImageViewRamka.hidden = NO;
        
//        maskView = [[RamkaView alloc] initWithFrame:CGRectMake(0, 0, 78, 79)];
//        [self.proImageView.layer setMask:maskView.layer];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Photo Editor Creation and Presentation
- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage
{   [[UIApplication sharedApplication] setStatusBarHidden:YES];
    // Initialize the photo editor and set its delegate
    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:editingResImage];
    [photoEditor setDelegate:self];
    
    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    // If a high res image is passed, create the high res context with the image and the photo editor.
    if (highResImage) {
        [self setupHighResContextForPhotoEditor:photoEditor withImage:highResImage];
    }
    
    // Present the photo editor.
    [self presentViewController:photoEditor animated:YES completion:nil];
}

#pragma mark - Photo Editor Customization


- (void) setupHighResContextForPhotoEditor:(AFPhotoEditorController *)photoEditor withImage:(UIImage *)highResImage
{
    // Capture a reference to the editor's session, which internally tracks user actions on a photo.
    __block AFPhotoEditorSession *session = [photoEditor session];
    
    // Add the session to our sessions array. We need to retain the session until all contexts we create from it are finished rendering.
    [[self sessions] addObject:session];
    
    // Create a context from the session with the high res image.
    AFPhotoEditorContext *context = [session createContextWithImage:highResImage];
    
    __block SeequEditProfileViewController * blockSelf = self;
    
    // Call render on the context. The render will asynchronously apply all changes made in the session (and therefore editor)
    // to the context's image. It will not complete until some point after the session closes (i.e. the editor hits done or
    // cancel in the editor). When rendering does complete, the completion block will be called with the result image if changes
    // were made to it, or `nil` if no changes were made. In this case, we write the image to the user's photo album, and release
    // our reference to the session.
    [context render:^(UIImage *result) {
//        if (result) {
//            UIImageWriteToSavedPhotosAlbum(result, nil, nil, NULL);
//        }
        
        [[blockSelf sessions] removeObject:session];
        
        blockSelf = nil;
        session = nil;
        
    }];
}

#pragma Photo Editor Delegate Methods


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


- (void) onButtonDelete:(id)sender event:(id)event {
    NSIndexPath *indexPath = [self CreateIndexPathFromEvent:event];
    
    if (indexPath != nil) {
        [self tableView:self.MyTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
    
    [self.MyTableView reloadData];
}

- (void) onButtonChooseInternetHeader:(id)sender event:(id)event {
    [selectedTextField resignFirstResponder];
    selectedIndexPath = [self CreateIndexPathFromEvent:event];
    selectedButton = (UIButton*)sender;
    SeequChooserListViewController *controller = [[SeequChooserListViewController alloc] initWithNibName:@"SeequChooserListViewController" bundle:nil];
    controller.delegate = self;
    controller.currentSelected = selectedButton.titleLabel.text;
    controller.arrayOfList = [[NSArray alloc] initWithObjects:@"home page", @"home", @"work", @"other", nil];
    controller.videoViewState = self.videoViewState;
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}


- (void) onButtonChooseContactHeader:(id)sender event:(id)event {
    [selectedTextField resignFirstResponder];
    selectedIndexPath = [self CreateIndexPathFromEvent:event];
    selectedButton = (UIButton*)sender;
    SeequChooserListViewController *controller = [[SeequChooserListViewController alloc] initWithNibName:@"SeequChooserListViewController" bundle:nil];
    controller.delegate = self;
    controller.currentSelected = selectedButton.titleLabel.text;
    controller.arrayOfList = [[NSArray alloc] initWithObjects:@"Email", @"Phone", nil];
    controller.videoViewState = self.videoViewState;
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}

- (void) onButtonChooseSocialHeader:(id)sender event:(id)event {
    [selectedTextField resignFirstResponder];
    selectedIndexPath = [self CreateIndexPathFromEvent:event];
    selectedButton = (UIButton*)sender;
    SeequChooserListViewController *controller = [[SeequChooserListViewController alloc] initWithNibName:@"SeequChooserListViewController" bundle:nil];
    controller.delegate = self;
    controller.currentSelected = selectedButton.titleLabel.text;
    controller.arrayOfList = [[NSArray alloc] initWithObjects:@"Facebook", @"Linkedin", @"Pinterest", @"Tumblr", @"Twitter", @"Other", @"My Blog", nil];
    controller.videoViewState = self.videoViewState;
    [self presentViewController:controller animated:YES completion:^{
        
    }];

}


-(void) selectLanguageClicked:(int) index {
    SeequSecondLanguageViewController *secondLanguageViewController = [[SeequSecondLanguageViewController alloc] initWithNibName:@"SeequSecondLanguageViewController" bundle:nil];

    secondLanguageViewController.delegate = self;
    secondLanguageViewController.videoViewState = self.videoViewState;
    secondLanguageViewController.showNoneField = YES;
    secondLanguageViewController.currentIndex = index;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    ProfileFooterCell* cell = (ProfileFooterCell*) [self.viewFooter cellForRowAtIndexPath:indexPath];
    secondLanguageViewController.selectedLanguage = cell.value.text;
    switch (index + 1) {
        case 1:{
            secondLanguageViewController.navigationTitle = @"Primary Language";
            
            
            secondLanguageViewController.showNoneField = NO;
            break;
        }
        case 2:
            secondLanguageViewController.navigationTitle = @"Second Language";
//            secondLanguageViewController.selectedLanguage = self.labelSecondLanguage.text;
            break;
        case 3:
            secondLanguageViewController.navigationTitle = @"Third Language";
//            secondLanguageViewController.selectedLanguage = self.labelThirdLanguage.text;
            break;
        case 4:
            secondLanguageViewController.navigationTitle = @"Fourth Language";
   //         secondLanguageViewController.selectedLanguage = self.labelFourthLanguage.text;
            break;
        default:
            break;
    }
    [self presentViewController:secondLanguageViewController animated:YES completion:^{
        
        
    }];

}


-(void) selectCountryClicked {
    SeequCountryListViewController *controller = [[SeequCountryListViewController alloc] initWithNibName:@"SeequCountryListViewController" bundle:nil];
    controller.delegate = self;
    controller.currentSelected = selectedCountry;
    controller.arrayOfList = [Common sharedCommon].arrayCountries;
    controller.videoViewState = self.videoViewState;
    [self presentViewController:controller animated:YES completion:^{
        
    }];

}


-(void) selectStateClicked {
    SeequStateListViewController *controller = [[SeequStateListViewController alloc] initWithNibName:@"SeequStateListViewController" bundle:nil];
    controller.delegate = self;
    controller.currentSelected = selectedState;
    controller.arrayOfList = self.stateList;
    controller.videoViewState = self.videoViewState;
    [self presentViewController:controller animated:YES completion:^{
        
    }];

}

#pragma mark-
#pragma mark Table view methods
#pragma mark-

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView ==  self.MyTableView) {
        return 5;
    }
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView ==  self.MyTableView) {
        switch (section) {
            case 0:
                //        case 1:
                return 1;
                break;
            case 1:
                return [arrayInternetInfo count] + 1;
                break;
            case 2:
                return [arrayContactInfo count] + 1;
                break;
            case 3:
                return [arraySocialInfo count] + 1;
            default:
                return 0;
                break;
        }

    } else {
        switch (section) {
            case 0:
                
                return langArray.count == 4?langArray.count:langArray.count +1;
            case 1:
                return locatArray.count;
            default:
                return 0;
        }

    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView ==  self.MyTableView) {

        switch (section) {
            case 0:
                return @"*Introduction";
                break;
            case 1:
                return @"Internet";
                break;
            case 2:
                return @"Contact Information";
                break;
            case 3:
                return @"Social Information";
                break;
            default:
                break;
        }
    } else {
        switch (section) {
            case 0:
                return @"Languages";
                break;
            case 1:
                return @"Locations";
                break;
            default:
                break;
        }

    }
    
    return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( tableView == self.MyTableView) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell;
        if (indexPath.section == 0) {
            static NSString *CellIdent = @"CellIntroduction";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdent];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdent];
            }
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        // Set up the cell...
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        switch (indexPath.section) {
            case 0: {
                UIFont *font = [UIFont systemFontOfSize:14];
                CGSize textSize = CGSizeMake(290, 5000.0f);
                CGSize size = [textViewIntroduction.text sizeWithFont:font constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
                textViewIntroduction.frame = CGRectMake(10, 0, 300, size.height + TEXT_VIEW_DIFF);

                CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
                textViewIntroduction.tag = rect.origin.y;

                [cell addSubview:textViewIntroduction];
            }
                break;
    //        case 1: {
    //            UIFont *font = [UIFont systemFontOfSize:14];
    //            CGSize textSize = CGSizeMake(290, 5000.0f);
    //            CGSize size = [textViewBio.text sizeWithFont:font constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];;
    //            textViewBio.frame = CGRectMake(10, 0, 300, size.height + TEXT_VIEW_DIFF);
    //            
    //            CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
    //            textViewBio.tag = rect.origin.y;
    //
    //            [cell addSubview:textViewBio];
    //        }
    //            break;
            case 1: {
                if (indexPath.row == [arrayInternetInfo count]) {
                    cell.imageView.image = [UIImage imageNamed:@"defaultSeequTableCellAddButton.png"];
                    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14]];
                    [cell.textLabel setTextColor:[UIColor grayColor]];
                    [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
                    cell.textLabel.text = @"Add another item";
                } else {
                    NSDictionary *dict = [arrayInternetInfo objectAtIndex:indexPath.row];
                    NSString *header = [dict objectForKey:@"itemName"];
                    NSString *value = [dict objectForKey:@"itemValue"];

                    UIButton *button_type = [[UIButton alloc] initWithFrame:CGRectMake(-5, 0, 85, 44)];
                    button_type.tag = indexPath.row;
                    [button_type setBackgroundColor:[UIColor whiteColor]];
                    [button_type.titleLabel setFont:[UIFont systemFontOfSize:12]];
                    [button_type setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                    [button_type setTitle:header forState:UIControlStateNormal];
                    button_type.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    button_type.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
                    [button_type addTarget:self
                                    action:@selector(onButtonChooseInternetHeader:event:)
                          forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:button_type];

                    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(80, 10, 200, 24)];
                    textField.delegate = self;
                    CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
                    textField.tag = rect.origin.y;
                    textField.keyboardType = UIKeyboardTypeURL;
                    [textField setBackgroundColor:[UIColor whiteColor]];
                    [textField setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
                    [textField setTextColor:[UIColor blackColor]];
                    [textField setText:value];
                    [textField setTextAlignment:NSTextAlignmentLeft];
                    [cell addSubview:textField];

                    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
                    button.tag = indexPath.row;
                    [button setBackgroundImage:[UIImage imageNamed:@"defaultSeequTableCellDeleteButton.png"] forState:UIControlStateNormal];
                    [button addTarget:self
                               action:@selector(onButtonDelete:event:)
                     forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = button;
                }
            }
                break;
            case 2: {
                if (indexPath.row == [arrayContactInfo count]) {
                    cell.imageView.image = [UIImage imageNamed:@"defaultSeequTableCellAddButton.png"];
                    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14]];
                    [cell.textLabel setTextColor:[UIColor grayColor]];
                    [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
                    cell.textLabel.text = @"Add another item";
                } else {
                    NSDictionary *dict = [arrayContactInfo objectAtIndex:indexPath.row];
                    
                    NSString *header = [dict objectForKey:@"itemName"];
                    NSString *value = [dict objectForKey:@"itemValue"];
                    
                    UIButton *button_type = [[UIButton alloc] initWithFrame:CGRectMake(-5, 0, 85, 44)];
                    button_type.tag = indexPath.row;
                    [button_type setBackgroundColor:[UIColor whiteColor]];
                    [button_type.titleLabel setFont:[UIFont systemFontOfSize:12]];
                    [button_type setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                    [button_type setTitle:header forState:UIControlStateNormal];
                    button_type.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    button_type.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
                    [button_type addTarget:self
                               action:@selector(onButtonChooseContactHeader:event:)
                     forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:button_type];
                    
                    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(80, 10, 200, 24)];
                    textField.delegate = self;
                    CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
                    textField.tag = rect.origin.y;
                    if ([header isEqualToString:@"Phone"]) {
                        textField.keyboardType = UIKeyboardTypePhonePad;
                    } else {
                        textField.keyboardType = UIKeyboardTypeEmailAddress;
                    }
                    [textField setBackgroundColor:[UIColor whiteColor]];
                    [textField setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
                    [textField setTextColor:[UIColor blackColor]];
                    [textField setText:value];
                    [textField setTextAlignment:NSTextAlignmentLeft];
                    [cell addSubview:textField];

                    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
                    button.tag = indexPath.row;
                    [button setBackgroundImage:[UIImage imageNamed:@"defaultSeequTableCellDeleteButton.png"] forState:UIControlStateNormal];
                    [button addTarget:self
                               action:@selector(onButtonDelete:event:)
                     forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = button;
                }
            }
                break;
            case 3: {
                if (indexPath.row == [arraySocialInfo count]) {
                    cell.imageView.image = [UIImage imageNamed:@"defaultSeequTableCellAddButton.png"];
                    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14]];
                    [cell.textLabel setTextColor:[UIColor grayColor]];
                    [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
                    cell.textLabel.text = @"Add another item";
                } else {
                    NSDictionary *dict = [arraySocialInfo objectAtIndex:indexPath.row];
                    NSString *header = [dict objectForKey:@"itemName"];
                    NSString *value = [dict objectForKey:@"itemValue"];
                    
                    UIButton *button_type = [[UIButton alloc] initWithFrame:CGRectMake(-5, 0, 85, 44)];
                    button_type.tag = indexPath.row;
                    [button_type setBackgroundColor:[UIColor whiteColor]];
                    [button_type.titleLabel setFont:[UIFont systemFontOfSize:12]];
                    [button_type setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                    [button_type setTitle:header forState:UIControlStateNormal];
                    button_type.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    button_type.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
                    [button_type addTarget:self
                                    action:@selector(onButtonChooseSocialHeader:event:)
                          forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:button_type];
                    
                    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(80, 10, 200, 24)];
                    textField.delegate = self;
                    CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
                    textField.tag = rect.origin.y;
                    textField.keyboardType = UIKeyboardTypeURL;
                    [textField setBackgroundColor:[UIColor whiteColor]];
                    [textField setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
                    [textField setTextColor:[UIColor blackColor]];
                    [textField setText:value];
                    [textField setTextAlignment:NSTextAlignmentLeft];
                    [cell addSubview:textField];
                    
                    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
                    button.tag = indexPath.row;
                    [button setBackgroundImage:[UIImage imageNamed:@"defaultSeequTableCellDeleteButton.png"] forState:UIControlStateNormal];
                    [button addTarget:self
                               action:@selector(onButtonDelete:event:)
                     forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = button;
                }
            }
                break;
            default:
                break;
        }
        
    //    [cell setBackgroundColor:[UIColor colorWithRed:28.0/255.0
    //                                             green:28.0/255.0
    //                                              blue:248.0/255.0
    //                                             alpha:1.0]];
        
    //    [cell setBackgroundColor:[UIColor redColor]];
        
        return cell;
    }else {
        static NSString *CellIdentifier = @"CellFooter";
        ProfileFooterCell *cell = (ProfileFooterCell *)[self.viewFooter dequeueReusableCellWithIdentifier:CellIdentifier ] ;
        cell.delegate = self;
        if (cell == nil) {
            cell = [[ProfileFooterCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        [cell setBackgroundColor:[UIColor whiteColor]];
        ProfileFooterInfo* inf;
        if (indexPath.section == 0) {
            if (indexPath.row == langArray.count) {
                [cell updateCell:[labelArray objectAtIndex:indexPath.row ] value:nil withImage:nil];
            } else {
                inf = [langArray objectAtIndex:indexPath.row];
                
                [cell updateCell:[labelArray objectAtIndex:indexPath.row ] value:inf.value withImage:[self getApproriateFlag:inf.value]];
            }

        } else {

            inf = [locatArray objectAtIndex:indexPath.row];
            [cell updateCell:inf.name value:inf.value withImage:nil];
            if (indexPath.row == 0 && !isCountryListRefreshed) {
                [cell startCountryUpdate];
            }
            if (indexPath.row == 1 && !isStateListRefreshed) {
                [self performSelectorInBackground:@selector(updateStateList:) withObject:selectedCountry.countryID];
                
                [cell startStateUpdate:selectedCountry.countryID];
            }
            
        }
        cell.data = inf;
        cell.value.delegate = self;
        CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
        cell.value.tag = self.viewFooter.frame.origin.y + rect.origin.y;
        if ((indexPath.section == 1 && (indexPath.row ==0 ||indexPath.row == 3)) ||indexPath.section == 0){
            cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
            cell.value.enabled = NO;
        } else {
            if (indexPath.row == 1) {
                if (self.stateList && self.stateList.count) {
                    cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
                    cell.value.enabled = NO;
                } else {
                    cell.accessoryType =UITableViewCellAccessoryNone;
                    cell.value.enabled = YES;
                }
            } else {
                cell.accessoryType =UITableViewCellAccessoryNone;
                cell.value.enabled = YES;
            }
        }
        return  cell;
    }
}


-(UIImage*) getApproriateFlag:(NSString*) laguage{
    NSString *filePath = [Common FindFilePathWithFilename:@"LanguageList.plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    NSArray *array = [dict objectForKey:@"Item"];
    
  
    for (int i = 0; i <  array.count; i++) {
        if ([[[array objectAtIndex:i] objectAtIndex:0] isEqualToString:laguage]) {
            UIImage* im = [UIImage imageNamed:[[array objectAtIndex:i] objectAtIndex:1]];
            return im;

        }
        
    }
    return  nil;
}

-(void) didCountryUpdated:(NSArray *)countries {
    isCountryListRefreshed = YES;
    [Common sharedCommon].arrayCountries = countries;
}


-(void) didStateUpdated:(NSArray *)states {
    isStateListRefreshed = YES;
    self.selectedState = nil;
    self.stateList = states;
    [self.viewFooter reloadData];
}


-(void) didDataChanged {
    isLocationChanged = YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.MyTableView == tableView) {
        
        switch (indexPath.section) {
            case 1: {
                if (indexPath.row == [arrayInternetInfo count]) {
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"home page", @"itemName",
                                          @"www.", @"itemValue", nil];
                    [arrayInternetInfo addObject:dict];

                    [self.MyTableView beginUpdates];
                    [self.MyTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                            withRowAnimation:UITableViewRowAnimationMiddle];
                    [self.MyTableView endUpdates];
                    
                    NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
                    [tableView deselectRowAtIndexPath:path animated:YES];
                } else {
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                }
            }
                break;
            case 2: {
                if (indexPath.row == [arrayContactInfo count]) {
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Phone", @"itemName",
                                          @"", @"itemValue", nil];
                    [arrayContactInfo addObject:dict];

                    [self.MyTableView beginUpdates];
                    [self.MyTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                            withRowAnimation:UITableViewRowAnimationMiddle];
                    [self.MyTableView endUpdates];
                    
                    NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
                    [tableView deselectRowAtIndexPath:path animated:YES];
                } else {
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                }
            }
                break;
            case 3: {
                if (indexPath.row == [arraySocialInfo count]) {
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Facebook", @"itemName",
                                          @"", @"itemValue", nil];
                    [arraySocialInfo addObject:dict];
                    
                    [self.MyTableView beginUpdates];
                    [self.MyTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                            withRowAnimation:UITableViewRowAnimationMiddle];
                    [self.MyTableView endUpdates];
                    
                    NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
                    [tableView deselectRowAtIndexPath:path animated:YES];
                } else {
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                }
            }
                break;
            default:
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                break;
        }
    } else {
        
        [self selectLocation:indexPath];
    }
}

-(void) selectLocation:(NSIndexPath*) indexPath {
    if (indexPath.section ) {
        switch (indexPath.row) {
            case 0:
                [self selectCountryClicked];
                break;
            case 1:
                [self selectStateClicked];
                break;
            case 2:
                break;
            case 3:
                [self selectTimeZoneClicked];
                break;
            default:
                break;
        }

    } else {
        [self selectLanguageClicked:indexPath.row];
    }

}
-(void) selectTimeZoneClicked{
    SeequTimeZoneViewController *controller = [[SeequTimeZoneViewController alloc] init];
    controller.timeZoneDelegate = self;
    
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:controller];
//    controller.delegate = self;
//    controller.currentSelected = selectedCountryDictionary;
//    controller.arrayOfList = [Common sharedCommon].arrayCountris;
//    controller.videoViewState = self.videoViewState;
    [self presentViewController:nc animated:YES completion:^{
        
    }];

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    // Apply the updates.
    switch (indexPath.section) {
        case 1: {
            [arrayInternetInfo removeObjectAtIndex:indexPath.row];
            isChangedInternetInfo = YES;
        }
            break;
        case 2: {
            [arrayContactInfo removeObjectAtIndex:indexPath.row];
            isChangedContactInfo = YES;
        }
            break;
        case 3: {
            [arraySocialInfo removeObjectAtIndex:indexPath.row];
            isChangedSocialInfo = YES;
        }
            break;
        default:
            break;
    }

    [self.MyTableView beginUpdates];
    [self.MyTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                            withRowAnimation:UITableViewRowAnimationMiddle];
    [self.MyTableView endUpdates];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.MyTableView) {
        
        switch (indexPath.section) {
            case 0: {
                UIFont *font = [UIFont systemFontOfSize:14];
                CGSize textSize = CGSizeMake(290, 5000.0f);
                CGSize size = [textViewIntroduction.text sizeWithFont:font constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
                
                CGFloat retVal = size.height + TEXT_VIEW_DIFF;
                
                if (retVal < 40) {
                    retVal = 40;
                }
                
                return retVal;
            }
                break;
    //        case 1: {
    //            UIFont *font = [UIFont systemFontOfSize:14];
    //            CGSize textSize = CGSizeMake(290, 5000.0f);
    //            CGSize size = [textViewBio.text sizeWithFont:font constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    //            
    //            CGFloat retVal = size.height + TEXT_VIEW_DIFF;
    //            
    //            if (retVal < 40) {
    //                retVal = 40;
    //            }
    //            
    //            return retVal;
    //        }
    //            break;
                
            default:
                return 44;
                break;
        }

        return 60;
    } else {
        return 44;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!isEditing) {
        [self.textFieldFirstName resignFirstResponder];
        [self.textFieldLastName resignFirstResponder];
        [self.textFieldSpecialist resignFirstResponder];
        [self.textFieldCompany resignFirstResponder];
        [self resignFirstResponder];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!isEditing) {
//        [selectedTextField resignFirstResponder];
//        [selectedTextView resignFirstResponder];
    }
}

- (void) didSaveBadges:(SeequBadgStatusViewController*)sortViewController withBadge:(NSString*)badg {
    isChangeBadgeStatus = YES;
    badgStatus = badg;
    self.imageViewMasterBadg.image = [UIImage imageNamed:[NSString stringWithFormat:@"ProfileBadgeStatus%@.png", badgStatus]];

    [sortViewController dismissViewControllerAnimated:YES completion:^{

    }];
}

- (void) didChooseLanguage:(SeequSecondLanguageViewController *)secondLanguageViewController withLanguage:(NSString *)language {
    isChangeLanguage = YES;
    
    if ([language isEqualToString:@"None"] || [language isEqualToString:@"(n/a)"]) {
        language = @"";
    }
    [secondLanguageViewController dismissViewControllerAnimated:YES completion:^{
        if (language) {
            if (langArray.count != secondLanguageViewController.currentIndex) {
                ((ProfileFooterInfo*)[langArray objectAtIndex:secondLanguageViewController.currentIndex]).value = language;
            } else {
                ProfileFooterInfo*  inf = [[ProfileFooterInfo alloc] init];
                inf.value = language;
                [langArray addObject:inf];
            }
            
            
        } else {
            
            if(langArray.count > secondLanguageViewController.currentIndex){
                [langArray removeObjectAtIndex:secondLanguageViewController.currentIndex];
            }
        }
        
        
        [self.viewFooter reloadData];

    }];
}

- (void) SetLocation:(ProfileFooterInfo*) inf index:(int) index {
    Common *common = [Common sharedCommon];
    switch (index) {
        case 0:{
            if (!common.contactObject.country.countryName) {
                inf.value = @"";
            } else {
                inf.value = common.contactObject.country.countryName;
               
                self.selectedCountry = common.contactObject.country;
            }
            return;
        }
        case 1:{
            if ([common.contactObject.state.stateID intValue]== 0) {
                
                inf.value = common.contactObject.state.stateName;
            } else {
                inf.value = common.contactObject.state.stateAbbrev;
                self.selectedState = common.contactObject.state;
            }
            return;
        }
        case 2:{
            if (!common.contactObject.City) {
                inf.value = @"";
            } else {
                inf.value = common.contactObject.City;
            }
            return;
        }
        case 3:{
            if (!common.contactObject.TimeZone) {
                inf.value = @"";
            } else {
                int v = [common.contactObject.TimeZone intValue];
                inf.value = [SeequTimeZoneInfo getTimeZoneValue:v];
            }
            return;
        }
            
        default:
            break;
    }

}

- (void) SetLanguages:(ProfileFooterInfo*) inf index:(int) index {
    Common *common = [Common sharedCommon];
    
    switch (index) {
        case 0:{
            if (!common.contactObject.LanguagePrimary ||[common.contactObject.LanguagePrimary isEqualToString:@"(null)"]) {
                inf.value = @"";
            } else {
                inf.value = common.contactObject.LanguagePrimary;
            }
            return;
        }
        case 1:{
            if (!common.contactObject.LanguageSecond||[common.contactObject.LanguageSecond isEqualToString:@"(null)"] ){
                inf.value = @"";
            } else {
                inf.value = common.contactObject.LanguageSecond;
            }
            return;
        }
        case 2:{
            if (!common.contactObject.LanguageThird||[common.contactObject.LanguageThird isEqualToString:@"(null)"] ) {
                inf.value = @"";
            } else {
                inf.value = common.contactObject.LanguageThird;
            }
            return;
        }
        case 3:{
            if (!common.contactObject.LanguageFourth||[common.contactObject.LanguageFourth isEqualToString:@"(null)"]) {
                inf.value = @"";
            } else {
                inf.value = common.contactObject.LanguageFourth;
            }
            return;
        }
            
        default:
            break;
    }
}

- (void)hideIndicatorViewAndDismiss:(NSString*)close {
    [self.indicator stopAnimating];
    [self.viewIndicator removeFromSuperview];
    
    if ([close isEqualToString:@"YES"]) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

#pragma mark-
#pragma mark Change Profile methods
#pragma mark-

- (void)changeProfileImage {
}

- (void)changeProfileBadgeStatus {
}

- (void)changeMainFields:(NSDictionary*)dict {
}

- (void)changeLanguage:(NSDictionary*)dict {
}

#pragma mark-
#pragma mark SeequChooserListViewController Delegate method
#pragma mark-

- (void) didSelectItem:(SeequChooserListViewController*)controller Item:(NSString*)item {
    [selectedButton setTitle:item forState:UIControlStateNormal];
    selectedButton = nil;
    
    if (selectedIndexPath) {
        switch (selectedIndexPath.section) {
            case 2: {
                NSDictionary *dict = [arrayInternetInfo objectAtIndex:selectedIndexPath.row];
                NSDictionary *replace_dict = [[NSDictionary alloc] initWithObjectsAndKeys:item, @"itemName",
                                              [dict objectForKey:@"itemValue"], @"itemValue", nil];
                [arrayInternetInfo replaceObjectAtIndex:selectedIndexPath.row withObject:replace_dict];
                isChangedInternetInfo = YES;
            }
                break;
            case 3: {
                NSDictionary *dict = [arrayContactInfo objectAtIndex:selectedIndexPath.row];
                NSDictionary *replace_dict = [[NSDictionary alloc] initWithObjectsAndKeys:item, @"itemName",
                                              [dict objectForKey:@"itemValue"], @"itemValue", nil];
                [arrayContactInfo replaceObjectAtIndex:selectedIndexPath.row withObject:replace_dict];
                isChangedContactInfo = YES;
            }
                break;
            case 4: {
                NSDictionary *dict = [arraySocialInfo objectAtIndex:selectedIndexPath.row];
                NSDictionary *replace_dict = [[NSDictionary alloc] initWithObjectsAndKeys:item, @"itemName",
                                              [dict objectForKey:@"itemValue"], @"itemValue", nil];
                [arraySocialInfo replaceObjectAtIndex:selectedIndexPath.row withObject:replace_dict];
                isChangedSocialInfo = YES;
            }
                break;
            default:
                break;
        }
        UITableViewCell *cell = [self.MyTableView cellForRowAtIndexPath:selectedIndexPath];
        selectedIndexPath = nil;
        
        if (cell) {
            for (UITextField *textField in cell.subviews) {
                if ([textField isKindOfClass:[UITextField class]]) {
                    if ([item isEqualToString:@"Phone"]) {
                        textField.keyboardType = UIKeyboardTypePhonePad;
                    } else {
                        textField.keyboardType = UIKeyboardTypeEmailAddress;
                    }
                    selectedTextField = textField;
                    break;
                }
                if ([textField isKindOfClass:[UITextView class]]) {
                    selectedTextView = (UITextView*)textField;
                }
            }
        }
    }
    
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark-
#pragma mark SeequStateListViewController Delegate method
#pragma mark-

- (void) didSelectState:(SeequStateListViewController*)controller State:(SeequState*)state {
    self.selectedState = state;
    isLocationChanged = YES;
    //    self.labelState.text = [selectedStateDictionary objectForKey:@"abbreviation"];
    ((ProfileFooterInfo*)[locatArray objectAtIndex:1]).value = [NSString stringWithFormat:@"(%@) %@",state.stateAbbrev,state.stateName];
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self.viewFooter reloadData];

}

#pragma mark-
#pragma mark SeequCountryListViewController Delegate method
#pragma mark-

- (void) didSelectCountry:(SeequCountryListViewController *)controller Country:(SeequCountry *)country {
    isLocationChanged = YES;
    ((ProfileFooterInfo*)[locatArray objectAtIndex:0]).value = country.countryName;
    self.selectedCountry =country;
    
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
    ((ProfileFooterInfo*)[locatArray objectAtIndex:1]).value = nil;
    ((ProfileFooterInfo*)[locatArray objectAtIndex:2]).value = nil;
    ((ProfileFooterInfo*)[locatArray objectAtIndex:3]).value = nil;
    isStateListRefreshed = NO;
    [self.viewFooter reloadData];

    ///@todo  getstate request
 //   self.stateList = [Common GetStatesById:country.countryID];
    
    //
}

- (NSIndexPath*) CreateIndexPathFromEvent:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.MyTableView];
    return [self.MyTableView indexPathForRowAtPoint: currentTouchPosition];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    selectedTextView = textView;
    isEditing = NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    isEditing = YES;
    isChangeMainFields = YES;
    static int numberOfLines = 0;
    
    int numLines = textView.contentSize.height / textView.font.lineHeight;

    if (numberOfLines < numLines) {
        NSIndexPath *indexPath;
        if (textView == textViewIntroduction) {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        } else {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        }
        NSArray *array = [NSArray arrayWithObject:indexPath];
        [self.MyTableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
        numberOfLines = numLines;
        
        [textView becomeFirstResponder];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    isEditing = NO;
    
    NSIndexPath *indexPath;
    if (textView == textViewIntroduction) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    } else {
        if (textView == textViewBio) {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        }
    }
    
    if (indexPath) {
        NSArray *array = [NSArray arrayWithObject:indexPath];
        [self.MyTableView beginUpdates];
        [self.MyTableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.MyTableView endUpdates];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    selectedTextField = textField;
    isEditing = NO;
    
    [self.MyTableView scrollRectToVisible:CGRectMake(0, textField.tag - 100, 320, 480) animated:YES];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.textFieldFirstName ||
        textField == self.textFieldLastName ||
        textField == self.textFieldSpecialist ||
        textField == self.textFieldCompany) {
        isChangeMainFields = YES;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    isEditing = YES;
    
    if (textField == self.textFieldFirstName ||
        textField == self.textFieldLastName ||
        textField == self.textFieldSpecialist ||
        textField == self.textFieldCompany) {
        isChangeMainFields = YES;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    isEditing = NO;
    CGPoint point = CGPointMake(160, textField.tag + 10);
    
    NSIndexPath *indexPath = [self.MyTableView indexPathForRowAtPoint:point];
    
    switch (indexPath.section) {
        case 1: {
            NSDictionary *dict = [arrayInternetInfo objectAtIndex:indexPath.row];
            NSString *value = [dict objectForKey:@"itemValue"];
            
            if (![value isEqualToString:textField.text]) {
                NSDictionary *replace_dict = [[NSDictionary alloc] initWithObjectsAndKeys:[dict objectForKey:@"itemName"], @"itemName",
                                              textField.text, @"itemValue", nil];
                [arrayInternetInfo replaceObjectAtIndex:indexPath.row withObject:replace_dict];
                isChangedInternetInfo = YES;
            }
        }
            break;
        case 2: {
            NSDictionary *dict = [arrayContactInfo objectAtIndex:indexPath.row];
            NSString *value = [dict objectForKey:@"itemValue"];
            
            if (![value isEqualToString:textField.text]) {
                NSDictionary *replace_dict = [[NSDictionary alloc] initWithObjectsAndKeys:[dict objectForKey:@"itemName"], @"itemName",
                                              textField.text, @"itemValue", nil];
                [arrayContactInfo replaceObjectAtIndex:indexPath.row withObject:replace_dict];
                isChangedContactInfo = YES;
            }
        }
            break;
        case 3: {
            NSDictionary *dict = [arraySocialInfo objectAtIndex:indexPath.row];
            NSString *value = [dict objectForKey:@"itemValue"];
            
            if (![value isEqualToString:textField.text]) {
                NSDictionary *replace_dict = [[NSDictionary alloc] initWithObjectsAndKeys:[dict objectForKey:@"itemName"], @"itemName",
                                              textField.text, @"itemValue", nil];
                [arraySocialInfo replaceObjectAtIndex:indexPath.row withObject:replace_dict];
                isChangedSocialInfo = YES;
            }
        }
            break;
        default:
            break;
    }
}

- (void) SaveChanges {
    BOOL isHaveChanges = NO;
    if (isChangeProfileImage) {
        NSString *error_message = [Common UpdateProfileImage:self.imageViewProfile.image];

        if (!error_message) {
            isHaveChanges = YES;
        } else {
            [self performSelectorOnMainThread:@selector(hideIndicatorViewAndDismiss:) withObject:@"NO" waitUntilDone:YES];

            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                [self performSelectorOnMainThread:@selector(ShowMessageOnMainThread:) withObject:error_message waitUntilDone:YES];
            }
            
            return;
        }
    }
    
    if (isChangeBadgeStatus) {
        NSString *error_message = [Common UpdateBadgeStatus:badgStatus];
        
        if (!error_message) {
            isHaveChanges = YES;
        } else {
            [self performSelectorOnMainThread:@selector(hideIndicatorViewAndDismiss:) withObject:@"NO" waitUntilDone:YES];

            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                [self performSelectorOnMainThread:@selector(ShowMessageOnMainThread:) withObject:error_message waitUntilDone:YES];
            }

            return;
        }
    }
    
    if (isChangeMainFields) {
        NSString *error_message;
        
        if (![self.textFieldFirstName.text stringByReplacingOccurrencesOfString:@" " withString:@""].length ||
            ![self.textFieldLastName.text stringByReplacingOccurrencesOfString:@" " withString:@""].length ||
            ![self.textFieldSpecialist.text stringByReplacingOccurrencesOfString:@" " withString:@""].length ||
            ![textViewIntroduction.text stringByReplacingOccurrencesOfString:@" " withString:@""].length) {
            
            error_message = @"The required fields (*) can not be empty.";
        } else if(![Common validateStr:self.textFieldFirstName.text]||![Common validateStr:self.textFieldLastName.text]){
            error_message=@"You can use only alphanumeric characters for first and last names";
        }
        else{
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [Common CreateValidString:self.textFieldFirstName.text], @"firstName",
                                  [Common CreateValidString:self.textFieldLastName.text], @"lastName",
                                  [Common CreateValidString:self.textFieldSpecialist.text], @"specialist",
                                  [Common CreateValidString:self.textFieldCompany.text], @"company",
                                  [Common CreateValidString:textViewBio.text], @"bio",
                                  [Common CreateValidString:textViewIntroduction.text], @"introduction",nil];

            error_message = [Common UpdateMainFields:dict];
        }
        
        if (!error_message) {
            isHaveChanges = YES;
        } else {
            [self performSelectorOnMainThread:@selector(hideIndicatorViewAndDismiss:) withObject:@"NO" waitUntilDone:YES];
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                [self performSelectorOnMainThread:@selector(ShowMessageOnMainThread:) withObject:error_message waitUntilDone:YES];
            }
            
            return;
        }
    }
    
    if (isChangeLanguage) {
        NSDictionary * dict = [self getUpdatedLAnguages];
        NSString *error_message = [Common UpdateProfileLanguages:dict];
        if (!error_message) {
            isHaveChanges = YES;
        } else {
            [self performSelectorOnMainThread:@selector(hideIndicatorViewAndDismiss:) withObject:@"NO" waitUntilDone:YES];

            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                [self performSelectorOnMainThread:@selector(ShowMessageOnMainThread:) withObject:error_message waitUntilDone:YES];
            }

            return;
        }
    }
    
    if (isChangedInternetInfo) {
        NSString *error_message = [Common UpdateInternetInfo:arrayInternetInfo];
        [Common sharedCommon].contactObject.arrayInternetInfo = arrayInternetInfo;
        if (!error_message) {
            isHaveChanges = YES;
        } else {
            [self performSelectorOnMainThread:@selector(hideIndicatorViewAndDismiss:) withObject:@"NO" waitUntilDone:YES];

            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                [self performSelectorOnMainThread:@selector(ShowMessageOnMainThread:) withObject:error_message waitUntilDone:YES];
            }

            return;
        }
    }
    if (isChangedContactInfo) {
        NSString *error_message = [Common UpdateContactInfo:arrayContactInfo];
        [Common sharedCommon].contactObject.arrayContactInfo = arrayContactInfo;
        if (!error_message) {
            isHaveChanges = YES;
        } else {
            [self performSelectorOnMainThread:@selector(hideIndicatorViewAndDismiss:) withObject:@"NO" waitUntilDone:YES];

            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                [self performSelectorOnMainThread:@selector(ShowMessageOnMainThread:) withObject:error_message waitUntilDone:YES];
            }

            return;
        }
    }
    if (isLocationChanged) {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
        for (int i = 0; i< locatArray.count; ++i) {
            ProfileFooterInfo* inf = [locatArray objectAtIndex:i];
            [dic setValue:inf.value forKeyPath:inf.name];

        }
        
        [dic  setValue:selectedCountry.countryID forKey:@"countryID"];
        if (selectedState) {
            [dic  setValue:selectedState.stateID forKey:@"stateID"];
            [dic  setValue:selectedState.stateAbbrev forKey:@"stateAbbrev"];

        }

        
        NSString *error_message = [Common UpdateContactLocation:dic];
        [Common sharedCommon].contactObject.arrayContactInfo = arrayContactInfo;
        if (!error_message) {
            isHaveChanges = YES;
        } else {
            [self performSelectorOnMainThread:@selector(hideIndicatorViewAndDismiss:) withObject:@"NO" waitUntilDone:YES];
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                [self performSelectorOnMainThread:@selector(ShowMessageOnMainThread:) withObject:error_message waitUntilDone:YES];
            }
            
            return;
        }

    }
    
    
    if (isChangedSocialInfo) {
        NSString *error_message = [Common UpdateSocialInfo:arraySocialInfo];
        [Common sharedCommon].contactObject.arraySocialInfo = arraySocialInfo;
        if (!error_message) {
            isHaveChanges = YES;
        } else {
            [self performSelectorOnMainThread:@selector(hideIndicatorViewAndDismiss:) withObject:@"NO" waitUntilDone:YES];

            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                [self performSelectorOnMainThread:@selector(ShowMessageOnMainThread:) withObject:error_message waitUntilDone:YES];
            }

            return;
        }
    }
    
    [self performSelectorOnMainThread:@selector(hideIndicatorViewAndDismiss:) withObject:@"YES" waitUntilDone:YES];
    if (isHaveChanges) {
        [self performSelectorOnMainThread:@selector(SendProfileChangeXMPPMessage) withObject:nil waitUntilDone:YES];
    }
}

- (void) SendProfileChangeXMPPMessage {
//    UINavigationController *nav = [[idoubs2AppDelegate sharedInstance].tabBarController.viewControllers objectAtIndex:0];
//    SeequContactsViewController *controller = [nav.viewControllers objectAtIndex:0];
    NSArray *array = [[ContactStorage sharedInstance] GetAllUsersInfoList];
        if(array && [array count]){
    for (UserInfoCoreData *object in array) {
        [[idoubs2AppDelegate getChatManager] SendUpdateRequestTo:object.seeQuId];
    }
  }
}

- (void) ShowMessageOnMainThread:(NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


-(NSDictionary*) getUpdatedLAnguages{
    NSDictionary* dict = [[NSMutableDictionary alloc] init];
    for (int  i = 0; i < langArray.count; i++) {
        ProfileFooterInfo* inf = (ProfileFooterInfo*)[langArray objectAtIndex:i];
        [dict setValue:inf.value forKeyPath:[[labelArray objectAtIndex:i] lowercaseString]];
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (UITextView*) CreateTextViewWithText:(NSString*)text {
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize textSize = CGSizeMake(290, 5000.0f);
    CGSize size = [text sizeWithFont:font constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 300, size.height + TEXT_VIEW_DIFF)];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setFont:[UIFont systemFontOfSize:14]];
    [textView setTextColor:[UIColor blackColor]];
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    [textView setText:text];
    [textView setTextAlignment:NSTextAlignmentLeft];
    textView.delegate = self;
    
    return textView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextFieldFirstName:nil];
    [self setTextFieldLastName:nil];
    [self setTextFieldSpecialist:nil];
    [self setTextFieldCompany:nil];
    [self setViewHeader:nil];
    [self setMyTableView:nil];
    [self setImageViewProfile:nil];
    [self setImageViewMasterBadg:nil];
    [self setViewFooter:nil];
    
    [super viewDidUnload];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) didSelectTimeZone:(NSString *)timeZone {
    ProfileFooterInfo*  inf = [locatArray objectAtIndex:3];
    inf.value  = timeZone;
    isLocationChanged = YES;

    [self.viewFooter reloadData];
}

@end
