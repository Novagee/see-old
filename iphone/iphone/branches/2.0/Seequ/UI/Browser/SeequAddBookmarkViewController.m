//
//  SeequAddBookmarkViewController.m
//  ProTime
//
//  Created by Norayr on 04/29/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import "SeequAddBookmarkViewController.h"
#import "Common.h"
#import "NavigationBar.h"
#import "BackBarButton.h"


@interface SeequAddBookmarkViewController ()

@end

@implementation SeequAddBookmarkViewController


@synthesize addBookmarkDelegate = _delegate;
@synthesize defaultPath;
@synthesize selectedPath;
@synthesize navTitle;
@synthesize arrayEditBookMark;
@synthesize indexEditBookMark;
@synthesize activityItems;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self) {
        // Custom initialization
        self.arrayEditBookMark = nil;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    ((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];

    BackBarButton *barButtonCancel = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequCancelButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(onButtonCancel:)];
    self.navigationItem.leftBarButtonItem = barButtonCancel;

    BackBarButton *barButtonSave = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequSaveButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(onButtonSave:)];
    self.navigationItem.rightBarButtonItem = barButtonSave;
    [self.tableView reloadData];
    
    self.navigationItem.title = self.navTitle;    

    if (self.arrayEditBookMark) {
        self.textFieldURL.enabled = YES;
        [self.textFieldURL setTextColor:[UIColor colorWithRed:107.0/255.0 green:127.0/255.0 blue:155.0/255.0 alpha:1.0]];
        [self.textFieldURL setFont:[UIFont fontWithName:@"Helvetica" size:17]];
    } else {
        self.textFieldURL.enabled = NO;
        [self.textFieldURL setTextColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
        [self.textFieldURL setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.textFieldTitle becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onButtonCancel:(id)sender {
    if (self.arrayEditBookMark) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        if ([_delegate respondsToSelector:@selector(didFinishSeequAddBookmarkViewController:)]) {
            [_delegate didFinishSeequAddBookmarkViewController:self];
        }
    }
}

- (void) onButtonSave:(id)sender {
    if (!self.arrayEditBookMark) {
        if ([_delegate respondsToSelector:@selector(didFinishSeequAddBookmarkViewController:)]) {
            [_delegate didFinishSeequAddBookmarkViewController:self];
        }
    }
    
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bookMarkPath = [documentsDirectory stringByAppendingPathComponent:@"Bookmarks"];
    [[NSFileManager defaultManager] createDirectoryAtPath:bookMarkPath
                              withIntermediateDirectories:NO
                                               attributes:nil
                                                    error:&error];

    NSString *removablePath = [self.defaultPath stringByAppendingPathComponent:@"bookmarks.plist"];
    NSString *fileFullPath = [self.selectedPath stringByAppendingPathComponent:@"bookmarks.plist"];
    
    NSDictionary *dictBookMark = [[NSDictionary alloc] initWithObjectsAndKeys:self.textFieldTitle.text, @"title",
                                  self.textFieldURL.text, @"url", nil];
    
    NSArray *arrayOfBookMarks = [[NSArray alloc] initWithContentsOfFile:fileFullPath];
    NSMutableArray *marrayOfBookMarks;
    
    if (!arrayOfBookMarks) {
        marrayOfBookMarks = [[NSMutableArray alloc] init];
    } else {
        marrayOfBookMarks = [[NSMutableArray alloc] initWithArray:arrayOfBookMarks];
    }
    
    if (self.arrayEditBookMark) {
        if ([self.defaultPath isEqualToString:self.selectedPath]) {
            [marrayOfBookMarks replaceObjectAtIndex:self.indexEditBookMark withObject:dictBookMark];
        } else {
            [marrayOfBookMarks addObject:dictBookMark];
            
            NSArray *arrayOfRootBookMarks = [[NSArray alloc] initWithContentsOfFile:removablePath];
            NSMutableArray *marrayOfRootBookMarks = [[NSMutableArray alloc] initWithArray:arrayOfRootBookMarks];
            [marrayOfRootBookMarks removeObjectAtIndex:self.indexEditBookMark];
            
            [marrayOfRootBookMarks writeToFile:removablePath atomically:YES];
        }
    } else {
        [marrayOfBookMarks addObject:dictBookMark];
    }
    
    [marrayOfBookMarks writeToFile:fileFullPath atomically:YES];
    
    if (self.arrayEditBookMark) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onButtonSave:nil];
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        default:
            return 1;
            break;
    }
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell%d%d", indexPath.section, indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    // Configure the cell...
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                self.textFieldTitle.frame = CGRectMake(20, 7, 280, 30);
                NSString *title;
                if (self.arrayEditBookMark) {
                    title = [self.arrayEditBookMark objectAtIndex:0];
                } else {
                    title = [self.activityItems objectAtIndex:0];
                }
                
                self.textFieldTitle.text = title;
                [cell addSubview:self.textFieldTitle];
            }
                break;
            case 1: {
                self.textFieldURL.frame = CGRectMake(20, 7, 280, 30);
                NSString *url;
                if (self.arrayEditBookMark) {
                    url = [self.arrayEditBookMark objectAtIndex:1];
                } else {
                    url = [self.activityItems objectAtIndex:1];
                }
                self.textFieldURL.text = url;
                [cell addSubview:self.textFieldURL];
            }
                break;
            default:
                break;
        }
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [cell.textLabel setTextColor:[UIColor colorWithRed:107.0/255.0 green:127.0/255.0 blue:155.0/255.0 alpha:1.0]];
        
        cell.textLabel.text = [[NSFileManager defaultManager] displayNameAtPath:self.selectedPath];
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
    // Navigation logic may go here. Create and push another view controller.

    if (indexPath.section == 1) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *bookMarkPath = [documentsDirectory stringByAppendingPathComponent:@"Bookmarks"];
        
        SeequBookmarkFoldersViewController *bookmarkFoldersViewController = [[SeequBookmarkFoldersViewController alloc] initWithNibName:@"SeequBookmarkFoldersViewController" bundle:nil];
        bookmarkFoldersViewController.beginFolderPath = bookMarkPath;
        bookmarkFoldersViewController.selectedFolderPath = self.selectedPath;
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
    [self setTextFieldTitle:nil];
    [self setTextFieldURL:nil];
    
    [super viewDidUnload];
}

@end