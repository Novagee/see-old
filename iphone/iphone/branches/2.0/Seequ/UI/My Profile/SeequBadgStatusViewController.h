//
//  SeequBadgStatusViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/8/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SeequBadgStatusViewControllerDelegate;

@interface SeequBadgStatusViewController : UIViewController {
    NSMutableArray *arrayBadgesText;
    NSIndexPath *prevIndexPath;
    
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, assign) int videoViewState;

@property (nonatomic, assign) id<SeequBadgStatusViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *BadgStatus;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *MyTableView;


- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (IBAction) onButtonCancel:(id)sender;


@end

@protocol SeequBadgStatusViewControllerDelegate <NSObject>

@optional

- (void) didSaveBadges:(SeequBadgStatusViewController*)sortViewController withBadge:(NSString*)badg;

@end