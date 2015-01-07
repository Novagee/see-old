//
//  CoreDataManager.h
//  ProTime
//
//  Created by Grigori Jlavyan on 6/9/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreDataManager : NSObject

+ (NSManagedObjectModel *)managedObjectModel;
+ (NSString *)persistentStoreDirectory;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
+ (NSManagedObjectContext *)managedObjectContext;
+ (NSManagedObjectContext *)managedObjectContextForMainThread;
//@property (nonatomic, strong) NSString *guid;

- (BOOL)saveManagedObjectContext:(NSManagedObjectContext*)_managedObjectContext;
- (NSArray*)fetchWithPredicate:(NSManagedObjectContext*)_managedObjectContext withPredicate:(NSString*)predicateString andEntityName:(NSString*)EntityName;
- (void)deleteEntity:(NSManagedObjectContext*)_managedObjectContext andEntityName:(NSString *)EntityName;
@end
