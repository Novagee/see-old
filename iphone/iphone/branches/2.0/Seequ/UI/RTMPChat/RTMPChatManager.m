 //
//  RTMPChatManager.m
//  Protime
//
//  Created by Macbook on 9/13/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//
#import "ActivityStorage.h"
#import "ContactStorage.h"
#import "RTMPChatManager.h"
#import "idoubs2AppDelegate.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#include "rtmp_chatmanager.h"
#import "Common.h"
#import "MessageItem.h"
#import "MessageCoreDataManager.h"
#import "CDMessageOwner.h"
#import "CDMessage.h"
#import "UserStatusCoreData.h"
#import "CDGroup.h"

#define USER_STATUS_BOTH            @"both"
#define USER_STATUS_SUBSCRIBE       @"subscribe"
#define USER_STATUS_REMOVE          @"remove"
#define USER_STATUS_SUBSCRIPTION    @"subscription"
#define USER_STATUS_NAME            @"name"
#define USER_STATUS_SEEQUID         @"seeQuId"
#define USER_STATUS_STATUS          @"status"

@interface RTMPChatManager () {
    BOOL isStarted;
//    NSTimer *resendTimer;
    dispatch_source_t resendTimer;
}

@end

@implementation RTMPChatManager

@synthesize delegate = _delegate;

static RTMPChatManager *sharedRTMPChatManager = nil;

