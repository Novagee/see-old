//
//  AviaryPickerController.h
//  ProTime
//
//  Created by Norayr on 09/14/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AviaryPickerDelegate;

@interface AviaryPickerController : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) id<AviaryPickerDelegate> avDelegate;
@property (nonatomic,assign) BOOL forProfile;

@end

@protocol AviaryPickerDelegate <NSObject>

@optional
///@todo levon needs  to rename/reimplement delegate method
- (void) didFinish1:(AviaryPickerController*)controller Image:(UIImage*)img HighResolutionImage:(UIImage*)himg;

@end