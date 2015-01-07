//
//  SeequBookmarkFoldersViewController.m
//  ProTime
//
//  Created by Norayr on 04/29/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import "SeequBookmarkFoldersViewController.h"
#import "NavigationBar.h"
#import "BackBarButton.h"


@interface SeequBookmarkFoldersViewController ()

@end

@implementation SeequBookmarkFoldersViewController

@synthesize beginFolderPath;
@synthesize selectedFolderPath;
@synthesize bookmarkFoldersDelegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    
    if (IS_IOS_7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];

    arrayOfFolders = [[NSMutableArray alloc] init];
    [arrayOfFolders addObject:@"Bookmarks"];

//    NSFileManager *fM = [NSFileManager defaultManager];
//    NSArray *fileList = [fM subpathsOfDirectoryAtPath:self.beginFolderPath  error:nil];
//    for (NSString *file in fileList) {
//        NSString *path = [self.beginFolderPath stringByAppendingPathComponent:file];
//        BOOL isDir = NO;
//        [fM fileExistsAtPath:path isDirectory:(&isDir)];
//        if(isDir) {
//            [arrayOfFolders addObject:path];
//        }
//    }
    
    [self CreateArroyOfFolderList];

    self.navigationItem.title = [[NSFileManager defaultManager] displayNameAtPath:self.beginFolderPath];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    ((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(onButtonBack:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
}

- (void) onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return arrayOfFolders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        NSString *folder = [arrayOfFolders objectAtIndex:indexPath.row];
        NSArray *arrayOfSubs = [folder componentsSeparatedByString:@"/"];
        
        if (arrayOfSubs.count == 0) {
            cell.textLabel.text = [arrayOfSubs lastObject];
        } else {
            NSString *pad = [[NSString string] stringByPaddingToLength:arrayOfSubs.count*3 withString:@" " startingAtIndex:0];
            NSString *folderNameByTree = [arrayOfSubs lastObject];
            folderNameByTree = [pad stringByAppendingString:folderNameByTree];

            cell.textLabel.text = folderNameByTree;
        }
        
        NSMutableArray *marrayOfSubs = [[NSMutableArray alloc] initWithArray:arrayOfSubs];
        [marrayOfSubs removeObjectAtIndex:0];
        
        NSString *bookMarkFolder = [marrayOfSubs componentsJoinedByString:@"/"];
        NSString *path = [self.beginFolderPath stringByAppendingPathComponent:bookMarkFolder];
        
        if ([self.selectedFolderPath isEqualToString:path]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(BookmarkFoldersViewController:didSelectPath:)]) {
        NSString *folder = [arrayOfFolders objectAtIndex:indexPath.row];
        NSArray *arrayOfSubs = [folder componentsSeparatedByString:@"/"];
        
        NSMutableArray *marrayOfSubs = [[NSMutableArray alloc] initWithArray:arrayOfSubs];
        [marrayOfSubs removeObjectAtIndex:0];
        
        NSString *bookMarkFolder = [marrayOfSubs componentsJoinedByString:@"/"];
        NSString *path = [self.beginFolderPath stringByAppendingPathComponent:bookMarkFolder];
        
        [_delegate BookmarkFoldersViewController:self didSelectPath:path];
    }
    
    [self onButtonBack:self.navigationItem.leftBarButtonItem];
}

- (void) CreateArroyOfFolderList {
    if (!arrayOfFolders) {
        arrayOfFolders = [[NSMutableArray alloc] init];
    } else {
        [arrayOfFolders removeAllObjects];
    }
    
    [arrayOfFolders addObject:@"Bookmarks"];
    
    NSFileManager *fM = [NSFileManager defaultManager];
    NSArray *folderList = [fM subpathsOfDirectoryAtPath:self.beginFolderPath  error:nil];
    for (NSString *folder in folderList) {
        NSString *path_ = [self.beginFolderPath stringByAppendingPathComponent:folder];
        BOOL isDir = NO;
        [fM fileExistsAtPath:path_ isDirectory:(&isDir)];
        if(isDir) {
            [arrayOfFolders addObject:[@"Bookmarks/" stringByAppendingString:folder]];
        }
    }
}

@end