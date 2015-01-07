//
//  TabBarVCDemoViewController.h
//  PlutoLand
//
//  Created by xhan on 10-7-22.
//  Copyright 2010 ixHan.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLTabBarController.h"
#import "SegmentDemoViewController.h"

@interface TabBarVCDemoViewController : PLTabBarController{
    int statusBarHeight;
}

- (id)initWithControllers:(NSMutableArray*)controllers;

@end
