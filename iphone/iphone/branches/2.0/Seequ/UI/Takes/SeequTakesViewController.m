//
//  SeequTakesViewController.m
//  ProTime
//
//  Created by Toros Torosyan on 4/9/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import "idoubs2AppDelegate.h"
#import "SeequTakesViewController.h"
#import "SeequTakesCollectionViewCell.h"
#import "SeequTakesCollectionViewLayout.h"
#import "NavigationBar.h"
#import "BackBarButton.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "MessageItem.h"
#import <ImageIO/ImageIO.h>
#import "Common.h"
#import "GalleryViewController.h"
#import "SeequVideoRecorerViewController.h"
#import "AviaryPickerController.h"
#import "GalleryCellInfo.h"

#define CELL_COUNT 30
#define CELL_IDENTIFIER @"WaterfallCell"
#define CELL_HEIGHT_WIDTH 143



static NSString* const WaterfallCellIdentifier = @"WaterfallCell";
static NSString* const WaterfallHeaderIdentifier = @"WaterfallHeader";

@interface SeequTakesViewController ()<SeequCollectionViewDelegateWaterfallLayout, UICollectionViewDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout,SeequTakesCollectionViewCellDelegate,SeequVideoRecorerViewControllerDelegate,UIActionSheetDelegate,AviaryPickerDelegate> {
    UIView *activityView;
     Message_Type message_Type;
}

@property (nonatomic, strong) NSMutableArray *cellHeights;
@property (nonatomic, strong) NSMutableArray *cellSizes;
@end

@implementation SeequTakesViewController

@synthesize collection;
@synthesize allAssets = _allAssets;
@synthesize assetExport;
@synthesize activityIndicator;
@synthesize assetLibrary = _assetLibrary;
@synthesize allAssetsUrl = _allAssetsUrl;
@synthesize isLibraryChanged = _isLibraryChanged;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    activityView = [[UIView alloc] initWithFrame: self.view.bounds];
    activityView.backgroundColor = [UIColor clearColor];

   // [self.view setAutoresizesSubviews:YES];
    SeequTakesCollectionViewLayout *layout = [[SeequTakesCollectionViewLayout alloc] init];
//    if ([[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound) {
//        
//        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
//        layout.headerHeight = 15;
//        layout.footerHeight = 10;
//        layout.minimumColumnSpacing = COLUMN_SPACING_IPAD;
//        layout.minimumInteritemSpacing = COLUMN_SPACING_IPAD;
//        layout.columnCount = 4;
//        
////        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
////        layout.headerHeight = 15;
////        layout.footerHeight = 10;
////        layout.minimumColumnSpacing = COLUMN_SPACING;
////        layout.minimumInteritemSpacing = COLUMN_SPACING;
////        layout.columnCount =  2;
//
//        
//    }else{
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.headerHeight = 15;
        layout.footerHeight = 10;
        layout.minimumColumnSpacing = COLUMN_SPACING;
        layout.minimumInteritemSpacing = COLUMN_SPACING;
        layout.columnCount =  2;
        
 //   }
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - 100/2,[[UIScreen mainScreen] bounds].size.height/2 - 100/2,100,100);
    activityIndicator.hidden = NO;
    [activityView addSubview: activityIndicator];
    activityIndicator.center = activityView.center;
     [self UpdateAllAssets];
    [collection setCollectionViewLayout:layout];
    collection.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  //  collection.dataSource = self;
    collection.delegate = self;
    collection.backgroundColor = [UIColor blackColor];
    
    
    [collection registerClass:[SeequTakesCollectionViewCell class]
        forCellWithReuseIdentifier:CELL_IDENTIFIER];
    
  self.assetLibrary = [SeequTakesViewController defaultAssetsLibrary];
//    self.assetLibrary = [ALAssetsLibrary new];
    
//    [collection registerClass:[CHTCollectionViewWaterfallHeader class]
//        forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader
//               withReuseIdentifier:HEADER_IDENTIFIER];
//    [collection registerClass:[CHTCollectionViewWaterfallFooter class]
//        forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter
//               withReuseIdentifier:FOOTER_IDENTIFIER];

   
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(doUpdate:)
//                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(UpdateAllAssets)name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAssetChangedNotifiation:) name:ALAssetsLibraryChangedNotification object:_assetLibrary];
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    //UIImageView * img = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
    
    [self.navigationController.navigationBar setBackgroundImage: [UIImage imageNamed:@"seequNavigationDefaultBG.png"] forBarMetrics:UIBarMetricsDefault];
