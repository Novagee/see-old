//
//  ChatManager.h
//  Protime
//
//  Created by Macbook on 9/13/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
#define CHATMESSAGE_RESEND_MESSAGE_TIMEOUT 3

@protocol ChatManager <NSObject>
@optional

- (void) addDelegate:(id)delegate;
- (void) removeDelegate:(id)delegate;
- (void) sendMessage:(NSString*) _messageContent toJID: (NSString *)_friendJID MessageID:(NSString*)messageID AddToResendList:(BOOL)add;
- (void) resendMessage:(NSString*)msg_ID;

- (void) SendTextMessage:(NSString*)text to:(NSString*)to  MessageID:(NSString*)messageID  AddToResendList:(BOOL)add;
- (void) SendLinkWithLink:(NSString*)link to:(NSString*)to;
- (void) SendUpdateRequestTo:(NSString*)to;
- (void) SendSessionConnectionRequestTo:(NSString*)to;
- (void) SendSessionDisconnectionRequestTo:(NSString*)to;

- (void) RemoveBuddy:(NSString*)to;

//Group chat functions
-(BOOL) createGroup: (NSString*) groupName groupId: (NSString*)groupId;
-(BOOL) destroyGroups: (NSArray*) groupIds;
-(BOOL) joinGroups: (NSArray*) groupIds;
-(BOOL) leaveGroup:(NSString*) groupId;
-(BOOL) invite: (NSString*) groupName groupId: (NSString*)groupId members:( NSArray *) membersArray;
-(BOOL) sendGroupMessage: (SeequMessageObject*) obj;

- (int) GetUserOnLineStatus:(NSString*)seequID;
- (NSString*) GetUserSubscription:(NSString*)seequID;
- (NSManagedObjectContext *)managedObjectContext;

- (BOOL) isConnected;

+ (NSDate *)parseDateTime:(NSString *)dateTimeStr withMandatoryTimeZone:(BOOL)mandatoryTZ;
+ (NSTimeInterval)parseTimeZoneOffset:(NSString *)tzo;

@end