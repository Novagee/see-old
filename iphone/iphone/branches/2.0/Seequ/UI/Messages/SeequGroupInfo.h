//
//  SeequGroupInfo.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 5/22/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SeequGroupInfo : NSObject

@property (nonatomic,retain) NSString* groupID;
@property (nonatomic,retain) NSString* ownerID;
@property (nonatomic,retain) NSMutableArray* members;
@property (nonatomic,retain) NSString*  name;
-(id) initWithName:(NSString*) name;
@end
