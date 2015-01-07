//
//  GalleryViewController.m
//  Photos
//
//  Created by Andrey Syvrachev on 21.05.13.
//  Copyright (c) 2013 Andrey Syvrachev. All rights reserved.
//

#import "GalleryViewController.h"
#import "BookmarkUIActivity.h"
#import "MessageBalloonView.h"
#import "GalleryCell.h"
#import "idoubs2AppDelegate.h"
#import "SeequDropboxActivity.h"

static BOOL isPresented;

@interface GalleryViewController ()<ASGalleryViewControllerDelegate> {
    BOOL needToResetTranslusient;

}
@property (nonatomic,retain) UIButton* shareButton;
@end

@implementation GalleryViewController
@synthesize userName;
@synthesize galleryDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isPresented = NO;
    }
    return self;
}

+(BOOL) isPreviewAvailable {
    return isPresented;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    needToResetTranslusient = NO;
    isPresented = YES;

	// Do any additional setup after loading the view.
// JSC    [self setWantsFullScreenLayout:YES] to self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = self.userName;
    UIButton*  button =  [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* im = [UIImage imageNamed:@"defaultSeequBackButton.png"];
    button.frame = CGRectMake(0, 0, im.size.width, im.size.height);
    [button setBackgroundImage:im forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onButtonBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem*  item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem =item;
    
    _shareButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* im1 = [UIImage imageNamed:@"defaultSeequActionButton.png"];
    _shareButton.frame = CGRectMake(0, 0, im1.size.width, im1.size.height);
    [_shareButton setBackgroundImage:im1 forState:UIControlStateNormal];
    [_shareButton addTarget:self action:@selector(shareClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*  item1 = [[UIBarButtonItem alloc] initWithCustomView:_shareButton];
    [self.navigationController.navigationBar setBackgroundImage: [UIImage imageNamed:@"seequNavigationDefaultBG.png"] forBarMetrics:UIBarMetricsDefault];
    _shareButton.enabled = NO;
//    firstTime = YES;
//    _currentIndex = [self getCurrentIndex];
    
    self.navigationItem.rightBarButtonItem = item1;
//    JSC self.wantsFullScreenLayout =  YES to self.edgesForExtendedLayout = UIRectEdgeNone;
    self.hidesBottomBarWhenPushed = YES;
    self.navigationController.navigationBar.translucent = YES;
    
    
//    [_collectionView registerClass:[GalleryCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
//    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//    [self.view bringSubviewToFront:_balloon];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([idoubs2AppDelegate sharedInstance].messageFromActivity == YES && (
        [idoubs2AppDelegate sharedInstance].messageFromActivityImage || [idoubs2AppDelegate sharedInstance].messageFromActivityVideoPath)) {
        [self dismissViewControllerAnimated:NO completion:^{
            if ([self.galleryDelegate respondsToSelector:@selector(didDismissViewController)]) {
                [self.galleryDelegate didDismissViewController];
            }
        }];
    }

}

-(void) shareClicked:(id) sender {
    ///@todo levon get  image and  text from  collection view  cell
     GalleryCellInfo* info = [_assets objectAtIndex:self.selectedIndex];
    NSArray* dataToShare = @[info.actualImage];
    BookmarkUIActivity *forwardActivity = [[BookmarkUIActivity alloc] initWithType:Activity_Type_Forward];
        SeequDropboxActivity *dropboxActivity=[[SeequDropboxActivity alloc] init];
        dropboxActivity.activityItems=@[info];
        NSMutableArray *activitiesArray=[[NSMutableArray alloc] init];
        [activitiesArray addObject:forwardActivity];
        [activitiesArray addObject:dropboxActivity];
        UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                      applicationActivities:activitiesArray];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    [self presentViewController:activityViewController animated:NO completion:^{
        
    }];
    
}

-(NSUInteger)numberOfAssetsInGalleryController:(ASGalleryViewController *)controller
{
    return [self.assets count];
}

-(id<ASGalleryAsset>)galleryController:(ASGalleryViewController *)controller assetAtIndex:(NSUInteger)index
{
    return self.assets[index];
}

-(void)updateTitle
{
   // self.title = [NSString stringWithFormat:NSLocalizedString(@"%u of %u", nil),self.selectedIndex + 1,[self numberOfAssetsInGalleryController:self]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([[idoubs2AppDelegate sharedInstance].videoService isInCall]){
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView setVideoState:VideoViewState_HIDE Animation:YES];
    }

    
  //  [self updateTitle];
}

-(void)selectedIndexDidChangedInGalleryController:(ASGalleryViewController*)controller;
{
  //  [self updateTitle];
    [self updateShareButton];
}


- (IBAction) onButtonBack:(id)sender {
    needToResetTranslusient = YES; /// bad  solution  but  need to make  workaround
//    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
//        [self.showImagedelegate toMasterView];
//    }
    UIViewController *controller = [self.navigationController.viewControllers objectAtIndex:0];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.hidesBottomBarWhenPushed = YES;
        controller.hidesBottomBarWhenPushed = YES;
    } else {
        self.hidesBottomBarWhenPushed = NO;
        controller.hidesBottomBarWhenPushed = NO;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        isPresented = NO;
    }];
    
    
}

-(void) updateShareButton {
    GalleryCellInfo* info = [_assets objectAtIndex:self.selectedIndex];
    if (info.actualImage) {
        _shareButton.enabled = YES;
    } else {
        _shareButton.enabled = NO;
    }

}
- (NSUInteger)supportedInterfaceOrientations{
        return UIInterfaceOrientationMaskAll;
}
-(BOOL)shouldAutorotate{
        return YES;
}
-(BOOL)shouldAutomaticallyForwardRotationMethods{
        return NO;
}
@end