+(RTMPChatManager *) sharedRTMPManager {
	@synchronized([RTMPChatManager class])
	{
		if (!sharedRTMPChatManager) {
			sharedRTMPChatManager = [[RTMPChatManager alloc] init];
            [[NSNotificationCenter defaultCenter] addObserver:sharedRTMPChatManager selector:@selector(onRTMPChatEvent:) name:@"rtmp_chat_event" object:nil];
        }
        
		return sharedRTMPChatManager;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized([RTMPChatManager class])
	{
        NSAssert(sharedRTMPChatManager == nil, @"Attempted to allocate a second instance of a singleton.");
        sharedRTMPChatManager = [super alloc];
        return sharedRTMPChatManager;
	}
    return nil;
}

-(void)startResend{
//        __weak RTMPChatManager* weakSelf = self;
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                
//               resendTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:weakSelf  selector:@selector(resendMessages) userInfo:nil repeats:YES];
//                
//                [[NSRunLoop currentRunLoop] addTimer:resendTimer forMode:NSDefaultRunLoopMode];
//                
//                [[NSRunLoop currentRunLoop] run];
//        });
//    
//    
//    
    NSLog(@"JSC- Start resending...");
    dispatch_queue_t  queue = dispatch_queue_create("seequ.timer", 0);
    resendTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(resendTimer, dispatch_walltime(NULL, 0), 60ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(resendTimer, ^{
        
        NSLog(@"resend started ************");
        [mDicForResendMessages removeAllObjects];
        NSArray* arr = [[MessageCoreDataManager sharedManager] getAllNoDeliveredMessages];
        for (CDMessage* message in arr) {
            [mDicForResendMessages setObject:message forKey:message.messageID];
        }
        
        for (NSString* message_id in mDicForResendMessages) {
            CDMessage* message = [mDicForResendMessages objectForKey:message_id];
            if ([message.messageType integerValue] == Message_Type_Image) {
                ///get already  saved  image
                NSString *imageToSaveFolder = [Common makeFolderIfNotExist:message.senderContact.seequId];
                
                NSString *imagePath = [imageToSaveFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_image.png", message.messageID]];
                UIImage* imageForSend  = [UIImage imageWithContentsOfFile:imagePath];
                SeequMessageObject* info = [[SeequMessageObject alloc] init];
                info.msgId = message.messageID;
                info.from = message.senderContact.seequId;
                info.image =imageForSend;
                info.msg = message.textMessage;
                info.url = message.url;
                info.from_name = [NSString stringWithFormat:@"%@ %@", [Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
                info.type = [message.messageType integerValue];
                
                [Common performSelectorInBackground:@selector(sendMessageWithImageFile:) withObject:info];
                
            } else if([message.messageType integerValue] == Message_Type_Video ||
                      [message.messageType integerValue] == Message_Type_Video_Response||
                      [message.messageType integerValue] == Message_Type_Double_Take) {
                NSString *imageToSaveFolder = [Common makeFolderIfNotExist:message.senderContact.seequId];
                
                NSString *videoPath = [imageToSaveFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_video.mp4", message.messageID]];
                NSData *videoForSend = [NSData dataWithContentsOfFile:videoPath];
                NSURL*url=[[NSURL alloc] initFileURLWithPath:videoPath];
                UIImage* thumbnail = [Common getVideoThumbnail:url];
                SeequMessageObject* info = [[SeequMessageObject alloc] init];
                info.msgId = message.messageID;
                info.from =message.senderContact.seequId;
                info.videoData =videoForSend;
                info.msg = message.textMessage;
                info.thumbnail = thumbnail;
                info.type  = (Message_Type)[message.messageType integerValue];
                info.url = message.url;
                info.url_dt = message.dt_url ?message.dt_url:@"";
                info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
                //            NSString*  resp = ((info.type == Message_Type_Video) ||(info.type == Message_Type_Double_Take))?@"NO":@"YES";
                //            info.textMessage = [NSString stringWithFormat:@"%@<--*VIDEO_RESPONSE*-->%@<--*VIDEO_RESPONSE*-->%@",resp,info.dt_url,info.textMessage];
                [Common performSelectorInBackground:@selector(sendMessageWithVideoFile:) withObject:info];
            } else {
                ///@todo levon  change
                NSString *_selfJid = [NSString stringWithFormat:@"%@im.protime.tv",message.senderContact.seequId];
                SeequMessageObject* info = [[SeequMessageObject alloc] init];
                info.msgId = message.messageID;
                info.from =_selfJid;
                info.msg = message.textMessage;
                info.type  = Message_Type_Text;
                info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
                [self sendMessage:info AddToResendList:NO];
            }
        }        
    });
    
    dispatch_resume(resendTimer);
}
-(void)stopResend{
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                if (resendTimer.isValid) {
//                        [resendTimer invalidate];
//                        NSLog(@"resend stopped **********");
//                }
//        });
    NSLog(@"JSC- Stop resending...");
    if(resendTimer) {
        dispatch_source_cancel(resendTimer); // TODO: JSC - Check that resendTimer is being initialized in iOS 8
    }
}

-(void) resendMessages {
    NSLog(@"resend started ************");
    [mDicForResendMessages removeAllObjects];
    NSArray* arr = [[MessageCoreDataManager sharedManager] getAllNoDeliveredMessages];
    for (CDMessage* message in arr) {
        [mDicForResendMessages setObject:message forKey:message.messageID];
    }

    for (NSString* message_id in mDicForResendMessages) {
        CDMessage* message = [mDicForResendMessages objectForKey:message_id];
        if ([message.messageType integerValue] == Message_Type_Image) {
            ///get already  saved  image
            NSString *imageToSaveFolder = [Common makeFolderIfNotExist:message.senderContact.seequId];
            
            NSString *imagePath = [imageToSaveFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_image.png", message.messageID]];
            UIImage* imageForSend  = [UIImage imageWithContentsOfFile:imagePath];
            SeequMessageObject* info = [[SeequMessageObject alloc] init];
            info.msgId = message.messageID;
            info.from = message.senderContact.seequId;
            info.image =imageForSend;
            info.msg = message.textMessage;
            info.url = message.url;
            info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
            info.type = [message.messageType integerValue];

            [Common performSelectorInBackground:@selector(sendMessageWithImageFile:) withObject:info];
       
        } else if([message.messageType integerValue] == Message_Type_Video ||
                  [message.messageType integerValue] == Message_Type_Video_Response||
                  [message.messageType integerValue] == Message_Type_Double_Take) {
            NSString *imageToSaveFolder = [Common makeFolderIfNotExist:message.senderContact.seequId];
 
            NSString *videoPath = [imageToSaveFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_video.mp4", message.messageID]];
            NSData *videoForSend = [NSData dataWithContentsOfFile:videoPath];
            NSURL*url=[[NSURL alloc] initFileURLWithPath:videoPath];
            UIImage* thumbnail = [Common getVideoThumbnail:url];
            SeequMessageObject* info = [[SeequMessageObject alloc] init];
            info.msgId = message.messageID;
            info.from =message.senderContact.seequId;
            info.videoData =videoForSend;
            info.msg = message.textMessage;
            info.thumbnail = thumbnail;
            info.type  = (Message_Type)[message.messageType integerValue];
            info.url = message.url;
            info.url_dt = message.dt_url ?message.dt_url:@"";
            info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];

            
            
            
//            NSString*  resp = ((info.type == Message_Type_Video) ||(info.type == Message_Type_Double_Take))?@"NO":@"YES";
//            info.textMessage = [NSString stringWithFormat:@"%@<--*VIDEO_RESPONSE*-->%@<--*VIDEO_RESPONSE*-->%@",resp,info.dt_url,info.textMessage];
            [Common performSelectorInBackground:@selector(sendMessageWithVideoFile:) withObject:info];

        } else {
            ///@todo levon  change
            NSString *_selfJid = [NSString stringWithFormat:@"%@@im.protime.tv",message.senderContact.seequId];
            SeequMessageObject* info = [[SeequMessageObject alloc] init];
            info.msgId = message.messageID;
            info.from =_selfJid;
            info.msg = message.textMessage;
            info.type  = Message_Type_Text;
            info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
            [self sendMessage:info AddToResendList:NO];
        }
        
            
        
    }
    
}
    

- (id) init {
    self = [super init];
    
    if (self) {
        multicastDelegate = [[MulticastDelegate alloc] init];
        mDicForResendMessages = [[NSMutableDictionary alloc] init];
        NSArray* arr = [[MessageCoreDataManager sharedManager] getAllNoDeliveredMessages];
        for (CDMessage* message in arr) {
            [mDicForResendMessages setObject:message forKey:message.messageID];
        }
}
    
    return self;
}

- (void) dealloc
{
	@synchronized([RTMPChatManager class])
	{
        sharedRTMPChatManager = nil;
    }
}

- (void) addDelegate:(id)delegate
{
	[multicastDelegate addDelegate:delegate];
}

- (void) removeDelegate:(id)delegate
{
	[multicastDelegate removeDelegate:delegate];
}

-(void) onRTMPChatEvent:(NSNotification*)notification {
    @synchronized(self){
        NSDictionary *userInfo = notification.object;
        enum RTMP_EVENT_TYPE rtmp_call_event = (enum RTMP_EVENT_TYPE)[[userInfo objectForKey:@"rtmp_call_event"] intValue];
        NSLog(@"[RTMP-XMPP][RCV] - Event:%d", rtmp_call_event);

        int chatMsgType = [[userInfo objectForKey:@"chatMsgType"] intValue];
        NSData *jData = [userInfo objectForKey: @"messageType"];

        if (![idoubs2AppDelegate sharedInstance].isRosterReceived && (rtmp_call_event != RTMP_CHAT_EVENT_TYPE_ROSTER)) {
            [[idoubs2AppDelegate sharedInstance].rtmpEvents addObject:notification];
            return;
        }
        switch (rtmp_call_event)
        {
            case RTMP_CHAT_EVENT_TYPE_TXT_MESSAGE: {
                NSDictionary *jDict = [[CJSONDeserializer deserializer] deserialize:jData error:nil];
                [self onRTMPChatEventTextMsg: jDict];
            }
                break;
                
            case RTMP_CHAT_EVENT_TYPE_TXT_MSG_DELIVERED: {
                NSDictionary *jDict = [[CJSONDeserializer deserializer] deserialize:jData error:nil];
                [self onRTMPChatEventTextMsgDelivered: jDict];
            }
                break;

            case RTMP_CHAT_EVENT_TYPE_ROSTER: {
                NSArray *jarray = [[CJSONDeserializer deserializer] deserialize:jData error:nil];
                [self onRTMPChatEventRoster: jarray];
            }
                break;
                
            case RTMP_CHAT_EVENT_TYPE_PRESENCE: {
                NSDictionary *jDict = [[CJSONDeserializer deserializer] deserialize:jData error:nil];
                [self onRTMPChatEventPresence: jDict];
            }
                break;

            case RTMP_CHAT_EVENT_RESULT_TXT_MESSAGE: {
                NSDictionary *jDict = [[CJSONDeserializer deserializer] deserialize:jData error:nil];
                [self onRTMPChatEventResultTextMsg: jDict];
            }
                break;
            case RTMP_CHAT_EVENT_INSTMSG: {
                NSDictionary *jDict = [[CJSONDeserializer deserializer] deserialize:jData error:nil];
                [self onRTMPChatEventInstMsg: chatMsgType param:jDict];
            }
                break;
            case RTMP_CHAT_EVENT_INSTMSG_RESULT: {
                NSDictionary *jDict = [[CJSONDeserializer deserializer] deserialize:jData error:nil];
                [self onRTMPChatEventInstMsgResult: chatMsgType param:jDict];
            }
                break;
            default:
                break;
        }
    }
}


-(void) onRTMPChatEventTextMsg:(NSDictionary*)dict {
    
    NSString *msgID = [dict objectForKey:@"msgId"];
    
    
    if (!msgID) {
        return;
    } else if([msgID rangeOfString:@"msgId"].location == NSNotFound) {
        msgID =[ NSString stringWithFormat:@"msgId%@",msgID];
    }
    NSString *from = [dict objectForKey:@"from"];
    NSString *text = [dict objectForKey:@"msg"];
    NSRange rr = [text rangeOfString:DOUBLE_TAKE_REJECT];
    if (rr.location != NSNotFound) {
        NSString* msg_id = [text substringFromIndex:rr.length];
        [[MessageCoreDataManager sharedManager] deleteMessageWithMessageId:msg_id];
        return;
    }
//    NSTimeInterval time = [[dict objectForKey:@"time"] doubleValue];
    NSLog(@"[RTMP-XMPP][RCV] - msgID:%@, from:%@, msg:%@", msgID, from, text);
    if (!from ) {
        return;
    }
    NSString *localPushText;

     NSString* seequId = nil;
    if ([from rangeOfString: @"@"].location !=NSNotFound) {
        seequId  = [from substringWithRange: NSMakeRange(0, [from rangeOfString: @"@"].location)];

    } else {
        seequId = from;
    }
    rtmp_manager_t* manager = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager];
    if(manager /*&& rtmp_manager_is_connected(manager)*/)
    {
        
        NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:from, @"to", msgID, @"msgId", nil];
        NSString *jStr = [[CJSONSerializer serializer] serializeDictionary:jsonDict];
        rtmp_chatmanager_send_txtMsgDeliveryNotify(manager, [jStr UTF8String], jStr.length);
    } else {
        NSAssert(NO,@"impossible situation");
        return;
    }
    Message_Type tp = (Message_Type)[[dict objectForKey:@"msg_type"] intValue];
    NSDictionary *dictPostNotification = nil;

    switch (tp) {
        case Message_Type_Ringback:{
            dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:seequId, @"SEEQUID", @"RINGBACK", @"type", nil];
            [Common postNotificationWithName:@"REQUEST" object:dictPostNotification];
            localPushText=@" sent you ringback";
            if ([[UIApplication sharedApplication] applicationState]==UIApplicationStateBackground) {
                [[idoubs2AppDelegate sharedInstance] ShowLocalPushForMessageWithSeequID:seequId withPushText:localPushText andStatus:@"Request"];
                //               [Common AddMissedWithSeequID:seequId Type:1];
            }
        }
            return;
        case Message_Type_Connection:{
            dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:seequId, @"SEEQUID", @"CONNECTION", @"type", nil];
            [Common postNotificationWithName:@"REQUEST" object:dictPostNotification];
            localPushText=@" wants to connect with you";
            if ([[UIApplication sharedApplication] applicationState]==UIApplicationStateBackground) {
                [[idoubs2AppDelegate sharedInstance] ShowLocalPushForMessageWithSeequID:seequId withPushText:localPushText andStatus:@"Request"];
                //                [Common AddMissedWithSeequID:seequId Type:2];
            }

        }
            return;
        case Message_Type_Update: {
            [Common postNotificationWithName:@"UPDATE" object:seequId];

        }
            return;
        case Message_Type_Browser_Session_Connect:{
            [Common postNotificationWithName:@"BROWSER_SESSION" object:[NSNumber numberWithBool:YES]];
        }
            return;
        case Message_Type_Browser_Session_Disconnect: {
            [Common postNotificationWithName:@"BROWSER_SESSION" object:[NSNumber numberWithBool:NO]];
        }
            return;
        case Message_Type_Browser_Link: {
             NSString *text = [dict objectForKey:@"msg"];
            [Common postNotificationWithName:@"BROWSER_LINK" object:text];
        }
            return;
        default:
            break;
    }
        
    if ([[MessageCoreDataManager sharedManager] isMessageExist:msgID]) {
        return;
    }
    
    NSLog(@"message: %@", dict);
    
    [[MessageCoreDataManager sharedManager] insertMessageFromDictionary:dict];
    Common *common = [Common sharedCommon];
 //   [Common addBadgeOnCurrentUser:[Common sharedCommon].contactObject.SeequID ];
// JSC   NSString *stringDate=[dict objectForKey:@"time"];
// JSC    NSTimeInterval date=[stringDate doubleValue];
// JSC   date = date/1000;
    BOOL toShow =[multicastDelegate shouldReceiveMessage:seequId];
    if (!toShow ) {
        [Common addBadgeOnCurrentUser:seequId];
        
        [Common AddMissedWithSeequID:seequId Type:2];
        MissedEventObject *eventObj = [common.MissedEvents objectForKey:seequId];
        [multicastDelegate didMissedEvent:eventObj SeequID:seequId];
        [Common postNotificationWithName:kNewTextMessage object:dict];
    }
    
 
}

-(void)playIncomingMessageWithSeequID:(NSString*)SeequId andPushText:(NSString*)localPushText{
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                [[idoubs2AppDelegate sharedInstance].soundService vibrate];
                [[idoubs2AppDelegate sharedInstance].soundService playIncomingMessage];
        } else {
                [[idoubs2AppDelegate sharedInstance] ShowLocalPushForMessageWithSeequID:SeequId withPushText:localPushText andStatus:@"Message"];
        }
 
}

-(void) onRTMPChatEventTextMsgDelivered:(NSDictionary*)dict {
 
    NSString *message_ID = [dict objectForKey:@"msgId"];
    if (message_ID)
    {
        NSString *from = [dict objectForKey:@"from"];
        from = [from substringWithRange: NSMakeRange(0, [from rangeOfString: @"@"].location)];
        [[MessageCoreDataManager sharedManager] setMessageDelivered:message_ID];
        [mDicForResendMessages removeObjectForKey:message_ID];
        
        ///@todo  set  to delivered
   //     [[idoubs2AppDelegate sharedInstance].sqliteService updateMessageDeliveredWithSeequID:from MessageID:message_ID Delivered:YES];

//        NSDictionary *post_dict = [[NSDictionary alloc] initWithObjectsAndKeys:message_ID, @"meessage_ID", from, @"from", nil];
//        [Common postNotificationOnMainThreadWithName:MessageDeliveredEvent object:post_dict];
        
        NSLog(@"[RTMP-XMPP][RCV] <Delivered> - msgID:%@, from:%@", message_ID, from);
    }
}

-(void) onRTMPChatEventRoster:(NSArray*)array {
    NSLog(@"[RTMP-XMPP][RCV] <Roster> - %@", array);
    if (![array isKindOfClass:[NSArray class]])
        return;
    __weak RTMPChatManager* weakSelf = self;
     __block int counter = 0;
    __block NSArray*  arr = array;
    __block int i = 0;
    dispatch_queue_t myQueue = dispatch_queue_create("Roster Queue",NULL);

    dispatch_async(myQueue, ^{
        for (; i <  arr.count; i++) {
            
            NSLog(@"the i is %d",  i);
                        __block NSDictionary* dict = [arr objectAtIndex:i];
            
                        __block NSString* subscription = [dict objectForKey: USER_STATUS_SUBSCRIPTION];
                        NSString* name = [dict objectForKey: USER_STATUS_NAME];
                        __block NSString* seeQuId = [name substringWithRange: NSMakeRange(0, [name rangeOfString: @"@"].location)];
                        
                        if([subscription isEqualToString: USER_STATUS_REMOVE]){
                                
                                NSDictionary* contactDict = [[NSDictionary alloc] initWithObjectsAndKeys:seeQuId, @"seeQuId",@"none", USER_STATUS_SUBSCRIPTION,@"NO",@"isFavorite",@"NO",@"needToDoubleTake", nil];
                                [[ContactStorage   sharedInstance] InsertContactFromDictionary:contactDict];
                                [weakSelf declineRingbacksForSeequId:seeQuId];
                        }else{
                            
                                if(![[ContactStorage sharedInstance] IsUserAvailable: seeQuId]){
                                    [Common GetUserDetailsBySeequId:seeQuId success:^(NSDictionary* dict)  {
                                        counter++;
                                        if (dict) {
                                            NSMutableDictionary *mutDict=[[NSMutableDictionary  alloc] initWithDictionary:dict];
                                        
                                            if (mutDict && mutDict.count) {
                                                [mutDict setObject:subscription forKey:@"subscription"];
                                                
                                                
                                                [mutDict setObject:[UIImage imageNamed:@"profile"] forKey:@"photo"];
                                                [[ContactStorage sharedInstance] InsertContactFromDictionary:mutDict];
                                                [[ContactStorage sharedInstance] getImageBySeequId:seeQuId success:^(UIImage *image) {
                                                    [[ContactStorage sharedInstance] SetImageBySeequId:seeQuId image:image];
                                                }];
                                            }
                                            NSLog(@"the counter ААА is %d  i = %d in array with size %d",counter, i,arr.count);
                                            if (counter == arr.count ) {
                                                [weakSelf UpdateOnlineStatuses:arr];
                                            }
                                        }
                                     
                                    }];

                                }else{
                                     NSLog(@"the counter BBB is %d  i = %d in array with size %d",counter,i,arr.count);

                                    UserInfoCoreData* info = [[ContactStorage sharedInstance] getUserInfoBySeequId:seeQuId];
                                   NSMutableDictionary *contactDict=[[NSMutableDictionary  alloc] initWithDictionary:dict];
                                    [contactDict setObject:subscription forKey:@"subscription"];
                                    [contactDict setObject:seeQuId forKey:@"seeQuId"];
                                    [[ContactStorage sharedInstance] InsertContactFromDictionary:contactDict];

                                    if (!info.userImage) {
                                        [[ContactStorage sharedInstance] getImageBySeequId:seeQuId success:^(UIImage *image) {
                                            [[ContactStorage sharedInstance] SetImageBySeequId:seeQuId image:image];

                                        }];
                                    }
                                    counter++;
                                    NSLog(@"the counter BBBBB is %d",counter);

                                    if (counter == array.count) {
                                        [weakSelf UpdateOnlineStatuses:array];
                                    }
                                }
                        }
                }
        
        });
        
}

-(void) UpdateOnlineStatuses :(NSArray*) array{
    NSLog(@"UpdateOnlineStatuses");

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLogin"]) {
        [self getFavoriteList];
        [self getMuteUsersList];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Refresh" object:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLogin"];
        
    }
    [self getContactsOnlineStatus];
    
    if (array.count>1) {
        [self updateDataStorageWithArray:array];
    }
    @synchronized(self) {
        [idoubs2AppDelegate sharedInstance].isRosterReceived = YES;
    }
    for (NSNotification* notif in [idoubs2AppDelegate sharedInstance].rtmpEvents) {
        [self onRTMPChatEvent:notif];
        [NSThread sleepForTimeInterval:1.0];

    }
    [[idoubs2AppDelegate sharedInstance].rtmpEvents removeAllObjects];
  
}

-(BOOL)haveUserInfoInArray:(UserInfoCoreData*)userInfo inArray:(NSArray*)array{
        for(NSDictionary *dict in array){
                NSString* name = [dict objectForKey: USER_STATUS_NAME];
                NSString* seeQuId = [name substringWithRange: NSMakeRange(0, [name rangeOfString: @"@"].location)];
                if ([userInfo.seeQuId isEqualToString:seeQuId] || ![userInfo.status.subscription isEqualToString:USER_STATUS_BOTH]) {
                        return YES;
                }
        }
        return NO;
}
-(void)getContactsOnlineStatus{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC),dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSDictionary *onlineUsersDict=[Common GetOnlineUsers];
                if([onlineUsersDict objectForKey:@"success"]){
                        NSArray *onlineUsersArray=[onlineUsersDict objectForKey:@"return_values"];
                        
                        [[ContactStorage sharedInstance] InsertContactsFromArray:onlineUsersArray];
                        
                }
                
        });
}
-(void)updateDataStorageWithArray:(NSArray*)array{
    __weak RTMPChatManager* weakSelf = self;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSArray *allUserArray=[[ContactStorage sharedInstance] GetAllUsersInfoList];
                for (UserInfoCoreData *userInfo in allUserArray) {
                        if(![weakSelf  haveUserInfoInArray:userInfo inArray:array]){
                                NSDictionary* contactDict = [[NSDictionary alloc] initWithObjectsAndKeys:userInfo.seeQuId, @"seeQuId",@"none", USER_STATUS_SUBSCRIPTION,@"NO",@"isFavorite",@"NO",@"needToDoubleTake", nil];
                                [[ContactStorage sharedInstance] InsertStatusFromDictionary:userInfo.seeQuId status:contactDict];
                                [weakSelf declineRingbacksForSeequId:userInfo.seeQuId];
                        }
                }
        });
        
}
-(void)getFavoriteList{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,1*NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                NSArray* favoriteUsersArray;
                NSString *error=[Common GetFavoritsList:&favoriteUsersArray];
                if (!error && [favoriteUsersArray count]) {
                        NSLog(@"favorite Users Array %@",favoriteUsersArray);
                        for(NSString *seequId in favoriteUsersArray){
                                [[ContactStorage sharedInstance] setIsUserFavorit:seequId isFavorit:YES];
                        }
                }
                
        });

}
-(void)getMuteUsersList{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,2*NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                NSArray* muteUsersArray;
                NSString *error=[Common GetMuteUsersList:&muteUsersArray];
                if (!error && [muteUsersArray count]) {
                        NSLog(@"Mute Users Array %@",muteUsersArray);
                        for(NSString *seequId in muteUsersArray){
                                
                                if (![[ContactStorage sharedInstance] IsUserAvailable:seequId]) {
                                        NSMutableDictionary *userInfo=[[NSMutableDictionary alloc] initWithDictionary:[Common GetUserDetailsByPTID:seequId]];
                                        [userInfo setValue:[NSString stringWithFormat:@"%@",[NSNumber numberWithBool:YES]] forKey:@"isMute"];
                                        [[ContactStorage sharedInstance] InsertContactFromDictionary:userInfo];
                                }else{
                                        [[ContactStorage sharedInstance] setIsUserMute:seequId isMute:YES];
                                }
                        }
                }
                
        });

}
-(void) onRTMPChatEventPresence:(NSDictionary*)dict {
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSLog(@"[RTMP-XMPP][RCV] <Presence>");
    NSLog(@"PRESENCE: %@", dict);

    NSString *from = [dict objectForKey:@"from"];
    NSArray *array = [from componentsSeparatedByString:@"/"];
    
    if (array && array.count) {
        from = [array objectAtIndex:0];
    } else {
        return;
    }
    
    NSMutableDictionary *dict_ = [[NSMutableDictionary alloc] initWithDictionary:dict];
    [dict_ setValue:from forKey:@"from"];
    [dict_ setValue:from forKey:@"name"];
     NSString* seequId = [from substringWithRange: NSMakeRange(0, [from rangeOfString: @"@"].location)];
        BOOL isUserAvailable = [[ContactStorage sharedInstance] IsUserAvailable: seequId];
    if(isUserAvailable){
        dispatch_async(dispatch_get_main_queue(), ^{
                [[ContactStorage sharedInstance] InsertStatusFromDictionary:seequId status:dict_];

        });

    }

}

