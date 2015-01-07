//
//  GalleryViewController.h
//  Photos
//
//  Created by Andrey Syvrachev on 21.05.13.
//  Copyright (c) 2013 Andrey Syvrachev. All rights reserved.
//

#import "ASGalleryViewController.h"
#import "GalleryCellInfo.h"

@protocol GalleryViewControllerDelegate <NSObject>
@optional
-(void) didDismissViewController;

@end

@interface GalleryViewController : ASGalleryViewController

@property (nonatomic,strong) NSArray* assets;
@property (nonatomic,retain) NSString* userName;
@property (nonatomic,assign) id<GalleryViewControllerDelegate> galleryDelegate;

+(BOOL) isPreviewAvailable;

@end
