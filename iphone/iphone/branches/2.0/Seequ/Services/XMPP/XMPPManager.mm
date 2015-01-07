
//
//  XMPPManager.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/27/11.
//  Copyright (c) 2011 Beinteractive. All rights reserved.
//

#import "XMPPManager.h"
#import "UserEntity.h"
#import "XMPPvCardTempModule.h"
#import "XMPP.h"
#import "Common.h"
#import "idoubs2AppDelegate.h"

@implementation XMPPManager


#define RESEND_MESSAGE_TIMEOUT 10


@synthesize delegate = _delegate;
@synthesize isReceiveError;

static XMPPManager *sharedXMPPManager;

+ (XMPPManager *) sharedXMPPManager {
	@synchronized([XMPPManager class])
	{
		if (!sharedXMPPManager)
			sharedXMPPManager = [[XMPPManager alloc] init];
        
		return sharedXMPPManager;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized([XMPPManager class])
	{
		//NSAssert(sharedXMPPManager == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedXMPPManager = [super alloc];
		return sharedXMPPManager;
	}
	// to avoid compiler warning
	return nil;
}

- (void) dealloc {

    
    [[[[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] XMPPHandler] xmppStream] removeDelegate:self];


}
-(void) sendMessage:(NSString *)_messageContent toJID:(NSString *)_friendJID MessageID:(NSString *)messageID AddToResendList:(BOOL)add {
    ///@note symbolic definition to avoid  warning.... 
}

- (id) init {
    self = [super init];
    
    if (self) {
        multicastDelegate = [[MulticastDelegate alloc] init];

        mDicForResendMessages = [[NSMutableDictionary alloc] init];
        
//        NSMutableDictionary *mDict = [[idoubs2AppDelegate sharedInstance].sqliteService getAllNoDeliveredMessages];
//
//        for (NSString *key in mDict) {
//            TBIMessageDetailsObject *obj = [mDict objectForKey:key];
//
//            NSDictionary *resend_dict = [[NSDictionary alloc] initWithObjectsAndKeys:obj.message, @"text", obj.seequID, @"toJID", nil];
//            [mDicForResendMessages setObject:resend_dict forKey:key];
//        }
    }
    
    return self;
}

- (MulticastDelegate *)multicastDelegate
{
	return multicastDelegate;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)addDelegate:(id)delegate
{
	[multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id)delegate
{
	[multicastDelegate removeDelegate:delegate];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error {
    NSLog(@"XMPPManager didNotRegister");        
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"XMPPManager xmppStreamDidAuthenticate");
    self.isReceiveError = NO;

    [Common postNotificationWithName:kXMPPConnectionChangeNotification object:nil];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@(YES), @"Authenticate", nil];
    [Common postNotificationWithName:kXMPPAuthenticateNotification object:dict];
    
    for (NSString *message_ID in mDicForResendMessages) {
        NSDictionary *dict = [mDicForResendMessages objectForKey:message_ID];
        NSString *msgText = [dict objectForKey:@"text"];
        NSString *toJid = [dict objectForKey:@"toJID"];
        
        [self SendTextMessage:msgText to:toJid MessageID:message_ID AddToResendList:NO];
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    NSLog(@"XMPPManager didNotAuthenticate");
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@(NO), @"Authenticate", nil];
    [Common postNotificationWithName:kXMPPAuthenticateNotification object:dict];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error {
//    NSLog(@"XMPPManager didReceiveError");    
    self.isReceiveError = YES;
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender {
//    NSLog(@"XMPPManager xmppStreamDidDisconnect");    

//    [Common postNotificationWithName:kXMPPConnectionChangeNotification object:nil];
}

- (void)xmppStream:(XMPPStream *)sender didRegisterModule:(id)module {
    NSLog(@"XMPPManager didRegisterModule");    
}

- (void)xmppStream:(XMPPStream *)sender willUnregisterModule:(id)module {
    NSLog(@"XMPPManager willUnregisterModule");    
}

#pragma mark -----XMPPRoster-----

- (id <XMPPUser>)myUserForXMPPStream:(XMPPStream *)xmppStream {
    return nil;
}
- (id <XMPPResource>)myResourceForXMPPStream:(XMPPStream *)xmppStream {
    return nil;
}
- (id <XMPPUser>)userForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)xmppStream {
    return nil;
}
- (id <XMPPResource>)resourceForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)xmppStream {
    return nil;
}
- (void)beginRosterPopulationForXMPPStream:(XMPPStream *)xmppStream {
}
- (void)endRosterPopulationForXMPPStream:(XMPPStream *)xmppStream {
}
- (void)handleRosterItem:(NSXMLElement *)item xmppStream:(XMPPStream *)xmppStream {
}
- (void)handlePresence:(XMPPPresence *)presence xmppStream:(XMPPStream *)xmppStream {
}
- (void)clearAllResourcesForXMPPStream:(XMPPStream *)xmppStream {
}
- (void)clearAllUsersAndResourcesForXMPPStream:(XMPPStream *)xmppStream {
}
- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence {
}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
}

