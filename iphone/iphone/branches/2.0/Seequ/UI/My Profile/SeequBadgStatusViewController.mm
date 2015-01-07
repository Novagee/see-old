//
//  SeequBadgStatusViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/8/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequBadgStatusViewController.h"
#import "idoubs2AppDelegate.h"

@interface SeequBadgStatusViewController ()

@end

@implementation SeequBadgStatusViewController


@synthesize BadgStatus;
@synthesize delegate = _delegate;
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

    prevIndexPath = nil;
    
    NSDictionary *dict  = [[NSDictionary alloc] initWithObjectsAndKeys:@"                 Pro",  @"text", @"NO", @"status",  nil];
    NSDictionary *dict1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"                 Expert", @"text", @"NO", @"status", nil];
    NSDictionary *dict2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"                 Advisor", @"text", @"NO", @"status", nil];
    NSDictionary *dict3 = [[NSDictionary alloc] initWithObjectsAndKeys:@"                 Mentor", @"text", @"YES", @"status",  nil];
    NSDictionary *dict4 = [[NSDictionary alloc] initWithObjectsAndKeys:@"                 Government",  @"text", @"YES", @"status",  nil];
    NSDictionary *dict5 = [[NSDictionary alloc] initWithObjectsAndKeys:@"                 Business", @"text", @"NO", @"status",  nil];
    NSDictionary *dict6 = [[NSDictionary alloc] initWithObjectsAndKeys:@"                 Organization", @"text", @"NO", @"status",  nil];
    NSDictionary *dict7 = [[NSDictionary alloc] initWithObjectsAndKeys:@"                 Member", @"text", @"YES", @"status",  nil];
    
    arrayBadgesText = [[NSMutableArray alloc] init];
    [arrayBadgesText addObject:dict];
    [arrayBadgesText addObject:dict1];
    [arrayBadgesText addObject:dict2];
    [arrayBadgesText addObject:dict3];
    [arrayBadgesText addObject:dict4];
    [arrayBadgesText addObject:dict5];
    [arrayBadgesText addObject:dict6];
    [arrayBadgesText addObject:dict7];

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
            frame = CGRectMake(0, 44, 320, 416 + diff);
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 320 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 320 - diff));
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 228 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 228 - diff));
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

- (IBAction)onButtonCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onButtonSave:(id)sender {
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayBadgesText count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    // Set up the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSDictionary *dict = [arrayBadgesText objectAtIndex:indexPath.row];
    NSString *text = [dict objectForKey:@"text"];
    cell.textLabel.text = text;
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    UIImageView *imageViewBadg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 72, 20)];
    [imageViewBadg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ProfileBadgeStatus%@.png", text]]];
    [cell addSubview:imageViewBadg];
    
    NSString *status = [dict objectForKey:@"status"];
    if ([status isEqualToString:@"YES"]) {
        UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(220, 8, 70, 26)];
        [lblHeader setBackgroundColor:[UIColor clearColor]];
        [lblHeader setFont:[UIFont systemFontOfSize:14]];
        [lblHeader setTextColor:[UIColor lightGrayColor]];
        [lblHeader setText:@"Qualified"];
        [lblHeader setTextAlignment:NSTextAlignmentLeft];
        [cell addSubview:lblHeader];
        
        [cell setBackgroundColor:[UIColor colorWithRed:235.0/255.0
                                                 green:235.0/255.0
                                                  blue:235.0/255.0
                                                 alpha:1.0]];
    }

    if (self.BadgStatus && [text isEqualToString:self.BadgStatus]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *text = [arrayBadgesText objectAtIndex:indexPath.row];
    
    if (prevIndexPath && prevIndexPath.row != indexPath.row) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:prevIndexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [cell setBackgroundColor:[UIColor colorWithRed:235.0/255.0
                                                 green:235.0/255.0
                                                  blue:235.0/255.0
                                                 alpha:1.0]];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    
    prevIndexPath = indexPath;
    
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_delegate respondsToSelector:@selector(didSaveBadges:withBadge:)]) {
        [_delegate didSaveBadges:self withBadge:[cell.textLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 41.5;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMyTableView:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end