-(NSString*) getMessageId:(NSString*)str {
    NSRange range = [str rangeOfString:@"_msgId" options:NSBackwardsSearch];
    
    NSAssert(range.location != NSNotFound, @"must  be  found at least 1  slash");
    NSString* subString = [str substringFromIndex:range.location + 1];
    range = [subString rangeOfString:@".mp4" options:NSBackwardsSearch];
    subString =[subString substringToIndex:range.location];
    
    return subString;
}

-(void) onRTMPChatEventResultTextMsg:(NSDictionary*)dict {
    NSString *message_ID = [dict objectForKey:@"msgId"];
    if (message_ID) {
//        [[idoubs2AppDelegate sharedInstance].sqliteService updateMediaMessageState:1 MessageID:message_ID];
//        [mDicForResendMessages removeObjectForKey:message_ID];
        ///@todo levon set to delivered
        [[MessageCoreDataManager sharedManager] updateMediaMessageSendState:YES MessageID:message_ID];
        Message_Type type = [[dict objectForKey:@"msg_type"] integerValue];
        if (type == Message_Type_Video_Response) {
            
            
            NSString* _responseMessageId = [dict objectForKey:@"msgId"];

            NSString* _sourceMessageId = [self getMessageId:[dict objectForKey:@"url_dt"]];
            [[MessageCoreDataManager sharedManager] deleteMessageWithMessageId:_responseMessageId];
            [[MessageCoreDataManager sharedManager] deleteMessageWithMessageId:_sourceMessageId];
            NSString*  folder = [Common makeDTFolder];
            NSString *responsePath  = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_video.mp4",_responseMessageId]];
            NSString *sourcePath  = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_video.mp4",_responseMessageId]];
            NSError *error;
            
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:responsePath error:&error];
            NSLog(@"the file %@ remove oparation success = %d",responsePath,success);
            success = [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:&error];
            NSLog(@"the file %@ remove oparation success = %d",sourcePath,success);

        }
    }
}

