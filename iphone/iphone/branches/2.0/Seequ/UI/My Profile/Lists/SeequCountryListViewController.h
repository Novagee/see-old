//
//  SeequCountryListViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 11/30/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequCountry.h"
@protocol SeequCountryListViewControllerDelegate;

@interface SeequCountryListViewController : UIViewController {
//    id<SeequCountryListViewControllerDelegate> __unsafe_unretained _delegate;

    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}


@property (nonatomic, assign) int videoViewState;

@property (nonatomic, assign) id<SeequCountryListViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *arrayOfList;
@property (nonatomic, retain) SeequCountry *currentSelected;
@property (strong, nonatomic) IBOutlet UITableView *MyTableView;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (IBAction)onButtonCancel:(id)sender;


@end

@protocol SeequCountryListViewControllerDelegate <NSObject>

@optional

- (void) didSelectCountry:(SeequCountryListViewController*)controller Country:(SeequCountry*)country;

@end