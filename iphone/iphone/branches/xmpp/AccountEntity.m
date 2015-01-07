//
//  AccountEntity.m
//  iPhoneXMPP
//
//  Created by Andranik Muradyan on 7/2/11.
//  Copyright 2011 home. All rights reserved.
//

#import "AccountEntity.h"
#import "idoubs2AppDelegate.h"


@implementation AccountEntity

@synthesize userCredentials;
@synthesize serverSettings;
@synthesize proxySettings;
@synthesize XMPPHandler;
//@synthesize companionJID;
@synthesize accountName;
@synthesize onlineByDefault;
@synthesize accountState;


#pragma mark ------ Connect/Disconnect/Reconect
-(id) initAccountWithUserCredentials: (CoreUser*) _userCredentials ServerSettings: (CoreServer*) _serverSettings
					   ProxySettings: (CoreProxy*) _proxySettings DefaultState: (BOOL) _defaultState
					  andAccountName: (NSString*)_accountName
{
	@try {
		if (self = [super init]) {
			if (( _userCredentials && _serverSettings )) {
				self.userCredentials = _userCredentials;
				self.serverSettings = _serverSettings;
				self.proxySettings = _proxySettings;
				self.onlineByDefault = _defaultState;
				self.accountState = Online;
				self.accountName = _accountName;
				//self.companionJID = nil;
				
				XMPPHandler = [[CoreXMPP alloc] initXMPPCoreWithStream];
				[[XMPPHandler xmppStream] addDelegate:self];
				[[XMPPHandler xmppRoster] addDelegate:self];
			}
		}
	}
	@catch (NSException * e) {
		UIAlertView *error = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Something gone wrong while setting up account." delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		[error show];

	}
	
	return self;	
}

-(BOOL) connect{

	if ([[XMPPHandler xmppStream] isConnected]) {
		return YES;
	}
	
  	[[XMPPHandler xmppStream] setHostName:[serverSettings host]];
  	[[XMPPHandler xmppStream] setHostPort:[[serverSettings port] intValue]];
	
	if ([userCredentials username] != nil && 
		[userCredentials password] != nil) {
		[[XMPPHandler xmppStream] setMyJID:[XMPPJID jidWithString:[userCredentials username]]];
		@try {
			NSError *error = nil;
			if ([[XMPPHandler xmppStream] connect:&error])
			{
				if ([[XMPPHandler xmppStream] authenticateWithPassword:[userCredentials password] error:&error])
					return YES;
				else 
					return NO;
			}			
		}
		@catch (NSException * e) {
		}
}
	return NO;
}

-(void) disconnect{
	[XMPPHandler disconnectFromStream];
}

-(BOOL) reconnect {
	return YES;
}


-(BOOL) goToState:(AccountState) _accountState
{
	NSXMLElement* presence;
	BOOL isOk = NO;
	switch (_accountState) {
		case Online:
            NSLog(@"Online");
			[self connect];
			presence = [NSXMLElement elementWithName:@"presence"];
            [presence addAttributeWithName:@"from" stringValue:@"Online"];
			[[XMPPHandler xmppStream] sendElement:presence];
			accountState = _accountState;
			break;
		case Offline:
            NSLog(@"Offline");
			presence = [NSXMLElement elementWithName:@"presence"];
			[presence addAttributeWithName:@"type" stringValue:@"unavailable"];
			[[XMPPHandler xmppStream] sendElement:presence];			
			accountState = _accountState;
			[self disconnect];
			break;
		case Away:
            NSLog(@"Away");
            [self connect];
			presence = [NSXMLElement elementWithName:@"presence"];
			[presence addAttributeWithName:@"from" stringValue:@"away"];
			[[XMPPHandler xmppStream] sendElement:presence];			
			accountState = _accountState;
			break;
		default:
			break;
	}

	if([[XMPPHandler xmppStream] isConnected]) {
		isOk = YES;
	}
	return isOk;
}

#pragma mark ----- Messaging

-(void) sendMessage:(NSString*) _messageContent toJID: (NSString *)_friendJID MessageID:(NSString*)messageID {
	if([_messageContent length] > 0)
	{
		NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
		[body setStringValue:_messageContent];
		
		NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
		[message addAttributeWithName:@"type" stringValue:@"chat"];
		[message addAttributeWithName:@"to" stringValue:_friendJID];
        [message addAttributeWithName:@"xmlns" stringValue:@"jabber:client"];
        if (messageID) {
            [message addAttributeWithName:@"id" stringValue:messageID];
        }
		[message addChild:body];
        
        NSXMLElement *x = [NSXMLElement elementWithName:@"request"];
        [x addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:receipts"];
        
        [message addChild:x];
        
        //        NSLog(@"message: %@", [message compactXMLString]);
		[[XMPPHandler xmppStream] sendElement:message];
	}
}

-(NSString*) receiveMessage:(XMPPMessage *)_message {
	NSString *messageStr = @"";
	if([_message isChatMessageWithBody])
	{
		messageStr = [[_message elementForName:@"body"] stringValue];
	}
	
	return messageStr;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	if ([XMPPHandler selfSignedCertificates])
	{
// JSC		[settings setObject:@(YES) forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
        [settings setObject:@(NO) forKey:(NSString *)kCFStreamSSLValidatesCertificateChain];
	}
	
	if ([XMPPHandler SSLHostNameMismatch])
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = [XMPPHandler xmppStream].hostName;
		NSString *virtualDomain = [[XMPPHandler xmppStream].myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
			//if ([serverDomain isEqualToString:@"xmpp.airtalkmobile.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
				//if ([virtualDomain isEqualToString:@"airtalkmobile.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil) {
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{

}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{

	
	NSError *error = nil;
	
	if (![[XMPPHandler xmppStream] authenticateWithPassword:[userCredentials password] error:&error])
	{
		
	}
	else {
		
	}
	
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{

}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{

	
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    //    NSLog(@"Recive Message: %@", [message compactXMLString]);
    XMPPJID *jidFrom = [message from];
    
	if ([message isChatMessage] && ![[[message elementForName:@"body"] stringValue] isEqualToString:@""]) {
        NSString *msgID = [message attributeStringValueForName:@"id"];

        if (!msgID) {
            return;
        }
		
		NSXMLElement *message_ = [NSXMLElement elementWithName:@"message"];
		[message_ addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@", sender.myJID.user, sender.myJID.domain]];
		[message_ addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@", jidFrom.user, jidFrom.domain]];
		[message_ addAttributeWithName:@"id" stringValue:msgID];
		
        NSXMLElement *received = [NSXMLElement elementWithName:@"received"];
        [received addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:receipts"];
        
        [message_ addChild:received];
        
		[[XMPPHandler xmppStream] sendElement:message_];
        
        
        //        NSLog(@"Send Delivery: %@", [message compactXMLString]);
	} else {
        NSXMLElement *received = [message elementForName:@"received"];
        
        if (received) {
            NSString *message_ID = [message attributeStringValueForName:@"id"];
            
            if (message_ID) {
                NSLog(@"[account %@", message_ID);
 //               [[idoubs2AppDelegate sharedInstance].sqliteService updateMessageDeliveredWithSeequID:jidFrom.user MessageID:message_ID Delivered:YES];
            }
        }
    }
}


- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(connect)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender
{

	
}

@end