//    BackBarButton *cameraBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"seequTakesCamera"]
//                                                                      style:UIBarButtonItemStylePlain
//                                                                     target:self
//                                                                     action:@selector(onCameraClicked)];

    
       //[cameraBarButton setImageInsets:UIEdgeInsetsMake(11, 11, 11, 11)];
    //[cameraBarButton setTintColor:[UIColor whiteColor]];
//    self.navigationItem.rightBarButtonItem = cameraBarButton;
    self.navigationItem.title = @"Takes";
    if(_isLibraryChanged){
        _isLibraryChanged = NO;
        [self UpdateAllAssets];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)cellSizes {
    if (!_cellSizes) {
        _cellSizes = [NSMutableArray array];
        for (NSInteger i = 0; i < CELL_COUNT; i++) {
            CGSize size = CGSizeMake(arc4random() % 50 + 50, arc4random() % 50 + 50);
            _cellSizes[i] = [NSValue valueWithCGSize:size];
        }
    }
    return _cellSizes;
}

#pragma mark - Life Cycle

- (void)dealloc {
    collection.delegate = nil;
    collection.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateLayoutForOrientation:toInterfaceOrientation];
}

- (void)updateLayoutForOrientation:(UIInterfaceOrientation)orientation {
//    SeequTakesCollectionViewLayout *layout =
//    (SeequTakesCollectionViewLayout *)self.collection.collectionViewLayout;
    
    //layout.columnCount = UIInterfaceOrientationIsPortrait(orientation) ? 2 : 3;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   // return CELL_COUNT;
    return [self.allAssets count ];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SeequTakesCollectionViewCell *cell =
    (SeequTakesCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                                forIndexPath:indexPath];
    cell.delegate = self;
    ALAsset *alasset;
    if(_allAssets[indexPath.row]){
        alasset =   [self.allAssets objectAtIndex:indexPath.row];
        if([[alasset valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]){
            cell.videoPlayButton.hidden = YES;
        }else {
            cell.videoPlayButton.hidden = NO;
        }
        if(alasset){
            UIImage *img = [UIImage imageWithCGImage:alasset.thumbnail];
            cell.imageView.image =  img;
        }
        
    }

    return cell;
}


- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition{
    
    
    
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(_allAssets[indexPath.row]){
     
         ALAsset *alasset = _allAssets[indexPath.row];
        if([[alasset valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]){
            
      //      SeequShowImageViewController *showImageViewController = [[SeequShowImageViewController alloc] initWithNibName:@"SeequShowImageViewController" bundle:nil];
    
            self.imageArray = [[NSMutableArray alloc] init];
            MessageItem* item = [[MessageItem alloc] init];
            item.url = @"";
            item.stringMessageText = @"";
            UIImage* img = [UIImage imageWithCGImage:alasset.defaultRepresentation.fullResolutionImage];
            item.image = img;
            GalleryCellInfo* info = [[GalleryCellInfo alloc] init];
            info.item = item;
            info.actualImage = img;
            [self.imageArray addObject:info];
//            showImageViewController.isCalledFromTakes = YES;
//            showImageViewController.dataArray = self.imageArray;
//            showImageViewController.url = item.url;
//            showImageViewController.showImagedelegate = self;
//            showImageViewController.message = @"";
            //showImageViewController.userName = self.stringNavigationTitle;
            //    UIViewController *controller = [self.navigationController.viewControllers objectAtIndex:0];
            //    controller.hidesBottomBarWhenPushed = YES;
            //    [idoubs2AppDelegate RefreshTab];
            
            //   [self.navigationController pushViewController:showImageViewController animated:YES];
//            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
//            UINavigationController*  nc = [[UINavigationController alloc] initWithRootViewController:showImageViewController];
//            [self presentViewController:nc animated:YES completion:nil];
            
            GalleryViewController*  vc = [GalleryViewController alloc];
            vc.assets = self.imageArray;
            vc.userName  = @"";
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
            UINavigationController*  nc = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:nc animated:YES completion:nil];
            
            
            
        }else {
            NSURL* url = [alasset valueForProperty:@"ALAssetPropertyAssetURL"];
            SeequMPViewController* mPlayer = [[SeequMPViewController alloc] init];
           // mPlayer.delegate = self;
            mPlayer.isResponse = YES;
            mPlayer.url = url;
            [self presentViewController:mPlayer animated:YES completion:^{
                
            }];

        }
    }
//    NSURL* url = [_allAssets[indexPath.row] valueForProperty:@"ALAssetPropertyAssetURL"];
//    SeequMPViewController* mPlayer = [[SeequMPViewController alloc] init];
//    mPlayer.delegate = self;
//    mPlayer.isResponse = YES;
//    mPlayer.url = url;
//    [self presentViewController:mPlayer animated:YES completion:^{
//        
//    }];
    
}
-(void) UpdateAllAssets{
    [self.view addSubview:activityView];
    [activityIndicator startAnimating];
    [self performSelector:@selector(getAssetsFromLibrary) withObject:nil afterDelay:0.01];
    
    
}

-(void)getAssetsFromLibrary{
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        self.allAssets = [[NSMutableArray alloc] init];
        self.allAssetsUrl = [[NSMutableArray alloc] init];
        //ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
       // ALAssetsLibrary *assetLibrary = [SeequTakesViewController defaultAssetsLibrary];
        [_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop){
            
            if (group && [[group valueForProperty:ALAssetsGroupPropertyName]isEqualToString:@"Camera Roll"] ){
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop){
                    if (asset){
                        if([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]){
                            
                            NSDictionary *meta = [[asset defaultRepresentation] metadata];
                            NSDictionary *exif=[meta objectForKey:(NSString *)kCGImagePropertyExifDictionary];
                            NSString *uresComment=[exif objectForKey:(NSString*)kCGImagePropertyExifLensMake];
                            if ([uresComment isEqualToString:@"Seequ"]) {
                                
                                [_allAssets addObject:asset];
                                [_allAssetsUrl addObject:[asset valueForProperty:ALAssetPropertyAssetURL] ];
                            }
                        }else if([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
                            
                            AVURLAsset *assetURL = [AVURLAsset URLAssetWithURL:[asset valueForProperty:ALAssetPropertyAssetURL ]options:nil];
                            NSArray *publisherArray = [AVMetadataItem metadataItemsFromArray:assetURL.commonMetadata withKey:AVMetadataCommonKeyPublisher keySpace:AVMetadataKeySpaceCommon];
                            if(publisherArray.count > 0){
                                AVMetadataItem *publisher = [publisherArray objectAtIndex:0];
                                NSString* publisherStr = [publisher.value copyWithZone:nil];
                                if([publisherStr isEqualToString:@"Seequ"]){
                                    [_allAssets addObject:asset];
                                    [_allAssetsUrl addObject:[asset valueForProperty:ALAssetPropertyAssetURL] ];
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                }];
                
                NSComparisonResult (^sortBlock)(id, id) = ^(id obj1, id obj2) {
                    NSDate * date1 = [obj1 valueForProperty:ALAssetPropertyDate];
                    NSDate * date2 = [obj2 valueForProperty:ALAssetPropertyDate];
                    return (NSComparisonResult)[date1 compare:date2];
                    
                };
                NSArray *sorted = [_allAssets sortedArrayUsingComparator:sortBlock];
                _allAssets = [NSMutableArray arrayWithArray:sorted];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[collection reloadData];
                    
                    if(stop){
                        [activityIndicator stopAnimating];
                        [activityView removeFromSuperview];
                        if(_allAssets.count == 0 && self.tabBarController.selectedIndex == 4){
                            UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"" message:@"There is no media for \"Takes\"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            alert.delegate = self;
                            [alert show];
                            
                        }else{

                        [collection reloadData];
                        }
                    }
                    
                });
                
            }
        } failureBlock:^(NSError *error){
            
            NSLog(@"error enumerating AssetLibrary groups %@\n", error);
        }];
        
        
        
    });
    
}

