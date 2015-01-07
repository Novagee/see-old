        //
//  Common.m
//  ProTime
//

//#define BASE_LINK @"http://192.168.0.80:3128/"
//#define BASE_LINK @"http://tommy.protime.tv:8080/seequ/"
//#define BASE_LINK @"http://192.168.0.222:8080/seequ/"

#define SEEQU_SERVICES @"https://sip.protime.tv:8443/seequServices"
//#define SEEQU_SERVICES @"http://192.168.0.222:8080/seequServices"

//#define SEEQU_SERVICES @"http://10.10.50.25:8080/seequServices"

#define kREQUESTS @"kREQUESTS"
#define kRECENTS @"kRECENTS"
#define kCONTACTLIS @"kCONTACTLIS"





#define REQUEST_TIME_OUT 20
#define LOGIN_FAILED_TIME_OUT 600

#import "Common.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "MissedEventObject.h"
#include "TBI_rsa.h"
#include "TBI_base64.h"
#import "SeequCountry.h"
#import "SeequState.h"
#import "SeequTimeZoneInfo.h"
#import "NSURLRequest+IgnoreSSL.h"
#import "ContactStorage.h"
#import "Activitystorage.h"
#import "idoubs2AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "RTMPChatManager.h"
#import "MessageCoreDataManager.h"

@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end

@implementation NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
}
@end


@implementation SeequMessageObject

-(id) initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.from   = [dictionary objectForKey:@"to"];
        self.msgId  = [dictionary objectForKey:@"msgId"];
        self.type   = [((NSNumber*)[dictionary objectForKey:@"msgType"]) intValue];
        self.msg    = [dictionary objectForKey:@"msg"];
        self.url    = [dictionary objectForKey:@"url"];
        self.url_dt = [dictionary objectForKey:@"url_dt"];
    }
    return self;
}
@end

@implementation Common

@synthesize contactObject = _contactObject;
@synthesize SeequID;
@synthesize email;
@synthesize arrayStates;
@synthesize arrayCountries;
@synthesize MissedEvents;
@synthesize login_failed_time;
@synthesize arrayFavorites;

static Common *sharedCommon;

+ (Common *) sharedCommon {
	@synchronized([Common class])
	{
		if (!sharedCommon) {
			sharedCommon = [[Common alloc] init];
            [[NSNotificationCenter defaultCenter] addObserver:sharedCommon
                                                     selector:@selector(onUpdateContact:)
                                                         name:@"UPDATE"
                                                       object:nil];
        }
        
		return sharedCommon;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized([Common class])
	{
		NSAssert(sharedCommon == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedCommon = [super alloc];
		return sharedCommon;
	}
	// to avoid compiler warning
	return nil;
}

- (NSString*)SeequID {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"IDENTITY_IMPI"];
}

+ (NSString*) LoginWithSeequID:(NSString*)seequID Password:(NSString*)password {
	NSString *urlString = [NSString stringWithFormat:@"%@/j_spring_security_check", [Common getBaseTomcatLink]];
    RSLog(@"[HTTP][SEND] {LoginWithSeequID} - %@", urlString);
    
    NSError *error;
    NSHTTPURLResponse * response;
    
    NSString *encodedParameterPairs = [NSString stringWithFormat:@"j_username=%@&j_password=%@", seequID, password];
    NSData *requestData = [encodedParameterPairs dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *requestWithBodyParams = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                     timeoutInterval:10];
    [requestWithBodyParams setHTTPMethod:@"POST"];
    [requestWithBodyParams setHTTPBody:requestData];
    [requestWithBodyParams setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [requestWithBodyParams setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSData * data = [NSURLConnection sendSynchronousRequest:requestWithBodyParams returningResponse:&response error:&error];
    
//    NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    if (!error && data) {
        NSError *error = nil;
        NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        
        if (!error && dict) {
                
            NSString *auth = [dict objectForKey:@"message"];
            RSLogHTTP(@"[RCV] {LoginWithSeequID} - %@", auth);
            if ( [[dict objectForKey:@"success"] intValue] == 1) {
                return nil;
            } else {
                [Common sharedCommon].login_failed_time = [[NSDate date] timeIntervalSince1970];
                return auth;
            }
        }
    }
    
    return nil;
}
+(NSString*)changePassword:(NSString*)newPassword{
       NSString *urlString = [NSString stringWithFormat:@"%@/resetPassword/sendChangePassEmail?newPassword=%@", [Common getBaseTomcatLink],newPassword];
        NSString * error_description;
        NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:60 ErrorMessage:&error_description];
        if (error_description) {
                return error_description;
        }
        NSError *error = nil;
        NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        if (!error && dict) {
                NSString *auth = [dict objectForKey:@"message"];
                if ([[dict objectForKey:@"success"] intValue] == 1) {
                        return nil;
                }else{
                        return auth;
                }
        }
        return nil;
}
+(NSString*) getBaseTomcatLink {
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDef boolForKey:DEVELOPER_MODE];
    if (!flag) {
//        return @"http://192.168.0.222:8080/seequ";
        return  @"https://tommy.protime.tv:8443/seequ";
    } else {
        flag = [userDef boolForKey:TOMCAT_DEBUG];
        if (!flag) {
//            return @"http://192.168.0.222:8080/seequ";
        return @"https://tommy.protime.tv:8443/seequ";
        }
        NSString* str = [userDef stringForKey:TOMCAT_SERVER];
        if (!str) {
            str = @"192.168.0.250";
        }
        return [NSString stringWithFormat:@"https://%@:8443/seequ",str];
    }
}


+(NSString*) getBaseSIPLink {
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDef boolForKey:DEVELOPER_MODE];
    if (!flag) {
        return @"sip.protime.tv";
    } else {
        flag = [userDef boolForKey:RTMP_DEBUG];
        if (!flag) {
            return @"sip.protime.tv";
        }
        NSString* str = [userDef stringForKey:SIP_SERVER];
        if (!str) {
            str = @"10.20.0.22";
        }
        return str;
    }
}

+(NSString*) getBaseRTMPLink {
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDef boolForKey:DEVELOPER_MODE];
    if (!flag) {
        return @"uvc.protime.tv";
    } else {
        flag = [userDef boolForKey:RTMP_DEBUG];
        if (!flag) {
            return @"uvc.protime.tv";
        }
        NSString* str = [userDef stringForKey:RTMP_SERVER];
        if (!str) {
            str = @"10.20.0.13";
        }
        return str;
    }
}
+ (NSDictionary*) GetOnlineUsers{
        NSString *url=[NSString stringWithFormat:@"%@/user/getOnlineUsers?seeQuId=%@",[Common getBaseTomcatLink],[Common sharedCommon].SeequID];
        NSString * error_description;
        NSData *data = [Common SendSynchronousRequestWithURL:url TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
        if (error_description) {
                RSLogHTTP(@"[ERR] {GetAllUsersBySeequID} - %@", error_description);
                return nil;
        }
        
        NSError *error = nil;
        
        NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        
        if (error) {
                error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
                RSLogHTTP(@"[ERR] {GetAllUsersBySeequID} - %@", error_description);
                return nil;
        }
        return dict;
}
+ (NSString*) GetAllUsersBySeequID:(NSString*)seequID {
    NSString*  ownSeequID = [Common sharedCommon].SeequID;
    NSString *urlString  = nil;
    if ([ownSeequID isEqualToString:seequID]) {
        urlString =[NSString stringWithFormat:@"%@/user/getUpdatedContacts?lastModDate=-1", [Common getBaseTomcatLink]];
    } else {
        urlString = [NSString stringWithFormat:@"%@/user/getUpdatedContacts?seeQuId=%@&lastModDate=-1", [Common getBaseTomcatLink], seequID];
    }
     RSLogHTTP(@"[SEND] {GetAllUsersBySeequID} - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
//    NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {GetAllUsersBySeequID} - %@", error_description);
        return error_description;
    }
    
    NSError *error = nil;
    
    NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        RSLogHTTP(@"[ERR] {GetAllUsersBySeequID} - %@", error_description);
        return error_description;
    }
    
    RSLogHTTP(@"[RCV] {GetAllUsersBySeequID} - %@", dict);
    if ([[dict objectForKey:@"success"] intValue] == 1) {
            NSDictionary *return_values = [dict objectForKey:@"return_values"];
            [Common sharedCommon].arrayFavorites=[[NSMutableArray alloc] initWithArray:[return_values objectForKey:@"favorites"]];
            NSLog(@"favorits list %@",[Common sharedCommon].arrayFavorites);
            NSArray *users = [return_values objectForKey:@"users"];
            [[ContactStorage sharedInstance] InsertContactsFromArray:users];
//            if (save) {
//            [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCONTACTLIS];
//        }
    }
        
    
    return nil;
}

+ (NSString*) GetUpdatedUsersBySeequID:(NSString*)seequID LastModDate:(double)modDate UserList:(NSDictionary**)dictionary {
//	NSString *urlString = [NSString stringWithFormat:@"%@user/getUpdatedContacts?seeQuId=%@&lastModDate=%.0f", BASE_LINK, seequID, modDate];
    NSString*  ownSeequID = [Common sharedCommon].SeequID;
    NSString *urlString  = nil;
    if ([ownSeequID isEqualToString:seequID]) {
        urlString =[NSString stringWithFormat:@"%@/user/getUpdatedContacts?lastModDate=%.0f", [Common getBaseTomcatLink], modDate];
    } else {
        urlString = [NSString stringWithFormat:@"%@/user/getUpdatedContacts?seeQuId=%@&lastModDate=%.0f", [Common getBaseTomcatLink], seequID, modDate];
    }
    
    RSLogHTTP(@"[SEND] {GetUpdatedUsersBySeequID} - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
//    NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {GetUpdatedUsersBySeequID} - %@", error_description);
        return error_description;
    }
    
    NSError *error = nil;
    
    NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        RSLogHTTP(@"[ERR] {GetUpdatedUsersBySeequID} - %@", error_description);
        return error_description;
    }
    
    RSLogHTTP(@"[RCV] {GetUpdatedUsersBySeequID} - %@", dict);
    if ([[dict objectForKey:@"success"] intValue] == 1) {
        *dictionary = dict;
           
    }
    
    return nil;
}

+ (int) GetContactCountWithSeequID:(NSString*)seequID {
	NSString *urlString = [NSString stringWithFormat:@"%@/user/getContactsCount?seeQuId=%@", [Common getBaseTomcatLink], seequID];
    RSLogHTTP(@"[SEND] {GetContactCountWithSeequID} - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
//    NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {GetContactCountWithSeequID} - %@", error_description);
        return 0;
    }
    
    NSError *error = nil;
    
    NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        RSLogHTTP(@"[ERR] {GetContactCountWithSeequID} - %@", error_description);
        return error_description;
    }
    
    RSLogHTTP(@"[RCV] {GetContactCountWithSeequID} - %@", dict);
    if ([[dict objectForKey:@"success"] intValue] == 1) {
        return [[dict objectForKey:@"return_values"] integerValue];
    }
    
    return 0;
}

//+ (NSArray*) GetSavedContactList {
//    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCONTACTLIS];
//    
//    NSError *error = nil;
//    
//    NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
//    
//    if (error) {
//        return nil;
//    }
//    
//    if ([[dict objectForKey:@"success"] intValue] == 1) {
//        NSDictionary *return_values = [dict objectForKey:@"return_values"];
//        [Common sharedCommon].arrayFavorites=[[NSMutableArray alloc] initWithArray:[return_values objectForKey:@"favorites"]];
//            NSLog(@"favorits list %@",[Common sharedCommon].arrayFavorites);
//        NSArray *users = [return_values objectForKey:@"users"];
////        [[ContactStorage sharedInstance] InsertContactsFromArray:users];
//        return users;
//    }
//
//    return nil;
//}

//+ (void) AddUserToSavedContactListWithSeequID:(NSDictionary*)userDict {
//    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCONTACTLIS];
//    
//    NSError *error = nil;
//    
//    NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
//    
//    if (error) {
//        return;
//    }
//    
//    if ([[dict objectForKey:@"success"] intValue] == 1) {
//        NSMutableDictionary *m_dict = [[NSMutableDictionary alloc] initWithDictionary:dict];
//        NSMutableDictionary *m_return_values = [[NSMutableDictionary alloc] initWithDictionary:[m_dict objectForKey:@"return_values"]];
//        
//        NSArray *array = [m_return_values objectForKey:@"users"];
//        NSMutableArray *m_array = [[NSMutableArray alloc] initWithArray:array];
//        
//        [m_array addObject:userDict];
//        
//        [m_return_values setObject:m_array forKey:@"users"];
//        [m_dict setObject:m_return_values forKey:@"return_values"];
//        
//        NSString *serialized_string = [[CJSONSerializer serializer] serializeDictionary:m_dict];
//        NSData *added_data = [serialized_string dataUsingEncoding:NSUTF8StringEncoding];
//        [[NSUserDefaults standardUserDefaults] setObject:added_data forKey:kCONTACTLIS];
//    }
//}
//+(void)addOrRemovecContactInFavoriteList:(BOOL)add withSeequID:(NSString*)SeequID{
//        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCONTACTLIS];
//        
//        NSError *error = nil;
//        
//        NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
//        
//        if (error) {
//                return;
//        }
//        
//        if ([[dict objectForKey:@"success"] intValue] == 1) {
//                NSMutableDictionary *m_dict = [[NSMutableDictionary alloc] initWithDictionary:dict];
//                NSMutableDictionary *m_return_values = [[NSMutableDictionary alloc] initWithDictionary:[m_dict objectForKey:@"return_values"]];
//                NSMutableArray *m_array=[[NSMutableArray alloc]initWithArray:[m_return_values objectForKey:@"favorites"]];
//                if (add) {
//                        [m_array addObject:SeequID];
//                }else{
//                        [m_array removeObject:SeequID];
//                }
//                [Common sharedCommon].arrayFavorites=[[NSMutableArray alloc] initWithArray:m_array];
//                [m_return_values setObject:m_array forKey:@"favorites"];
//                [m_dict setObject:m_return_values forKey:@"return_values"];
//                NSString *serialized_string = [[CJSONSerializer serializer] serializeDictionary:m_dict];
//                NSData *added_data = [serialized_string dataUsingEncoding:NSUTF8StringEncoding];
//                [[NSUserDefaults standardUserDefaults] setObject:added_data forKey:kCONTACTLIS];
//        }
//}
//+ (void) RemoveUserFromSavedContactListWithSeequID:(NSString*)seequID {
//    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCONTACTLIS];
//    
//    NSError *error = nil;
//    
//    NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
//    
//    if (error) {
//        return;
//    }
//    
//    if ([[dict objectForKey:@"success"] intValue] == 1) {
//        NSMutableDictionary *m_dict = [[NSMutableDictionary alloc] initWithDictionary:dict];
//        NSMutableDictionary *m_return_values = [[NSMutableDictionary alloc] initWithDictionary:[m_dict objectForKey:@"return_values"]];
//        
//        NSArray *array = [m_return_values objectForKey:@"users"];
//        NSMutableArray *m_array = [[NSMutableArray alloc] initWithArray:array];
//        
//        for (NSDictionary *user_dict in m_array) {
//            NSString *user_seequID = [user_dict objectForKey:@"seeQuId"];
//            
//            if ([user_seequID isEqualToString:seequID]) {
//                [m_array removeObject:user_dict];
//                
//                break;
//            }
//        }
//        
//        [m_return_values setObject:m_array forKey:@"users"];
//        [m_dict setObject:m_return_values forKey:@"return_values"];
//        
//        NSString *serialized_string = [[CJSONSerializer serializer] serializeDictionary:m_dict];
//        NSData *removed_data = [serialized_string dataUsingEncoding:NSUTF8StringEncoding];
//        [[NSUserDefaults standardUserDefaults] setObject:removed_data forKey:kCONTACTLIS];
//    }
//}

+ (int) GetProfileInfoByPTID:(NSString*)seequID withActivityBadgCount:(BOOL)badg {
    Common *common = [Common sharedCommon];
    common.SeequID = seequID;
    common.MissedEvents = [[NSMutableDictionary alloc] init];
    
    NSDictionary *catched_Dict = [Common GetLastCatchedInfoWithSeequID:seequID];
     NSDictionary* dic = [catched_Dict objectForKey:@"rateData"];
    if (catched_Dict && dic) {
       
        [Common SetProfileDataByDictionary:catched_Dict];
        [Common SetProfileImageByPTID:seequID];
    } else {
    
        NSDictionary *dictUserDetails = [Common GetProfileData:seequID];

        if (dictUserDetails) {
            [Common SetProfileDataByDictionary:dictUserDetails];
            [Common SetProfileImageByPTID:seequID];
       //     common.arrayStates = [Common GetAllStates];
            
        }
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"id"  ascending:YES];
    [common.arrayStates sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    NSSortDescriptor* descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"countryID"  ascending:YES];
    common.arrayCountries = [Common GetAllCountries];
    [common.arrayCountries sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor1,nil]];

    
    return 0;
}

