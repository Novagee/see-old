//
//  SeequDropboxViewControllerViewController.m
//  ProTime
//
//  Created by Grigori Jlavyan on 7/28/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequDropboxViewController.h"
#import "SeequDropboxTreeItem.h"
#import "SeequDropboxTreeTableViewCell.h"
#import "NavigationBar.h"
#import "idoubs2AppDelegate.h"
#import "common.h"
#import "GalleryCellInfo.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import <DropboxSDK/DropboxSDK.h>


@implementation UINavigationController (Rotation_IOS6)

-(BOOL)shouldAutorotate
{
        return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
        return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
        return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end

@interface SeequDropboxViewController ()<DBRestClientDelegate,UITableViewDelegate,UITableViewDataSource,SeequViewForDragDelegate>{
        DBAccountInfo *accountInfo;
        SeequViewForDragToDropbox *dragView;
        SeequDropboxTreeItem *rootItem;
        CGPoint nowPoints;
        SeequDropboxTreeTableViewCell *selectidCell;
        NSString *selectidPath;
        BOOL isSelectorRun;
        BOOL dropboxConnectionRetrie;
        UIView *infoView;
        UITextView *accountInfoText;
        UIButton *unLinkButton;
        
}

@property (nonatomic) BOOL isLoading;
@property (nonatomic, retain) NSMutableArray *itemsArray;
@property (nonatomic, retain) DBRestClient *dropboxClient;
@property (nonatomic, retain) UITableView *MyTableView;
@property (nonatomic) NSUInteger dropboxConnectionRetryCount;
@property (nonatomic,retain) NSTimer *selectionTimer;
@property (nonatomic,retain) NSTimer *scrollTimer;

- (void)handleApplicationBecameActive:(NSNotification *)notification;
- (void)handleCancel;

@end

@implementation SeequDropboxViewController

-(id)init{
        self=[super init];
        if (self) {
                accountInfo=nil;
                _isLoading = YES;
                nowPoints=CGPointZero;
                self.dropboxConnectionRetryCount = 0;
                self.MyTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStylePlain];
                [self.MyTableView setDelegate:self];
                [self.MyTableView setDataSource:self];
                [self.view addSubview:self.MyTableView];
                dragView=[[SeequViewForDragToDropbox alloc] initWithFrame:CGRectMake(self.view.frame.size.width-DRAGGING_VIEW_WIDTH, self.view.frame.size.height-144, DRAGGING_VIEW_WIDTH, DRAGGING_VIEW_HEIGHT)];
                [dragView setDelegate:self];
                [self.view addSubview:dragView];
                infoView=[[UIView alloc] initWithFrame:CGRectMake(0,0,250,100)];
                UIImage *unLinkImage=[UIImage imageNamed:@"ChangeAccountButton"];
                
                infoView.center=self.view.center;
                infoView.backgroundColor=[UIColor colorWithWhite:0.9 alpha:0.5];
                accountInfoText=[[UITextView alloc] initWithFrame:CGRectMake(0, 0, infoView.frame.size.width
                                                                             , infoView.frame.size.height-unLinkImage.size.height)] ;
                [accountInfoText setBackgroundColor:[UIColor clearColor]];
                [accountInfoText setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
                accountInfoText.textAlignment=NSTextAlignmentCenter;
                accountInfoText.editable=NO;
                
                unLinkButton=[[UIButton alloc] initWithFrame:CGRectMake((infoView.frame.size.width-unLinkImage.size.width)/2,(infoView.frame.size.height-unLinkImage.size.height)-5, unLinkImage.size.width, unLinkImage.size.height)];
                [unLinkButton addTarget:self action:@selector(unlinkAll) forControlEvents:UIControlEventTouchUpInside];
                
                [unLinkButton setImage:unLinkImage forState:UIControlStateNormal];
                [infoView addSubview:accountInfoText];
                [infoView addSubview:unLinkButton];
                infoView.hidden=YES;
                infoView.layer.borderWidth=0.5;
                [self.view addSubview:infoView];
                
                
        }
        return self;
}

- (void)viewDidLoad
{
        [super viewDidLoad];
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.view.clipsToBounds=YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                               target:self
                                                                                               action:@selector(handleCancel)];
        
        
//        self.navigationController.navigationBar.tintColor=[UIColor darkGrayColor];
        self.navigationController.navigationBar.backgroundColor=[UIColor lightGrayColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleApplicationBecameActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getMetadata:)
                                                     name:@"LoadMetadata"
                                                   object:nil];
        isSelectorRun=NO;
        selectidPath=nil;
        rootItem=nil;
        dropboxConnectionRetrie=NO;
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    
        
}

