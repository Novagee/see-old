//
//  SeequAboutViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/4/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeequAboutViewController : UIViewController {
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, assign) int videoViewState;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *version;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (void) GoBack:(id)sender;

@end
