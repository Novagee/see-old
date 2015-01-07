//
//  LocationCoreData.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 6/17/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocationCoreData : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSNumber * countryId;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * stateAbbrev;
@property (nonatomic, retain) NSNumber * stateId;
@property (nonatomic, retain) NSString * timeZone;

@end
