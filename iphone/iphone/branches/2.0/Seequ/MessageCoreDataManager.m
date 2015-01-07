 //
//  MessageCoreDataManager.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 6/16/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "MessageCoreDataManager.h"
#import "CDMessage.h"
#import "ContactStorage.h"
#import "Common.h"
#import "CDMessageOwner.h"
#import "CDGroup.h"
#import "UserInfoCoreData.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"

@implementation MessageCoreDataManager


static MessageCoreDataManager* _sharedManager = nil;

+(MessageCoreDataManager*) sharedManager {
    if (!_sharedManager) {
        _sharedManager = [[MessageCoreDataManager alloc] init];
    }
    return _sharedManager;
}

-(BOOL) isMessageExist:(NSString *)messageId{
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName: NSStringFromClass([CDMessage class]) inManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageID == %@", messageId];
    
    [fetch setEntity: entity];
    [fetch setPredicate: predicate];
    
    NSError *error = nil;
    [moc lock];
    NSArray *array = [moc executeFetchRequest:fetch error:&error];
    [moc unlock];

    if(array == nil || array.count == 0)
    {
        NSLog(@"Whoops, object %@ not found: %@", messageId, [error localizedDescription]);
        return NO;
    }
    NSAssert(array.count <=1, @"Message ID  unique!!!");
    return YES;
}


-(CDMessageOwner*)getMessageOwner:(NSString*)seequId context:(NSManagedObjectContext*) moc{
    CDMessageOwner* userInfo = [self fetchContactBySeequId:moc seequId:seequId];
    if(!userInfo)
        return nil;
    
    return userInfo;
}


-(NSArray*) getAllNoDeliveredMessages{
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName: NSStringFromClass([CDMessage class]) inManagedObjectContext:moc];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSend == %@", [NSNumber numberWithBool:NO]];
        
        [fetch setEntity: entity];
        [fetch setPredicate: predicate];
        [moc lock];
        NSError *error = nil;
        NSArray *array = [moc executeFetchRequest:fetch error:&error];
        [moc unlock];
        return array;

}

-(BOOL) updateMediaMessageSendState:(BOOL) isDelivered MessageID:(NSString*) messageId{
    
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];

        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName: NSStringFromClass([CDMessage class]) inManagedObjectContext:moc];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageID == %@", messageId];
        
        [fetch setEntity: entity];
        [fetch setPredicate: predicate];
        [moc lock];
        NSError *error = nil;
        NSArray *array = [moc executeFetchRequest:fetch error:&error];
        [moc unlock];

        if(array == nil || array.count == 0)
        {
            NSLog(@"3: Oops, object %@ not found: %@", messageId, [error localizedDescription]);
            return NO;
        }
        if(array.count > 1)
            NSLog(@"WARNING: duplicated record %@ !!!!!!!!!!!!!!!!!!!!!!!", messageId);
        CDMessage*  message = [array objectAtIndex:0];
        message.isSend = [NSNumber numberWithBool: isDelivered];
        [self saveManagedObjectContext:moc];

        return YES ;

}


-(BOOL) deleteMessageOwner:(CDMessageOwner *)owner {
    
    NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
    [moc lock];
    
    [moc deleteObject:owner];
    [self saveManagedObjectContext:moc];
    
    [moc unlock];
    return YES;
}

-(BOOL) deleteMessageWithMessageId:(NSString *)seequId {
    CDMessage* message = [self getMessageById:seequId];
    if (!message) {
        return NO;
    }
    NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
    [moc lock];
    [moc deleteObject:message];
    [self saveManagedObjectContext:moc];
    [moc unlock];
    return YES;
}



