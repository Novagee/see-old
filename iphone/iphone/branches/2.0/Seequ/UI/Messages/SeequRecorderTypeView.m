//
//  SeequRecorderTypeVIew.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 7/2/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequRecorderTypeView.h"

@interface SeequRecorderTypeView (){
    SeequRecorderType state;
    NSArray* labels;
}

@end

@implementation SeequRecorderTypeView


-(id) initWithFrame:(CGRect)frame state:(SeequRecorderType)type {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *labelPhoto=[[UILabel alloc] initWithFrame:CGRectMake(100, 10, 40, 20)];
        labelPhoto.text=@"Photo";
        labelPhoto.font=[UIFont fontWithName:@"Helvetica Neue" size:12];
        labelPhoto.textColor=[UIColor yellowColor];
        labelPhoto.textAlignment = NSTextAlignmentCenter;

        UILabel* labelVideo=[[UILabel alloc] initWithFrame:CGRectMake(140, 10, 40, 20)];
        labelVideo.text=@"Video";
        labelVideo.font=[UIFont fontWithName:@"Helvetica Neue" size:12];
        labelVideo.textColor=[UIColor whiteColor];
        labelVideo.textAlignment = NSTextAlignmentCenter;
        
        UILabel* labelDoubleTake=[[UILabel alloc] initWithFrame:CGRectMake(180, 10, 80, 20)];
        labelDoubleTake.text=@"Double Take";
        labelDoubleTake.font=[UIFont fontWithName:@"Helvetica Neue" size:12];
        labelDoubleTake.textColor=[UIColor whiteColor];
        labelDoubleTake.textAlignment = NSTextAlignmentCenter;
        if (type != SeequRecorderTypeNone) {
            labels = [NSArray arrayWithObjects:labelPhoto,labelVideo,labelDoubleTake, nil];
        } else {
            labels = [NSArray arrayWithObjects:labelPhoto,labelVideo, nil];
            type = SeequRecorderTypePhoto;
        }

        for (UILabel* lab in labels) {
            [self addSubview:lab];
        }

        [self setupSwipeRecognizers];
        state = type;
        [self updateState:NO];
    }
    return self;
}

- (void) setupSwipeRecognizers {
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipeGesture:)];
    [leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:leftSwipeRecognizer];
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipeGesture:)];
    [rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:rightSwipeRecognizer];
}
- (void)handleRightSwipeGesture:(UISwipeGestureRecognizer *)recognizer{
  
    if ( state  == SeequRecorderTypePhoto) {
        return;
    }
    state--;
    [self updateState:YES];
    [self performSelector:@selector(notifyScroller) withObject:nil afterDelay:0.35];
}
- (void) handleLeftSwipeGesture:(UISwipeGestureRecognizer *)recognizer{
    
    if ( state == [labels count] ) {
        return;
    }
    state++;
    [self updateState:YES];
    [self performSelector:@selector(notifyScroller) withObject:nil afterDelay:0.35];
    
    
}

-(void) notifyScroller{
    [self.delegate didChangeToState:state];
}
-(void) swipeLeft {
    [self handleLeftSwipeGesture:nil];
}

-(void) swipeRight {
    [self handleRightSwipeGesture:nil];
}

-(void) updateState:(BOOL) flag {
    int i =(int)state -1;
    UILabel* lab = [labels objectAtIndex:i];
  
    
    int diff = self.bounds.size.width/2 - lab.center.x;
    //    labelPhoto.frame=CGRectMake(labelPhoto.frame.origin.x+labelPhoto.frame.size.width + diff, labelPhoto.frame.origin.y, labelPhoto.frame.size.width, labelPhoto.frame.size.height);
    //    labelVideo.frame=CGRectMake(labelVideo.frame.origin.x+labelVideo.frame.size.width + diff, labelVideo.frame.origin.y, labelVideo.frame.size.width, labelVideo.frame.size.height);
    int index = 0;
    if (flag) {
        [UIView beginAnimations:@"swipe" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        for (UILabel* lab in labels) {
            lab.frame=CGRectMake(lab.frame.origin.x + diff, lab.frame.origin.y, lab.frame.size.width, lab.frame.size.height);
            if(index == i) {
                lab.textColor=[UIColor yellowColor];
                lab.alpha = 1.;
            } else {
                lab.textColor=[UIColor whiteColor];
                lab.alpha = .8;
            }
            index++;
        }
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        //    label2.layer.transform=CATransform3DMakeTranslation(1, 1, -10);
        [UIView commitAnimations];

    } else {
        for (UILabel* lab in labels) {
            lab.frame=CGRectMake(lab.frame.origin.x + diff, lab.frame.origin.y, lab.frame.size.width, lab.frame.size.height);
            if(index == i) {
                lab.textColor=[UIColor yellowColor];
                lab.alpha = 1.;
            } else {
                lab.textColor=[UIColor whiteColor];
                lab.alpha = .8;
            }
            index++;
        }

    }
 
 
}


@end
