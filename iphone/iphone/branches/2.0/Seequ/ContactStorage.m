//
//  ContactStorage.m
//  ProTime
//
//  Created by Grigori Jlavyan on 6/9/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

//
//  ContactStorage.m
//  ProTime
//
//  Created by Samvel Shakhbazyan on 1/16/14.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//
#import "common.h"
#import "ContactStorage.h"
#import "UserInfoCoreData.h"
#import "LocationCoreData.h"
#import "UserLanguageCoreData.h"
#import "InfoCoreData.h"
#import "UserStatusCoreData.h"
#import "ContactObject.h"
#import "idoubs2AppDelegate.h"

#import <CoreData/CoreData.h>

static ContactStorage* g_contactStorage = nil;

@implementation ContactStorage

const NSString* const g_seeQuId            = @"seeQuId";
const NSString* const g_email              = @"email";
const NSString* const g_firstName          = @"firstName";
const NSString* const g_lastName           = @"lastName";
const NSString* const g_title              = @"title";
const NSString* const g_bio                = @"bio";
const NSString* const g_introduction       = @"introduction";
const NSString* const g_isImageExist       = @"isImageExist";
const NSString* const g_regDate            = @"regDate";
const NSString* const g_contactInfoList    = @"contactInfoList";
const NSString* const g_internetInfoList   = @"internetInfoList";
const NSString* const g_socialInfoList     = @"socialInfoList";
const NSString* const g_location           = @"location";
const NSString* const g_userLanguage       = @"userLanguage";
const NSString* const g_favorite           = @"isFavorite";
const NSString* const g_mute               = @"isMute";
const NSString* const g_needToDoubleTake   = @"needToDoubleTake";

const NSString* const g_city               = @"city";
const NSString* const g_country            = @"country";
const NSString* const g_countryId          = @"countryId";
const NSString* const g_state              = @"state";
const NSString* const g_stateAbbrev        = @"stateAbbrev";
const NSString* const g_stateId            = @"stateId";
const NSString* const g_timeZone           = @"timeZone";

const NSString* const g_primary            = @"primary";
const NSString* const g_second             = @"second";
const NSString* const g_third              = @"third";
const NSString* const g_fourth             = @"fourth";

const NSString* const g_itemName           = @"itemName";
const NSString* const g_itemValue          = @"itemValue";

const NSString* const g_type               = @"type";
const NSString* const g_subscription       = @"subscription";
const NSString* const g_status             = @"status";

const NSString* const g_photo              = @"photo";
const NSString* const g_rate               = @"rate";
const NSString* const g_rateData           = @"rateData";


- (BOOL) InsertContactsFromArray: (NSArray*)contacts {
        
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        [moc lock];
        [moc processPendingChanges];
        for (NSDictionary* contact in contacts) {
                [self InsertContactFromDictionary:moc contact:contact];
               
        }
        
        BOOL ret = [self saveManagedObjectContext:moc];
        [moc unlock];
        return ret;
}

- (BOOL) InsertContactFromDictionary:(NSDictionary*)contact {
  //      NSLog(@"[ContactStorage] ==== InsertContactFromDictionary ====");
        BOOL ret = NO;
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        [moc lock];
        [moc processPendingChanges];
        if([self InsertContactFromDictionary:moc contact:contact])
                ret = [self saveManagedObjectContext:moc];
        [moc unlock];
        return ret;
}

- (BOOL) InsertContactFromContactObject:(ContactObject*)contactObj {
        NSLog(@"[ContactStorage] ==== InsertContactFromContactObject ====");
        BOOL ret = FALSE;
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        [moc lock];
        if([self InsertContactFromContactObject:moc contact:contactObj])
                ret = [self saveManagedObjectContext:moc];
        [moc unlock];
        return ret;
}
- (BOOL) setIsUserFavorit:(NSString*)seequId isFavorit:(BOOL)isFavorit{
        NSManagedObjectContext *moc = [CoreDataManager managedObjectContext];
        [moc lock];
        [moc processPendingChanges];
        UserInfoCoreData *userInfo = [self fetchContactBySeequId:moc seequId:(NSString*)seequId];
        if(!userInfo)
        {
                [moc unlock];
                return FALSE;
        }
        userInfo.isFavorit=[NSNumber numberWithBool:isFavorit];
        
        BOOL ret = [self saveManagedObjectContext:moc];
        [moc unlock];
        
        return ret;

}
- (BOOL) setIsUserMute:(NSString*)seequId isMute:(BOOL)isMute{
        NSManagedObjectContext *moc = [CoreDataManager managedObjectContext];
        [moc lock];
        [moc processPendingChanges];
        UserInfoCoreData *userInfo = [self fetchContactBySeequId:moc seequId:(NSString*)seequId];
        if(!userInfo)
        {
                [moc unlock];
                return FALSE;
        }
        userInfo.isMute=[NSNumber numberWithBool:isMute];
        
        BOOL ret = [self saveManagedObjectContext:moc];
        [moc unlock];
        
        return ret;
        
}




