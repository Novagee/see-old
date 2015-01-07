//
//  PLTabBarController.m
//  PlutoLand
//
//  Created by xu xhan on 7/22/10.
//  Copyright 2010 xu han. All rights reserved.
//

#import "PLTabBarController.h"
#import "PLGlobal.h"
#import "UIViewAdditions.h"
#import "SeequSendMessageViewController.h"


#ifndef USING_UITABBAR_CONTROLLER_SUBCLASS

@interface PLTabBarController(Private)

- (void)changeViewToIndex:(int)index;

@end



@implementation PLTabBarController

@synthesize tabBarView;

@dynamic selectedVC;
@synthesize selectedIndex = _selectedIndex;

- (id)initWithTabBar:(PLSegmentView*)tabBar viewControllers:(NSArray*)aviewControllers
{
	if (self = [super init]) {
		tabBarView = [tabBar retain];
		tabBarView.delegate = self;
		viewControllers = [aviewControllers retain];
		containerView = nil;
		_selectedIndex = 0;
	}
	return self;
}

- (void)dealloc {
	PLSafeRelease(tabBarView);
	PLSafeRelease(viewControllers);
	PLSafeRelease(_transitionView);
    [super dealloc];
}


#pragma mark -


- (void)loadView {
//	[super loadView];
	UIView* view_ = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	view_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	view_.height -= 20;
	self.view = view_;
	[view_ release];
	

	_transitionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320,460 - tabBarView.height)];
	_transitionView.clipsToBounds = YES;
	[_transitionView setNeedsLayout];
	_transitionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_transitionView];
	[self.view addSubview:tabBarView];
//	tabBarView.bottom = 480;	
	[self updateViewAndTabBarToIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];

}

- (void)viewDidLoad{
	[self updateViewAndTabBarToIndex:_selectedIndex];
}

#pragma mark -
#pragma mark Action


- (UIViewController*)selectedVC
{
	return [viewControllers objectAtIndex:self.selectedIndex];
}

- (void)setSelectedIndex:(int)value{
	if (self.view) {
		[self updateViewAndTabBarToIndex:value];
	}else {
		_selectedIndex = value;
	}	
}

#pragma mark -
#pragma mark private

- (void)updateViewAndTabBarToIndex:(int)index
{
	[self changeViewToIndex:index];
	tabBarView.selectedIndex = index;
}

- (void)changeViewToIndex:(int)index
{
//	if (index == _selectedIndex) 	return;
	_selectedIndex = index;
	
	[containerView removeFromSuperview];
	containerView = [(UIViewController*)[viewControllers objectAtIndex:_selectedIndex] view];
//	containerView.frame = _transitionView.bounds;
	containerView.height = _transitionView.height;
//	containerView.autoresizingMask = _transitionView.autoresizingMask;
//	[_transitionView insertSubview:containerView atIndex:0];
	[_transitionView addSubview:containerView];
	
}

#pragma mark -
#pragma mark delegate of segment view

- (void)segmentClickedAtIndex:(int)index onCurrentCell:(BOOL)isCurrent
{
	[self changeViewToIndex:index];
}

@end

@implementation UIViewController (PLTabBarControllerCategory)

- (PLTabBarController*)pltabBarController{
	for (UIResponder* next = self; next; next = [next nextResponder]) {
//		UIResponder* nextResponder = [next nextResponder];
		if ([next isKindOfClass:[PLTabBarController class]]) {
			return (PLTabBarController*)next;
		}
	}
	return nil;
}

@end

#else

@implementation PLTabBarController

@synthesize tabBarView = _plTabbar;
@synthesize TBIdelegate = TBIdelegate_;

- (void)setTabBarView:(PLSegmentView *)tabbarView{
	if (_plTabbar != tabbarView) {

		_plTabbar = tabbarView ;
		_plTabbar.delegate = self;
	}
	_plTabbar.origin = CGPointZero;
	float offset = _plTabbar.height - self.tabBar.height;
	self.tabBar.top -= 	offset;
	self.tabBar.height += offset;
	[self.tabBar addSubview:_plTabbar];
}


- (void)setSelectedIndex:(NSUInteger)index
{
	[super setSelectedIndex:index];
    if(index == 1 && [self.selectedViewController isKindOfClass:[UINavigationController class]]){
        UINavigationController* nc = (UINavigationController*)self.selectedViewController;
        if(nc.viewControllers.count == 2) {
            SeequSendMessageViewController* sendMessagesViewController  = [nc.viewControllers objectAtIndex:1];
            sendMessagesViewController.needToScroll = YES;
        }
    }
	[self.tabBar bringSubviewToFront:_plTabbar];
	_plTabbar.selectedIndex = index;
}

/*
- (void)viewDidLoad{
	[super viewDidLoad];
	_plTabbar.selectedIndex = self.selectedIndex;
}
*/

#pragma mark -
#pragma mark delegate of segment view

- (void)segmentClickedAtIndex:(int)index onCurrentCell:(BOOL)isCurrent
{
	self.selectedIndex = index;

	if ([self.TBIdelegate respondsToSelector:@selector(didSelectControllerWithIndex:onCurrentCell:)]) {
		[self.TBIdelegate didSelectControllerWithIndex:index onCurrentCell:isCurrent];
	}
}

- (void)segmentDoubleClicked {
	if ([self.TBIdelegate respondsToSelector:@selector(didDoubleClickedFromUser:)]) {
		[self.TBIdelegate didDoubleClickedFromUser:@"YES"];
	}
}

- (void)segmentShowCallMenu {
	if ([self.TBIdelegate respondsToSelector:@selector(didSelectShowCallMenu)]) {
		[self.TBIdelegate didSelectShowCallMenu];
	}
}

- (void)segmentDidClickedOnLastTab {
    	if ([self.TBIdelegate respondsToSelector:@selector(didClickedOnLastTab)]) {
		[self.TBIdelegate didClickedOnLastTab];
	}
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return YES;
//}

@end

#endif
