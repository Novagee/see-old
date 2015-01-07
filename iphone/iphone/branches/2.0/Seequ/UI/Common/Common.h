//
//  Common.h
//  ProTime
//
//  Created by Artak on 7/13/11.
//  Copyright 2011 BeInteractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactObject.h"
#import "RSLogging.h"


///Group
#define GROUP_ID [NSString stringWithFormat:@"groupid%.0f", [[NSDate date] timeIntervalSince1970]*1000.0]

#define IS_IOS_7  ((floor(NSFoundationVersionNumber)>NSFoundationVersionNumber_iOS_6_1) ? YES : NO)
#define USER_UPDATE_TIME_INTERVAL 3600
#define CACHED_CONTACT_LIST_KEY [NSString stringWithFormat:@"cachedContactList_key_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"IDENTITY_IMPI"]]
#define kXMPPStatusChangeNotification @"kXMPPStatusChangeNotification"
#define kXMPPConnectionChangeNotification @"kXMPPConnectionChangeNotification"
#define kXMPPAuthenticateNotification @"kXMPPAuthenticateNotification"
#define kContactListNotification @"kContactListNotification"
#define kPhotoSavedNotification @"kPhotoSavedNotification"
#define kStopVideoCapturing @"kStopVideoCapturing"

#define kMISSEDCALL @"kMISSEDCALL"
#define kNewTextMessage @"NewTextMessage"

#define DEVELOPER_MODE @"Development Settings"
#define XMPP_TRANSPORT @"XMPP Transport"
#define TOMCAT_DEBUG @"Tomcat Debugging"
#define RTMP_DEBUG @"RTMP Debugging"
#define RTMP_SERVER @"RTMP Server"
#define SIP_SERVER @"SIP Server"
#define TOMCAT_SERVER @"Tomcat Server"
#define IS_IPHONE_5 (([[UIScreen mainScreen] bounds].size.height-568) ? NO : YES)
#define VIDEO_DURATION 60
#define DOUBLE_TAKE_REJECT @"-=REJECT DT=-:"


#define TUMB_IMAGE_HEIGHT 200




typedef enum Message_Type {
	Message_Type_NON,
    Message_Type_Text,
    Message_Type_Image,
    Message_Type_Video,
    Message_Type_Video_Response,
    Message_Type_Double_Take,
    Message_Type_Ringback,
    Message_Type_Connection,
    Message_Type_Update,
    Message_Type_Browser_Session_Connect,
    Message_Type_Browser_Session_Disconnect,
    Message_Type_Browser_Link
} Message_Type;

typedef enum {
    SeequRecorderTypeNone,
    SeequRecorderTypePhoto,
    SeequRecorderTypeVideo,
    SeequRecorderTypeDoubleTake
} SeequRecorderType;





@interface SeequMessageObject : NSObject
    @property (nonatomic,retain) NSString* from;
    @property (nonatomic,retain) NSString* from_name;
    @property (nonatomic,retain) NSNumber* time;
    @property (nonatomic,retain) NSString* msg;
    @property (nonatomic,retain) NSString* msgId;
    @property (nonatomic,assign) Message_Type type;
    @property (nonatomic,retain) NSString* url;
    @property (nonatomic,retain) NSString* url_dt;
    @property (nonatomic,retain) UIImage* image;
    @property (nonatomic,retain) NSData*  videoData;
    @property (nonatomic,retain) NSString* videoName;
    @property (nonatomic,retain) UIImage* thumbnail;

    -(id) initWithDictionary:(NSDictionary*) dictionary;
@end

@interface Common : NSObject<NSURLConnectionDelegate> {
    NSString *SeequID;
    NSString *email;
    NSMutableArray *arrayContactObjects;
    NSMutableArray *arrayOnRequestedContactObjects;
    
}

@property (nonatomic, strong) ContactObject *contactObject;
@property (nonatomic, strong, getter = SeequID) NSString *SeequID;
@property (nonatomic, strong) NSString *email;

