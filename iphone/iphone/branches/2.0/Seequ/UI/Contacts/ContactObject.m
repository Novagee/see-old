//
//  ContactObject.m
//  ProTime
//
//  Created by Norayr on 7/5/11.
//  Copyright 2011 To-Be-Interactive. All rights reserved.
//
#import "ContactStorage.h"
#import "ContactObject.h"
#import "Common.h"

@implementation ContactObject


@synthesize delegate = _delegate;
@synthesize FirstName;
@synthesize LastName;
@synthesize SeequID;
@synthesize registrationDate;
@synthesize isOnline;
@synthesize isFavorite;
@synthesize imageExist;
@synthesize isNameSeted;
@synthesize isRecent;
@synthesize SessionsCount;
@synthesize ratingValue;
@synthesize ratingCount;
@synthesize reviewCount;
@synthesize topicCount;
@synthesize connectionCount;
@synthesize arrayAddressBookItems;
@synthesize image;
@synthesize contactType;
@synthesize requestStatus;

@synthesize ID;
@synthesize contactPerson;
@synthesize startTime;
@synthesize stopTime;
@synthesize status;
@synthesize time;
@synthesize badgeStatus;
@synthesize company;
@synthesize specialist;
@synthesize introduction;
@synthesize biography;
@synthesize content;
@synthesize arrayInternetInfo;
@synthesize arrayContactInfo;
@synthesize arraySocialInfo;
@synthesize arrayFavorites;
@synthesize arrayReviews;

@synthesize City;
@synthesize TimeZone;
@synthesize LanguagePrimary;
@synthesize LanguageSecond;
@synthesize LanguageThird;
@synthesize LanguageFourth;

- (id)initWithABRecordRef:(const ABRecordRef)record {
    self = [super init];
    
    if (self) {
        CFTypeRef name = ABRecordCopyValue(record, kABPersonFirstNameProperty);
        self.FirstName = (__bridge NSString *)name;
        if (name) {
            CFRelease(name);
        }
        CFTypeRef lastName = ABRecordCopyValue(record, kABPersonLastNameProperty);
        self.LastName = (__bridge NSString *)lastName;
        if (lastName) {
            CFRelease(lastName);

        }

        if (!self.FirstName && !self.LastName) {
            return nil;
        }
        CFTypeRef comp = ABRecordCopyValue(record, kABPersonOrganizationProperty);
        self.company = (__bridge NSString *)comp;
        if (comp) {
            CFRelease(comp);
        }
        if (!self.company) {
            self.company = @"";
        }
        
        ABMutableMultiValueRef multiValue = ABRecordCopyValue(record, kABPersonAddressProperty);
        
        CFIndex count = ABMultiValueGetCount(multiValue);
        
        if (count && multiValue) {
            CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, 0);

            if (dict) {
                self.City = (__bridge NSString *)CFDictionaryGetValue(dict, kABPersonAddressCityKey);
                self.state.stateName = (__bridge NSString *)CFDictionaryGetValue(dict, kABPersonAddressStateKey);
                self.country.countryName = (__bridge NSString *)CFDictionaryGetValue(dict, kABPersonAddressCountryKey);
                CFRelease(dict);
            }
        }
        if (multiValue) {
            CFRelease(multiValue);
        }
        arrayAddressBookItems = [[NSMutableArray alloc] init];
        
        CFStringRef phoneNumber, phoneNumberLabel;

        ABMutableMultiValueRef multi = ABRecordCopyValue(record, kABPersonPhoneProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(multi); i++) {
            phoneNumberLabel = ABMultiValueCopyLabelAtIndex(multi, i);
            
            phoneNumber      = ABMultiValueCopyValueAtIndex(multi, i);
            
            AddressBookItem *addressBookItem = [[AddressBookItem alloc] initWithType:Item_Type_Phone_Number
                                                          LabelType:(__bridge NSString *)phoneNumberLabel
                                                              Value:(__bridge NSString*)phoneNumber];
            if (phoneNumber) {
                CFRelease(phoneNumber);
            }
            if (phoneNumberLabel) {
                CFRelease(phoneNumberLabel);
            }
            [self.arrayAddressBookItems addObject:addressBookItem];
        }
        
        CFRelease(multi);
        
        ABMultiValueRef emailMultiValue = ABRecordCopyValue(record, kABPersonEmailProperty);
        CFArrayRef ar = ABMultiValueCopyArrayOfAllValues(emailMultiValue);
        NSArray *emailAddresses = (__bridge NSArray *)ar;
        
        for (NSString *email in emailAddresses) {
            AddressBookItem *addressBookItem = [[AddressBookItem alloc] initWithType:Item_Type_EMail
                                                          LabelType:@"Work"
                                                              Value:email];
            
            [self.arrayAddressBookItems addObject:addressBookItem];
        }
        if (emailMultiValue) {
            CFRelease(emailMultiValue);

        }
        if (ar) {
            CFRelease(ar);
        }
        if (![self HaveValidAddressBookItem]) {
            return nil;
        }
        
		if (ABPersonHasImageData(record)) {
            CFDataRef dataRef = ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail);
            NSData *data = (__bridge NSData*)dataRef;
            
            self.image = [UIImage imageWithData:data];
            if (dataRef) {
                CFRelease(dataRef);

            }
            self.imageExist = YES;
		}

        self.isNameSeted = YES;
        self.isRecent = NO;
        self.contactType = Contact_Type_Address_Book;
    }

    return self;
}

