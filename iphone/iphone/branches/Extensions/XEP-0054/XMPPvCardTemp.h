//
//  XMPPvCardTemp.h
//  XEP-0054 vCard-temp
//
//  Created by Eric Chamberlain on 3/9/11.
//  Copyright 2011 RF.com. All rights reserved.
//  Copyright 2010 Martin Morrison. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "XMPPIQ.h"
#import "XMPPJID.h"
#import "XMPPUser.h"
#import "XMPPvCardTempAdr.h"
#import "XMPPvCardTempBase.h"
#import "XMPPvCardTempEmail.h"
#import "XMPPvCardTempLabel.h"
#import "XMPPvCardTempTel.h"


typedef enum _XMPPvCardTempClass {
	XMPPvCardTempClassNone,
	XMPPvCardTempClassPublic,
	XMPPvCardTempClassPrivate,
	XMPPvCardTempClassConfidential,
} XMPPvCardTempClass;


extern NSString *const kXMPPNSvCardTemp;
extern NSString *const kXMPPvCardTempElement;


/*
 * Note: according to the DTD, every fields bar N and FN can appear multiple times.
 * The provided accessors only support this for the field types where multiple
 * entries make sense - for the others, if required, the NSXMLElement accessors
 * must be used.
 */
@interface XMPPvCardTemp : XMPPvCardTempBase


@property (nonatomic, weak) NSDate *bday;
@property (nonatomic, weak) NSData *photo;
@property (nonatomic, weak) NSString *nickname;
@property (nonatomic, weak) NSString *formattedName;
@property (nonatomic, weak) NSString *familyName;
@property (nonatomic, weak) NSString *givenName;
@property (nonatomic, weak) NSString *middleName;
@property (nonatomic, weak) NSString *prefix;
@property (nonatomic, weak) NSString *suffix;

@property (nonatomic, weak) NSArray *addresses;
@property (nonatomic, weak) NSArray *labels;
@property (nonatomic, weak) NSArray *telecomsAddresses;
@property (nonatomic, weak) NSArray *emailAddresses;

@property (nonatomic, weak) XMPPJID *jid;
@property (nonatomic, weak) NSString *mailer;

@property (nonatomic, weak) NSTimeZone *timeZone;
@property (nonatomic, weak) CLLocation *location;

@property (nonatomic, weak) NSString *title;
@property (nonatomic, weak) NSString *role;
@property (nonatomic, weak) NSData *logo;
@property (nonatomic, weak) XMPPvCardTemp *agent;
@property (nonatomic, weak) NSString *orgName;

/*
 * ORGUNITs can only be set if there is already an ORGNAME. Otherwise, changes are ignored.
 */
@property (nonatomic, weak) NSArray *orgUnits;

@property (nonatomic, weak) NSArray *categories;
@property (nonatomic, weak) NSString *note;
@property (nonatomic, weak) NSString *prodid;
@property (nonatomic, weak) NSDate *revision;
@property (nonatomic, weak) NSString *sortString;
@property (nonatomic, weak) NSString *phoneticSound;
@property (nonatomic, weak) NSData *sound;
@property (nonatomic, weak) NSString *uid;
@property (nonatomic, weak) NSString *url;
@property (nonatomic, weak) NSString *version;
@property (nonatomic, weak) NSString *description;

@property (nonatomic, assign) XMPPvCardTempClass privacyClass;
@property (nonatomic, weak) NSData *key;
@property (nonatomic, weak) NSString *keyType;


+ (XMPPvCardTemp *)vCardTempFromElement:(NSXMLElement *)element;
+ (XMPPvCardTemp *)vCardTempFromIQ:(XMPPIQ *)iq;
+ (XMPPIQ *)iqvCardRequestForJID:(XMPPJID *)jid;


- (void)addAddress:(XMPPvCardTempAdr *)adr;
- (void)removeAddress:(XMPPvCardTempAdr *)adr;
- (void)clearAddresses;


- (void)addLabel:(XMPPvCardTempLabel *)label;
- (void)removeLabel:(XMPPvCardTempLabel *)label;
- (void)clearLabels;


- (void)addTelecomsAddress:(XMPPvCardTempTel *)tel;
- (void)removeTelecomsAddress:(XMPPvCardTempTel *)tel;
- (void)clearTelecomsAddresses;


- (void)addEmailAddress:(XMPPvCardTempEmail *)email;
- (void)removeEmailAddress:(XMPPvCardTempEmail *)email;
- (void)clearEmailAddresses;


@end