- (void)setNeedToDoubleTake:(NSString*)seequId needToDoubleTake:(BOOL)needToDoubleTake{
        NSManagedObjectContext *moc = [CoreDataManager managedObjectContext];
        [moc lock];
        [moc processPendingChanges];
        UserInfoCoreData *userInfo = [self fetchContactBySeequId:moc seequId:(NSString*)seequId];
        if(!userInfo)
        {
                [moc unlock];
                return ;
        }
        userInfo.needToDoubleTake=[NSNumber numberWithBool:needToDoubleTake];
        
        [self saveManagedObjectContext:moc];
        [moc unlock];

}
- (BOOL) InsertStatusFromDictionary:(NSString*)seequId status:(NSDictionary*)statusDict {
        
//        NSLog(@"[ContactStorage] ==== InsertUserStatusFromDictionary ====");
        NSManagedObjectContext *moc = [CoreDataManager managedObjectContext];
         [moc lock];
         [moc processPendingChanges];
        UserInfoCoreData *userInfo = [self fetchContactBySeequId:moc seequId:seequId];
        if(![userInfo isKindOfClass:[UserInfoCoreData class]]||![userInfo.status isKindOfClass:[UserStatusCoreData class]])
        {
                [moc unlock];
                return FALSE;
        }
        
        userInfo.status = [self InsertUserStatusFromDictionary:moc statusStorage:userInfo.status status:statusDict];
        if(!userInfo.status)
        {
                [moc unlock];
                return FALSE;
        }
        [moc unlock];
        BOOL ret = [self saveManagedObjectContext:moc];
       
        
        return ret;

}

- (BOOL) RemoveContactBySeequId: (NSString*) seequId {
        
        if( !seequId || !seequId.length )
                return FALSE;
        
        NSLog(@"[ContactStorage] ==== RemoveContactBySeequId ====");
        
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        [moc lock];
        [moc processPendingChanges];
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName: NSStringFromClass([UserInfoCoreData class]) inManagedObjectContext:moc];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"seeQuId == %@", seequId];
        
        [fetch setEntity: entity];
        [fetch setPredicate: predicate];
        
        NSError *error = nil;
        [moc lock];
        NSArray *array = [moc executeFetchRequest:fetch error:&error];
        [moc unlock];
        if(array == nil)
        {
                NSLog(@"1: Oops, object %@ not found: %@", seequId, [error localizedDescription]);
        }
        else
        {
                if(array.count > 0)
                {
                        for (NSManagedObject *managedObject in array) {
                                [moc deleteObject:managedObject];
                        }
                        [self saveManagedObjectContext:moc];
                }
        }
        
        [moc unlock];
        return TRUE;
}

- (BOOL) IsUserAvailable: (NSString*) seequId {
    
    //    NSLog(@"[ContactStorage] ==== IsUserAvailable ====");
        
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        [moc lock];
//        [moc processPendingChanges];
        UserInfoCoreData* userInfo = [self fetchContactBySeequId:moc seequId:seequId];
        [moc unlock];
        return userInfo != nil;
}

- (BOOL) IsUserOnline: (NSString*) seequId {
        
   //     NSLog(@"[ContactStorage] ==== IsUserOnline ====");
        
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        [moc lock];
        [moc processPendingChanges];
        UserInfoCoreData* userInfo = [self fetchContactBySeequId:moc seequId:seequId];
        [moc unlock];
        return [userInfo.status.isOnline boolValue];
}

- (BOOL) SetImageBySeequId: (NSString*) seequId image:(UIImage*)image {
        
        BOOL ret = FALSE;
        
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        [moc lock];
        [moc processPendingChanges];
        UserInfoCoreData* userInfo = [self fetchContactBySeequId:moc seequId:seequId];
        if(userInfo)
        {
                userInfo.userImage =  UIImagePNGRepresentation(image);
                ret = [self saveManagedObjectContext:moc];
        }
        [moc unlock];
        
        return ret;
}

- (NSString*) GetUserSubscriptionBySeequId:(NSString*) seequId {
        
    //    NSLog(@"[ContactStorage] ==== GetUserSubscriptionBySeequId ====");
        
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        [moc lock];
        [moc processPendingChanges];
        UserInfoCoreData* userInfo = [self fetchContactBySeequId:moc seequId:seequId];
        [moc unlock];
        
        return userInfo.status.subscription;
}

