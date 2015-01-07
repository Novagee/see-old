//
//  SeequAddFavoriteViewController.m
//  ProTime
//
//  Created by Grigori Jlavyan on 5/21/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import "ContactCell.h"
#import "NavigationBar.h"
#import "idoubs2AppDelegate.h"
#import "SeequAddFavoriteViewController.h"

#define tableCellHeigh 55
#define sectionHeaderHeight 23.3

@interface SeequAddFavoriteViewController(){
        UITableView *tabelview;
        UISearchBar *search;
        NSMutableArray *sectionsArray;
        ContactObject *selectedContactObject;
        UIInterfaceOrientation Video_InterfaceOrientation;
        int videoViewState;
        
}
@end

static NSString *contactCell=@"contactCell";

@implementation SeequAddFavoriteViewController

@synthesize fetchedController=_fetchedController;

-(id)initWithFrame:(CGRect)frame{
        self=[super init];
        if(self){
                tabelview=[[UITableView alloc] initWithFrame:frame];
                tabelview.delegate=self;
                tabelview.dataSource=self;
                search=[[UISearchBar alloc] initWithFrame:CGRectMake(0,0,tabelview.frame.size.width,44)];
                search.delegate=self;
                tabelview.tableHeaderView=search;
             [self.view addSubview:tabelview];
             
        }
        return self;
}

- (void)viewDidLoad
{
        [super viewDidLoad];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

        if(IS_IOS_7){
                self.edgesForExtendedLayout=UIRectEdgeNone;
                [tabelview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
               
        }

    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewChange:) name:kVideoViewChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoViewOrientationChange:) name:kVideoViewOrientationChangeNotification object:nil];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContactObjectUpdateEvent:) name:kContactObjectUpdateNotification object:nil];
        ((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
      
//        self.navigationItem.title=@"Add Favorite";
        BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(GoBack)];
        
        self.navigationItem.leftBarButtonItem = backBarButton;
//        _arrayContacts=[[NSMutableArray alloc] init];
        _fetchedController=[self getFetchedResultsController];
        [tabelview registerClass:[ContactCell class] forCellReuseIdentifier:contactCell];
        
      
        
        
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"status.subscription=%@ && isFavorit=%@",@"both",[NSNumber numberWithBool:NO]];
//        NSError *error;
//        [_fetchedController setDelegate:self];
//        [_fetchedController.fetchRequest setPredicate:predicate];
//        [_fetchedController performFetch:&error];
//        if (error) {
//                NSLog(@"Error-%@",[error description]);
//        }
//        [self sortNotFavoritsList];
//        sectionsArray=[self configureSectionsWithArray:_arrayContacts];
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
-(void)viewDidUnload {
    [super viewDidUnload];
    _fetchedController=nil;
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
                  tabelview.frame = frame;
                if (animated) {
                        [UIView commitAnimations];
                }
        }
}
- (NSFetchedResultsController *)getFetchedResultsController
{
	if (_fetchedController == nil) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSManagedObjectContext* mContext = [CoreDataManager managedObjectContextForMainThread];
		NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([UserInfoCoreData class])
                                                          inManagedObjectContext:mContext];
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:@selector(caseInsensitiveCompare:)];
                NSPredicate *predicate=[NSPredicate predicateWithFormat:@"status.subscription=%@ && isFavorit=%@",@"both",[NSNumber numberWithBool:NO]];
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

#pragma NSFetchedResultsController Delegate
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
        [tabelview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
-(void)GoBack{
        [self.navigationController popViewControllerAnimated:YES];
}
#pragma UITbabelView deledates
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        
        ContactCell*cell=[[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactCell];
        
//        cell.selectionStyle=UITableViewCellSelectionStyleDefault;
        UserInfoCoreData *userInfo=[_fetchedController objectAtIndexPath:indexPath];
        ContactObject *obj=[[ContactStorage sharedInstance] GetContactObjectBySeequId:userInfo.seeQuId];
//        NSMutableArray *array = [sectionsArray objectAtIndex:indexPath.section];
//        if (array.count > indexPath.row) {
//                = [array objectAtIndex:indexPath.row];
//                
                [cell setContactObject:obj];
//        }
        return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        UserInfoCoreData *userInfo=[_fetchedController objectAtIndexPath:indexPath];
        selectedContactObject =[[ContactStorage sharedInstance] GetContactObjectBySeequId:userInfo.seeQuId];
        
        [self onSelectedRow];
      
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
        
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        return [[_fetchedController sectionIndexTitles] objectAtIndex:section];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return tableCellHeigh;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
        
        return[_fetchedController.sections count];
        
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        id<NSFetchedResultsSectionInfo>sectionInfo=[_fetchedController.sections objectAtIndex:section];
        return sectionInfo.numberOfObjects;
}
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
        if(IS_IOS_7){
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 30)];
                UILabel *sectionTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, -5,self.view.frame.size.width, 30)];
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
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
        
        return sectionHeaderHeight;
}
#pragma searchBar delegates
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
        [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
        [searchBar setShowsCancelButton:NO animated:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
        NSError* error;
        NSPredicate * predicate;
        if (searchText && [searchText length]) {
              predicate =[NSPredicate predicateWithFormat:@"status.subscription=%@ && isFavorit=%@ && firstName CONTAINS[cd] %@ ",@"both",[NSNumber numberWithBool:NO],searchText];
                
        }else{
              predicate =[NSPredicate predicateWithFormat:@"status.subscription=%@ && isFavorit=%@",@"both",[NSNumber numberWithBool:NO]];
        }
        [_fetchedController.fetchRequest setPredicate:predicate];
        [_fetchedController performFetch:&error];
        if(error){
                NSLog(@"Error-%@",[error description]);
        }
        [tabelview reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
        [searchBar resignFirstResponder];
        [searchBar setText:@""];
        [tabelview reloadData];
        
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        [search resignFirstResponder];
}

- (void)onSelectedRow{
        if (![[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
                [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
        } else {
                [[idoubs2AppDelegate sharedInstance] ShowLoadingViewWithMessage:@"Adding to favorites."];
                [self performSelectorOnMainThread:@selector(AddToFavorites) withObject:nil waitUntilDone:NO];
        }
}
- (void) AddToFavorites {
        @autoreleasepool {
                NSString *error_message = [Common AddFavoriteWithSeequID:selectedContactObject.SeequID];
                
                if (error_message) {
                        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"autorisation_problem"]) {
                                [[idoubs2AppDelegate sharedInstance] performSelectorOnMainThread:@selector(ShowDefaultMessageWithText:) withObject:error_message waitUntilDone:YES];
                        }
                } else {
                       selectedContactObject.isFavorite = YES;
                        [[ContactStorage sharedInstance] setIsUserFavorit:selectedContactObject.SeequID  isFavorit:YES];
                }
        }
        
        [[ idoubs2AppDelegate sharedInstance] HideLoadingView];
}
- (void) onContactObjectUpdateEvent:(NSNotification*)notification {
        NSError *error;
        [_fetchedController performFetch:&error];
        [tabelview reloadData];
}

- (void) HideLoadingView {
        [[idoubs2AppDelegate sharedInstance] HideLoadingView];
        [self.navigationController popViewControllerAnimated:NO];
}
@end
