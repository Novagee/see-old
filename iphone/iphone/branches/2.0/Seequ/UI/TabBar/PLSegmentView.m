//
//  PLSegmentView.m
//  PlutoLand
//
//  Created by xu xhan on 7/22/10.
//  Copyright 2010 xu han. All rights reserved.
//

#import "PLSegmentView.h"
#import "idoubs2AppDelegate.h"

/////////////////////////////////////////////////////////////////////////////////////
@interface PLSegmentView(private)

- (void)onCellClicked:(PLSegmentCell*)cell;
- (void)onCellDoubleClicked:(PLSegmentCell*)cell;
- (void)onCellDownRepeat:(PLSegmentCell*)cell withEvent:(UIEvent*)event;


@end

/////////////////////////////////////////////////////////////////////////////////////

@implementation PLSegmentView

@synthesize tabWidth;
@synthesize  backgroundImageView = _backgroundImageView ;
@synthesize delegate;
@dynamic selectedIndex;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
		_backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		[self addSubview:_backgroundImageView];
        self.tabWidth = [idoubs2AppDelegate sharedInstance].window.frame.size.width/5;
//		_isMultyCellSelectable = NO;
		_items = [NSMutableArray array] ;
		_selectedIndex = -1;
        state_inCall = NO;
        state_showProfile = YES;
    }
    return self;
}
-(CGFloat) getCellWidth {
    return [UIScreen mainScreen].bounds.size.width/5;
}

- (void)segmentDemo1TabBar
{
    [self StopAnimation];
    
	NSArray* imageNormalArray = [@"tabContacts1.png;tabMessages1;tabBrowser1;tabActivity1;tabCamera" componentsSeparatedByString:@";"];
	NSArray* imageSelectedArray = [@"tabContactsSel1.png;tabMessagesSel1.png;tabBrowserSel1.png;tabActivitySel1.png;tabCamera" componentsSeparatedByString:@";"];
	[self setupCellsByImagesName:imageNormalArray selectedImagesName:imageSelectedArray offset:CGSizeMake(self.tabWidth, 0)];
 //   [self setupCellsByImagesName:imageNormalArray normalImage:[UIImage imageNamed:@"tabButton"] selectedImage:[UIImage imageNamed:@"tabSelected"] offset:CGSizeMake([self getCellWidth], 0)];
    imageAnimationBG = nil;
}

- (void)segmentDemoVideoTabBar {
    [self StopAnimation];

	NSArray* imageNormalArray = [@"tabContacts1;tabMessages1;tabBrowser1;tabActivity1;tabInVideoCall1" componentsSeparatedByString:@";"];
	NSArray* imageSelectedArray = [@"tabContactsSel1.png;tabMessagesSel1.png;tabBrowserSel1.png;tabActivitySel1.png;tabInVideoCall1.png" componentsSeparatedByString:@";"];
	[self setupCellsByImagesName:imageNormalArray selectedImagesName:imageSelectedArray offset:CGSizeMake(self.tabWidth, 0)];
  //  [self setupCellsByImagesName:imageNormalArray normalImage:[UIImage imageNamed:@"tabButton"] selectedImage:[UIImage imageNamed:@"tabSelected"] offset:CGSizeMake([self getCellWidth], 0)];//lastSelectedImage:[UIImage imageNamed:@"tabInCallButton"]

    
    imageAnimationBG = [UIImage imageNamed:@"tabInVideoCallBlack.png"];
}

- (void)segmentDemoVideoSelectedTabBar {
    [self StopAnimation];


	NSArray* imageNormalArray = [@"tabContacts1.png;tabMessages1;tabBrowser1;tabActivity1;tabSelInVideoCall1" componentsSeparatedByString:@";"];
   // NSArray* imageNormalArray = [@"tabContacts.png;tabMessages;tabBrowser;tabActivity;tabSelInVideoCall" componentsSeparatedByString:@";"];
	NSArray* imageSelectedArray = [@"tabContactsSel1.png;tabMessagesSel1.png;tabBrowserSel1.png;tabActivitySel1.png;tabSelInVideoCall1.png" componentsSeparatedByString:@";"];
	[self setupCellsByImagesName:imageNormalArray selectedImagesName:imageSelectedArray offset:CGSizeMake(self.tabWidth, 0)];
 //   [self setupCellsByImagesName:imageNormalArray normalImage:[UIImage imageNamed:@"tabButton"] selectedImage:[UIImage imageNamed:@"tabSelected"] lastSelectedImage:[UIImage imageNamed:@"tabInCallButton"] offset:CGSizeMake([self getCellWidth], 0)];
    imageAnimationBG = [UIImage imageNamed:@"tabMe.png"];
}