- (NSArray*) GetAllUsersInfoList {
        
        NSManagedObjectContext *moc = [CoreDataManager managedObjectContext];
    
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName: NSStringFromClass([UserInfoCoreData class]) inManagedObjectContext:moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        // Set example predicate and sort orderings...
        //    NSNumber *minimumSalary = ...;
        //    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(lastName LIKE[c] 'Worsley') AND (salary > %@)", minimumSalary];
        //    [request setPredicate:predicate];
        //
        //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
        //    [request setSortDescriptors:@[sortDescriptor]];
        [moc lock];

        NSError *error;
        NSArray *userInfoArray = [moc executeFetchRequest:request error:&error];
        [moc unlock];

        if (userInfoArray == nil)
        {
                NSLog(@"Oops, couldn't execute fetch request: %@", [error localizedDescription]);
                return nil;
        }
        
        return userInfoArray;
}
-(UserInfoCoreData*)getUserInfoBySeequId:(NSString*)seequId{
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        [moc lock];
        UserInfoCoreData* userInfo = [self fetchContactBySeequId:moc seequId:seequId];
        [moc unlock];
        
        if(!userInfo)
                return nil;
        
        return userInfo;
}

- (ContactObject*) GetContactObjectBySeequId: (NSString*) seequId {
        
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
       
        UserInfoCoreData* userInfo = [self fetchContactBySeequId:moc seequId:seequId];
//        [moc unlock];
        
        if(!userInfo)
                return nil;
        
        ContactObject* obj = [[ContactObject alloc] initWithSeequID:seequId];
        [ContactStorage UserInfoToContactObject: userInfo contactObject:obj];
        
        return obj;
}

-(void) getImageBySeequId:(NSString *)seequId success:(void (^)(UIImage *))success {
    @autoreleasepool {
        UIImage *image=[Common GetImageByPTID:seequId andHeight:IMAGE_HEIGHT];
        success( image);
        
    }

}

+ (void) UserInfoToContactObject:(UserInfoCoreData*)userInfo contactObject:(ContactObject*)obj {
        
        if(!userInfo || !obj)
                return;
        
        obj.FirstName = userInfo.firstName;
        obj.LastName = userInfo.lastName;
        obj.registrationDate = [userInfo.regDate timeIntervalSince1970];
        obj.imageExist = [userInfo.isImageExist boolValue];
        obj.introduction = userInfo.introduction;
        obj.biography = userInfo.bio;
        obj.specialist = userInfo.title;
        obj.isFavorite=[userInfo.isFavorit boolValue];
       obj.country.countryName = userInfo.location.country;
        obj.country.countryID = [userInfo.location.countryId stringValue];
        obj.state.stateID = [userInfo.location.stateId stringValue];
        obj.state.stateAbbrev = userInfo.location.stateAbbrev;
        obj.state.stateName = userInfo.location.state;
        obj.City = userInfo.location.city;
        obj.TimeZone = userInfo.location.timeZone;
        
        obj.LanguagePrimary = userInfo.userLanguage.primary;
        obj.LanguageSecond = userInfo.userLanguage.secondary;
        obj.LanguageThird = userInfo.userLanguage.third;
        obj.LanguageFourth = userInfo.userLanguage.fourth;
    
        
        obj.isOnline = online_Status_Away;
        if([userInfo.status.subscription isEqualToString: @"both"])
        {
                obj.contactType = Contact_Type_MY_Seequ_Contact;
                obj.isOnline = userInfo.status.isOnline ? (online_Status)[userInfo.status.isOnline intValue] : online_Status_Offline;
        }
        else if([userInfo.status.subscription isEqualToString:@"from"])
                obj.contactType = Contact_Type_Request_Connection;
        else if([userInfo.status.subscription isEqualToString:@"to"])
                obj.contactType = Contact_Type_Request_For_Connection;
        else
                obj.contactType = Contact_Type_Seequ_Contact;
        
        obj.isNameSeted = YES;
        
        if(obj.arrayContactInfo && [obj.arrayContactInfo count] > 0)
                [obj.arrayContactInfo removeAllObjects];
        
        if ([userInfo.contactInfoList count] > 0) {
                if(!obj.arrayContactInfo)
                        obj.arrayContactInfo = [[NSMutableArray alloc] init];
                
                for (InfoCoreData* info in userInfo.contactInfoList) {
                        
                        if (info.name && [info.name isKindOfClass:[NSString class]] && info.name.length &&
                            info.value && [info.value isKindOfClass:[NSString class]] && info.value.length)
                        {
                                NSDictionary* tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:info.name, g_itemName, info.value, g_itemValue, nil];
                                [obj.arrayContactInfo addObject:tempDict];
                        }
                }
        }
        
        if(obj.arrayInternetInfo && [obj.arrayInternetInfo count] > 0)
                [obj.arrayInternetInfo removeAllObjects];
        
        if ([userInfo.internetInfoList count] > 0) {
                if(!obj.arrayInternetInfo)
                        obj.arrayInternetInfo = [[NSMutableArray alloc] init];
                
                for (InfoCoreData* info in userInfo.internetInfoList) {
                        
                        if (info.name && [info.name isKindOfClass:[NSString class]] && info.name.length &&
                            info.value && [info.value isKindOfClass:[NSString class]] && info.value.length)
                        {
                                NSDictionary* tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:info.name, g_itemName, info.value, g_itemValue, nil];
                                [obj.arrayInternetInfo addObject:tempDict];
                        }
                }
        }
        
        if(obj.arraySocialInfo && [obj.arraySocialInfo count] > 0)
                [obj.arraySocialInfo removeAllObjects];
        
        if ([userInfo.socialInfoList count] > 0) {
                if(!obj.arraySocialInfo)
                        obj.arraySocialInfo = [[NSMutableArray alloc] init];
                
                for (InfoCoreData* info in userInfo.socialInfoList) {
                        
                        if (info.name && [info.name isKindOfClass:[NSString class]] && info.name.length &&
                            info.value && [info.value isKindOfClass:[NSString class]] && info.value.length)
                        {
                                NSDictionary* tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:info.name, g_itemName, info.value, g_itemValue, nil];
                                [obj.arraySocialInfo addObject:tempDict];
                        }
                }
        }
    if(obj.imageExist ){
        
        if (userInfo.userImage) {
            obj.image = [UIImage imageWithData:userInfo.userImage];
        } else {
            
            [[ContactStorage sharedInstance] getImageBySeequId:obj.SeequID success:^(UIImage *image) {
                [[ContactStorage sharedInstance] SetImageBySeequId:obj.SeequID image:image];
                obj.image = image;
            }];
        }
    }else{
        obj.image = [UIImage imageNamed:@"GenericContact.png"];
    }
}