-(void) handleAssetChangedNotifiation:(NSNotification *) notification {
    if(IS_IOS_7){
        
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            void(^EnumerateGroupBlock)(ALAssetsGroup *group, BOOL *stop) = ^(ALAssetsGroup *group, BOOL *stop){
                // [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                if(group && [[group valueForProperty:ALAssetsGroupPropertyName]isEqualToString:@"Camera Roll"]  ){
                    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    }];
                }
            };
            [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:EnumerateGroupBlock failureBlock:NULL];
            
            NSDictionary *userInfo = notification.userInfo;
            NSSet *updateAssets = userInfo[ALAssetLibraryUpdatedAssetsKey];
            if (updateAssets.count>0) {
                [[updateAssets allObjects] enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
                    [self.assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                        
                        
                        if (asset && ![_allAssets containsObject:asset]){
                            
                            if([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]){
                                
                                NSDictionary *meta = [[asset defaultRepresentation] metadata];
                                NSDictionary *exif=[meta objectForKey:(NSString *)kCGImagePropertyExifDictionary];
                                NSString *uresComment=[exif objectForKey:(NSString*)kCGImagePropertyExifLensMake];
                                if ([uresComment isEqualToString:@"Seequ"]) {
                                    if (asset && ![_allAssetsUrl containsObject:[asset valueForProperty:ALAssetPropertyAssetURL]]){
                                        [_allAssets addObject:asset];
                                        [_allAssetsUrl addObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [collection reloadData];
                                        });
                                    }
                                    
                                }
                            }else if([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
                                
                                AVURLAsset *assetURL = [AVURLAsset URLAssetWithURL:[asset valueForProperty:ALAssetPropertyAssetURL ]options:nil];
                                NSArray *publisherArray = [AVMetadataItem metadataItemsFromArray:assetURL.commonMetadata withKey:AVMetadataCommonKeyPublisher keySpace:AVMetadataKeySpaceCommon];
                                if(publisherArray.count > 0){
                                    AVMetadataItem *publisher = [publisherArray objectAtIndex:0];
                                    NSString* publisherStr = [publisher.value copyWithZone:nil];
                                    if([publisherStr isEqualToString:@"Seequ"]){
                                        if (asset && ![_allAssetsUrl containsObject:[asset valueForProperty:ALAssetPropertyAssetURL]]){
                                            [_allAssets addObject:asset];
                                            [_allAssetsUrl addObject:[asset valueForProperty:ALAssetPropertyAssetURL]];
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [collection reloadData];
                                            });
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                            }
                        }
                    } failureBlock:^(NSError *error) {
                    }];
                    
                    
                }];
            }
            
            
            
        });
    }else{
        _isLibraryChanged = YES;
    }

    
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    UICollectionReusableView *reusableView = nil;
//    
//    if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
//        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
//                                                          withReuseIdentifier:HEADER_IDENTIFIER
//                                                                 forIndexPath:indexPath];
//    } else if ([kind isEqualToString:CHTCollectionElementKindSectionFooter]) {
//        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
//                                                          withReuseIdentifier:FOOTER_IDENTIFIER
//                                                                 forIndexPath:indexPath];
//    }
//    
//    return reusableView;
//}

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

