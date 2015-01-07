    //
//  TabBarVCDemoViewController.m
//  PlutoLand
//
//  Created by xhan on 10-7-22.
//  Copyright 2010 ixHan.com. All rights reserved.
//

#import "TabBarVCDemoViewController.h"
#import "UIViewAdditions.h"
#import "idoubs2AppDelegate.h"

/////////////////////////////////////////////////////////////////////////////////////


@interface DemoColorfulVC : UIViewController
{
	UIColor* bgColor;
}
@property(nonatomic,strong) UIColor* bgColor;

- (id)initWithColor:(UIColor*)color;

@end

@implementation DemoColorfulVC

@synthesize bgColor;

- (id)initWithColor:(UIColor*)color
{
	self =  [super init];
	self.bgColor = color;
	return self;
}

- (void)loadView
{
	[super loadView];
	self.view.backgroundColor = self.bgColor;
	self.navigationItem.title = [self.bgColor description];
}



@end

/////////////////////////////////////////////////////////////////////////////////////


@implementation TabBarVCDemoViewController


- (id)initWithControllers:(NSMutableArray*)controllers
{
    
	self = [super init];
	self.viewControllers = controllers;
	self.tabBarView = [SegmentDemoViewController segmentDemo1TabBar];
    [self.tabBarView clipsToBounds];
    self.tabBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    statusBarHeight=0;
    [self willChangeStatusBarFrame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeStatusBarFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    return self;
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self.tabBar setHidden: UIInterfaceOrientationIsLandscape(orientation)];
    UIView* view =  [self.view.subviews objectAtIndex:0];
    if (view) {
        CGFloat width = UIInterfaceOrientationIsPortrait(orientation)? [idoubs2AppDelegate sharedInstance].window.frame.size.width:[idoubs2AppDelegate sharedInstance].window.frame.size.height;
        CGFloat height = !UIInterfaceOrientationIsPortrait(orientation)? [idoubs2AppDelegate sharedInstance].window.frame.size.width:[idoubs2AppDelegate sharedInstance].window.frame.size.height;
        
        view.frame = (self.tabBar.hidden)?CGRectMake(0, 0, width, height):
                                                CGRectMake(0, 0, width, height - self.tabBarView.frame.size.height);
        self.tabBar.frame = CGRectMake(0, height - self.tabBarView.frame.size.height-statusBarHeight, width, self.tabBarView.frame.size.height);
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    BOOL isRegistered = [[NSUserDefaults standardUserDefaults] boolForKey:@"autologin"];
    if (!isRegistered) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    switch (self.selectedIndex) {
        case 0: {
            return UIInterfaceOrientationIsPortrait(interfaceOrientation);
        }
            break;
        case 1: {
            return YES;
        }
            break;
        case 2: {
            return YES;
        }
            break;
        case 3: {
            return UIInterfaceOrientationIsPortrait(interfaceOrientation);
        }
            break;
        case 4: {
            return UIInterfaceOrientationIsPortrait(interfaceOrientation);
        }
            break;
        default:
            break;
    }
    
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}
-(void)willChangeStatusBarFrame{
    statusBarHeight=UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)?0:[UIApplication sharedApplication].statusBarFrame.size.height-20;
    if(!IS_IOS_7||statusBarHeight<0){
        statusBarHeight=0;
    }
    [self.view setNeedsLayout];
}

@end