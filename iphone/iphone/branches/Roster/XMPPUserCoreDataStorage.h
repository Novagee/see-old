#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPUser.h"
#import "XMPPStreamCoreDataStorage.h"

#if TARGET_OS_IPHONE
  #import "DDXML.h"
#endif

@class XMPPGroupCoreDataStorage;
@class XMPPResourceCoreDataStorage;

@interface XMPPUserCoreDataStorage : NSManagedObject <XMPPUser>

@property (nonatomic, strong) XMPPJID *jid;
@property (nonatomic, assign) int section;

@property (nonatomic, strong) NSString * jidStr;
@property (nonatomic, strong) NSString * nickname;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSString * subscription;
@property (nonatomic, strong) NSString * ask;

@property (nonatomic, strong,readonly) NSString * sectionName;
@property (nonatomic, strong) NSNumber * sectionNum;

@property (nonatomic, strong) NSSet * groups;
@property (nonatomic, strong) XMPPResourceCoreDataStorage * primaryResource;
@property (nonatomic, strong) NSSet * resources;
@property (nonatomic, strong) XMPPStreamCoreDataStorage * stream;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc xmppStream:(XMPPStream *)xmppStream withItem:(NSXMLElement *)item;

- (void)updateWithItem:(NSXMLElement *)item;
- (void)updateWithPresence:(XMPPPresence *)presence;

@end

@interface XMPPUserCoreDataStorage (CoreDataGeneratedAccessors)


- (void)addResourcesObject:(XMPPResourceCoreDataStorage *)value;
- (void)removeResourcesObject:(XMPPResourceCoreDataStorage *)value;
- (void)addResources:(NSSet *)value;
- (void)removeResources:(NSSet *)value;


- (void)addGroupsObject:(XMPPGroupCoreDataStorage *)value;
- (void)removeGroupsObject:(XMPPGroupCoreDataStorage *)value;
- (void)addGroups:(NSSet *)value;
- (void)removeGroups:(NSSet *)value;


@end
