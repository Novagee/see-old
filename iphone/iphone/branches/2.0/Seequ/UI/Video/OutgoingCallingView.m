//
//  CallingView.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/1/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "OutgoingCallingView.h"

@implementation OutgoingCallingView

@synthesize delegate = _delegate;

#define RETINA_DIFF 63;

- (id) initWithContactObject:(ContactObject*)contactObject Video:(BOOL)video {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 568)];
    
    if (self) {
        // Initialization code
        UIImageView *imageViewBG;
        diff_retina = 0;
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            diff_retina = RETINA_DIFF;
            imageViewBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
            [imageViewBG setImage:[UIImage imageNamed:@"seequOutgoingCallBg568.png"]];
        } else {
            imageViewBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
            [imageViewBG setImage:[UIImage imageNamed:@"seequOutgoingCallBg.png"]];
        }
        [self addSubview:imageViewBG];

        UIImageView *imageViewCallIcon = [[UIImageView alloc] initWithFrame:CGRectMake(105, 132 + diff_retina, 33, 24)];
        if (video) {
            [imageViewCallIcon setImage:[UIImage imageNamed:@"seequVideoCallIcon.png"]];
        } else {
            [imageViewCallIcon setImage:[UIImage imageNamed:@"seequAudioCallIcon.png"]];
        }
        [self addSubview:imageViewCallIcon];
        
        labelCallingState = [[UILabel alloc] initWithFrame:CGRectMake(144,  132 + diff_retina, 150, 24)];
        [labelCallingState setBackgroundColor:[UIColor clearColor]];
        [labelCallingState setTextColor:[UIColor whiteColor]];
        [labelCallingState setFont:[UIFont boldSystemFontOfSize:20.0]];
        [labelCallingState setText:@"Calling"];
        [self addSubview:labelCallingState];
        
        UIButton *buttonEnd = [[UIButton alloc] init];
        buttonEnd.frame = CGRectMake(23.5, 252 + diff_retina, 273, 41);
        [buttonEnd setBackgroundImage:[UIImage imageNamed:@"seequEndCall.png"]
                             forState:UIControlStateNormal];
        [buttonEnd addTarget:self
                      action:@selector(onButtonEndCall:)
            forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:buttonEnd];

        int diff_x = 30;

        UIView *viewImageBG = [[UIView alloc] initWithFrame:CGRectMake(7 + diff_x, 180 + diff_retina, 48, 48)];
        [viewImageBG setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:viewImageBG];
        
        UIImageView *imageViewProfile = [[UIImageView alloc] initWithFrame:CGRectMake(9 + diff_x, 182 + diff_retina, 44, 44)];
        imageViewProfile.image = contactObject.image;
        [self addSubview:imageViewProfile];
        
        UILabel *labelDisplayName = [[UILabel alloc] initWithFrame:CGRectMake(66 + diff_x, 177 + diff_retina, 210, 21)];
        [labelDisplayName setBackgroundColor:[UIColor clearColor]];
        [labelDisplayName setTextColor:[UIColor blackColor]];
        [labelDisplayName setFont:[UIFont boldSystemFontOfSize:17.0]];
        [labelDisplayName setText:[NSString stringWithFormat:@"%@ %@", contactObject.FirstName, contactObject.LastName]];
        [self addSubview:labelDisplayName];

        UILabel *labelSpecialist = [[UILabel alloc] initWithFrame:CGRectMake(66 + diff_x, 196 + diff_retina, 210, 21)];
        [labelSpecialist setBackgroundColor:[UIColor clearColor]];
        [labelSpecialist setTextColor:[UIColor blackColor]];
        [labelSpecialist setFont:[UIFont systemFontOfSize:12.0]];
        [labelSpecialist setText:contactObject.specialist];
        [self addSubview:labelSpecialist];

//        UILabel *labelCompany = [[UILabel alloc] initWithFrame:CGRectMake(66, 213 + diff_retina, 229, 21)];
//        [labelCompany setBackgroundColor:[UIColor clearColor]];
//        [labelCompany setTextColor:[UIColor blackColor]];
//        [labelCompany setFont:[UIFont systemFontOfSize:12.0]];
//        [labelCompany setText:contactObject.company];
//        [self addSubview:labelCompany];
        
//        [self setRatingStars:5];
        
//        UIImageView *imageViewMasterBadge = [[UIImageView alloc] initWithFrame:CGRectMake(252, 180 + diff_retina, 48, 13)];
//        [imageViewMasterBadge setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ProfileBadgeStatus%@.png", contactObject.badgeStatus]]];
//        [self addSubview:imageViewMasterBadge];
    }

    return self;
}

- (void) setRatingStars:(int)stars {
    for (int i = 0; i < stars; i++) {
        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(276 - (stars*10)/2 + i * 10, 200 + diff_retina, 10, 9)];
        starImageView.image = [UIImage imageNamed:@"contactRatingStar.png"];
        
        [self addSubview:starImageView];
    }
}

- (void) onButtonEndCall:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOnEndCall)])
	{
		[_delegate didClickOnEndCall];
	}
}

- (void) setCallingStateText:(NSString*)text {
	[UIView beginAnimations:@"animateViewCenter" context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
						   forView:labelCallingState
							 cache:YES];

    labelCallingState.text = text;
    
	[UIView commitAnimations];
}

@end