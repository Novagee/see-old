//
//  CoreServer.h
//  iPhoneXMPP
//
//  Created by Andranik Muradyan on 7/1/11.
//  Copyright 2011 home. All rights reserved.
//

#ifndef _CORE_SERVER_H
#define _CORE_SERVER_H

#import <Foundation/Foundation.h>

typedef enum seccontype{
	SSL_,
	TLS
} SecureConnectionType;

@interface CoreServer : NSObject {
	NSString* host;
	NSString* port;
	BOOL enableSecureConnection;
	SecureConnectionType secureConnectionType;
}

@property (nonatomic, strong, readwrite) NSString* host;
@property (nonatomic, strong, readwrite) NSString* port;
@property (readwrite, assign) SecureConnectionType secureConnectionType;
@property (readwrite, assign) BOOL enableSecureConnection;

// Initializing routines
// For case, when we don't need secure connection
-(id) initCoreServerWithHost:(NSString*) _host
					 andPort:(NSString*) _port;

// For cases, when we need secure connection(SSL or TLS)
-(id) initCoreServerWithHost:(NSString*) _host
						Port:(NSString*) _port
	 andSecureConnectionType:(SecureConnectionType) _secureConnectionType;

// Cleanup routine
//-(void) dealloc;

@end

#endif