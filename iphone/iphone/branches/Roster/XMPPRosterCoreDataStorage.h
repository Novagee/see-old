#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPRoster.h"

@class XMPPStream;

/**
 * This class is an example implementation of XMPPRosterStorage using core data.
 * You are free to substitute your own roster storage class.
**/

@interface XMPPRosterCoreDataStorage : NSObject <XMPPRosterStorage>
{	
	NSManagedObjectModel *managedObjectModel;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectContext *managedObjectContext;
    NSMutableDictionary *rosterPopulation;
}

@property (weak, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (weak, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (weak, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong) NSMutableDictionary *rosterPopulation;

/*
 * add the XMPPStream to core data.
 * used to track multiple XMPPStreams.
*/
- (void)addXMPPStream:(XMPPStream *)xmppStream;

@end

