//
//  SeequSearchViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/2/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequSearchViewController.h"
#import "SeequSearchResultsViewController.h"
#import "idoubs2AppDelegate.h"
#import "NavigationBar.h"
#import "BackBarButton.h"

@interface SeequSearchViewController ()

@end

@implementation SeequSearchViewController


@synthesize searchTextDefault;
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
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    // Do any additional setup after loading the view from its nib.
    
    arrayBadges = [[NSMutableArray alloc] initWithObjects:@"                 All",
                                                          @"                 BIZ",
                                                          @"                 EDU",
                                                          @"                 ORG",
                                                          @"                 GOV",
                                                          @"                 PRO",
                                                          @"                 EXPERT",
                                                          @"                 MENTOR",
                                                          @"                 ADVISOR",
                                                          @"                 MEMBER", nil];

    arraySelectedBadges = [[NSMutableArray alloc] initWithArray:arrayBadges];
    arrayBadgeItems = [[NSMutableArray alloc] init];
    
    [self onButtonFilter:self.buttonPeople];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewChange:)
                                                 name:kVideoViewChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewOrientationChange:)
                                                 name:kVideoViewOrientationChangeNotification
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.hidden = NO;

	((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleSearch.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
    
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack:)];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    [self didSaveBadges:nil withBadgesArray:arraySelectedBadges];
    if (self.searchTextDefault) {
        [self.textFieldSearch setText:self.searchTextDefault];
        searchTextDefault = nil;
    }

    self.scrollViewContent.contentSize = CGSizeMake(320, 367);
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (UIInterfaceOrientationIsPortrait([idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation)) {
        [self setVideoViewState:self.videoViewState Animated:NO];
    }
}

- (void) onVideoViewChange:(NSNotification*)notification {
    NSNumber* eargs = [notification object];
    videoViewState = (VideoViewState)[eargs intValue];
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
            frame = CGRectMake(0, 0, 320, 367 + diff);
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 271 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 271 - diff));
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 179 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 179 - diff));
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
        self.scrollViewContent.frame = frame;
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButtonFilter:(id)sender {
    UIButton *button = (UIButton*)sender;
    
    switch (button.tag) {
        case 1: {
            searchType = Search_Type_People;
            [self.buttonPeople setBackgroundImage:[UIImage imageNamed:@"segSearchPeopleSel.png"] forState:UIControlStateNormal];
            [self.buttonTopics setBackgroundImage:[UIImage imageNamed:@"segSearchTopics.png"] forState:UIControlStateNormal];
        }
            break;
        case 2: {
            searchType = Search_Type_Topics;
            [self.buttonPeople setBackgroundImage:[UIImage imageNamed:@"segSearchPeople.png"] forState:UIControlStateNormal];
            [self.buttonTopics setBackgroundImage:[UIImage imageNamed:@"segSearchTopicsSel.png"] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    
//    [self filterContactsWithSegment_Type:searchType];
}

- (IBAction)onButtonSearch:(id)sender {
    if (self.textFieldSearch.text && self.textFieldSearch.text.length) {
        SeequSearchResultsViewController *searchResultsViewController = [[SeequSearchResultsViewController alloc] initWithNibName:@"SeequSearchResultsViewController" bundle:nil];
        searchResultsViewController.searchText = self.textFieldSearch.text;
        searchResultsViewController.videoViewState = self.videoViewState;
        [self.navigationController pushViewController:searchResultsViewController animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
                                                        message:@"Empty search text."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)onButtonSort:(id)sender {
    SeequSortViewController *sortViewController = [[SeequSortViewController alloc] initWithNibName:@"SeequSortViewController" bundle:nil];
    sortViewController.delegate = self;
    sortViewController.sortText = self.labelSortType.text;
    sortViewController.videoViewState = self.videoViewState;
    [self.tabBarController presentViewController:sortViewController animated:YES completion:nil ];
}

- (IBAction)onButtonSearchBadge:(id)sender {
    SeequBadgesViewController *badgesViewController = [[SeequBadgesViewController alloc] initWithNibName:@"SeequBadgesViewController" bundle:nil];
    badgesViewController.delegate = self;
    badgesViewController.arrayBadges = arraySelectedBadges;
    badgesViewController.videoViewState = self.videoViewState;
    [self.tabBarController presentViewController:badgesViewController animated:YES completion:nil];
}

- (IBAction)onButtonResetSearch:(id)sender {
    self.textFieldSearch.text = @"";
    [self didSaveBadges:nil withBadgesArray:arrayBadges];
    self.labelSortType.text = @"Relevance";
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onButtonSearch:nil];
    
    return YES;
}

#pragma mark SeequSortViewControllerDelegate

- (void) didSelectSortType:(SeequSortViewController *)sortViewController withSortText:(NSString *)text {
    self.labelSortType.text = text;
    
    [sortViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark SeequBadgesViewControllerDelegate

- (void) didSaveBadges:(SeequBadgesViewController *)sortViewController withBadgesArray:(NSMutableArray *)array {
    if (sortViewController) {
        [sortViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    arraySelectedBadges = array;
    
    for (UIView *v in arrayBadgeItems) {
        [v removeFromSuperview];
    }
    
    if ([arraySelectedBadges count] >= 9) {
        UILabel *labelDots = [[UILabel alloc] initWithFrame:CGRectMake(68, 120, 222, 21)];
        [labelDots setFont:[UIFont boldSystemFontOfSize:14.0]];
        [labelDots setText:@"Show All"];
        [labelDots setTextColor:[UIColor blackColor]];
        [labelDots setBackgroundColor:[UIColor clearColor]];
        [self.scrollViewContent addSubview:labelDots];
        [arrayBadgeItems addObject:labelDots];
        
        return;
    }
    
    int index = 0;
    for (NSString *badg in arraySelectedBadges) {
        if (index < 3) {
            NSString *_badg = [badg stringByReplacingOccurrencesOfString:@" " withString:@""];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(68 + index*63, 122, 58, 16)];
            [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"contactMasterBadge%@.png", _badg]]];
            [self.scrollViewContent addSubview:imageView];
            [arrayBadgeItems addObject:imageView];
        } else {
            UILabel *labelDots = [[UILabel alloc] initWithFrame:CGRectMake(258, 127, 20, 10)];
            [labelDots setText:@"..."];
            [labelDots setBackgroundColor:[UIColor clearColor]];
            [self.scrollViewContent addSubview:labelDots];
            [arrayBadgeItems addObject:labelDots];
            
            break;
        }
        
        index++;
    }
}

- (void)viewDidUnload {
    [self setButtonPeople:nil];
    [self setButtonTopics:nil];

    [self setTextFieldSearch:nil];
    [self setLabelSortType:nil];
    [self setScrollViewContent:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end