#pragma mark NSFetchedResultsController Delegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    NSIndexPath *myIP;
//    
//    for (int i = 0; i < sections.count; i++) {
//        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:i];
//        int section = [sectionInfo.name intValue];
//        
//        for (int j = 0; j < sectionInfo.numberOfObjects; j++) {
//            myIP = [NSIndexPath indexPathForRow:j inSection:i];
//            XMPPUserCoreDataStorage *user = [[self fetchedResultsController] objectAtIndexPath:myIP];
//            
//            NSArray *arr = [user.displayName componentsSeparatedByString:@"@"];
//            
//            NSString *SeequID = [arr objectAtIndex:0];
//            DiscussionProfileObject *obj = [[Common sharedCommon].DiscussionHeaderItems objectForKey:SeequID];
//            
//            switch (section) {
//                case 0:
//                case 1:
//                    obj.isOnline = YES;
//                    if ([SeequID isEqualToString:self.CurrentPTID]) {
//                        [self setOnline:YES];
//                        [self SetStarsByCount:obj.Ratingvalue];
//                    }
//                    break;
//                default:
//                    obj.isOnline = NO;
//                    if ([SeequID isEqualToString:self.CurrentPTID]) {
//                        [self setOnline:NO];
//                        [self SetStarsByCount:obj.Ratingvalue];
//                    }
//                    break;
//            }
//        }
//    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSArray *values = [[UserEntity sharedUserEntity].listOfAccounts allValues];
        if (![values  count]) {
            return nil;
        }
		AccountEntity* a = [values objectAtIndex:0];
		NSManagedObjectContext* mContext = [[[a XMPPHandler] xmppRosterStorage] managedObjectContext];
		//for (id mContext in arr) {
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorage"
												  inManagedObjectContext:mContext];
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = @[sd1, sd2];
		
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		//}		
		NSError *error = nil;
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:mContext
																		 sectionNameKeyPath:@"sectionNum"
																				  cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		if (![fetchedResultsController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
	}
	
	return fetchedResultsController;	
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
//    BOOL isOnlineVisibility = [[NSUserDefaults standardUserDefaults] boolForKey:@"online"];
//    if (isOnlineVisibility) {
//        [[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] goToState:Online];
//    } else {
//        [[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] goToState:Away];
//    }

    return YES;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSString *from = [message from].user;
    
    if (!from ) {
        return;
    }
    
    NSString *msgID;
    
	if ([message isChatMessage] && [[message elementForName:@"body"] stringValue]) {
        msgID = [message attributeStringValueForName:@"id"];
        if (!msgID) {
            return;
        }
	} else {
        NSXMLElement *received = [message elementForName:@"received"];
        
        if (received) {
            msgID = [message attributeStringValueForName:@"id"];
            
            if (msgID) {
                [mDicForResendMessages removeObjectForKey:msgID];
                NSLog(@"[mDicForResendMessages %@", msgID);
            }
        }
        
        return;
    }
    
 //   if ([[idoubs2AppDelegate sharedInstance].sqliteService checkForMessageIDExisting:msgID])
        return;
    
    
    NSString *text = [[message elementForName:@"body"] stringValue];
    
    Common *common = [Common sharedCommon];
    
    NSDictionary *dictPostNotification = nil;
    if ([text isEqualToString:@"*#===RINGBACK===#*"]) {
        dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:from, @"SEEQUID", @"RINGBACK", @"type", nil];
        [Common postNotificationWithName:@"REQUEST" object:dictPostNotification];
        return;
    }
    
    if ([text isEqualToString:@"*#===REVIEW===#*"]) {
        dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:from, @"SEEQUID", @"REVIEW", @"type", nil];
        [Common postNotificationWithName:@"REQUEST" object:dictPostNotification];
        return;
    }
    
    if ([text isEqualToString:@"*#===REFRESH===#*"]) {
        dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:from, @"SEEQUID", @"REFRESH", @"type", nil];
        [Common postNotificationWithName:@"REQUEST" object:dictPostNotification];
        return;
    }

    if ([text isEqualToString:@"*#===UPDATE===#*"]) {
        [Common postNotificationWithName:@"UPDATE" object:from];
        return;
    }
    
    if ([text isEqualToString:@"BROWSER_SESSION_CONNECTION_REQUEST"]) {
        [Common postNotificationWithName:@"BROWSER_SESSION" object:[NSNumber numberWithBool:YES]];
        return;
    }

    if ([text isEqualToString:@"BROWSER_SESSION_DISCONNECTION_REQUEST"]) {
        [Common postNotificationWithName:@"BROWSER_SESSION" object:[NSNumber numberWithBool:NO]];
        return;
    }
    
    NSRange range = [text rangeOfString:@"BROWSER_LINK: "];
    if (range.length == [@"BROWSER_LINK: " length]) {
        [Common postNotificationWithName:@"BROWSER_LINK" object:text];
        
        return;
    }
    