-(void) onRTMPChatEventInstMsg:(int)type param:(NSDictionary*)dict {
    NSLog(@"onRTMPChatEventInstMsg:%i param:%@", type, dict);
    switch (type)
    {
        case IM_TYPE_REMOVE:
            break;
        case IM_TYPE_LEAVE_GROUP:
            [self onRTMPChatEventGroupLeave: dict];
            break;
            
        case IM_TYPE_INVITE_GROUP:
            [self onRTMPChatEventGroupInvite: dict];
            break;
            
        case IM_TYPE_MESSAGE_GROUP:
            [self onRTMPChatEventGroupMsg: dict];
            break;
            
        case IM_TYPE_DESTROY_GROUP:
            [self onRTMPChatEventGroupDestroy: dict];
            break;
        case IM_TYPE_JOIN_GROUP:
            [self onRtmpchatEventGroupJoin:dict];
            break;
            
        case IM_TYPE_MESSAGE:
            [self onRTMPChatEventTextMsg: dict];
            break;
            
        default:
            break;
    }
}

-(void) onRTMPChatEventInstMsgResult:(int)type param:(NSDictionary*)dict {
    
    switch (type)
    {
        case IM_TYPE_MESSAGE:
        case IM_TYPE_MESSAGE_GROUP:
            [self onRTMPChatEventResultTextMsg: dict];
            break;
            
        default:
            break;
    }
}

