//
//  CoreProxy.h
//  iPhoneXMPP
//
//  Created by Andranik Muradyan on 7/1/11.
//  Copyright 2011 home. All rights reserved.
//

#ifndef _CORE_PROXY_H
#define _CORE_PROXY_H

#import <Foundation/Foundation.h>

typedef enum {
	HTTPS,
	SOCKS5
} ProxyType;

@interface CoreProxy : NSObject
@property (readwrite, weak) NSString* host;
@property (readwrite, weak) NSString* port;
@property (readwrite, weak) NSString* username;
@property (readwrite, weak) NSString* password;
@property (readwrite, assign) BOOL authenticationNeeded;
@property (readwrite, assign) BOOL isNTLMAuth;
@property (readwrite, assign) ProxyType proxyType;

// Initializing routines
// For the case when we need no authentication
-(id) initWithHost: (NSString*) host
			  Port: (NSString*) port
	  andProxyType: (ProxyType) type;

// In case we need to be authnticated
-(id) initWithHost: (NSString*) host
			  Port: (NSString*) port
		 ProxyType: (ProxyType) type
		  Username: (NSString*) uname
		  Password: (NSString*) passwd
		 andIsNTLM: (BOOL) isNTLM; 

// Cleanup routine
//-(void) dealloc;

@end

#endif