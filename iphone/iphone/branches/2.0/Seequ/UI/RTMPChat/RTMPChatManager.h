//
//  RTMPChatManager.h
//  Protime
//
//  Created by Macbook on 9/13/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MissedEventObject.h"
#import "ChatManager.h"
#import "rtmpmanager.h"
#import "Common.h"
//#import "ChatCoreDataStorage.h"

@protocol RTMPChatManagerDelegate;

@interface RTMPChatManager : NSObject<ChatManager>{
//    id<RTMPChatManagerDelegate> __weak _delegate;
    id multicastDelegate;
    NSMutableDictionary *mDicForResendMessages;
//    NSMutableArray *mArrayRosters;
//    ChatCoreDataStorage* dataStorage;
}

@property (nonatomic, assign) id<RTMPChatManagerDelegate> delegate;

- (void) addDelegate:(id)delegate;
- (void) removeDelegate:(id)delegate;

- (void) onRTMPChatEvent:(NSNotification*)notification;

- (void) resendMessage:(NSString*)msg_ID;
- (void) stopResend;
- (void) startResend;

//- (void) SendTextMessage:(NSString*)text to:(NSString*)to  MessageID:(NSString*)messageID  AddToResendList:(BOOL)add;
- (void) sendTextMessage:(SeequMessageObject*)message  AddToResendList:(BOOL)add;
- (void) sendMessage:(NSString*) _messageContent toJID: (NSString *)_friendJID MessageID:(NSString*)messageID AddToResendList:(BOOL)add;

- (void) RemoveBuddy:(NSString*)to;

//Group chat functions
-(BOOL) createGroup: (NSString*) groupName groupId: (NSString*)groupId;
-(BOOL) destroyGroups: (NSArray*) groupIds;
-(BOOL) joinGroups: (NSArray*) groupIds;
-(BOOL) leaveGroup:(NSString*) groupId;

-(BOOL) invite: (NSString*) groupName groupId:(NSString*) groupId members:( NSArray *) membersArray;
-(BOOL) sendGroupMessage:(SeequMessageObject*) obj ;
//- (int) GetUserOnLineStatus:(NSString*)protimeID;
//- (NSString*) GetUserSubscription:(NSString*)from;

//- (NSManagedObjectContext *)managedObjectContext;

+ (NSDate *)parseDateTime:(NSString *)dateTimeStr withMandatoryTimeZone:(BOOL)mandatoryTZ;
+ (NSTimeInterval)parseTimeZoneOffset:(NSString *)tzo;

+(RTMPChatManager *) sharedRTMPManager;

@end

@protocol RTMPChatManagerDelegate <NSObject>
@optional
- (BOOL) shouldReceiveMessage:(NSString*)proID;
- (void) didMissedEvent:(MissedEventObject*)event SeequID:(NSString*)proID;
- (void) didReceiveMessage:(NSDictionary*)dict;
@end