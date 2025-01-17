#import "XMPPResourceMemoryStorage.h"
#import "XMPP.h"
#import "XMPPElement+Delay.h"


@implementation XMPPResourceMemoryStorage

- (id)initWithPresence:(XMPPPresence *)aPresence
{
	if((self = [super init]))
	{
		jid = [aPresence from];
		presence = aPresence;
		
		presenceDate = [presence delayedDeliveryDate];
		if (presenceDate == nil)
		{
			presenceDate = [[NSDate alloc] init];
		}
	}
	return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Encoding, Decoding
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if ! TARGET_OS_IPHONE
- (id)replacementObjectForPortCoder:(NSPortCoder *)encoder
{
	if([encoder isBycopy])
		return self;
	else
		return [NSDistantObject proxyWithLocal:self connection:[encoder connection]];
}
#endif

- (id)initWithCoder:(NSCoder *)coder
{
	if((self = [super init]))
	{
		if([coder allowsKeyedCoding])
		{
			jid          = [coder decodeObjectForKey:@"jid"];
			presence     = [coder decodeObjectForKey:@"presence"];
			presenceDate = [coder decodeObjectForKey:@"presenceDate"];
		}
		else
		{
			jid          = [coder decodeObject];
			presence     = [coder decodeObject];
			presenceDate = [coder decodeObject];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	if([coder allowsKeyedCoding])
	{
		[coder encodeObject:jid          forKey:@"jid"];
		[coder encodeObject:presence     forKey:@"presence"];
		[coder encodeObject:presenceDate forKey:@"presenceDate"];
	}
	else
	{
		[coder encodeObject:jid];
		[coder encodeObject:presence];
		[coder encodeObject:presenceDate];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Standard Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (XMPPJID *)jid
{
	return jid;
}

- (XMPPPresence *)presence
{
	return presence;
}

- (NSDate *)presenceDate
{
	return presenceDate;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Update Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)updateWithPresence:(XMPPPresence *)aPresence
{

	presence = aPresence ;
	
	presenceDate = [presence delayedDeliveryDate];
	if (presenceDate == nil)
	{
		presenceDate = [[NSDate alloc] init];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Comparison Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSComparisonResult)compare:(id <XMPPResource>)another
{
	XMPPPresence *mp = [self presence];
	XMPPPresence *ap = [another presence];
	
	int mpp = [mp priority];
	int app = [ap priority];
	
	if(mpp < app)
		return NSOrderedDescending;
	if(mpp > app)
		return NSOrderedAscending;
	
	// Priority is the same.
	// Determine who is more available based on their show.
	int mps = [mp intShow];
	int aps = [ap intShow];
	
	if(mps < aps)
		return NSOrderedDescending;
	if(mps > aps)
		return NSOrderedAscending;
	
	// Priority and Show are the same.
	// Determine based on who was the last to receive a presence element.
	NSDate *mpd = [self presenceDate];
	NSDate *apd = [another presenceDate];
	
	return [mpd compare:apd];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSObject Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSUInteger)hash
{
	return [jid hash];
}

- (BOOL)isEqual:(id)anObject
{
	if([anObject isMemberOfClass:[self class]])
	{
		XMPPResourceMemoryStorage *another = (XMPPResourceMemoryStorage *)anObject;
		
		return [jid isEqual:[another jid]];
	}
	
	return NO;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"XMPPResource: %@", [jid full]];
}

@end
