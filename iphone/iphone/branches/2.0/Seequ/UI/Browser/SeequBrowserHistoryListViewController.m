//
//  SeequBrowserHistoryListViewController.m
//  ProTime
//
//  Created by Norayr on 02/20/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import "SeequBrowserHistoryListViewController.h"
#import "NavigationBar.h"
#import "BackBarButton.h"
#import "config.h"

@interface SeequBrowserHistoryListViewController ()

@end

@implementation SeequBrowserHistoryListViewController

@synthesize seequBrowserHistoryListDelegate = _delegate;
@synthesize arrayHistoryList;

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

    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    NSDictionary *dict = [self.arrayHistoryList objectAtIndex:0];
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"EEMMMd" options:0 locale:[NSLocale currentLocale]]];
    NSString* date = [dateFormater stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"time"] doubleValue]]];

    self.navigationItem.title = date;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack:)];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    BackBarButton *actionBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"seequButtonDone.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(onButtonDone:)];
    
    self.navigationItem.rightBarButtonItem = actionBarButton;
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onButtonDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onButtonClear:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Clear History"
                                              otherButtonTitles:nil];
    [sheet showInView:self.view];
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
    return self.arrayHistoryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...

    NSDictionary *dict = [self.arrayHistoryList objectAtIndex:indexPath.row];
    cell.imageView.image = nil;

    if ([dict isKindOfClass:[NSMutableArray class]]) {
        NSLog(@"WWWWWWWWW");
    } else {
        cell.textLabel.text = [dict objectForKey:@"title"];
        cell.imageView.image = [UIImage imageNamed:@"bookmark.png"];
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
    if ([_delegate respondsToSelector:@selector(didSelectHistoryItem:withDictionary:)]) {
        NSDictionary *dict = [self.arrayHistoryList objectAtIndex:indexPath.row];
        
        [_delegate didSelectHistoryItem:self withDictionary:dict];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:HISTORY_KEY];
        [arrayHistoryList removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
