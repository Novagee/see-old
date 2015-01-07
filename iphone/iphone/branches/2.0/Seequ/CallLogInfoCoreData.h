//
//  CallLogInfoCoreData.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 6/17/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CallLogInfoCoreData : NSManagedObject

@property (nonatomic, retain) NSNumber * endTime;
@property (nonatomic, retain) NSNumber * status;

@end
