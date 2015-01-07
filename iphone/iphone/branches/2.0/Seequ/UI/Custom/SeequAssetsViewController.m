//
//  SeequAssetsViewController.m
//  ProTime
//
//  Created by Grigori Jlavyan on 8/12/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequAssetsViewController.h"
#import "SeequCollectionViewCell.h"
#import "BookmarkUIActivity.h"
#import "SeequDropboxActivity.h"
#import "SeequNewMessageContactsViewController.h"
#import "idoubs2AppDelegate.h"
#import "SeequVideoRecorerViewController.h"
#import "GalleryViewController.h"
#import <ImageIO/ImageIO.h>
#import <AviarySDK/AviarySDK.h>


#define SHARE_BUTTON_TAG 1
#define SEND_BUTTON_TAG 2
#define TEMP_FORWARD_VIDEO  @"temp_forward_video.mp4"
#define FORWARD_VIDEO  @"forward_video.mp4"

static NSString *seequCollectionCellIdentifier=@"CollectionCellIdentifier";
@interface SeequAssetsViewController () <NewMessageContactsDelegate,UIVideoEditorControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,AFPhotoEditorControllerDelegate>{
        bool selectionOn;
        NSString * forwardVideoPhate;
        UIImageView *selectedAssetView;
        NSIndexPath *selectedIndexPath;
        UIImage *editedImage;
}
@end

@implementation SeequAssetsViewController
@synthesize videoEditor=_videoEditor;

- (id)initWithFrame:(CGRect)frame
{
        self = [super init];
        if (self) {
                self.view.frame=frame;
                self.view.backgroundColor = [UIColor whiteColor];
                UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
                flowLayout.itemSize = CGSizeMake(75,70);
                [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
                [flowLayout setMinimumLineSpacing:4];
                [flowLayout setMinimumInteritemSpacing:0];
                self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-108) collectionViewLayout:flowLayout];
                self.collectionView.contentInset=UIEdgeInsetsMake(5, 3, 3, 5);
                [self.collectionView registerClass:[SeequCollectionViewCell class] forCellWithReuseIdentifier:seequCollectionCellIdentifier];
                [self.collectionView setBackgroundColor:[UIColor whiteColor]];
                [self.collectionView setDelegate:self];
                [self.collectionView setDataSource:self];
                [self.view addSubview:self.collectionView];
                selectedAssetView = [[UIImageView alloc] init];
                selectedAssetView.contentMode = UIViewContentModeScaleAspectFit;
//                selectedAssetView.layer.masksToBounds=YES;
                selectedAssetView.hidden=YES;
                selectedAssetView.userInteractionEnabled=YES;
                [self.view addSubview:selectedAssetView];
                // Custom initialization
        }
        return self;
}

- (void)viewWillAppear:(BOOL)animated
{
        [super viewWillAppear:animated];
        if (!self.assets.count) {
             [self preparePhotos];
        }
        [self.navigationController setNavigationBarHidden:NO];
        self.edgesForExtendedLayout=UIRectEdgeNone;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"seequNavigationDefaultBG.png"] forBarMetrics:UIBarMetricsDefault];
        
        
        if (self.pickerType == kPickerTypeMovie) {
                [self getAssetsDurations];
        }
        ALAssetsGroup *group = (ALAssetsGroup*)self.assetsGroup;
     UIBarButtonItem *selectButton = [[UIBarButtonItem alloc] initWithTitle:selectionOn?@"deselect":@"select" style:UIBarButtonItemStylePlain target:self action:@selector(onSelect)];
     UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Album" style:UIBarButtonItemStylePlain target:self action:@selector(onLeftBarButton)];
     [self.navigationItem setRightBarButtonItem:selectButton];
     [self.navigationItem setLeftBarButtonItem:leftBarButton];
     [self.navigationItem setTitle:[group valueForProperty:ALAssetsGroupPropertyName]];
     [self.navigationController.navigationBar setBackgroundColor:[UIColor blueColor]];
     [self.navigationController setToolbarHidden:NO];
     [self updateBarItemsStates];
}

