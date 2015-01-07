//
//  SeequDropboxTreeTableViewCell.h
//  ProTime
//
//  Created by Grigori Jlavyan on 8/6/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequDropboxTreeItem.h"


@interface SeequDropboxTreeTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *iconButton;
@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) SeequDropboxTreeItem *treeItem;

- (void)setLevel:(NSInteger)pixels;

@end




