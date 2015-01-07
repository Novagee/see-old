//
//  SegmentDemoViewController.h
//  PlutoLand
//
//  Created by xhan on 10-7-22.
//  Copyright 2010 ixHan.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PLSegmentView.h"

typedef enum tabBar_Type {
	tabBar_Type_Default,
    tabBar_Type_Landscape,
    tabBar_Type_Video,
    tabBar_Type_Video_Selected,
    tabBar_Type_Audio,
    tabBar_Type_Audio_Selected,
    tabBar_Type_OnHold
}
tabBar_Type;

@interface SegmentDemoViewController : UIViewController {
	PLSegmentView* segmentDemo1;
}

@property (nonatomic, strong) PLSegmentView *segmentDemo1;


+ (PLSegmentView*)segmentDemo1TabBar;
+ (PLSegmentView*)segmentDemo1TabBarLandscape;
+ (PLSegmentView*)segmentDemoVideoTabBar;
+ (PLSegmentView*)segmentDemoVideoSelectedTabBar;
+ (PLSegmentView*)segmentDemoAudioTabBar;
+ (PLSegmentView*)segmentDemoAudioSelectedTabBar;


@end

