//
//  CoreXMPP.h
//  iPhoneXMPP
//
//  Created by Andranik Muradyan on 7/2/11.
//  Copyright 2011 home. All rights reserved.
//

#ifndef _CORE_XMPP_H
#define _CORE_XMPP_H

#import <Foundation/Foundation.h>
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPUserCoreDataStorage.h"
#import "XMPPvCardCoreDataStorageController.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPRoster.h"
#import "XMPP.h"

@interface CoreXMPP : NSObject {
	XMPPStream* xmppStream;
	XMPPRoster* xmppRoster;
	XMPPMessage* xmppMesasge;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPvCardTempModule *xmppvCardTempModule;
	
	BOOL selfSignedCertificates;
	BOOL SSLHostNameMismatch;
}

@property (readwrite, strong) XMPPStream* xmppStream;
@property (readwrite, strong) XMPPRoster* xmppRoster;
@property (readwrite, strong) XMPPMessage* xmppMessage;
@property (readwrite, strong) XMPPRosterCoreDataStorage* xmppRosterStorage;
@property (readwrite, strong) XMPPvCardAvatarModule* xmppvCardAvatarModule;
@property (readwrite, strong) XMPPvCardTempModule* xmppvCardTempModule;

@property (readwrite, assign) BOOL selfSignedCertificates;
@property (readwrite, assign) BOOL SSLHostNameMismatch;

-(id) initXMPPCoreWithStream;

// Init XMPP stream without any parameters.
-(void) initXMPPStream;

// Use to disconnect from stream and do not forget to go offline before disconnecting.
-(void) disconnectFromStream;

// Used to initialize XMPPRosterStorage, XMPPRoster for adding roster to XMPP stream.
-(XMPPRoster *) setupXMPPRoster;

// Used to initialize XMPPvCardTempModule, XMPPvCardAvatareModule modules for adding avatar to the roster and stream.
-(XMPPvCardAvatarModule *) setupXMPPAvatarModule;

/*
 Optional method for initializing XMPP stream with two parameters.
 Set the first allowSelfSignedCertificate parameter to YES in cases when XMPP server uses self signed certificates.
 Set the second allowSSLHostNameMismatch parameter to YES in cases when XMPP server uses SSL connection. 
 */
-(void) initXMPPStreamWithSSCertificate: (BOOL) allowSelfSignedCertificate
						 andSSLHostNameMismatch: (BOOL) allowSSLHostNameMismatch;

//-(void) dealloc;

@end

#endif