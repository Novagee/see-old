//
//  IncomingRequestView.m
//  ProTime
//
//  Created by Norayr on 02/07/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import "IncomingRequestView.h"

@implementation IncomingRequestView

@synthesize delegate = _delegate;
@synthesize contactObject;
@synthesize incomingRequestType;

- (id) initWithContactObject:(ContactObject*)object Message:(NSString*)message Target:(id)target IncomingRequestType:(IncomingRequest_Type)type Small:(BOOL)small {
    if (small) {
        self = [super initWithFrame:CGRectMake(0, 0, 60, 47)];
    } else {
        self = [super initWithFrame:CGRectMake(0, 0, 261, 61)];
    }
    
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor clearColor]];
        self.delegate = target;
        self.contactObject = object;
        self.incomingRequestType = type;

        UIImageView *BgImage;
        if (small) {
            BgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"seequIncomingRequestSmallBg.png"]];
        } else {
            BgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"seequIncomingRequestBg.png"]];
        }
        
        BgImage.frame = self.frame;
        [self addSubview:BgImage];
        
        UIImageView *imageViewImageRamka;
        
        if (small) {
            imageViewImageRamka = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 30, 30)];
        } else {
            imageViewImageRamka = [[UIImageView alloc] initWithFrame:CGRectMake(8, 22, 30, 30)];
        }
        
        [imageViewImageRamka setImage:[UIImage imageNamed:@"seequMyProfileImageBG.png"]];
        [self addSubview:imageViewImageRamka];
        
        UIImageView *imageViewProfile = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 28, 28)];
        [imageViewProfile setImage:self.contactObject.image];
        [imageViewImageRamka addSubview:imageViewProfile];
        
        if (!small) {
            UILabel *labelDisplayName = [[UILabel alloc] initWithFrame:CGRectMake(49, 24, 200, 12)];
            [labelDisplayName setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
            [labelDisplayName setMinimumScaleFactor:14];
            [labelDisplayName setTextColor:[UIColor whiteColor]];
            [labelDisplayName setBackgroundColor:[UIColor clearColor]];
            labelDisplayName.text = [NSString stringWithFormat:@"%@", [self.contactObject displayName]];
            [self addSubview:labelDisplayName];
            
            
            labelMessage = [[UILabel alloc] initWithFrame:CGRectMake(49, 38, 200, 18)];
            [labelMessage setFont:[UIFont fontWithName:@"Helvetica" size:13]];
            [labelMessage setTextColor:[UIColor whiteColor]];
            [labelMessage setBackgroundColor:[UIColor clearColor]];
            labelMessage.text = message;
            [self addSubview:labelMessage];
        }
        
        [self addTarget:self action:@selector(SelfClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void) SelfClick {
    if ([self.delegate respondsToSelector:@selector(didClickOnIncomingRequestView:)]) {
        [self.delegate didClickOnIncomingRequestView:self];
    }
}

@end