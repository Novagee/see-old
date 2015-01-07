#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPCapabilities.h"

/**
 * This class is an example implementation of XMPPCapabilitiesStorage using core data.
 * You are free to substitute your own storage class.
**/

@interface XMPPCapabilitiesCoreDataStorage : NSObject <XMPPCapabilitiesStorage>
{
//	XMPPCapabilities __weak *parent;
	
	NSManagedObjectModel *managedObjectModel;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectContext *managedObjectContext;
}

@property (weak, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (weak, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (weak, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@end