- (id) initWithSeequID:(NSString*)seequID {
    
    self = [super init];
    
    if (self) {
        self.SeequID = seequID;
        self.FirstName = nil;
        self.LastName = nil;
        self.isOnline = online_Status_Offline;
        self.imageExist = YES;
        self.image = nil;
        self.isNameSeted = NO;
        self.isRecent = NO;
        self.contactType = Contact_Type_Seequ_Contact;
        self.requestStatus = Request_Status_NON;
        SeequState* state_ =[[SeequState alloc] init];
        self.state = state_;
        SeequCountry* country_ = [[SeequCountry alloc] init];
        self.country = country_;
    }
    
    return self;
}

- (void) StartGetingFirstLastName {
    ContactObject *object = [Common getContactObjectWithSeequID:self.SeequID];

    if (object) {
        [Common TransferContactInformation:object To:self];
        self.image = [object.image copy];
    }
}

- (void) GetingFirstLastName {
    @autoreleasepool {
        NSDictionary *dict = [Common GetUserDetailsByPTID:self.SeequID];
        if (dict) {
            [self performSelectorOnMainThread:@selector(SetUserInfoWithDictionary:) withObject:dict waitUntilDone:YES];
                [[ContactStorage sharedInstance] InsertContactFromDictionary:dict];
        }
//        
//        if (self.imageExist) {
//            [self StartGetingImage];
//        }
//        else {
//            [Common AddContactObjectToCommonArray:self];
//            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.SeequID, @"seequID", self.image, @"image", nil];
//            [Common postNotificationWithName:@"ContactObjectImage" object:dict];
//            [Common postNotificationWithName:kContactObjectUpdateNotification object:self];
        }
    
}

