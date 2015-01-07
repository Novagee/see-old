//
//  SeequAssetsViewController.h
//  ProTime
//
//  Created by Grigori Jlavyan on 8/12/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALAssetAdapter.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SeequVideoRecorerViewController.h"

@interface SeequAssetsViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) ALAssetsGroup *assetsGroup;
@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) NSMutableArray *checkedAssetsNumbers;
@property (strong, nonatomic) NSMutableArray *info;
@property (strong, nonatomic) NSMutableArray *thumbnails;
@property (strong, nonatomic) NSMutableArray *assetsDurations;
@property (strong, nonatomic) UIVideoEditorController *videoEditor;
@property (nonatomic) BOOL isPlayerPlaying;
@property (strong, nonatomic) MPMoviePlayerViewController *player;
@property (nonatomic) SeequPickerType pickerType;
- (id)initWithFrame:(CGRect)frame;
@end
