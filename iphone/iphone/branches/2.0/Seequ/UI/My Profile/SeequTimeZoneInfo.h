//
//  SeequTimeZoneInfo.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 12/24/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SeequTimeZoneInfo : NSObject
@property  (nonatomic,retain)NSString* key;
@property  (nonatomic,retain)NSString* value;
@property (nonatomic,retain) NSString*  city;


+(NSArray*) getAllTimeZones;

+(int) getTimeZoneNumber:(NSString*) value;
+(NSString*) getTimeZoneValue:(int) number;

@end
