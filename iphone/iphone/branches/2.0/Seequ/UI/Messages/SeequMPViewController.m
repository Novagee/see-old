//
//  SeequMPViewController.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 2/24/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequMPViewController.h"
#import "Common.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AROverlayViewController.h"
#import "idoubs2AppDelegate.h"

#import <MediaPlayer/MediaPlayer.h>
/*
 // Posted when the scaling mode changes.
 MP_EXTERN NSString *const MPMoviePlayerScalingModeDidChangeNotification;
 
 // Posted when movie playback ends or a user exits playback.
 MP_EXTERN NSString *const MPMoviePlayerPlaybackDidFinishNotification;
 
 MP_EXTERN NSString *const MPMoviePlayerPlaybackDidFinishReasonUserInfoKey NS_AVAILABLE_IOS(3_2); // NSNumber (MPMovieFinishReason)
 
 // Posted when the playback state changes, either programatically or by the user.
 MP_EXTERN NSString *const MPMoviePlayerPlaybackStateDidChangeNotification NS_AVAILABLE_IOS(3_2);
 
 // Posted when the network load state changes.
 MP_EXTERN NSString *const MPMoviePlayerLoadStateDidChangeNotification NS_AVAILABLE_IOS(3_2);
 
 // Posted when the currently playing movie changes.
 MP_EXTERN NSString *const MPMoviePlayerNowPlayingMovieDidChangeNotification NS_AVAILABLE_IOS(3_2);
 
  
 // Posted when the movie player begins or ends playing video via AirPlay.
 MP_EXTERN NSString *const MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification NS_AVAILABLE_IOS(5_0);
 
 // Posted when the ready for display state changes.
 MP_EXTERN NSString *const MPMoviePlayerReadyForDisplayDidChangeNotification NS_AVAILABLE_IOS(6_0);

 */


@interface SeequMPViewController (){
    MPMoviePlayerController* moviePlayerController;
    AROverlayViewController* vc;
    UIActivityIndicatorView* activityIndicator;
    BOOL isStarted;
    UIButton* cancelButton;
}
@end

@implementation SeequMPViewController
@synthesize url =_url;
@synthesize delegate;
@synthesize  isResponse;
@synthesize messageItem;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isStarted = NO;
    }
    return self;
}

-(void) addNotificationObservers{
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoPlayerStateChange) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoPlayerDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVideoPlayerLoadStateChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:moviePlayerController];

}
-(void) onVideoPlayerDidFinish:(NSNotification*) notification {
    MPMoviePlayerController* vmc = (MPMoviePlayerController*)notification.object;
    if (![vmc isEqual:moviePlayerController]) {
        return;
    }
     NSLog(@"video stopped");
    if (self.isResponse) {
        [self dismissViewControllerAnimated:YES completion:^{
            //[idoubs2AppDelegate sharedInstance].isMediaPlayerOn = NO;

            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }];
    } else {
     //   [idoubs2AppDelegate sharedInstance].isMediaPlayerOn = NO;

        [vc  stopRecording];
        [self dismissViewControllerAnimated:YES completion:nil];

    }

}
-(void) onVideoPlayerLoadStateChange:(NSNotification*) notification {
     switch (moviePlayerController.loadState) {
        case    MPMovieLoadStateUnknown:
            NSLog(@"state did MPMovieLoadStateUnknown");
            break;
            
        case    MPMovieLoadStatePlayable:
            NSLog(@"state did MPMovieLoadStatePlayable");
            break;
        case    MPMovieLoadStatePlaythroughOK:
            NSLog(@"state did MPMovieLoadStatePlaythroughOK");
            break;
        case    MPMovieLoadStateStalled:
            NSLog(@"state MPMovieLoadStateStalled");
            break;
                   
        default:
            break;
    }

}
-(void) onVideoPlayerStateChange {
    switch (moviePlayerController.playbackState) {
        case    MPMoviePlaybackStateStopped:
            NSLog(@"state did MPMoviePlaybackStateStopped");
            break;
            
        case    MPMoviePlaybackStatePlaying:
            NSLog(@"state did MPMoviePlaybackStatePlaying");
            dispatch_async(dispatch_get_main_queue(), ^{
                UInt32 doChangeDefaultRoute = 1;
                AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
            });

            if (!isStarted) {
                if (!self.isResponse) {
             //       [vc startRecording];
                    ///@todo  levon check duration of  movie to be  > than  1 sec
                    [vc performSelector:@selector(startRecording) withObject:nil afterDelay:0.0];

                }
                isStarted = YES;
            }
            [activityIndicator stopAnimating];
            break;
        case    MPMoviePlaybackStatePaused:
            NSLog(@"state did MPMoviePlaybackStatePaused");
            [activityIndicator startAnimating];

            break;
        case    MPMoviePlaybackStateInterrupted:
            NSLog(@"state did MPMoviePlaybackStateInterrupted");
            break;
        case    MPMoviePlaybackStateSeekingForward:
            NSLog(@"state did MPMoviePlaybackStateSeekingForward");
            break;
        case    MPMoviePlaybackStateSeekingBackward:
            NSLog(@"state did MPMoviePlaybackStateSeekingBackward");
                
            break;
            
        default:
            break;
    }
}