- (CDMessageOwner*) fetchContactBySeequId:(NSManagedObjectContext*)moc seequId:(NSString*)seequId {
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName: NSStringFromClass([CDMessageOwner class]) inManagedObjectContext:moc];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"seequId == %@", seequId];
        
        [fetch setEntity: entity];
        [fetch setPredicate: predicate];
        
        NSError *error = nil;
        [moc lock];
        NSArray *array = [moc executeFetchRequest:fetch error:&error];

        [moc unlock];

        if(array == nil || array.count == 0)
        {
            NSLog(@"4: Oops, object %@ not found: %@", seequId, [error localizedDescription]);

            return nil;
        }

        if(array.count > 1)
            NSLog(@"WARNING: duplicated record %@ !!!!!!!!!!!!!!!!!!!!!!!", seequId);
        
        return [array objectAtIndex:0];
}


-(CDGroup*) getGroupByGroupId:(NSString*) groupID {
    NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
    CDGroup* userInfo = [self fetchGroupBySeequId:moc seequId:groupID];
    return userInfo;
    ///@note  change  same  in contact strorage :)
    

}

- (CDGroup*) fetchGroupBySeequId:(NSManagedObjectContext*)moc seequId:(NSString*)seequId {
        NSLog(@"SeequId-%@",seequId);
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName: NSStringFromClass([CDGroup class]) inManagedObjectContext:moc];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupId == %@", seequId];
        
        [fetch setEntity: entity];
        [fetch setPredicate: predicate];
        
        NSError *error = nil;
        [moc lock];
        NSArray *array = [moc executeFetchRequest:fetch error:&error];
        [moc unlock];

        if(array == nil || array.count == 0)
        {
            NSLog(@"5: Oops, object %@ not found: %@", seequId, [error localizedDescription]);

            return nil;
        }

        if(array.count > 1)
            NSAssert(NO,@"Impossible  situation - group  with  given  id MUST be one");
        
        return [array objectAtIndex:0];
}


-(CDMessage*) getMessageById:(NSString*) messageId {
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName: NSStringFromClass([CDMessage class]) inManagedObjectContext:moc];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageID == %@", messageId];
        
        [fetch setEntity: entity];
        [fetch setPredicate: predicate];
        
        NSError *error = nil;
        [moc lock];
        NSArray *array = [moc executeFetchRequest:fetch error:&error];
        [moc unlock];

        NSAssert(array||array.count == 1,@"must be  1 obj");
        return [array objectAtIndex:0];
}


-(BOOL) setMessageDelivered:(NSString *)messageID {
    NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName: NSStringFromClass([CDMessage class]) inManagedObjectContext:moc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageID == %@", messageID];
    
    [fetch setEntity: entity];
    [fetch setPredicate: predicate];
    
    NSError *error = nil;
    [moc lock];
    NSArray *array = [moc executeFetchRequest:fetch error:&error];
    [moc unlock];

    if(array == nil || array.count == 0)
    {
        NSLog(@"Oops, message %@ not found: %@", messageID, [error localizedDescription]);
        return NO;
    }
    
    if(array.count > 1)
        NSAssert(NO,@"Impossible  situation - group  with  given  id MUST be one");
    CDMessage* message = [array objectAtIndex:0];
    message.isDelivered = [NSNumber numberWithBool:YES];
    ///workarround
    message.isSend = [NSNumber numberWithBool:YES];

    [self saveManagedObjectContext:moc];

    return YES;
}

+(NSString*) getLastMessage:(CDMessage*)mess {
    int type = [mess.messageType intValue];
    switch (type) {
        case Message_Type_Text:            
            return mess.textMessage;
        case Message_Type_Video:
        case Message_Type_Double_Take:
            return @"Message with  video";
        case Message_Type_Image:
            return @"Message with photo";
        default:
            return @"";
    }
 }

-(void) updateMessageOwnerLastMessage:(CDMessageOwner*) owner {
    NSDate* tempDate = [NSDate dateWithTimeIntervalSince1970:0];
    CDMessage* tempMessage = nil;
    for (CDMessage* message in owner.messages) {
        if ([message.date isEqualToDate:owner.lastDate]) {
            return;
        }
        if([[message.date laterDate:tempDate] isEqualToDate:message.date]) {
            tempDate = message.date;
            tempMessage = message;
        }
    }
    

    if (tempMessage) {
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        owner.lastDate =tempMessage.date;
        owner.lastMessage = [MessageCoreDataManager getLastMessage:tempMessage];
        [self saveManagedObjectContext:moc];


    } else {
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        owner.lastDate =nil;
        owner.lastMessage = nil;
        [self saveManagedObjectContext:moc];
        
    }

}

