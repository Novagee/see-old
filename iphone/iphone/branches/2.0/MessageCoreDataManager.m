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
    NSArray *array = [moc executeFetchRequest:fetch error:&error];
    if(array == nil || array.count == 0)
    {
        NSLog(@"Whoops, object %@ not found: %@", messageId, [error localizedDescription]);
        return NO;
    }
    NSAssert(array.count <=1, @"Message ID  unique!!!");
    return YES;
}



-(BOOL) InsertMessageFromDictionary:(NSDictionary *)messageDict {
    NSString* from = [messageDict objectForKey:@"from"];
    NSString* message = [messageDict objectForKey:@"msg"];
    NSString* messageID = [messageDict objectForKey:@"msgId"];
    NSTimeInterval timeInterval = [[messageDict objectForKey:@"time"] doubleValue];
    NSManagedObjectContext* moc = [CoreDataManager managedObjectContext];
    [moc lock];

    CDMessage* messageObj = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CDMessage class]) inManagedObjectContext:moc];
    messageObj.messageID = messageID;
    messageObj.date = [NSDate dateWithTimeIntervalSince1970:timeInterval/1000];
    
    /////////
    NSString*  seequId = nil;
    NSString*  senderId = nil;
    BOOL isGroup = NO;
    messageObj.isDelivered  = [NSNumber numberWithBool:NO];

    if ([from rangeOfString:@"@"].location != NSNotFound ) {
        seequId  = [from substringWithRange: NSMakeRange(0, [from rangeOfString: @"@"].location)];
        
    } else {
        seequId = from;
        senderId = [message substringWithRange: NSMakeRange(0, [message rangeOfString: @"*#===TEXT===#"].location)];
        isGroup = YES;
    }
    CDContactObject* sender = [[ContactStorage sharedInstance] getUserInfoBySeequId:seequId];
    messageObj.senderContact = sender;

    NSArray*  array = [message componentsSeparatedByString:@"*#===TEXT===#*"];
    NSAssert(array.count == 2, @"must have  count = 2");
    NSString* text = [array objectAtIndex:1];
    messageObj.isGroup = [NSNumber numberWithBool:isGroup];
    BOOL img = NO;
    if ([text rangeOfString:@"*#IMAGE FILE#*" options:NSAnchoredSearch].location != NSNotFound) {
        NSArray *array = [text componentsSeparatedByString:@"*#IMAGE FILE#*"];
        
        if (array && array.count) {
            NSString *url = [array objectAtIndex:1];
            NSString *text_msg = [array objectAtIndex:2];
            messageObj.messageType = [NSNumber numberWithShort:Message_Type_Image];
            messageObj.url = url;
            messageObj.textMessage = text_msg;
            img = YES;
   //         localPushText=[NSString stringWithFormat:@" sent you an image"];
    //        NSLog(@"[RTMP-XMPP][RCV] <Image> - imgURL:%@, text:%@", url, text_msg);
        }
    } else if ([text rangeOfString:@"*#VIDEO FILE#*" options:NSAnchoredSearch].location != NSNotFound) {
        NSArray *array = [text componentsSeparatedByString:@"*#VIDEO FILE#*"];
        
        if (array && array.count) {
            NSString *url = [array objectAtIndex:1];
            NSString *text_msg = [array objectAtIndex:2];
            NSNumber*  n = [array objectAtIndex:3];
            switch ([n intValue] ) {
                case 3:
                    messageObj.messageType = [NSNumber numberWithShort:Message_Type_Video];
                    break;
                case 5:
                    messageObj.messageType = [NSNumber numberWithShort:Message_Type_Double_Take];
                    break;
                default:
                    break;
            }
            messageObj.url = url;
            //            NSString*  resp = obj.type == Message_Type_Video?@"NO":@"YES";
            messageObj.textMessage = text_msg;//[NSString stringWithFormat:@"%@<--*VIDEO_RESPONSE*-->%@",resp,text_msg];
//            localPushText=[NSString stringWithFormat:@" sent you a video"];
//            NSLog(@"[RTMP-XMPP][RCV] <Video> - imgURL:%@, text:%@", url, text_msg);
            
            ///@todo levon needs  to  fix
        }
    }else if ([text rangeOfString:@"*#DOUBLE_TAKE#*" options:NSAnchoredSearch].location != NSNotFound){
        message=[text stringByReplacingOccurrencesOfString:@"*#DOUBLE_TAKE#*"  withString:@"*#VIDEO FILE#*"];
        NSArray *array = [text componentsSeparatedByString:@"*#VIDEO FILE#*"];
        messageObj.messageType = [NSNumber numberWithShort:Message_Type_Video_Response];
        if (array && array.count) {
            messageObj.url = [array objectAtIndex:1];
            messageObj.textMessage  = [array objectAtIndex:2];
        }
    //    localPushText=[NSString stringWithFormat:@" sent you a double take"];
    }else{
        messageObj.textMessage = [array objectAtIndex:1];
    }
    ///@todo levon  needs  to  change notification  from TBI
    //    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
    //        if (obj.message.length) {
    //            dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:seequId, @"SEEQUID", obj.message, @"message", nil];
    //            [Common postNotificationWithName:@"REQUEST" object:dictPostNotification];
    //        } else {
    //            if (obj.url.length) {
    //                dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:seequId, @"SEEQUID", @"photo message", @"message", nil];
    //                [Common postNotificationWithName:@"REQUEST" object:dictPostNotification];
    //            }
    //        }
    //    }
    BOOL ret = [self saveManagedObjectContext:moc];
    
    [moc unlock];
    return ret;

}


@end
