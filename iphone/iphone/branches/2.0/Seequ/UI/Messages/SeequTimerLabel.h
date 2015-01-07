//
//  SeequTimerLabel.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 3/14/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeequTimerLabel : UILabel

/*Time format wish to display in label*/
@property (nonatomic,copy) NSString *timeFormat;
/*is The Timer Running?*/
@property (assign,readonly) BOOL isStarted;

-(void)start;
#if NS_BLOCKS_AVAILABLE
-(void)startWithEndingBlock:(void(^)(NSTimeInterval countTime))end; //use it if you are not going to use delegate
#endif
-(void)pause;
-(void)reset;

/*--------Setter methods*/
-(void)setStopWatchTime:(NSTimeInterval)time;
@end