-(BOOL) insertEmptyMessageOwner:(NSString*)seequId   isGroup:(BOOL) isGroup object:(id) object{
    NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
    CDMessageOwner* sender = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CDMessageOwner class]) inManagedObjectContext:moc];
    sender.seequId = seequId;
    sender.isGroup = [NSNumber numberWithBool:isGroup];
    if (isGroup) {
        CDGroup* groupInfo = [self getGroupByGroupId:seequId];
        NSAssert(groupInfo, @"groupInfo must be exist");
        sender.groupInfo = groupInfo;
        sender.name = groupInfo.name;
        sender.groupInfo = (CDGroup*)object;
    } else {
        UserInfoCoreData* userInfo = [[ContactStorage sharedInstance] getUserInfoBySeequId:seequId];
        NSAssert(userInfo, @"userInfo must be exist");
        sender.userInfo = userInfo;
        sender.name = [NSString stringWithFormat:@"%@ %@",userInfo.firstName, userInfo.lastName];
        sender.userInfo = (UserInfoCoreData*)object;

    }
    [self saveManagedObjectContext:moc];
    return YES;

}



-(BOOL) insertMessageFromDictionary:(NSDictionary *)messageDict {
    NSString* from = [messageDict objectForKey:@"from"];
    NSString* from_name = [messageDict objectForKey:@"from_name"];
    NSString* message = [messageDict objectForKey:@"msg"];
    NSString* messageID = [messageDict objectForKey:@"msgId"];
    Message_Type message_type = (Message_Type)[[messageDict objectForKey:@"msg_type"] intValue];
    NSTimeInterval timeInterval = [[messageDict objectForKey:@"time"] doubleValue];
    NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
    
    CDMessage* messageObj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CDMessage class]) inManagedObjectContext:moc];
    messageObj.messageID = messageID;
    messageObj.date = [NSDate dateWithTimeIntervalSince1970:timeInterval/1000];
    messageObj.isNative = [NSNumber numberWithBool:NO];
    /////////
    NSString*  seequId = nil;
    NSString*  senderId = nil;
    BOOL isGroup = NO;
    messageObj.isDelivered  = [NSNumber numberWithBool:NO];
    messageObj.isSend = [NSNumber numberWithBool:YES];
    messageObj.isMediaDownloaded = [NSNumber numberWithBool: YES]; ///@note  for all  messages  except received  media messages

    if ([from rangeOfString:@"@"].location != NSNotFound ) {
        seequId  = [from substringWithRange: NSMakeRange(0, [from rangeOfString: @"@"].location)];
        
    } else {
        seequId = from;
        senderId = [messageDict objectForKey:@"sender"];
        UserInfoCoreData* sender = [[ContactStorage sharedInstance] getUserInfoBySeequId:senderId];
        if (!sender) {
            NSDictionary* dic = [Common GetUserDetailsByPTID:senderId];
            [[ContactStorage sharedInstance] InsertContactFromDictionary:dic];
            sender = [[ContactStorage sharedInstance] getUserInfoBySeequId:senderId];
        }
        messageObj.senderFromGroup = sender;
        isGroup = YES;
    }
    CDMessageOwner* sender = [self getMessageOwner:seequId context:moc];
    if (!sender) {
        sender = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CDMessageOwner class]) inManagedObjectContext:moc];
        sender.seequId = seequId;
        sender.isGroup = [NSNumber numberWithBool:isGroup];
        sender.name =from_name;
        if (isGroup) {
            CDGroup* groupInfo = [self getGroupByGroupId:seequId];
//            NSAssert(groupInfo, @"groupInfo must be exist");
            if(groupInfo) {
                sender.groupInfo = groupInfo;
                sender.name = from_name;
            } else {
                NSLog(@"ERROR: groupInfo must be exist");
                return NO;
            }
        } else {
            UserInfoCoreData* userInfo = [[ContactStorage sharedInstance] getUserInfoBySeequId:seequId];
//            NSAssert(userInfo, @"userInfo must be exist");
            if(userInfo) {
                sender.userInfo = userInfo;
                sender.name = from_name;
            } else {
                NSLog(@"ERROR: userInfo must be exist");
                return NO;
            }
        }
    }
      ///@todo  levon check  for nil  and add  new  cdmessageOwner
    messageObj.senderContact = sender;
    [sender addMessagesObject:messageObj];
    
    NSString *localPushText=[[NSString alloc] init];

    messageObj.isGroup = [NSNumber numberWithBool:isGroup];
    messageObj.textMessage = message;
    messageObj.messageType = [NSNumber numberWithShort:message_type];
