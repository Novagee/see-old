//
//  seequUIActivityItemProvider.h
//  ProTime
//
//  Created by Toros Torosyan on 3/10/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarkUIActivity.h"

@interface seequUIActivityItemProvider : UIActivityItemProvider <UIActivityItemSource>
@property(nonatomic) NSString * url;
@property(nonatomic) NSString * text;
@property(nonatomic) BookmarkUIActivity * bookmarkActivity;

@end
