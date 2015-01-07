//
//  ActivityCoreData.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 6/17/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CallLogInfoCoreData, RequestsInfoCoreData, UserInfoCoreData;

@interface ActivityCoreData : NSManagedObject

@property (nonatomic, retain) NSNumber * startTime;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) CallLogInfoCoreData *callLog;
@property (nonatomic, retain) RequestsInfoCoreData *request;
@property (nonatomic, retain) UserInfoCoreData *userInfo;

@end