//    BOOL img = NO;
    switch (message_type) {
        case Message_Type_Text:{
            messageObj.textMessage = message;
            localPushText=[NSString stringWithFormat:@": %@",message];
        }
            break;
        case Message_Type_Image:{
            messageObj.isMediaDownloaded = [NSNumber numberWithBool: NO];
            NSString* str = [messageDict objectForKey:@"url"];
            NSAssert(str, @"url  must be exist");
            messageObj.url = str;
            localPushText=[NSString stringWithFormat:@" sent you an image"];
            NSString* folder = [Common makeFolderIfNotExist:messageObj.senderContact.seequId];
            [Common getMedia:messageObj.url saveToFolder:folder message:messageObj.messageID seequID:messageObj.senderContact.seequId isVideo:NO];
        }
            break;
        case Message_Type_Video:
        case Message_Type_Video_Response:
        case Message_Type_Double_Take:{

            messageObj.isMediaDownloaded = [NSNumber numberWithBool: NO];
            NSString* str = [messageDict objectForKey:@"url"];
            NSAssert(str, @"url  must be exist");
            messageObj.url = str;
            localPushText=[NSString stringWithFormat:@" sent you a video"];
            if (message_type ==Message_Type_Video_Response) {
                str = [messageDict objectForKey:@"url_dt"];
                NSAssert(str, @"url_dt  must be exist");
                messageObj.dt_url = str;
            }
            ///@note  separate  simple  video  save  process from  DT and response
            if (message_type ==Message_Type_Video) {
                NSString* folder = [Common makeFolderIfNotExist:messageObj.senderContact.seequId];
                [Common getMedia:messageObj.url saveToFolder:folder message:messageObj.messageID seequID:messageObj.senderContact.seequId isVideo:YES];
            } else {
                NSString* folder = [Common makeDTFolder];
                [Common getMedia:messageObj.url saveToFolder:folder message:messageObj.messageID  seequID:messageObj.senderContact.seequId isVideo:YES];
            }
            


        }
            break;
        
            break;
        default:
            break;
    }
    if (sender.lastDate){
        if([[sender.lastDate laterDate:messageObj.date] isEqualToDate:messageObj.date]) {
            sender.lastDate = messageObj.date;
            sender.lastMessage = [MessageCoreDataManager getLastMessage:messageObj];
        }
    } else {
        sender.lastDate = messageObj.date;
        sender.lastMessage = [MessageCoreDataManager getLastMessage:messageObj];
    }

    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
        if (messageObj.textMessage.length) {
            NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:seequId, @"SEEQUID", messageObj.textMessage, @"message", nil];
            [Common postNotificationWithName:@"REQUEST" object:dic];
        } else {
            if (messageObj.url.length) {
                if ([messageObj.messageType intValue] == Message_Type_Image) {
                    NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:seequId, @"SEEQUID", @"photo message", @"message", nil];
                    [Common postNotificationWithName:@"REQUEST" object: dic];
                } else {
                    NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:seequId, @"SEEQUID", @"video message", @"message", nil];
                    [Common postNotificationWithName:@"REQUEST" object: dic];
                }
            }
        }
    }
