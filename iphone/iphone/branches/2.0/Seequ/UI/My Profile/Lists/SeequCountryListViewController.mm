//
//  SeequCountryListViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 11/30/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequCountryListViewController.h"
#import "idoubs2AppDelegate.h"
#import "SeequCountry.h"

@interface SeequCountryListViewController ()

@property(readwrite, copy, nonatomic) NSArray *tableData;
@end

@implementation SeequCountryListViewController


@synthesize delegate = _delegate;
@synthesize currentSelected;
@synthesize arrayOfList;
@synthesize videoViewState;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewChange:)
                                                 name:kVideoViewChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewOrientationChange:)
                                                 name:kVideoViewOrientationChangeNotification
                                               object:nil];
    self.tableData = [self partitionObjects:self.arrayOfList collationStringSelector:@selector(countryName)];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (UIInterfaceOrientationIsPortrait([idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation)) {
        [self setVideoViewState:self.videoViewState Animated:NO];
    }
}

- (void) onVideoViewChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    self.videoViewState = (VideoViewState)[eargs intValue];
}

- (void) onVideoViewOrientationChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    Video_InterfaceOrientation = (UIInterfaceOrientation)[eargs intValue];
    
    [self setVideoViewState:self.videoViewState Animated:YES];
}

- (void) setVideoViewState:(int)state Animated:(BOOL)animated {
    if ([[idoubs2AppDelegate sharedInstance].videoService.showVideoView isVideoState]) {
        if (UIInterfaceOrientationIsLandscape(Video_InterfaceOrientation)) {
            state = VideoViewState_HIDE;
        }
    } else {
        state = VideoViewState_HIDE;
    }
    
    videoViewState = state;
    
    int diff = 0;
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 568) {
        diff = 88;
    }
    
    CGRect frame = CGRectZero;
    switch (state) {
        case VideoViewState_NONE:
        case VideoViewState_NORMAL:
        case VideoViewState_NORMAL_MENU:
        case VideoViewState_HIDE: {
            //frame = CGRectMake(0, 44, 320, 416 + diff);
            
            if(IS_IOS_7){
                self.view.frame = CGRectMake(0, 0, 320, 416 + diff);
                self.MyTableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
                
            } else{
                self.view.frame = CGRectMake(0, 20, 320, 416 + diff);
                self.MyTableView.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height);
            }
        }
            break;
        case VideoViewState_TAB: {
            
            if(IS_IOS_7){
                frame = CGRectMake(0, self.view.frame.size.height - 320 - diff + 64, 320, self.view.frame.size.height - (self.view.frame.size.height - 320 - diff) );
            } else{
                frame = CGRectMake(0, self.view.frame.size.height - 320 - diff + 44, 320, self.view.frame.size.height - (self.view.frame.size.height - 320 - diff) );
            }
        }
            break;
        case VideoViewState_TAB_MENU: {
            if(IS_IOS_7){
                frame = CGRectMake(0, self.view.frame.size.height - 228 - diff + 64, 320, self.view.frame.size.height - (self.view.frame.size.height - 228 - diff));
            } else{
                frame = CGRectMake(0, self.view.frame.size.height - 228 - diff + 44, 320, self.view.frame.size.height - (self.view.frame.size.height - 228 - diff) );
            }
            
            self.MyTableView.frame = frame;
            
        }
            break;
        default:
            break;
    }
    
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        if (animated) {
            [UIView beginAnimations:@"scrollFrame" context:nil];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
            [UIView setAnimationDuration:0.3];
        }
        self.MyTableView.frame = frame;
        if (animated) {
            [UIView commitAnimations];
        }
    }
}


#pragma mark Table view methods


//// Customize the number of rows in the table view.
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.arrayOfList.count;
//}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //    currentSelected
  //  SeequCountry *country = [self.arrayOfList objectAtIndex:indexPath.row];
    SeequCountry *country = [[self.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (self.currentSelected && [country.countryID integerValue] == [self.currentSelected.countryID  integerValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = country.countryName;
    
    return cell;
}

/////////////////

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    return [collation sectionTitles];
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    //sectionForSectionIndexTitleAtIndex: is a bit buggy, but is still useable
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    BOOL showSection = [[self.tableData objectAtIndex:section] count] != 0;
    //only show the section title if there are rows in the section
    return (showSection) ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(IS_IOS_7){
        //UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, -5, 320, 30)];
        sectionTitle.text = [self tableView:tableView titleForHeaderInSection:section];
        sectionTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        //        sectionTitle.shadowColor = [UIColor colorWithWhite:0 alpha:0.4];
        //        sectionTitle.shadowOffset = CGSizeMake(1, 1);
        //sectionTitle.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [sectionTitle setTextColor:[UIColor whiteColor]];
        headerView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"seequSectionTabelHeader"]];
        [headerView addSubview:sectionTitle];
        return headerView;
    }
    else{
        return nil;
    }
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 23.3;
}


-(NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector

{
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //create an array to hold the data for each section
    for(int i = 0; i < sectionCount; i++)
    {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    //put each object into a section
    for (id object in array)
    {
        NSInteger index = [collation sectionForObject:object collationStringSelector:selector];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //sort each section
    for (NSMutableArray *section in unsortedSections)
    {
        [sections addObject:[collation sortedArrayFromArray:section collationStringSelector:selector]];
    }
    
    return sections;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //we use sectionTitles and not sections
    return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.tableData objectAtIndex:section] count];
}


///////////////

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(didSelectCountry:Country:)]) {
        [_delegate didSelectCountry:self Country:[[self.tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButtonCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    [self setMyTableView:nil];
    [super viewDidUnload];
}
@end