///@note  needn't change seequID
+ (NSDictionary*) GetProfileData:(NSString*)userId {
    NSData *data;
    NSString *stringURL = [NSString stringWithFormat:@"%@/user/getProfileData?seeQuId=%@", [Common getBaseTomcatLink], userId];
    NSURL *url = [NSURL URLWithString:stringURL];
    data = [[NSData alloc] initWithContentsOfURL:url];

    if (data && [data isKindOfClass:[NSData class]]) {
        NSError *error = nil;
        NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        if ([[dictionary objectForKey:@"success"] intValue] == 1) {
            NSDictionary *dict = [dictionary objectForKey:@"return_values"];
            
            NSString *key = [NSString stringWithFormat:@"userdetail%@", [Common sharedCommon].SeequID];
            [Common SaveDataWithData:data key:key];
            return dict;
        }
    }
    return nil;
}



+ (void) SetProfileDataByDictionary:(NSDictionary*)dict {
    NSLog(@"JSC - SetProfileDataByDictionary:%@", dict);
    Common *common = [Common sharedCommon];
    common.contactObject = [[ContactObject alloc] initWithSeequID:[dict objectForKey:@"seeQuId"]];
    UserInfoCoreData* userData;// JSC = [[ContactStorage sharedInstance] getUserInfoBySeequId:common.contactObject.SeequID];
    [[ContactStorage sharedInstance] InsertContactFromDictionary:dict];

    userData = [[ContactStorage sharedInstance] getUserInfoBySeequId:common.contactObject.SeequID];
    NSLog(@"JSC - userData:%@", userData);
    
//  JSC  NSAssert(userData, @"MUST BE exists");
//  JSC  if (!userData.userImage) {
    if (userData && !userData.userImage) {
        [[ContactStorage sharedInstance] getImageBySeequId:userData.seeQuId success:^(UIImage *image) {
            [[ContactStorage sharedInstance] SetImageBySeequId:userData.seeQuId image:image];
        }];
    }
    
  

    [common.contactObject SetUserInfoWithDictionary:dict];
}

+ (void) SetProfileImageByPTID:(NSString*)ptID {
    Common *common = [Common sharedCommon];
    NSData *imageData;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
        //Retina display
        imageData = [Common GetLastCatchedImageWithSeequID:ptID Height:320];
    } else {
        imageData = [Common GetLastCatchedImageWithSeequID:ptID Height:160];
    }
    
    if (imageData) {
        common.contactObject.image = [[UIImage alloc] initWithData:imageData];
        [Common postNotificationWithName:@"ProfileInfo" object:nil];
    }
    
    UIImage *image = [Common GetImageByPTID:ptID andHeight:160];
    if (image) {
        common.contactObject.image = [Common GetImageByPTID:ptID andHeight:160];
    }
    
    [Common postNotificationWithName:@"ProfileInfo" object:nil];
}

+ (NSMutableDictionary*) GetUserDetailsByPTID:(NSString*)seequID {
    NSData *data;
    NSString *stringURL = [NSString stringWithFormat:@"%@/user/getProfileData?seeQuId=%@", [Common getBaseTomcatLink], seequID];
    NSURL *url = [NSURL URLWithString:stringURL];
    data = [[NSData alloc] initWithContentsOfURL:url];
    
    if (data && [data isKindOfClass:[NSData class]]) {
        NSError *error = nil;
        NSMutableDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        
        if ([[dictionary objectForKey:@"success"] intValue] == 1) {
            return [dictionary objectForKey:@"return_values"];
        }
    }
    
    return nil;
}

+(void) GetUserDetailsBySeequId:(NSString*) seequID success:(void (^)(NSMutableDictionary * dict))success {
    @autoreleasepool {
        NSData *data;
        NSString *stringURL = [NSString stringWithFormat:@"%@/user/getProfileData?seeQuId=%@", [Common getBaseTomcatLink], seequID];
        NSURL *url = [NSURL URLWithString:stringURL];
        data = [[NSData alloc] initWithContentsOfURL:url];
        
        if (data && [data isKindOfClass:[NSData class]]) {
            NSError *error = nil;
            NSMutableDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
            
            if ([[dictionary objectForKey:@"success"] intValue] == 1) {
                 success( [dictionary objectForKey:@"return_values"]);
            } else {
                success (nil);
            }
        } else {
            success(nil);
        }
    }
}

+(void) getUserBalance:(void (^)(NSMutableDictionary * dict))success {
    @autoreleasepool {
        NSData *data;
        NSString *stringURL = [NSString stringWithFormat:@"%@/user/getBalance", [Common getBaseTomcatLink]];
        NSURL *url = [NSURL URLWithString:stringURL];
        data = [[NSData alloc] initWithContentsOfURL:url];
        
        if (data && [data isKindOfClass:[NSData class]]) {
            NSError *error = nil;
            NSMutableDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
            
            if ([[dictionary objectForKey:@"success"] intValue] == 1) {
                success( [dictionary objectForKey:@"return_values"]);
            } else {
                success (nil);
            }
        }
    }
}


+ (UIImage*) GetImageByPTID:(NSString*)seequID andHeight:(int)height {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
        //Retina display
        height *= 2;
    }
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/image/show?seeQuId=%@&width=%d&height=%d", [Common getBaseTomcatLink], seequID, height,height]]];
    
    UIImage *retValImage;
    
    if (!imageData || ![imageData bytes]) {
        retValImage = [UIImage imageNamed:@"GenericContact.png"];
    } else {
        retValImage = [[UIImage alloc] initWithData:imageData];
        ///@todo remove cash  in userdefaults
     //   [Common SaveDataWithData:imageData key:[NSString stringWithFormat:@"imagekey%@%d", seequID, height]];
    }
    
    [[Common sharedCommon]->arrayOnRequestedContactObjects removeObject:seequID];
    return retValImage;
}

+ (void) saveVideoToFolder:(NSData*)video contact:(NSString*) contactID message:(NSString*) messageID{
    NSString *imageToSaveFolder = [Common makeFolderIfNotExist:contactID];
    
    if (!imageToSaveFolder) {
        return;
    }
    
    
    NSString *videoPath = [imageToSaveFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_video.mp4", messageID]];
    [video writeToFile:videoPath options:NSAtomicWrite error:nil];
}


+ (UIImage*) imageFromSavedFileWithContact:(NSString*)contactID message:(NSString*) messageID{
    NSString *imageToSaveFolder = [Common makeFolderIfNotExist:contactID];
    
    if (!imageToSaveFolder) {
        return nil;
    }
    
    
    NSString *imageFileName = [NSString stringWithFormat:@"%@_image.png", messageID];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *folderList = [fileManager subpathsOfDirectoryAtPath:imageToSaveFolder  error:nil];
    for (NSString *file in folderList) {
        if ([file isEqualToString:imageFileName]) {
            NSString *imageFilePath = [imageToSaveFolder stringByAppendingPathComponent:file];
            NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath];
            UIImage *messageIm = [UIImage imageWithData:imageData];
            
            NSLog(@"DEBUG: [messages] cached image is available - %@", imageFilePath);
            return messageIm;
        }
    }
    
    return nil;
}


+ (NSString*) makeFolderIfNotExist:(NSString*) contactId{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *imageFolderPath =  [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_IMAGES", contactId]];
    
    BOOL isDir = NO;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:imageFolderPath isDirectory:(&isDir)];
    if (exist || isDir) {
        NSArray *folderList = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:imageFolderPath  error:nil];
        
        if (folderList && folderList.count > 10) {
            NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedCompare:)];
            NSArray* sortedArray = [folderList sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            NSString *filePathForDelete = [imageFolderPath stringByAppendingPathComponent:[sortedArray objectAtIndex:0]];
            [[NSFileManager defaultManager] removeItemAtPath:filePathForDelete error:nil];
            NSLog(@"DEBUG: [messages] image folders count(%d) > 10, removing the last - %@", folderList.count, filePathForDelete);
        }
        NSLog(@"DEBUG: [messages] image folder exists - %@", imageFolderPath);
        return imageFolderPath;
    } else {
        BOOL maked= [[NSFileManager defaultManager] createDirectoryAtPath:imageFolderPath
                                              withIntermediateDirectories:NO
                                                               attributes:nil
                                                                    error:nil];
        if (maked) {
            NSLog(@"DEBUG: [messages] image folder created - %@", imageFolderPath);
            return imageFolderPath;
        }
    }
    
    return nil;
}


+ (NSString*) makeDTFolder{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString * DTPath =  [documentsDir stringByAppendingPathComponent:@"DT"];
    
    BOOL isDir = NO;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:DTPath isDirectory:(&isDir)];
    if (!(exist || isDir)) {
        BOOL maked= [[NSFileManager defaultManager] createDirectoryAtPath:DTPath
                                              withIntermediateDirectories:NO
                                                               attributes:nil
                                                                    error:nil];
        if (!maked) {
            NSLog(@"DEBUG: [messages] image folder created - %@", DTPath);
            return nil;
        }
    }
    
    return DTPath;
}



+ (NSString*) GetSeequIDByEmail:(NSString*)mail SeequID:(NSString**)seequID {
    NSString *urlString = [NSString stringWithFormat:@"%@/user/isAccountExists?email=%@",[Common getBaseTomcatLink], mail];
    RSLogHTTP(@"[SEND] {GetSeequIDByEmail} - %@", urlString);

    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
       RSLogHTTP(@"[ERR] {GetSeequIDByEmail} - %@", error_description);
        return error_description;
    }
    
    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];

    if (error) {
        RSLogHTTP(@"[ERR] {GetSeequIDByEmail} - %@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]);
        return @"Invalid data from server.";
    }
    
    RSLogHTTP(@"[RCV] {GetSeequIDByEmail} - %@", dictionary);
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
		*seequID = [dictionary objectForKey:@"return_values"];
    } else {
        if ([[dictionary objectForKey:@"success"] intValue] == 0) {
            return [dictionary objectForKey:@"message"];
        }
    }
    
    return nil;
}

+ (NSString*) CreateValidString:(NSString*)string {
    NSString *retVal;
    if ([string isKindOfClass:[NSNull class]]) {
        retVal = @" ";
        return retVal;
    }
    
    if (!string) {
        retVal = @" ";
        return retVal;
    }
    
    return string;
}

+ (NSString*)ConvertDurationToString:(int)duration {
    NSString *str;
    int houres = 0;
    int minutes = 0;
    int secondes = 0;
    
    if (duration >= 3600) {
        houres = duration / 3600;
        duration = duration % 3600;
    }
    
    if (duration >= 60) {
        minutes = duration / 60;
        duration = duration % 60;
    }
    
    secondes = duration;
    
    if (houres != 0) {
        str = [NSString stringWithFormat:@"     %d hour %d min %d sec", houres, minutes, secondes];
    } else {
        if (minutes != 0) {
            str = [NSString stringWithFormat:@"     %d min %d sec", minutes, secondes];
        } else {
            str = [NSString stringWithFormat:@"     %d sec", secondes];
        }
    }
    
    return str;
}

+ (NSString*)ConvertDurationToStringNoZero:(int)duration {
    NSString *str;
    int houres = 0;
    int minutes = 0;
    int secondes = 0;
    
    if (duration >= 3600) {
        houres = duration / 3600;
        duration = duration % 3600;
    }
    
    if (duration >= 60) {
        minutes = duration / 60;
        duration = duration % 60;
    }
    
    secondes = duration;
    
    if (houres != 0) {
        str = [NSString stringWithFormat:@"%02d:%02d:%02d", houres, minutes, secondes];
    } else {
        if (minutes != 0) {
            str = [NSString stringWithFormat:@"%02d:%02d", minutes, secondes];
        } else {
            str = [NSString stringWithFormat:@"%02d", secondes];
        }
    }
    
    return str;
}

+ (NSString*)ConvertDurationToMoney:(int)duration WithHourlyRate:(NSString*)hrate {
    float fhrate = [hrate floatValue];
    float secrate = fhrate/3600;
    float fallrate = secrate * duration;
    int iallrate = fallrate;
    float fmnrate = fallrate - iallrate;
    int imnrate = fmnrate * 100;
    
    return [NSString stringWithFormat:@"$%d.%02d", iallrate, imnrate];
}

+ (NSString*) send_Rating_RequestWithSeequID:(NSString*)seeQuId Title:(NSString*)title Content:(NSString*)content  RatingValue:(int)value ReturnDictionary:(NSDictionary**)dictionary {
    NSString *urlString = [NSString stringWithFormat:@"%@/review/add?seeQuId=%@&authorSeeQuId=%@&title=%@&content=%@&ratingValue=%d", [Common getBaseTomcatLink], seeQuId, [Common sharedCommon].contactObject.SeequID, title, content, value];
    
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        return error_description;
    }

    NSError *error = nil;
    *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        return @"Invalid data from server.";
    }
    
    return nil;
}

+ (NSString*) SendRingbackEmailWithEmail:(NSString*)mail SeequID:(NSString*)seequID {
    NSString *urlString = [NSString stringWithFormat:@"%@/request/sendRingBackEmail?email=%@", [Common getBaseTomcatLink],  mail];
    
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:60 ErrorMessage:&error_description];
    
    if (error_description) {
        return error_description;
    }
    
    NSError *error = nil;
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        return @"Invalid data from server.";
    }
    
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        return nil;
    }
        
    return @"Failed to send ringback.";
}

+ (NSString*) SendInvitationEmailWithEmail:(NSString*)mail SeequID:(NSString*)seequID {
    NSString *urlString = [NSString stringWithFormat:@"%@/request/sendRingBackEmail?email=%@", [Common getBaseTomcatLink], mail];
    
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:60 ErrorMessage:&error_description];
    
    if (error_description) {
        return error_description;
    }
    
    NSError *error = nil;
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        return @"Invalid data from server.";
    }
    
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        return nil;
    }
    
    return @"Failed to send invite.";
}

+ (NSString*) SendResetPasswordWithEmail:(NSString*)mail {
    NSString *urlString = [NSString stringWithFormat:@"%@/resetPassword/sendResetPassEmail?email=%@", [Common getBaseTomcatLink], mail];
    
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:60 ErrorMessage:&error_description];
    
    if (error_description) {
        return error_description;
    }
    
//    NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    //NSLog(@"allData === %@", allData);

    NSError *error = nil;
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        return @"Invalid data from server.";
    }
    
//    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
//        return nil;
//    }

    return [dictionary objectForKey:@"message"];
}

#pragma mark -
#pragma mark Update Profile Information methods

+ (NSString*) UpdateProfileImage:(UIImage *)image {
    @autoreleasepool {
        NSString *regUrl = [NSString stringWithFormat:@"%@/image/update?",[Common getBaseTomcatLink]];
        RSLogHTTP(@"[SEND] {UpdateProfileImage} - %@", regUrl);

        NSData *dataObj = UIImageJPEGRepresentation(image, 1.0);
        NSString *string = [NSString stringWithFormat:@"%@seeQuId=%@", regUrl, [Common sharedCommon].SeequID];
        string = [string stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        
        NSHTTPURLResponse * response;
        NSError * error;
        
        NSString *boundry = @"-----------------------------185291718831015";
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:string]];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry] forHTTPHeaderField:@"Content-Type"];
        
        NSMutableData *postData = [NSMutableData dataWithCapacity:[dataObj length] + 512];
        [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\"test.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postData appendData:dataObj];
        [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [urlRequest setHTTPBody:postData];
       [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"tommy.protime.tv"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        
        if (error) {
            NSString *error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
            RSLogHTTP(@"[ERR] {UpdateProfileImage} - %@", error_description);
            return error_description;
        }
        
        error = nil;
        NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];

        if (error) {
            NSString *error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
            RSLogHTTP(@"[ERR] {UpdateProfileImage} - %@", error_description);
            return error_description;
        }

        RSLogHTTP(@"[RCV] {UpdateProfileImage} success - %@", dictionary);
        BOOL success = [[dictionary objectForKey:@"success"] boolValue];
        if (success) {
            [Common sharedCommon].contactObject.image = [image copy];
            return nil;
        } else {
            return @"Failed to update profile image.";
        }
        
        [Common sharedCommon].contactObject.image = [image copy];
        
        return nil;
    }
}

