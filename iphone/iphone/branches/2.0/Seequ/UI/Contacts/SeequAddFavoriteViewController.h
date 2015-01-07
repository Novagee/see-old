//
//  SeequAddFavoriteViewController.h
//  ProTime
//
//  Created by Grigori Jlavyan on 5/21/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import "SeequContactsViewController.h"
#import <UIKit/UIKit.h>

@interface SeequAddFavoriteViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIScrollViewDelegate,NSFetchedResultsControllerDelegate>
//@property(nonatomic,retain) NSMutableArray *arrayContacts;
@property(nonatomic,retain) NSFetchedResultsController *fetchedController;
-(id)initWithFrame:(CGRect)frame;
@end
