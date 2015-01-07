//
// XMPPRoomOccupant
// A chat room. XEP-0045 Implementation.
//

#import <Foundation/Foundation.h>

@class XMPPJID;

@interface XMPPRoomOccupant : NSObject {
	XMPPJID *jid;
	NSString *role;
	NSString *nick;
}

@property (nonatomic, strong) XMPPJID *jid;
@property (nonatomic, strong) NSString *role, *nick;

@end
