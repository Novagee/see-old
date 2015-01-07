//
//  XMPPvCardCoreDataStorage.h
//  XEP-0054 vCard-temp
//
//  Created by Eric Chamberlain on 3/18/11.
//  Copyright (c) 2011 RF.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class XMPPJID;
@class XMPPvCardAvatarCoreDataStorage;
@class XMPPvCardTempCoreDataStorage;
@class XMPPvCardTemp;


@interface XMPPvCardCoreDataStorage : NSManagedObject {
@private
}


/*
 *  user's JID, indexed for lookups
 */
@property (nonatomic, strong) NSString * jidStr;


/*
 *  user's photoHash used by XEP-0153
 */
@property (nonatomic, strong, readonly) NSString * photoHash;

/*
 *  the last time the record was modified, also used to determine if we need to fetch again
 */
@property (nonatomic, strong) NSDate * lastUpdated;


/*
 *  flag indicating whether a get request is already pending, used in conjunction with lastUpdated
 */
@property (nonatomic, strong) NSNumber * waitingForFetch;


/*
 *  Relationship to the vCardTemp record.  We use a relationship, so the vCardTemp stays faulted until we really need it.
 */
@property (nonatomic, strong) XMPPvCardTempCoreDataStorage * vCardTempRel;


/*
 *  Relationship to the vCardAvatar record.  We use a relationship, so the vCardAvatar stays faulted until we really need it.
 */
@property (nonatomic, strong) XMPPvCardAvatarCoreDataStorage * vCardAvatarRel;


/*
 *  Accessor to retrieve photoData, so we can hide the underlying relationship implementation.
 */
@property (nonatomic, strong) NSData *photoData;


/*
 *  Accessor to retrieve vCardTemp, so we can hide the underlying relationship implementation.
 */
@property (nonatomic, strong) XMPPvCardTemp *vCardTemp;


+ (XMPPvCardCoreDataStorage *)fetchOrInsertvCardForJID:(XMPPJID *)jid
                                inManagedObjectContext:(NSManagedObjectContext *)moc;


@end
