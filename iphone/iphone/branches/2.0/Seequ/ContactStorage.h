//
//  ContactStorage.h
//  ProTime
//
//  Created by Grigori Jlavyan on 6/9/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "CoreDataManager.h"

#import <Foundation/Foundation.h>

@class UserInfoCoreData, ContactObject;

@interface ContactStorage :CoreDataManager
{
}

- (BOOL) InsertContactsFromArray: (NSArray*) contacts;
- (BOOL) InsertContactFromDictionary:(NSDictionary*)contact;
- (BOOL) InsertContactFromContactObject:(ContactObject*)contactObj;
- (BOOL) InsertStatusFromDictionary:(NSString*)seequId status:(NSDictionary*)statusDict;
- (BOOL) RemoveContactBySeequId: (NSString*) seequId;
- (BOOL) updateRate:(NSString*) rate;
- (BOOL) IsUserAvailable: (NSString*) seequId;
- (BOOL) IsUserOnline: (NSString*) seequId;

- (BOOL) SetImageBySeequId: (NSString*) seequId image:(UIImage*)image;
- (void) getImageBySeequId:(NSString*) seequId  success:(void (^)(UIImage* image) )success;
- (BOOL) setIsUserFavorit:(NSString*)seequId isFavorit:(BOOL)isFavorit;
- (BOOL) setIsUserMute:(NSString*)seequId isMute:(BOOL)isMute;
- (void)setNeedToDoubleTake:(NSString*)seequId needToDoubleTake:(BOOL)needToDoubleTake;
- (NSString*) GetUserSubscriptionBySeequId:(NSString*) seequId;
- (NSArray*) GetAllUsersInfoList;
- (ContactObject*) GetContactObjectBySeequId: (NSString*) seequId;
-(UserInfoCoreData*)getUserInfoBySeequId:(NSString*)seequId;
- (void) PrintDB;
- (void)deleteContactStorage;
+ (ContactStorage*) sharedInstance;
+ (void) UserInfoToContactObject:(UserInfoCoreData*)userInfo contactObject:(ContactObject*)obj;
+ (NSString*) GetUserSubscription:(UserInfoCoreData*)userInfo;


@end
