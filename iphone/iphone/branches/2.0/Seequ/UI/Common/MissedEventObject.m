//
//  MissedEventObject.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/28/11.
//  Copyright (c) 2011 BeInteractive. All rights reserved.
//

#import "MissedEventObject.h"

@implementation MissedEventObject

@synthesize missedAudio;
@synthesize missedVideo;
@synthesize missedDiscussion;
@synthesize missedInvoice;
@synthesize missedInfo;

- (id) init {
    self = [super init];
    if (self) {
        [self clear];
    }
    
    return self;
}

- (void) clear {
    self.missedAudio = 0;
    self.missedVideo = 0;
    self.missedDiscussion = 0;
    self.missedInfo = 0;
    self.missedInvoice = 0;
}

@end