- (void)viewDidLoad
{
        [super viewDidLoad];
        selectionOn = NO;
        forwardVideoPhate = nil;
        self.assets = [NSMutableArray array];
        self.thumbnails = [NSMutableArray array];
        UIImage *shareImage = [UIImage imageNamed:@"shareButton"];
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.bounds = CGRectMake( 0, 0, shareImage.size.width, shareImage.size.height );
        [shareButton setImage:shareImage forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(onShareButton) forControlEvents:UIControlEventTouchDown];
        UIBarButtonItem *shareBarItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
        shareBarItem.tag=SHARE_BUTTON_TAG;
        UIImage *sendImage=[UIImage imageNamed:@"defaultSeequSendButton"];
        UIButton *sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.bounds=CGRectMake(0, 0, sendImage.size.width, sendImage.size.height);
        [sendButton setImage:sendImage forState:UIControlStateNormal];
        [sendButton addTarget:self action:@selector(onSendButton) forControlEvents:UIControlEventTouchDown];
        UIBarButtonItem *sendBarItem=[[UIBarButtonItem alloc] initWithCustomView:sendButton];
        sendBarItem.tag=SEND_BUTTON_TAG;
        
        
        self.toolbarItems = @[shareBarItem,
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                              sendBarItem,
                              [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],                       [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(onCancelButton)]
                              ];
        
        
        
}

- (void)viewDidAppear:(BOOL)animated
{
        [super viewDidAppear:animated];
        [self.collectionView reloadData];
        [self.navigationController setToolbarHidden:NO];
}
- (NSUInteger)supportedInterfaceOrientations {
        return UIInterfaceOrientationMaskPortrait;
}
-(BOOL)shouldAutorotate{
        return NO;
}
-(UIVideoEditorController *)videoEditor{
        if (!_videoEditor) {
                _videoEditor=[[UIVideoEditorController alloc] init];
        }
        return _videoEditor;
}

