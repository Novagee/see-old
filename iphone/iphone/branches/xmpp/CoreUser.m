//
//  CoreUser.m
//  iPhoneXMPP
//
//  Created by Andranik Muradyan on 7/1/11.
//  Copyright 2011 home. All rights reserved.
//

#import "CoreUser.h"


@implementation CoreUser

@synthesize username;
@synthesize password;

-(id) initCoreUserWithUsername: (NSString*) uname andPassword: (NSString*) passwd{
	@try {
		if (self = [super init]) {
			if((uname && [uname length] != 0) && (passwd && [passwd length] != 0 )){
				self.username = uname;
				self.password = passwd;
			}
		}
	}
	@catch (NSException *e) {
		UIAlertView *error = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Something gone wrong while setting username/password." delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		[error show];
//		[error release];
	}
	return self;
}


@end