+ (NSString*) GetUserSubscription:(UserInfoCoreData*) userInfo {
        
        return userInfo.status.subscription;
}

- (UserInfoCoreData*) fetchContactBySeequId:(NSManagedObjectContext*)moc seequId:(NSString*)seequId {
//        @synchronized(self){
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName: NSStringFromClass([UserInfoCoreData class]) inManagedObjectContext:moc];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"seeQuId == %@", seequId];
        
        [fetch setEntity: entity];
        [fetch setPredicate: predicate];
        NSArray *array;
        NSError *error = nil;
        @try {
            [moc lock];
            array =[[NSArray alloc] initWithArray:[moc executeFetchRequest:fetch error:&error]];
            [moc unlock];
               
        }
        @catch (NSException *exception) {
                NSLog(@"NSException -%@",exception);
        }
//        @finally {
//                
//        }
//        NSArray *array = [moc executeFetchRequest:fetch error:&error];
        if(array == nil || array.count == 0)
        {
                NSLog(@"2: Oops, object %@ not found: %@", seequId, moc);
                return nil;
        }
        
        if(array.count > 1){
                NSLog(@"WARNING: duplicated record %@ !!!!!!!!!!!!!!!!!!!!!!!", seequId);
                for (int i=1; i<array.count; i++) {
                        [moc deleteObject:(NSManagedObject*)[array objectAtIndex:i]];
                }

        }
        NSLog(@"JSC - object: %@ moc: %@", seequId, moc);
        return [array objectAtIndex:0];
//       }
}

-(BOOL) updateRate:(NSString *)rate {
    UserInfoCoreData* info = [[ContactStorage sharedInstance] getUserInfoBySeequId:[Common sharedCommon].contactObject.SeequID];
    NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];

    info.billingRate = [NSNumber numberWithFloat:[rate floatValue]];
    [self saveManagedObjectContext:moc];
    return YES;
}