-(void) onRtmpchatEventGroupJoin:(NSDictionary*) dict {
    [[MessageCoreDataManager sharedManager] updateGroupsFromArray:(NSArray*)dict];
}

-(void) onRTMPChatEventGroupDestroy: dict {
    NSString*  groupID =[dict objectForKey:@"roomId"];
    
    
    NSMutableDictionary* d  = [[NSMutableDictionary alloc] init];
    [d setObject:groupID forKey:@"roomId"];
    [d setObject:@"" forKey:@"roomName"];
    [d setObject:[NSNumber numberWithInt:0] forKey:@"status"];
 
    [[MessageCoreDataManager sharedManager] updateGroupsFromArray:[NSArray arrayWithObject:d]];
    ///@todo  remove group
}

-(void) onRTMPChatEventGroupLeave:(NSDictionary*)dict {
  //  [Common postNotificationWithName:@"GROUP_LEAVE" object:dict];
    //TODO: Levon
}

-(void) onRTMPChatEventGroupInvite:(NSDictionary*)dict {

    if([[MessageCoreDataManager sharedManager] insertGroupFromDictionary:dict]){
        [self joinGroups:[NSArray arrayWithObject:[dict objectForKey:@"roomId"]]];
    }
}

-(void) onRTMPChatEventGroupMsg:(NSDictionary*)dict {
    
   [self onRTMPChatEventTextMsg: dict];
}

