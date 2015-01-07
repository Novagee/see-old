//
//  ActivityStorage.m
//  ProTime
//
//  Created by Grigori Jlavyan on 1/31/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import "Common.h"
#import "ContactStorage.h"
#import "ActivityStorage.h"




static ActivityStorage *activityStorage=nil;

@implementation ActivityStorage

-(void)insertRequests:(NSMutableArray *)requestsArray{
         NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        [moc lock];
        [moc processPendingChanges];
        @synchronized (self){
                for ( NSDictionary *dict in  requestsArray) {
//                        [moc lock];
                        if (!dict || ![dict isKindOfClass:[NSDictionary class]]){
//                                [moc unlock];
                                continue;
                        }
                        ActivityCoreData * activityData;
                        NSDictionary *profileData=[[NSDictionary alloc] initWithDictionary:[dict objectForKey:@"profileData"]];
                        if(![[ContactStorage sharedInstance] IsUserAvailable:[profileData objectForKey:@"seeQuId"]]){
                        [[ContactStorage sharedInstance] InsertContactFromDictionary:profileData];
                        }
                       NSDictionary * activityDict=[[NSDictionary alloc] initWithDictionary:[dict objectForKey:Requests]];
                        
                        if(activityDict && [activityDict isKindOfClass:[NSDictionary class]]){
                                
                                
                                NSDictionary *typeEnumDict = [activityDict objectForKey:@"typeEnum"];
                                if (!typeEnumDict || ![typeEnumDict isKindOfClass:[NSDictionary class]]) {
//                                        [moc unlock];
                                        continue;
                                }
                                
                                NSDictionary *statusEnumDict = [activityDict objectForKey:@"statusEnum"];
                                if (!statusEnumDict || ![statusEnumDict isKindOfClass:[NSDictionary class]]) {
//                                        [moc unlock];
                                        continue;
                                }
                                activityData=[self getRequestFromStorageById:[[activityDict objectForKey:@"id"]integerValue]];
                                if (!activityData) {
                                      activityData =[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([ActivityCoreData class]) inManagedObjectContext:moc];
                                }
                                
                                activityData.type=@"request";
                                RequestsInfoCoreData* request=[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([RequestsInfoCoreData class]) inManagedObjectContext:moc];
                                activityData.startTime=[NSNumber numberWithDouble:[[activityDict objectForKey:@"date"] doubleValue]/1000];
                                request.requestId=[NSNumber numberWithInt:[[activityDict objectForKey:@"id"]integerValue]];
                                if([[activityDict objectForKey:@"seeQuId"] isEqualToString:[activityDict objectForKey:@"conSeeQuId"]]){
                                        if ([[typeEnumDict objectForKey:@"name"] isEqualToString:@"RINGBACK"]) {
                                                if ([[statusEnumDict objectForKey:@"name"] isEqualToString:@"ACCEPTED"]) {
                                                        request.type=[NSNumber numberWithInt:Contact_Type_Request_Ringback_Accepted];
                                                        request.status=[NSNumber numberWithInt:Request_Status_Ringback_Accepted];
                                                }else if([[statusEnumDict objectForKey:@"name"] isEqualToString:@"IGNORED"]){
                                                        request.type=[NSNumber numberWithInt:Contact_Type_Request_For_Ringback];
                                                        request.status=[NSNumber numberWithInt:Request_Status_For_Ringback];
                                                }else{
                                                        request.type=[NSNumber numberWithInt:Contact_Type_Request_For_Ringback];
                                                        request.status=[NSNumber numberWithInt:Request_Status_Ringback_Declined];
                                                }
                                        }else if([[typeEnumDict objectForKey:@"name"] isEqualToString:@"CONNECTION"]){
                                                if ([[statusEnumDict objectForKey:@"name"] isEqualToString:@"ACCEPTED"]) {
                                                        request.type=[NSNumber numberWithInt:Contact_Type_Request_Accepted];
                                                        request.status=[NSNumber numberWithInt:Request_Status_Connection_Accepted];
                                                }else if([[statusEnumDict objectForKey:@"name"] isEqualToString:@"IGNORED"]){
                                                        request.type=[NSNumber numberWithInt:Contact_Type_Request_For_Connection];
                                                        request.status=[NSNumber numberWithInt:Request_Status_For_Connection];
                                                }else{
                                                        request.type=[NSNumber numberWithInt:Contact_Type_Request_For_Connection];
                                                        request.status=[NSNumber numberWithInt:Request_Status_Connection_Declined];
                                                }
                                        }
                                }else{

                                        if ([[typeEnumDict objectForKey:@"name"] isEqualToString:@"RINGBACK"]) {
                                                if ([[statusEnumDict objectForKey:@"name"] isEqualToString:@"ACCEPTED"]) {
                                                        request.type=[NSNumber numberWithInt:Contact_Type_Request_Ringback_Accepted];
                                                        request.status=[NSNumber numberWithInt:Request_Status_Recived_Ringback_Accepted];
                                                }else if([[statusEnumDict objectForKey:@"name"] isEqualToString:@"DECLINED"]){
                                                        request.type=[NSNumber numberWithInt:Contact_Type_Request_Ringback_Accepted];
                                                        request.status=[NSNumber numberWithInt:Request_Status_Recived_Ringback_Declined];
                                                }else{
                                                        request.type=[NSNumber numberWithInt:Contact_Type_Request_Ringback];
                                                        request.status=[NSNumber numberWithInt:Request_Status_Ringback];
                                                }
                                        }else if([[typeEnumDict objectForKey:@"name"] isEqualToString:@"CONNECTION"]){
                                                if ([[statusEnumDict objectForKey:@"name"] isEqualToString:@"ACCEPTED"]) {
                                                        request.type=[NSNumber numberWithInt:Contact_Type_Request_Accepted];
                                                        request.status=[NSNumber numberWithInt:Request_Status_Recived_Connection_Accepted];
                                                }else if([[statusEnumDict objectForKey:@"name"] isEqualToString:@"DECLINED"]){
                                                        request.type=[NSNumber numberWithInt:Contact_Type_Request_Accepted];
                                                        request.status=[NSNumber numberWithInt:Request_Status_Recived_Connection_Declined];
                                                }else{
                                                        request.type=[NSNumber numberWithInt:Contact_Type_Request_Connection];
                                                        request.status=[NSNumber numberWithInt:Request_Status_Connection];
                                                }
                                        }
                                }
                                activityData.request=request;
                                
                                
                        }
                        UserInfoCoreData *userinfo=[[ContactStorage sharedInstance] getUserInfoBySeequId:[profileData objectForKey:@"seeQuId"]];
                        if (!userinfo) {
                            NSLog(@"JSC - Was %@", userinfo);
                                userinfo=[[ContactStorage sharedInstance] getUserInfoBySeequId:[profileData objectForKey:@"seeQuId"]];
                            NSLog(@"JSC - Now %@", userinfo);
                        }
                        activityData.userInfo=userinfo;
//                        [moc unlock];
                        
                }
              
        }
        [moc unlock];
        if([self saveManagedObjectContext:moc])
                NSLog(@"Successfully saved the context.");
        else
                NSLog(@"Failed to save the context.");
    
}
-(void)insertCallLog:(NSArray*)callsArray{
         NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        [moc lock];
        [moc processPendingChanges];
        @synchronized (self){
                for ( NSDictionary *dict in  callsArray) {
                        
                        if (!dict || ![dict isKindOfClass:[NSDictionary class]]){
                                
                                continue;
                        }
                        
                        ActivityCoreData * activityData;
                        
                        NSDictionary *profileData=[[NSDictionary alloc] initWithDictionary:[dict objectForKey:@"profileData"]];
                        NSDictionary *activityDict = [[NSDictionary alloc]initWithDictionary:[dict objectForKey:CallLogs]];
                        if(![[ContactStorage sharedInstance] IsUserAvailable:[profileData objectForKey:@"seeQuId"]]){
                                [[ContactStorage sharedInstance] InsertContactFromDictionary:profileData];
                        }else{
                                UserInfoCoreData *info=[[ContactStorage sharedInstance] getUserInfoBySeequId:[profileData objectForKey:@"seeQuId"]];
                                if (!info.firstName||!info.lastName) {
                                        [[ContactStorage sharedInstance] InsertContactFromDictionary:profileData];
                                }
                                
                        }
                        if ([activityDict count] && [activityDict isKindOfClass:[NSDictionary class]]){
                                activityData=[self getCallLogFromStorageByStartTime:[[activityDict objectForKey:@"startTime"]doubleValue]/1000];
                                if (!activityData) {
                                        activityData=[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([ActivityCoreData class]) inManagedObjectContext:moc];
                                }
                                activityData.type=@"callLog";
                                CallLogInfoCoreData *call=[NSEntityDescription insertNewObjectForEntityForName:@"CallLogInfoCoreData" inManagedObjectContext:moc];
                                
                                activityData.startTime=[NSNumber numberWithDouble:[[activityDict objectForKey:@"startTime"]doubleValue]/1000];
                                call.endTime=[NSNumber numberWithDouble:[[activityDict objectForKey:@"stopTime"]doubleValue]/1000];
                                call.status=[NSNumber numberWithInt:[[activityDict objectForKey:@"status"]integerValue]];
                                activityData.callLog=call;
                                UserInfoCoreData *userinfo=[[ContactStorage sharedInstance] getUserInfoBySeequId:[profileData objectForKey:@"seeQuId"]];
                                if (!userinfo) {
                                        userinfo=[[ContactStorage sharedInstance] getUserInfoBySeequId:[profileData objectForKey:@"seeQuId"]];
                                }
                                activityData.userInfo=userinfo;
                            NSLog(@"activityData: %@", activityData.userInfo);
                                //                                [moc unlock];
                        }
                }
        }
        [moc unlock];
        if([self saveManagedObjectContext:moc])
                NSLog(@"Successfully saved the context.");
        else
                NSLog(@"Failed to save the context.");
        
                        
}
+(ContactObject*)contactObjectFromActivityStorage:(ActivityCoreData*)object{
//        NSLog(@"seequId-%@",object.userInfo.seeQuId);
        ContactObject *obj=[[ContactObject alloc] initWithSeequID:object.userInfo.seeQuId];

        [ContactStorage UserInfoToContactObject:object.userInfo contactObject:obj];
        if([object.type isEqualToString:CallLogs]){
//                obj.contactType=Contact_Type_Recent;
                obj.isRecent=YES;
                obj.startTime=[object.startTime doubleValue];
                obj.stopTime=[object.callLog.endTime doubleValue];
                obj.status=[object.callLog.status intValue];
        }
        if([object.type isEqualToString:Requests]){
                obj.startTime=[object.startTime doubleValue];
                obj.requestStatus=[object.request.status integerValue];
                obj.contactType=[object.request.type integerValue];
                obj.ID=[object.request.requestId integerValue];
        }
        
        return obj;
}
-(UserInfoCoreData*)existUserInfoInStorage:(NSString*)seequId andProfileData:(NSDictionary*)profileData{
        UserInfoCoreData *userInfo;
        if ([[ContactStorage sharedInstance] IsUserAvailable:[profileData objectForKey:@"seeQuId"]]) {
            userInfo=[[ContactStorage sharedInstance] getUserInfoBySeequId:seequId];
        }else{
            [[ContactStorage sharedInstance] InsertContactFromDictionary:profileData];
            userInfo=[[ContactStorage sharedInstance] getUserInfoBySeequId:seequId];
        }
        
        
        return userInfo;
}

