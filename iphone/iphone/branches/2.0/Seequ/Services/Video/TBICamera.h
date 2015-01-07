//
//  TBICamera.h
//  Zangi
//
//  Created by Norayr Harutyunyan on 10/29/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TBICamera : NSObject {
    
}

+ (AVCaptureDevice *) frontFacingCamera;
+ (AVCaptureDevice *) backCamera;
+ (AVCaptureDevice *) cameraAtPosition:(AVCaptureDevicePosition)position;

@end