//
//    ///@todo  here  needs  to  download all video content to  the  local file system
//    if ([messageObj.messageType integerValue] > Message_Type_Image) {
//        NSData* data = [Common getMediaDataWithURLString:messageObj.url];
//    }

    BOOL ret = [self saveManagedObjectContext:moc];
    
    if (![MessageCoreDataManager isMediaMessage:[messageObj.messageType integerValue]]) {
        [Common playIncomingMessageWithSeequID:seequId andPushText:localPushText];

    }

    return ret;

}

-(NSArray*) getAllValidGroups {
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName: NSStringFromClass([CDGroup class]) inManagedObjectContext:moc];
     //   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isSend == %@", [NSNumber numberWithBool:NO]];
        
        [fetch setEntity: entity];
    //    [fetch setPredicate: predicate];
        [moc lock];
        NSError *error = nil;
        NSArray *array = [moc executeFetchRequest:fetch error:&error];
        [moc unlock];
        NSMutableArray* arr = [[NSMutableArray alloc] init];
        for (CDGroup* gr  in array) {
            if([gr.state intValue] != 0)
                [arr addObject:gr.groupId];
        }
        return arr;

}


-(BOOL)addMessageForSend:(NSDictionary *)messageDict thumbnail:(UIImage *) image {
    NSString* to = [messageDict objectForKey:@"to"];
    NSString* message = [messageDict objectForKey:@"msg"];
    NSString* messageID = [messageDict objectForKey:@"msgId"];
    NSNumber* isDelivered = [messageDict objectForKey:@"isDelivered"];
    NSNumber* isGroup = [messageDict objectForKey:@"isGroup"];
    NSNumber* isSend = [messageDict objectForKey:@"isSend"];
    NSNumber* messageType = [messageDict objectForKey:@"msgType"];
    NSString* url = [messageDict objectForKey:@"url"];
    NSDate* date = [messageDict objectForKey:@"date"];
    NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
    NSLog(@"33333");

    [moc lock];
    
    NSLog(@"4444444444");

    CDMessage* messageObj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CDMessage class]) inManagedObjectContext:moc];

    messageObj.messageID = messageID;
    messageObj.textMessage = message;
    messageObj.isDelivered  = isDelivered ;
    messageObj.isMediaDownloaded = [NSNumber numberWithBool:YES];
    if (image) {
        messageObj.thumbnail = UIImagePNGRepresentation(image);
    }
    NSLog(@"4444444444 00000000");
    NSLog(@"to is = %@",to);
    CDMessageOwner* sender = [self getMessageOwner:to context:moc];
     NSLog(@"4444444444 1111111");
    if (!sender) {
        sender = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CDMessageOwner class]) inManagedObjectContext:moc];
        NSLog(@"4444444444 222222222");

        sender.seequId = to;
        sender.isGroup = isGroup;
        if ([isGroup boolValue]) {
            NSLog(@"4444444444 33333333");

            CDGroup* groupInfo = [self getGroupByGroupId:to];
            NSLog(@"4444444444 44444444");

            NSAssert(groupInfo, @"groupInfo must be exist");
            sender.groupInfo = groupInfo;
            sender.name = groupInfo.name;
        } else {
            UserInfoCoreData* userInfo = [[ContactStorage sharedInstance] getUserInfoBySeequId:to];
            NSAssert(userInfo, @"userInfo must be exist");
            sender.userInfo = userInfo;
            sender.name = [NSString stringWithFormat:@"%@ %@",  userInfo.firstName,userInfo.lastName];
            
        }
    }

    messageObj.senderContact = sender;
    sender.lastDate = date;
    if ([messageType intValue] == Message_Type_Text || (message && message.length > 0)) {
        sender.lastMessage = message;
    } else if([messageType intValue] == Message_Type_Image) {
        sender.lastMessage =  @"Message with  photo";

    } else {
        sender.lastMessage = @"Message with  video";
    }

    messageObj.isGroup = isGroup;
    messageObj.isSend = isSend;
    messageObj.messageType = messageType;
    messageObj.url = url;
    messageObj.date = date;
    messageObj.isNative = [NSNumber numberWithBool:YES];
    ///@todo  levon check  for nil  and add  new  cdmessageOwner
    messageObj.senderContact = sender;
    NSLog(@"55555555");

    [sender addMessagesObject:messageObj];

    BOOL ret = [self saveManagedObjectContext:moc];
    NSLog(@"6666666666666");

    [moc unlock];
    return ret;

}

