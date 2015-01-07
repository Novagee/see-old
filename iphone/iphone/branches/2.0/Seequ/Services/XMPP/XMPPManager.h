//
//  XMPPManager.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/27/11.
//  Copyright (c) 2011 Beinteractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MissedEventObject.h"
#import "XMPPRoster.h"
#import "CoreXMPP.h"
#import "ChatManager.h"


#define BROWSER_SESSION @"BROWSER_SESSION"
#define BROWSER_LINK    @"BROWSER_LINK"


@protocol XMPPManagerDelegate;

@interface XMPPManager : NSObject <NSFetchedResultsControllerDelegate, XMPPRosterStorage, ChatManager> {
//    id<XMPPManagerDelegate> __weak _delegate;
    
    id multicastDelegate;
    
    NSFetchedResultsController *fetchedResultsController;
    NSArray *sections;
    BOOL isReceiveError;
    
    NSMutableDictionary *mDicForResendMessages;
}


@property (nonatomic, assign) id<XMPPManagerDelegate> delegate;
@property (nonatomic, assign) BOOL isReceiveError;

+ (XMPPManager *) sharedXMPPManager;

- (void) addDelegate:(id)delegate;
- (void) removeDelegate:(id)delegate;
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender;
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error;


- (NSFetchedResultsController *) fetchedResultsController;
- (void) SendTextMessage:(NSString*)text to:(NSString*)to  MessageID:(NSString*)messageID  AddToResendList:(BOOL)add;
- (void) SendLinkWithLink:(NSString*)link to:(NSString*)to;
- (void) SendUpdateRequestTo:(NSString*)to;
- (void) SendSessionConnectionRequestTo:(NSString*)to;
- (void) SendSessionDisconnectionRequestTo:(NSString*)to;
- (BOOL) GetUserOnLineStatus:(NSString*)seequID;
- (BOOL) isConnected;

@end

@protocol XMPPManagerDelegate <NSObject>

@optional

- (BOOL) shouldReceiveMessage:(NSString*)proID;
- (void) didMissedEvent:(MissedEventObject*)event SeequID:(NSString*)proID;
- (void) didReceiveMessage:(NSDictionary*)dict isExistingContact:(BOOL)isExist;

@end