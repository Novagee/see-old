//
//  SeequChooserListViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 11/22/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SeequChooserListViewControllerDelegate;

@interface SeequChooserListViewController : UIViewController {
//    id<SeequChooserListViewControllerDelegate> __unsafe_unretained _delegate;

    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, assign) int videoViewState;

@property (nonatomic, assign) id<SeequChooserListViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *currentSelected;
@property (nonatomic, strong) NSArray *arrayOfList;

@property (strong, nonatomic) IBOutlet UITableView *MyTableView;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (IBAction)onButtonCancel:(id)sender;

@end

@protocol SeequChooserListViewControllerDelegate <NSObject>

@optional

- (void) didSelectItem:(SeequChooserListViewController*)controller Item:(NSString*)item;

@end