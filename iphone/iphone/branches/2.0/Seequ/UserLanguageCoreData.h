//
//  UserLanguageCoreData.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 6/17/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserLanguageCoreData : NSManagedObject

@property (nonatomic, retain) NSString * fourth;
@property (nonatomic, retain) NSString * primary;
@property (nonatomic, retain) NSString * secondary;
@property (nonatomic, retain) NSString * third;

@end