- (void) sendMessage:(NSString*) _messageContent toJID: (NSString *)_friendJID MessageID:(NSString*)messageID AddToResendList:(BOOL)add
{

    NSTimeInterval time;
    time=[[NSDate date]timeIntervalSince1970];
    
//    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *date = [NSString stringWithFormat:@"%.0f", time*1000];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:_messageContent, @"msg", date, @"time", _friendJID, @"to", messageID, @"msgId", nil];

    rtmp_manager_t* manager = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager];
    if(manager && [[idoubs2AppDelegate sharedInstance] isConnected]/*&& rtmp_manager_is_connected(manager)*/)
    {
        NSString *jsonStr = [[CJSONSerializer serializer] serializeDictionary:jsonDict];
        const char* data = [jsonStr UTF8String];
        rtmp_chatmanager_send_txtMsg(manager, data, strlen(data));
        [self performSelector:@selector(resendMessage:) withObject:messageID afterDelay:CHATMESSAGE_RESEND_MESSAGE_TIMEOUT];
    }
    
    if (add) {
        [mDicForResendMessages setObject:jsonDict forKey:messageID];
    }

    NSLog(@"[RTMP-XMPP][SEND] <text> - msgID:%@, toJID:%@, msg:%@", messageID, _friendJID, _messageContent);
}
- (void) sendMessage:(SeequMessageObject*) obj AddToResendList:(BOOL)add
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *date = [NSString stringWithFormat:@"%.0f", time*1000];
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:obj.msg, @"msg", date, @"time", obj.from, @"to", obj.msgId, @"msgId",[NSNumber numberWithInt:obj.type],@"msg_type",obj.from_name, @"from_name", nil];
    if(obj.url) {
        [jsonDict setObject:obj.url forKey:@"url"];
    }
    if(obj.url_dt) {
        [jsonDict setObject:obj.url_dt forKey:@"url_dt"];
    }
    
    rtmp_manager_t* manager = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager];
    if(manager && [[idoubs2AppDelegate sharedInstance] isConnected]/*&& rtmp_manager_is_connected(manager)*/)
    {
        NSString *jsonStr = [[CJSONSerializer serializer] serializeDictionary:jsonDict];
        const char* data = [jsonStr UTF8String];
        rtmp_chatmanager_send_instmsg(manager, IM_TYPE_MESSAGE, data, strlen(data), TRUE);
    }
    
    if (add) {
        [mDicForResendMessages setObject:jsonDict forKey:obj.msgId];
    }
    
}

