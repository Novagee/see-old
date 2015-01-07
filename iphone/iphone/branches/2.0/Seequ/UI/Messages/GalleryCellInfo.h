//
//  GalleryCellInfo.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 11/5/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageItem.h"
#import "ASLib/ASGallery/ASGalleryViewController.h"


@protocol GalleryCellInfoDelegate;



@interface GalleryCellInfo : NSObject<ASGalleryAsset>
@property (nonatomic,retain) MessageItem* item;
@property (nonatomic,retain) UIImage*  actualImage;
@property (nonatomic,retain) NSURL*  actualPath;
@property(nonatomic,assign) id <GalleryCellInfoDelegate> delegate;
@property (nonatomic,retain) UIActivityIndicatorView* loadingIndicator;
@property (nonatomic,assign) id<ASGalleryImageView> imageView;

-(void) LoadImage;
- (void) getImage:(MessageItem*) messageItem;
@end

@protocol GalleryCellInfoDelegate <NSObject>

-(void) imageLoaded:(UIImage*) image item:(MessageItem*) item;

@end