- (BOOL) InsertContactFromDictionary:(NSManagedObjectContext*)moc contact:(NSDictionary*)contact {
    
        if(!contact && ![contact count]){
             NSLog(@"######### No contact info dictionary #########");
             return FALSE;
        }
                
        
        
        NSString * str, *seequId;
        NSNumber * num;
        long long date;
        
        seequId = [contact objectForKey:g_seeQuId];
        
 //       NSLog(@"InsertContactFromDictionary: %@", seequId);
        
        if(!seequId || ![seequId isKindOfClass:[NSString class]])
                return FALSE;
        
        UserInfoCoreData *userInfo = [self fetchContactBySeequId:moc seequId:seequId];
        if(userInfo == nil)
        {
                userInfo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([UserInfoCoreData class]) inManagedObjectContext:moc];
                userInfo.seeQuId = seequId;
        }
        
        str = [contact objectForKey:g_email];
        if(str && [str isKindOfClass:[NSString class]])
                userInfo.email = str;
        
        str = [contact objectForKey:g_firstName];
        if(str && [str isKindOfClass:[NSString class]])
                userInfo.firstName = str;
        
        str = [contact objectForKey:g_lastName];
        if(str && [str isKindOfClass:[NSString class]])
                userInfo.lastName = str;
        
        str = [contact objectForKey:g_title];
        if(str && [str isKindOfClass:[NSString class]])
                userInfo.title = str;
        
        str = [contact objectForKey:g_bio];
        if(str && [str isKindOfClass:[NSString class]])
                userInfo.bio = str;
        
        str=[contact objectForKey:g_favorite];
        if(str && [str isKindOfClass:[NSString class]])
                userInfo.isFavorit=[NSNumber numberWithInt:[str integerValue]] ;
        
        str=[contact objectForKey:g_mute];
        if(str && [str isKindOfClass:[NSString class]])
                userInfo.isMute=[NSNumber numberWithInt:[str integerValue]] ;
        
        str=[contact objectForKey:g_needToDoubleTake];
        if(str && [str isKindOfClass:[NSString class]])
                userInfo.needToDoubleTake=[NSNumber numberWithInt:[str integerValue]] ;
        
        str = [contact objectForKey:g_introduction];
        if(str && [str isKindOfClass:[NSString class]])
                userInfo.introduction = str;
        
        num = [contact objectForKey:g_isImageExist];
        if(num && [num isKindOfClass:[NSNumber class]])
                userInfo.isImageExist = num;
        UIImage* photo = [contact objectForKey:g_photo];
        if(photo)
            userInfo.userImage = UIImagePNGRepresentation(photo);
        NSDictionary* tempDict = [contact objectForKey:g_rateData];
    if (tempDict && [tempDict isKindOfClass:[NSDictionary class]]) {
        id bb = [tempDict objectForKey:g_rate];
        NSAssert(num,@"Must be exists in case of  tempDict existance" );
        if ([bb isKindOfClass:[NSNumber class]]) {
            userInfo.billingRate = bb;

        } else if([bb isKindOfClass:[NSString class]] ) {
            userInfo.billingRate = [NSNumber numberWithFloat:[((NSString*)bb) floatValue]];
        }
    }
    
  //      NSLog(@"Insert or Update: isImageExist %@ ==== %@ %@", seequId, num, userInfo.isImageExist);
//        if(!userInfo.use){
//            [[ContactStorage sharedInstance] getImageBySeequId:seequId success:^(UIImage *image) {
//                [[ContactStorage sharedInstance] SetImageBySeequId:seequId image:image];
//            }];
//        }
        num = [contact objectForKey:g_regDate];
        if(num && [num isKindOfClass:[NSNumber class]])
        {
                date = [num longLongValue];
                userInfo.regDate = [[NSDate alloc] initWithTimeIntervalSince1970:date/1000];
        }
        
        userInfo.status = [self InsertUserStatusFromDictionary:moc statusStorage:userInfo.status status:contact];
        
        NSDictionary* location = [contact objectForKey:g_location];
        userInfo.location = [self InsertLocationFromDictionary:moc locationStorage:userInfo.location location:location];
        
        NSDictionary* language = [contact objectForKey:g_userLanguage];
        userInfo.userLanguage = [self InsertUserLanguageFromDictionary:moc languageStorage:userInfo.userLanguage language:language];
        
        InfoCoreData* infoStorage;
        NSDictionary* dict;
        
        NSArray *contactInfoList = [contact objectForKey:g_contactInfoList];
        if([contactInfoList count])
        {
                [userInfo removeContactInfoList:userInfo.contactInfoList];
                for (dict in contactInfoList) {
                        
                        infoStorage = [self InsertInfoFromDictionary:moc info:dict];
                        if(infoStorage)
                                [userInfo addContactInfoListObject: infoStorage];
                }
        }
        
        NSArray *internetInfoList = [contact objectForKey:g_internetInfoList];
        if([internetInfoList count])
        {
                [userInfo removeInternetInfoList:userInfo.internetInfoList];
                for (dict in internetInfoList) {
                        
                        infoStorage = [self InsertInfoFromDictionary:moc info:dict];
                        if(infoStorage)
                                [userInfo addInternetInfoListObject: infoStorage];
                }
        }
        
        NSArray *socialInfoList = [contact objectForKey:g_socialInfoList];
        if([socialInfoList count])
        {
                [userInfo removeSocialInfoList:userInfo.socialInfoList];
                for (dict in socialInfoList) {
                        
                        infoStorage = [self InsertInfoFromDictionary:moc info:dict];
                        if(infoStorage)
                                [userInfo addSocialInfoListObject: infoStorage];
                }
        }
        
        return TRUE;

}

