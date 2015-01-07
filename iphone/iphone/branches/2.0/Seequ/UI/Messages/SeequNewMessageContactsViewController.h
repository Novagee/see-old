//
//  SeequNewMessageContactsViewController.h
//  ProTime
//
//  Created by Norayr on 06/07/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"
#import "ContactStorage.h"
#import "SearchBarWithCallButton.h"


@protocol NewMessageContactsDelegate;


@interface SeequNewMessageContactsViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate,NSFetchedResultsControllerDelegate, SearchBarDelegate> {
    id<NewMessageContactsDelegate> __unsafe_unretained _delegate;



    SearchBarWithCallButton *SearchBar;
}

@property (nonatomic, assign) id<NewMessageContactsDelegate> seequContactsDelegate;
@property (strong, nonatomic) IBOutlet UITableView *MyTableView;
@property (nonatomic, assign) int videoViewState;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewNavigationBar;
@property (strong, nonatomic) IBOutlet UILabel *labelMySeequ;
@property (strong, nonatomic) IBOutlet UIButton *buttonCancel;
@property (nonatomic,assign) BOOL isFromForwardCalled;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (nonatomic,strong) NSFetchedResultsController *fetchedController;

- (IBAction)onButtonCancel:(id)sender;
- (void) setVideoViewState:(int)state Animated:(BOOL)animated;
- (void) UpdateInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

@protocol NewMessageContactsDelegate <NSObject>

- (void) didSelectContact:(SeequNewMessageContactsViewController*)controller Contact:(ContactObject*)contactObject;
@optional
- (void) didRotateInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
