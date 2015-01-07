//
//  UserEntity.h
//  iPhoneXMPP
//
//  Created by Andranik Muradyan on 7/2/11.
//  Copyright 2011 home. All rights reserved.
//

#ifndef _USER_ENTITY_H
#define _USER_ENTITY_H

#import <Foundation/Foundation.h>
#import "AccountEntity.h"

@interface UserEntity : NSObject {
	NSMutableDictionary* listOfAccounts;
}

@property (readwrite, strong) NSMutableDictionary* listOfAccounts;

// Gets the instance of silngletone UserEntity
+(UserEntity*) sharedUserEntity;

// Initialization routine
-(id) initUserEntity;

// Utitlity functions
-(void) removeAccount:(NSString*) _accountName;
-(void) removeAllAccounts;
-(void) addAccount:(AccountEntity*) account;


-(AccountEntity*) getAccount:(NSString*) _accountName;

// Cleanup routine
//-(void) dealloc;

@end

#endif