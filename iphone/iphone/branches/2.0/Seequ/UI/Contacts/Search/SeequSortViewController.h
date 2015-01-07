//
//  SeequSortViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/2/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SeequSortViewControllerDelegate;

@interface SeequSortViewController : UIViewController {
//    id<SeequSortViewControllerDelegate> __weak _delegate;

    NSMutableArray *arraySortItems;
    NSIndexPath *indexPathPrevSelected;

    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, assign) int videoViewState;

@property (nonatomic, assign) id<SeequSortViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *sortText;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *MyTableView;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;
- (IBAction) onButtonCancel:(id)sender;

@end

@protocol SeequSortViewControllerDelegate <NSObject>

@optional

- (void) didSelectSortType:(SeequSortViewController*)sortViewController withSortText:(NSString*)text;

@end