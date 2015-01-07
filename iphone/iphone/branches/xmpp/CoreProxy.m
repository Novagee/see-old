//
//  CoreProxy.m
//  iPhoneXMPP
//
//  Created by Andranik Muradyan on 7/1/11.
//  Copyright 2011 home. All rights reserved.
//

#import "CoreProxy.h"


@implementation CoreProxy

@synthesize host;
@synthesize port;
@synthesize username;
@synthesize password;
@synthesize authenticationNeeded;
@synthesize isNTLMAuth;
@synthesize proxyType;

-(id) initWithHost: (NSString*) _host Port: (NSString*) _port andProxyType: (ProxyType) _type{
	@try {
		if (self = [super init]) {
			if((_host && [_host length] != 0) && (_port && [_port length] != 0 )){
				self.host = _host;
				self.port = _port;
				self.proxyType = _type;
			}
		}
	}
	@catch (NSException *e) {
		UIAlertView *error = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Something gone wrong while setting proxy." delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		[error show];

	}
	return self;
}

-(id) initWithHost: (NSString*) _host Port: (NSString*) _port ProxyType: (ProxyType) _type
		  Username: (NSString*) _uname Password: (NSString*) _passwd andIsNTLM: (BOOL) _isNTLM{
	@try {
		if (self = [super init]) {
			if((_host && [_host length] != 0) && (_port && [_port length] != 0 )){
				self.host = _host;
				self.port = _port;
				self.proxyType = _type;
				self.authenticationNeeded = TRUE;
				self.username = _uname;
				self.password = _passwd;
				self.isNTLMAuth = _isNTLM;
			}
		}
	}
	@catch (NSException *e) {
		UIAlertView *error = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Something gone wrong while setting proxy." delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		[error show];

	}
	return self;	
}



@end