-(void)updateBarItemsStates{
        NSArray* toolbarButtons = self.toolbarItems;
        int assetscount= selectedAssetView.hidden?[self getCheckedAssetsNumbersCount]:1;
        for (UIBarButtonItem *item in toolbarButtons) {
                if (item.tag==SHARE_BUTTON_TAG )
                        item.enabled=assetscount>0?YES:NO;
                
                if (item.tag==SEND_BUTTON_TAG )
                        item.enabled=assetscount==1?YES:NO;
        }
        if (!selectedAssetView.hidden) {
                ALAsset *asset = (ALAsset *)[self.assets objectAtIndex:selectedIndexPath.row];
                self.navigationItem.rightBarButtonItem.title = @"Edit";
                self.navigationItem.leftBarButtonItem.title = @"Photos";
                [self.navigationItem setTitle:[asset.defaultRepresentation filename]];
                
        }else{
              self.navigationItem.rightBarButtonItem.title = selectionOn?@"Deselect":@"Select";
              self.navigationItem.leftBarButtonItem.title = @"Album";
             [self.navigationItem setTitle:[self.assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
        }
}
-(int)getCheckedAssetsNumbersCount{
        int count = 0;
        for (int i = 0 ; i < self.assets.count ; i++) {
                if (![self.checkedAssetsNumbers[i] isEqual:[NSNull null]]) {
                        count++;
                }
        }
        return count;
}
-(NSMutableArray*)getCheckedAssetsThumbnailsArray{
        NSMutableArray *thumbnailsArray=[NSMutableArray array];
        for (int i = 0 ; i < self.assets.count ; i++) {
                if (![self.checkedAssetsNumbers[i] isEqual:[NSNull null]]) {
                        [thumbnailsArray addObject:self.thumbnails[i]];
                }
  
        }
        return thumbnailsArray;
}
-(void)deselectCheckedAssetsArray{
        for (int i = 0; i < self.assets.count; i++) {
                if (![self.checkedAssetsNumbers[i] isEqual:[NSNull null]]) {
                        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
                        SeequCollectionViewCell *cell = (SeequCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                       [self.checkedAssetsNumbers replaceObjectAtIndex:indexPath.row withObject:[NSNull null]];
                        cell.check.hidden = YES;
                }
        }
}
-(NSMutableArray *)getCheckedAssetsArray{
        NSMutableArray *checkedAssetsArray = [NSMutableArray array];
        for (int i = 0 ; i <self.assets.count ; i++) {
                if (![self.checkedAssetsNumbers[i] isEqual:[NSNull null]]) {
                        [checkedAssetsArray addObject:self.assets[i]];
                }
        }
        return checkedAssetsArray;
}
- (void)preparePhotos
{
        [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if(result == nil) {
                        return;
                }
                [self.assets addObject:result];
                [self.thumbnails addObject:[UIImage imageWithCGImage:[result aspectRatioThumbnail]]];
                [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }];
        self.checkedAssetsNumbers = [NSMutableArray arrayWithCapacity:self.assets.count];
        for (int i = 0; i < self.assets.count; i++) {
                [self.checkedAssetsNumbers addObject:[NSNull null]];
        }
//        [self.collectionView reloadData];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnClicked:)];
        [doneBtn setTitle:@"Done"];
        [self.navigationItem setRightBarButtonItem:doneBtn];
}

- (void)getAssetsDurations
{
        self.assetsDurations = [NSMutableArray arrayWithCapacity:self.assets.count];
        for (ALAsset *alAsset in self.assets) {
                if ([alAsset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo) {
                        if ([alAsset valueForProperty:ALAssetPropertyDuration] != ALErrorInvalidProperty) {
                                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                [formatter setDateFormat:@"mm:ss"];
                                [self.assetsDurations addObject:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[alAsset valueForProperty:ALAssetPropertyDuration] doubleValue]]]];
                        }
                }
        }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
        return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
        return [self.thumbnails count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
        UIImage *thumbnail =[self.thumbnails objectAtIndex:indexPath.row];
        SeequCollectionViewCell *cell = (SeequCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:seequCollectionCellIdentifier forIndexPath:indexPath];
        dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image=thumbnail;
        });
        [cell setBackgroundColor:[UIColor blackColor]];
        
        if (self.pickerType == kPickerTypeMovie) {
                cell.duration.hidden = NO;
                cell.duration.text =  self.assetsDurations[indexPath.row];
        }else{
                cell.duration.hidden = YES;
                
                cell.check.frame =CGRectMake(cell.imageView.frame.size.width-cell.check.frame.size.width,cell.imageView.frame.size.height-cell.check.frame.size.height, cell.check.frame.size.width, cell.check.frame.size.height);
        }
        if ([self.checkedAssetsNumbers[indexPath.row] isEqual:[NSNull null]]) {
                cell.check.hidden = YES;
        }
        else {
                cell.check.hidden = NO;
        }
        return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
        SeequCollectionViewCell *cell = (SeequCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if (selectionOn) {
                
                if (cell.check.hidden)
                {
                        [self.checkedAssetsNumbers replaceObjectAtIndex:indexPath.row withObject:@1];
                        cell.check.hidden = NO;
                }else{
                        [self.checkedAssetsNumbers replaceObjectAtIndex:indexPath.row withObject:[NSNull null]];
                        cell.check.hidden = YES;
                }
                
        }else{
                if (self.pickerType == kPickerTypeMovie) {
                        [self playAlAsset:(ALAsset*)[self.assets objectAtIndex:indexPath.row]];
                }else{
                        ALAsset *asset = (ALAsset*)[self.assets objectAtIndex:indexPath.row];
                        selectedIndexPath=indexPath;
                        [self showSelectedAssetViewWithAsset:asset];
                }
        }
        [self updateBarItemsStates];
}

#pragma mark - Play Movie

-(void)playAlAsset:(ALAsset *)asset
{
        if (!self.isPlayerPlaying)
        {
                self.isPlayerPlaying = YES;
                NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
                self.player = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self.player
                                                                name:MPMoviePlayerPlaybackDidFinishNotification
                                                              object:self.player.moviePlayer];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(movieFinishedCallback:)
                                                             name:MPMoviePlayerPlaybackDidFinishNotification
                                                           object:self.player.moviePlayer];
                
                self.player.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                self.player.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:self.player animated:YES completion:^{
                        NSLog(@"done present player");
                }];
                [self.player.moviePlayer setFullscreen:NO];
                [self.player.moviePlayer prepareToPlay];
                [self.player.moviePlayer play];
        }
}