+ (NSString*) UpdateBadgeStatus:(NSString*)badgeStatus {
	NSString *urlString = [NSString stringWithFormat:@"%@/user/updateBadgeStatus?badgeStatus=%@", [Common getBaseTomcatLink],badgeStatus];
    RSLogHTTP(@"[SEND] {UpdateBadgeStatus} - %@", urlString);

    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        return error_description;
    }
    
    NSError *error = nil;
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        NSString *error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        RSLogHTTP(@"[ERR] {UpdateBadgeStatus} - %@", error_description);
        return error_description;
    }
    
    RSLogHTTP(@"[RCV] {UpdateBadgeStatus} - %@", dictionary);
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        [Common sharedCommon].contactObject.badgeStatus = badgeStatus;
    }
    
    return nil;
}

+ (BOOL) UpdateBadgeNumber:(int)badgeNumber {
	NSString *urlString = [NSString stringWithFormat:@"%@/badgeNumber?number=%d&id=%@", SEEQU_SERVICES,badgeNumber,[Common sharedCommon].contactObject.SeequID];
    RSLogHTTP(@"[SEND] {UpdateBadgeNumber} - %@", urlString);
    
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {UpdateBadgeNumber} - %@", error_description);
        return error_description;
    }
    
    NSString* str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    RSLogHTTP(@"[RCV] {UpdateBadgeNumber} - %@", str);
    return [str isEqualToString:@"YES"];
}
+(NSString*)BlockRequests:(BOOL)block{
  NSString *urlString = [NSString stringWithFormat:@"%@/user/update?lockRequest=%s", [Common getBaseTomcatLink],block? "true" : "false"];
    NSString * error_description;
   [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        return error_description;
    }
    
    return nil;
}

+ (NSString*) UpdateMainFields:(NSDictionary*)dict {
    NSString *firstName = [dict objectForKey:@"firstName"];
    NSString *lastName = [dict objectForKey:@"lastName"];
    NSString *specialist = [dict objectForKey:@"specialist"];
    NSString *company = [dict objectForKey:@"company"];
    NSString *introduction = [dict objectForKey:@"introduction"];
    NSString *bio = [dict objectForKey:@"bio"];
    
    NSString *_firstName = [firstName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _firstName = [_firstName stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    
    NSString *_lastName = [lastName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _lastName = [_lastName stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    
    NSString *_specialist = [specialist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _specialist = [_specialist stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];

    NSString *_company = [company stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _company = [_company stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];

    NSString *_introduction = [introduction stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _introduction = [_introduction stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];

    NSString *_bio = [bio stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _bio = [_bio stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    
    
	NSString *urlString = [NSString stringWithFormat:@"%@/user/update?firstName=%@&lastName=%@&title=%@&company=%@&bio=%@&introduction=%@", [Common getBaseTomcatLink],_firstName,_lastName,_specialist,_company,_bio,_introduction];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    RSLogHTTP(@"[SEND] <UpdateMainFields> - %@", urlString);

    NSString * error_description;
    
    NSError *error;
    NSHTTPURLResponse * response;
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"tommy.protime.tv"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:REQUEST_TIME_OUT];
    
    [request setHTTPMethod:@"POST"];
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
//        error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
//        RSLogHTTP(@"[ERR] <UpdateMainFields> - %@", error_description);
        return nil;
    }
    else {
//        NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//        NSLog(@"allData === %@", allData);
        
        error = nil;
        
        NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        
        if (!error && dict) {
            NSString *auth = [dict objectForKey:@"message"];
            RSLogHTTP(@"[RCV] <UpdateMainFields> - %@", auth);
            
            if ([auth isEqualToString:@"Failed to auth"]) {
                NSString * retValu= [Common LoginWithSeequID:[[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_IMPI"]
                                              Password:[[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_PASSWORD"]];
                    BOOL isAuth =retValu?NO:YES;
                
                if (isAuth) {
                    [Common UpdateMainFields:dict];
                } else {
             //       error_description = @"Authentication problem. \n Please restart the application.";
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autorisation_problem"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [Common postNotificationWithName:@"AuthenticationProblem" object:nil];
                    
                    return nil;
                }
            }
        }
    }
    
    if (error_description) {
        return error_description;
    }

    error = nil;
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        NSString *error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        RSLogHTTP(@"[ERR] <UpdateMainFields> - %@", error_description);

        return error_description;
    }
    
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        RSLogHTTP(@"[RCV] <UpdateMainFields> - success");
        Common *common = [Common sharedCommon];
        common.contactObject.FirstName = firstName;
        common.contactObject.LastName = lastName;
        common.contactObject.specialist = specialist;
        common.contactObject.introduction = introduction;
        common.contactObject.biography = bio;
        common.contactObject.company = company;
    }
    
    return nil;
}


+ (NSString*) updateRate:(NSString*)rate {
    
    rate= [rate stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    rate = [rate stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    
    
	NSString *urlString = [NSString stringWithFormat:@"%@/user/update?rate=%@", [Common getBaseTomcatLink],rate];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    RSLogHTTP(@"[SEND] <UpdateMainFields> - %@", urlString);
    
//    NSString * error_description;
    
    NSError *error;
//    NSHTTPURLResponse * response;
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"tommy.protime.tv"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:REQUEST_TIME_OUT];
    
    [request setHTTPMethod:@"POST"];
    
//    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        //        error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        //        RSLogHTTP(@"[ERR] <UpdateMainFields> - %@", error_description);
        return error.description;
    }
      
    
    
    return nil;
}


+ (NSString*) UpdateProfileLanguages:(NSDictionary*)dictLanguage {
    NSString *primary = [dictLanguage objectForKey:@"primary"];
    NSString *second = [dictLanguage objectForKey:@"second"];
    NSString *third = [dictLanguage objectForKey:@"third"];
    NSString *fourth = [dictLanguage objectForKey:@"fourth"];
    
	NSString *urlString = [NSString stringWithFormat:@"%@/userLanguage/update?primary=%@&second=%@&third=%@&fourth=%@", [Common getBaseTomcatLink],primary,second,third,fourth];
    RSLogHTTP(@"[SEND] {UpdateProfileLanguages} - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {UpdateProfileLanguages} - %@", error_description);
        return error_description;
    }

    NSError *error = nil;
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];

    if (error) {
        NSString *error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        RSLogHTTP(@"[ERR] {UpdateProfileLanguages} - %@", error_description);
        return error_description;
    }

    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        RSLogHTTP(@"[RCV] {UpdateProfileLanguages} - success");
        [[Common sharedCommon].contactObject SetLanguagesWithDictionary:dictLanguage];
    }
    
    return nil;
}

+ (NSString*) UpdateInternetInfo:(NSMutableArray*)array {
    NSString *url_data = [[CJSONSerializer serializer] serializeArray:array];
    
	NSString *urlString = [NSString stringWithFormat:@"%@/internetInfo/add?data=%@", [Common getBaseTomcatLink], url_data];
    RSLogHTTP(@"[SEND] {UpdateInternetInfo} - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {UpdateInternetInfo} - %@", error_description);
        return error_description;
    }
    
    NSError *error = nil;

    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];

    if (error) {
        error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        RSLogHTTP(@"[ERR] {UpdateInternetInfo} - %@", error_description);
        return error_description;
    }

    if ([[dictionary objectForKey:@"success"] intValue] != 1) {
        return @"Update internet info failed.";
    }
    
    RSLogHTTP(@"[RCV] {UpdateInternetInfo} - success");
    return nil;
}

/**[12/16/13, 5:58:12 PM] Nerses Atalyan: http://tommy.protime.tv:8080/seequ/location/update
[12/16/13, 5:58:17 PM] Nerses Atalyan: On 12/16/13, at 5:55 PM, Nerses Atalyan wrote:
> country
timeZoneId
state
abbrev**/



+ (NSString*) UpdateContactLocation:(NSDictionary*)dict {
    
    NSString *country = [dict objectForKey:@"Country"];
    NSString *city = [dict objectForKey:@"City"];
    NSString *state =[dict objectForKey:@"State"];
    NSString *abbrev = [dict objectForKey:@"Time Zone"];
    NSString* stateId = [dict objectForKey:@"stateID"];
    NSString* countryID = [dict objectForKey:@"countryID"];
    NSString* stateAbbrev =[dict objectForKey:@"stateAbbrev"];

    int  timeZone = [SeequTimeZoneInfo getTimeZoneNumber:abbrev];
    if (timeZone == -1) {
        timeZone = 6;
    }
  
    ///@todo  need  to  delete  next  line get from  Nerses  the list  with  timezone
    
	NSString *urlString = nil;
    
    if (stateId) {
        urlString = [NSString stringWithFormat:@"%@/location/update?country=%@&city=%@&abbrev=%@&timeZone=%d", [Common getBaseTomcatLink],countryID,city,stateId,timeZone ];
    } else {
        urlString = [NSString stringWithFormat:@"%@/location/update?country=%@&city=%@&state_name=%@&timeZone=%d", [Common getBaseTomcatLink],countryID,city,state,timeZone ];
    }
    RSLogHTTP(@"[SEND] {UpdateContactLocation} - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {UpdateContactLocation} - %@", error_description);
        return error_description;
    }
    
    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        RSLogHTTP(@"[ERR] {UpdateContactLocation} - %@", error_description);
        return error_description;
    }
    
    if ([[dictionary objectForKey:@"success"] intValue] != 1) {
        return @"Update contact info failed.";
    } else {
        [Common sharedCommon].contactObject.country.countryName = country;
        [Common sharedCommon].contactObject.country.countryID = countryID;
        [Common sharedCommon].contactObject.state.stateID = stateId;
        [Common sharedCommon].contactObject.state.stateName = state;
        [Common sharedCommon].contactObject.state.stateAbbrev = stateAbbrev;

        [[Common sharedCommon].contactObject setCity:city];
        [[Common sharedCommon].contactObject setTimeZone:[NSString stringWithFormat:@"%d", timeZone]];
        
        RSLogHTTP(@"[RCV] {UpdateContactLocation} - success");
    }
    
    return nil;
}


+ (NSString*) UpdateContactInfo:(NSMutableArray*)array {
    NSString *url_data = [[CJSONSerializer serializer] serializeArray:array];

	NSString *urlString = [NSString stringWithFormat:@"%@/contactInfo/add?data=%@", [Common getBaseTomcatLink], url_data];
    RSLogHTTP(@"[SEND] {UpdateContactInfo} - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {UpdateContactInfo} - %@", error_description);
        return error_description;
    }
    
    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];

    if (error) {
        NSString *error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        RSLogHTTP(@"[ERR] {UpdateContactInfo} - %@", error_description);
        return error_description;
    }

    if ([[dictionary objectForKey:@"success"] intValue] != 1) {
        return @"Update contact info failed.";
    }
    
    RSLogHTTP(@"[RCV] {UpdateContactInfo} - success");
    return nil;
}

+ (NSString*) UpdateSocialInfo:(NSMutableArray*)array {
    NSString *url_data = [[CJSONSerializer serializer] serializeArray:array];
    
	NSString *urlString = [NSString stringWithFormat:@"%@/socialInfo/add?data=%@", [Common getBaseTomcatLink], url_data];
    RSLogHTTP(@"[SEND] {UpdateSocialInfo} - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {UpdateSocialInfo} - %@", error_description);
        return error_description;
    }
    
    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];

    if (error) {
        error_description = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
        RSLogHTTP(@"[ERR] {UpdateSocialInfo} - %@", error_description);
        return error_description;
    }

    if ([[dictionary objectForKey:@"success"] intValue] != 1) {
        return @"Update social info failed.";
    }

    RSLogHTTP(@"[RCV] {UpdateSocialInfo} - success");
    return nil;
}

#pragma mark -
#pragma mark Validation methods

+ (BOOL)validateEmail: (NSString *)emailStr{
    if([emailStr length] < 8){
        return NO;
    }
    NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
    
    return [emailTest evaluateWithObject:emailStr];
}
+ (NSString*)validatePwd: (NSString *)pwdStr{
    NSString *errorString=nil;
    if (![pwdStr length]) {
        errorString=@"";
        return errorString;
    }
    if ( [pwdStr length]<5 ){
        errorString=@"5 symbols required in password.";
        return errorString;
        // too long or too short
    }
    NSRange rangU;
    NSRange rangL;
//    rangU = [pwdStr rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
//    if ( !rangU.length ){
//        return NO;  // no number
//    }
    rangU=[pwdStr rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    rangL=[pwdStr rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    if(!rangU.length || !rangL.length){
        errorString=@"Upper and lower case latters required in password.";
        return errorString;
        //no upper case
    }
    
    rangL=[pwdStr rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet]];
    rangU=[pwdStr rangeOfCharacterFromSet:[NSCharacterSet symbolCharacterSet]];
    if(!rangU.length && !rangL.length){
        errorString=@"Special character required in password.";
        return errorString;
        //no symbol
    }
    
    return errorString;
    
    
}
+ (BOOL)validateStr: (NSString *)txtStr{
    
    NSString *txtReg = @".*[\\[\\]\\\\\\^\\$\\|\\?\\*\\+\\(\\):'\"&!<>_-]+.*";
    NSPredicate *txtTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", txtReg];
    
    return [txtTest evaluateWithObject:txtStr] == YES ? NO : YES;
}

+ (BOOL)isEmpty:(NSString *)myStr{
    if(myStr == (id)[NSNull null] || [myStr length] == 0)
    {
        return YES;
    }
    return NO;
}

+ (NSString*) ConvertDurationStandart:(NSString*)duration {
    NSArray *array = [duration componentsSeparatedByString:@":"];
    
    if (array && [array count] > 2) {
        int hours = [[array objectAtIndex:0] intValue];
        int minutes = [[array objectAtIndex:1] intValue];
        int seconds = [[array objectAtIndex:2] intValue];
        
        if (hours + minutes + seconds == 0) {
            return @"     No Answer";
        }
        
        NSString *retVal = @"";
        
        if (hours) {
            retVal = [NSString stringWithFormat:@"%d houres", hours];
        }
        if (minutes) {
            retVal = [NSString stringWithFormat:@"%@ %d min", retVal, minutes];
        }
        if (seconds) {
            retVal = [NSString stringWithFormat:@"%@ %d sec", retVal, seconds];
        }
        
        retVal = [NSString stringWithFormat:@"    %@", retVal];

        return retVal;
    }
    
    return nil;
}

///@note  needn't change seequID ???

+ (NSString*) AddRecentsCallWithSeequID:(NSString*)seequID StartTime:(NSTimeInterval)startTime StopTime:(NSTimeInterval)stopTime {
    Common *common = [Common sharedCommon];
    NSString *urlString = [NSString stringWithFormat:@"%@/callLog/add?seeQuId=%@&conSeeQuId=%@&startTime=%0.0f&stopTime=%0.0f", [Common getBaseTomcatLink], common.contactObject.SeequID, seequID, startTime*1000, stopTime*1000];
    
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        return error_description;
    }
    
    NSError *error = nil;
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        return @"Invalid data from server.";
    }
    
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        return nil;
    }
    
    return @"Failed to add call to server.";
}

///@note  needn't change seequID ???

+ (NSString*) AddMissedCallWithSeequID:(NSString*)seequID StartTime:(NSTimeInterval)startTime {
    Common *common = [Common sharedCommon];
    NSString *urlString = [NSString stringWithFormat:@"%@/callLog/addMissedCallLog?seeQuId=%@&conSeeQuId=%@&startTime=%d", [Common getBaseTomcatLink], common.contactObject.SeequID, seequID, (int)(startTime*1000)];

    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        return error_description;
    }
    
    NSError *error = nil;
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        return @"Invalid data from server.";
    }
    
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        return nil;
    }
    
    return @"Failed to add call to server.";
}




