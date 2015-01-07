#import <Foundation/Foundation.h>

@class XMPPStream;


@interface XMPPTransports : NSObject
{
	XMPPStream *__weak xmppStream;
}

- (id)initWithStream:(XMPPStream *)xmppStream;

@property (weak, nonatomic, readonly) XMPPStream *xmppStream;

- (void)queryGatewayDiscoveryIdentityForLegacyService:(NSString *)service;
- (void)queryGatewayAgentInfo;
- (void)queryRegistrationRequirementsForLegacyService:(NSString *)service;
- (void)registerLegacyService:(NSString *)service username:(NSString *)username password:(NSString *)password;
- (void)unregisterLegacyService:(NSString *)service;

@end