-(BOOL) sendGroupMessage:(SeequMessageObject*) obj   {
    
    rtmp_manager_t* manager = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager];
    if( !manager )
        return NO;
    
    NSTimeInterval time =[[NSDate date]timeIntervalSince1970];
    
    NSString *date = [NSString stringWithFormat:@"%.0f", time*1000];
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: obj.from, @"roomId", obj.msg, @"msg", obj.msgId, @"msgId", date, @"time",[NSNumber numberWithInt:obj.type],@"msg_type",obj.from_name, @"from_name", nil];
    if(obj.url) {
        [jsonDict setObject:obj.url forKey:@"url"];
    }
    if(obj.url_dt) {
        [jsonDict setObject:obj.url_dt forKey:@"url_dt"];
    }
    if([[idoubs2AppDelegate sharedInstance] isConnected]/*&& rtmp_manager_is_connected(manager)*/)
    {
        NSString *jsonStr = [[CJSONSerializer serializer] serializeDictionary:jsonDict];
        const char* data = [jsonStr UTF8String];
        // JSC
        return rtmp_chatmanager_send_instmsg(manager, IM_TYPE_MESSAGE_GROUP, data, strlen(data), TRUE);
    }
    // JSC
    return NO;
}


-(BOOL) sendGroupMessage: (NSString*)groupId  message: (NSString*) message  messageId:(NSString*)msgId {
    
    rtmp_manager_t* manager = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager];
    if( !manager )
        return FALSE;
    if([message rangeOfString:@"*#===RINGBACK===#*"].location == NSNotFound && [message rangeOfString:@"*#===CONNECTION===#*"].location == NSNotFound) {
        CDGroup* group =[[MessageCoreDataManager sharedManager] getGroupByGroupId:groupId];
        NSString *messageText = [NSString stringWithFormat:@"%@*#===TEXT===#*%@", group.name, message];
        message = messageText;
    }
    
    NSTimeInterval time =[[NSDate date]timeIntervalSince1970];
    
    NSString *date = [NSString stringWithFormat:@"%.0f", time*1000];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys: groupId, @"roomId", message, @"msg", msgId, @"msgId", date, @"time", nil];
    
    NSString *jsonStr = [[CJSONSerializer serializer] serializeDictionary:jsonDict];
    const char* data = [jsonStr UTF8String];
    return rtmp_chatmanager_send_instmsg(manager, IM_TYPE_MESSAGE_GROUP, data, strlen(data), TRUE);
}


- (void) resendMessage:(NSString*)msg_ID
{
//    NSDictionary *dict = [mDicForResendMessages objectForKey:msg_ID];
//    
//    if (dict) {
//        NSString *toJID = [dict objectForKey:@"to"];
//        
//        int online = [self GetUserOnLineStatus:toJID];
//        
//        if (online == 1) {
//            [self sendMessage:[dict objectForKey:@"msg"]
//                        toJID:toJID
//                    MessageID:msg_ID
//              AddToResendList:NO];
//        } else {
//            [self performSelector:@selector(resendMessage:) withObject:msg_ID afterDelay:CHATMESSAGE_RESEND_MESSAGE_TIMEOUT];
//        }
//    }
}

-(void) sendTextMessage:(SeequMessageObject *)message AddToResendList:(BOOL)add {
    NSAssert(message.type != Message_Type_Text || !(!message.msg || message.msg.length == 0), @"Must be some text message if  message type  is text");
    NSString *_selfJid = [NSString stringWithFormat:@"%@@im.protime.tv",message.from];
    
    
    if([message.from rangeOfString:@"groupid"].location == NSNotFound) {
        message.from = _selfJid;
        [self sendMessage:message  AddToResendList:NO];
    } else {
        [self sendGroupMessage:message];
    }
}

- (void) RemoveBuddy:(NSString*)to
{
    rtmp_manager_t* manager = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager];
    if( !manager )
        return;

    NSString *jid = [NSString stringWithFormat:@"%@@im.protime.tv",to];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:jid, @"to", nil];
    NSString *jsonStr = [[CJSONSerializer serializer] serializeDictionary:jsonDict];
    const char* data = [jsonStr UTF8String];
       NSDictionary* contactDict = [[NSDictionary alloc] initWithObjectsAndKeys:to, @"seeQuId",@"none", USER_STATUS_SUBSCRIPTION,@"NO",@"isFavorite",@"NO",@"needToDoubleTake", nil];
    __weak RTMPChatManager* weakSelf = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[ContactStorage sharedInstance] InsertContactFromDictionary:contactDict];
            [weakSelf declineRingbacksForSeequId:to];
    });
    rtmp_chatmanager_send_instmsg(manager, IM_TYPE_REMOVE, data, strlen(data), FALSE);
}

//Group chat functions
-(BOOL) createGroup: (NSString*) groupName groupId: (NSString*)groupId {

    rtmp_manager_t* manager = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager];
    if( !manager )
        return FALSE;
    
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys: groupName, @"roomName", groupId, @"roomId", nil];
    
    NSString *jsonStr = [[CJSONSerializer serializer] serializeDictionary:jsonDict];
    const char* data = [jsonStr UTF8String];
    return rtmp_chatmanager_send_instmsg(manager, IM_TYPE_CREAT_GROUP, data, strlen(data), FALSE);
}

