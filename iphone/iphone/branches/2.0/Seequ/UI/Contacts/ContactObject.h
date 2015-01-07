//
//  ContactObject.h
//  ProTime
//
//  Created by Norayr on 7/5/11.
//  Copyright 2011 To-Be-Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressBookItem.h"
#import "SeequCountry.h"
#import "SeequState.h"


#define kContactObjectChangeNotification @"kContactObjectChangeNotification"
#define kContactObjectUpdateNotification @"kContactObjectUpdateNotification"
#define IMAGE_HEIGHT 200


@protocol ContactObjectDelegate;

typedef enum Contact_Type {
	Contact_Type_NON,
	Contact_Type_Address_Book,
	Contact_Type_Seequ_Contact,
	Contact_Type_MY_Seequ_Contact,
    Contact_Type_Recent,
    Contact_Type_Request_For_Connection,
    Contact_Type_Request_Connection,
    Contact_Type_Request_Accepted,
    Contact_Type_Request_For_Ringback,
    Contact_Type_Request_Ringback,
    Contact_Type_Request_Ringback_Accepted,
    Contact_Type_Request_For_Review,
    Contact_Type_Request_Review,
    Contact_Type_Request_Review_Accepted
}
Contact_Type;

typedef enum Request_Status {
    Request_Status_NON,
    Request_Status_For_Connection,
    Request_Status_Connection,
    Request_Status_Connection_Accepted,
    Request_Status_Connection_Declined,
    Request_Status_Recived_Connection_Accepted,
    Request_Status_Recived_Connection_Declined,
    Request_Status_For_Ringback,
    Request_Status_Ringback,
    Request_Status_Ringback_Accepted,
    Request_Status_Ringback_Declined,
    Request_Status_Recived_Ringback_Accepted,
    Request_Status_Recived_Ringback_Declined,
    Request_Status_For_Review,
    Request_Status_Review,
    Request_Status_Review_Accepted,
    Request_Status_Review_Declined,
    Request_Status_Recived_Review_Accepted,
    Request_Status_Recived_Review_Declined
    
}
Request_Status;

typedef enum online_Status {
    online_Status_Away,
    online_Status_Online,
    online_Status_Offline
}
online_Status;


@interface ContactObject : NSObject {
//    id<ContactObjectDelegate> __weak _delegate;
    NSString *FirstName;
    NSString *LastName;
    NSString *SeequID;
    online_Status isOnline;
    BOOL imageExist;
    BOOL isNameSeted;
    BOOL isRecent;
    int SessionsCount;
    float ratingValue;
    int ratingCount;
    int reviewCount;
    int topicCount;
    
    NSMutableArray *arrayAddressBookItems;
    
    UIImage *image;
    
    int ID;
    NSString *contactPerson;
    NSTimeInterval startTime;
    NSTimeInterval stopTime;
    int status;
    NSString *time;
}

- (id) initWithABRecordRef:(const ABRecordRef)record;
- (id) initWithSeequID:(NSString*)seequID;
- (void) StartGetingFirstLastName;
- (void) StartGetingImage;
- (void) GetingFirstLastName;
- (void) SetUserInfoWithDictionary:(NSDictionary*)dict;
- (BOOL) HaveValidAddressBookItem;
- (BOOL) HavePhoneNumber;
- (BOOL) HaveEmailAddress;
- (void) SetLanguagesWithDictionary:(NSDictionary*)dict;
- (void) SetLocationWithDictionary:(NSDictionary*)dict;
- (void) SetRatingWithDictionary:(NSDictionary*)dict;
- (void) UpdateProfileDataAsynchronously;
- (void) UpdateProfileData;
- (NSString*) displayName;
- (NSString*) CompositeName;
   

@property (nonatomic, assign) id<ContactObjectDelegate> delegate;
@property (nonatomic, strong) NSString *FirstName;
@property (nonatomic, strong) NSString *LastName;
@property (nonatomic, strong) NSString *SeequID;
@property (nonatomic, assign) NSTimeInterval registrationDate;
@property (nonatomic, assign) online_Status isOnline;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, assign) BOOL imageExist;
@property (nonatomic, assign) BOOL isNameSeted;
@property (nonatomic, assign) BOOL isRecent;
@property (nonatomic, assign) int SessionsCount;
@property (nonatomic, assign) float ratingValue;
@property (nonatomic, assign) int ratingCount;
@property (nonatomic, assign) int reviewCount;
@property (nonatomic, assign) int topicCount;
@property (nonatomic, assign) int connectionCount;

@property (nonatomic, strong) NSMutableArray *arrayAddressBookItems;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) Contact_Type contactType;
@property (nonatomic, assign) Request_Status requestStatus;


@property (nonatomic, assign) int ID;
@property (nonatomic, strong) NSString *contactPerson;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval stopTime;
@property (nonatomic, assign) int status;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *badgeStatus;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *specialist;
@property (nonatomic, strong) NSString *introduction;
@property (nonatomic, strong) NSString *biography;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSMutableArray *arrayInternetInfo;
@property (nonatomic, strong) NSMutableArray *arrayContactInfo;
@property (nonatomic, strong) NSMutableArray *arraySocialInfo;
@property (nonatomic, strong) NSMutableArray *arrayFavorites;
@property (nonatomic, strong) NSMutableArray *arrayReviews;

@property (nonatomic, retain) SeequState*  state;
@property (nonatomic, retain) SeequCountry* country;

//@property (nonatomic, strong) NSString *Country;
//@property (nonatomic, strong) NSString *CountryID;
//@property (nonatomic, strong) NSString *StateID;
//
//
//@property (nonatomic, strong) NSString *State;
@property (nonatomic, strong) NSString *City;
@property (nonatomic, strong) NSString *TimeZone;
@property (nonatomic, strong) NSString *LanguagePrimary;
@property (nonatomic, strong) NSString *LanguageSecond;
@property (nonatomic, strong) NSString *LanguageThird;
@property (nonatomic, strong) NSString *LanguageFourth;


@end

@protocol ContactObjectDelegate <NSObject>

@optional

- (void) didGetUserInfo:(ContactObject*)contactsObj withDict:(NSDictionary*)dict;
- (void) didGetUserImage:(ContactObject*)contactsObj Image:(UIImage*)image;

@end