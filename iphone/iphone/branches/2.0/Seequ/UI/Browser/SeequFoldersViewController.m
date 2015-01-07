//
//  SeequFoldersViewController.m
//  ProTime
//
//  Created by Norayr on 04/30/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import "SeequFoldersViewController.h"
#import "SeequEditFolderViewController.h"
#import "SeequAddBookmarkViewController.h"
#import "idoubs2AppDelegate.h"
#import "NavigationBar.h"


@interface SeequFoldersViewController ()

@end

@implementation SeequFoldersViewController


@synthesize seequFoldersDelegate = _delegate;
@synthesize beginFolderPath;


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(IS_IOS_7){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    self.buttonNewFolder.hidden = YES;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = [[NSFileManager defaultManager] displayNameAtPath:self.beginFolderPath];
    
    actionBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"seequButtonDone.png"]
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(onButtonDone:)];
    
    self.navigationItem.rightBarButtonItem = actionBarButton;
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

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
    
    [self CreateArroyOfFolderList];
    [self.tableView reloadData];
}

- (void) onButtonDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onButtonEdit:(id)sender {
    if (self.tableView.editing) {
        self.navigationItem.rightBarButtonItem = actionBarButton;
        [self.buttonEdit setBackgroundImage:[UIImage imageNamed:@"seequButtonEdit.png"] forState:UIControlStateNormal];
        self.buttonNewFolder.hidden = YES;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        [self.buttonEdit setBackgroundImage:[UIImage imageNamed:@"seequButtonDone.png"] forState:UIControlStateNormal];
        self.buttonNewFolder.hidden = NO;
    }
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

- (IBAction)onButtonNewFolder:(id)sender {
    SeequEditFolderViewController *editFolderViewController = [[SeequEditFolderViewController alloc] initWithNibName:@"SeequEditFolderViewController" bundle:nil];
    editFolderViewController.beginFolderPath = self.beginFolderPath;
    editFolderViewController.selectedPath = self.beginFolderPath;
    [self.navigationController pushViewController:editFolderViewController animated:YES];
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
    return arrayOfFolder.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = nil;
    
    if ([[arrayOfFolder objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        cell.textLabel.text = [arrayOfFolder objectAtIndex:indexPath.row];
    } else {
        if ([[arrayOfFolder objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = [[arrayOfFolder objectAtIndex:indexPath.row] objectForKey:@"title"];
            cell.imageView.image = [UIImage imageNamed:@"bookmark.png"];
        }
    }
    
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

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[arrayOfFolder objectAtIndex:(indexPath.row)] isKindOfClass:[NSString class]]) {
            NSString *folder = [arrayOfFolder objectAtIndex:(indexPath.row)];
            NSString *folderPath = [self.beginFolderPath stringByAppendingPathComponent:folder];
            if ([[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil]) {
                [arrayOfFolder removeObjectAtIndex:(indexPath.row)];
                // Delete the row from the data source
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            }
        } else {
            if ([[arrayOfFolder objectAtIndex:(indexPath.row)] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dictBookMark = [arrayOfFolder objectAtIndex:(indexPath.row)];
                [arrayOfBookMarks removeObject:dictBookMark];
                [arrayOfFolder removeObject:dictBookMark];
                [arrayOfBookMarks writeToFile:bookMarksPath atomically:YES];
                // Delete the row from the data source
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            }
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

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
    if (tableView.editing) {
        if ([[arrayOfFolder objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
            SeequEditFolderViewController *editFolderViewController = [[SeequEditFolderViewController alloc] initWithNibName:@"SeequEditFolderViewController" bundle:nil];
            editFolderViewController.beginFolderPath = self.beginFolderPath;
            editFolderViewController.selectedPath = self.beginFolderPath;
            editFolderViewController.folderName = [arrayOfFolder objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:editFolderViewController animated:YES];
        } else {
            if ([[arrayOfFolder objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = [arrayOfFolder objectAtIndex:indexPath.row];
                SeequAddBookmarkViewController *addBookmarkViewController = [[idoubs2AppDelegate sharedInstance].seequAddBookmark.viewControllers objectAtIndex:0];
                addBookmarkViewController.defaultPath = self.beginFolderPath;
                addBookmarkViewController.selectedPath = self.beginFolderPath;
                addBookmarkViewController.indexEditBookMark = [arrayOfBookMarks indexOfObject:dict];
                NSArray *arrayBookMark = [[NSArray alloc] initWithObjects:[dict objectForKey:@"title"], [dict objectForKey:@"url"], nil];
                addBookmarkViewController.arrayEditBookMark = arrayBookMark;
                addBookmarkViewController.navTitle = @"Edit Bookmark";
                [self presentViewController:[idoubs2AppDelegate sharedInstance].seequAddBookmark animated:YES completion:nil];
            }
        }
    } else {
        // Navigation logic may go here. Create and push another view controller.
        if ([[arrayOfFolder objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
            NSString *path = [self.beginFolderPath stringByAppendingPathComponent:[arrayOfFolder objectAtIndex:indexPath.row]];
            SeequFoldersViewController *foldersViewController = [[SeequFoldersViewController alloc] initWithNibName:@"SeequFoldersViewController" bundle:nil];
            foldersViewController.seequFoldersDelegate = self.seequFoldersDelegate;
            foldersViewController.beginFolderPath = path;
             // ...
             // Pass the selected object to the new view controller.
             [self.navigationController pushViewController:foldersViewController animated:YES];
        } else {
            if ([[arrayOfFolder objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]]) {
                if ([_delegate respondsToSelector:@selector(didSelectHistoryItem:withDictionary:)]) {
                    NSDictionary *dict = [arrayOfFolder objectAtIndex:indexPath.row];
                    
                    [_delegate didSelectHistoryItem:self withDictionary:dict];
                }
            }
        }
    }
}

- (void) CreateArroyOfFolderList {
    if (!arrayOfFolder) {
        arrayOfFolder = [[NSMutableArray alloc] init];
    } else {
        [arrayOfFolder removeAllObjects];
    }
    
    NSFileManager *fM = [NSFileManager defaultManager];
    NSArray *folderList = [fM subpathsOfDirectoryAtPath:self.beginFolderPath  error:nil];
    for (NSString *folder in folderList) {
        NSString *path_ = [self.beginFolderPath stringByAppendingPathComponent:folder];
        BOOL isDir = NO;
        [fM fileExistsAtPath:path_ isDirectory:(&isDir)];
        if(isDir) {
            NSArray *arrayOfSubs = [folder componentsSeparatedByString:@"/"];
            
            if (arrayOfSubs.count == 1) {
                [arrayOfFolder addObject:folder];
            }
        } else {
            if ([folder isEqualToString:@"bookmarks.plist"]) {
                bookMarksPath = path_;
                NSArray *array = [[NSArray alloc] initWithContentsOfFile:bookMarksPath];
                arrayOfBookMarks = [[NSMutableArray alloc] initWithArray:array];
                [arrayOfFolder addObjectsFromArray:arrayOfBookMarks];
            }
        }
    }
}

- (void)viewDidUnload {
    [self setButtonNewFolder:nil];
    [self setButtonEdit:nil];
    [super viewDidUnload];
}

@end