//+ (NSString*) initRecentsWithData:(NSData*)data Recents:(NSMutableArray**)array {
//    NSError *error = nil;
//    
//    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
//    
//    if (error) {
//        return @"Invalid data from server.";
//    }
//    
//    *array = [[NSMutableArray alloc] init];
//    NSMutableArray *tmpArray;
//    
//    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
//        tmpArray = [dictionary objectForKey:@"return_values"];
//        
//        if ([tmpArray count]) {
//            for (NSDictionary *dict in tmpArray) {
//                if (!dict || ![dict isKindOfClass:[NSDictionary class]])
//                    continue;
//                
//                NSDictionary *callLog = [dict objectForKey:@"callLog"];
//                if (!callLog || ![callLog isKindOfClass:[NSDictionary class]])
//                    continue;
//                
//                ContactObject *obj = [[ContactObject alloc] initWithSeequID:[callLog objectForKey:@"conSeeQuId"]];
//                NSDictionary *profileData = [dict objectForKey:@"profileData"];
//                if (!profileData || ![profileData isKindOfClass:[NSDictionary class]])
//                    continue;
//                
//                [obj SetUserInfoWithDictionary:profileData];
//                obj.ID = [[callLog objectForKey:@"id"] intValue];
//                obj.contactType = Contact_Type_Recent;
//                obj.startTime = [[callLog objectForKey:@"startTime"] doubleValue] / 1000;
//                obj.stopTime =  [[callLog objectForKey:@"stopTime"] doubleValue] / 1000;
//                obj.status = [[callLog objectForKey:@"status"] intValue];
//                obj.isRecent = YES;
//                obj.isOnline = online_Status_Offline;
//                if ([[dict objectForKey:@"userStatus"] isEqualToString:@"Online"]) {
//                    obj.isOnline = online_Status_Online;
//                }
//                
//                [*array addObject:obj];
//                
//            }
//        }
//    } else {
//        return [dictionary objectForKey:@"message"];
//    }
//    
//    return nil;
//}
///@note  needn't change seequID ???

+ (void) GetRecentCallsWithDate:(NSTimeInterval)date{
    NSString *urlString = [NSString stringWithFormat:@"%@/callLog/getCallLogs?start=1&limit=30&date=%.0f", [Common getBaseTomcatLink], date*1000];
    RSLogHTTP(@"[SEND] {GetRecentCallsWithDate} - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:60 ErrorMessage:&error_description];
//    NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    //NSLog(@"allData === %@", allData);
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {GetRecentCallsWithDate} - %@", error_description);
//        return error_description;
    }
    
//    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kRECENTS];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    return [Common initRecentsWithData:data Recents:array];
    
    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        RSLogHTTP(@"[ERR] {GetRecentCallsWithDate} - %@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]);
//        return @"Invalid data from server.";
    }
    
   
    NSMutableArray *tmpArray;
    
    RSLogHTTP(@"[RCV] {GetRecentCallsWithDate} - %@", dictionary);
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        tmpArray = [dictionary objectForKey:@"return_values"];
        
        if ([tmpArray count]) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[ActivityStorage sharedInstance] insertCallLog:tmpArray];
//                });
//            NSString *strCatch = [[NSUserDefaults standardUserDefaults] objectForKey:kRECENTS];
//            
//            if (strCatch) {
//                NSData *strData = [strCatch dataUsingEncoding:NSUTF8StringEncoding];
//                NSDictionary *dictCatch = [[CJSONDeserializer deserializer] deserializeAsDictionary:strData error:&error];
//                NSArray *arrayCatch = [dictCatch objectForKey:@"return_values"];
//                NSMutableArray *marrayCatch = [[NSMutableArray alloc] initWithArray:arrayCatch];
//                [marrayCatch addObjectsFromArray:tmpArray];
//                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:marrayCatch, @"return_values", [NSNumber numberWithInt:1], @"success", nil];
//                NSString *str = [[CJSONSerializer serializer] serializeDictionary:dict];
//                [[NSUserDefaults standardUserDefaults] setObject:str forKey:kRECENTS];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            } else {
//                [[NSUserDefaults standardUserDefaults] setObject:allData forKey:kRECENTS];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            }
//            
//            return [Common initRecentsWithData:data Recents:array];
        }
        
//        if ([tmpArray count]) {
//            for (NSDictionary *dict in tmpArray) {
//                if (!dict || ![dict isKindOfClass:[NSDictionary class]])
//                    continue;
//                
//                NSDictionary *callLog = [dict objectForKey:@"callLog"];
//                if (!callLog || ![callLog isKindOfClass:[NSDictionary class]])
//                    continue;
//                
//                ContactObject *obj = [[ContactObject alloc] initWithSeequID:[callLog objectForKey:@"conSeeQuId"]];
//                NSDictionary *profileData = [dict objectForKey:@"profileData"];
//                if (!profileData || ![profileData isKindOfClass:[NSDictionary class]])
//                    continue;
//                
//                [obj SetUserInfoWithDictionary:profileData];
//                obj.ID = [[callLog objectForKey:@"id"] intValue];
//                obj.contactType = Contact_Type_Recent;
//                obj.startTime = [[callLog objectForKey:@"startTime"] doubleValue] / 1000;
//                obj.stopTime =  [[callLog objectForKey:@"stopTime"] doubleValue] / 1000;
//                obj.status = [[callLog objectForKey:@"status"] intValue];
//                obj.isRecent = YES;
//                obj.isOnline = online_Status_Offline;
//                if ([[dict objectForKey:@"userStatus"] isEqualToString:@"Online"]) {
//                    obj.isOnline = online_Status_Online;
//                }
//                
//                [*array addObject:obj];
//                
//            }
//        }
//    } else {
//        return [dictionary objectForKey:@"message"];
    }
    
//    return nil;
}

+ (NSString*) AddRequestWithSeequID:(NSString*)seequID Date:(NSTimeInterval)date Name:(NSString*)name Content:(NSString*)content {
    NSString *urlString = [NSString stringWithFormat:@"%@/request/add?seeQuId=%@&type=%@&content=%@", [Common getBaseTomcatLink],  seequID, name, content];
    RSLogHTTP(@"[SEND] {AddRequestWithSeequID} - %@", urlString);

    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {AddRequestWithSeequID} - %@", error_description);
        return error_description;
    }
    
    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        RSLogHTTP(@"[ERR] {AddRequestWithSeequID} - %@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]);
        return @"Invalid data from server.";
    }
    
    RSLogHTTP(@"[RCV] {AddRequestWithSeequID} - %@", dictionary);
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        return nil;
    }
    
    return @"Failed to send request.";
}

+ (NSString*) UpdateRequestWithID:(int)ID Date:(NSTimeInterval)date Status:(NSString*)status {
    NSString *urlString = [NSString stringWithFormat:@"%@/request/update?id=%d&status=%@", [Common getBaseTomcatLink], ID, status];
    RSLogHTTP(@"[SEND] {UpdateRequestWithID} - %@", urlString);

    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {UpdateRequestWithID} - %@", error_description);
        return error_description;
    }
    
    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        RSLogHTTP(@"[ERR] {UpdateRequestWithID} - %@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]);
        return @"Invalid data from server.";
    }
    
    RSLogHTTP(@"[RCV] {UpdateRequestWithID} - %@", dictionary);
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        return nil;
    } else {
        return [dictionary objectForKey:@"message"];
    }
    
    return @"Unable to apply.";
}



+ (void) GetRequestsWithDate:(NSTimeInterval)date{
    Common *common = [Common sharedCommon];
    NSString *urlString = [NSString stringWithFormat:@"%@/request/getRequests?seeQuId=%@&start=1&limit=30&date=%.0f", [Common getBaseTomcatLink], common.contactObject.SeequID, date*1000];
       NSLog(@"[SEND] {GetRequestsWithDate} - %@", urlString);
    
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:60 ErrorMessage:&error_description];
//    NSString *allData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"allData === %@", allData);
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {GetRequestsWithDate} - %@", error_description);
//        return error_description;
    }

    
    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        RSLogHTTP(@"[ERR] {GetRequestsWithDate} - %@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]);
//        return @"Invalid data from server.";
    }
    
//    *array = [[NSMutableArray alloc] init];
    NSMutableArray *tmpArray;
    
    RSLogHTTP(@"[RCV] {GetRequestsWithDate} - %@", dictionary);
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        tmpArray = [dictionary objectForKey:@"return_values"];
        
        if ([tmpArray count]) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[ActivityStorage sharedInstance] insertRequests:tmpArray];
//                });
//            NSString *strCatch = [[NSUserDefaults standardUserDefaults] objectForKey:kREQUESTS];
        
//            if (strCatch) {
//                NSData *strData = [strCatch dataUsingEncoding:NSUTF8StringEncoding];
//                NSDictionary *dictCatch = [[CJSONDeserializer deserializer] deserializeAsDictionary:strData error:&error];
//                NSArray *arrayCatch = [dictCatch objectForKey:@"return_values"];
//                NSMutableArray *marrayCatch = [[NSMutableArray alloc] initWithArray:arrayCatch];
//                [marrayCatch addObjectsFromArray:tmpArray];
//                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:marrayCatch, @"return_values", [NSNumber numberWithInt:1], @"success", nil];
//                NSString *str = [[CJSONSerializer serializer] serializeDictionary:dict];
//                [[NSUserDefaults standardUserDefaults] setObject:str forKey:kREQUESTS];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            } else {
//                [[NSUserDefaults standardUserDefaults] setObject:allData forKey:kREQUESTS];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            }
//            
//            return [Common initRequestsWithData:data Requests:array];
//            
        }
    }
    
//    return nil;
}

//+ (NSString*) initRequestsWithData:(NSData*)data Requests:(NSMutableArray**)array {
//    NSError *error = nil;
//    
//    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
//    
//    if (error) {
//        return @"Invalid data from server.";
//    }
//    
//    *array = [[NSMutableArray alloc] init];
//    NSMutableArray *tmpArray;
//    
//    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
//        tmpArray = [dictionary objectForKey:@"return_values"];
//        
//        if ([tmpArray count]) {
//            for (NSDictionary *dict in tmpArray) {
//                NSDictionary *requestData = [dict objectForKey:@"request"];
//                if (!requestData || ![requestData isKindOfClass:[NSDictionary class]]) {
//                    continue;
//                }
//                
//                NSDictionary *typeEnumDict = [requestData objectForKey:@"typeEnum"];
//                if (!typeEnumDict || ![typeEnumDict isKindOfClass:[NSDictionary class]]) {
//                    continue;
//                }
//                
//                NSDictionary *statusEnumDict = [requestData objectForKey:@"statusEnum"];
//                if (!statusEnumDict || ![statusEnumDict isKindOfClass:[NSDictionary class]]) {
//                    continue;
//                }
//                
//                
//                NSString *name = [typeEnumDict objectForKey:@"name"];
//                ContactObject *obj;
//                
//                if ([name isEqualToString:@"RINGBACK"]) {
//                    if ([[requestData objectForKey:@"seeQuId"] isEqualToString:[requestData objectForKey:@"conSeeQuId"]]) {
//                        obj = [[ContactObject alloc] initWithSeequID:[requestData objectForKey:@"peerSeeQuId"]];
//                        
//                        NSString *status = [statusEnumDict objectForKey:@"name"];
//                        
//                        if (status && [status isKindOfClass:[NSString class]]) {
//                            if ([status isEqualToString:@"ACCEPTED"]) {
//                                obj.contactType = Contact_Type_Request_Ringback_Accepted;
//                                obj.requestStatus = Request_Status_Ringback_Accepted;
//                            } else {
//                                if ([status isEqualToString:@"IGNORED"]) {
//                                    obj.contactType = Contact_Type_Request_For_Ringback;
//                                    obj.requestStatus = Request_Status_For_Ringback;
//                                } else {
//                                    obj.contactType = Contact_Type_Request_For_Ringback;
//                                    obj.requestStatus = Request_Status_Ringback_Declined;
//                                }
//                            }
//                        } else {
//                            continue;
//                        }
//                    } else {
//                        obj = [[ContactObject alloc] initWithSeequID:[requestData objectForKey:@"conSeeQuId"]];
//                        NSString *status = [statusEnumDict objectForKey:@"name"];
//                        if (status && [status isKindOfClass:[NSString class]]) {
//                            if ([status isEqualToString:@"ACCEPTED"]) {
//                                obj.contactType = Contact_Type_Request_Ringback_Accepted;
//                                obj.requestStatus = Request_Status_Recived_Ringback_Accepted;
//                            } else {
//                                if ([status isEqualToString:@"DECLINED"]) {
//                                    obj.contactType = Contact_Type_Request_Ringback_Accepted;
//                                    obj.requestStatus = Request_Status_Recived_Ringback_Declined;
//                                } else {
//                                    obj.contactType = Contact_Type_Request_Ringback;
//                                    obj.requestStatus = Request_Status_Ringback;
//                                }
//                            }
//                        } else {
//                            continue;
//                        }
//                    }
//                } else {
//                    if ([name isEqualToString:@"CONNECTION"]) {
//                        if ([[requestData objectForKey:@"seeQuId"] isEqualToString:[requestData objectForKey:@"conSeeQuId"]]) {
//                            obj = [[ContactObject alloc] initWithSeequID:[requestData objectForKey:@"peerSeeQuId"]];
//                            NSString *status = [statusEnumDict objectForKey:@"name"];
//                            if (status && [status isKindOfClass:[NSString class]]) {
//                                if ([status isEqualToString:@"ACCEPTED"]) {
//                                    obj.contactType = Contact_Type_Request_Accepted;
//                                    obj.requestStatus = Request_Status_Connection_Accepted;
//                                } else {
//                                    if ([status isEqualToString:@"IGNORED"]) {
//                                        obj.contactType = Contact_Type_Request_For_Connection;
//                                        obj.requestStatus = Request_Status_For_Connection;
//                                    } else {
//                                        obj.contactType = Contact_Type_Request_For_Connection;
//                                        obj.requestStatus = Request_Status_Connection_Declined;
//                                    }
//                                }
//                            } else {
//                                continue;
//                            }
//                        } else {
//                            obj = [[ContactObject alloc] initWithSeequID:[requestData objectForKey:@"conSeeQuId"]];
//                            NSString *status = [statusEnumDict objectForKey:@"name"];
//                            if (status && [status isKindOfClass:[NSString class]]) {
//                                if ([status isEqualToString:@"ACCEPTED"]) {
//                                    obj.contactType = Contact_Type_Request_Accepted;
//                                    obj.requestStatus = Request_Status_Recived_Connection_Accepted;
//                                } else {
//                                    if ([status isEqualToString:@"DECLINED"]) {
//                                        obj.contactType = Contact_Type_Request_Accepted;
//                                        obj.requestStatus = Request_Status_Recived_Connection_Declined;
//                                    } else {
//                                        obj.contactType = Contact_Type_Request_Connection;
//                                        obj.requestStatus = Request_Status_Connection;
//                                    }
//                                }
//                            } else {
//                                continue;
//                            }
//                        }
//                    } else {
//                        if ([name isEqualToString:@"REVIEW"]) {
//                            if ([[requestData objectForKey:@"seeQuId"] isEqualToString:[requestData objectForKey:@"conSeeQuId"]]) {
//                                obj = [[ContactObject alloc] initWithSeequID:[requestData objectForKey:@"peerSeeQuId"]];
//                                NSString *status = [statusEnumDict objectForKey:@"name"];
//                                if (status && [status isKindOfClass:[NSString class]]) {
//                                    if ([status isEqualToString:@"ACCEPTED"]) {
//                                        obj.contactType = Contact_Type_Request_Review_Accepted;
//                                        obj.requestStatus = Request_Status_Review_Accepted;
//                                    } else {
//                                        if ([status isEqualToString:@"IGNORED"]) {
//                                            obj.contactType = Contact_Type_Request_For_Review;
//                                            obj.requestStatus = Request_Status_For_Review;
//                                        } else {
//                                            obj.contactType = Contact_Type_Request_For_Review;
//                                            obj.requestStatus = Request_Status_Review_Declined;
//                                        }
//                                    }
//                                } else {
//                                    continue;
//                                }
//                            } else {
//                                obj = [[ContactObject alloc] initWithSeequID:[requestData objectForKey:@"conSeeQuId"]];
//                                NSString *status = [statusEnumDict objectForKey:@"name"];
//                                if (status && [status isKindOfClass:[NSString class]]) {
//                                    if ([status isEqualToString:@"ACCEPTED"]) {
//                                        obj.contactType = Contact_Type_Request_Review_Accepted;
//                                        obj.requestStatus = Request_Status_Recived_Review_Accepted;
//                                    } else {
//                                        if ([status isEqualToString:@"DECLINED"]) {
//                                            obj.contactType = Contact_Type_Request_Review_Accepted;
//                                            obj.requestStatus = Request_Status_Recived_Review_Declined;
//                                        } else {
//                                            obj.contactType = Contact_Type_Request_Review;
//                                            obj.requestStatus = Request_Status_Review;
//                                        }
//                                    }
//                                } else {
//                                    continue;
//                                }
//                            }
//                        }
//                    }
//                }
//                
//                
//                obj.content = [requestData objectForKey:@"content"];
//                NSDictionary *profileData = [dict objectForKey:@"profileData"];
//                [obj SetUserInfoWithDictionary:profileData];
//                
//                obj.ID = [[requestData objectForKey:@"id"] intValue];
//                obj.startTime = [[requestData objectForKey:@"date"] doubleValue] / 1000;
//                
//                obj.isOnline = online_Status_Offline;
//                if ([[dict objectForKey:@"userStatus"] isEqualToString:@"Online"]) {
//                    obj.isOnline = online_Status_Online;
//                }
//                
//                [*array addObject:obj];
//                
//            }
//        }
//    } else {
//        return [dictionary objectForKey:@"message"];
//    }
//    
//    return nil;
//}

