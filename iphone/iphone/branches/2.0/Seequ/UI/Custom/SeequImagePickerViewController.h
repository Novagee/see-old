//
//  SeequImagePickerViewController.h
//  ProTime
//
//  Created by Grigori Jlavyan on 8/12/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequAssetsViewController.h"
#import "SeequVideoRecorerViewController.h"


@interface SeequImagePickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate >

@property (nonatomic, strong) NSMutableArray *assetGroups;
@property (nonatomic,retain) ALAssetsLibrary *library;
@property (nonatomic,retain) SeequAssetsViewController  *assetsViewController;
@property (nonatomic) int assetsGroupIndex;
@property (nonatomic) int numberOfGroups;
@property (nonatomic) SeequPickerType pickerType;

@end
