//
//  SeequSettingsViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/4/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeequSettingsViewController : UIViewController {
    NSArray *arrayTexts;
    
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, assign) int videoViewState;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *MyTableView;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelDisplayName;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (void) GoBack:(id)sender;
- (IBAction) switchValueChanged:(id)sender;

@end