//+ (void) ChangeContactObjectsRequestStatus:(ContactObject*)object RequestStatus:(Request_Status)status {
//    NSString *strData = [[NSUserDefaults standardUserDefaults] objectForKey:kREQUESTS];
//    
//    if (!strData)
//        return;
//    
//    NSData *data = [strData dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSError *error = nil;
//    
//    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
//    
//    if (error) {
//        return;
//    }
//    
//    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
//        NSArray *array = [dictionary objectForKey:@"return_values"];
//        
//        if ([array count]) {
//            NSMutableArray *m_array = [[NSMutableArray alloc] initWithArray:array];
//            for (int i = 0; i < m_array.count; i++) {
//                NSDictionary *dict = [m_array objectAtIndex:i];
//                NSDictionary *requestData = [dict objectForKey:@"request"];
//                if (!requestData || ![requestData isKindOfClass:[NSDictionary class]]) {
//                    continue;
//                }
//                
//                NSDictionary *typeEnumDict = [requestData objectForKey:@"typeEnum"];
//                if (!typeEnumDict || ![typeEnumDict isKindOfClass:[NSDictionary class]]) {
//                    continue;
//                }
//                
//                NSDictionary *statusEnumDict = [requestData objectForKey:@"statusEnum"];
//                if (!statusEnumDict || ![statusEnumDict isKindOfClass:[NSDictionary class]]) {
//                    continue;
//                }
//
//                NSString *name = [typeEnumDict objectForKey:@"name"];
//                NSMutableDictionary *m_requestData = [[NSMutableDictionary alloc] initWithDictionary:requestData];
//                
//                if (![[requestData objectForKey:@"seeQuId"] isEqualToString:[requestData objectForKey:@"conSeeQuId"]]) {
//                    if ([[requestData objectForKey:@"conSeeQuId"] isEqualToString:object.SeequID]) {
//                         if ([name isEqualToString:@"RINGBACK"]) {
//                             NSString *ring_status = [statusEnumDict objectForKey:@"name"];
//                             if (ring_status && [ring_status isKindOfClass:[NSString class]]) {
//                                 if (![ring_status isEqualToString:@"ACCEPTED"] && ![ring_status isEqualToString:@"DECLINED"]) {
//                                     if (status == Request_Status_Recived_Ringback_Accepted) {
//                                         NSMutableDictionary *m_dict = [[NSMutableDictionary alloc] initWithDictionary:statusEnumDict];
//                                         [m_dict setObject:@"ACCEPTED" forKey:@"name"];
//                                         [m_requestData setObject:m_dict forKey:@"statusEnum"];
//                                         [m_array replaceObjectAtIndex:i withObject:m_requestData];
//                                     } else {
//                                         if (status == Request_Status_Recived_Ringback_Declined) {
//                                             NSMutableDictionary *m_dict = [[NSMutableDictionary alloc] initWithDictionary:statusEnumDict];
//                                             [m_dict setObject:@"DECLINED" forKey:@"name"];
//                                             [m_requestData setObject:m_dict forKey:@"statusEnum"];
//                                             [m_array replaceObjectAtIndex:i withObject:m_requestData];
//                                         }
//                                     }
//                                 }
//                             }
//                         } else {
//                             if ([name isEqualToString:@"CONNECTION"]) {
//                                 NSString *ring_status = [statusEnumDict objectForKey:@"name"];
//                                 if (ring_status && [ring_status isKindOfClass:[NSString class]]) {
//                                     if (![ring_status isEqualToString:@"ACCEPTED"] && ![ring_status isEqualToString:@"DECLINED"]) {
//                                         if (status == Request_Status_Recived_Connection_Accepted) {
//                                             NSMutableDictionary *m_dict = [[NSMutableDictionary alloc] initWithDictionary:statusEnumDict];
//                                             [m_dict setObject:@"ACCEPTED" forKey:@"name"];
//                                             [m_requestData setObject:m_dict forKey:@"statusEnum"];
//                                             [m_array replaceObjectAtIndex:i withObject:m_requestData];
//                                         } else {
//                                             if (status == Request_Status_Recived_Connection_Declined) {
//                                                 NSMutableDictionary *m_dict = [[NSMutableDictionary alloc] initWithDictionary:statusEnumDict];
//                                                 [m_dict setObject:@"DECLINED" forKey:@"name"];
//                                                 [m_requestData setObject:m_dict forKey:@"statusEnum"];
//                                                 [m_array replaceObjectAtIndex:i withObject:m_requestData];
//                                             }
//                                         }
//                                     }
//                                 }
//                             } else {
//                                 if ([name isEqualToString:@"REVIEW"]) {
//                                     NSString *ring_status = [statusEnumDict objectForKey:@"name"];
//                                     if (ring_status && [ring_status isKindOfClass:[NSString class]]) {
//                                         if (![ring_status isEqualToString:@"ACCEPTED"] && ![ring_status isEqualToString:@"DECLINED"]) {
//                                             if (status == Request_Status_Recived_Review_Accepted) {
//                                                 NSMutableDictionary *m_dict = [[NSMutableDictionary alloc] initWithDictionary:statusEnumDict];
//                                                 [m_dict setObject:@"ACCEPTED" forKey:@"name"];
//                                                 [m_requestData setObject:m_dict forKey:@"statusEnum"];
//                                                 [m_array replaceObjectAtIndex:i withObject:m_requestData];
//                                             } else {
//                                                 if (status == Request_Status_Recived_Review_Declined) {
//                                                     NSMutableDictionary *m_dict = [[NSMutableDictionary alloc] initWithDictionary:statusEnumDict];
//                                                     [m_dict setObject:@"DECLINED" forKey:@"name"];
//                                                     [m_requestData setObject:m_dict forKey:@"statusEnum"];
//                                                     [m_array replaceObjectAtIndex:i withObject:m_requestData];
//                                                 }
//                                             }
//                                         }
//                                     }
//                                 }
//                             }
//                         }
//                    }
//                }
//            }
//            
//            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:m_array, @"return_values", [NSNumber numberWithInt:1], @"success", nil];
//            NSString *str = [[CJSONSerializer serializer] serializeDictionary:dict];
//            [[NSUserDefaults standardUserDefaults] setObject:str forKey:kREQUESTS];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//    }
//}

+ (NSString*) CleareAllActivitys {
    NSString *urlString = [NSString stringWithFormat:@"%@/request/removeAllRequestsAndLogs", [Common getBaseTomcatLink]];
    
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:60 ErrorMessage:&error_description];
//    NSString *allData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"allData === %@", allData);
    
    if (error_description) {
        return error_description;
    }
    
    
    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        return @"Invalid data from server.";
    }
    
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        return nil;
    }
    
    return @"Ooops";
}

+ (BOOL) isGreenColor:(UIColor*)color {
    const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
    BOOL retVal = NO;
    
    if (componentColors[0] == 0.0 && componentColors[1] == 1.0 && componentColors[2] == 0.0 && componentColors[3] == 1.0) {
        retVal = YES;
    }
    
    return retVal;
}

+ (BOOL) isRedColor:(UIColor*)color {
    BOOL retVal = NO;
    if (color) {
        const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
        
        if (componentColors && componentColors[0] == 1.0 && componentColors[1] == 0.0 && componentColors[2] == 0.0 && componentColors[3] == 1.0) {
            retVal = YES;
        }
    }
    
    return retVal;
}


+ (NSString*) SearchContactsWithText:(NSString*)key ReturnedArray:(NSMutableArray**)array start:(int) startPos limit:(int)limit total:(NSNumber**) totalCount{
    Common *common = [Common sharedCommon];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/searchByProp?key=%@&start=%d&limit=%d", [Common getBaseTomcatLink], key,startPos,limit];
    RSLogHTTP(@"[SEND] {SearchContactsWithText} - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        return error_description;
    }
    
    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        RSLogHTTP(@"[ERR] {SearchContactsWithText} - %@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]);
        return @"Invalid data from server.";
    }
    
    *array = nil;
    NSMutableArray *tmpArray;
    
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        RSLogHTTP(@"[SEND] {SearchContactsWithText} - DATA RECEIVED");
        *totalCount = [[dictionary objectForKey:@"resultCount"] copy];
        tmpArray = [dictionary objectForKey:@"return_values"];
        
        if ([tmpArray count]) {
            for (NSDictionary *dict in tmpArray) {
                if (![[dict objectForKey:@"seeQuId"] isEqualToString:common.SeequID]) {
                    ContactObject *obj;
                    
//                    NSString *education = @" ";
//                    NSDictionary *userProfile = [dict objectForKey:@"userProfile"];
//                    if ([userProfile isKindOfClass:[NSDictionary class]]) {
//                        education = [userProfile objectForKey:@"education"];
//                    }
                    
                    obj = [[ContactObject alloc] initWithSeequID:[dict objectForKey:@"seeQuId"]];
                    [obj SetUserInfoWithDictionary:dict];
                    obj.isOnline = online_Status_Away;
                    if ([[dict objectForKey:@"status"] isEqualToString:@"Online"]) {
                        obj.isOnline = online_Status_Online;
                    }
                    
                    if (!*array) {
                        *array = [[NSMutableArray alloc] init];
                    }
                    [*array addObject:obj];
                }
            }
        }
    }
    
    return nil;
}


+ (NSString*) SearchContactsWithText:(NSString*)key ReturnedArray:(NSMutableArray**)array {
    Common *common = [Common sharedCommon];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/search?key=%@&start=1&limit=30", [Common getBaseTomcatLink], key];
    RSLogHTTP(@"[SEND] {SearchContactsWithText} - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        return error_description;
    }

    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        RSLogHTTP(@"[ERR] {SearchContactsWithText} - %@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]);
        return @"Invalid data from server.";
    }
    
    *array = nil;
    NSMutableArray *tmpArray;
    
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        RSLogHTTP(@"[SEND] {SearchContactsWithText} - DATA RECEIVED");
        tmpArray = [dictionary objectForKey:@"return_values"];
        
        if ([tmpArray count]) {
            for (NSDictionary *dict in tmpArray) {
                if (![[dict objectForKey:@"seeQuId"] isEqualToString:common.SeequID]) {
                    ContactObject *obj;
                    
// JSC
//                    NSString *education = @" ";
//                    NSDictionary *userProfile = [dict objectForKey:@"userProfile"];
//                    if ([userProfile isKindOfClass:[NSDictionary class]]) {
//                        education = [userProfile objectForKey:@"education"];
//                    }
                    
                    obj = [[ContactObject alloc] initWithSeequID:[dict objectForKey:@"seeQuId"]];
                    [obj SetUserInfoWithDictionary:dict];
                    obj.isOnline = online_Status_Away;
                    if ([[dict objectForKey:@"status"] isEqualToString:@"Online"]) {
                        obj.isOnline = online_Status_Online;
                    }
                    
                    if (!*array) {
                        *array = [[NSMutableArray alloc] init];
                    }
                    [*array addObject:obj];
                }
            }
        }
    }
    
    return nil;
}

+ (NSString*)FindFilePathWithFilename:(NSString*)fileName {
	// Get the path to the database in the application package
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    
	return filePath;
}

