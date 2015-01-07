//
//  CoreUser.h
//  iPhoneXMPP
//
//  Created by Andranik Muradyan on 7/1/11.
//  Copyright 2011 home. All rights reserved.
//

#ifndef _CORE_USER_H
#define _CORE_USER_H

#import <Foundation/Foundation.h>


@interface CoreUser : NSObject {
	NSString* username;
	NSString* password;
}

@property (strong, nonatomic, readwrite) NSString* username;
@property (strong, nonatomic, readwrite) NSString* password;

// Initializing routine
-(id) initCoreUserWithUsername: (NSString*) uname
					 andPassword: (NSString*) passwd;

// Cleanup routine
//-(void) dealloc;

@end

#endif