//
//  SeequDoubleTakeSettingsViewController.m
//  ProTime
//
//  Created by Grigori Jlavyan on 3/19/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import "idoubs2AppDelegate.h"
#import "SeequDoubleTakeSettingsCell.h"
#import "SeequDoubleTakeSettingsViewController.h"

#define tableCellHeigh 55
#define sectionHeaderHeight 23.3

static NSString *doubleTakeSettingsCell=@"doubleTakeSettingsCell";

@interface SeequDoubleTakeSettingsViewController ()
<NSFetchedResultsControllerDelegate, UITableViewDataSource,UISearchBarDelegate,NSFetchedResultsControllerDelegate>{
      NSMutableArray *sectionsArray;
      NSMutableArray *arrayContacts;
      UIInterfaceOrientation Video_InterfaceOrientation;
      int videoViewState;
}
  

@end


@implementation SeequDoubleTakeSettingsViewController
@synthesize fetchedController=_fetchedController;

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
    self.edgesForExtendedLayout=UIRectEdgeNone;
    [self.tabelview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewOrientationChange:) name:kVideoViewOrientationChangeNotification object:nil];
    ((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
    self.navigationItem.title=@"Double take";
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack)];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    [self.tabelview registerClass:[SeequDoubleTakeSettingsCell class] forCellReuseIdentifier:doubleTakeSettingsCell];
        _fetchedController=[self getFetchedResultsController];
 
        
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self setVideoViewState:videoViewState Animated:YES];
   
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}

- (void) onVideoViewChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    videoViewState = (VideoViewState)[eargs intValue];
}

- (void) onVideoViewOrientationChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    Video_InterfaceOrientation = (UIInterfaceOrientation)[eargs intValue];
    [self.view setNeedsLayout];
    
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
            frame = CGRectMake(0, 0, self.view.frame.size.width, 364 + diff);
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 271 - diff, self.view.frame.size.width, self.view.frame.size.height - (self.view.frame.size.height - 271 - diff));
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 179 - diff, self.view.frame.size.width, self.view.frame.size.height - (self.view.frame.size.height - 179 - diff));
        }
            break;
        default:
            break;
    }
    
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        if (animated) {
            [UIView beginAnimations:@"TableFrame" context:nil];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.3];
        }
        self.tabelview.frame = frame;
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (NSFetchedResultsController *)getFetchedResultsController
{
	if (_fetchedController == nil) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSManagedObjectContext* mContext = [CoreDataManager managedObjectContext];
		NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([UserInfoCoreData class])
                                                          inManagedObjectContext:mContext];
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:@selector(caseInsensitiveCompare:)];
                NSPredicate *predicate=[NSPredicate predicateWithFormat:@"status.subscription=%@",@"both"];
      		NSArray *sortDescriptors = @[sd1];
                
		[fetchRequest setEntity:entity];
                [fetchRequest setPredicate:predicate];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
                
		NSError *error = nil;
                _fetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                managedObjectContext:mContext
                                                                                  sectionNameKeyPath:@"firstName.stringGroupByFirstInitial"
                                                                                           cacheName:nil];
		[_fetchedController setDelegate:self];
                
		
		if (![_fetchedController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
	}
	
	return _fetchedController;
}


-(void)GoBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma UITbabelView deledates
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    SeequDoubleTakeSettingsCell*cell=[[SeequDoubleTakeSettingsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:doubleTakeSettingsCell];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
        UserInfoCoreData *userInfo=[_fetchedController objectAtIndexPath:indexPath];
        ContactObject *obj=[[ContactStorage sharedInstance] GetContactObjectBySeequId:userInfo.seeQuId];
       [cell updateCell:obj needToDoubleTake:[userInfo.needToDoubleTake boolValue]];

return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        return [[_fetchedController sectionIndexTitles] objectAtIndex:section];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableCellHeigh;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
        return [_fetchedController.sections count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        id<NSFetchedResultsSectionInfo>sectionInfo=[_fetchedController.sections objectAtIndex:section];
        return sectionInfo.numberOfObjects;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 30)];
    UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, -5,self.view.frame.size.width, 30)];
    sectionTitle.text = [self tableView:tableView titleForHeaderInSection:section];
    sectionTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    [sectionTitle setTextColor:[UIColor whiteColor]];
    headerView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"seequSectionTabelHeader"]];
    [headerView addSubview:sectionTitle];
    return headerView;
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    
    return sectionHeaderHeight;
}
#pragma NSFetchedResultsController delegates
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
        [self.tabelview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}
#pragma searchBar delegates
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:NO animated:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
        NSError *error;
        NSPredicate *predicate;
        
    if (searchText && [searchText length]) {
          predicate =[NSPredicate predicateWithFormat:@"status.subscription=%@ && firstName CONTAINS[cd] %@",@"both",searchText];
    } else {
         predicate =[NSPredicate predicateWithFormat:@"status.subscription=%@ ",@"both"];
    }
       
    [_fetchedController.fetchRequest setPredicate:predicate];
    [_fetchedController performFetch:&error];
        if (error) {
                NSLog(@"Error- %@",[error description]);
        }
    [self.tabelview reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
    [self.searchBar setText:@""];
    [self.tabelview reloadData];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

@end

