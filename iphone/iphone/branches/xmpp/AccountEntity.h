//
//  AccountEntity.h
//  iPhoneXMPP
//
//  Created by Andranik Muradyan on 7/2/11.
//  Copyright 2011 home. All rights reserved.
//

#ifndef _PROVIDER_ENTITY_H
#define _PROVIDER_ENTITY_H

#define MESSAGE_ID [NSString stringWithFormat:@"msgId%.0f", [[NSDate date] timeIntervalSince1970]*1000.0]

#import <Foundation/Foundation.h>
#import "CoreUser.h"
#import "CoreProxy.h"
#import "CoreServer.h"
#import "CoreXMPP.h"


typedef enum {
	Online,
	Offline,
	Invisible,
	DND,
	Away,
	FreeForChat,
	Custom		// Allow user to define own states(i.e. InMoodForSex, WannaDie etc...)
} AccountState;

@interface AccountEntity : NSObject {
	NSString* accountName;		 // Holds the name of the account, i.e. "gtalk", "airphone", 
								 // "jabber" or user defined
	CoreUser*	userCredentials; // Holds user credentials, i.e. username/password
	CoreServer* serverSettings;	 // Holds server settings, i.e. host/port.etc.
	CoreProxy*	proxySettings;	 // Holds proxy settings, i.e. host/port/type/etc.
	CoreXMPP*	XMPPHandler;	 // Holds everything concerning the messaging
	BOOL onlineByDeafult;		 // Indicates whether current account goes online(or to 
								 // mentioned state) at application startup or not.
	// Assuming that JID is unique we moved it into the method.
	//XMPPJID* companionJID;		 // Jid of the person you are talking to.
	AccountState accountState;	 // Indicates accounts current state
}

@property (readwrite, strong) CoreUser*		userCredentials;
@property (readwrite, strong) CoreServer*	serverSettings;
@property (readwrite, strong) CoreProxy*	proxySettings;
@property (readwrite, strong) CoreXMPP*		XMPPHandler;
//@property (readwrite, retain) XMPPJID*		companionJID;
@property (readwrite, strong) NSString*		accountName;
@property (readwrite, assign) BOOL			onlineByDefault;
@property (readwrite, assign) AccountState	accountState;

// Initializing routine
-(id) initAccountWithUserCredentials: (CoreUser*) _userCredentials
					  ServerSettings: (CoreServer*) _serverSettings
					   ProxySettings: (CoreProxy*) _proxySettings
						DefaultState: (BOOL) _defaultState
					  andAccountName: (NSString*) _accountName;

// Here should be connect, disconnect, reconnect, update functions
-(BOOL) connect;
-(void) disconnect;

// Save last state to NSUserDefaults -> goToState(offline) -> disconnect -> connect -> goToState(last state)
-(BOOL) reconnect;

// Updates new settings to NSUserDefaults and into list of accounts and reconnects
//-(void) update;

-(BOOL) goToState:(AccountState) _accountState;


#pragma mark ------- Send/Recieve functions
// Here should be send/receive file and message functions
-(void) sendMessage:(NSString*) _messageContent toJID: (NSString *)_friendJID MessageID:(NSString*)messageID;

// Receive message from delegate.
-(NSString*) receiveMessage:(XMPPMessage *)_message;

// Cleanup routine
//-(void) dealloc;

@end

#endif