//
//  ChatCoreDataStorage.m
//  testCoreData
//
//  Created by Macbook on 11/14/13.
//  Copyright (c) 2013 Macbook. All rights reserved.
//

#import "ChatCoreDataStorage.h"
#import "UserCoreDataStorage.h"
static ChatCoreDataStorage *chatCoreDataStorage=nil;
@implementation ChatCoreDataStorage

@dynamic managedObjectModel;
@dynamic persistentStoreCoordinator;
@dynamic managedObjectContext;

- (id)init{

    self = [super init];
    if(self)
    {
    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UsersCoreDataStorage" inManagedObjectContext:[self managedObjectContext]];
//    self->userList = [[UsersCoreDataStorage alloc] initWithEntity:entity insertIntoManagedObjectContext:[self managedObjectContext]];
    }
    return self;
}

- (NSString *)persistentStoreDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    
    NSBundle *bundle = [NSBundle mainBundle];
    
	// Attempt to find a name for this application
	NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	if (appName == nil) {
		appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
	}
    
    if (appName == nil) {
        appName = @"chatframework";
    }
    
    NSString *result = [basePath stringByAppendingPathComponent:appName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if(![fileManager fileExistsAtPath:result])
	{
		[fileManager createDirectoryAtPath:result withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
    return result;
}

- (NSManagedObjectModel *)managedObjectModel
{
	if (managedObjectModel)
	{
		return managedObjectModel;
	}
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"ChatUsers" ofType:@"momd"];
	if (path)
	{
		// If path is nil, then NSURL or NSManagedObjectModel will throw an exception
		
		NSURL *url = [NSURL fileURLWithPath:path];
		
		managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
	}
	
	return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (persistentStoreCoordinator)
	{
		return persistentStoreCoordinator;
	}
	
	NSManagedObjectModel *mom = [self managedObjectModel];
	
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
	
	NSString *docsPath = [self persistentStoreDirectory];
	NSString *storePath = [docsPath stringByAppendingPathComponent:@"ChatUsers.sqlite"];
	if (storePath)
	{
        NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
        NSPersistentStore *persistentStore;
        NSError *error = nil;
//		if ([[NSFileManager defaultManager] fileExistsAtPath:storePath])
//		{
//			[[NSFileManager defaultManager] removeItemAtPath:storePath error:nil];
//		}

        // If storePath is nil, then NSURL will throw an exception
        persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
		                                                           configuration:nil
                                                                             URL:storeUrl
                                                                         options:nil
                                                                           error:&error];
		if(!persistentStore)
		{
			NSLog(@"=====================================================================================");
			NSLog(@"Error creating persistent store:\n%@", error);
#if TARGET_OS_IPHONE
			NSLog(@"Chaned core data model recently? Quick Fix: Delete the app from device and reinstall.");
#else
			NSLog(@"Quick Fix: Delete the database: %@", storePath);
#endif
			NSLog(@"=====================================================================================");
		}
	}
    
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
	if (managedObjectContext)
	{
		return managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator)
	{
		managedObjectContext = [[NSManagedObjectContext alloc] init];
		[managedObjectContext setPersistentStoreCoordinator:coordinator];
	}
	
	return managedObjectContext;
}

- (void)addOrUpdateUsersList: (NSArray*)usersList{
    
    UserCoreDataStorage* usr = nil;
    if(!usersList.count)
        return;
    
    NSMutableArray* tmpArray = [[NSMutableArray alloc] initWithArray:usersList];
    for (int index = 0; index < tmpArray.count; index++) {
        NSDictionary *rDict = [tmpArray objectAtIndex:index];
        
        NSString* subscription = [rDict objectForKey:@"subscription"];
        
        usr = [UserCoreDataStorage getUserFromManagedObjectContext:[self managedObjectContext] withUserInfo:rDict];
        if(usr)
        {
            if([subscription isEqualToString:@"remove"] ) {
                NSLog(@"[Contacts][Remove] name - %@", [rDict objectForKey:@"name"]);
                [self removeUser:rDict];
            } else {
                NSLog(@"[Contacts][Update] name - %@", [rDict objectForKey:@"name"]);
                [self updateUserData:(UserCoreDataStorage*)usr userDict:rDict];
            }
        }
        else
        {
            if(![subscription isEqualToString:@"remove"] ) {
                NSLog(@"[Contacts][Insert] from:%@, name:%@", [rDict objectForKey:@"from"], [rDict objectForKey:@"name"]);
                [UserCoreDataStorage insertInManagedObjectContext:[self managedObjectContext] withUserInfo:rDict];
            }
        }
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
		NSLog(@"%s ERROR: %@", __PRETTY_FUNCTION__,error);
	}
}