- (void)movieFinishedCallback:(NSNotification*)aNotification
{
        if ([aNotification.name isEqualToString: MPMoviePlayerPlaybackDidFinishNotification]) {
                NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
                
                if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
                {
                        MPMoviePlayerController *moviePlayer = [aNotification object];
                        
                        
                        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                                      object:moviePlayer];
                        [self dismissViewControllerAnimated:YES completion:^{  }];
                }
                self.isPlayerPlaying = NO;
        }
}
-(void)onCancelButton{
        if (!selectedAssetView.hidden) {
                [self hideSelectedAssetView];
        }else{
                [self dismissViewControllerAnimated:YES completion:nil];
        }
}
-(void)onShareButton{
        
        NSMutableArray *activitiesArray=[NSMutableArray array];
        NSMutableArray *dataToShare ;
        ALAsset *asset;
        //= 
        SeequDropboxActivity *dropboxActivity=[[SeequDropboxActivity alloc] init];
        if (!selectedAssetView.hidden) {
                dropboxActivity.activityItems = @[[self.assets objectAtIndex:selectedIndexPath.row]];
                dropboxActivity.isfromSeequImagePicker=YES;
                asset = (ALAsset *)[self.assets objectAtIndex:selectedIndexPath.row];
                dataToShare =(NSMutableArray *)@[[UIImage imageWithCGImage:[asset.defaultRepresentation fullResolutionImage]]];
        }else if (!selectedAssetView.hidden && editedImage){
                NSData *data = UIImageJPEGRepresentation(editedImage, 0.8);
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"editedImage"];
                [data writeToFile:filePath atomically:YES];
                GalleryCellInfo *info=[[GalleryCellInfo alloc] init];
                info.actualImage = editedImage;
                info.actualPath = [NSURL fileURLWithPath:filePath];
                dropboxActivity.activityItems = @[info];
                dropboxActivity.isfromSeequImagePicker=NO;
                dataToShare =(NSMutableArray *)@[editedImage];
                
        }else{
                dropboxActivity.activityItems = [self getCheckedAssetsArray];
                dropboxActivity.isfromSeequImagePicker=YES;
                dataToShare = [self getCheckedAssetsThumbnailsArray];
        }
        
        [activitiesArray addObject:dropboxActivity];
        
        UIActivityViewController *activityViewController=[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:activitiesArray];
        activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
        [self presentViewController:activityViewController animated:NO completion:^{
                
        }];
        

}
-(void)onSendButton{
        if (self.pickerType==kPickerTypeMovie) {
                NSString *filePath;
                ALAsset *asset=(ALAsset*)[[self getCheckedAssetsArray] objectAtIndex:0];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                filePath=[documentsDirectory stringByAppendingPathComponent:FORWARD_VIDEO];
                Byte *buffer = (Byte*)malloc([asset defaultRepresentation].size);
                NSUInteger buffered = [[asset defaultRepresentation] getBytes:buffer fromOffset:0.0 length:[asset defaultRepresentation].size error:nil];
                NSData *assetData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                [assetData writeToFile:filePath atomically:YES];
                if( [self getALAssetDuration:asset] > VIDEO_DURATION){
                        [self openVideoEditorWithVideoPath:filePath];
                        
                  }else{
                          [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Compress..."];
                          NSString *tempFilePath = [documentsDirectory stringByAppendingPathComponent:TEMP_FORWARD_VIDEO];
                          __weak SeequAssetsViewController *weakSelf=self;
                        [SeequVideoRecorerViewController convertVideoToLowQuailtyWithInputURL:[NSURL fileURLWithPath:filePath] outputURL:[NSURL fileURLWithPath:tempFilePath] handler:^(AVAssetExportSession *exportSession) {
                                if (exportSession.status==AVAssetExportSessionStatusCompleted) {
                                        forwardVideoPhate=tempFilePath;
                                        
                                        NSError *error;
                                        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                                        if (error) {
                                                NSLog(@"SeequAssetsViewController error removeItemAtPath -%@",[error description]);
                                        }
                                        
                                       [weakSelf performSelectorOnMainThread:@selector(goToSeequNewMessageContactsViewController) withObject:nil waitUntilDone:NO];
                                }
                                [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(HideLoadingView) withObject:nil waitUntilDone:NO];
                        }];
                        
                }
                
        }else{
                [self goToSeequNewMessageContactsViewController];
        }
        
}

-(void)onSelect{
        if (!selectedAssetView.hidden){
                [self launchPhotoEditor];

        }else{
                if (!selectionOn) {
                        self.navigationItem.rightBarButtonItem.title=@"Deselect";
                        selectionOn=YES;
                }else{
                        self.navigationItem.rightBarButtonItem.title=@"Select";
                        selectionOn=NO;
                        [self deselectCheckedAssetsArray];
                }
        }
        [self updateBarItemsStates];
}
-(void)onLeftBarButton{
        if (!selectedAssetView.hidden) {
                [self hideSelectedAssetView];
                selectedIndexPath = nil;
                editedImage = nil;
        }else{
                [self.navigationController popViewControllerAnimated:YES];
        }
}
-(void)goToSeequNewMessageContactsViewController{
        SeequNewMessageContactsViewController *viewController = [[SeequNewMessageContactsViewController alloc] initWithNibName:@"SeequNewMessageContactsViewController" bundle:nil];
        viewController.seequContactsDelegate = self;
        viewController.isFromForwardCalled = YES;
        [self.navigationController pushViewController:viewController animated:YES];

}
-(void)openVideoEditorWithVideoPath:(NSString*)videoPhat{
        
        [self.videoEditor setVideoMaximumDuration:VIDEO_DURATION];
        [self.videoEditor setVideoPath:videoPhat];
        [self.videoEditor setDelegate:self];
        [self presentViewController:self.videoEditor animated:YES completion:nil];
}
-(int)getALAssetDuration:(ALAsset*)asset{
        AVURLAsset *avUrl = [AVURLAsset assetWithURL:[asset.defaultRepresentation url]];
        CMTime time = [avUrl duration];
        int seconds = ceil(time.value/time.timescale);
        return seconds;
}

-(void)showSelectedAssetViewWithAsset:(ALAsset*)asset{
        
        UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:selectedIndexPath];
        CGRect cellRect = attributes.frame;
        CGRect cellFrameInSuperview = [self.collectionView convertRect:cellRect toView:[self.collectionView superview]];
        
        [selectedAssetView setImage:[UIImage imageWithCGImage:[asset.defaultRepresentation fullScreenImage]]];
        selectedAssetView.frame = CGRectMake(cellFrameInSuperview.origin.x+cellFrameInSuperview.size.width/2,cellFrameInSuperview.origin.y+cellFrameInSuperview.size.height/2, 0, 0);
        selectedAssetView.alpha=0.7;
        selectedAssetView.hidden=NO;
        [UIView animateWithDuration:0.3 animations:^{
                selectedAssetView.frame = CGRectMake(self.collectionView.frame.origin.x,  self.collectionView.frame.origin.y,self.collectionView.frame.size.width , self.collectionView.frame.size.height);
                selectedAssetView.alpha = 1;
                self.collectionView.hidden=YES;
        } completion:nil];
        
}
-(void)hideSelectedAssetView{
        
        UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:selectedIndexPath];
        CGRect cellRect = attributes.frame;
        CGRect cellFrameInSuperview = [self.collectionView convertRect:cellRect toView:[self.collectionView superview]];
        [UIView animateWithDuration:0.3 animations:^{
                selectedAssetView.frame = CGRectMake(cellFrameInSuperview.origin.x+cellFrameInSuperview.size.width/2,cellFrameInSuperview.origin.y+cellFrameInSuperview.size.height/2, 0, 0);
        } completion:^(BOOL finished) {
                selectedAssetView.hidden=YES;
                [self updateBarItemsStates];
        }];
        self.collectionView.hidden=NO;
        selectedIndexPath = nil;
        editedImage = nil;
}
#pragma mark -NewMessageContactsDelegate
-(void)didSelectContact:(SeequNewMessageContactsViewController *)controller Contact:(ContactObject *)contactObject{
        [idoubs2AppDelegate sharedInstance].messageFromActivity = YES;
        if (self.pickerType==kPickerTypePhoto) {
                if(!selectedAssetView.hidden && editedImage){
                        [idoubs2AppDelegate sharedInstance].messageFromActivityImage=editedImage;
                }else if (!selectedAssetView.hidden){
                        ALAsset *asset = (ALAsset *)[self.assets objectAtIndex:selectedIndexPath.row];
                        [idoubs2AppDelegate sharedInstance].messageFromActivityImage=[UIImage imageWithCGImage:[asset.defaultRepresentation fullResolutionImage]];
                }else{
                        [idoubs2AppDelegate sharedInstance].messageFromActivityImage =[[self getCheckedAssetsThumbnailsArray] objectAtIndex:0];
                }
        }else{
                if (forwardVideoPhate) {
                        [idoubs2AppDelegate sharedInstance].messageFromActivityVideoPath=forwardVideoPhate;
                }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
                [idoubs2AppDelegate sharedInstance].messageFromActivityTo = contactObject.SeequID;
                [idoubs2AppDelegate sharedInstance].messageNavigationTitle = contactObject.displayName;
                [[idoubs2AppDelegate sharedInstance].messages popToRootViewControllerAnimated:NO];
                [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 1;
        });
        [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISS_CAMERA" object:nil];
        }];

        
        

}

