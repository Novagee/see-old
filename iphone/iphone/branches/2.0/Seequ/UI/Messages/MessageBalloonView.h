//
//  MessageBaloonView.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 11/1/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageBalloonView : UIView

@property (nonatomic,retain) NSString*  text;


- (id)initWithText:(NSString*)message;
@end
