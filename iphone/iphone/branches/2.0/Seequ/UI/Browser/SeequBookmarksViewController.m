//
//  SeequBookmarksViewController.m
//  ProTime
//
//  Created by Norayr on 02/20/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import "SeequBookmarksViewController.h"
#import "SeequEditFolderViewController.h"
#import "SeequAddBookmarkViewController.h"
#import "SeequFoldersViewController.h"
#import "idoubs2AppDelegate.h"
#import "NavigationBar.h"

@interface SeequBookmarksViewController ()

@end

@implementation SeequBookmarksViewController


@synthesize seequBookmarksDelegate = _delegate;


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

    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    self.buttonNewFolder.hidden = YES;
    self.navigationItem.title = @"Bookmarks";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"seequNavigationDefaultBG.png"] forBarMetrics:UIBarMetricsDefault];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onButtonDone:)];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];

    if (!self.tableView.editing) {
        actionBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"seequButtonDone.png"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(onButtonDone:)];
        
        self.navigationItem.rightBarButtonItem = actionBarButton;
    }
    
    [self CreateArroyOfFolderList];
    [self.tableView reloadData];
}

- (void) onButtonDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onButtonEdit:(id)sender {
    [self ChangeButtonStateByEdit:self.tableView.editing ShowNewFolder:YES];
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

- (IBAction)onButtonNewFolder:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    SeequEditFolderViewController *editFolderViewController = [[SeequEditFolderViewController alloc] initWithNibName:@"SeequEditFolderViewController" bundle:nil];
    editFolderViewController.beginFolderPath = [documentsDirectory stringByAppendingPathComponent:@"Bookmarks"];
    editFolderViewController.selectedPath = [documentsDirectory stringByAppendingPathComponent:@"Bookmarks"];
    [self.navigationController pushViewController:editFolderViewController animated:YES];
}

