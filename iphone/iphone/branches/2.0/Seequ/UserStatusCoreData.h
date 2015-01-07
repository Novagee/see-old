//
//  UserStatusCoreData.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 6/17/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserStatusCoreData : NSManagedObject

@property (nonatomic, retain) NSNumber * isOnline;
@property (nonatomic, retain) NSString * subscription;

@end