- (void)viewDidUnload
{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadMetadata" object:nil];
        
        [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
        [super viewWillAppear:animated];
        if (self.rootPath == nil)
                self.rootPath = @"/";
        
        if ([self.rootPath isEqualToString:@"/"]) {
                self.title = @"Dropbox";
        } else {
                self.title = [self.rootPath lastPathComponent];
        }
        self.isLoading = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        dragView=[[SeequViewForDragToDropbox alloc] initWithFrame:CGRectMake(self.view.frame.size.width-DRAGGING_VIEW_WIDTH, self.view.frame.size.height-144, DRAGGING_VIEW_WIDTH, DRAGGING_VIEW_HEIGHT)];
        if (self.isfromSeequImagePicker) {
                 ALAsset *asset=(ALAsset*)[self.activityArray objectAtIndex:0];
                [dragView setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
        }else{
                GalleryCellInfo *info=[self.activityArray objectAtIndex:0];
                [dragView setImage:info.actualImage];
        }
      [dragView setDelegate:self];
      [self.view addSubview:dragView];
}
-(void)viewWillLayoutSubviews{
        [super viewWillLayoutSubviews];
}

- (BOOL) hasValidData {
        BOOL valid = rootItem != nil && self.isLoading == NO;
        return valid;
}

- (void)viewDidAppear:(BOOL)animated
{
        [super viewDidAppear:animated];
        
        if (![[DBSession sharedSession] isLinked]) {
                if (!dropboxConnectionRetrie) {
                        [self showLoginDialogOrCancel];
                }else{
                        [self handleCancel];
                }
                
        } else {
                [self.dropboxClient loadMetadata:self.rootPath];
                [self.dropboxClient loadAccountInfo];
        }
}
-(void)addLeftBarButton{
        UIImage *infoImage=[UIImage imageNamed:@"information_button"];
        UIButton *infoButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, infoImage.size.width, infoImage.size.height)];
        [infoButton setBackgroundImage:infoImage forState:UIControlStateNormal];
        [infoButton addTarget:self action:@selector(onInfoButton) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftBarButton=[[UIBarButtonItem alloc] initWithCustomView:infoButton];
        self.navigationItem.leftBarButtonItem=leftBarButton;
        
}


- (NSUInteger)supportedInterfaceOrientations {
        return UIInterfaceOrientationMaskPortrait;
}
-(BOOL)shouldAutorotate{
        return NO;
}
- (void) showLoginDialogOrCancel {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [[DBSession sharedSession] linkFromController:self];
        dropboxConnectionRetrie=YES;
        
}

- (void)didReceiveMemoryWarning
{
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (DBRestClient *)dropboxClient
{
        if (_dropboxClient == nil && [DBSession sharedSession] != nil) {
                _dropboxClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
                _dropboxClient.delegate = self;
        }
        return _dropboxClient;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        if (![self hasValidData] || self.itemsArray.count < 1) return 0;
        
        return [self.itemsArray count];
        
}
-(void)getMetadata:(NSNotification *)notification{
        [self.dropboxClient loadMetadata:notification.object];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *CellIdentifier = @"TreeTableViewCell";
        SeequDropboxTreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
                cell = [[SeequDropboxTreeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.treeItem=[self.itemsArray objectAtIndex:indexPath.row];
        [cell.titleTextField setText:cell.treeItem.base];
        [cell setLevel:cell.treeItem.submersionLevel];
        if (cell.treeItem.ancestorSelectingItems.count) {
                [cell.countLabel setText:[NSString stringWithFormat:@"%d",cell.treeItem.ancestorSelectingItems.count]];
        }else{
                [cell.countLabel setText:@"-"];
        }
        
        
        return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        if ([self.itemsArray  count] > indexPath.row) {
                SeequDropboxTreeTableViewCell *cell=(SeequDropboxTreeTableViewCell*)[self.MyTableView cellForRowAtIndexPath:indexPath];
                if (cell.treeItem.ancestorSelectingItems.count>0) {
// JSC                        NSMutableArray *removeIndexPaths=[NSMutableArray array];
                        NSMutableArray *insertIndexPaths=[NSMutableArray array];
                        if (cell.treeItem.selected) {
// JSC                              removeIndexPaths = [self getRemoveIndexPaths:cell];
                                cell.treeItem.selected=NO;
                        }else{
                                insertIndexPaths = [self getInsertIndexPaths:cell];
                                cell.treeItem.selected=YES;
                        }
                        if ([insertIndexPaths count])
                                [self.MyTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
                }
                [self.MyTableView reloadData];
        }
}
-(void)tableViewScrollToTop{
        
        NSArray *array=[self.MyTableView indexPathsForVisibleRows];
        if (array.count<self.itemsArray.count ) {
                NSIndexPath *indexPath=[array objectAtIndex:0];
                if (indexPath.row>0) {
                        NSIndexPath *scrollingIndexPath=[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
                        [UIView beginAnimations:@"scrollToTop" context:nil];
                        [UIView setAnimationDuration:0.2];
                        [self.MyTableView scrollToRowAtIndexPath:scrollingIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                        [UIView commitAnimations];
                }
        }

        
}
-(void)tableViewScrollToBottom{
        NSArray *array=[self.MyTableView indexPathsForVisibleRows];
        if (array.count<self.itemsArray.count ) {
                NSIndexPath *indexPath=[array lastObject];
                if (indexPath.row+1<self.itemsArray.count) {
                        NSIndexPath *scrollingIndexPath=[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
                        [UIView beginAnimations:@"scrollToBottom" context:nil];
                        [UIView setAnimationDuration:0.2];
                        [self.MyTableView scrollToRowAtIndexPath:scrollingIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        [UIView commitAnimations];
                }
        }

        
}
#pragma mark - Dropbox client delegate methods

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
        [self addMetadata:(DBMetadata *)metadata];
        self.isLoading = NO;
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{       // Error 401 gets returned if a token is invalid, e.g. if the user has deleted
        // the app from their list of authorized apps at dropbox.com
        if (error.code == 401) {
                [self showLoginDialogOrCancel];
        } else {
                self.isLoading = NO;
        }
}
- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info{
        [self addLeftBarButton];
        accountInfoText.text=[NSString stringWithFormat:@"You are logged in as \n\"%@\"",info.displayName];
}
- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
        NSLog(@"File upload failed with error: %@", error);
}
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
          metadata:(DBMetadata*)metadata{
        [[idoubs2AppDelegate sharedInstance] HideLoadingView];
        [self handleCancel];
}
-(void)onInfoButton{
        [UIView beginAnimations:@"accountInfo" context:nil];
        [UIView setAnimationDuration:0.5];
        infoView.hidden=!infoView.hidden;
        [UIView commitAnimations];
}
- (void)setIsLoading:(BOOL)isLoading
{
        if (_isLoading != isLoading) {
                _isLoading = isLoading;
                [self.MyTableView reloadData];
        }
}
-(NSMutableArray*)getInsertIndexPaths:(SeequDropboxTreeTableViewCell*)treeCell{
        NSInteger insertTreeItemIndex=[self.itemsArray indexOfObject:treeCell.treeItem];
        NSMutableArray *insertIndexPaths = [NSMutableArray array];
        NSIndexPath *indexPath;
        for (SeequDropboxTreeItem *item in treeCell.treeItem.ancestorSelectingItems) {
                if (![self.itemsArray containsObject:item]) {
                        insertTreeItemIndex++;
                        [self.dropboxClient loadMetadata:item.path];
                        [self.itemsArray insertObject:item atIndex:insertTreeItemIndex];
                        indexPath = [NSIndexPath indexPathForRow:insertTreeItemIndex inSection:0];
                        [insertIndexPaths addObject:indexPath];
                }
        }
        return insertIndexPaths;
}
-(NSMutableArray*)getRemoveIndexPaths:(SeequDropboxTreeTableViewCell*)treeCell{
        NSIndexPath *indexPath;
        NSMutableArray *removeIndexPaths = [NSMutableArray array];
        NSMutableArray *treeItemsToRemove = [NSMutableArray array];
        for (SeequDropboxTreeItem *item in treeCell.treeItem.ancestorSelectingItems) {
                if ([self.itemsArray containsObject:item]) {
                        NSInteger *itemIndex=[self.itemsArray indexOfObject:item];
                        indexPath=[NSIndexPath indexPathForRow:itemIndex inSection:0];
                        [removeIndexPaths addObject:indexPath];
                        [treeItemsToRemove addObject:item];
                        [self removeChildIfSelected:item];
                        item.selected=NO;
                }
        }
        if ([treeItemsToRemove count]>0) {
                for (SeequDropboxTreeItem *item in treeItemsToRemove) {
                        [self.itemsArray removeObject:item];
                }
        }
        
        
        return removeIndexPaths;
}
-(void)removeChildIfSelected:(SeequDropboxTreeItem*)treeItem{
        if (treeItem.selected && treeItem.ancestorSelectingItems.count>0) {
                for (SeequDropboxTreeItem *item in treeItem.ancestorSelectingItems) {
                        if ([self.itemsArray containsObject:item]) {
                                item.selected=NO;
                                [self.itemsArray removeObject:item];
                                [self removeChildIfSelected:item];
                        }
                }
        }
}

- (void)handleApplicationBecameActive:(NSNotification *)notification
{
        if ([[DBSession sharedSession] isLinked]) {
                [self.dropboxClient loadMetadata:self.rootPath];
                [self.dropboxClient loadAccountInfo];
                self.isLoading = YES;
                self.navigationItem.rightBarButtonItem.enabled = YES;
        }else{
                [self handleCancel];
        }
}
-(void)unlinkAll{
        if ([[DBSession sharedSession].userIds objectAtIndex:0]) {
                NSLog(@"dropbox userId -%@  %d ",[[DBSession sharedSession].userIds objectAtIndex:0],[DBSession sharedSession].userIds.count);
                [[DBSession sharedSession] unlinkUserId:[[DBSession sharedSession].userIds objectAtIndex:0]];
                self.dropboxClient=nil;
                [[idoubs2AppDelegate sharedInstance] setDropboxClient:nil];
                
        }
        infoView.hidden=YES;
        [self showLoginDialogOrCancel];
}


-(void)selectPath:(NSTimer *)theTimer{
        NSIndexPath *indexPath=(NSIndexPath*)[theTimer userInfo];
        if ([self.MyTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)] && [self.MyTableView cellForRowAtIndexPath:indexPath]!=nil) {
                [self.MyTableView.delegate tableView:self.MyTableView didSelectRowAtIndexPath:indexPath];
        }
}
#pragma SeequViewForDrag delegates
-(void)dragViewDraggedToPoint:(CGPoint)newPoint{
        @synchronized(self){
                BOOL isInRow=NO;
                if (self.MyTableView.indexPathsForVisibleRows.count>0) {
                        for(NSIndexPath *indexPath in self.MyTableView.indexPathsForVisibleRows){
                                CGRect rectInTableView = [self.MyTableView rectForRowAtIndexPath:indexPath];
                                CGRect rectInSuperview = [self.MyTableView convertRect:rectInTableView toView:self.view];
                                if(CGRectContainsPoint(rectInSuperview, newPoint)){
                                        isInRow=YES;
                                        SeequDropboxTreeTableViewCell *newSelectidCell=(SeequDropboxTreeTableViewCell*)[self.MyTableView cellForRowAtIndexPath:indexPath];
                                        if(selectidCell && newSelectidCell!=selectidCell){
                                                [selectidCell setBackgroundColor:[UIColor whiteColor]];
                                                selectidCell=newSelectidCell;
                                                [selectidCell setBackgroundColor:[UIColor lightGrayColor]];
                                                [self.selectionTimer invalidate];
                                                isSelectorRun=NO;
                                        }else if (!selectidCell){
                                                selectidCell=newSelectidCell;
                                                [selectidCell setBackgroundColor:[UIColor lightGrayColor]];
                                        }else if (selectidCell && selectidCell==newSelectidCell && !isSelectorRun) {
                                                isSelectorRun=YES;
                                                [selectidCell setBackgroundColor:[UIColor lightGrayColor]];
                                                if (self.itemsArray.count > 0 && self.itemsArray.count>=indexPath.row ) {
                                                        selectidPath=selectidCell.treeItem.path;
                                                        if (!selectidCell.treeItem.selected)
                                                                self.selectionTimer=[NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(selectPath:) userInfo:indexPath repeats:NO];
                                                }
                                        }
                                }
                        }
                }
                if (selectidCell && !isInRow) {
                        [selectidCell setBackgroundColor:[UIColor whiteColor]];
                        [self.selectionTimer invalidate];
                        selectidCell=nil;
                        isSelectorRun=NO;
                        
                }
        }
        if (!infoView.hidden) {
                infoView.hidden=YES;
        }
}
-(void)dragViewTouchesEnded{
        if (selectidCell) {
                [dragView drageViewDropid];
                [[idoubs2AppDelegate sharedInstance].soundService playDrop];
                [NSThread detachNewThreadSelector:@selector(showLoadingView) toTarget:self withObject:nil];
                selectidCell.backgroundColor=[UIColor whiteColor];
                NSString *fileName;
                NSString *filePath;
                NSError *error;
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"/Temp_For_Dropbox"];
                
                if(![[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory])
                        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
                
                
                if (self.isfromSeequImagePicker) {
                        for (int i = 0 ; i < self.activityArray.count ; i++) {
                                ALAsset *asset =(ALAsset*)[self.activityArray objectAtIndex:i];
                                NSData *assetData;
                                CGImageRef imageRef;
                                Byte *buffer;
                                fileName = [asset.defaultRepresentation filename];
                                
                                if (![[asset valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) {
                                        if([fileName rangeOfString:@"MOV"].location!=NSNotFound){
                                              fileName = [fileName stringByReplacingOccurrencesOfString:@"MOV" withString:@"mp4"];
                                        }
                                           buffer = (Byte*)malloc([asset defaultRepresentation].size);
                                        NSUInteger buffered = [[asset defaultRepresentation] getBytes:buffer fromOffset:0.0 length:[asset defaultRepresentation].size error:nil];
                                        assetData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                                }else{
                                        
                                     imageRef = CGImageCreateCopy([asset.defaultRepresentation fullScreenImage]);
                                      assetData=UIImageJPEGRepresentation([UIImage imageWithCGImage:imageRef],0.8);
                                        @try {
                                                 CGImageRelease(imageRef);
                                        }
                                        @catch (NSException *exception) {
                                                NSLog(@"exception -%@",exception);
                                        }
                                        
                                }
                                filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
                                [assetData writeToFile:filePath atomically:YES];
                                [[[idoubs2AppDelegate sharedInstance] getDropboxClient] uploadFile:fileName toPath:selectidCell.treeItem.path withParentRev:nil fromPath:filePath];
                        }
                        
                }else{
                        GalleryCellInfo *info=[self.activityArray objectAtIndex:0];
                        fileName = [info.actualPath lastPathComponent];
                        fileName = [fileName stringByReplacingOccurrencesOfString:@"msgId" withString:@""];
                        filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
                        NSData *imageData=UIImageJPEGRepresentation(info.actualImage,0.8);
                        [imageData writeToFile:filePath atomically:YES];
                        [[[idoubs2AppDelegate sharedInstance] getDropboxClient] uploadFile:fileName toPath:selectidCell.treeItem.path withParentRev:nil fromPath:filePath];
                }
                
                [[idoubs2AppDelegate sharedInstance] HideLoadingView];
                [self handleCancel];
               
        }
}
-(void)dragViewMovedToBottomBorder{
        if (![self.scrollTimer isValid]) {
                self.scrollTimer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(tableViewScrollToBottom) userInfo:nil repeats:YES];
        }
}
-(void)dragViewMovedToTopBorder{
        if (![self.scrollTimer isValid]) {
                self.scrollTimer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(tableViewScrollToTop) userInfo:nil repeats:YES];
        }
}
-(void)dragViewMovedFromTopOrBottomBorders{
        if ([self.scrollTimer isValid]) {
                [self.scrollTimer invalidate];
        }
}

-(SeequDropboxTreeItem *)getTreeItemInRootItemAtPath:(SeequDropboxTreeItem *)root atPath:(NSString*)path{
        NSMutableArray *pathComponentArray=[[NSMutableArray alloc]initWithArray:[path componentsSeparatedByString:@"/"]];
        if (pathComponentArray && pathComponentArray.count>1) {
                for (SeequDropboxTreeItem *item in root.ancestorSelectingItems) {
                        if ([item.base isEqualToString:[pathComponentArray objectAtIndex:1]]) {
                                [pathComponentArray removeObjectAtIndex:1];
                                if (pathComponentArray.count>1) {
                                        return [self getTreeItemInRootItemAtPath:item atPath:[self pathByComponent:pathComponentArray]];
                                }else{
                                        return item;
                                }
                        }
                }
                
        }
        return nil;
}

-(NSString*)pathByComponent:(NSMutableArray*)componentArray{
        NSString *path=@"/";
        for (NSString * component in componentArray) {
                if (![component isEqualToString:@""]) {
                         path=[path stringByAppendingPathComponent:component];
                }
               
        }
        return path;
        
}
- (void)addMetadata:(DBMetadata *)metadata{
        if ([metadata.path isEqualToString:@"/"]) {
                rootItem=[[SeequDropboxTreeItem alloc] initWithMetadata:metadata andParentItem:nil];
                [rootItem addChild:metadata];
                self.itemsArray=[[NSMutableArray alloc] initWithObjects:rootItem, nil];
                
        }else{
                SeequDropboxTreeItem *item=[self getTreeItemInRootItemAtPath:rootItem atPath:metadata.path];
                [item addChild:metadata];
        }
        [self.MyTableView reloadData];
        
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
        if (!infoView.hidden) {
                infoView.hidden=YES;
        }
}
-(void)showLoadingView{
        [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"uploading..."];
}
- (void)handleCancel

{
        if([self.scrollTimer isValid]) {
        [self.scrollTimer invalidate];
        }
        
        id<SeequDropboxViewControllerDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(dropboxViewControllerDidCancel:)]) {
                [delegate dropboxViewControllerDidCancel:self];
        }
}


@end
