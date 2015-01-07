//
//  IncomingCallingView.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 11/8/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "IncomingCallingView.h"

@implementation IncomingCallingView

@synthesize delegate = _delegate;

#define RETINA_DIFF 41;

- (id) initWithContactObject:(ContactObject*)contactObject Video:(BOOL)video {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 568)];
    
    if (self) {
        // Initialization code
        
        UIImageView *imageViewBG;
        diff_retina = 0;
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            diff_retina = RETINA_DIFF;
            imageViewBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 321, 568)];
            if (video) {
                [imageViewBG setImage:[UIImage imageNamed:@"seequIncomingVideoCallBg568.png"]];
            } else {
                [imageViewBG setImage:[UIImage imageNamed:@"seequIncomingAudioCallBg568.png"]];
            }
        } else {
            imageViewBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 321, 480)];
            if (video) {
                [imageViewBG setImage:[UIImage imageNamed:@"seequIncomingVideoCallBg.png"]];
            } else {
                [imageViewBG setImage:[UIImage imageNamed:@"seequIncomingAudioCallBg.png"]];
            }
        }

        [self addSubview:imageViewBG];
        
        if (video) {
            UIButton *buttonAnswerWithCamera = [[UIButton alloc] init];
            buttonAnswerWithCamera.frame = CGRectMake(23.5, 188 + diff_retina, 273, 41);
            [buttonAnswerWithCamera setBackgroundImage:[UIImage imageNamed:@"seequAnswerWithCameraCall.png"]
                                              forState:UIControlStateNormal];
            [buttonAnswerWithCamera addTarget:self
                                       action:@selector(onButtonAnswerWithCamera:)
                             forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:buttonAnswerWithCamera];
            
            UIButton *buttonAnswerWithVoiceOnly = [[UIButton alloc] init];
            buttonAnswerWithVoiceOnly.frame = CGRectMake(23.5, 237 + diff_retina, 273, 41);
            [buttonAnswerWithVoiceOnly setBackgroundImage:[UIImage imageNamed:@"seequAnswerWithVoiceOnlyCall.png"]
                                                 forState:UIControlStateNormal];
            [buttonAnswerWithVoiceOnly addTarget:self
                                          action:@selector(onButtonAnswerWithVoiceOnly:)
                                forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:buttonAnswerWithVoiceOnly];
        } else {
            UIButton *buttonAnswer = [[UIButton alloc] init];
            buttonAnswer.frame = CGRectMake(23.5, 212 + diff_retina, 273, 41);
            [buttonAnswer setBackgroundImage:[UIImage imageNamed:@"seequAnswerCall.png"]
                                    forState:UIControlStateNormal];
            [buttonAnswer addTarget:self
                             action:@selector(onButtonAnswer:)
                   forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:buttonAnswer];
        }
        
        UIButton *buttonReplyWithMessage = [[UIButton alloc] init];
        if (video) {
            buttonReplyWithMessage.frame = CGRectMake(23.5, 285 + diff_retina, 273, 41);
        } else {
            buttonReplyWithMessage.frame = CGRectMake(23.5, 260 + diff_retina, 273, 41);
        }
        [buttonReplyWithMessage setBackgroundImage:[UIImage imageNamed:@"seequReplyWithMessageCall.png"]
                                          forState:UIControlStateNormal];
        [buttonReplyWithMessage addTarget:self
                                   action:@selector(onButtonReplyWithMessage:)
                         forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:buttonReplyWithMessage];
        
        
        UIButton *buttonDecline = [[UIButton alloc] init];
        if (video) {
            buttonDecline.frame = CGRectMake(23.5, 335 + diff_retina, 273, 41);
        } else {
            buttonDecline.frame = CGRectMake(23.5, 310 + diff_retina, 273, 41);
        }
        [buttonDecline setBackgroundImage:[UIImage imageNamed:@"seequDeclineCall.png"]
                                 forState:UIControlStateNormal];
        [buttonDecline addTarget:self
                          action:@selector(onButtonDeclineCall:)
                forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:buttonDecline];
        
        
        int diff_y = 0;
        
        if (!video) {
            diff_y = 22;
        }
        
        int diff_x = 30;
        
        UILabel *labelDisplayName = [[UILabel alloc] initWithFrame:CGRectMake(66 + diff_x, 114 + diff_y + diff_retina, 210, 21)];
        [labelDisplayName setBackgroundColor:[UIColor clearColor]];
        [labelDisplayName setTextColor:[UIColor blackColor]];
        [labelDisplayName setTextAlignment:NSTextAlignmentLeft];
        [labelDisplayName setFont:[UIFont boldSystemFontOfSize:17.0]];
        [self addSubview:labelDisplayName];
        
        if (contactObject.FirstName && contactObject.LastName) {
            [labelDisplayName setText:[NSString stringWithFormat:@"%@ %@", contactObject.FirstName, contactObject.LastName]];
            
            UIView *viewImageBG = [[UIView alloc] initWithFrame:CGRectMake(7 + diff_x, 117 + diff_y + diff_retina, 48, 48)];
            [viewImageBG setBackgroundColor:[UIColor whiteColor]];
            [self addSubview:viewImageBG];
            
            UIImageView *imageViewProfile = [[UIImageView alloc] initWithFrame:CGRectMake(9 + diff_x, 119 + diff_y + diff_retina, 44, 44)];
            imageViewProfile.image = contactObject.image;
            [self addSubview:imageViewProfile];
            
//            UIImageView *imageViewMasterBadge = [[UIImageView alloc] initWithFrame:CGRectMake(252, 117 + diff_y + diff_retina, 48, 13)];
//            NSString *imageName = [NSString stringWithFormat:@"ProfileBadgeStatus%@.png", contactObject.badgeStatus];
//            [imageViewMasterBadge setImage:[UIImage imageNamed:imageName]];
//            [self addSubview:imageViewMasterBadge];
            
            UILabel *labelSpecialist = [[UILabel alloc] initWithFrame:CGRectMake(66 + diff_x, 133 + diff_y + diff_retina, 210, 21)];
            [labelSpecialist setBackgroundColor:[UIColor clearColor]];
            [labelSpecialist setTextColor:[UIColor blackColor]];
            [labelSpecialist setFont:[UIFont systemFontOfSize:12.0]];
            [labelSpecialist setText:contactObject.specialist];
            [self addSubview:labelSpecialist];
            
//            UILabel *labelCompany = [[UILabel alloc] initWithFrame:CGRectMake(66, 150 + diff_y + diff_retina, 229, 21)];
//            [labelCompany setBackgroundColor:[UIColor clearColor]];
//            [labelCompany setTextColor:[UIColor blackColor]];
//            [labelCompany setFont:[UIFont systemFontOfSize:12.0]];
//            [labelCompany setText:contactObject.company];
//            [self addSubview:labelCompany];
            
//            [self setRatingStars:ceilf(contactObject.ratingValue) Video:video];
        } else {
            if (contactObject.FirstName) {
                [labelDisplayName setTextAlignment:NSTextAlignmentCenter];
                labelDisplayName.frame = CGRectMake(10, 114 + diff_y + diff_retina, 300, 21);
                [labelDisplayName setText:contactObject.FirstName];
            }
        }
    }
    
    return self;
}

