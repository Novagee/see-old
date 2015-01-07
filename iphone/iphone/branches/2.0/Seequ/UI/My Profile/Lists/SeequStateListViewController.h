//
//  SeequStateListViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 11/30/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequState.h"

@protocol SeequStateListViewControllerDelegate;

@interface SeequStateListViewController : UIViewController {
//    id<SeequStateListViewControllerDelegate> __unsafe_unretained _delegate;
    
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}


@property (nonatomic, assign) int videoViewState;

@property (nonatomic, assign) id<SeequStateListViewControllerDelegate> delegate;
@property (nonatomic, strong) SeequState *currentSelected;
@property (nonatomic, strong) NSArray *arrayOfList;

@property (strong, nonatomic) IBOutlet UITableView *MyTableView;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (IBAction)onButtonCancel:(id)sender;


@end

@protocol SeequStateListViewControllerDelegate <NSObject>

@optional

- (void) didSelectState:(SeequStateListViewController*)controller State:(SeequState*)state;

@end