@property (nonatomic, strong) NSArray *arrayStates;
@property (nonatomic, strong) NSMutableArray *arrayFavorites;
@property (nonatomic, strong) NSArray *arrayCountries;
@property (nonatomic, strong) NSMutableDictionary *MissedEvents;
@property (nonatomic, assign) NSTimeInterval login_failed_time;


+ (Common *) sharedCommon;
+ (NSString*) LoginWithSeequID:(NSString*)seequID Password:(NSString*)password;
+ (NSString*) GetAllUsersBySeequID:(NSString*)seequID;
+ (NSString*) GetUpdatedUsersBySeequID:(NSString*)seequID LastModDate:(double)modDate UserList:(NSDictionary**)dictionary;
+ (int) GetContactCountWithSeequID:(NSString*)seequID;
//+ (NSArray*) GetSavedContactList;
//+ (void) AddUserToSavedContactListWithSeequID:(NSDictionary*)userDict;
//+ (void) RemoveUserFromSavedContactListWithSeequID:(NSString*)seequID;
+ (int) GetProfileInfoByPTID:(NSString*)seequID withActivityBadgCount:(BOOL)badg;
+ (NSDictionary*) GetProfileData:(NSString*)userId;
+ (void) SetProfileImageByPTID:(NSString*)ptID;
+ (NSMutableDictionary*) GetUserDetailsByPTID:(NSString*)seequID;
+ (UIImage*) GetImageByPTID:(NSString*)seequID andHeight:(int)height;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize ;
+ (void) SetProfileDataByDictionary:(NSDictionary*)dict;
+ (NSString*) GetSeequIDByEmail:(NSString*)mail SeequID:(NSString**)seequID;
- (NSString*) SeequID;
+ (NSString*) CreateValidString:(NSString*)string;
+ (NSString*) ConvertDurationToString:(int)duration;
+ (NSString*) ConvertDurationToStringNoZero:(int)duration;
+ (NSString*) ConvertDurationToMoney:(int)duration WithHourlyRate:(NSString*)hrate;
+ (BOOL) validateEmail: (NSString *)emailStr;
+ (NSString*) validatePwd: (NSString *)pwdStr;
+ (BOOL) validateStr: (NSString *)txtStr;
+ (BOOL) isEmpty:(NSString *)myStr;
+ (NSString*) AddRecentsCallWithSeequID:(NSString*)seequID StartTime:(NSTimeInterval)startTime StopTime:(NSTimeInterval)stopTime;
+ (NSString*) AddMissedCallWithSeequID:(NSString*)seequID StartTime:(NSTimeInterval)startTime;
+ (NSString*) AddRequestWithSeequID:(NSString*)seequID Date:(NSTimeInterval)date Name:(NSString*)name Content:(NSString*)content;
+ (NSString*) UpdateRequestWithID:(int)seequID Date:(NSTimeInterval)date Status:(NSString*)status;
+(NSString*) getBaseTomcatLink;
+(NSString*) getBaseSIPLink;
+(NSString*) getBaseRTMPLink;
+ (UIImage*) getThumbImage:(UIImage*)img ;

+(void) GetUserDetailsBySeequId:(NSString*) seequID success:(void (^)(NSMutableDictionary * dict))success;

