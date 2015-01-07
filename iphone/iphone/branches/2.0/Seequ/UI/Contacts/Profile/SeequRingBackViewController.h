//
//  SeequRingBackViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/11/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"

@interface SeequRingBackViewController : UIViewController <UIActionSheetDelegate> {
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, strong) ContactObject *contactObj;
@property (nonatomic, assign) int videoViewState;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewContent;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textViewDescription;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewTextBG;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (IBAction)onButtonCancel:(id)sender;
- (IBAction)onButtonSend:(id)sender;
- (void) SendRingback;
- (void) HideLoadingView;
- (void) SendXMPPMessageForRefresh;

@end