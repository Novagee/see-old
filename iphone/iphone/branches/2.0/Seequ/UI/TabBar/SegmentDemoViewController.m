    //
//  SegmentDemoViewController.m
//  PlutoLand
//
//  Created by xhan on 10-7-22.
//  Copyright 2010 ixHan.com. All rights reserved.
//

#import "SegmentDemoViewController.h"
#import "PLSegmentView.h"

@implementation SegmentDemoViewController

@synthesize segmentDemo1;

- (void)loadView {
	[super loadView];
//	JSC self.view.backgroundColor =[UIColor viewFlipsideBackgroundColor];

	segmentDemo1 = [[self class] segmentDemo1TabBar] ;
	
	[self.view addSubview:segmentDemo1];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


+(CGFloat) getCellWidth {
    return [UIScreen mainScreen].bounds.size.width/5;
}


/////////////////////////////////////////////////////////////////////////////////////

+ (PLSegmentView*)segmentDemo1TabBar
{

    CGRect screenRect = [[UIScreen mainScreen] bounds];
	PLSegmentView* segmentDemo = [[PLSegmentView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 50)];
	
//	NSArray* imageNormalArray = [@"tabContacts.png;tabMessages.png;tabBrowser.png;tabActivity.png;tabMe.png" componentsSeparatedByString:@";"];
    NSArray* imageNormalArray = [@"tabContacts1.png;tabMessages1.png;tabBrowser1.png;tabActivity1.png;tabCamera" componentsSeparatedByString:@";"];

	NSArray* imageSelectedArray = [@"tabContactsSel1.png;tabMessagesSel1.png;tabBrowserSel1.png;tabActivitySel1.png;tabCamera" componentsSeparatedByString:@";"];
	[segmentDemo setupCellsByImagesName:imageNormalArray selectedImagesName:imageSelectedArray offset:CGSizeMake(screenRect.size.width/5, 0)];

//	NSArray* imageNormalArray = [@"tabContacts;tabMessages;tabBrowser;tabActivity;tabTakes" componentsSeparatedByString:@";"];
//    [segmentDemo setupCellsByImagesName:imageNormalArray normalImage:[UIImage imageNamed:@"tabButton"] selectedImage:[UIImage imageNamed:@"tabSelected"] offset:CGSizeMake([SegmentDemoViewController getCellWidth], 0)];
	return segmentDemo;
}

+ (PLSegmentView*)segmentDemo1TabBarLandscape
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	PLSegmentView* segmentDemo = [[PLSegmentView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 50)];
	
	NSArray* imageNormalArray = [@"tabContactsLand.png;tabMessagesLand.png;tabBrowserLand.png;tabActivityLand.png;tabMeLand.png" componentsSeparatedByString:@";"];
	NSArray* imageSelectedArray = [@"tabContactsLandSel.png;tabMessagesLandSel.png;tabBrowserLandSel.png;tabActivityLandSel.png;tabMeLandSel.png" componentsSeparatedByString:@";"];
	[segmentDemo setupCellsByImagesName:imageNormalArray selectedImagesName:imageSelectedArray offset:CGSizeMake(screenRect.size.width/5, 0)];
	return segmentDemo;
}


+ (PLSegmentView*)segmentDemoVideoTabBar {
    CGRect screenRect = [[UIScreen mainScreen] bounds];

	PLSegmentView* segmentDemo = [[PLSegmentView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 50)];
	
	NSArray* imageNormalArray = [@"tabContacts1.png;tabMessages1.png;tabBrowser1.png;tabActivity1.png;tabInVideoCall1.png" componentsSeparatedByString:@";"];
	NSArray* imageSelectedArray = [@"tabContactsSel1.png;tabMessagesSel1.png;tabBrowserSel1.png;tabActivitySel1.png;tabInVideoCall1.png" componentsSeparatedByString:@";"];
	[segmentDemo setupCellsByImagesName:imageNormalArray selectedImagesName:imageSelectedArray offset:CGSizeMake(screenRect.size.width/5, 0)];
	return segmentDemo;
}

+ (PLSegmentView*)segmentDemoVideoSelectedTabBar {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	PLSegmentView* segmentDemo = [[PLSegmentView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 50)];
	
	NSArray* imageNormalArray = [@"tabContacts1.png;tabMessages1.png;tabBrowser1.png;tabActivity1.png;tabSelInVideoCall1.png" componentsSeparatedByString:@";"];
	NSArray* imageSelectedArray = [@"tabContactsSel1.png;tabMessagesSel1.png;tabBrowserSel1.png;tabActivitySel1.png;tabSelInVideoCall1.png" componentsSeparatedByString:@";"];
	[segmentDemo setupCellsByImagesName:imageNormalArray selectedImagesName:imageSelectedArray offset:CGSizeMake(screenRect.size.width/5, 0)];
	return segmentDemo;
}

+ (PLSegmentView*)segmentDemoAudioTabBar {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	PLSegmentView* segmentDemo = [[PLSegmentView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 50)];
	
	NSArray* imageNormalArray = [@"tabContacts1.png;tabMessages1.png;tabBrowser1.png;tabActivity1.png;tabInAudioCall1.png" componentsSeparatedByString:@";"];
	NSArray* imageSelectedArray = [@"tabContactsSel1.png;tabMessagesSel1.png;tabBrowserSel1.png;tabActivitySel1.png;tabInAudioCall1.png" componentsSeparatedByString:@";"];
	[segmentDemo setupCellsByImagesName:imageNormalArray selectedImagesName:imageSelectedArray offset:CGSizeMake(screenRect.size.width/5, 0)];
	return segmentDemo;
}

+ (PLSegmentView*)segmentDemoAudioSelectedTabBar {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	PLSegmentView* segmentDemo = [[PLSegmentView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 50)];
	
	NSArray* imageNormalArray = [@"tabContacts1.png;tabMessages1.png;tabBrowser1.png;tabActivity1.png;tabSelInAudioCall1.png" componentsSeparatedByString:@";"];
	NSArray* imageSelectedArray = [@"tabContactsSel1.png;tabMessagesSel1.png;tabBrowserSel1.png;tabActivitySel1.png;tabSelInAudioCall1.png" componentsSeparatedByString:@";"];
	[segmentDemo setupCellsByImagesName:imageNormalArray selectedImagesName:imageSelectedArray offset:CGSizeMake(screenRect.size.width/5, 0)];
	return segmentDemo;
}

@end