+(UIImage *)fixOrientationOfImage:(UIImage *)image ;
+ (void) GetRecentCallsWithDate:(NSTimeInterval)date;
+ (void) GetRequestsWithDate:(NSTimeInterval)date;
+ (NSDictionary*) GetOnlineUsers;
//+ (void) ChangeContactObjectsRequestStatus:(ContactObject*)object RequestStatus:(Request_Status)status;
+ (NSString*) CleareAllActivitys;
+ (BOOL) isGreenColor:(UIColor*)color;
+ (BOOL) isRedColor:(UIColor*)color;
+ (NSString*) SearchContactsWithText:(NSString*)key ReturnedArray:(NSMutableArray**)array;
+ (NSString*) SearchContactsWithText:(NSString*)key ReturnedArray:(NSMutableArray**)array start:(int) startPos limit:(int)limit total:(NSNumber**) totalCount;
+ (NSString*) FindFilePathWithFilename:(NSString*)fileName;
+ (NSString*) RegisterPushNotificationWithDeviceToken:(NSString*)DeviceToken registerForce:(BOOL)forse;
+ (NSString*) UnRegisterPushNotificationWithDeviceToken:(NSString*)DeviceToken;
+ (NSString*) SendPushNotificationTo:(NSString*)ptID withText:(NSString*)text Status:(NSString*)status;
- (NSString*) ResetNotificationBadgesCount;
+ (NSMutableArray*) GetAllStates;
+ (NSArray*) GetAllCountries;
+ (NSArray*) GetStatesById:(NSString*) countryId ;
+ (NSString*)changePassword:(NSString*) newPassword;

+ (void) SetMissedWithSeequID:(NSString*)proID Type:(int)type MissedCount:(int)missedCount;
+ (void) AddMissedWithSeequID:(NSString*)proID Type:(int)type;
+ (void) RemoveMissedWithSeequID:(NSString*)proID Type:(int)type;
+ (int) GetAllMissedsCalls; ///@todo  needs  to check  for  proper  work  (not tested)
+ (int) GetAllMissedCallsFromCash;
+ (void) SetMissedCallsCountToCash:(int) count;
+ (int) GetAllMisseds;
+ (int) GetMissedMessages;
+ (void)incrementMessageBadgeWith:(int)incrCount;
+ (void) SaveDataWithData:(NSData*)data key:(NSString*)key;
+ (NSDictionary*) GetLastCatchedInfoWithSeequID:(NSString*)ptID;
+ (NSData*) GetLastCatchedImageWithSeequID:(NSString*)ptID Height:(int)height;
+ (void)postNotificationWithName:(NSString *)aName object:(id)anObject;
+ (NSMutableArray*) GetSavedContacts;
+ (NSString*) ConvertDurationStandart:(NSString*)duration;
+ (void) addBadgeOnCurrentUser:(NSString*)userId;
+ (void) removeBadgeOnCurrentUser:(NSString*)userId;
+ (int) getCurrentUserBadgeValue:(NSString*)userId;
+ (NSString*) createEditableCopyOfFileWithFileName:(NSString*)filename;
+ (BOOL) GetAddressBookSyncListWithArray:(NSMutableArray*)array ReturnArray:(NSArray**)retArray;
+ (NSString*) send_Rating_RequestWithSeequID:(NSString*)seeQuId Title:(NSString*)title Content:(NSString*)content  RatingValue:(int)value ReturnDictionary:(NSDictionary**)dictionary;
+ (NSString*) SendRingbackEmailWithEmail:(NSString*)mail SeequID:(NSString*)seequID;
+ (NSString*) SendInvitationEmailWithEmail:(NSString*)mail SeequID:(NSString*)seequID;
+ (NSString*) SendResetPasswordWithEmail:(NSString*)mail;
+ (NSString*) GetStringValueWithDictionary:(NSDictionary*)dict Key:(NSString*)key;
+ (NSNumber*) GetIntValueWithDictionary:(NSDictionary*)dict Key:(NSString*)key ;
+ (BOOL) CheckFavoriteWithSeequID:(NSString*)seequID;
+ (NSString*) AddFavoriteWithSeequID:(NSString*)seequID;
+ (NSString*) RemoveFavoriteWithSeequID:(NSString*)seequID;
+ (NSString*) GetFavoritsList:(NSArray**)array;
+ (NSString*) AddMuteUserWithSeequId:(NSString*)seequID;
+ (NSString*) RemoveMuteUserWithSeequId:(NSString*)seequID;
+ (NSString*) GetMuteUsersList:(NSArray**)array;
//+(void)addOrRemovecContactInFavoriteList:(BOOL)add withSeequID:(NSString*)SeequID;
+(NSString*)BlockRequests:(BOOL)block;
#pragma mark -
#pragma mark Update Profile Information methods

