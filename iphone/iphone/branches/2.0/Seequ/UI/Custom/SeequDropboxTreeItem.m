//
//  SeequDropboxTreeItem.m
//  ProTime
//
//  Created by Grigori Jlavyan on 8/6/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequDropboxTreeItem.h"

@implementation SeequDropboxTreeItem
@synthesize base, path;
@synthesize numberOfSubitems;
@synthesize parentSelectingItem;
@synthesize ancestorSelectingItems;
@synthesize submersionLevel;
@synthesize selected;

-(id)initWithMetadata:(DBMetadata *)metadata andParentItem:(SeequDropboxTreeItem *)parentItem{
        self=[super init];
        if (self) {
                [self setBase:metadata.filename];
                [self setPath:metadata.path];
                [self setParentSelectingItem:parentItem];
                self.selected=NO;
                if (parentItem) {
                        [self setSubmersionLevel:parentItem.submersionLevel+1];
                }else{
                        [self setSubmersionLevel:0];
                }

        }
        return self;
}
-(void)addChild:(DBMetadata *)metadata{
        NSMutableArray *ancestorArray=[[NSMutableArray alloc] init];
        if (metadata.contents.count>0){
                for (DBMetadata *mdata in metadata.contents){
                        if (mdata.isDirectory) {
                                SeequDropboxTreeItem *childItem=[[SeequDropboxTreeItem alloc]initWithMetadata:mdata andParentItem:self];
                                [ancestorArray addObject:childItem];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadMetadata" object:childItem.path];
                        }

                }
                [self setAncestorSelectingItems:ancestorArray];
        }
}
- (BOOL)isEqual:(id)other {
        if (other == self)
                return YES;
        if (!other || ![other isKindOfClass:[self class]])
                return NO;
        return [self isEqualToSelectingItem:other];
}

- (BOOL)isEqualToSelectingItem:(SeequDropboxTreeItem *)selectingItem {
	if (self == selectingItem)
                return YES;
	
	if ([base isEqualToString:selectingItem.base])
		if ([path isEqualToString:selectingItem.path])
			if (numberOfSubitems == selectingItem.numberOfSubitems)
				return YES;
	
	return NO;
}
@end