- (void)setupAudioSession {
    
    static BOOL audioSessionSetup = NO;
    if (audioSessionSetup) {
        return;
    }
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    UInt32 doSetProperty = 1;
    
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
    
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    audioSessionSetup = YES;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNotificationObservers];
	// Do any additional setup after loading the view.
     moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:_url];
    
    [moviePlayerController.view setFrame:self.view.bounds];
    [self.view addSubview:moviePlayerController.view];
    [self setupAudioSession];
    //   moviePlayerController.view.frame =CGRectMake(0, 46, self.view.frame.size.width, self.view.frame.size.height);
    //    moviePlayerController.fullscreen = YES;
    moviePlayerController.scalingMode = MPMovieScalingModeAspectFit;
    moviePlayerController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    moviePlayerController.controlStyle = MPMovieControlStyleNone;///MPMovieControlStyleFullscreen;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[idoubs2AppDelegate sharedInstance].soundService setSpeakerEnabled:1];
    });

    [moviePlayerController play];
    dispatch_async(dispatch_get_main_queue(), ^{
        UInt32 doChangeDefaultRoute = 1;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        NSError *setCategoryError = nil;
        if (![session setCategory:AVAudioSessionCategoryPlayback
                      withOptions:AVAudioSessionCategoryOptionMixWithOthers
                            error:&setCategoryError]) {
            // handle error
        }
        
    });
    if (!isResponse) {
        vc = [[AROverlayViewController alloc] init];
        vc.delegate =self.delegate;
        vc.messageItem = self.messageItem;
        vc.view.frame = CGRectMake(220, 5, 50, 50);
        [moviePlayerController.view addSubview:vc.view];

    }
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:moviePlayerController.view.bounds];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [moviePlayerController.view addSubview: activityIndicator];
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* image = [UIImage imageNamed:@"defaultSeequCancelButton"];
    cancelButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [cancelButton setImage:image forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(closePlayer) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.alpha = 0.6;
    [self.view addSubview:cancelButton];
    [activityIndicator startAnimating];

}

-(void) closePlayer {
    [self dismissViewControllerAnimated:YES completion:^{
    //    [idoubs2AppDelegate sharedInstance].isMediaPlayerOn = NO;

        [moviePlayerController stop];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];

}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    moviePlayerController.view.frame = self.view.bounds;
    NSLog(@"%@",  NSStringFromCGRect(moviePlayerController.view.frame));
    if (!isResponse) {
        vc.view.frame = CGRectMake(moviePlayerController.view.frame.size.width - 100, 5, 50, 50);
    }
    activityIndicator .frame = moviePlayerController.view.bounds;
    cancelButton.frame = CGRectMake(moviePlayerController.view.frame.size.width/2 - cancelButton.frame.size.width/2, moviePlayerController.view.frame.size.height -cancelButton.frame.size.height - 20, cancelButton.frame.size.width, cancelButton.frame.size.height);

}
-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
     if (!isResponse)
         [vc.captureManager updateOrientation];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
