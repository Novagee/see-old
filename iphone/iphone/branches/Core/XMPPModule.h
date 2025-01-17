#import <Foundation/Foundation.h>

#import "MulticastDelegate.h"
#import "XMPPStream.h"


/**
 * XMPPModule is the base class that all extensions/modules inherit.
 * They automatically get:
 * 
 * - An xmppStream variable, with the corresponding property.
 * - A multicastDelegate that automatically invokes added delegates.
 * 
 * The module also automatically registers/unregisters itself with the xmpp stream.
**/
@interface XMPPModule : NSObject <XMPPStreamDelegate>
{
	XMPPStream *__weak xmppStream;
	
	id  multicastDelegate;
}

- (id)initWithStream:(XMPPStream *)xmppStream;

@property (weak, nonatomic, readonly) XMPPStream *xmppStream;

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;

@end