+ (NSString*) RegisterPushNotificationWithDeviceToken:(NSString*)DeviceToken registerForce:(BOOL)forse {
        NSString * registerForce=forse?@"registerForce":@"register";
        NSString *pmode = @"";
        #ifdef ADHOC
        pmode = @"&pmode";
        #endif
        NSString *udid=[UIDevice currentDevice].identifierForVendor.UUIDString;
      
        NSString *urlString = [NSString stringWithFormat:@"%@/%@?id=%@&deviceID=%@&bundle=%@&uid=%@%@", SEEQU_SERVICES,registerForce , [[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_IMPI"], DeviceToken,[[NSBundle mainBundle] bundleIdentifier],udid,pmode];
        RSLogHTTP(@"[SEND] {RegisterPushNotificationWithDeviceToken} - %@", urlString);
        NSString * error_description;
        NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
        
        if (error_description) {
                RSLogHTTP(@"[ERR] {RegisterPushNotificationWithDeviceToken} - %@", error_description);
                return error_description;
        }
        
        NSString *responseData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        RSLogHTTP(@"[RCV] {RegisterPushNotificationWithDeviceToken} - %@", responseData);
        //    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        return responseData;
}

+ (NSString*) UnRegisterPushNotificationWithDeviceToken:(NSString*)DeviceToken {
    NSString *urlString = [NSString stringWithFormat:@"%@/unregister?id=%@&deviceID=%@", SEEQU_SERVICES, [[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_IMPI"], DeviceToken];
    RSLogHTTP(@"[SEND] {UnRegisterPushNotificationWithDeviceToken} - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {UnRegisterPushNotificationWithDeviceToken} - %@", error_description);
        return error_description;
    }
    
    NSString *responseData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    RSLogHTTP(@"[RCV] {UnRegisterPushNotificationWithDeviceToken} - %@", responseData);
//    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    return responseData;
}

+ (NSString*) SendPushNotificationTo:(NSString*)ptID withText:(NSString*)text Status:(NSString*)status {
    NSString *urlString = [NSString stringWithFormat:@"%@/push?id=%@&message=%@&status=%@&from=%@", SEEQU_SERVICES, ptID, text, status, [Common sharedCommon].SeequID];
    RSLogHTTP(@"[SEND] {SendPushNotificationTo} - %@", urlString);
    
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] {SendPushNotificationTo} - %@", error_description);
        return error_description;
    }
    
    NSString *responseData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    RSLogHTTP(@"[RCV] {SendPushNotificationTo} - %@", responseData);
//    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    return responseData;
}

- (NSString*) ResetNotificationBadgesCount {
    NSString *urlString = [NSString stringWithFormat:@"%@/resetBadge?deviceID=%@", SEEQU_SERVICES, [[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_IMPI"]];
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        return error_description;
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

+(NSArray*) prepareCountriesArray:(NSArray*) countriesArray {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (NSDictionary*  dict in countriesArray) {

        SeequCountry* country = [[SeequCountry alloc] init];
        country.countryName = [dict objectForKey:@"country"];
        country.countryID = [dict objectForKey:@"id"];
        [array addObject:country];
    }
    return array;
    
}

+(NSArray*) prepareStatesArray:(NSArray*) statesArray {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (NSDictionary*  dict in statesArray) {
        
        SeequState* state = [[SeequState alloc] init];
        state.stateName = [dict objectForKey:@"state"];
        state.stateID = [dict objectForKey:@"id"];
        state.stateAbbrev = [dict objectForKey:@"abbreviation"];

        [array addObject:state];
    }
    return array;
    
}

+ (NSArray*) GetAllCountries {

    NSString *urlString = [NSString stringWithFormat:@"%@/country/list", [Common getBaseTomcatLink]];
    RSLogHTTP(@"[SEND] <GetAllCountris> - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] <GetAllCountris> - %@", error_description);
        return nil;
    }
    
    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        RSLogHTTP(@"[ERR] <GetAllCountris> - %@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]);
        return nil;
    }
    
    RSLogHTTP(@"[RCV] <GetAllCountris> - Data Received");
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
		return [Common prepareCountriesArray:[dictionary objectForKey:@"return_values"]];
    }
    
    return nil;
}

+ (NSMutableArray*) GetAllStates {
    NSString *urlString = [NSString stringWithFormat:@"%@/state/list", [Common getBaseTomcatLink]];
    RSLogHTTP(@"[SEND] <GetAllStates> - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] <GetAllStates> - %@", error_description);
        return nil;
    }
    
    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        RSLogHTTP(@"[ERR] <GetAllStates> - %@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]);
        return nil;
    }
    
    RSLogHTTP(@"[RCV] <GetAllStates> - Data Received");
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
		return [dictionary objectForKey:@"return_values"];
    }
    
    return nil;    
}


+ (NSArray*) GetStatesById:(NSString*) countryId {
    NSString *urlString = [NSString stringWithFormat:@"%@/state/getStatesById?country=%@", [Common getBaseTomcatLink],countryId];
    RSLogHTTP(@"[SEND] <GetStatesById> - %@", urlString);
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        RSLogHTTP(@"[ERR] <GetStatesById> - %@", error_description);
        return nil;
    }
    
    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        RSLogHTTP(@"[ERR] <GetStatesById> - %@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]);
        return nil;
    }
    
    RSLogHTTP(@"[RCV] <GetStatesById> - Data Received");
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
		return [Common prepareStatesArray:[dictionary objectForKey:@"return_values"]];
    }
    
    return nil;
}


+ (void) SetMissedWithSeequID:(NSString*)proID Type:(int)type MissedCount:(int)missedCount{
    if (!proID) {
        return;
    }
    Common *common = [Common sharedCommon];
    MissedEventObject *missedObj;
    if (common.MissedEvents) {
        missedObj = [common.MissedEvents objectForKey:proID];
    }
    
    if (!missedObj) {
        missedObj = [[MissedEventObject alloc] init];
        [common.MissedEvents setObject:missedObj forKey:proID];
    }
    
    switch (type) {
        case 0:
            missedObj.missedAudio += missedCount;
            break;
        case 1:
            missedObj.missedVideo += missedCount;
            break;
        case 2:
            missedObj.missedDiscussion += missedCount;
            break;
        default:
            break;
    }
}


+ (void) AddMissedWithSeequID:(NSString*)proID Type:(int)type {
    Common *common = [Common sharedCommon];
    
    MissedEventObject *missedObj = [common.MissedEvents objectForKey:proID];
    
    if (!missedObj) {
        missedObj = [[MissedEventObject alloc] init];
        
        //        missedObj.missedAudio = 0;
        //        missedObj.missedVideo = 0;
        //        missedObj.missedDiscussion = 0;
        //        missedObj.missedInvoice = 0;
        //        missedObj.missedInfo = 0;
        
        [common.MissedEvents setObject:missedObj forKey:proID];
        
    }
    
    switch (type) {
        case 0:
            missedObj.missedAudio++;
            break;
        case 1:
            missedObj.missedVideo++;
            break;
        case 2:
            missedObj.missedDiscussion++;
            break;
        default:
            break;
    }
    
    [Common postNotificationWithName:@"AddedMissed" object:@"AddMissedWithSeequID"];
}

+ (void) RemoveMissedWithSeequID:(NSString*)proID Type:(int)type {
    Common *common = [Common sharedCommon];
    
    MissedEventObject *missedObj = [common.MissedEvents objectForKey:proID];
    
    if (!missedObj) {
        missedObj = [[MissedEventObject alloc] init];
        [common.MissedEvents setObject:missedObj forKey:proID];
        
    }
    
    switch (type) {
        case 0:
            missedObj.missedAudio = 0;
            break;
        case 1:
            missedObj.missedVideo = 0;
            break;
        case 2:
            missedObj.missedDiscussion = 0;
            break;
        default:
            break;
    }
    
    [Common postNotificationWithName:@"AddedMissed" object:@"AddMissedWithSeequID"];
}

+ (void)incrementMessageBadgeWith:(int)incrCount{
    Common *common = [Common sharedCommon];
    
    int missedCounts = 0;
    
    for (NSString *key in common.MissedEvents) {
        MissedEventObject *missedObj = [common.MissedEvents objectForKey:key];
        
        if (missedObj) {
            missedCounts -= incrCount;
        }
    }
    [Common postNotificationWithName:@"AddedMissed" object:@"AddMissedWithSeequID"];
}

+ (int) GetAllMissedsCalls {
    Common *common = [Common sharedCommon];
    
    int missedCounts = 0;
    
    for (NSString *key in common.MissedEvents) {
        MissedEventObject *missedObj = [common.MissedEvents objectForKey:key];
        
        if (missedObj) {
            missedCounts += missedObj.missedAudio;
            missedCounts += missedObj.missedVideo;
        }
    }
    
    return missedCounts;
}

+(int) GetAllMissedCallsFromCash{
//    NSMutableArray *array;
    int  count = 0;
//    ///@todo  wrong  return  value  !!!!
//    if (![Common GetAllRecentsFromCatch:&array]) {
//        if (array && array.count) {
//            for (ContactObject* obj in array) {
//                if (obj.isRecent && obj.status == 0) {
//                    count++;
//                }
//            }
//        }
//    }
//    int temp = [[NSUserDefaults standardUserDefaults] integerForKey:kMISSEDCALL];

    return count;
}

+(void) SetMissedCallsCountToCash:(int)count{
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:kMISSEDCALL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (int) GetAllMisseds {
    Common *common = [Common sharedCommon];
    
    int missedCounts = 0;
    
    for (NSString *key in common.MissedEvents) {
        MissedEventObject *missedObj = [common.MissedEvents objectForKey:key];
        
        if (missedObj) {
            missedCounts += missedObj.missedAudio;
            missedCounts += missedObj.missedVideo;
            missedCounts += missedObj.missedDiscussion;
        }
    }
    return missedCounts;
}

+ (int) GetMissedMessages {
    Common *common = [Common sharedCommon];
    
    int missedCounts = 0;
    
    for (NSString *key in common.MissedEvents) {
        MissedEventObject *missedObj = [common.MissedEvents objectForKey:key];
        
        if (missedObj) {
            missedCounts += missedObj.missedDiscussion;
        }
    }
    
    return missedCounts;
}

+ (void) SaveDataWithData:(NSData*)data key:(NSString*)key {
    NSMutableArray *mut_array_keys;
    NSArray *array_keys = [[NSUserDefaults standardUserDefaults] objectForKey:@"catched_keys"];
    if (!array_keys) {
        mut_array_keys = [[NSMutableArray alloc] init];
    } else {
        mut_array_keys = [[NSMutableArray alloc] initWithArray:array_keys];
    }
    
    [mut_array_keys addObject:key];
    [[NSUserDefaults standardUserDefaults] setObject:array_keys forKey:@"catched_keys"];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}

+ (NSDictionary*) GetLastCatchedInfoWithSeequID:(NSString*)ptID {
    NSString *userdetail_key = [NSString stringWithFormat:@"userdetail%@", ptID];
    
    NSData *catched_data = [[NSUserDefaults standardUserDefaults] objectForKey:userdetail_key];
    
    if (catched_data && [catched_data isKindOfClass:[NSData class]]) {
        NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:catched_data error:nil];
        return [dictionary objectForKey:@"return_values"];
    }
    
    return nil;
}

+ (NSData*) GetLastCatchedImageWithSeequID:(NSString*)ptID Height:(int)height {
    NSString *image_key = [NSString stringWithFormat:@"imagekey%@%d", ptID, height];
    NSData *catched_data = [[NSUserDefaults standardUserDefaults] objectForKey:image_key];
    
    return catched_data;
}

+ (void)postNotificationWithName:(NSString *)aName object:(id)anObject {
    NSNotification *notification = [NSNotification notificationWithName:aName object:anObject];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
}

+ (NSMutableArray*) GetSavedContacts {
    return (NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:CACHED_CONTACT_LIST_KEY];
    
}

+ (void) addBadgeOnCurrentUser:(NSString*)userId{
    NSArray *arrayContactsMessageBadge_ = [[NSUserDefaults standardUserDefaults] objectForKey:@"contactsMessageBadge"];
    NSMutableArray *arrayContactsMessageBadge = [NSMutableArray arrayWithArray:arrayContactsMessageBadge_];
    if (!arrayContactsMessageBadge) {
        arrayContactsMessageBadge = [[NSMutableArray alloc] init];
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"badge", userId, @"from", nil];
        [arrayContactsMessageBadge addObject:dict];
    } else {
        BOOL A = NO;
        for (NSDictionary *dict in arrayContactsMessageBadge) {
            if ([[dict objectForKey:@"from"] isEqualToString:userId]) {
                A = YES;
                int badge = [[dict objectForKey:@"badge"] integerValue];
                NSString *strBadge = [NSString stringWithFormat:@"%d",badge+1];
                NSDictionary *dict_ = [[NSDictionary alloc] initWithObjectsAndKeys:strBadge,@"badge", userId, @"from", nil];
                [arrayContactsMessageBadge removeObject:dict];
                [arrayContactsMessageBadge addObject:dict_];
                break;
            }
        }
        if (!A) {
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"badge", userId, @"from", nil];
            [arrayContactsMessageBadge addObject:dict];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:arrayContactsMessageBadge forKey:@"contactsMessageBadge"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) removeBadgeOnCurrentUser:(NSString*)userId{
    NSArray *arrayContactsMessageBadge_ = [[NSUserDefaults standardUserDefaults] objectForKey:@"contactsMessageBadge"];
    NSMutableArray *arrayContactsMessageBadge = [NSMutableArray arrayWithArray:arrayContactsMessageBadge_];
    for (NSDictionary *dict in arrayContactsMessageBadge) {
        if ([[dict objectForKey:@"from"] isEqualToString:userId]) {
            [arrayContactsMessageBadge removeObject:dict];

            break;
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:arrayContactsMessageBadge forKey:@"contactsMessageBadge"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIImage*)getVideoThumbnail:(NSURL*)path{
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:path options:nil];
    AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil];
    UIImage* im = [UIImage imageWithCGImage:imageRef];
    if (imageRef) {
        CGImageRelease(imageRef);
    }
    im = [Common getThumbImage:im];
    return im;
}
+(void)playIncomingMessageWithSeequID:(NSString*)SeequId andPushText:(NSString*)localPushText{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [[idoubs2AppDelegate sharedInstance].soundService vibrate];
        [[idoubs2AppDelegate sharedInstance].soundService playIncomingMessage];
    } else {
        [[idoubs2AppDelegate sharedInstance] ShowLocalPushForMessageWithSeequID:SeequId withPushText:localPushText andStatus:@"Message"];
    }
    
}


+ (int) getCurrentUserBadgeValue:(NSString*)userId{
    NSArray *arrayContactsMessageBadge_ = [[NSUserDefaults standardUserDefaults] objectForKey:@"contactsMessageBadge"];
    NSMutableArray *arrayContactsMessageBadge = [NSMutableArray arrayWithArray:arrayContactsMessageBadge_];
    if (!arrayContactsMessageBadge) {
        return 0;
    } else {
        for (NSDictionary *dict in arrayContactsMessageBadge) {
            if ([[dict objectForKey:@"from"] isEqualToString:userId]) {
                int badge = [[dict objectForKey:@"badge"] integerValue];
                return badge;
            }
        }
    }
    return 0;
}

+ (NSString*)createEditableCopyOfFileWithFileName:(NSString*)filename {
	// Get the path to the documents directory and append the filename
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString *path = [documentsDir stringByAppendingPathComponent:filename];
	// Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL success;
	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:path];
	
	// If the database already exists then return without doing anything
	if(success) return path;
	
	// If not then proceed to copy the database from the application to the users filesystem
	
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"XmppChat.plist"];
    
	// Copy the database from the package to the users filesystem
	if ([fileManager copyItemAtPath:databasePathFromApp toPath:path error:nil]) {
        return path;
    }
    
    return nil;
}

+ (BOOL) GetAddressBookSyncListWithArray:(NSMutableArray*)array ReturnArray:(NSArray**)retArray {
    NSString *url_data = [[CJSONSerializer serializer] serializeArray:array];
    url_data = [@"data=" stringByAppendingString:url_data];

    url_data = [url_data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url_data = [url_data stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSData *urlData = [url_data dataUsingEncoding:NSUTF8StringEncoding];

    
	NSString *urlString = [NSString stringWithFormat:@"%@/user/searchInContactInfo", [Common getBaseTomcatLink]];
    RSLogHTTP(@"[SEND] <GetAddressBookSyncListWithArray> - %@", urlString);
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSHTTPURLResponse * response;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                 cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                             timeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:urlData];
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    NSString *alldata = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        RSLogHTTP(@"[ERR] <GetAddressBookSyncListWithArray> - %@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]);
        return NO;
    }
    
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        *retArray = [dictionary objectForKey:@"return_values"];
        RSLogHTTP(@"[RCV] <GetAddressBookSyncListWithArray> - %@", *retArray);
        return YES;
    }

    return NO;
}

+ (NSString*) GetStringValueWithDictionary:(NSDictionary*)dict Key:(NSString*)key {
    if (dict && [dict isKindOfClass:[NSDictionary class]] &&
        [[dict objectForKey:key] isKindOfClass:[NSString class]]) {
        return  [dict objectForKey:key] ;
    }
    
    return @"";
}

+ (NSNumber*) GetIntValueWithDictionary:(NSDictionary*)dict Key:(NSString*)key {
    if (dict && [dict isKindOfClass:[NSDictionary class]] &&
        [[dict objectForKey:key] isKindOfClass:[NSNumber class]]) {
        return  [dict objectForKey:key];
    }
    
    return nil;
}

+ (BOOL) CheckFavoriteWithSeequID:(NSString*)seequID {
    
    for (NSString *ID in [Common sharedCommon].arrayFavorites) {
        if ([ID isEqualToString:seequID]) {
            return YES;
        }
    }

    return NO;
}
+(NSString*)GetFavoritsList:(NSArray**)array{
        NSString *urlString = [NSString stringWithFormat:@"%@/favorite/getFavoritesIds", [Common getBaseTomcatLink]];
        NSString * error_description;
        NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
        
        if (error_description) {
                return error_description;
        }
        
        NSError *error = nil;
        NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        
        if (error) {
                return @"Invalid data from server.";
        }
        
        if ([[dictionary objectForKey:@"success"] intValue] == 1) {
                *array=[[NSArray alloc]initWithArray:[dictionary objectForKey:@"return_values"]];
                return nil;
        }
        
        return [dictionary objectForKey:@"message"];
 
}
+ (NSString*) AddFavoriteWithSeequID:(NSString*)seequID {
	NSString *urlString = [NSString stringWithFormat:@"%@/favorite/add?conSeeQuId=%@", [Common getBaseTomcatLink],  seequID];
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        return error_description;
    }

    NSError *error = nil;
    
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
    
    if (error) {
        return @"Invalid data from server.";
    }

    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        return nil;
    }
    
    return [dictionary objectForKey:@"message"];
}

+ (NSString*) RemoveFavoriteWithSeequID:(NSString*)seequID {
	NSString *urlString = [NSString stringWithFormat:@"%@/favorite/remove?conSeeQuId=%@", [Common getBaseTomcatLink],  seequID];
    NSString * error_description;
    NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
    
    if (error_description) {
        return error_description;
    }

    NSError *error = nil;
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];

    if (error) {
        return @"Invalid data from server.";
    }
    
    if ([[dictionary objectForKey:@"success"] intValue] == 1) {
        return nil;
    }
    
    return [dictionary objectForKey:@"message"];
}
+(NSString*)GetMuteUsersList:(NSArray**)array{
        NSString *urlString = [NSString stringWithFormat:@"%@/blackList/getBlackListId", [Common getBaseTomcatLink]];
        NSString * error_description;
        NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
        
        if (error_description) {
                return error_description;
        }
        
        NSError *error = nil;
        NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        
        if (error) {
                return @"Invalid data from server.";
        }
        
        if ([[dictionary objectForKey:@"success"] intValue] == 1) {
                *array=[[NSArray alloc]initWithArray:[dictionary objectForKey:@"return_values"]];
                return nil;
        }
        
        return [dictionary objectForKey:@"message"];
        
}
+(NSString*)AddMuteUserWithSeequId:(NSString*)seequID{
        NSString *urlString = [NSString stringWithFormat:@"%@/blackList/add?conSeeQuId=%@", [Common getBaseTomcatLink],  seequID];
        NSString * error_description;
        NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
        
        if (error_description) {
                return error_description;
        }
        
        NSError *error = nil;
        
        NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        
        if (error) {
                return @"Invalid data from server.";
        }
        
        if ([[dictionary objectForKey:@"success"] intValue] == 1) {
                return nil;
        }
        
        return [dictionary objectForKey:@"message"];
}