- (void)segmentDemoAudioTabBar {
    [self StopAnimation];

	NSArray* imageNormalArray = [@"tabContacts1.png;tabMessages1.png;tabBrowser1.png;tabActivity1.png;tabInAudioCall1.png" componentsSeparatedByString:@";"];
//	NSArray* imageNormalArray = [@"tabContacts.png;tabMessages.png;tabBrowser.png;tabActivity.png;tabInAudioCall.png" componentsSeparatedByString:@";"];

	NSArray* imageSelectedArray = [@"tabContactsSel1.png;tabMessagesSel1.png;tabBrowserSel1.png;tabActivitySel1.png;tabInAudioCall1.png" componentsSeparatedByString:@";"];
	[self setupCellsByImagesName:imageNormalArray selectedImagesName:imageSelectedArray offset:CGSizeMake(self.tabWidth, 0)];
  //  [self setupCellsByImagesName:imageNormalArray normalImage:[UIImage imageNamed:@"tabButton"] selectedImage:[UIImage imageNamed:@"tabSelected"] lastSelectedImage:[UIImage imageNamed:@"tabInCallButton"] offset:CGSizeMake([self getCellWidth], 0)];
    imageAnimationBG = [UIImage imageNamed:@"tabInAudioCallBlack.png"];
}

- (void)segmentDemoAudioSelectedTabBar {
    [self StopAnimation];

	NSArray* imageNormalArray = [@"tabContacts1.png;tabMessages1.png;tabBrowser1.png;tabActivity1.png;tabSelInAudioCall1.png" componentsSeparatedByString:@";"];
//	NSArray* imageNormalArray = [@"tabContacts.png;tabMessages.png;tabBrowser.png;tabActivity.png;tabSelInAudioCall.png" componentsSeparatedByString:@";"];
	NSArray* imageSelectedArray = [@"tabContactsSel1.png;tabMessagesSel1.png;tabBrowserSel1.png;tabActivitySel1.png;tabSelInAudioCall1.png" componentsSeparatedByString:@";"];
	[self setupCellsByImagesName:imageNormalArray selectedImagesName:imageSelectedArray offset:CGSizeMake(self.tabWidth, 0)];
//    [self setupCellsByImagesName:imageNormalArray normalImage:[UIImage imageNamed:@"tabButton"] selectedImage:[UIImage imageNamed:@"tabSelected"] lastSelectedImage:[UIImage imageNamed:@"tabInCallButton"] offset:CGSizeMake([self getCellWidth], 0)];

    imageAnimationBG = [UIImage imageNamed:@"tabMe.png"];
}



- (void)segmentDemoOnHoldTabBar {
    [self StopAnimation];
    
//	NSArray* imageNormalArray = [@"tabContacts.png;tabMessages.png;tabBrowser.png;tabActivity.png;tabOnHold.png" componentsSeparatedByString:@";"];
	NSArray* imageNormalArray = [@"tabContacts1.png;tabMessages1.png;tabBrowser1.png;tabActivity1.png;tabOnHold1.png" componentsSeparatedByString:@";"];

	NSArray* imageSelectedArray = [@"tabContactsSel1.png;tabMessagesSel1.png;tabBrowserSel1.png;tabActivitySel1.png;tabOnHold1.png" componentsSeparatedByString:@";"];
    [self setupCellsByImagesName:imageNormalArray selectedImagesName:imageSelectedArray offset:CGSizeMake(self.tabWidth, 0)];

//	[self setupCellsByImagesName:imageNormalArray normalImage:[UIImage imageNamed:@"tabButton"] selectedImage:[UIImage imageNamed:@"tabSelected"] lastSelectedImage:[UIImage imageNamed:@"tabInCallButton"] offset:CGSizeMake([self getCellWidth], 0)];
    
    imageAnimationBG = [UIImage imageNamed:@"tabOnHoldBlack.png"];
}