- (void) SetUserInfoWithDictionary:(NSDictionary*)dict {
    self.FirstName = [Common GetStringValueWithDictionary:dict Key:@"firstName"];
    self.LastName = [Common GetStringValueWithDictionary:dict Key:@"lastName"];
    self.registrationDate = [[dict objectForKey:@"regDate"] doubleValue];
    
    NSDictionary *dictLocation = [dict objectForKey:@"location"];
    [self SetLocationWithDictionary:dictLocation];
    NSDictionary *dictLanguage = [dict objectForKey:@"userLanguage"];
    [self SetLanguagesWithDictionary:dictLanguage];    
    NSDictionary *dictRating = [dict objectForKey:@"rating"];
    [self SetRatingWithDictionary:dictRating];
    
    self.reviewCount = [[dict objectForKey:@"reviewCount"] intValue];
    self.topicCount = [[dict objectForKey:@"topicCount"] intValue];
    self.connectionCount = [[dict objectForKey:@"contactCount"] intValue];
    
    self.SessionsCount = [[dict objectForKey:@"sessionsCount"] intValue];
    self.badgeStatus = [Common GetStringValueWithDictionary:dict Key:@"badgeStatus"];
    self.company = [Common GetStringValueWithDictionary:dict Key:@"company"];
    self.specialist = [Common GetStringValueWithDictionary:dict Key:@"title"];
    self.introduction = [Common GetStringValueWithDictionary:dict Key:@"introduction"];
    if ([dict objectForKey:@"isFavorite"]) {
            NSString *fivorite=[dict objectForKey:@"isFavorite"];
            self.isFavorite=[fivorite boolValue];
    }else{
            self.isFavorite=[Common CheckFavoriteWithSeequID:self.SeequID];
    }
    
    self.biography = [Common GetStringValueWithDictionary:dict Key:@"bio"];
    
    NSArray *arrayCont = [dict objectForKey:@"contactInfoList"];
    if ([arrayCont count] > 0) {
        self.arrayContactInfo = [[NSMutableArray alloc] initWithArray:arrayCont];
        for (int  i = self.arrayContactInfo.count- 1; i >=0; --i) {
            NSDictionary* tempDict = [self.arrayContactInfo objectAtIndex:i];
            NSString *name = [tempDict objectForKey:@"itemName"];
            NSString *value = [tempDict objectForKey:@"itemValue"];
            
            if (name && [name isKindOfClass:[NSString class]] && name.length &&
                value && [value isKindOfClass:[NSString class]] && value.length) {
                continue;
            } else {
                [self.arrayContactInfo removeObject:tempDict];
            }
        }
//        for (NSDictionary *dict in self.arrayContactInfo) {
//            NSString *name = [dict objectForKey:@"itemName"];
//            NSString *value = [dict objectForKey:@"itemValue"];
//            
//            if (name && [name isKindOfClass:[NSString class]] && name.length &&
//                value && [value isKindOfClass:[NSString class]] && value.length) {
//                continue;
//            } else {
//                [self.arrayContactInfo removeObject:dict];
//            }
//        }

    }
    
    NSArray *arrayInt = [dict objectForKey:@"internetInfoList"];
    self.arrayInternetInfo = [[NSMutableArray alloc] initWithArray:arrayInt];
    NSArray *arraySoc = [dict objectForKey:@"socialInfoList"];
    self.arraySocialInfo = [[NSMutableArray alloc] initWithArray:arraySoc];
    NSArray *arrayFav = [dict objectForKey:@"favoriteList"];
    self.arrayFavorites = [[NSMutableArray alloc] initWithArray:arrayFav];
    NSArray *arrayRev = [dict objectForKey:@"reviewList"];
    
    self.arrayReviews = [[NSMutableArray alloc] initWithArray:arrayRev];

    self.isNameSeted = YES;
    
    if ([_delegate respondsToSelector:@selector(didGetUserInfo:withDict:)]) {
        [_delegate didGetUserInfo:self withDict:dict];
    }
}

- (void) StartGetingImage {
    UIImage *img = [Common GetImageByPTID:self.SeequID andHeight:IMAGE_HEIGHT];
    
    if (img) {
        self.image = img;
        if ([_delegate respondsToSelector:@selector(didGetUserImage:Image:)]) {
            [_delegate didGetUserImage:self Image:self.image];
        }

//        [Common AddContactObjectToCommonArray:self];
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.SeequID, @"seequID", self.image, @"image", nil];
        [Common postNotificationWithName:@"ContactObjectImage" object:dict];
//        [Common postNotificationWithName:kContactObjectUpdateNotification object:self];
    }
}