- (void) setRatingStars:(int)stars  Video:(BOOL)video {
    for (int i = 0; i < stars; i++) {
        UIImageView *starImageView;
        if (video) {
            starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(276 - (stars*10)/2 + i * 10, 137 + diff_retina, 10, 9)];
        } else {
            starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(276 - (stars*10)/2 + i * 10, 157 + diff_retina, 10, 9)];
            
        }
        starImageView.image = [UIImage imageNamed:@"contactRatingStar.png"];
        
        [self addSubview:starImageView];
    }
}

- (void) onButtonAnswerWithCamera:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOnAnswerWithCamera)]) {
		[_delegate didClickOnAnswerWithCamera];
	}
}

- (void) onButtonAnswerWithVoiceOnly:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOnAnswerWithVoiceOnly)]) {
		[_delegate didClickOnAnswerWithVoiceOnly];
	}
}

- (void) onButtonAnswer:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOnAnswer)]) {
		[_delegate didClickOnAnswer];
	}
}

- (void) onButtonReplyWithMessage:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOnReplyWithMessage)]) {
		[_delegate didClickOnReplyWithMessage];
	}
}

- (void) onButtonDeclineCall:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickOnDeclineCall)]) {
		[_delegate didClickOnDeclineCall];
	}
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan");
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