//    NSTimeInterval date = [[NSDate date] timeIntervalSince1970];
    
    BOOL toShow =[multicastDelegate shouldReceiveMessage:from];
    if (!toShow) {
        [Common addBadgeOnCurrentUser:from];
        
        [Common AddMissedWithSeequID:from Type:2];
        MissedEventObject *eventObj = [common.MissedEvents objectForKey:from];
        [multicastDelegate didMissedEvent:eventObj SeequID:from];
    }
    
    
//    TBIMessageDetailsObject *obj = [[TBIMessageDetailsObject alloc] initWithSeequID:from];
//    obj.from = NO;
//
//    BOOL img = NO;
//    if ([text rangeOfString:@"*#IMAGE FILE#*" options:NSAnchoredSearch].location != NSNotFound) {
//        NSArray *array = [text componentsSeparatedByString:@"*#IMAGE FILE#*"];
//        
//        if (array && array.count) {
//            NSString *url = [array objectAtIndex:1];
//            NSString *text_msg = [array objectAtIndex:2];
//            obj.type = Message_Type_Image;
//            obj.url = url;
//            obj.message = text_msg;
//            img = YES;
//        }
//    } else {
//        obj.message = text;
//    }
//
//    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
//        if (obj.message.length) {
//            dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:from, @"SEEQUID", obj.message, @"message", nil];
//            [Common postNotificationWithName:@"REQUEST" object:dictPostNotification];
//        } else {
//            if (obj.url.length) {
//                dictPostNotification = [[NSDictionary alloc] initWithObjectsAndKeys:from, @"SEEQUID", @"photo message", @"message", nil];
//                [Common postNotificationWithName:@"REQUEST" object:dictPostNotification];
//            }
//        }
//    }
//    
//    obj.date = date;
//    obj.messageID = msgID;
//    obj.delivered = NO;
//    
//    [[idoubs2AppDelegate sharedInstance].sqliteService addMessageWithMessageDetailsObject:obj];
//    
//    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
//        [[idoubs2AppDelegate sharedInstance].soundService vibrate];
//        [[idoubs2AppDelegate sharedInstance].soundService playIncomingMessage];
//    } else {
////        [[idoubs2AppDelegate sharedInstance] ShowLocalPushForMessageWithSeequID:from Image:img];
//    }
}