+(NSString*)RemoveMuteUserWithSeequId:(NSString*)seequID{
        NSString *urlString = [NSString stringWithFormat:@"%@/blackList/remove?conSeeQuId=%@", [Common getBaseTomcatLink],  seequID];
        NSString * error_description;
        NSData *data = [Common SendSynchronousRequestWithURL:urlString TimeOut:REQUEST_TIME_OUT ErrorMessage:&error_description];
        
        if (error_description) {
                return error_description;
        }
        
        NSError *error = nil;
        NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        
        if (error) {
                return @"Invalid data from server.";
        }
        
        if ([[dictionary objectForKey:@"success"] intValue] == 1) {
                return nil;
        }
        
        return [dictionary objectForKey:@"message"];
}
+ (void) TransferContactInformation:(ContactObject*)from To:(ContactObject*)to {
    if (from.FirstName) to.FirstName = from.FirstName;
    if (from.LastName) to.LastName = from.LastName;
    if (from.country) to.country = from.country;
    if (from.state) to.state = from.state;
    if (from.City) to.City = from.City;
    if (from.TimeZone) to.TimeZone = from.TimeZone;
    if (from.LanguagePrimary) to.LanguagePrimary = from.LanguagePrimary;
    if (from.LanguageSecond) to.LanguageSecond = from.LanguageSecond;
    if (from.LanguageThird) to.LanguageThird = from.LanguageThird;
    if (from.LanguageFourth) to.LanguageFourth = from.LanguageFourth;
    if (from.ratingValue) to.ratingValue = from.ratingValue;
    if (from.ratingCount) to.ratingCount = from.ratingCount;
    if (from.reviewCount) to.reviewCount = from.reviewCount;
    if (from.topicCount) to.topicCount = from.topicCount;
    if (from.SessionsCount) to.SessionsCount = from.SessionsCount;
    if (from.badgeStatus) to.badgeStatus = from.badgeStatus;
    if (from.company) to.company = from.company;
    if (from.specialist) to.specialist = from.specialist;
    if (from.introduction) to.introduction = from.introduction;
    if (from.biography) to.biography = from.biography;
    if (from.arrayContactInfo) to.arrayContactInfo = from.arrayContactInfo;
    if (from.arrayInternetInfo) to.arrayInternetInfo = from.arrayInternetInfo;
    if (from.arraySocialInfo) to.arraySocialInfo = from.arraySocialInfo;
    if (from.arrayFavorites) to.arrayFavorites = from.arrayFavorites;
    if (from.arrayReviews) to.arrayReviews = from.arrayReviews;
    if (from.image) to.image = from.image;
}

- (void) onUpdateContact:(NSNotification*)notification {
    NSString *seequId = [notification object];
    
        ContactObject *object=[[ContactStorage sharedInstance] GetContactObjectBySeequId:seequId];
        if (object){
           [NSThread detachNewThreadSelector:@selector(GetingFirstLastName)
                                     toTarget:object
                                   withObject:nil];
//             UserInfoCoreData *userInfo=[[ContactStorage sharedInstance] getUserInfoBySeequId:seequId];
//             UIImage *image=[Common GetImageByPTID:seequId andHeight:IMAGE_HEIGHT];
            ///@todo levon
//            UIImage* imageAtPath =[[idoubs2AppDelegate sharedInstance].userPhotoDictionary objectForKey:userInfo.seeQuId];
//            if(imageAtPath){
//                NSError *error;
//                [[NSFileManager defaultManager] removeItemAtPath:[[ContactStorage sharedInstance] getImagePathBySeequID:userInfo.seeQuId] error:&error];
//            }
//            [UIImagePNGRepresentation(image) writeToFile:[[ContactStorage sharedInstance] getImagePathBySeequID:userInfo.seeQuId] atomically:YES];
     //       [[idoubs2AppDelegate sharedInstance].userPhotoDictionary setObject:image forKey:userInfo.seeQuId];
        }
    
}

+ (ContactObject*) getContactObjectWithSeequID:(NSString*)seequID {
    if (![Common sharedCommon]->arrayContactObjects) {
        [Common sharedCommon]->arrayContactObjects = [[NSMutableArray alloc] init];
    }

    if (![Common sharedCommon]->arrayOnRequestedContactObjects) {
        [Common sharedCommon]->arrayOnRequestedContactObjects = [[NSMutableArray alloc] init];
    }
    
    for (ContactObject *object in [Common sharedCommon]->arrayContactObjects) {
        if ([object.SeequID isEqualToString:seequID]) {
            return object;
        }
    }
    
    ContactObject *object = [[ContactObject alloc] initWithSeequID:seequID];
//    [NSThread detachNewThreadSelector:@selector(GetingFirstLastName)
//                             toTarget:object
//                           withObject:nil];

    [[Common sharedCommon]->arrayOnRequestedContactObjects addObject:object.SeequID];
    
    return object;
}

+ (void) AddContactObjectToCommonArray:(ContactObject*)object {
    if (![Common sharedCommon]->arrayContactObjects) {
        [Common sharedCommon]->arrayContactObjects = [[NSMutableArray alloc] init];
    }
    
    for (int index = 0; index < [Common sharedCommon]->arrayContactObjects.count; index++) {
        ContactObject *my_object = [[Common sharedCommon]->arrayContactObjects objectAtIndex:index];
        if ([my_object.SeequID isEqualToString:object.SeequID]) {
            [[Common sharedCommon]->arrayContactObjects replaceObjectAtIndex:index withObject:object];
            return;
        }
    }
    
    [[Common sharedCommon]->arrayContactObjects addObject:object];
    [Common RemoveContactObjectFromRequestedArray:object.SeequID];
}

+ (void) RemoveContactObjectFromRequestedArray:(NSString*)seequID {
    [[Common sharedCommon]->arrayOnRequestedContactObjects removeObject:seequID];
}

+ (BOOL) CheckObjectOnWait:(NSString*)seequID {
    for (NSString* obj in [Common sharedCommon]->arrayOnRequestedContactObjects) {
        if ([seequID isEqualToString:obj]) {
            return YES;
        }
    }
    
    return NO;
}

