//
//  SeequTakesViewController.h
//  ProTime
//
//  Created by Toros Torosyan on 4/9/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationBar.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "SeequMPViewController.h"



#define COLUMN_SPACING 13
#define COLUMN_SPACING_IPAD 39.2
@interface SeequTakesViewController : UIViewController
@property (strong, nonatomic) IBOutlet UICollectionView *collection;
@property (strong, nonatomic) NSMutableArray* imageArray;
@property(strong, nonatomic)  NSMutableArray* allAssets;
@property(strong, nonatomic)  NSMutableArray* allAssetsUrl;

@property(strong, nonatomic) AVAssetExportSession* assetExport;
@property( strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property( strong, nonatomic)  ALAssetsLibrary *assetLibrary;
@property (nonatomic, assign) BOOL isLibraryChanged;

+ (ALAssetsLibrary *)defaultAssetsLibrary;
- (void) onClickLikeButton;
- (void) onClickCommentButton;
- (void) onClickBigLikeButton;
- (void) onCameraClicked;
-(void)getAssetsFromLibrary;
@end
