//
//  SeequGroupInfo.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 5/22/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequGroupInfo.h"

@implementation SeequGroupInfo

@synthesize members = _members;
@synthesize groupID = _groupID;
@synthesize ownerID = _ownerID;
@synthesize name = _name;
-(id) initWithOwner:(NSString*) owner name:(NSString*) name_{
    self = [super init];
    if (self) {
        self.ownerID = owner;
        self.name = name_;
        _members = [[NSMutableArray alloc] initWithObjects:_ownerID, nil];
    }
    return self;
}
///@note this  must be used  only  for own  mgroups
-(id) initWithName:(NSString *)name_ {
    self = [super init];
    if (self) {
        self.name = name_;
        
        _members = [[NSMutableArray alloc] initWithObjects:_ownerID, nil];
    }
    return self;
}
@end
