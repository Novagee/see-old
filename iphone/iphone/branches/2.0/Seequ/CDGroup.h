//
//  CDGroup.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 7/10/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserInfoCoreData;

@interface CDGroup : NSManagedObject

@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSSet *groupMembers;
@property (nonatomic, retain) UserInfoCoreData *groupOwner;
@end

@interface CDGroup (CoreDataGeneratedAccessors)

- (void)addGroupMembersObject:(UserInfoCoreData *)value;
- (void)removeGroupMembersObject:(UserInfoCoreData *)value;
- (void)addGroupMembers:(NSSet *)values;
- (void)removeGroupMembers:(NSSet *)values;

@end