-(double)getLastRequestTime{
        NSFetchRequest* request=[[NSFetchRequest alloc] initWithEntityName:@"ActivityCoreData"];
        NSError* error;
        NSPredicate* predicate=[NSPredicate predicateWithFormat:@"type=='request'"];
        NSSortDescriptor* sortdescription=[[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:NO];
        
        [request setPredicate:predicate];
        [request setSortDescriptors:@[sortdescription]];
        
        NSArray *array=nil;
        @try {
            NSManagedObjectContext *moc=[CoreDataManager managedObjectContext];
            [moc lock];
            array=[moc executeFetchRequest:request error:&error];
            [moc unlock];
        }
        @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
        }
        if (array.count) {
                ActivityCoreData* activity=[array objectAtIndex:0];
                NSLog(@"%f",[activity.startTime doubleValue]);
                return [activity.startTime doubleValue]+1;
        }
        return 0;
        
}
-(double)getLastCallTime{
        NSFetchRequest* request=[[NSFetchRequest alloc] initWithEntityName:@"ActivityCoreData"];
        NSError* error;
        NSPredicate* predicate=[NSPredicate predicateWithFormat:@"type=='callLog'"];
        NSSortDescriptor* sortDescription=[[NSSortDescriptor alloc]initWithKey:@"startTime" ascending:NO];
        [request setSortDescriptors:@[sortDescription]];
        [request setPredicate:predicate];
        NSManagedObjectContext *moc=[CoreDataManager managedObjectContext];
                NSArray *array=nil;
        @try {
            [moc lock];
                array=[ moc executeFetchRequest:request error:&error];
            [moc unlock];

        }
        @catch (NSException *exception) {
                NSLog(@"%@",exception.description);
        }
        if (array.count) {
                ActivityCoreData* activity=[array objectAtIndex:0];
                return [activity.startTime doubleValue]+1;
        }
        return 0;
        
}
-(int)activityCountWithPredicate:(NSString*)stringPredicate withEntityName:(NSString*)entityName{
        NSFetchRequest* fetchRequest=[[NSFetchRequest alloc] initWithEntityName:entityName];
        NSPredicate *predicate=[NSPredicate predicateWithFormat:stringPredicate];
        [fetchRequest setPredicate:predicate];
        NSError *error;
        int count=[[CoreDataManager managedObjectContext] countForFetchRequest:fetchRequest error:&error];
        if (error) {
                NSLog(@"[activityCountWithPredicate] error-%@",error);
                return 0;
        }
        return count;
}

