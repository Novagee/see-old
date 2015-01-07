//
//  SeequDoubleTakeSettingsViewController.h
//  ProTime
//
//  Created by Grigori Jlavyan on 3/19/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ChatCoreDataStorage.h"
#import "SeequContactsViewController.h"
#import "NavigationBar.h"
#import "Common.h"
@interface SeequDoubleTakeSettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tabelview;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic,strong) NSFetchedResultsController *fetchedController;
@end