- (void)StartAnimation {
    PLSegmentCell *cell = (PLSegmentCell*)[_items lastObject];
    if (cell) {
        [cell StartAnimationWithImage:imageAnimationBG];
    }
}

- (void)StopAnimation {
    PLSegmentCell *cell = (PLSegmentCell*)[_items lastObject];
    if (cell) {
        [cell StopAnimation];
    }
}

#pragma mark -
#pragma mark public

- (void)setupCellsByImagesName:(NSArray*)images selectedImagesName:(NSArray*)selectedImages offset:(CGSize)offset;
{
	[self setupCellsByImagesName:images selectedImagesName:selectedImages offset:offset startPosition:CGPointZero];
}

- (void)setupCellsByImagesName:(NSArray*)images selectedImagesName:(NSArray*)selectedImages offset:(CGSize)offset startPosition:(CGPoint)point
{
    for (PLSegmentCell *cell in _items) {
        [cell removeFromSuperview];
    }
    
    [_items removeAllObjects];
    
	NSAssert([images count] == [selectedImages count], @"two arrays should have same items count");
	for (int cnt = 0; cnt < [images count]; cnt++) {
		CGPoint origin = CGPointMake(offset.width * cnt + point.x, offset.height * cnt + point.y);
		PLSegmentCell* cell = [[PLSegmentCell alloc] initWithNormalImage:[UIImage imageNamed:[images objectAtIndex:cnt]]
														   selectedImage:[UIImage imageNamed:[selectedImages objectAtIndex:cnt]] 
															  startPoint:origin];
		[self addCell:cell];

	}	
}

-(void) setupCellsByImagesName:(NSArray *)images normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage offset:(CGSize)offset {
    [self setupCellsByImagesName:images normalImage:normalImage selectedImage:selectedImage offset:offset startPosition:CGPointZero];
}

-(void) setupCellsByImagesName:(NSArray *)images normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage offset:(CGSize)offset startPosition:(CGPoint)point {
    for (PLSegmentCell *cell in _items) {
        [cell removeFromSuperview];
    }
    
    [_items removeAllObjects];
    
	for (int cnt = 0; cnt < [images count]; cnt++) {
		CGPoint origin = CGPointMake(offset.width * cnt + point.x, offset.height * cnt + point.y);
        CGRect rect = CGRectMake(origin.x, origin.y, offset.width, 50);
		PLSegmentCell* cell = [[PLSegmentCell alloc] initWithImage:[UIImage imageNamed:[images objectAtIndex:cnt]] background:normalImage selectedBackground:selectedImage frame:rect]; ;
		[self addCell:cell];
        
	}
}

-(void) setupCellsByImagesName:(NSArray *)images normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage lastSelectedImage:(UIImage *)lastSelectedImage  offset:(CGSize)offset {
    [self setupCellsByImagesName:images normalImage:normalImage selectedImage:selectedImage lastSelectedImage:lastSelectedImage offset:offset startPosition:CGPointZero];
}

-(void) setupCellsByImagesName:(NSArray *)images normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage lastSelectedImage:(UIImage *)lastSelectedImage offset:(CGSize)offset startPosition:(CGPoint)point {
    for (PLSegmentCell *cell in _items) {
        [cell removeFromSuperview];
    }
    
    [_items removeAllObjects];
    
	for (int cnt = 0; cnt < [images count]; cnt++) {
		CGPoint origin = CGPointMake(offset.width * cnt + point.x, offset.height * cnt + point.y);
        CGRect rect = CGRectMake(origin.x, origin.y, offset.width, 50);
        PLSegmentCell* cell;
        if (cnt != images.count -1) {
             cell= [[PLSegmentCell alloc] initWithImage:[UIImage imageNamed:[images objectAtIndex:cnt]] background:normalImage selectedBackground:selectedImage frame:rect];

        } else {
             cell = [[PLSegmentCell alloc] initWithImage:[UIImage imageNamed:[images objectAtIndex:cnt]] background:normalImage selectedBackground:lastSelectedImage frame:rect];
        }
		[self addCell:cell];
        
	}
}