-(BOOL)updateGroupsFromArray: (NSArray*)arr {
    NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];

    for (NSDictionary* dd in arr) {
        NSString* groupId = [dd objectForKey:@"roomId"];
        BOOL flag = [[dd objectForKey:@"status"] boolValue];
        CDGroup* group = [[MessageCoreDataManager sharedManager] getGroupByGroupId:groupId];
        if (group) {
            group.state =[NSNumber numberWithBool:flag];
        }
    }
    [self saveManagedObjectContext:moc];
    [Common postNotificationWithName:@"UpdateGroupState" object:arr];
    return  TRUE;
}



-(BOOL) insertGroupFromDictionary:(NSDictionary *)dict {
    
    NSString*  groupID =[dict objectForKey:@"roomId"];
    NSString*  groupName =[dict objectForKey:@"roomName"];
    NSString* groupOwner = [dict objectForKey:@"inviter"];
   // NSArray*   members = [dict objectForKey:@"participants"];
    
    NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
    CDGroup*  group = [self getGroupByGroupId:groupID];
    NSAssert(!group, @"MUST be nil");
    group = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CDGroup class]) inManagedObjectContext:moc];
    group.name = groupName;
    group.groupId = groupID;
    
    UserInfoCoreData*  userInfo = [[ContactStorage sharedInstance] getUserInfoBySeequId:groupOwner];
    NSLog(@"userInfo: %@, groupOwner: %@", userInfo, [Common sharedCommon].contactObject.SeequID);
    if (!userInfo && ![groupOwner isEqualToString:[Common sharedCommon].contactObject.SeequID]) {
//        NSAssert(userInfo, @"user info  must be exist and at least  a friend");
        NSLog(@"user info  must be exist and at least  a friend");
        ///todo@ need to  add  [Common sharedCommon].contactObject.SeequID to  core data
    }
    group.groupOwner = userInfo;
    
    BOOL ret = [self saveManagedObjectContext:moc];
    ///@todo  levon add members to  group  for edti
    
    return ret;
    
}

+(BOOL) isMediaMessage:(Message_Type)type {
    return ((type == Message_Type_Image) ||
            (type == Message_Type_Video) ||
            (type == Message_Type_Video_Response) ||
            (type == Message_Type_Double_Take) );
}

-(BOOL) updateMediaMessageDownloadState:(NSString *)messageId thumbnail:(UIImage *)image{
        NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName: NSStringFromClass([CDMessage class]) inManagedObjectContext:moc];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageID == %@", messageId];
        
        [fetch setEntity: entity];
        [fetch setPredicate: predicate];
        [moc lock];
        NSError *error = nil;
        NSArray *array = [moc executeFetchRequest:fetch error:&error];
        [moc unlock];

        if(array == nil || array.count == 0)
        {
            return NO;
        }
        if(array.count > 1)
            NSLog(@"WARNING: duplicated record %@ !!!!!!!!!!!!!!!!!!!!!!!", messageId);
        CDMessage*  message = [array objectAtIndex:0];
        message.isMediaDownloaded = [NSNumber numberWithBool: YES];
        message.thumbnail = UIImagePNGRepresentation(image);
        [self saveManagedObjectContext:moc];
   //     [Common postNotificationWithName:kNewTextMessage object:nil];
        return YES ;

}

@end
