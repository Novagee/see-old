//
//  SeequMuteMembersViewController.m
//  ProTime
//
//  Created by Grigori Jlavyan on 7/2/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import "SeequMuteMembersViewController.h"
#import "SeequContactProfileViewController.h"
#import "UserInfoCoreData.h"
#import "NavigationBar.h"
#import "BackBarButton.h"
#import "SeequDoubleTakeSettingsCell.h"
#import "common.h"
#import "idoubs2AppDelegate.h"

#define tableCellHeigh 55

static NSString *MutedUsersCell=@"MutedUsersCell";
@interface SeequMuteMembersViewController (){
        UITableView *_tableView;
        UISearchBar *_searchBar;
        NSFetchedResultsController *fetchedController;
        UIInterfaceOrientation Video_InterfaceOrientation;
        int videoViewState;
}

@end

@implementation SeequMuteMembersViewController

- (id)initWithFrame:(CGRect)frame{
        self=[super init];
        if (self) {
                self.view.frame=frame;
                _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                [_tableView setDataSource:self];
                [_tableView setDelegate:self];
                _searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0,_tableView.frame.size.width, 44)];
                [_searchBar setDelegate:self];
                _tableView.tableHeaderView=_searchBar;
                [self.view addSubview:_tableView];
        }
        return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

        if(IS_IOS_7){
                self.edgesForExtendedLayout = UIRectEdgeNone;
                [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewOrientationChange:) name:kVideoViewOrientationChangeNotification object:nil];
        ((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
        [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
        self.navigationItem.title=@"Muted Members";
        BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage    imageNamed:@"defaultSeequBackButton.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(GoBack)];
        
        self.navigationItem.leftBarButtonItem = backBarButton;
        [_tableView registerClass:[SeequDoubleTakeSettingsCell class] forCellReuseIdentifier:MutedUsersCell];
        fetchedController=[self getFetchedResultsController];

}
-(void)viewWillLayoutSubviews{
        [super viewWillLayoutSubviews];
        [self setVideoViewState:videoViewState Animated:YES];
        
}

- (void) onVideoViewChange:(NSNotification*)notification {
        NSNumber* eargs = [notification object];
        videoViewState = (VideoViewState)[eargs intValue];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return tableCellHeigh;
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
                _tableView.frame = frame;
                if (animated) {
                        [UIView commitAnimations];
                }
        }
}





#pragma TabelView delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        id<NSFetchedResultsSectionInfo>sectionInfo=[fetchedController.sections objectAtIndex:section];
        return sectionInfo.numberOfObjects;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
        return [fetchedController.sections count];
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedController sections] objectAtIndex:section];
        return [sectionInfo name];
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
        if(IS_IOS_7){
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
                UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, -5, 320, 30)];
                sectionTitle.text = [self tableView:tableView titleForHeaderInSection:section];
                sectionTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
                [sectionTitle setTextColor:[UIColor whiteColor]];
                headerView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"seequSectionTabelHeader"]];
                [headerView addSubview:sectionTitle];
                return headerView;
        }
        else{
                return nil;
        }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
        ContactObject *selectedContactObject;
        UserInfoCoreData *userInfo=[fetchedController objectAtIndexPath: indexPath];
        selectedContactObject=[[ContactStorage sharedInstance] GetContactObjectBySeequId:userInfo.seeQuId];
        SeequContactProfileViewController *profileViewController = [[SeequContactProfileViewController alloc] initWithNibName:@"SeequContactProfileViewController" bundle:nil];
        profileViewController.contactObj = selectedContactObject;
        profileViewController.videoViewState = videoViewState;
        [self.navigationController pushViewController:profileViewController animated:YES];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        SeequDoubleTakeSettingsCell*cell=[[SeequDoubleTakeSettingsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MutedUsersCell];
        UserInfoCoreData *userInfo=[fetchedController objectAtIndexPath:indexPath];
        ContactObject *obj=[[ContactStorage sharedInstance] GetContactObjectBySeequId:userInfo.seeQuId];
         cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle=UITableViewCellSelectionStyleDefault;
        [cell updateCellForMutedMembers:obj];
        return cell;
}
#pragma FetchedResultsController delegates
- (NSFetchedResultsController *)getFetchedResultsController
{
	if (fetchedController == nil) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSManagedObjectContext* mContext = [CoreDataManager managedObjectContextForMainThread];
		NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([UserInfoCoreData class])
                                                          inManagedObjectContext:mContext];
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                NSPredicate *predicate=[NSPredicate predicateWithFormat:@"isMute=%@",[NSNumber numberWithBool:YES]];
      		NSArray *sortDescriptors = @[sd1];
                
		[fetchRequest setEntity:entity];
                [fetchRequest setPredicate:predicate];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
                
		NSError *error = nil;
                fetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:mContext
                                                                      sectionNameKeyPath:@"firstName.stringGroupByFirstInitial"
                                                                              cacheName:nil];
		[fetchedController setDelegate:self];
                
		
		if (![fetchedController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
	}
	
	return fetchedController;
}
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
        [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
#pragma Searchbar delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
        [_searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
        [_searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
        NSError *error;
        NSPredicate *predicate;
        
        if (searchText && [searchText length]) {
                predicate =[NSPredicate predicateWithFormat:@"isMute=%@ && firstName CONTAINS[cd] %@",[NSNumber numberWithBool:YES],searchText];
        } else {
                predicate =[NSPredicate predicateWithFormat:@"isMute=%@ ",[NSNumber numberWithBool:YES]];
        }
        
        [fetchedController.fetchRequest setPredicate:predicate];
        [fetchedController performFetch:&error];
        if (error) {
                NSLog(@"Error- %@",[error description]);
        }
        [_tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
        [searchBar resignFirstResponder];
        [_searchBar setText:@""];
        NSError *error;
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"isMute=%@",[NSNumber numberWithBool:YES]];
        [fetchedController.fetchRequest setPredicate:predicate];
        [fetchedController performFetch:&error];
        [_tableView reloadData];
        
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        [_searchBar resignFirstResponder];
}


-(void)GoBack{
        [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}
@end
