//
//  MissedEventObject.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/28/11.
//  Copyright (c) 2011 BeInteractive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MissedEventObject : NSObject {
    int missedAudio;
    int missedVideo;
    int missedDiscussion;
    int missedInvoice;
    int missedInfo;
}

@property (nonatomic, assign) int missedAudio;
@property (nonatomic, assign) int missedVideo;
@property (nonatomic, assign) int missedDiscussion;
@property (nonatomic, assign) int missedInvoice;
@property (nonatomic, assign) int missedInfo;

- (void) clear;

@end
