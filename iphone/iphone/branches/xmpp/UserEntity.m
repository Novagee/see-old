//
//  UserEntity.m
//  iPhoneXMPP
//
//  Created by Andranik Muradyan on 7/2/11.
//  Copyright 2011 home. All rights reserved.
//

#import "UserEntity.h"


@implementation UserEntity

@synthesize listOfAccounts;

static UserEntity* s_userEntity = nil;


+(UserEntity*) sharedUserEntity{
	@synchronized(s_userEntity) {
		if(s_userEntity == nil){
			s_userEntity = [[UserEntity alloc] initUserEntity];
		}
	}
	
	return s_userEntity;	
}

-(id) initUserEntity
{
	@try {
		if (self = [super init]) {
			// if there are no preconfigured accounts in user defaults
			listOfAccounts = [[NSMutableDictionary alloc] init];
			// else if there are accounts read them and init list with them
		}
	}
	@catch (NSException * e) {
		UIAlertView *error = [[UIAlertView alloc] initWithTitle: @"Error" message: @"Something gone wrong while initing user entity." delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
		
		[error show];

	}
	
	return self;	
}

-(void) addAccount:(AccountEntity*) account {
	if (account) {
		[listOfAccounts setObject:account forKey:account.accountName];
	}
}

-(void) removeAccount:(NSString*) _accountName {
	if (_accountName) {
		[listOfAccounts removeObjectForKey:_accountName];
	}
}

-(void) removeAllAccounts {
    [listOfAccounts removeAllObjects];
}


-(AccountEntity*) getAccount:(NSString *)_accountName {
	return [listOfAccounts valueForKey:_accountName];
}


@end

