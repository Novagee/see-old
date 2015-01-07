//
//  SeequEditFolderViewController.m
//  ProTime
//
//  Created by Norayr on 04/30/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import "SeequEditFolderViewController.h"
#import "NavigationBar.h"
#import "BackBarButton.h"

@interface SeequEditFolderViewController ()

@end

@implementation SeequEditFolderViewController


@synthesize beginFolderPath;
@synthesize selectedPath;
@synthesize folderName;

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
    if (IS_IOS_7) {
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"Edit Folder";
    
    [self.textFieldFolderName setText:self.folderName];
    
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
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.textFieldFolderName becomeFirstResponder];
}

- (void) onButtonBack:(id)sender {
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bookMarkPath = [documentsDirectory stringByAppendingPathComponent:@"Bookmarks"];
    [[NSFileManager defaultManager] createDirectoryAtPath:bookMarkPath
                              withIntermediateDirectories:NO
                                               attributes:nil
                                                    error:&error];
    
    if ([self.textFieldFolderName.text stringByReplacingOccurrencesOfString:@" " withString:@""].length) {
        if (!self.folderName) {
            NSString *path = [self.selectedPath stringByAppendingPathComponent:self.textFieldFolderName.text];
            
            if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                           withIntermediateDirectories:NO
                                                            attributes:nil
                                                                 error:&error])
            {
                NSLog(@"Create directory error: %@", error);
            }
        } else {
            NSString *oldDirectoryPath = [self.beginFolderPath stringByAppendingPathComponent:self.folderName];
            
            if ([self.selectedPath isEqualToString:self.beginFolderPath]) {
                if (![self.folderName isEqualToString:self.textFieldFolderName.text]) {
                    NSArray *tempArrayForContentsOfDirectory =[[NSFileManager defaultManager] contentsOfDirectoryAtPath:oldDirectoryPath error:nil];
                    
                    NSString *newDirectoryPath = [[oldDirectoryPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:self.textFieldFolderName.text];
                    
                    [[NSFileManager defaultManager] createDirectoryAtPath:newDirectoryPath
                                              withIntermediateDirectories:NO
                                                               attributes:nil
                                                                    error:&error];
                    
                    for (int i = 0; i < [tempArrayForContentsOfDirectory count]; i++)
                    {
                        
                        NSString *newFilePath = [newDirectoryPath stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];
                        
                        NSString *oldFilePath = [oldDirectoryPath stringByAppendingPathComponent:[tempArrayForContentsOfDirectory objectAtIndex:i]];
                        
                        [[NSFileManager defaultManager] moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
                        
                        if (error) {
                            // handle error
                        }
                        
                    }
                    
                    [[NSFileManager defaultManager] removeItemAtPath:oldDirectoryPath error:&error];
                }
            } else {
                NSString *newDirectoryPath = [self.selectedPath stringByAppendingPathComponent:self.textFieldFolderName.text];
                
                if (![[NSFileManager defaultManager] moveItemAtPath:oldDirectoryPath toPath:newDirectoryPath error:&error]) {
                    
                }
            }
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self onButtonBack:nil];
    
    return YES;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    if (indexPath.section == 0) {
        self.textFieldFolderName.frame = CGRectMake(20, 7, 280, 30);
        [cell addSubview:self.textFieldFolderName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.text = [[NSFileManager defaultManager] displayNameAtPath:self.selectedPath];
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
    if (indexPath.section == 1) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *bookMarkPath = [documentsDirectory stringByAppendingPathComponent:@"Bookmarks"];
        
        SeequBookmarkFoldersViewController *bookmarkFoldersViewController = [[SeequBookmarkFoldersViewController alloc] initWithNibName:@"SeequBookmarkFoldersViewController" bundle:nil];
        bookmarkFoldersViewController.beginFolderPath = bookMarkPath;
        bookmarkFoldersViewController.selectedFolderPath = beginFolderPath;
        bookmarkFoldersViewController.bookmarkFoldersDelegate = self;
        // ...
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:bookmarkFoldersViewController animated:YES];
    }
}

- (void)BookmarkFoldersViewController:(SeequBookmarkFoldersViewController*)viewController didSelectPath:(NSString*)path {
    self.selectedPath = path;
}

- (void)viewDidUnload {
    [self setTextFieldFolderName:nil];
    [super viewDidUnload];
}

@end