- (BOOL) InsertContactFromContactObject:(NSManagedObjectContext*)moc contact:(ContactObject*)contactObj {
        
        if(!contactObj)
                return FALSE;
        
        NSLog(@"InsertContactFromContactObject: %@", contactObj.SeequID);
        
        UserInfoCoreData *userInfo = [self fetchContactBySeequId:moc seequId:contactObj.SeequID];
        if(userInfo == nil)
        {
                userInfo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([UserInfoCoreData class]) inManagedObjectContext:moc];
                userInfo.seeQuId = contactObj.SeequID;
        }
        
        userInfo.email = @"";
        userInfo.firstName = contactObj.FirstName;
        userInfo.lastName = contactObj.LastName;
        userInfo.title = contactObj.specialist;
        userInfo.bio = contactObj.biography;
        userInfo.introduction = contactObj.introduction;
        userInfo.isImageExist = [[NSNumber alloc] initWithBool:contactObj.imageExist];
        userInfo.regDate = [[NSDate alloc] initWithTimeIntervalSince1970: contactObj.registrationDate];
        
//        userInfo.image = [[NSData alloc] initWithData: UIImagePNGRepresentation(contactObj.image)];
        
        userInfo.status = [self InsertUserStatusFromContactObject:moc statusStorage:userInfo.status contact:contactObj];
        userInfo.location = [self InsertLocationFromContactObject:moc locationStorage:userInfo.location contact:contactObj];
        userInfo.userLanguage = [self InsertUserLanguageFromContactObject:moc languageStorage:userInfo.userLanguage contact:contactObj];
        
        InfoCoreData* infoStorage;
        NSDictionary* dict;
        
        if([contactObj.arrayContactInfo count])
        {
                [userInfo removeContactInfoList:userInfo.contactInfoList];
                for (dict in contactObj.arrayContactInfo) {
                        
                        infoStorage = [self InsertInfoFromDictionary:moc info:dict];
                        if(infoStorage)
                                [userInfo addContactInfoListObject: infoStorage];
                }
        }
        
        if([contactObj.arrayInternetInfo count])
        {
                [userInfo removeInternetInfoList:userInfo.internetInfoList];
                for (dict in contactObj.arrayInternetInfo) {
                        
                        infoStorage = [self InsertInfoFromDictionary:moc info:dict];
                        if(infoStorage)
                                [userInfo addInternetInfoListObject: infoStorage];
                }
        }
        
        if([contactObj.arraySocialInfo count])
        {
                [userInfo removeSocialInfoList:userInfo.socialInfoList];
                for (dict in contactObj.arraySocialInfo) {
                        
                        infoStorage = [self InsertInfoFromDictionary:moc info:dict];
                        if(infoStorage)
                                [userInfo addSocialInfoListObject: infoStorage];
                }
        }
        
        return TRUE;
}

- (LocationCoreData*) InsertLocationFromDictionary:(NSManagedObjectContext*)moc locationStorage:(LocationCoreData*)locationStorage location:(NSDictionary*)location {
        
        if(!location || ![location isKindOfClass:[NSDictionary class]])
                return locationStorage;
        
        if(!locationStorage)
                locationStorage = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([LocationCoreData class]) inManagedObjectContext:moc];
        
        NSString * str;
        NSNumber * num;
        
        str = [location objectForKey:g_city];
        if(str && [str isKindOfClass:[NSString class]])
                locationStorage.city = str;
        
        str = [location objectForKey:g_country];
        if(str && [str isKindOfClass:[NSString class]])
                locationStorage.country = str;
        
        num = [location objectForKey:g_countryId];
        if(num && [num isKindOfClass:[NSNumber class]])
                locationStorage.countryId = num;
        
        str = [location objectForKey:g_state];
        if(str && [str isKindOfClass:[NSString class]])
                locationStorage.state = str;
        
        str = [location objectForKey:g_stateAbbrev];
        if(str && [str isKindOfClass:[NSString class]])
                locationStorage.stateAbbrev = str;
        
        num = [location objectForKey:g_stateId];
        if(num && [num isKindOfClass:[NSNumber class]])
                locationStorage.stateId = num;
        
        str = [location objectForKey:g_timeZone];
        if(str && [str isKindOfClass:[NSString class]])
                locationStorage.timeZone = str;
        
        return locationStorage;
}

