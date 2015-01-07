//
//  CoreServer.m
//  iPhoneXMPP
//
//  Created by Andranik Muradyan on 7/1/11.
//  Copyright 2011 home. All rights reserved.
//

#import "CoreServer.h"


@implementation CoreServer

@synthesize host;
@synthesize port;
@synthesize secureConnectionType;
@synthesize enableSecureConnection;

-(id) initCoreServerWithHost:(NSString*) _host andPort:(NSString*) _port{
	@try {
		if (self = [super init]) {
			if (( _host && [_host length] != 0 ) && ( _port && [_port length] != 0 )) {
				self.host = _host;
				self.port = _port;
				self.enableSecureConnection = FALSE;
			}
		}
	}
	@catch (NSException * e) {
		UIAlertView *error = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Something gone wrong while initializing proxy." delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		[error show];

	}
	
	return self;
}

-(id) initCoreServerWithHost:(NSString*) _host Port:(NSString*) _port
	andSecureConnectionType:(SecureConnectionType) _secureConnectionType{
	@try {
		if (self = [super init]) {
			if (( _host && [_host length] != 0 ) && ( _port && [_port length] != 0 )) {
				self.host = _host;
				self.port = _port;
				self.secureConnectionType = _secureConnectionType;
				self.enableSecureConnection = TRUE;
			}
		}
	}
	@catch (NSException * e) {
		UIAlertView *error = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Something gone wrong while initializing proxy." delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		[error show];
	}
	
	return self;
}


@end
