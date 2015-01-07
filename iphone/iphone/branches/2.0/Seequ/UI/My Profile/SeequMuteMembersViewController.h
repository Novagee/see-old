//
//  SeequMuteMembersViewController.h
//  ProTime
//
//  Created by Grigori Jlavyan on 7/2/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactStorage.h"

@interface SeequMuteMembersViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,NSFetchedResultsControllerDelegate>
- (id)initWithFrame:(CGRect)frame;

@end