- (void) SendTextMessage:(NSString*)text to:(NSString*)to  MessageID:(NSString*)messageID  AddToResendList:(BOOL)add {
    if(text.length > 0) {
        NSString *_selfJid = [NSString stringWithFormat:@"%@@im.protime.tv",to];
        [[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] sendMessage:text toJID:_selfJid MessageID:messageID];
        
        NSString *name = [Common sharedCommon].SeequID;
        if ([Common sharedCommon].contactObject.FirstName && [Common sharedCommon].contactObject.LastName) {
            name = [NSString stringWithFormat:@"%@ %@", [Common sharedCommon].contactObject.FirstName, [Common sharedCommon].contactObject.LastName];
        }
        
        NSDictionary *push_dict;
        
        if ([text isEqualToString:@"*#===RINGBACK===#*"]) {
            if (![self GetUserOnLineStatus:to]) {
                push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:to, @"SeequID",
                             [NSString stringWithFormat:@"%@ sent you a ringback.", name], @"message",
                             @"Ringback", @"status", nil];
                [[idoubs2AppDelegate sharedInstance].arrayPushes addObject:push_dict];
            }
        } else {
            if ([text isEqualToString:@"*#===REVIEW===#*"]) {
                if (![self GetUserOnLineStatus:to]) {
                    push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:to, @"SeequID",
                                 [NSString stringWithFormat:@"%@ sent you a request for review.", name], @"message",
                                 @"Review", @"status", nil];
                    [[idoubs2AppDelegate sharedInstance].arrayPushes addObject:push_dict];
                }
            } else {
                if ([text rangeOfString:@"*#IMAGE FILE#*" options:NSAnchoredSearch].location != NSNotFound) {
                    if (![self GetUserOnLineStatus:to]) {
                        push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:to, @"SeequID",
                                     [NSString stringWithFormat:@"%@ sent you an image.", name], @"message",
                                     @"Message", @"status", nil];
                        [[idoubs2AppDelegate sharedInstance].arrayPushes addObject:push_dict];
                    }
                } else {
                    if (![text isEqualToString:@"*#===REFRESH===#*"] && add) {
                        if (![self GetUserOnLineStatus:to]) {
                            push_dict = [[NSDictionary alloc] initWithObjectsAndKeys:to, @"SeequID",
                                         [NSString stringWithFormat:@"%@ sent you a message.", name], @"message",
                                         @"Message", @"status", nil];
                            [[idoubs2AppDelegate sharedInstance].arrayPushes addObject:push_dict];
                        }
                    }
                }
            }
        }
        
        if (add) {
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:text, @"text",
                                  to, @"toJID",  nil];
            
            [mDicForResendMessages setObject:dict forKey:messageID];
        }
        
        [self performSelector:@selector(resendMessage:) withObject:messageID afterDelay:RESEND_MESSAGE_TIMEOUT];        
    }
}

- (void) resendMessage:(NSString*)msg_ID {
    NSDictionary *dict = [mDicForResendMessages objectForKey:msg_ID];
    
    if (dict) {
        NSString *toJID = [dict objectForKey:@"toJID"];
        
        if ([self GetUserOnLineStatus:toJID]) {
            [self SendTextMessage:[dict objectForKey:@"text"] to:toJID MessageID:msg_ID AddToResendList:NO];
        } else {
            [self performSelector:@selector(resendMessage:) withObject:msg_ID afterDelay:RESEND_MESSAGE_TIMEOUT];
        }
    }
}

- (void) SendLinkWithLink:(NSString*)link to:(NSString*)to {
    if ([self GetUserOnLineStatus:to]) {
        if(link.length > 0) {
            NSString *jid = [NSString stringWithFormat:@"%@@im.protime.tv",to];
            NSString *text = [NSString stringWithFormat:@"BROWSER_LINK: %@", link];
            [[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] sendMessage:text toJID:jid MessageID:MESSAGE_ID];
        }
    }
}

- (void) SendUpdateRequestTo:(NSString*)to {
    if ([self GetUserOnLineStatus:to]) {
        NSString *jid = [NSString stringWithFormat:@"%@@im.protime.tv",to];
        NSString *text = @"*#===UPDATE===#*";
        [[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] sendMessage:text toJID:jid MessageID:MESSAGE_ID];
    }
}

- (void) SendSessionConnectionRequestTo:(NSString*)to {
    NSString *jid = [NSString stringWithFormat:@"%@@im.protime.tv",to];
    NSString *text = @"BROWSER_SESSION_CONNECTION_REQUEST";
    [[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] sendMessage:text toJID:jid MessageID:MESSAGE_ID];
}

- (void) SendSessionDisconnectionRequestTo:(NSString*)to {
    NSString *jid = [NSString stringWithFormat:@"%@@im.protime.tv",to];
    NSString *text = @"BROWSER_SESSION_DISCONNECTION_REQUEST";
    [[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] sendMessage:text toJID:jid MessageID:MESSAGE_ID];
}

- (BOOL) GetUserOnLineStatus:(NSString*)seequID {
    NSArray *array = [[self fetchedResultsController] fetchedObjects];
    
    for (XMPPUserCoreDataStorage *user in array) {
        if ([user.jid.user isEqualToString:seequID]) {
            return [user isOnline];
        }
    }
    
    return NO;
}

- (BOOL) isConnected {
    AccountEntity *accountEntity = [[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"];
    if (accountEntity.accountState == Online && [[[[[UserEntity sharedUserEntity].listOfAccounts objectForKey:@"protime"] XMPPHandler] xmppStream] isConnected]) {
        return YES;
    }

    return NO;
}

@end