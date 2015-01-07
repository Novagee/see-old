//
//  AviaryPickerController.m
//  ProTime
//
//  Created by Norayr on 09/14/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//
#import "Common.h"
#import "AviaryPickerController.h"
#import "UIImage+Operations.h"
#import "idoubs2AppDelegate.h"

@interface AviaryPickerController ()
-(void)onButtonCancel:(id)sender;
-(void)onButtonTakePhoto:(id)sender;
-(void)onButtonPhotoAlbum:(id)sender;
@end

@implementation AviaryPickerController

@synthesize avDelegate = _avDelegate;
@synthesize forProfile ;

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
    if(![[idoubs2AppDelegate sharedInstance].videoService isInCall]){
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0,44.0);
    self.cameraViewTransform=translate;
    }
    // Do any additional setup after loading the view from its nib.
    
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
 
    if (self.sourceType != UIImagePickerControllerSourceTypePhotoLibrary) {
        UIImageView *imgViewNav = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        imgViewNav.image = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
        [imgViewNav setAlpha:0.5];
        [self.view addSubview:imgViewNav];
        
        UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(14, 8, 37, 31)];
        [btnBack setImage:[UIImage imageNamed:@"defaultSeequBackButton.png"] forState:UIControlStateNormal];
        [btnBack addTarget:self action:@selector(onButtonCancel:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnBack];
        
        UIImageView *imgViewButtonsBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 97, 320, 97)];
        imgViewButtonsBG.image = [UIImage imageNamed:@"SeequTakePhotoButtonsBG.png"];
        [self.view addSubview:imgViewButtonsBG];
        
        UIButton *btnPhotoLibrary = [[UIButton alloc] initWithFrame:CGRectMake(40, imgViewButtonsBG.frame.origin.y + 10, 49, 49)];
        [btnPhotoLibrary setImage:[UIImage imageNamed:@"ButtonChooseExisting.png"] forState:UIControlStateNormal];
        [btnPhotoLibrary addTarget:self action:@selector(onButtonPhotoAlbum:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnPhotoLibrary];
        
        UILabel *lblChooseExisting = [[UILabel alloc] initWithFrame:CGRectMake(40, imgViewButtonsBG.frame.origin.y + 58, 49, 31)];
        [lblChooseExisting setBackgroundColor:[UIColor clearColor]];
        [lblChooseExisting setTextColor:[UIColor whiteColor]];
        [lblChooseExisting setFont:[UIFont boldSystemFontOfSize:12]];
        [lblChooseExisting setTextAlignment:NSTextAlignmentCenter];
        lblChooseExisting.numberOfLines = 2;
        [lblChooseExisting setText:@"Choose Existing"];
        [self.view addSubview:lblChooseExisting];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(127, imgViewButtonsBG.frame.origin.y + 10, 67, 68)];
        [btn setImage:[UIImage imageNamed:@"SeequButtonTakePhoto.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onButtonTakePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        
        UIButton *btnSwitchCamera = [[UIButton alloc] initWithFrame:CGRectMake(228, imgViewButtonsBG.frame.origin.y + 10, 49, 49)];
        [btnSwitchCamera setImage:[UIImage imageNamed:@"SeequButtonSwitchCamera.png"] forState:UIControlStateNormal];
        [btnSwitchCamera addTarget:self action:@selector(onButtonSwitchCamera:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnSwitchCamera];
        
        UILabel *lblSwitchCamera = [[UILabel alloc] initWithFrame:CGRectMake(230, imgViewButtonsBG.frame.origin.y + 58, 49, 20)];
        [lblSwitchCamera setBackgroundColor:[UIColor clearColor]];
        [lblSwitchCamera setTextColor:[UIColor whiteColor]];
        [lblSwitchCamera setFont:[UIFont boldSystemFontOfSize:12]];
        [lblSwitchCamera setTextAlignment:NSTextAlignmentCenter];
        [lblSwitchCamera setText:@"Rotate"];
        
        if (forProfile) {
            CGRect f = self.view.bounds;
            f.size.height -= self.navigationBar.bounds.size.height;
            CGFloat barHeight = (f.size.height - f.size.width) / 2;
            UIView*  view = [[UIView alloc] initWithFrame:self.view.bounds];
            view.backgroundColor = [UIColor clearColor];
            UIView* topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, f.size.width, barHeight)];
            topView .backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
            [view addSubview:topView];
            UIView* bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, f.size.height - barHeight, f.size.width, barHeight)];
            bottomView .backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
            [view addSubview:bottomView];
            
            self.cameraOverlayView = view;

        }
        [self.view addSubview:lblSwitchCamera];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

-(void)onButtonCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onButtonTakePhoto:(id)sender {
    [self takePicture];
}

-(void)onButtonPhotoAlbum:(id)sender {
    UIImagePickerController * imagePicker = [UIImagePickerController new];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void) onButtonSwitchCamera:(id)sender {
    if (self.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerCameraDeviceFront]) {
            self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    } else {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerCameraDeviceRear]) {
            self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePicker Delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:NO completion:nil];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    //    float rads = 0;
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *TakedImage = [info objectForKey:UIImagePickerControllerOriginalImage];

        if (forProfile ) {
            CGSize s = TakedImage.size;
//            if (TakedImage.size.width > TakedImage.size.height) {
//                TakedImage = [UIImage rotateImage:TakedImage byDegrees:90];
//            } else 
            TakedImage = [UIImage rotateImage:TakedImage byDegrees:0];

            CGRect f = self.view.bounds;
            f.size.height -= self.navigationBar.bounds.size.height;
            CGFloat barHeight = (f.size.height - f.size.width) / 2;
            CGFloat temp = self.view.bounds.size.width< self.view.bounds.size.height?self.view.bounds.size.width:self.view.bounds.size.height;
            CGFloat scaleFactor = TakedImage.size.width/temp;
            CGImageRef  imageRef;
            if (s.width < s.height) {
                 imageRef = CGImageCreateWithImageInRect([TakedImage CGImage], CGRectMake(0, barHeight*scaleFactor, temp*scaleFactor, temp*scaleFactor)) ;

            } else {
                imageRef = CGImageCreateWithImageInRect([TakedImage CGImage], CGRectMake(barHeight*scaleFactor, 0, temp*scaleFactor, temp*scaleFactor)) ;
            }
            TakedImage = [UIImage imageWithCGImage:imageRef];
            CFRelease(imageRef);
        }
        
        if ([_avDelegate respondsToSelector:@selector(didFinish1:Image:HighResolutionImage:)]) {
            [_avDelegate didFinish1:self Image:TakedImage HighResolutionImage:TakedImage];
        }
        
        return;
    }
}

@end
