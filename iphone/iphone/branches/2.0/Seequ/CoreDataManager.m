
//  CoreDataManager.m
//  ProTime
//
//  Created by Grigori Jlavyan on 1/31/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import "ContactStorage.h"
#import "CoreDataManager.h"

@implementation CoreDataManager

static NSManagedObjectModel *managedObjectModel = nil;
static NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;
static NSManagedObjectContext *managedObjectContext = nil;
static NSString *guid=nil;
+ (NSString *)persistentStoreDirectory
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
                appName = @"Contactstorage";
        }
        
        NSString *result = [basePath stringByAppendingPathComponent:appName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if(![fileManager fileExistsAtPath:result])
	{
		[fileManager createDirectoryAtPath:result withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
        return result;
}
+(NSString *)guid {
	if (guid == nil) {
		CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
		NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
		CFRelease(uuid);
                
           guid= [NSString stringWithFormat:@"%@",[uuidStr lowercaseString]];
	}
	return guid;
}
+ (NSManagedObjectModel *)managedObjectModel
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
	 [[NSNotificationCenter defaultCenter] addObserver:[ContactStorage sharedInstance] selector:@selector(_mocDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
	return managedObjectModel;
       
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (persistentStoreCoordinator)
	{
		return persistentStoreCoordinator;
	}
	
	NSManagedObjectModel *mom = [CoreDataManager managedObjectModel];
	
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
	
	NSString *docsPath = [self persistentStoreDirectory];
	NSString *storePath = [docsPath stringByAppendingPathComponent:@"ChatUsers.sqlite"];
	if (storePath)
	{
                NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
                NSPersistentStore *persistentStore;
                NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:YES],
                                         NSMigratePersistentStoresAutomaticallyOption,
                                        [NSNumber numberWithBool:YES],
                                         NSInferMappingModelAutomaticallyOption, nil];
                NSError *error = nil;
                persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
		                                                           configuration:nil
                                                                                     URL:storeUrl
                                                                                 options:options
                                                                                   error:&error];
        
        NSDictionary *attributes = @{
            NSMigratePersistentStoresAutomaticallyOption: @(YES),
            NSInferMappingModelAutomaticallyOption : @(YES),
            NSPersistentStoreFileProtectionKey: NSFileProtectionCompleteUntilFirstUserAuthentication
        };
        
// JSC        NSDictionary *attributes = @{NSFileProtectionKey: NSFileProtectionComplete};
        if (![[NSFileManager defaultManager] setAttributes:attributes
                                              ofItemAtPath:storePath
                                                     error:&error]) {
            NSLog(@"File protection failed: %@", error);
        }
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

+ (NSManagedObjectContext *)managedObjectContext
{  //@synchronized(self){
        NSThread *thread=[NSThread currentThread];
	if ([thread isMainThread])
	{
		return [CoreDataManager managedObjectContextForMainThread];
	}
	 NSString *threadKey = [NSString stringWithFormat:@"ManagedObjectContext_"/*,[NSThread currentThread]*/];
        if ( [[thread threadDictionary] objectForKey:threadKey] == nil ){
                NSPersistentStoreCoordinator *coordinator = [CoreDataManager  persistentStoreCoordinator];
                if (coordinator)
                {
                       NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
                        [moc setParentContext:[CoreDataManager managedObjectContextForMainThread]];
                        [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                        [[thread threadDictionary] setObject:moc forKey:threadKey];
                }
	}
	return [[thread threadDictionary] objectForKey:threadKey];
  // }
}
+ (NSManagedObjectContext *)managedObjectContextForMainThread{
        if (managedObjectContext)
	{
		return managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [CoreDataManager  persistentStoreCoordinator];
	if (coordinator)
	{
		managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		[managedObjectContext setPersistentStoreCoordinator:coordinator];
                [managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
	}
	
	return managedObjectContext;
     
}
- (BOOL) saveManagedObjectContext: (NSManagedObjectContext*) _managedObjectContext {
//        [self performSelectorOnMainThread:@selector(saveContext:) withObject:_managedObjectContext waitUntilDone:NO];
    __block     NSError *error;
        dispatch_async(dispatch_get_main_queue(), ^{
                [_managedObjectContext processPendingChanges];
            
                @try {
                    [_managedObjectContext lock];

                        if (![_managedObjectContext save:&error]) {
                                NSLog(@"Oops, couldn't save: %@ %@ %@", [error localizedDescription], [error userInfo], error.description);
//                                return FALSE;
                        }
                }
                @catch (NSException *exception) {
                        NSLog(@"saveManagedObjectContext: %@", exception.description);
                }
                @finally {
                }
                [_managedObjectContext unlock];
        });
        
        return TRUE;
}
//-(void)saveContext:(NSManagedObjectContext*) _managedObjectContext{
//        NSError *error;
//        
//        [_managedObjectContext lock];
//        [_managedObjectContext processPendingChanges];
//        @try {
//                if (![_managedObjectContext save:&error]) {
//                        NSLog(@"Oops, couldn't save: %@ %@ %@", [error localizedDescription], [error userInfo], error.description);
//                        return ;
//                }
//        }
//        @catch (NSException *exception) {
//                NSLog(@"saveManagedObjectContext: %@", exception.description);
//        }
//        @finally {
//        }
//        [_managedObjectContext unlock];
//}

- (NSArray*)fetchWithPredicate:(NSManagedObjectContext*)_managedObjectContext withPredicate:(NSString*)predicateString andEntityName:(NSString *)EntityName{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:EntityName inManagedObjectContext:_managedObjectContext];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        [fetch setPredicate: predicate];
        
        [fetch setEntity: entity];
        
        NSError *error = nil;
    [_managedObjectContext lock];
        NSArray *array = [_managedObjectContext executeFetchRequest:fetch error:&error];
    [_managedObjectContext unlock];
 
        if(array == nil || array.count == 0)
        {
                NSLog(@"%@ object with (%@) not found", EntityName, predicateString);
                return nil;
        }

        //    if(array.count > 1)
        //        NSLog(@"WARNING: duplicated record !!!!!!!!!!!!!!!!!!!!!!!");
        //
        //    return [array objectAtIndex:0];
        return  array;
}
-(void)deleteEntity:(NSManagedObjectContext*)_managedObjectContext andEntityName:(NSString *)EntityName{
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:EntityName inManagedObjectContext:_managedObjectContext];
        [fetch setEntity:entity];
        NSError *error;
    [_managedObjectContext lock];

        NSArray *array=[_managedObjectContext executeFetchRequest:fetch error:&error];
    [_managedObjectContext unlock];

        if (array && array.count>0) {
                for (int i=0; i<array.count; i++) {
                        [_managedObjectContext deleteObject:[array objectAtIndex:i]];
                }
                [self saveManagedObjectContext:_managedObjectContext];
        }
    
}
@end
