//
//  SeequRecordVideoEditor.m
//  ProTime
//
//  Created by Grigori Jlavyan on 4/25/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "SeequRecordVideoEditor.h"
#define VIEWSIZE 54
#define INSET 2
@interface SeequRecordVideoEditor()<UIGestureRecognizerDelegate>{
    UIImageView * videoImage;
    UITapGestureRecognizer *tapGesture;
    UIActivityIndicatorView *indicator;
}
@end
@implementation SeequRecordVideoEditor
- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, VIEWSIZE, VIEWSIZE)];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];
        tapGesture.delegate=self;
        videoImage=[[UIImageView alloc] initWithFrame:CGRectMake(INSET, INSET, VIEWSIZE-2*INSET, VIEWSIZE-2*INSET)];
        tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handeleTap)];
        videoImage.userInteractionEnabled=YES;
        [videoImage addGestureRecognizer:tapGesture];
        videoImage.backgroundColor=[UIColor lightGrayColor];
        videoImage.contentMode = UIViewContentModeScaleAspectFill;
        videoImage.clipsToBounds = YES;
        [self addSubview:videoImage];
        indicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.hidesWhenStopped=YES;
        indicator.frame=CGRectMake(0, 0,2*INSET,2*INSET);
        indicator.center=videoImage.center;
        indicator.hidden=YES;
        [self addSubview:indicator];
        // Initialization code
    }
    return self;
}
-(void)setPhotoImage:(UIImage*)image{
    videoImage.image=image;
}
-(void)videoImageWithURL:(NSURL*)videoURL{
    indicator.hidden=NO;
    [indicator startAnimating];
    [self performSelectorOnMainThread:@selector(setVideoImage:) withObject:videoURL waitUntilDone:YES];
  
}
-(void)setVideoImage:(NSURL*)videoURL{
    MPMoviePlayerController *theMovie = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    theMovie.shouldAutoplay=NO;
//    UIImage *image=[theMovie thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[theMovie contentURL] options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 2);
    CGImageRef imageRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    
    videoImage.image=image;
    [indicator stopAnimating];
}
-(void)removeVideoImage{
    videoImage.image=nil;
}
-(void)handeleTap{
    [self.delegate videoEditorPressed];
}


@end
