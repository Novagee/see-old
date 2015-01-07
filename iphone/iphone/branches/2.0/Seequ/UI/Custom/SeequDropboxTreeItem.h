//
//  SeequDropboxTreeItem.h
//  ProTime
//
//  Created by Grigori Jlavyan on 8/6/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

@interface SeequDropboxTreeItem : NSObject

@property (nonatomic, strong) NSString *base, *path;
@property (nonatomic) NSInteger numberOfSubitems;
@property (nonatomic, strong) SeequDropboxTreeItem *parentSelectingItem;
@property (nonatomic, strong) NSMutableArray *ancestorSelectingItems;
@property (nonatomic) NSInteger submersionLevel;
@property (nonatomic) BOOL selected;

- (BOOL)isEqualToSelectingItem:(SeequDropboxTreeItem *)selectingItem;
- (id)initWithMetadata:(DBMetadata *)metadata andParentItem:(SeequDropboxTreeItem*)parentItem;
- (void)addChild:(DBMetadata *)metadata;
@end