- (void)didReceiveMemoryWarning
{
        [super didReceiveMemoryWarning];
}
#pragma UIVideo Editor Controller Delegate

-(void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error{
        forwardVideoPhate=nil;
}
-(void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath{
        [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(ShowLoadingViewWithMessage:) withObject:@"Compress..." waitUntilDone:NO];
        __weak  SeequAssetsViewController *weakSelf=self;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *tempFilePath = [documentsDirectory stringByAppendingPathComponent:TEMP_FORWARD_VIDEO];
        [SeequVideoRecorerViewController convertVideoToLowQuailtyWithInputURL:[NSURL fileURLWithPath:editedVideoPath] outputURL:[NSURL fileURLWithPath:tempFilePath] handler:^(AVAssetExportSession *exportSession) {
                if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                        forwardVideoPhate = tempFilePath;
                        NSError *error;
                        [[NSFileManager defaultManager] removeItemAtPath:editedVideoPath error:&error];
                        [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingString:FORWARD_VIDEO] error:&error];
                        if (error) {
                                NSLog(@"SeequAssetsViewController error remove item -%@",[error description]);
                        }
                        [weakSelf performSelectorOnMainThread:@selector(dismissVideoEditor) withObject:nil waitUntilDone:NO];
                        [weakSelf performSelectorOnMainThread:@selector(goToSeequNewMessageContactsViewController) withObject:nil waitUntilDone:NO];
                }
                [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(HideLoadingView) withObject:nil waitUntilDone:NO];
                
        }];

}
-(void)dismissVideoEditor{
        [self.videoEditor dismissViewControllerAnimated:NO completion:nil];
}
#pragma Photo Ediror
-(void)launchPhotoEditor{
        ALAsset *asset=(ALAsset*)[self.assets objectAtIndex:selectedIndexPath.row];
        [AFPhotoEditorController setPremiumAddOns:(AFPhotoEditorPremiumAddOnHiRes | AFPhotoEditorPremiumAddOnWhiteLabel)];
        AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:[UIImage imageWithCGImage:[asset.defaultRepresentation fullResolutionImage]]];
        [photoEditor setDelegate:self];
        [self setPhotoEditorCustomizationOptions];
       
        
        [self presentViewController:photoEditor animated:YES completion:nil];
}
-(void)setPhotoEditorCustomizationOptions{
        NSArray * toolOrder = @[kAFCrop,kAFEffects, kAFFocus, kAFFrames, kAFStickers, kAFEnhance, kAFOrientation,  kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme, kAFSharpness];
        [AFPhotoEditorCustomization setToolOrder:toolOrder];
        
        [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
        [AFPhotoEditorCustomization setCropToolCustomEnabled:NO];
        [AFPhotoEditorCustomization setCropToolInvertEnabled:NO];
        
        NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
        [AFPhotoEditorCustomization setCropToolPresets:@[ square]];
}
#pragma Photo Editor Delegate Methods
-(void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image{
        [selectedAssetView setImage:image];
        editedImage=image;
        [editor dismissViewControllerAnimated:YES completion:nil];
}
-(void)photoEditorCanceled:(AFPhotoEditorController *)editor{
        [editor dismissViewControllerAnimated:YES completion:nil];
}
@end
