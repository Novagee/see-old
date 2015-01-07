
//
//  ActivityStorage.h
//  ProTime
//
//  Created by Grigori Jlavyan on 6/14/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactObject.h"
#import "CallLogInfoCoreData.h"
#import "RequestsInfoCoreData.h"
#import "UserInfoCoreData.h"
#import "CoreDataManager.h"
#import "ActivityCoreData.h"

#define CallLogs @"callLog"
#define Requests  @"request"

@interface ActivityStorage : CoreDataManager

-(void)insertRequests:(NSMutableArray *)requestsArray;
-(void)insertCallLog:(NSArray*)callsArray;
-(NSArray*)getCallLogFromStorage:(NSString*)query;
-(ActivityCoreData*)getRequestFromStorageById:(int)requestId;
-(ActivityCoreData*)getCallLogFromStorageByStartTime:(double)startTime;
-(void)deleteActivityFromStorage;
-(void)updateRequestWithDictionary:(NSDictionary*)requestsInfoDict;
+(ActivityStorage *)sharedInstance;
+(ContactObject*)contactObjectFromActivityStorage:(ActivityCoreData*)object;
-(double)getLastRequestTime;
-(double)getLastCallTime;
-(int)activityCountWithPredicate:(NSString*)stringPredicate withEntityName:(NSString*)entityName;
-(void)insertCallLogInfoFromDictionary:(NSDictionary*)dict;
-(int)getMissedRequestCount;
-(int)getMissedCallCount;
-(void)updateCallsStatus;
@end
