//
//  CDMessage.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 8/18/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDMessageOwner, UserInfoCoreData;

@interface CDMessage : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * dt_url;
@property (nonatomic, retain) NSNumber * isDelivered;
@property (nonatomic, retain) NSNumber * isGroup;
@property (nonatomic, retain) NSNumber * isMediaDownloaded;
@property (nonatomic, retain) NSNumber * isNative;
@property (nonatomic, retain) NSNumber * isSend;
@property (nonatomic, retain) NSString * messageID;
@property (nonatomic, retain) NSNumber * messageType;
@property (nonatomic, retain) NSString * textMessage;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) CDMessageOwner *senderContact;
@property (nonatomic, retain) UserInfoCoreData *senderFromGroup;

@end