-(NSArray*)getCallLogFromStorage:(NSString*)query{
    NSArray* array;    
    array=[self fetchWithPredicate:[CoreDataManager managedObjectContext] withPredicate:query andEntityName:@"CallLogInfoCoreData"];
    return array;
}

-(ActivityCoreData*)getRequestFromStorageById:(int)requestId{
        NSArray * array;
        NSString * query=[NSString stringWithFormat:@"request.requestId==%d",requestId];
        
        array=[self fetchWithPredicate:[CoreDataManager managedObjectContext] withPredicate:query andEntityName:NSStringFromClass([ActivityCoreData class])];
        if (array.count>0) {
                ActivityCoreData *activity=[array objectAtIndex:0];
                return activity;
        }
        
        return nil;
}

-(ActivityCoreData*)getCallLogFromStorageByStartTime:(double)startTime{
        NSArray * array;
        NSString * query=[NSString stringWithFormat:@"startTime==%@ && type=='callLog' ",[NSNumber numberWithDouble:startTime]];
        
        array=[self fetchWithPredicate:[CoreDataManager managedObjectContext] withPredicate:query andEntityName:NSStringFromClass([ActivityCoreData class])];
        if (array.count>0) {
                ActivityCoreData *activity=[array objectAtIndex:0];
                return activity;
        }
        
        return nil;
}

