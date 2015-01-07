//
//  CoreXMPP.m
//  iPhoneXMPP
//
//  Created by Andranik Muradyan on 7/2/11.
//  Copyright 2011 home. All rights reserved.
//

#import "CoreXMPP.h"


@implementation CoreXMPP

@synthesize xmppStream;
@synthesize xmppRoster;
@synthesize xmppMessage;
@synthesize xmppRosterStorage;
@synthesize xmppvCardAvatarModule;
@synthesize xmppvCardTempModule;
@synthesize selfSignedCertificates;
@synthesize SSLHostNameMismatch;

-(id) initXMPPCoreWithStream {
		@try {
			if (self = [super init]) {
				[self initXMPPStream];
				[self setupXMPPRoster];
				[self setupXMPPAvatarModule];
			}
		}
		@catch (NSException * e) {
			UIAlertView *error = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Something gone wrong while initing core xmpp." delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
			
			[error show];
//			[error release];
		}
		
		return self;
}

-(void) initXMPPStream {
	self.xmppStream = [[XMPPStream alloc] init];
}

-(void) disconnectFromStream {
	[self.xmppStream disconnect];
}

-(XMPPRoster *) setupXMPPRoster {
	self.xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
	self.xmppRoster = [[XMPPRoster alloc] initWithStream:self.xmppStream rosterStorage:xmppRosterStorage];
	
	[self.xmppRoster setAutoRoster:YES];
	
	return self.xmppRoster;
}

-(XMPPvCardAvatarModule *) setupXMPPAvatarModule {
	self.xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithStream:self.xmppStream 
															  storage:[XMPPvCardCoreDataStorageController sharedXMPPvCardCoreDataStorageController]];
    self.xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
	return self.xmppvCardAvatarModule;
}

-(void) initXMPPStreamWithSSCertificate: (BOOL) allowSelfSignedCertificate
						 andSSLHostNameMismatch: (BOOL) allowSSLHostNameMismatch {
	
	if(self.xmppStream == nil) {
        [self initXMPPStream];
	}
	
	selfSignedCertificates = allowSelfSignedCertificate;	
	SSLHostNameMismatch = allowSSLHostNameMismatch;
}



@end
