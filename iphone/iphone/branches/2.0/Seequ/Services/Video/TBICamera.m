//
//  TBICamera.m
//  Zangi
//
//  Created by Norayr Harutyunyan on 10/29/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "TBICamera.h"

@implementation TBICamera

+ (AVCaptureDevice *)frontFacingCamera {
	return [TBICamera cameraAtPosition:AVCaptureDevicePositionFront];
}

+ (AVCaptureDevice *)backCamera {
	return [TBICamera cameraAtPosition:AVCaptureDevicePositionBack];
}

+ (AVCaptureDevice *)cameraAtPosition:(AVCaptureDevicePosition)position {
	NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras){
        if (device.position == position){
            return device;
        }
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

@end