#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPResource.h"

@class XMPPUserCoreDataStorage;
@class XMPPPresence;


@interface XMPPResourceCoreDataStorage : NSManagedObject <XMPPResource>

@property (nonatomic, strong) XMPPJID *jid;
@property (nonatomic, strong) XMPPPresence *presence;

@property (nonatomic, assign) int priority;
@property (nonatomic, assign) int intShow;

@property (nonatomic, strong) NSString * jidStr;
@property (nonatomic, strong) NSString * presenceStr;

@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * show;
@property (nonatomic, strong) NSString * status;

@property (nonatomic, strong) NSDate * presenceDate;

@property (nonatomic, strong) NSNumber * priorityNum;
@property (nonatomic, strong) NSNumber * showNum;

@property (nonatomic, strong) XMPPUserCoreDataStorage * user;

+ (id)insertInManagedObjectContext:(NSManagedObjectContext *)moc withPresence:(XMPPPresence *)presence;

- (void)updateWithPresence:(XMPPPresence *)presence;

@end
