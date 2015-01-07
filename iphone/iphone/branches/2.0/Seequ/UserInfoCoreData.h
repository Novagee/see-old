//
//  UserInfoCoreData.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 8/28/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDGroup, InfoCoreData, LocationCoreData, UserLanguageCoreData, UserStatusCoreData;

@interface UserInfoCoreData : NSManagedObject

@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * introduction;
@property (nonatomic, retain) NSNumber * isFavorit;
@property (nonatomic, retain) NSNumber * isImageExist;
@property (nonatomic, retain) NSNumber * isMute;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * needToDoubleTake;
@property (nonatomic, retain) NSDate * regDate;
@property (nonatomic, retain) NSString * seeQuId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * userImage;
@property (nonatomic, retain) NSNumber * billingRate;
@property (nonatomic, retain) NSSet *contactInfoList;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) NSSet *internetInfoList;
@property (nonatomic, retain) LocationCoreData *location;
@property (nonatomic, retain) NSSet *socialInfoList;
@property (nonatomic, retain) UserStatusCoreData *status;
@property (nonatomic, retain) UserLanguageCoreData *userLanguage;
@end

@interface UserInfoCoreData (CoreDataGeneratedAccessors)

- (void)addContactInfoListObject:(InfoCoreData *)value;
- (void)removeContactInfoListObject:(InfoCoreData *)value;
- (void)addContactInfoList:(NSSet *)values;
- (void)removeContactInfoList:(NSSet *)values;

- (void)addGroupsObject:(CDGroup *)value;
- (void)removeGroupsObject:(CDGroup *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

- (void)addInternetInfoListObject:(InfoCoreData *)value;
- (void)removeInternetInfoListObject:(InfoCoreData *)value;
- (void)addInternetInfoList:(NSSet *)values;
- (void)removeInternetInfoList:(NSSet *)values;

- (void)addSocialInfoListObject:(InfoCoreData *)value;
- (void)removeSocialInfoListObject:(InfoCoreData *)value;
- (void)addSocialInfoList:(NSSet *)values;
- (void)removeSocialInfoList:(NSSet *)values;

@end
