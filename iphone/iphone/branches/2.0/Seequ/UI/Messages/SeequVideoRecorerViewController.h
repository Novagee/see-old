//
//  SeequVideoRecorerViewController.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 3/12/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import "SeequRecordVideoEditor.h"
#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"

typedef enum{
        kPickerTypePhoto,
        kPickerTypeMovie
}SeequPickerType;

@protocol SeequVideoRecorerViewControllerDelegate ;

@interface SeequVideoRecorerViewController : UIViewController<CaptureSessionManagerDelegate, UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIVideoEditorControllerDelegate,SeequRecordVideoEditorDelegate>{
    
}

@property (retain) CaptureSessionManager *captureManager;
@property (nonatomic,assign) id<CaptureSessionManagerDelegate> delegate;
@property (nonatomic,assign) id<SeequVideoRecorerViewControllerDelegate> captureDelegate;
@property (nonatomic,assign) AVCaptureDevicePosition devicePosition;
@property (nonatomic,assign) BOOL forProfile;


-(id) initWithType:(SeequRecorderType) type;
+ (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler;
@end

@protocol SeequVideoRecorerViewControllerDelegate <NSObject>

@optional

-(void) captureFinished:(NSURL*) url fromLibrary:(BOOL)library;
-(void) takePhotoFinished:(UIImage*) image;
-(void) didFinish:(SeequVideoRecorerViewController*)controller Image:(UIImage*)img HighResolutionImage:(UIImage*)himg fromLibrary:(BOOL)library;
-(void) didChangeRecorderType:(SeequRecorderType) type;
-(void) cancelClicked;

@end
