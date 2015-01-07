//
//  SeequDTViewController.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 8/4/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequDTViewController.h"
#import "VideoPlayerViewController.h"
#import "Common.h"
#import "MessageCoreDataManager.h"

@interface SeequDTViewController()<VideoPlayerViewControllerDelegate>
@property (nonatomic, retain) VideoPlayerViewController *responseVC;
@property (nonatomic, retain) VideoPlayerViewController *sourceVC;
@property (nonatomic,retain) NSString*  sourceMessageId;
@property (nonatomic,retain) NSString*  responseMessageId;

@end

@implementation SeequDTViewController

@synthesize responseVC = _responseVC;
@synthesize sourceVC = _sourceVC;
@synthesize message = _message;
@synthesize sourceMessageId =  _sourceMessageId;
@synthesize responseMessageId = _responseMessageId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) didFinishPlaying {
    [self dismissViewControllerAnimated:YES completion:^{
        [[MessageCoreDataManager sharedManager] deleteMessageWithMessageId:_responseMessageId];
        [[MessageCoreDataManager sharedManager] deleteMessageWithMessageId:_sourceMessageId];
        NSString*  folder = [Common makeDTFolder];
        NSString *responsePath  = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_video.mp4",self.responseMessageId]];
        NSString *sourcePath  = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_video.mp4",self.sourceMessageId]];
        NSError *error;

        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:responsePath error:&error];
        NSLog(@"success = %d",success);
        success = [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:&error];
        NSLog(@"success = %d",success);

    }];
}

-(NSString*) getMessageId:(NSString*)str {
    NSRange range = [str rangeOfString:@"_msgId" options:NSBackwardsSearch];
    
    NSAssert(range.location != NSNotFound, @"must  be  found at least 1  slash");
    NSString* subString = [str substringFromIndex:range.location + 1];
    range = [subString rangeOfString:@".mp4" options:NSBackwardsSearch];
    subString =[subString substringToIndex:range.location];
    
    return subString;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSAssert( _message.url,  @"url must be initialized" );
    NSAssert(_message.dt_url,  @"dt_url must be initialized" );
    self.responseMessageId = [self getMessageId:_message.url];
    self.sourceMessageId = [self getMessageId:_message.dt_url];
    
    NSString*  folder = [Common makeDTFolder];
    NSString *responsePath  = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_video.mp4",self.responseMessageId]];
    VideoPlayerViewController *player = [[VideoPlayerViewController alloc] init];
    player.URL = [NSURL fileURLWithPath:responsePath ];
    player.view.frame = self.view.frame;
    [self.view addSubview:player.view];
    self.responseVC = player;
    player.videoDelegate =self;

    
    // my video player
    VideoPlayerViewController *player1 = [[VideoPlayerViewController alloc] init];
    NSString *sourcePath  = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_video.mp4",self.sourceMessageId]];
    player1.URL =  [NSURL fileURLWithPath:sourcePath ] ;
    player1.view.frame = CGRectMake(self.view.frame.size.width - 150, 50, 100, 100);
    [self.view addSubview:player1.view];
    self.sourceVC = player1;

}

-(void) viewWillLayoutSubviews {
    self.responseVC.view.frame = self.view.bounds;
    NSLog(@"%@", NSStringFromCGRect(self.view.bounds));
    CGRect r =  CGRectMake(self.view.bounds.size.width - 150, 50, 100, 100);
    NSLog(@"%@", NSStringFromCGRect(r));
    self.sourceVC.view.frame = r;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