- (BOOL) HaveValidAddressBookItem {
    for (AddressBookItem *item in self.arrayAddressBookItems) {
        if (item.labelType != Label_Type_Unknown) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) HavePhoneNumber {
    for (AddressBookItem *item in self.arrayAddressBookItems) {
        if (item.itemType == Item_Type_Phone_Number) {
            return YES;
        }
    }

    return NO;
}

- (BOOL) HaveEmailAddress {
    for (AddressBookItem *item in self.arrayAddressBookItems) {
        if (item.itemType == Item_Type_EMail) {
            return YES;
        }
    }
    
    return NO;
}

-(NSString*) checkStringForNil:(NSString*) str {
    if (!str || [str isEqualToString:@"(null)"] ||[str isEqualToString:@"<null>"]) {
        return @"";
    }
    return str;
}

-(NSString*) checkNumberforNil:(NSNumber*) num {
    NSString* str = [num stringValue];
    if (!str || [str isEqualToString:@"(null)"] ||[str isEqualToString:@"<null>"] || [str intValue] == 0) {
        return @"";
    }
    return str;

}

- (void) SetLanguagesWithDictionary:(NSDictionary*)dict {
    self.LanguagePrimary = [self checkStringForNil:[Common GetStringValueWithDictionary:dict Key:@"primary"]];
    self.LanguageSecond = [self checkStringForNil:[Common GetStringValueWithDictionary:dict Key:@"second"]];
    self.LanguageThird = [self checkStringForNil:[Common GetStringValueWithDictionary:dict Key:@"third"]];
    self.LanguageFourth = [self checkStringForNil:[Common GetStringValueWithDictionary:dict Key:@"fourth"]];
}

- (void) SetLocationWithDictionary:(NSDictionary*)dict {
    self.country.countryName = [self checkStringForNil:[Common GetStringValueWithDictionary:dict Key:@"country"]];
    self.country.CountryID = [self checkNumberforNil:[Common GetIntValueWithDictionary:dict  Key:@"countryId"]];

    self.state.stateID = [self checkNumberforNil:[Common GetIntValueWithDictionary:dict Key:@"stateId"]];
    self.state.stateAbbrev = [self checkStringForNil:[Common GetStringValueWithDictionary:dict Key:@"stateAbbrev"]];
    self.state.stateName = [self checkStringForNil:[Common GetStringValueWithDictionary:dict Key:@"state"]];

    self.City = [self checkStringForNil:[Common GetStringValueWithDictionary:dict Key:@"city"]];
    self.TimeZone = [self checkStringForNil:[Common GetStringValueWithDictionary:dict Key:@"timeZone"]];
}

- (void) SetRatingWithDictionary:(NSDictionary*)dict {
    self.ratingValue = 0;
    self.ratingCount = 0;
    
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        self.ratingValue = [[dict valueForKey:@"ratingValue"] floatValue];
        self.ratingCount = [[dict valueForKey:@"count"] intValue];
    }
}

- (void) UpdateProfileDataAsynchronously {
    [NSThread detachNewThreadSelector:@selector(UpdateProfileData) toTarget:self withObject:nil];
}

- (void) UpdateProfileData {
    @autoreleasepool {
        NSDictionary *dict = [Common GetUserDetailsByPTID:self.SeequID];
        if (dict) {
            [self performSelectorOnMainThread:@selector(SetUserInfoWithDictionary:) withObject:dict waitUntilDone:NO];

            NSDictionary *dict_post = [[NSDictionary alloc] initWithObjectsAndKeys:self.SeequID, @"seequID", dict, @"dict", nil];
            [Common postNotificationWithName:@"ContactObjectProfileDataUpdate" object:dict_post];
            [NSThread sleepForTimeInterval:3.0];
        }
    }
}

- (NSString*) displayName {
    if (ABPersonGetSortOrdering() == kABPersonSortByFirstName) {
        return [NSString stringWithFormat:@"%@ %@", self.FirstName, self.LastName];
    }
    
    return [NSString stringWithFormat:@"%@ %@", self.LastName, self.FirstName];
}

- (NSString*) CompositeName {
    if (self.FirstName && self.LastName) {

        if (ABPersonGetCompositeNameFormatForRecord(kABPersonCompositeNameFormatFirstNameFirst)) {
            return [NSString stringWithFormat:@"%@ %@", self.FirstName, self.LastName];
        }
        
        return [NSString stringWithFormat:@"%@ %@", self.LastName, self.FirstName];
    } else {
        if (self.FirstName) {
            return self.FirstName;
        } else {
            if (self.LastName) {
                return self.LastName;
            } else {
                return @"";
            }
        }
    }
}

- (void) dealloc {
//    NSLog(@"Contact Object dealloc");
    ///@todo levon  needs  to check  availability
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end