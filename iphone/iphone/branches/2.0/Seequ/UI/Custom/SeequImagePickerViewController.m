//
//  SeequImagePickerViewController.m
//  ProTime
//
//  Created by Grigori Jlavyan on 8/12/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequImagePickerViewController.h"
#import "NavigationBar.h"

@interface SeequImagePickerViewController (){
        UITableView *MyTableView;
}

@end

@implementation SeequImagePickerViewController

@synthesize assetGroups = _assetGroups;
@synthesize library = _library;

- (id)init
{
    self = [super init];
    if (self) {
            MyTableView=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
            [MyTableView setDelegate:self];
            [MyTableView setDataSource:self];
            [self.view addSubview:MyTableView];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
        [super viewDidLoad];
	[self.navigationItem setTitle:@"Loading..."];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissImagePicker)];
	[self.navigationItem setRightBarButtonItem:cancelButton];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.assetGroups = tempArray;
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
        self.library = assetLibrary;
        // Load Albums into assetGroups
        dispatch_async(dispatch_get_main_queue(), ^{
                // Group enumerator Block
                void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
                {
                        if (group == nil) {
                                return;
                        }
                        NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                        NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                        if (self.pickerType == kPickerTypeMovie) {
                                [group setAssetsFilter:[ALAssetsFilter allVideos]];
                        }else{
                                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                        }
                        if ([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"] && nType == ALAssetsGroupSavedPhotos) {
                                [self.assetGroups insertObject:group atIndex:0];
//                                self.assetsGroupIndex=0;
//                                [self prepareSeequAssetsViewController];
                                
                        }
                        else {
                                if (group.numberOfAssets != 0) {
                                        [self.assetGroups addObject:group];
                                }
                        }
                        [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
                };
                // Group Enumerator Failure Block
                void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [alert show];
                        
                        if ([[error localizedDescription] isEqualToString:@"User denied access" ]) {
                                [self performSelector:@selector(dismissImagePicker) withObject:nil afterDelay:2];
                        }
                };
                [self.library enumerateGroupsWithTypes:ALAssetsGroupAll
                                            usingBlock:assetGroupEnumerator
                                          failureBlock:assetGroupEnumberatorFailure];
        });
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

}

- (void)viewWillAppear:(BOOL)animated
{
        [super viewWillAppear:animated];
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController setToolbarHidden:YES];
         [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"seequNavigationDefaultBG.png"] forBarMetrics:UIBarMetricsDefault];
}

- (void)reloadTableView
{
	[MyTableView reloadData];
	[self.navigationItem setTitle:@"Albums"];
}

- (void)dismissImagePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSUInteger)supportedInterfaceOrientations {
        return UIInterfaceOrientationMaskPortrait;
}
-(BOOL)shouldAutorotate{
        return NO;
}


#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return [self.assetGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        ALAssetsGroup *group = (ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row];
        if (self.pickerType == kPickerTypeMovie) {
                [group setAssetsFilter:[ALAssetsFilter allVideos]];
        }else{
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        }
        NSInteger groupCount = [group numberOfAssets];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",[group valueForProperty:ALAssetsGroupPropertyName], groupCount];
        [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row] posterImage]]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.assetsGroupIndex = indexPath.row;
        [self prepareSeequAssetsViewController];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 57;
}

-(void)prepareSeequAssetsViewController{
        SeequAssetsViewController *assetsViewController=[[SeequAssetsViewController alloc] initWithFrame:self.view.frame];
        assetsViewController.pickerType=self.pickerType;
        assetsViewController.assetsGroup = [self.assetGroups objectAtIndex:self.assetsGroupIndex];
        [self.navigationController pushViewController:assetsViewController animated:YES];
}
@end
