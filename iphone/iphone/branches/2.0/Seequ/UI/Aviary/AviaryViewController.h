//
//  AviaryViewController.h
//  AviaryDemo-iOS
//
//  Created by Michael Vitrano on 1/23/13.
//  Copyright (c) 2013 Aviary. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AviarySDK/AviarySDK.h>
#import "AviaryPickerController.h"
#import "SeequVideoRecorerViewController.h"

@interface AviaryViewController : UIViewController <AviaryPickerDelegate, SeequVideoRecorerViewControllerDelegate>


@property (strong, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (strong, nonatomic) IBOutlet UIButton *choosePhotoButton;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;

- (IBAction)takePhoto:(id)sender;
- (IBAction)choosePhoto:(id)sender;

@end