- (void)addUser: (NSDictionary*)userDict {
    
    UserCoreDataStorage* usr = [UserCoreDataStorage getOrInsertInManagedObjectContext:[self managedObjectContext] withUserInfo:userDict];
    if(!usr)
        return;
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
		NSLog(@"%s ERROR: %@", __PRETTY_FUNCTION__,error);
	}
}

- (void)updateUserData:(UserCoreDataStorage*)usr userDict:(NSDictionary*)userDict{
    
    NSString* str = [userDict objectForKey:@"from"];
    if(str)
        usr.from = str;
    
    str = [userDict objectForKey:@"subscription"];
    if(str)
        usr.subscription = str;
    
    str = [userDict objectForKey:@"status"];
    if(str)
        usr.status = str;

    str = [userDict objectForKey:@"type"];
    if(str)
        usr.presence_type = str;
    
}

- (void)updateUser: (NSDictionary*)userDict{

    UserCoreDataStorage* usr = [UserCoreDataStorage getUserFromManagedObjectContext:[self managedObjectContext] withUserInfo:userDict];
    if(!usr)
        return;
    
    [self updateUserData:usr userDict:userDict];
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
		NSLog(@"%s ERROR: %@", __PRETTY_FUNCTION__,error);
	}
}

- (void)removeUser: (NSDictionary*)userDict{
    
    UserCoreDataStorage* usr = [UserCoreDataStorage getUserFromManagedObjectContext:[self managedObjectContext] withUserInfo:userDict];
    if(!usr)
        return;
    
    [[self managedObjectContext] deleteObject:usr];
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
		NSLog(@"%s ERROR: %@", __PRETTY_FUNCTION__,error);
	}
}

- (BOOL)isUserAvailable:(NSString*)name{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue:name forKey:@"name"];
    UserCoreDataStorage* usr = [UserCoreDataStorage getUserFromManagedObjectContext:[self managedObjectContext] withUserInfo:dict];
    
    return (usr !=  nil);
}

- (int)isUserOnLine:(NSString*)name{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue:name forKey:@"name"];
    UserCoreDataStorage* usr = [UserCoreDataStorage getOrInsertInManagedObjectContext:[self managedObjectContext] withUserInfo:dict];
    if(!usr)
        return 0;
    
    NSLog(@"DEBUG: {ChatCoreDataStorage}->[isUserOnLine] usr:%@, status:%@", name, usr.presence_type);
    
    if ([usr.presence_type isEqualToString:@"available"])
        return 1;
    
    return 0;
}

- (NSString*) GetUserSubscription:(NSString*)name{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue:name forKey:@"name"];
    UserCoreDataStorage* usr = [UserCoreDataStorage getOrInsertInManagedObjectContext:[self managedObjectContext] withUserInfo:dict];
    if(!usr)
        return nil;
    
    NSLog(@"DEBUG: {ChatCoreDataStorage}->[GetUserSubscription] usr:%@, subscription:%@", name, usr.subscription);
    
    return usr.subscription;
}

- (BOOL) SetNeedToDoubleTake: (NSString*)name needToDoubleTake:(BOOL)n2dt {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue:name forKey:@"name"];
    UserCoreDataStorage* usr = [UserCoreDataStorage getOrInsertInManagedObjectContext:[self managedObjectContext] withUserInfo:dict];
    if(!usr)
        return FALSE;
    
    usr.needToDoubleTake = [NSNumber numberWithBool:n2dt];
    
    NSLog(@"DEBUG: {ChatCoreDataStorage}->[SetNeedToDoubleTake] usr:%@", name);
    NSError *error = nil;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
		NSLog(@"%s ERROR: %@", __PRETTY_FUNCTION__,error);
	}
    return TRUE;
}

- (BOOL) GetNeedToDoubleTake: (NSString*)name {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue:name forKey:@"name"];
    UserCoreDataStorage* usr = [UserCoreDataStorage getOrInsertInManagedObjectContext:[self managedObjectContext] withUserInfo:dict];
    if(!usr)
        return FALSE;
    
    NSLog(@"DEBUG: {ChatCoreDataStorage}->[SetNeedToDoubleTake] usr:%@ n2dt:%@", name, usr.needToDoubleTake);
    return [usr.needToDoubleTake boolValue];
}
+ (ChatCoreDataStorage*) sharedInstance
{
    if (chatCoreDataStorage == nil)
        chatCoreDataStorage = [[ChatCoreDataStorage alloc] init];
    
    return chatCoreDataStorage;
}

@end