- (void) ChangeButtonStateByEdit:(BOOL)edit ShowNewFolder:(BOOL)show {
    if (edit) {
        self.navigationItem.rightBarButtonItem = actionBarButton;
        [self.buttonEdit setBackgroundImage:[UIImage imageNamed:@"seequButtonEdit.png"] forState:UIControlStateNormal];
        self.buttonNewFolder.hidden = YES;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        [self.buttonEdit setBackgroundImage:[UIImage imageNamed:@"seequButtonDone.png"] forState:UIControlStateNormal];
        if (show)
            self.buttonNewFolder.hidden = NO;
    }
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
    return arrayOfFolder.count+1;
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
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"History";
    } else {
        if ([[arrayOfFolder objectAtIndex:(indexPath.row - 1)] isKindOfClass:[NSString class]]) {
            cell.textLabel.text = [arrayOfFolder objectAtIndex:(indexPath.row - 1)];
        } else {
            if ([[arrayOfFolder objectAtIndex:(indexPath.row - 1)] isKindOfClass:[NSDictionary class]]) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.text = [[arrayOfFolder objectAtIndex:(indexPath.row - 1)] objectForKey:@"title"];
                cell.imageView.image = [UIImage imageNamed:@"bookmark.png"];                
            }
        }
    }
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return NO;
    
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[arrayOfFolder objectAtIndex:(indexPath.row - 1)] isKindOfClass:[NSString class]]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *bookMarkPath = [documentsDirectory stringByAppendingPathComponent:@"Bookmarks"];

            NSString *folder = [arrayOfFolder objectAtIndex:(indexPath.row - 1)];
            NSString *folderPath = [bookMarkPath stringByAppendingPathComponent:folder];
            if ([[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil]) {
                [arrayOfFolder removeObjectAtIndex:(indexPath.row - 1)];
            }
            // Delete the row from the data source
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        } else {
            if ([[arrayOfFolder objectAtIndex:(indexPath.row - 1)] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dictBookMark = [arrayOfFolder objectAtIndex:(indexPath.row - 1)];
                [arrayOfFolder removeObjectAtIndex:(indexPath.row - 1)];

                for (int i = 0; i < arrayOfBookMarks.count; i++) {
                    NSDictionary *dict = [arrayOfBookMarks objectAtIndex:i];
                    if ([[dict objectForKey:@"title"] isEqualToString:[dictBookMark objectForKey:@"title"]] &&
                        [[dict objectForKey:@"url"] isEqualToString:[dictBookMark objectForKey:@"url"]]) {
                        [arrayOfBookMarks removeObjectAtIndex:i];
                        [arrayOfBookMarks writeToFile:bookMarksPath atomically:YES];
                        
                        break;
                    }
                }
                
                
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

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self ChangeButtonStateByEdit:NO ShowNewFolder:NO];
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self ChangeButtonStateByEdit:YES ShowNewFolder:NO];
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
    if (indexPath.row == 0) {
        // Navigation logic may go here. Create and push another view controller.
        SeequBrowserHistoryViewController *detailViewController = [[SeequBrowserHistoryViewController alloc] initWithNibName:@"SeequBrowserHistoryViewController" bundle:nil];
        detailViewController.seequBrowserHistoryDelegate = (id)self.seequBookmarksDelegate;
        // ...
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else {
        if (tableView.editing) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *bookMarkPath = [documentsDirectory stringByAppendingPathComponent:@"Bookmarks"];
            
            if ([[arrayOfFolder objectAtIndex:indexPath.row - 1] isKindOfClass:[NSString class]]) {
                SeequEditFolderViewController *editFolderViewController = [[SeequEditFolderViewController alloc] initWithNibName:@"SeequEditFolderViewController" bundle:nil];
                editFolderViewController.beginFolderPath = bookMarkPath;
                editFolderViewController.selectedPath = bookMarkPath;
                editFolderViewController.folderName = [arrayOfFolder objectAtIndex:indexPath.row - 1];
                [self.navigationController pushViewController:editFolderViewController animated:YES];
            } else {
                if ([[arrayOfFolder objectAtIndex:indexPath.row - 1] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dict = [arrayOfFolder objectAtIndex:indexPath.row - 1];
                    SeequAddBookmarkViewController *addBookmarkViewController = [[idoubs2AppDelegate sharedInstance].seequAddBookmark.viewControllers objectAtIndex:0];
                    addBookmarkViewController.defaultPath = bookMarkPath;
                    addBookmarkViewController.selectedPath = bookMarkPath;
                    addBookmarkViewController.indexEditBookMark = [arrayOfBookMarks indexOfObject:dict];
                    NSArray *arrayBookMark = [[NSArray alloc] initWithObjects:[dict objectForKey:@"title"], [dict objectForKey:@"url"], nil];
                    addBookmarkViewController.arrayEditBookMark = arrayBookMark;
                    addBookmarkViewController.navTitle = @"Edit Bookmark";
                    [self presentViewController:[idoubs2AppDelegate sharedInstance].seequAddBookmark animated:YES completion:nil];
                }
            }
        } else {
            if ([[arrayOfFolder objectAtIndex:(indexPath.row - 1)] isKindOfClass:[NSString class]]) {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *bookMarkPath = [documentsDirectory stringByAppendingPathComponent:@"Bookmarks"];
                NSString *folder = [arrayOfFolder objectAtIndex:(indexPath.row - 1)];
                NSString *path = [bookMarkPath stringByAppendingPathComponent:folder];
                
                SeequFoldersViewController *foldersViewController = [[SeequFoldersViewController alloc] initWithNibName:@"SeequFoldersViewController" bundle:nil];
                foldersViewController.seequFoldersDelegate = (id)self.seequBookmarksDelegate;
                foldersViewController.beginFolderPath = path;
                [self.navigationController pushViewController:foldersViewController animated:YES];
            } else {
                if ([[arrayOfFolder objectAtIndex:(indexPath.row - 1)] isKindOfClass:[NSDictionary class]]) {
                    if ([_delegate respondsToSelector:@selector(didSelectHistoryItem:withDictionary:)]) {
                        NSDictionary *dict = [arrayOfFolder objectAtIndex:(indexPath.row - 1)];
                        
                        [_delegate didSelectHistoryItem:self withDictionary:dict];
                    }
                }
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) CreateArroyOfFolderList {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bookMarkPath = [documentsDirectory stringByAppendingPathComponent:@"Bookmarks"];
    
    if (!arrayOfFolder) {
        arrayOfFolder = [[NSMutableArray alloc] init];
    } else {
        [arrayOfFolder removeAllObjects];
    }
    
    NSFileManager *fM = [NSFileManager defaultManager];
    NSArray *folderList = [fM subpathsOfDirectoryAtPath:bookMarkPath  error:nil];
    for (NSString *folder in folderList) {
        NSString *path_ = [bookMarkPath stringByAppendingPathComponent:folder];
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
    [self setTableView:nil];
    [self setButtonNewFolder:nil];
    [self setButtonEdit:nil];
    [super viewDidUnload];
}

@end