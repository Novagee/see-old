//
//  MessageCoreDataManager.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 6/16/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "CoreDataManager.h"
#import "Common.h"
@class CDGroup,CDMessageOwner,CDMessage;
@interface MessageCoreDataManager : CoreDataManager
-(BOOL)insertMessageFromDictionary:(NSDictionary*)messageDict;
-(BOOL)addMessageForSend:(NSDictionary*) messageDict thumbnail:(UIImage*) image ;
-(BOOL) setMessageDelivered:(NSString*) messageID;
-(BOOL) insertGroupFromDictionary:(NSDictionary *)groupDict;
-(BOOL)isMessageExist:(NSString*)messageId;
-(CDMessageOwner*) getMessageOwner:(NSString*)seequId context:(NSManagedObjectContext*) moc;

-(BOOL) insertEmptyMessageOwner:(NSString*)seequId   isGroup:(BOOL) isGroup object:(id) object;
-(CDGroup*) getGroupByGroupId:(NSString*) groupID;
-(BOOL) deleteMessageOwner:(CDMessageOwner*) owner;
-(BOOL) deleteMessageWithMessageId:(NSString*) messageId;
+(MessageCoreDataManager*) sharedManager;
+(NSString*) getLastMessage:(CDMessage*)mess;
-(void) updateMessageOwnerLastMessage:(CDMessageOwner*) owner;
-(BOOL) updateMediaMessageSendState:(BOOL) isDelivered MessageID:(NSString*) messageId;
-(NSArray*) getAllValidGroups;

-(NSArray*) getAllNoDeliveredMessages;
-(BOOL)updateGroupsFromArray: (NSArray*)arr;
-(BOOL) updateMediaMessageDownloadState:(NSString*) messageId thumbnail:(UIImage*) image;


+(BOOL) isMediaMessage:(Message_Type)type;
@end
