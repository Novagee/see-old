//
//  RequestsInfoCoreData.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 8/1/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RequestsInfoCoreData : NSManagedObject

@property (nonatomic, retain) NSNumber * requestId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * type;

@end
