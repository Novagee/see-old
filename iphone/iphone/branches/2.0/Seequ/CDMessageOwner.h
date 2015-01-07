//
//  CDMessageOwner.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 6/18/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDGroup, CDMessage, UserInfoCoreData;

@interface CDMessageOwner : NSManagedObject

@property (nonatomic, retain) NSNumber * isGroup;
@property (nonatomic, retain) NSDate * lastDate;
@property (nonatomic, retain) NSString * lastMessage;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * seequId;
@property (nonatomic, retain) CDGroup *groupInfo;
@property (nonatomic, retain) NSSet *messages;
@property (nonatomic, retain) UserInfoCoreData *userInfo;
@end

@interface CDMessageOwner (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(CDMessage *)value;
- (void)removeMessagesObject:(CDMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
