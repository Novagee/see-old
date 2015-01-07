//
//  PLTabBarController.h
//  PlutoLand
//
//  Created by xu xhan on 7/22/10.
//  Copyright 2010 xu han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLSegmentView.h"

#define USING_UITABBAR_CONTROLLER_SUBCLASS

#ifndef USING_UITABBAR_CONTROLLER_SUBCLASS


@protocol PLTabBarControllerDelegate <UITabBarDelegate>

@optional

@end


//TODO: add lazy load viewController , by using a delegate when need to display a new ViewController's contents
@interface PLTabBarController : UIViewController <PLSegmentViewDelegate> {
	
	NSArray *viewControllers;
	PLSegmentView *tabBarView;
	UIView *containerView;
	UIView *_transitionView;
	int _selectedIndex;
}

@property (nonatomic, retain) PLSegmentView *tabBarView;
@property(nonatomic,assign) int selectedIndex;
@property(nonatomic,readonly) UIViewController* selectedVC;

- (id)initWithTabBar:(PLSegmentView*)tabBar viewControllers:(NSArray*)viewControllers;

- (void)updateViewAndTabBarToIndex:(int)index;


@end

@interface UIViewController (PLTabBarControllerCategory)

@property(nonatomic,readonly) PLTabBarController *pltabBarController;

@end

#else
// NOTE: should set default selectedIndex in the -init method, otherwise it not works

@protocol TBITabBarControllerDelegate;

@interface PLTabBarController : UITabBarController<PLSegmentViewDelegate>
{
    __weak id<TBITabBarControllerDelegate> TBIdelegate_;
	PLSegmentView* _plTabbar;
}

@property (nonatomic, weak) id<TBITabBarControllerDelegate> TBIdelegate;
@property (nonatomic, strong) PLSegmentView *tabBarView;

@end

@protocol TBITabBarControllerDelegate <NSObject>

@optional

-(void)didSelectControllerWithIndex:(int)index onCurrentCell:(BOOL)isCurrent;
-(void)didDoubleClickedFromUser:(NSString*)user;
-(void)didSelectShowCallMenu;
-(void)didClickedOnLastTab;

@end

#endif