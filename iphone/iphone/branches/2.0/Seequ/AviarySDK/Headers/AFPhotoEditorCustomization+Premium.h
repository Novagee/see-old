//
//  AFPhotoEditorCustomization+Premium.h
//  AviarySDK
//
//  Created by Jack Sisson on 3/19/13.
//  Copyright (c) 2013 Aviary, Inc. All rights reserved.
//

#import "AFPhotoEditorCustomization.h"

typedef enum{
    AFPhotoEditorIconStateDefault,
    AFPhotoEditorIconStateSelected
}AFPhotoEditorIconState;

/**
 This category provides premium partners to override default images (icons, bars, etc.) in the Aviary Photo Editor.
 */
@interface AFPhotoEditorCustomization (Premium)

/** 
 Sets the tool's icon image in the editor's home bottom bar.
 
 Tool options are as follows:
 
    kAFEnhance
    kAFEffects
    kAFStickers
    kAFOrientation
    kAFCrop
    kAFBrightness
    kAFContrast
    kAFSaturation
    kAFSharpness
    kAFDraw
    kAFText
    kAFRedeye
    kAFWhiten
    kAFBlemish
    kAFMeme
    kAFFrames;
    kAFFocus
 
 @param image The image to use
 @param tool The tool to set for the image. See the discussion for possible values
 @param state The state of the tool to apply the image to. Options are AFPhotoEditorIconStateDefault and AFPhotoEditorIconStateSelected
 */
+ (void)setIconImage:(UIImage*)image forTool:(NSString*)tool forState:(AFPhotoEditorIconState)state;

/**
 Sets the nav bar's background image.
 
 @param image The image to use
 */
+ (void)setNavBarImage:(UIImage*)image;

/**
 Sets the apply button's background image.
 
 @param image The image to use
 */
+ (void)setApplyButtonBackgroundImage:(UIImage*)image;

/**
 Sets the apply button's active state background image.
 
 @param image The image to use
 */
+ (void)setActiveApplyButtonBackgroundImage:(UIImage*)image;

/**
 Sets the cancel button background image.
 
 @param image The image to use
 */
+ (void)setCancelButtonBackgroundImage:(UIImage*)image;

/**
 Sets the cancel button's active state background image.
 
 @param image The image to use
 */
+ (void)setActiveCancelButtonBackgroundImage:(UIImage*)image;

/**
 Sets the back button's background image.
 
 @param image The image to use
 */
+ (void)setBackButtonBackgroundImage:(UIImage*)image;

/**
 Sets the back button's active state background image.
 
 @param image The image to use
 */

+ (void)setActiveBackButtonBackgroundImage:(UIImage*)image;

@end
