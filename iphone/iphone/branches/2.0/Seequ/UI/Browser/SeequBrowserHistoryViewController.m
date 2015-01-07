//
//  SeequBrowserHistoryViewController.m
//  ProTime
//
//  Created by Norayr on 02/20/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import "SeequBrowserHistoryViewController.h"
#import "config.h"
#import "NavigationBar.h"
#import "BackBarButton.h"

@interface SeequBrowserHistoryViewController ()

@end

@implementation SeequBrowserHistoryViewController


@synthesize seequBrowserHistoryDelegate = _delegate;


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
    self.navigationItem.title = @"History";
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

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
    
    arrayHistory = [self CreateHistoryArray];
    [self.tableView reloadData];
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onButtonDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil ];
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
    
    return arrayHistory.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.imageView.image = nil;

    if ([[arrayHistory objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = [arrayHistory objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict objectForKey:@"title"];
        //
       // NSLog(@"link = %@", [dict objectForKey:@"link"]);
        //
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.imageView.image = [UIImage imageNamed:@"bookmark.png"];
    } else {
        NSArray *arrayItem = [arrayHistory objectAtIndex:indexPath.row];
        NSDictionary *dict = [arrayItem objectAtIndex:0];
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"EEEEMMMd" options:0 locale:[NSLocale currentLocale]]];
        NSString* date = [dateFormater stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"time"] doubleValue]]];
        
        cell.textLabel.text = date;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
//    NSLog(@"%i", indexPath.row);
//    NSLog(@"link %@" , cell.textLabel.text);
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
    if ([[arrayHistory objectAtIndex:indexPath.row] isKindOfClass:[NSDictionary class]]) {
        if ([_delegate respondsToSelector:@selector(didSelectHistoryItem:withDictionary:)]) {
            NSDictionary *dict = [arrayHistory objectAtIndex:indexPath.row];
            
            [_delegate didSelectHistoryItem:self withDictionary:dict];
        }
    } else {
        NSArray *tmpArray = [arrayHistory objectAtIndex:indexPath.row];
        NSMutableArray *arrayItem = [[NSMutableArray alloc] initWithArray:tmpArray];
        
        SeequBrowserHistoryListViewController *controller = [[SeequBrowserHistoryListViewController alloc] init];
        ///@todo levon check  for  proper  delegate  assigning
        controller.seequBrowserHistoryListDelegate =  (id<SeequBrowserHistoryListDelegate>) self.seequBrowserHistoryDelegate;
        controller.arrayHistoryList = arrayItem;
        [self.navigationController pushViewController:controller animated:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSMutableArray*) CreateHistoryArray {
    NSMutableArray *arrayUnsorted = [[NSMutableArray alloc] init];
    NSMutableDictionary *mDict = [[NSUserDefaults standardUserDefaults] objectForKey:HISTORY_KEY];
    
    for (NSString *key in mDict) {
        NSDictionary *dict = [mDict objectForKey:key];
        [arrayUnsorted addObject:dict];
    }
    
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    NSArray *arraySorted = [arrayUnsorted sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    NSMutableArray *arrayReturn = [[NSMutableArray alloc] init];
    NSMutableArray *arrayTmp;
    int prev_day = 0;
   // NSLog(@"array sorted = %@",arraySorted);
    int today = (int)[[NSDate date] timeIntervalSince1970]/86400;
    for (NSDictionary *dict in arraySorted) {
        NSTimeInterval time = [[dict objectForKey:@"time"] doubleValue];
        
        int day = (int)(time/86400);
        
        if (day == today) {
            [arrayReturn addObject:dict];
            prev_day = day;
            
            continue;
        }
        
        if (day != prev_day) {
            arrayTmp = [[NSMutableArray alloc] init];
            [arrayTmp addObject:dict];
            [arrayReturn addObject:arrayTmp];
            prev_day = day;
        } else {
            [arrayTmp addObject:dict];
            
        }
    }
    
    
   // NSLog(@"----%@", arrayReturn);
    return arrayReturn;
    
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:HISTORY_KEY];
        [arrayHistory removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

@end
