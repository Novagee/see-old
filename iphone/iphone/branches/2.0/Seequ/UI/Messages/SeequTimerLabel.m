//
//  SeequTimerLabel.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 3/14/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequTimerLabel.h"
#import "Common.h"

#define kDefaultTimeFormat  @"HH:mm:ss"
#define kDefaultFireIntervalNormal  0.1
#define kDefaultFireIntervalHighUse  0.02
#define kDefaultTimerType MZTimerLabelTypeStopWatch


@interface SeequTimerLabel () {
    NSDate *startCountDate;
    NSDate *zeroDate;

    
}
@property (strong) NSTimer *timer;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@end

@implementation SeequTimerLabel
@synthesize isStarted = _isStarted;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void) setup {
    zeroDate = [NSDate dateWithTimeIntervalSince1970:0];
    self.textColor = [UIColor whiteColor];
    self.textAlignment =NSTextAlignmentCenter;
    self.font = [UIFont systemFontOfSize: 25];
    [self updateLabel];
}

-(void) start{
    if ([self.timeFormat rangeOfString:@"SS"].location != NSNotFound) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:kDefaultFireIntervalHighUse target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    }else{
        _timer = [NSTimer scheduledTimerWithTimeInterval:kDefaultFireIntervalNormal target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    }
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    if(startCountDate == nil){
        startCountDate = [NSDate date];
        
    }
    _isStarted = YES;
    [_timer fire];

}
-(void)pause{
    [_timer invalidate];
    _timer = nil;
    _isStarted = NO;
}

-(void)reset{
    startCountDate = (self.isStarted)? [NSDate date] : nil;
    [self updateLabel];
}
-(void) setStopWatchTime:(NSTimeInterval)time {
    
}
-(void) startWithEndingBlock:(void (^)(NSTimeInterval))end {
    
}

- (NSDateFormatter*)dateFormatter{
    
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        _dateFormatter.dateFormat = self.timeFormat;
    }
    return _dateFormatter;
}
- (NSString*)timeFormat
{
    if ([_timeFormat length] == 0 || _timeFormat == nil) {
        _timeFormat = kDefaultTimeFormat;
    }
    
    return _timeFormat;
}
-(void)updateLabel{
    
    NSTimeInterval timeDiff = [[[NSDate alloc] init] timeIntervalSinceDate:startCountDate];
     NSDate *timeToShow;
        
    if (_isStarted) {
        timeToShow = [zeroDate dateByAddingTimeInterval:timeDiff];
    }else{
        timeToShow = [zeroDate dateByAddingTimeInterval:(!startCountDate)?0:timeDiff];
    }
    
    NSString *strDate = [self.dateFormatter stringFromDate:timeToShow];
    self.text = strDate;
    if (timeDiff >= VIDEO_DURATION) {
        [Common postNotificationWithName:kStopVideoCapturing object:nil];
    }

    
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