-(void)deleteActivityFromStorage{
        [self deleteEntity:[CoreDataManager managedObjectContext] andEntityName:NSStringFromClass([ActivityCoreData class])];
}
-(void)updateRequestWithDictionary:(NSDictionary *)requestsInfoDict{
    NSLog(@"JSC - updateRequestWithDictionary: %@", requestsInfoDict);
        NSManagedObjectContext *moc=[CoreDataManager managedObjectContext];
        [moc lock];
        NSString* query=[NSString stringWithFormat:@"userInfo.seeQuId==%@ AND request.type==%@",[requestsInfoDict objectForKey:@"seeQuId"],[requestsInfoDict objectForKey:@"old_type"]];
        NSArray* arrey=[self fetchWithPredicate:moc withPredicate:query andEntityName:NSStringFromClass([ActivityCoreData class])];
        if ([arrey count]>0) {
                for(ActivityCoreData *activity in arrey ){
                        [requestsInfoDict setValue:activity.request.requestId forKey:@"id"];
               activity.request=[self insertRequestsInfoFromDictionary:moc withDict:requestsInfoDict];
                 [self saveManagedObjectContext:moc];
                }
        }else{
                NSLog(@"Activity object not found");
        }
        [moc unlock];
//        for (ActivityCoreData* obj in arrey ) {
//                obj.request.status=[NSNumber numberWithInteger:status];
//        }
       
}
-(void)insertCallLogInfoFromDictionary:(NSDictionary*)dict{
    NSLog(@"JSC - insertCallLogInfoFromDictionary: %@", dict);

        NSManagedObjectContext *moc=[CoreDataManager managedObjectContext];
        [moc lock];
        NSString *query=[NSString stringWithFormat:@"startTime==%@",[dict objectForKey:@"startTime"]];
         NSArray* arrey=[self fetchWithPredicate:moc withPredicate:query andEntityName:NSStringFromClass([ActivityCoreData class])];
        if ([arrey count]>0) {
                ActivityCoreData *activity=[arrey objectAtIndex:0];
                activity.callLog=[self insertCallLogInfo:moc withDict:dict];
                if ([arrey count]>1) {
                        for (int i=1; i<arrey.count; i++) {
                                [moc deleteObject:[arrey objectAtIndex:i]];
                        }
                }
                 [self saveManagedObjectContext:moc];
        }else{
                NSLog(@"Activity object not found");
        }
        [moc unlock];
}
-(CallLogInfoCoreData*)insertCallLogInfo:(NSManagedObjectContext*)moc withDict:(NSDictionary*)dict{
    NSLog(@"JSC - insertCallLogInfo: %@", dict);
    
        CallLogInfoCoreData *call=[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CallLogInfoCoreData class]) inManagedObjectContext:moc];
        call.status=[dict objectForKey:@"status"];
        call.endTime=[NSNumber numberWithDouble:0];
        return call;
}
-(RequestsInfoCoreData*)insertRequestsInfoFromDictionary:(NSManagedObjectContext*)moc  withDict:(NSDictionary*)requestsInfoDict{
    NSLog(@"JSC - insertRequestsInfoFromDictionary: %@", requestsInfoDict);
         RequestsInfoCoreData* request=[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([RequestsInfoCoreData class]) inManagedObjectContext:moc];
        request.status=[requestsInfoDict objectForKey:@"status"];
        request.type=[requestsInfoDict objectForKey:@"type"];
        request.requestId=[requestsInfoDict objectForKey:@"id"];
        return request;
        
}
+(ActivityStorage*)sharedInstance{
        if (activityStorage == nil)
                activityStorage = [[ActivityStorage alloc] init];
        
        return activityStorage;
        
}
-(int)getMissedRequestCount{
        NSManagedObjectContext *moc=[CoreDataManager managedObjectContext];
        NSString *query=[NSString stringWithFormat:@"request.status=%@ OR  request.status=%@",[NSNumber numberWithInt:Request_Status_Connection],[NSNumber numberWithInt:Request_Status_Ringback]];
        NSArray *array=[self fetchWithPredicate:moc withPredicate:query andEntityName:NSStringFromClass([ActivityCoreData class])];
        if ([array count]) {
                return [array count];
        }
        return 0;
}
-(NSArray*)getMissedCalls{
        NSManagedObjectContext *moc=[CoreDataManager managedObjectContext];
        [moc processPendingChanges];
        NSString *query=[NSString stringWithFormat:@"callLog.status=%@ ",[NSNumber numberWithInt:0]];
        NSArray *array=[self fetchWithPredicate:moc withPredicate:query andEntityName:NSStringFromClass([ActivityCoreData class])];
        if ([array count]) {
                return array;
        }
        return nil;
}
-(int)getMissedCallCount{
        NSArray *array=[[NSArray alloc] initWithArray:[self getMissedCalls]];
        return [array count];
}
-(void)updateCallsStatus{
        NSArray *array=[[NSArray alloc] initWithArray:[self getMissedCalls]];
        if ([array count]>0) {
                for (ActivityCoreData *activity in array) {
                        NSDictionary *callDict=[NSDictionary dictionaryWithObjectsAndKeys: activity.startTime,@"startTime",[NSNumber numberWithInt:3],@"status", nil];
                        [[ActivityStorage sharedInstance] insertCallLogInfoFromDictionary:callDict];
                }
        }
        
}

@end
