//
//  SeequBadgesViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/2/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequBadgesViewController.h"
#import "idoubs2AppDelegate.h"

@interface SeequBadgesViewController ()

@end

@implementation SeequBadgesViewController

@synthesize delegate = _delegate;
@synthesize arrayBadges;
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
    
    arrayWorking = [[NSMutableArray alloc] initWithArray:self.arrayBadges];
    
    arrayBadgesText = [[NSMutableArray alloc] initWithObjects:@"                 All",
                                                              @"                 BIZ",
//                                                              @"                 EDU",
                                                              @"                 ORG",
                                                              @"                 GOV",
                                                              @"                 PRO",
                                                              @"                 EXPERT",
                                                              @"                 MENTOR",
                                                              @"                 ADVISOR",
                                                              @"                 MEMBER", nil];
    self.buttonSave.hidden = YES;

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
            frame = CGRectMake(0, 44, 320, 416 + diff);
            if (state == VideoViewState_HIDE) {
                if (![UIApplication sharedApplication].statusBarHidden) {
                    self.view.frame = CGRectMake(0, 20, 320, 460 + diff);
                }
            }
        }
            break;
        case VideoViewState_TAB: {
            frame = CGRectMake(0, self.view.frame.size.height - 271 - 48 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 271 - diff) + 48);
        }
            break;
        case VideoViewState_TAB_MENU: {
            frame = CGRectMake(0, self.view.frame.size.height - 179 - 48 - diff, 320, self.view.frame.size.height - (self.view.frame.size.height - 179 - diff) + 48);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButtonCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onButtonSave:(id)sender {
    if ([_delegate respondsToSelector:@selector(didSaveBadges:withBadgesArray:)]) {
        [_delegate didSaveBadges:self withBadgesArray:arrayWorking];
    }
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
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Set up the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSString *text = [arrayBadgesText objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];

    UIImageView *imageViewCheckmark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 30)];
    
    if ([self isHaveBadge:text]) {
        [imageViewCheckmark setImage:[UIImage imageNamed:@"defaultSeequCheckedButton.png"]];
        UIView *viewBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        [viewBG setBackgroundColor:[UIColor colorWithRed:235.0/255.0
                                                 green:235.0/255.0
                                                  blue:235.0/255.0
                                                 alpha:1.0]];
        [cell setBackgroundView:viewBG];
    } else {
        [imageViewCheckmark setImage:[UIImage imageNamed:@"defaultSeequUnCheckedButton.png"]];
        UIView *viewBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        [viewBG setBackgroundColor:[UIColor whiteColor]];
        [cell setBackgroundView:viewBG];
    }

    cell.accessoryView = imageViewCheckmark;
    
    if (indexPath.row != 0) {
        text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        UIImageView *imageViewBadg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 20, 72, 20)];
        NSString *fileName = [NSString stringWithFormat:@"ProfileBadgeStatus%@", [self MakeValidImageName:text]];
        [imageViewBadg setImage:[UIImage imageNamed:fileName]];
        [cell addSubview:imageViewBadg];
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.buttonSave.hidden = NO;
    NSString *text = [arrayBadgesText objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([self isHaveBadge:text]) {
        if (indexPath.row == 0) {
            [self DeselectAll];
        } else {
            [self DeleteBadgFromArray:text];
            UIImageView *imageView = (UIImageView *)cell.accessoryView;
            [imageView setImage:[UIImage imageNamed:@"defaultSeequUnCheckedButton.png"]];
            UIView *viewBG = cell.backgroundView;
            [viewBG setBackgroundColor:[UIColor clearColor]];
        }
    } else {
        if (indexPath.row == 0) {
            [self SelectAll];
        } else {
            [self AddBadgToArray:text];
            UIImageView *imageView = (UIImageView *)cell.accessoryView;
            [imageView setImage:[UIImage imageNamed:@"defaultSeequCheckedButton.png"]];
            
            UIView *viewBG = cell.backgroundView;
            [viewBG setBackgroundColor:[UIColor colorWithRed:235.0/255.0
                                                     green:235.0/255.0
                                                      blue:235.0/255.0
                                                     alpha:1.0]];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (BOOL) isHaveBadge:(NSString*)badg {
    @synchronized(self) {
        for (NSString *str in arrayWorking) {
            if ([str isEqualToString:badg]) {
                return YES;
            }
        }
    }

    return NO;
}

- (void) AddBadgToArray:(NSString*)badg {
    @synchronized(self) {
        BOOL isFound = NO;
        for (NSString *str in arrayWorking) {
            if ([str isEqualToString:badg]) {
                isFound = YES;
                
                break;
            }
        }
        
        if (!isFound) {
            [arrayWorking addObject:badg];
        }
        
        if (arrayWorking.count >= arrayBadgesText.count-1) {
            [self SelectAll];
        }
    }
}

- (void) DeleteBadgFromArray:(NSString*)badg {
    @synchronized(self) {
        for (NSString *str in arrayWorking) {
            if ([str isEqualToString:badg]) {
                [arrayWorking removeObject:str];
                
                break;
            }
        }
    }
    
    if (![badg isEqualToString:@"                 All"]) {
        [self DeleteBadgFromArray:@"                 All"];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        UITableViewCell *cell = [self.MyTableView cellForRowAtIndexPath:indexPath];
        
        if (cell) {
            UIImageView *imageView = (UIImageView *)cell.accessoryView;
            [imageView setImage:[UIImage imageNamed:@"defaultSeequUnCheckedButton.png"]];
            UIView *viewBG = cell.backgroundView;
            [viewBG setBackgroundColor:[UIColor clearColor]];
        }
        
        if (!arrayWorking.count) {
            self.buttonSave.hidden = YES;
        }
    }
}

- (void) SelectAll {
    [arrayWorking removeAllObjects];
    
    for (int i = 0; i < arrayBadgesText.count;i++) {
        NSString *text = [arrayBadgesText objectAtIndex:i];
        [arrayWorking addObject:text];
    }
  
    for (int i = 0; i < arrayBadgesText.count;i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];

        UITableViewCell *cell = [self.MyTableView cellForRowAtIndexPath:indexPath];
        
        if (cell) {
            UIImageView *imageView = (UIImageView *)cell.accessoryView;
            [imageView setImage:[UIImage imageNamed:@"defaultSeequCheckedButton.png"]];
            UIView *viewBG = cell.backgroundView;
            [viewBG setBackgroundColor:[UIColor colorWithRed:235.0/255.0
                                                     green:235.0/255.0
                                                      blue:235.0/255.0
                                                     alpha:1.0]];
        }
    }
}

- (void) DeselectAll {
    [arrayWorking removeAllObjects];

    for (int i = 0; i < arrayBadgesText.count;i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        UITableViewCell *cell = [self.MyTableView cellForRowAtIndexPath:indexPath];

        if (cell) {
            UIImageView *imageView = (UIImageView *)cell.accessoryView;
            [imageView setImage:[UIImage imageNamed:@"defaultSeequUnCheckedButton.png"]];
            UIView *viewBG = cell.backgroundView;
            [viewBG setBackgroundColor:[UIColor clearColor]];
        }
    }
    
    self.buttonSave.hidden = YES;
}

- (NSString*) MakeValidImageName:(NSString*)name {
    if (!name || ![name isKindOfClass:[NSString class]] || name.length < 1) {
        return nil;
    }
    
    if ([name isEqualToString:@"BIZ"]) {
        return @"Business";
    }
    
    if ([name isEqualToString:@"ORG"]) {
        return @"Organization";
    }
    
    if ([name isEqualToString:@"GOV"]) {
        return @"Government";
    }
    
    NSString *firstSimbol = [name substringToIndex:1];
    firstSimbol = [firstSimbol uppercaseString];
    
    NSString *fromFirst = [name substringFromIndex:1];
    fromFirst = [fromFirst lowercaseString];
    
    return [NSString stringWithFormat:@"%@%@", firstSimbol, fromFirst];
}

- (void)viewDidUnload {
    [self setMyTableView:nil];
    [self setButtonSave:nil];
    [super viewDidUnload];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end