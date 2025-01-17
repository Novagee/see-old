#import "XMPPCapsResourceCoreDataStorageObject.h"
#import "XMPPCapsCoreDataStorageObject.h"


@implementation XMPPCapsResourceCoreDataStorageObject 

@dynamic jidStr;

@dynamic haveFailed;
@dynamic failed;

@dynamic node;
@dynamic ver;
@dynamic ext;

@dynamic hashStr;
@dynamic hashAlgorithm;

@dynamic caps;

- (BOOL)haveFailed
{
	return [[self failed] boolValue];
}

- (void)setHaveFailed:(BOOL)flag
{
	self.failed = @(flag);
}

@end
