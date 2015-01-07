//
//  MessageCoreDataManager.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 6/16/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "CoreDataManager.h"

@interface MessageCoreDataManager : CoreDataManager
-(BOOL)InsertMessageFromDictionary:(NSDictionary*)messageDict;
-(BOOL)isMessageExist:(NSString*)messageId;

+(MessageCoreDataManager*) sharedManager;
@end
