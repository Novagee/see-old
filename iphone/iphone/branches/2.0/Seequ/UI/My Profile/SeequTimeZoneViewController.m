//
//  SeequTimeZoneViewController.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 12/18/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//
#import "idoubs2AppDelegate.h"
#import "SeequTimeZoneViewController.h"
#import "SeequTimezoneCell.h"
#import "SeequTimeZoneInfo.h"



@interface SeequTimeZoneViewController (){
}
@property (nonatomic,retain) NSArray* timeZones;
@end

@implementation SeequTimeZoneViewController
@synthesize timeZones;
@synthesize timeZoneDelegate;
@synthesize videoViewState;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        timeZones = [SeequTimeZoneInfo getAllTimeZones];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(IS_IOS_7){
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewChange:)
                                                 name:kVideoViewChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewOrientationChange:)
                                                 name:kVideoViewOrientationChangeNotification
                                               object:nil];
    
//    UIBarButtonItem*  cancelItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"defaultSeequCancelButton"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked) ];
    UIImage* im = [UIImage imageNamed:@"defaultSeequCancelButton"];
    UIButton* button  = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, im.size.width, im.size.height);
    [button setImage:im forState:UIControlStateNormal];
    UIBarButtonItem*  cancelItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(cancelClicked)  forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"seequNavigationDefaultBG"] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = cancelItem;
    self.navigationItem.title = @"Time Zone";
    [self.tableView registerNib:[UINib nibWithNibName:@"SeequTimezoneCell"
                                                bundle:[NSBundle mainBundle]]
          forCellReuseIdentifier:@"CellTimeZone"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
        if(UIInterfaceOrientationIsPortrait([idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation)){
        [self setVideoViewState:self.videoViewState Animated:NO];
    }
}

-(void) cancelClicked{
    NSLog(@"‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡‡");
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
    return timeZones.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellTimeZone";
    SeequTimezoneCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    SeequTimeZoneInfo* inf = [timeZones objectAtIndex:indexPath.row];
    cell.value.text = inf.value;
    cell.cities.text = inf.city;
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
    
    [self dismissViewControllerAnimated:YES completion:^{
        SeequTimeZoneInfo* inf = (SeequTimeZoneInfo*)[timeZones objectAtIndex:indexPath.row];
        [timeZoneDelegate didSelectTimeZone:inf.value ];
    }];
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
            if(IS_IOS_7){
                
                self.view.frame = CGRectMake(0, 64, 320, 460 + diff);
                
            } else{
                
                self.view.frame = CGRectMake(0, 0, 320, 460 + diff);
            }
            
        }
            break;
        case VideoViewState_TAB: {
            if(IS_IOS_7){
                
                frame = CGRectMake(0, self.view.frame.size.height - 303 - diff , 320, self.view.frame.size.height);
                
            } else{
                
                frame = CGRectMake(0, self.view.frame.size.height - 371 - diff , 320, self.view.frame.size.height);
            }
        }
            break;
        case VideoViewState_TAB_MENU: {
            if(IS_IOS_7){
                
                frame = CGRectMake(0, self.view.frame.size.height - 211 - diff , 320, self.view.frame.size.height);
                
            } else{
                
                frame = CGRectMake(0, self.view.frame.size.height - 279 - diff , 320, self.view.frame.size.height);
            }
        }
            break;
        default:
            break;
    }
    
    if (!CGRectEqualToRect(frame, CGRectZero)){
        [UIView beginAnimations:@"scrollFrame" context:nil];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.3];
        self.tableView.frame = frame;
        [UIView commitAnimations];
    }
}

@end
