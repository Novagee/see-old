//
//  SeequTimeZoneViewController.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 12/18/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SeequTimeZoneViewControllerDelegate <NSObject>

-(void) didSelectTimeZone:(NSString*) timeZone ;

@end
@interface SeequTimeZoneViewController : UITableViewController  
{
    
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;

}
@property(nonatomic,assign) id<SeequTimeZoneViewControllerDelegate> timeZoneDelegate;
@property (nonatomic, assign) int videoViewState;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

@end


