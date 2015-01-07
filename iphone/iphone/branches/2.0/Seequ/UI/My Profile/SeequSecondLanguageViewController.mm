//
//  SeequSecondLanguageViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/8/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequSecondLanguageViewController.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"


@interface SeequSecondLanguageViewController ()


@property (nonatomic,retain)    NSMutableArray*  flags;


@end

@implementation SeequSecondLanguageViewController

@synthesize delegate = _delegate;
@synthesize navigationTitle;
@synthesize videoViewState;
@synthesize selectedLanguage;
@synthesize showNoneField;
@synthesize currentIndex;
@synthesize flags = _flags;

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
    if(IS_IOS_7){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    // Do any additional setup after loading the view from its nib.
    
    NSString *filePath = [Common FindFilePathWithFilename:@"LanguageList.plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    NSArray *array = [dict objectForKey:@"Item"];
    
    arrayCountrys = [[NSMutableArray alloc ] init];
    _flags  = [[NSMutableArray alloc] init];
    for (int i = 0; i <  array.count; i++) {
        [arrayCountrys addObject:[[array objectAtIndex:i] objectAtIndex:0]];
        [self.flags addObject:[[array objectAtIndex:i] objectAtIndex:1]];

    }
    
//    if (self.showNoneField) {
//        [arrayCountrys addObject:@"None"];
//    }
//    
//    for (NSDictionary *dict in array) {
//        [arrayCountrys addObject:dict];
//    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewChange:)
                                                 name:kVideoViewChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVideoViewOrientationChange:)
                                                 name:kVideoViewOrientationChangeNotification
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.labelNavigationTitle.text = navigationTitle;

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
               frame = CGRectMake(0, 64, 320, 416 + diff);
            } else{
               frame = CGRectMake(0, 44, 320, 416 + diff);
            }
//            self.MyTableView.frame = frame;
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 320 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 320 - diff));
//            self.MyTableView.frame = frame;
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 228 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 228 - diff));
//            self.MyTableView.frame = frame;
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
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.showNoneField?arrayCountrys.count +1:[arrayCountrys count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    // Set up the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;
    int index = self.showNoneField ? indexPath.row -1:indexPath.row;
    if (self.showNoneField && indexPath.row == 0) {
        NSString *text = @"None";
        cell.textLabel.text = [NSString stringWithFormat:@"                 %@", text];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    } else {
        NSString *text = [arrayCountrys objectAtIndex:index];
        cell.textLabel.text = [NSString stringWithFormat:@"                 %@", text];
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        if (self.selectedLanguage && [self.selectedLanguage isEqualToString:text]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        UIImage* im = [UIImage imageNamed:[_flags objectAtIndex:index]];
        
        UIImageView *imageViewBadg = [[UIImageView alloc] initWithImage:im];
        CGFloat scaleFactor = 40/im.size.width;
        imageViewBadg.frame = CGRectMake(15, (cell.frame.size.height - im.size.height*scaleFactor)/2, scaleFactor* im.size.width, scaleFactor* im.size.height);
        [imageViewBadg setImage: im];
        [cell addSubview:imageViewBadg];
        
        }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *text;
    int index = self.showNoneField ? indexPath.row -1:indexPath.row;
    text = index == -1 ?nil:[arrayCountrys objectAtIndex:index];

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
    
    if ([_delegate respondsToSelector:@selector(didChooseLanguage:withLanguage:)]) {
        [_delegate didChooseLanguage:self withLanguage:text];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    [self setMyTableView:nil];
    [super viewDidUnload];
}
@end