+ (NSData*) SendSynchronousRequestWithURL:(NSString*)url TimeOut:(int)seconds ErrorMessage:(NSString **)message {
    if ([[NSDate date] timeIntervalSince1970] - [Common sharedCommon].login_failed_time < LOGIN_FAILED_TIME_OUT) {
        *message = @"Authentication problem. \n Please restart the application.";
        return nil;
    }
    
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
//    NSLog(@"[HTTP][SEND] <SendSynchronousRequestWithURL> - %@", url);
    NSError *error;
    NSHTTPURLResponse * response;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:seconds];
    
    [request setHTTPMethod:@"POST"];
     [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"tommy.protime.tv"];
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"sip.protime.tv"];
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    if (error) {
        *message = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
//        NSLog(@"[HTTP][ERR] <SendSynchronousRequestWithURL> - %@", message);
        return nil;
    }
    else {
//        NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//        NSLog(@"allData === %@", allData);
        
        error = nil;
        
        NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        
        if (!error && dict) {
            NSString *auth = [dict objectForKey:@"message"];
//            NSLog(@"[HTTP][RCV] <SendSynchronousRequestWithURL> - %@", auth);
            
            if ([auth isEqualToString:@"Failed to auth"]) {
              NSString * retValu = [Common LoginWithSeequID:[[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_IMPI"]
                                              Password:[[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_PASSWORD"]];
                    BOOL isAuth =retValu?NO:YES;
                
                if (isAuth) {
                    [Common SendSynchronousRequestWithURL:url TimeOut:seconds ErrorMessage:message];
                } else {
                    *message = @"Authentication problem. \n Please restart the application.";
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autorisation_problem"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [Common postNotificationWithName:@"AuthenticationProblem" object:nil];
                    
                    return nil;
                }
            }
        }
    }
    
//    NSLog(@"[HTTP][RCV] <SendSynchronousRequestWithURL> - data received");
    return data;
}

+ (BOOL) NSStringisNullOrEmpty:(NSString*)string {
    return string == nil || string==(id)[NSNull null] || [string isEqualToString: @""];
}
+ (NSString *) ConvertDateToFriendlyString:(NSTimeInterval)time {
    
    //    NSDate
    
    NSString *retVal = @"";
    
    if (!time) {
        return retVal;
    }
    
    @try {
        //        NSDateComponents *event_components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit |
        //                                              NSMonthCalendarUnit |
        //                                              NSYearCalendarUnit |
        //                                              NSWeekCalendarUnit |
        //                                              NSWeekdayCalendarUnit |
        //                                              NSWeekdayOrdinalCalendarUnit
        //                                                                             fromDate:[NSDate dateWithTimeIntervalSince1970:time]];
        NSDate *date=[NSDate dateWithTimeIntervalSince1970:time];
        
        //        NSInteger event_day = [event_components day];
        //        NSInteger event_month = [event_components month];
        //        NSInteger event_year = [event_components year];
        //            NSInteger event_week = [event_components weekday];
        NSDateFormatter *Shortday = [[NSDateFormatter alloc] init];
        Shortday.timeStyle = kCFDateFormatterShortStyle;
        Shortday.dateStyle = NSDateFormatterShortStyle;
        Shortday.doesRelativeDateFormatting = YES;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd, yyy"];
        NSDateFormatter *weekDay = [[NSDateFormatter alloc] init];
        [weekDay setDateFormat:@"EEE"];
        NSDateFormatter *hours=[[NSDateFormatter alloc] init];
        [hours setDateFormat:@"hh:mm"];
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        
        int event_day_count = time/86400;
        int now_day_count = now/86400;
        
        int call_day_diff = now_day_count - event_day_count;
        BOOL isWeekday = NO;
        
        switch (call_day_diff) {
            case 0: {
                isWeekday = YES;
                retVal = [Shortday stringFromDate:date];
            }
                break;
            case 1:
            {
                isWeekday = YES;
                retVal = [Shortday stringFromDate:date];
            }
                break;
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
            case 7: {
                isWeekday = YES;
                retVal =[NSString stringWithFormat:@"%@ %@",[weekDay stringFromDate:date],[hours stringFromDate:date]];
            }
                break;
        }
        
        if (!isWeekday) {
            retVal = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
        }
    } @catch (NSException * e) {
        return @"";
    }
    
    return retVal;
}

+ (NSString *) ConvertNSDateToFriendlyString:(NSDate*)date {
    
    //    NSDate
    
        NSString *retVal = @"";
    if (!date) {
        return retVal;      
    }
        @try {
                NSTimeInterval time = [date timeIntervalSince1970];
                NSDateFormatter *Shortday = [[NSDateFormatter alloc] init];
                Shortday.timeStyle = kCFDateFormatterShortStyle;
                Shortday.dateStyle = NSDateFormatterShortStyle;
                Shortday.doesRelativeDateFormatting = YES;
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MMM dd, yyy"];
                NSDateFormatter *weekDay = [[NSDateFormatter alloc] init];
                [weekDay setDateFormat:@"EEE"];
                NSDateFormatter *hours=[[NSDateFormatter alloc] init];
                [hours setDateFormat:@"hh:mm"];
                NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                
                int event_day_count = time/86400;
                int now_day_count = now/86400;
                
                int call_day_diff = now_day_count - event_day_count;
                BOOL isWeekday = NO;
                
                switch (call_day_diff) {
                        case 0: {
                                isWeekday = YES;
                                retVal = [Shortday stringFromDate:date];
                        }
                                break;
                        case 1:
                        {
                                isWeekday = YES;
                                retVal = [Shortday stringFromDate:date];
                        }
                                break;
                        case 2:
                        case 3:
                        case 4:
                        case 5:
                        case 6:
                        case 7: {
                                isWeekday = YES;
                                retVal =[NSString stringWithFormat:@"%@ %@",[weekDay stringFromDate:date],[hours stringFromDate:date]];
                        }
                                break;
                }
                
                if (!isWeekday) {
                        retVal = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
                }
        } @catch (NSException * e) {
                return @"";
        }
        
        return retVal;
}

+ (NSString *) ConvertIntToWeekDay:(int)day {
    NSString *retVal = @"";
    if (!day || day > 7) {
        return retVal;
    }
    
    switch (day) {
        case 1:
            retVal = @"Sunday";
            break;
        case 2:
            retVal = @"Monday";
            break;
        case 3:
            retVal = @"Tuesday";
            break;
        case 4:
            retVal = @"Wednesday";
            break;
        case 5:
            retVal = @"Thursday";
            break;
        case 6:
            retVal = @"Friday";
            break;
        case 7:
            retVal = @"Saturday";
            break;
        default:
            break;
    }
    
    return  retVal;
}

+ (NSString*)ConvertDurationToStringForCall:(int)duration {
    NSString *str;
//  JSC  int houres = 0;
    int minutes = 0;
    int secondes = 0;
    
    if (duration >= 3600) {
//   JSC     houres = duration / 3600;
        duration = duration % 3600;
    }
    
    if (duration >= 60) {
        minutes = duration / 60;
        duration = duration % 60;
    }
    
    secondes = duration;
    
    if (minutes != 0) {
        str = [NSString stringWithFormat:@"%d:%02d", minutes, secondes];
    } else {
        str = [NSString stringWithFormat:@"0:%02d", secondes];
    }
    
    return str;
}


+(int) getReceivedMessageType:(NSDictionary *)dict {
    return -1;
}

+(NSString*) getVideoDirectLink:(NSString*) fp{
    
    
//    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"us-east.manta.joyent.com/seequ/stor/TESTPATH/movie.mov"]] ;
//    [request setHTTPMethod:@"GET"];
//    [request setValue:@"us-east.manta.joyent.com" forHTTPHeaderField:@"host"];
//    [request setValue:@"/seequ/stor/TESTPATH/movie.mov" forHTTPHeaderField:@"path"];
//    [request set]

    NSString* paramStr = nil;
    char* encOut = 0;
    char* encodedSignedDate = 0;
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"id_rsa"];
    
    tbi_rsa_t* rsa_private = rsaOpenPrivate([filePath UTF8String]);
    
       
   
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString*  keyID = @"/seequ/keys/7a:82:63:83:49:12:9d:ce:6f:c1:3f:76:bd:18:76:67";
    keyID =[keyID urlEncodeUsingEncoding:NSUTF8StringEncoding];
    paramStr = [NSString stringWithFormat:@"algorithm=rsa-sha256&expires=%lld&keyId=%@",milliseconds + 180*1000, keyID];
    NSString* signString = [NSString stringWithFormat:@"GET\n%@\n%@%@\n%@",@"us-east.manta.joyent.com",@"/seequ/stor/",fp,paramStr];
    int retval = rsaSign(rsa_private, [signString UTF8String], signString.length, &encOut);
    NSLog(@"%@",signString);

    if (retval) {
        TBI_size_t size = TBI_base64_encode((const uint8_t*)encOut, retval, &encodedSignedDate);
        NSString*  tempStr = [NSString stringWithFormat:@"%.*s",  size, encodedSignedDate];
        tempStr =[tempStr urlEncodeUsingEncoding:NSUTF8StringEncoding];
       

        paramStr = [NSString stringWithFormat:@"%@&signature=%@", paramStr, tempStr];

      //  return [[NSDictionary alloc] initWithObjectsAndKeys:authzHeader, @"AuthzHeader", date, @"date", nil];
        NSString*  requestString = [NSString stringWithFormat:@"https://us-east.manta.joyent.com/seequ/stor/%@?%@",fp,paramStr ];
        NSLog(@"%@",requestString);
      return  requestString;
    }
    return nil;
}

+ (NSDictionary*) createAuthzHeaders {
    char* encOut = 0;
    char* encodedSignedDate = 0;
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"id_rsa"];
    
    tbi_rsa_t* rsa_private = rsaOpenPrivate([filePath UTF8String]);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
 //   [formatter setLocale:[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ;
    NSLocale* loc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter.locale =loc;
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [formatter setDateFormat:@"EEE MMM d HH:mm:ss yyyy zzz"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    NSString *signature_date = [@"date: " stringByAppendingString:date];
    
    int retval = rsaSign(rsa_private, [signature_date UTF8String], signature_date.length, &encOut);
    
    if (retval) {
        TBI_size_t size = TBI_base64_encode((const uint8_t*)encOut, retval, &encodedSignedDate);
        NSString *authzHeader = [NSString stringWithFormat:@"Signature keyId=\"/seequ/keys/7a:82:63:83:49:12:9d:ce:6f:c1:3f:76:bd:18:76:67\",algorithm=\"rsa-sha256\",signature=\"%.*s\"", size, encodedSignedDate];
        
        return [[NSDictionary alloc] initWithObjectsAndKeys:authzHeader, @"AuthzHeader", date, @"date", nil];
    }
    
    return nil;
}

+ (NSString*) putImageToSeequID:(NSString*)seequID ImageData:(NSData*)imgData ImageName:(NSString*)imgName {
    if (![Common createDirectoryOnMantaWithSeequID:seequID])
        return nil;
    
    NSDictionary *dict = [Common createAuthzHeaders];
    NSString *authzHeader = [dict objectForKey:@"AuthzHeader"];
    NSString *date = [dict objectForKey:@"date"];

    NSString *url = [NSString stringWithFormat:@"https://us-east.manta.joyent.com/seequ/stor/%@/%@", seequID, imgName];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    RSLogHTTP(@"[SEND] {putImageToSeequID} - %@", url);
    NSError *error;
    NSHTTPURLResponse * response;

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:30];
    [request addValue:date forHTTPHeaderField:@"Date"];
    [request addValue:authzHeader forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:imgData];
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    RSLogHTTP(@"[RCV] {putImageToSeequID} - responseStatus:%d", response.statusCode);
    
    if (response && response.statusCode == 204) {
        return url;
    }
    
//    NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    NSLog(@"allData === %@", allData);
    
    return nil;
}

+ (NSString*) putVideoToSeequID:(NSString*)seequID videoData:(NSData*)videoData videoName:(NSString*)videoName {
    if (![Common createDirectoryOnMantaWithSeequID:seequID])
        return nil;
    
    NSDictionary *dict = [Common createAuthzHeaders];
    NSString *authzHeader = [dict objectForKey:@"AuthzHeader"];
    NSString *date = [dict objectForKey:@"date"];
    
    NSString *url = [NSString stringWithFormat:@"https://us-east.manta.joyent.com/seequ/stor/%@/%@", seequID, videoName];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    RSLogHTTP(@"[SEND] {putImageToSeequID} - %@", url);
    NSError *error;
    NSHTTPURLResponse * response;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:30];
    [request addValue:date forHTTPHeaderField:@"Date"];
    [request addValue:authzHeader forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:videoData];
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    RSLogHTTP(@"[RCV] {putImageToSeequID} - responseStatus:%d", response.statusCode);
    if (error) {
        NSLog(@"%@", error.debugDescription);
    }
    if (response && response.statusCode == 204) {
        return url;
    }
    
    //    NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    //    NSLog(@"allData === %@", allData);
    NSLog(@"The response  is : %d",response.statusCode);
  
    return nil;
}


+ (NSString*) startJob:(NSString*)seequID ImageName:(NSString*)imgName Size:(NSString*)size {
    NSDictionary *dict = [Common createAuthzHeaders];
    NSString *authzHeader = [dict objectForKey:@"AuthzHeader"];
    NSString *date = [dict objectForKey:@"date"];
    
    NSString *url = [NSString stringWithFormat:@"https://us-east.manta.joyent.com/seequ/jobs/"];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    RSLogHTTP(@"[SEND] {startJob} - %@", url);
    
    NSString *reqDataStr = [NSString stringWithFormat:@"{\"name\":\"image resize\",\"phases\":[{\"exec\":\"convert $MANTA_INPUT_FILE -resize %@ /var/tmp/out.png && mpipe /seequ/stor/%@/%@_t.png < /var/tmp/out.png\"}]}", size, seequID, imgName];
    
    NSData *reqData = [reqDataStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSHTTPURLResponse * response;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:30];
    [request addValue:date forHTTPHeaderField:@"Date"];
    [request addValue:authzHeader forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:reqData];
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    RSLogHTTP(@"[RCV] {startJob} - responseStatus:%d, data:%@", response.statusCode, [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    
    if (response && response.statusCode == 201) {
        NSString *location = [[response allHeaderFields] objectForKey:@"location"];
        
        return location;
    }
    
//    NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    NSLog(@"allData === %@", allData);
    
    return nil;
}
/*
+ (BOOL) preparJob:(NSString*)job SeequID:(NSString*)seequID  ImageName:(NSString*)imgName {
    NSDictionary *dict = [Common createAuthzHeaders];
    NSString *authzHeader = [dict objectForKey:@"AuthzHeader"];
    NSString *date = [dict objectForKey:@"date"];
    NSData *reqData = [[NSString stringWithFormat:@"/seequ/stor/%@/%@", seequID, imgName] dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSString *url = [NSString stringWithFormat:@"https://us-east.manta.joyent.com%@/live/in", job];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    RSLogHTTP(@"[SEND] {preparJob} - %@", url);
    
    NSError *error;
    NSHTTPURLResponse * response;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:30];
    [request addValue:date forHTTPHeaderField:@"Date"];
    [request addValue:authzHeader forHTTPHeaderField:@"Authorization"];
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:reqData];
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    RSLogHTTP(@"[RCV] {preparJob} - responseStatus:%d, data:%@", response.statusCode, [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    
    if (response && response.statusCode == 204) {
        return YES;
    }
    
//    NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    NSLog(@"allData === %@", allData);
    
    return NO;
}

+ (BOOL) runAndEndJob:(NSString*)job SeequID:(NSString*)seequID  ImageName:(NSString*)imgName {
    NSDictionary *dict = [Common createAuthzHeaders];
    NSString *authzHeader = [dict objectForKey:@"AuthzHeader"];
    NSString *date = [dict objectForKey:@"date"];
    
    NSString *url = [NSString stringWithFormat:@"https://us-east.manta.joyent.com%@/live/in/end", job];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    RSLogHTTP(@"[SEND] {runAndEndJob} - %@", url);
    
    NSError *error;
    NSHTTPURLResponse * response;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:30];
    [request addValue:date forHTTPHeaderField:@"Date"];
    [request addValue:authzHeader forHTTPHeaderField:@"Authorization"];
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    RSLogHTTP(@"[RCV] {runAndEndJob} - responseStatus:%d, data:%@", response.statusCode, [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    
    if (response && response.statusCode == 202) {
        return YES;
    }
    
//    NSDictionary *allFields = [response allHeaderFields];
//    NSLog(@"allFields: %@", allFields);
//    
//    NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    NSLog(@"allData === %@", allData);
    
    return NO;
}

*/


+ (UIImage *)fixOrientationOfImage:(UIImage *)image  {
    
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (NSString*) getJobFileLink:(NSString*)job {
    NSDictionary *dict = [Common createAuthzHeaders];
    NSString *authzHeader = [dict objectForKey:@"AuthzHeader"];
    NSString *date = [dict objectForKey:@"date"];
    
    NSString *url = [NSString stringWithFormat:@"https://us-east.manta.joyent.com%@/live/out", job];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    RSLogHTTP(@"[SEND] {getJobFileLink} - %@", url);
    
    NSError *error;
    NSHTTPURLResponse * response;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:30];
    [request addValue:date forHTTPHeaderField:@"Date"];
    [request addValue:authzHeader forHTTPHeaderField:@"Authorization"];
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    RSLogHTTP(@"[RCV] {getJobFileLink} - responseStatus:%d, data:%@", response.statusCode, [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    
    if (response && response.statusCode == 200) {
        return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
    return nil;
}

+ (NSString*) getJobError:(NSString*)job SeequID:(NSString*)seequID  ImageName:(NSString*)imgName {
     NSDictionary *dict = [Common createAuthzHeaders];
    NSString *authzHeader = [dict objectForKey:@"AuthzHeader"];
    NSString *date = [dict objectForKey:@"date"];
    
    NSString *url = [NSString stringWithFormat:@"https://us-east.manta.joyent.com%@/live/err", job];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    RSLogHTTP(@"[SEND] {getJobError} - %@", url);
    
    NSError *error;
    NSHTTPURLResponse * response;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:30];
    [request addValue:date forHTTPHeaderField:@"Date"];
    [request addValue:authzHeader forHTTPHeaderField:@"Authorization"];
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
//    if (response && response.statusCode == 200) {
//        NSDictionary *dict = [response allHeaderFields];
//    }
    
    NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    RSLogHTTP(@"[RCV] {getJobError} - responseStatus:%d, data:%@", response.statusCode, allData);
    return allData;
}

+ (NSData*) getMediaDataWithURLString:(NSString *)url_string {
    NSDictionary *dict = [Common createAuthzHeaders];
    NSString *authzHeader = [dict objectForKey:@"AuthzHeader"];
    NSString *date = [dict objectForKey:@"date"];
    
    url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url_string = [url_string stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSError *error;
    NSHTTPURLResponse * response;
    RSLogHTTP(@"[SEND] {getImageDataWithURLString} - %@", url_string);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url_string]
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:30];
    [request addValue:date forHTTPHeaderField:@"Date"];
    [request addValue:authzHeader forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (!data) {
        if (error) {
            RSLogHTTP(@"[ERR] {getImageDataWithURLString} - %@", error.localizedDescription);
        }
        
        return nil;
    }
    
//    NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    NSLog(@"allData === %@", allData);
//
    RSLogHTTP(@"[RCV] {getImageDataWithURLString} - Data received");
    return data;
}
+ (int) TUMB_IMAGE_MAX_WIDTH_PORTRAIT {
    return [[UIScreen mainScreen] bounds].size.width - 105;
}

+ (int) TUMB_IMAGE_MAX_WIDTH_LANDSCAPE {
    return [[UIScreen mainScreen] bounds].size.height - 105;
}

+ (UIImage*) getThumbImage:(UIImage*)img {
    int imageWeight = ((TUMB_IMAGE_HEIGHT/2)*img.size.width)/img.size.height;
    int imageHeight = 100;
    
    if (imageWeight > [Common TUMB_IMAGE_MAX_WIDTH_PORTRAIT]) {
        imageWeight = [Common TUMB_IMAGE_MAX_WIDTH_PORTRAIT];
        imageHeight = (imageWeight*img.size.height)/img.size.width;
    }
    UIImage *newImage = [self imageWithImage:img scaledToSize:CGSizeMake(imageWeight, imageHeight)];
    return  newImage;
}


+(UIImage*) getThumbnailFromData:(NSData*) data isVideo:(NSURL*) url {
    if (!url) {
         return [Common getThumbImage:[UIImage imageWithData: data]];
    } else {
       return  [Common getVideoThumbnail:url];
    }
    
}

+(void) getMedia:(NSString *)url saveToFolder:(NSString *)folder message:(NSString*) messageID  seequID:(NSString*) seequId isVideo:(BOOL) flag{
    
    NSAssert(url, @"the url  must  be  initialised");
    NSAssert(folder, @"the folder  must  be  initialised");

    ///////
    dispatch_queue_t myQueue = dispatch_queue_create("Save Media",NULL);
    dispatch_async(myQueue, ^{
        
        NSData* data = [self getMediaDataWithURLString:url];
        
        if (!data) {
            return ;
        }
        NSString*  extension = (flag)? @"_video.mp4":@"_image.png";
        
        NSString *thePath = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", messageID,extension]];
        [data writeToFile:thePath options:NSAtomicWrite error:nil];
        ///@todo sets  thumbnail
        NSURL* url = nil;
        if (flag) {
             url = [NSURL fileURLWithPath:thePath];

        }
        
          UIImage* image = [Common getThumbnailFromData:data isVideo:url];
        
        [[MessageCoreDataManager sharedManager] updateMediaMessageDownloadState:messageID thumbnail:image];
        NSString* str =(flag)?@"sent you a video":@"sent you an image";
        [Common playIncomingMessageWithSeequID:seequId andPushText:str];
    });

    
 }

+ (BOOL) createDirectoryOnMantaWithSeequID:(NSString*)seequID {
    NSDictionary *dict = [Common createAuthzHeaders];
    NSString *authzHeader = [dict objectForKey:@"AuthzHeader"];
    NSString *date = [dict objectForKey:@"date"];
    
    NSString *url = [NSString stringWithFormat:@"https://us-east.manta.joyent.com/seequ/stor/%@", seequID];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    RSLogHTTP(@"[SEND] {createDirectoryOnMantaWithSeequID} - %@", url);
    NSError *error;
    NSHTTPURLResponse * response;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:30];
    [request addValue:date forHTTPHeaderField:@"Date"];
    [request addValue:authzHeader forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json; type=directory" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"PUT"];
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    RSLogHTTP(@"[RCV] {createDirectoryOnMantaWithSeequID} - responseStatus:%d, data:%@", response.statusCode, [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
    
    if (response && response.statusCode == 204) {
        return YES;
    }
    
//    NSString *allData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    NSLog(@"allData === %@", allData);
    
    return NO;
}


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(BOOL) sendMessageWithImageFile:(SeequMessageObject*) info{
    @autoreleasepool {
        NSLog(@"imageForSend.size: %@", NSStringFromCGSize(info.image.size));
        
        NSString *image_Name = [NSString stringWithFormat:@"image_name_%@.png", info.msgId];
            NSData *image_Data=UIImageJPEGRepresentation(info.image, 0.9);

        NSString *url_image = [Common putImageToSeequID:info.from ImageData:image_Data ImageName:image_Name];
        
        int imageWeight = (TUMB_IMAGE_HEIGHT*info.image.size.width)/info.image.size.height;
        CGSize imageSize=CGSizeMake(imageWeight, TUMB_IMAGE_HEIGHT);
        
        info.image=[Common imageWithImage:info.image scaledToSize:imageSize];
        NSString *image_Name_t = [NSString stringWithFormat:@"image_name_%@_t.png", info.msgId];
        
        NSString *url_image_t = [Common putImageToSeequID:info.from ImageData:image_Data ImageName:image_Name_t];
        
        if (!url_image || !url_image_t) {
              return NO;
        } else {            
            [Common performSelectorOnMainThread:@selector(sendMessageOnMainThreadWithMessageItem:) withObject:info waitUntilDone:YES];
        }
        
        return YES;
    }
}

+(BOOL) sendMessageWithVideoFile:(SeequMessageObject *)info {
    @autoreleasepool {
        
        NSString *video_Name =[NSString stringWithFormat:@"video_name_%@.mp4", info.msgId];
        NSString *url_Video = [Common putVideoToSeequID:info.from videoData:info.videoData videoName:video_Name];
        
        CGSize size=CGSizeMake((TUMB_IMAGE_HEIGHT*info.thumbnail.size.width)/info.thumbnail.size.height, TUMB_IMAGE_HEIGHT);
        info.thumbnail=[self imageWithImage:info.thumbnail scaledToSize:size];
        
        NSString *video_Name_t=[NSString stringWithFormat:@"video_name_%@_t.png", info.msgId];
        NSString *url_video_t=[Common putImageToSeequID:info.from ImageData:UIImagePNGRepresentation(info.thumbnail) ImageName:video_Name_t];
        
          
        if (!url_Video || !url_video_t) {
            return NO;
        } else {
            [Common performSelectorOnMainThread:@selector(sendMessageOnMainThreadWithMessageItem:) withObject:info waitUntilDone:YES];
        }
        
        return YES;
    }
}


+ (void) sendMessageOnMainThreadWithMessageItem : (SeequMessageObject*) info{
//    NSString *message = [NSString stringWithFormat:@"*#IMAGE FILE#*%@*#IMAGE FILE#*%@", info.url, info.textMessage];
  //  [[idoubs2AppDelegate getChatManager] SendTextMessage:message to:info.seequId MessageID:info.messageId AddToResendList:YES];
 //   SeequMessageObject* obj = [[SeequMessageObject alloc] initWithFileTransferData: info];
    RTMPChatManager* man = (RTMPChatManager*)[idoubs2AppDelegate getChatManager];
    [ man sendTextMessage:info  AddToResendList:YES];
}

+(void) sendMessageOnMainThreadWithVideoMessageItem: (SeequMessageObject*) info{
//    NSString *message ;
//    if (info.type==Message_Type_Video_Response ){
//        message=[NSString stringWithFormat:@"*#DOUBLE_TAKE#*%@*#VIDEO FILE#*%@*#VIDEO FILE#*%d", info.url, info.textMessage,info.type ];
//    }else{
//        message=[NSString stringWithFormat:@"*#VIDEO FILE#*%@*#VIDEO FILE#*%@*#VIDEO FILE#*%d", info.url, info.textMessage,info.type];
//    }
    
    RTMPChatManager* man = (RTMPChatManager*)[idoubs2AppDelegate getChatManager];
    [ man sendTextMessage:info  AddToResendList:YES];

}




@end


