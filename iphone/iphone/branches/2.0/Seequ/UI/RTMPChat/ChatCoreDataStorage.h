//
//  ChatCoreDataStorage.h
//  testCoreData
//
//  Created by Macbook on 11/14/13.
//  Copyright (c) 2013 Macbook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ChatCoreDataStorage : NSObject
{
	NSManagedObjectModel *managedObjectModel;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectContext *managedObjectContext;
}

@property (weak, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (weak, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (weak, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (void) addOrUpdateUsersList: (NSArray*)usersList;
- (void) addUser: (NSDictionary*)userDict;
- (void) updateUser: (NSDictionary*)userDict;
- (void) removeUser: (NSDictionary*)userDict;
- (BOOL) isUserAvailable:(NSString*)name;
- (int)  isUserOnLine:(NSString*)name;
- (NSString*) GetUserSubscription:(NSString*)name;
- (BOOL) SetNeedToDoubleTake: (NSString*)name needToDoubleTake:(BOOL)n2dt;
- (BOOL) GetNeedToDoubleTake: (NSString*)name;
- (NSManagedObjectContext *)managedObjectContext;
+ (ChatCoreDataStorage*) sharedInstance;
@end