- (LocationCoreData*) InsertLocationFromContactObject:(NSManagedObjectContext*)moc locationStorage:(LocationCoreData*)locationStorage contact:(ContactObject*)contactObj {
        
        if(!contactObj)
                return locationStorage;
        
        if(!locationStorage)
                locationStorage = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([LocationCoreData class]) inManagedObjectContext:moc];
        
        locationStorage.city = contactObj.City;
        locationStorage.country = contactObj.country.countryName;
        locationStorage.countryId = [NSNumber numberWithInt: [contactObj.country.countryID intValue]];
        locationStorage.state = contactObj.state.stateName;
        locationStorage.stateAbbrev = contactObj.state.stateAbbrev;
        locationStorage.stateId = [NSNumber numberWithInt: [contactObj.state.stateID intValue]];
        locationStorage.timeZone = contactObj.TimeZone;
        
        return locationStorage;
}

- (UserLanguageCoreData*) InsertUserLanguageFromDictionary:(NSManagedObjectContext*)moc languageStorage:(UserLanguageCoreData*)languageStorage language:(NSDictionary*)language {
        
        if(!language || ![language isKindOfClass:[NSDictionary class]])
                return languageStorage;
        
        if(!languageStorage)
                languageStorage = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([UserLanguageCoreData class]) inManagedObjectContext:moc];
        
        NSString * str;
        
        str = [language objectForKey:g_primary];
        if(str && [str isKindOfClass:[NSString class]])
                languageStorage.primary = str;
        
        str = [language objectForKey:g_second];
        if(str && [str isKindOfClass:[NSString class]])
                languageStorage.secondary = str;
        
        str = [language objectForKey:g_third];
        if(str && [str isKindOfClass:[NSString class]])
                languageStorage.third = str;
        
        str = [language objectForKey:g_fourth];
        if(str && [str isKindOfClass:[NSString class]])
                languageStorage.fourth = str;
        
        return languageStorage;
}

- (UserLanguageCoreData*) InsertUserLanguageFromContactObject:(NSManagedObjectContext*)moc languageStorage:(UserLanguageCoreData*)languageStorage contact:(ContactObject*)contactObj {
        
        if(!contactObj)
                return languageStorage;
        
        if(!languageStorage)
                languageStorage = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([UserLanguageCoreData class]) inManagedObjectContext:moc];
        
        languageStorage.primary = contactObj.LanguagePrimary;
        languageStorage.secondary = contactObj.LanguageSecond;
        languageStorage.third = contactObj.LanguageThird;
        languageStorage.fourth = contactObj.LanguageFourth;
        
        return languageStorage;
}

- (InfoCoreData*) InsertInfoFromDictionary:(NSManagedObjectContext*)moc info:(NSDictionary*)info {
        
        if(!info || ![info isKindOfClass:[NSDictionary class]])
                return nil;
        
        InfoCoreData *infoStorage = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([InfoCoreData class]) inManagedObjectContext:moc];
        
        NSString * str;
        
        str = [info objectForKey:g_itemName];
        if(str && [str isKindOfClass:[NSString class]])
                infoStorage.name = str;
        
        str = [info objectForKey:g_itemValue];
        if(str && [str isKindOfClass:[NSString class]])
                infoStorage.value = str;
        
        return infoStorage;
}

- (UserStatusCoreData*) InsertUserStatusFromDictionary:(NSManagedObjectContext*)moc statusStorage:(UserStatusCoreData*)statusStorage status:(NSDictionary*)status {
        
        if(!status || ![status isKindOfClass:[NSDictionary class]])
                return statusStorage;
        
        if(!statusStorage)
                statusStorage = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([UserStatusCoreData class]) inManagedObjectContext:moc];
        
        NSString * str;
        str = [status objectForKey:g_subscription];
        if(str && [str isKindOfClass:[NSString class]])
               statusStorage.subscription = str;
        
        str = [status objectForKey:g_type]?[status objectForKey:g_type]:[status objectForKey:g_status];
        if(str && [str isKindOfClass:[NSString class]])
        {
                if([str isEqualToString:@"available"]||[str isEqualToString:@"online"])
                        statusStorage.isOnline = [NSNumber numberWithInt:online_Status_Online];
                else if ([str isEqualToString:@"unavailable"]||[str isEqualToString:@"offline"])
                        statusStorage.isOnline = [NSNumber numberWithInt:online_Status_Offline];
                else
                        statusStorage.isOnline = [NSNumber numberWithInt:online_Status_Away];
        }
        
        return statusStorage;
}