-(BOOL) destroyGroups: (NSArray*) groupIds {
    
    rtmp_manager_t* manager = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager];
    if( !manager )
        return FALSE;
    
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:groupIds, @"rooms", nil];
    NSString *jsonStr = [[CJSONSerializer serializer] serializeDictionary:jsonDict];
    const char* data = [jsonStr UTF8String];
    return (rtmp_chatmanager_send_instmsg(manager, IM_TYPE_DESTROY_GROUP, data, strlen(data), FALSE) > 0);
}

-(BOOL) joinGroups: (NSArray*) groupIds {

    rtmp_manager_t* manager = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager];
    if( !manager )
        return FALSE;
    
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:groupIds, @"rooms", nil];
    NSString *jsonStr = [[CJSONSerializer serializer] serializeDictionary:jsonDict];
    const char* data = [jsonStr UTF8String];
    return (rtmp_chatmanager_send_instmsg(manager, IM_TYPE_JOIN_GROUP, data, strlen(data), FALSE) > 0);
}

-(BOOL) leaveGroup:(NSString*) groupId {

    rtmp_manager_t* manager = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager];
    if( !manager )
        return FALSE;
    
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:groupId, @"roomId", nil];
    NSString *jsonStr = [[CJSONSerializer serializer] serializeDictionary:jsonDict];
    const char* data = [jsonStr UTF8String];
    return (rtmp_chatmanager_send_instmsg(manager, IM_TYPE_LEAVE_GROUP, data, strlen(data), FALSE) > 0);
}

-(BOOL) invite: (NSString*)groupName groupId: (NSString*)groupId members:( NSArray *) membersArray {
    rtmp_manager_t* manager = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager];
    if( !manager )
        return FALSE;
    NSMutableArray* temp = [[NSMutableArray alloc] init];
    for (UserInfoCoreData* info in membersArray) {
        [temp addObject:info.seeQuId];
    }
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:groupName, @"roomName", groupId, @"roomId", temp, @"participants", nil];
    NSString *jsonStr = [[CJSONSerializer serializer] serializeDictionary:jsonDict];
    const char* data = [jsonStr UTF8String];
    return (rtmp_chatmanager_send_instmsg(manager, IM_TYPE_INVITE_GROUP, data, strlen(data), FALSE) > 0);
}


//- (int) GetUserOnLineStatus:(NSString*)from
//{
//    return [dataStorage isUserOnLine:from];
//}    

//- (NSString*) GetUserSubscription:(NSString*)from
//{
//    return [dataStorage GetUserSubscription:from];
//}

//- (NSManagedObjectContext *)managedObjectContext{
//    return [dataStorage managedObjectContext];
//}

- (void) SendLinkWithLink:(NSString*)link to:(NSString*)to {
        if(link.length > 0) {
            SeequMessageObject* info = [[SeequMessageObject alloc] init];
            info.msg =link;
            info.msgId = MESSAGE_ID;
            NSString *jid = [NSString stringWithFormat:@"%@@im.protime.tv",to];
            info.from = jid;
            info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
            info.type = Message_Type_Browser_Link;
            [self sendMessage:info AddToResendList:NO];
            RSLogRTMP(@"[SEND][link] - jid:%@, msg:%@", jid, text);
        }
}

- (void) SendUpdateRequestTo:(NSString*)to {
     SeequMessageObject* info = [[SeequMessageObject alloc] init];
    info.msg =@"update";
    info.msgId = MESSAGE_ID;
    NSString *jid = [NSString stringWithFormat:@"%@@im.protime.tv",to];
    info.from = jid;
    info.type = Message_Type_Update;

    info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
    [self sendMessage:info AddToResendList:NO];

}

- (void) SendSessionConnectionRequestTo:(NSString*)to {
     SeequMessageObject* info = [[SeequMessageObject alloc] init];
    info.msg =@"Connection Request";
    info.msgId = MESSAGE_ID;
    NSString *jid = [NSString stringWithFormat:@"%@@im.protime.tv",to];
    info.from = jid;
    info.type = Message_Type_Browser_Session_Connect;
    info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
    [self sendMessage:info AddToResendList:NO];

}

- (void) SendSessionDisconnectionRequestTo:(NSString*)to {

    SeequMessageObject* info = [[SeequMessageObject alloc] init];
    info.msg =@"Connection Request";
    info.msgId = MESSAGE_ID;
    NSString *jid = [NSString stringWithFormat:@"%@@im.protime.tv",to];
    info.from = jid;
    info.type = Message_Type_Browser_Session_Disconnect;
    info.from_name = [NSString stringWithFormat:@"%@ %@",[Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
    [self sendMessage:info AddToResendList:NO];

}
- (void)declineRingbacksForSeequId:(NSString*)seequId{
NSMutableDictionary *requestsInfoDict=[[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                [NSNumber numberWithInt:Request_Status_Recived_Ringback_Declined],@"status",
                                        [NSNumber numberWithInt:Contact_Type_Request_For_Ringback],@"type",
                                        seequId,@"seeQuId",
                                        [NSNumber numberWithInt:Contact_Type_Request_Ringback],@"old_type",nil];
        [[ActivityStorage sharedInstance] updateRequestWithDictionary:requestsInfoDict];
}

- (BOOL) isConnected {
    AccountEntity *accountEntity = [[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"];
    if (accountEntity.accountState == Online && [[[[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] XMPPHandler] xmppStream] isConnected]) {
        return YES;
    }
    
    return NO;
}

+ (NSDate *)parseDateTime:(NSString *)dateTimeStr withMandatoryTimeZone:(BOOL)mandatoryTZ
{
    return 0;
}

+ (NSTimeInterval)parseTimeZoneOffset:(NSString *)tzo
{
    return 0;
}

@end
