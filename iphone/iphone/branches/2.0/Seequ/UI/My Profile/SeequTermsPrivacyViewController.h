//
//  SeequTermsPrivacyViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/6/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum TermsPrivacy_Type {
	TermsPrivacy_Type_Terms,
    TermsPrivacy_Type_Privacy,
    TermsPrivacy_Type_Use
}
TermsPrivacy_Type;

@interface SeequTermsPrivacyViewController : UIViewController {
    TermsPrivacy_Type termsPrivacyType;
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}


@property (nonatomic, assign) int videoViewState;
@property (nonatomic, retain) NSString *segmentState;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonTerms;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonPrivacy;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonUse;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;


- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (IBAction)onButtonFilter:(id)sender;

@end