- (void)addCells:(NSArray*)cells
{
	for (PLSegmentCell* cell in cells) {
		[self addCell:cell];
	}
}



- (int)selectedIndex
{
	return _selectedIndex;
}

- (void)setSelectedIndex:(int)value
{
	int previousIndex = _selectedIndex;
	_selectedIndex = value;
	
//	if (previousIndex != _selectedIndex) {
		if(previousIndex != -1)
			((PLSegmentCell*)[_items objectAtIndex:previousIndex]).selected = NO;
		((PLSegmentCell*)[_items objectAtIndex:_selectedIndex]).selected = YES;
//	}
}

- (void) setInCall:(BOOL)inCall {
    state_inCall = inCall;
}

- (void) setShowProfile:(BOOL)showProfile {
    state_showProfile = showProfile;
}

#pragma mark -
#pragma mark private

- (void)addCell:(PLSegmentCell*)cell
{
    cell.delegate = self;
//    if (_items.count == 4) {
//        [cell addTarget:self action:@selector(onCellDownRepeat:withEvent:) forControlEvents:UIControlEventTouchDownRepeat|UIControlEventTouchUpInside];
//    } else {
        [cell addTarget:self action:@selector(onCellClicked:) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:cell action:@selector(longPress:)];
        [cell addGestureRecognizer:longPress];
 //   }
    
	[_items addObject:cell];
	[self addSubview:cell];
}

- (void)onCellDownRepeat:(PLSegmentCell*)cell withEvent:(UIEvent*)event {
    if (state_inCall) {
        UITouch* touch = [[event allTouches] anyObject];
        if (touch.tapCount == 2) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(onCellDoubleClicked:) withObject:cell afterDelay:0.15];
        } else {
            [self performSelector:@selector(onCellClicked:) withObject:cell afterDelay:0.2];
        }
    } else {
        [self onCellClicked:cell];
    }
}

-(void) didLongPressed:(PLSegmentCell *)cell {
    NSInteger index = [_items indexOfObject:cell];
    if (index ==  4) {
        return;
    }
    [[NSUserDefaults standardUserDefaults ] setObject:[NSString stringWithFormat:@"%d",index] forKey:@"defaultTabBar"];
    [self onCellClicked:cell];
}

- (void)onCellClicked:(PLSegmentCell*)cell
{
    if([_items indexOfObject:cell]==NSNotFound){
        return;
 }
	NSInteger index = [_items indexOfObject:cell];
 	NSAssert(index != NSNotFound , @"error on the cell click!");
	
    if (index == 4) {
        
        if (state_inCall) {
            if ([self.delegate respondsToSelector:@selector(segmentShowCallMenu)]) {
                [self.delegate segmentShowCallMenu];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(segmentDidClickedOnLastTab)]) {
                [self.delegate segmentDidClickedOnLastTab];
            }
            
//            ///@todo Toros
//            int previousIndex = _selectedIndex;
//            self.selectedIndex = index;
//            
//            if ([self.delegate respondsToSelector:@selector(segmentClickedAtIndex:onCurrentCell:)]) {
//                [self.delegate segmentClickedAtIndex:self.selectedIndex onCurrentCell:self.selectedIndex == previousIndex];
//            }
//            
//            ///
            
        }
    } else {
        int previousIndex = _selectedIndex;
        self.selectedIndex = index;		
        
        if ([self.delegate respondsToSelector:@selector(segmentClickedAtIndex:onCurrentCell:)]) {
            [self.delegate segmentClickedAtIndex:self.selectedIndex onCurrentCell:self.selectedIndex == previousIndex];
        }
    }
}

- (void)onCellDoubleClicked:(PLSegmentCell*)cell {
    NSLog(@"onCellDoubleClicked");

	if ([self.delegate respondsToSelector:@selector(segmentDoubleClicked)]) {
		[self.delegate segmentDoubleClicked];
	}
}


@end