+ (NSString*) UpdateProfileImage:(UIImage *)image;
+ (NSString*) UpdateBadgeStatus:(NSString*)badgeStatus;
+ (NSString*) UpdateMainFields:(NSDictionary*)dict;
+ (NSString*) updateRate:(NSString*)rate;
+ (NSString*) UpdateProfileLanguages:(NSDictionary*)dictLanguage;
+ (NSString*) UpdateInternetInfo:(NSMutableArray*)array;
+ (NSString*) UpdateContactInfo:(NSMutableArray*)array;
+ (NSString*) UpdateSocialInfo:(NSMutableArray*)array;
+ (BOOL) UpdateBadgeNumber:(int)badgeNumber;
+(void) getUserBalance:(void (^)(NSMutableDictionary * dict))success;

+ (void) TransferContactInformation:(ContactObject*)from To:(ContactObject*)to;
+ (ContactObject*) getContactObjectWithSeequID:(NSString*)seequID;
+ (void) AddContactObjectToCommonArray:(ContactObject*)object;
+ (void) RemoveContactObjectFromRequestedArray:(NSString*)seequID;
+ (BOOL) CheckObjectOnWait:(NSString*)seequID;
+ (NSData*) SendSynchronousRequestWithURL:(NSString*)url TimeOut:(int)seconds ErrorMessage:(NSString **)message;
+ (BOOL) NSStringisNullOrEmpty:(NSString*)string;

+ (BOOL) sendMessageWithImageFile:(SeequMessageObject*) info;
+ (BOOL) sendMessageWithVideoFile:(SeequMessageObject *)info;
+ (NSString *) ConvertDateToFriendlyString:(NSTimeInterval)time;
+ (NSString *) ConvertNSDateToFriendlyString:(NSDate*)date;

+ (NSString *) ConvertIntToWeekDay:(int)day;
+(UIImage*)getVideoThumbnail:(NSURL*)path;
+ (NSString*)ConvertDurationToStringForCall:(int)duration;
+(void)playIncomingMessageWithSeequID:(NSString*)SeequId andPushText:(NSString*)localPushText;

+ (NSDictionary*) createAuthzHeaders;
+ (NSString*) putImageToSeequID:(NSString*)seequID ImageData:(NSData*)imgData ImageName:(NSString*)imgName;
+ (NSString*) putVideoToSeequID:(NSString*)seequID videoData:(NSData*)videoData videoName:(NSString*)videoName;
+ (NSString*) startJob:(NSString*)seequID ImageName:(NSString*)imgName Size:(NSString*)size;
//+ (BOOL) preparJob:(NSString*)job SeequID:(NSString*)seequID  ImageName:(NSString*)imgName;
//+ (BOOL) runAndEndJob:(NSString*)job SeequID:(NSString*)seequID  ImageName:(NSString*)imgName;
+ (NSString*) getJobFileLink:(NSString*)job;
+ (NSString*) getJobError:(NSString*)job SeequID:(NSString*)seequID  ImageName:(NSString*)imgName;
+ (NSData*) getMediaDataWithURLString:(NSString*)url_string;
+ (NSString*) UpdateContactLocation:(NSDictionary*)dict;
+(NSString*) getVideoDirectLink:(NSString*) filePath;
+ (NSString*) makeFolderIfNotExist:(NSString*) contactId;
+ (NSString*) makeDTFolder;
+ (void) saveVideoToFolder:(NSData*)video contact:(NSString*) contactID message:(NSString*) messageID;
+ (UIImage*) imageFromSavedFileWithContact:(NSString*)contactID message:(NSString*) messageID;

+(int)getReceivedMessageType:(NSDictionary*)dict;


///@brief get media  from server and save it to  appropriate  folder
+(void) getMedia:(NSString *)url saveToFolder:(NSString *)folder message:(NSString*) messageID  seequID:(NSString*) seequId isVideo:(BOOL) flag;
@end