#pragma mark - SeeqUCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //return [self.cellSizes[indexPath.item] CGSizeValue];
    return CGSizeMake(CELL_HEIGHT_WIDTH, CELL_HEIGHT_WIDTH);

}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 22;
    }
    return 100;
}
- (void) GoBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onClickLikeButton{

}

-(void) viewWillLayoutSubviews{
    
}
- (void) onClickCommentButton{
    
}
- (void) onClickBigLikeButton{
    
}
-(void) toMasterView {
    
}

-(void) onCameraClicked{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Seequ"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Send photo", @"Send video",@"Send double take", nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [sheet showFromTabBar:[idoubs2AppDelegate sharedInstance].tabBarController.tabBar];
    
}
#pragma ActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0: {
            if (![[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    SeequVideoRecorerViewController*  videoRecorder = [[SeequVideoRecorerViewController alloc] initWithType:SeequRecorderTypePhoto];
                    videoRecorder.captureDelegate =self;
                    videoRecorder.devicePosition = AVCaptureDevicePositionBack;
                    message_Type = Message_Type_Video;
                    [self.tabBarController presentViewController:videoRecorder animated:YES completion:nil];
                    
                });
            } else {
                AviaryPickerController * imagePicker = [AviaryPickerController new];
                [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                imagePicker.avDelegate = self;
                
                [self.tabBarController presentViewController:imagePicker animated:YES completion:nil];
            }
            
        }
            break;
        case 1: {
            dispatch_async(dispatch_get_main_queue(), ^{
                SeequVideoRecorerViewController*  videoRecorder = [[SeequVideoRecorerViewController alloc] initWithType:SeequRecorderTypeVideo];
                videoRecorder.captureDelegate =self;
                videoRecorder.devicePosition = AVCaptureDevicePositionFront;
                message_Type = Message_Type_Video;
                [self.tabBarController presentViewController:videoRecorder animated:YES completion:nil];
                
            });
        }
            break;
        case 2: {
            dispatch_async(dispatch_get_main_queue(), ^{
                SeequVideoRecorerViewController*  videoRecorder = [[SeequVideoRecorerViewController alloc] initWithType:SeequRecorderTypeDoubleTake];
                videoRecorder.captureDelegate =self;
                message_Type = Message_Type_Double_Take;
                videoRecorder.devicePosition = AVCaptureDevicePositionFront;
                
                [self.tabBarController presentViewController:videoRecorder animated:YES completion:nil];
            });
        }
            break;
        default:
            break;
    }
    
}

-(void)captureFinished:(NSURL *)url fromLibrary:(BOOL)library{
    
}
-(void)takePhotoFinished:(UIImage *)image{
    
}
-(void)didFinish:(SeequVideoRecorerViewController *)controller Image:(UIImage *)img HighResolutionImage:(UIImage *)himg fromLibrary:(BOOL)library{
    
}

@end