- (UserStatusCoreData*) InsertUserStatusFromContactObject:(NSManagedObjectContext*)moc statusStorage:(UserStatusCoreData*)statusStorage contact:(ContactObject*)contactObj {
        
        if(!contactObj)
                return statusStorage;
        
        if(!statusStorage)
                statusStorage = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([UserStatusCoreData class]) inManagedObjectContext:moc];
        
        switch(contactObj.contactType){
                case Contact_Type_MY_Seequ_Contact:
                        statusStorage.subscription = @"both";
                        break;
                case Contact_Type_Request_For_Connection:
                        statusStorage.subscription = @"from";
                        break;
                case Contact_Type_Request_Connection:
                        statusStorage.subscription = @"to";
                        break;
                default:
                        statusStorage.subscription = @"none";
        }
        statusStorage.isOnline = [NSNumber numberWithInt:contactObj.isOnline];
        
        return statusStorage;
}

- (void) PrintDB {
        
        NSError* error;
        NSManagedObjectContext *moc = [CoreDataManager managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([UserInfoCoreData class]) inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
    
        NSArray *items = [moc executeFetchRequest:fetchRequest error:&error];
        
        for (UserInfoCoreData* userInfo in items)
        {
                [self PrintUserInfo: userInfo];
        }
}

- (void) PrintUserInfo:(UserInfoCoreData*)userInfo {
        
        if(!userInfo)
                return;
        
        NSLog(@"seeQuId: %@ ==========================", userInfo.seeQuId);
        NSLog(@"firstName: %@", userInfo.firstName);
        NSLog(@"lastName: %@", userInfo.lastName);
        NSLog(@"email: %@", userInfo.email);
        NSLog(@"title: %@", userInfo.title);
        NSLog(@"introduction: %@", userInfo.introduction);
        NSLog(@"regDate: %@", userInfo.regDate);
        NSLog(@"isImageExist: %@", userInfo.isImageExist);
        NSLog(@"bio: %@", userInfo.bio);
        
        NSLog(@"-------------- status --------------------");
        NSLog(@"subscribtion: %@", userInfo.status.subscription);
        NSLog(@"type: %@", userInfo.status.isOnline);
        NSLog(@"-------------- ------------ --------------");
        
        [self PrintLocation: userInfo.location];
        [self PrintLanguage: userInfo.userLanguage];
        
        InfoCoreData* info;
        NSLog(@"-------------- contactInfo ---------------");
        for(info in userInfo.contactInfoList){
                [self PrintInfo:info];
        }
        NSLog(@"-------------- ------------ --------------");
        NSLog(@"-------------- internetInfo --------------");
        for(info in userInfo.internetInfoList){
                [self PrintInfo:info];
        }
        NSLog(@"-------------- ------------ --------------");
        NSLog(@"-------------- socialInfo ----------------");
        for(info in userInfo.socialInfoList){
                [self PrintInfo:info];
        }
        NSLog(@"-------------- ------------ --------------");
}

- (void) PrintLocation:(LocationCoreData*)location{
        
        if(!location)
                return;
        
        NSLog(@"-------------- location ------------------");
        NSLog(@"city: %@", location.city);
        NSLog(@"country: %@ countryId: %@", location.country, location.countryId);
        NSLog(@"state: %@ stateAbbrev: %@ stateId %@", location.state, location.stateAbbrev, location.stateId);
        NSLog(@"timeZone: %@", location.timeZone);
        NSLog(@"-------------- ----------- ---------------");
}

- (void) PrintLanguage:(UserLanguageCoreData*)language {
        
        if(!language)
                return;
        
        NSLog(@"-------------- language ------------------");
        NSLog(@"primary: %@", language.primary);
        NSLog(@"secondary: %@", language.secondary);
        NSLog(@"third: %@", language.third);
        NSLog(@"fourth: %@", language.fourth);
        NSLog(@"-------------- ----------- ---------------");
}

- (void) PrintInfo:(InfoCoreData*)info {
        
        if(!info)
                return;
        
        NSLog(@"name: %@ value: %@", info.name, info.value);
}

#pragma mark -Managed Object Model Initialization-
+ (ContactStorage*) sharedInstance
{
        if (g_contactStorage == nil)
                g_contactStorage = [[ContactStorage alloc] init];
        
        return g_contactStorage;
}


- (void)_mocDidSaveNotification:(NSNotification *)notification {
        NSManagedObjectContext *savedContext = [notification object];
        NSManagedObjectContext *managedObjectContext=[CoreDataManager managedObjectContextForMainThread];
        // ignore change notifications for the main MOC
        if (managedObjectContext == savedContext)
        {
                return;
        }
        
        if (managedObjectContext.persistentStoreCoordinator != savedContext.persistentStoreCoordinator)
        {
                // that's another database
                return;
        }
           NSError *error;
//        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [managedObjectContext lock];
                [managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
                [managedObjectContext save:&error];
                [managedObjectContext unlock];
        
                
                
//        });
}
-(void)deleteContactStorage{
        [self deleteEntity:[CoreDataManager managedObjectContext] andEntityName:NSStringFromClass([UserInfoCoreData class])];
}

@end

