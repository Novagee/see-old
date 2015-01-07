#import "XMPPModule.h"
#import "XMPPStream.h"
#import "MulticastDelegate.h"


@implementation XMPPModule

@synthesize xmppStream;

- (id)initWithStream:(XMPPStream *)aXmppStream
{
	if ((self = [super init]))
	{
		xmppStream = aXmppStream ;
		[xmppStream addDelegate:self];
		
		multicastDelegate = [[MulticastDelegate alloc] init];
		
		// The LAST thing we do is register our module with the xmpp stream.
		// We MUST do this AFTER initializing our multicast delegate.
		[xmppStream registerModule:self];
	}
	return self;
}

- (void)dealloc
{
	[xmppStream unregisterModule:self];
	
	[xmppStream removeDelegate:self];

}

- (void)addDelegate:(id)delegate
{
	[multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id)delegate
{
	[multicastDelegate removeDelegate:delegate];
}

@end
