//
//  SeequBadgesViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/2/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SeequBadgesViewControllerDelegate;

@interface SeequBadgesViewController : UIViewController {
//    id<SeequBadgesViewControllerDelegate> __weak _delegate;

    NSMutableArray *arrayBadgesText;
    NSMutableArray *arrayWorking;

    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, assign) int videoViewState;

@property (nonatomic, assign) id<SeequBadgesViewControllerDelegate> delegate;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *MyTableView;
@property (nonatomic, strong) NSMutableArray *arrayBadges;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonSave;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (IBAction) onButtonCancel:(id)sender;
- (IBAction) onButtonSave:(id)sender;

- (BOOL) isHaveBadge:(NSString*)badg;
- (void) AddBadgToArray:(NSString*)badg;
- (void) DeleteBadgFromArray:(NSString*)badg;
- (void) SelectAll;
- (void) DeselectAll;
- (NSString*) MakeValidImageName:(NSString*)name;

@end

@protocol SeequBadgesViewControllerDelegate <NSObject>

@optional

- (void) didSaveBadges:(SeequBadgesViewController*)sortViewController withBadgesArray:(NSMutableArray*)array;

@end