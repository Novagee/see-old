//
//  GalleryCellInfo.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 11/5/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import "GalleryCellInfo.h"
#import "Common.h"
#import "ASLoadImageBackgroundOperation.h"
#import "ASGalleryAssetBase.h"
#import "ASLoadImageQueue.h"

#import "GalleryViewController.h"

@implementation GalleryCellInfo
@synthesize actualImage = _actualImage;
@synthesize item = _item;
@synthesize loadingIndicator = _loadingIndicator;

-(id) init {
    self = [super init ];
    if (self) {
        self.actualImage = nil;
    }
    
    return  self;
}


- (void) DrowImageWithData:(NSData*)data {
    UIImage *image = [UIImage imageWithData:data];
    
    self.actualImage = image;
    if ([GalleryViewController isPreviewAvailable]) {
        [_imageView setImage:image];

    }
  //  [self.delegate imageLoaded:image item:_item];
    
}


- (void) getImage:(MessageItem*) messageItem{
    @autoreleasepool {
        
        NSString *_url = [_item.url stringByReplacingOccurrencesOfString:@"_t.png" withString:@".png"];
        NSData *data = [Common getMediaDataWithURLString:_url];
        
        if (data) {
            [self performSelectorOnMainThread:@selector(DrowImageWithData:) withObject:data waitUntilDone:YES];
        }
        
    }
}

-(void) LoadImage {
    [NSThread detachNewThreadSelector:@selector(getImage:) toTarget:self withObject:_item];

}

-(BOOL)isImageForTypeAvailable:(ASGalleryImageType)imageType {
    return  YES;
}
-(BOOL)isVideo {
    return  NO;
}
-(NSOperation*)loadImage:(id<ASGalleryImageView>)galleryImageView withImageType:(ASGalleryImageType)imageType {
    self.imageView = galleryImageView;
    UIImage* image = self.actualImage;
    if (image){
        [galleryImageView setImage:image];
        return nil;
    }
    [self LoadImage];
//    ASLoadImageBackgroundOperation* loadImageOperation = [[ASLoadImageBackgroundOperation alloc] init];
//    loadImageOperation.queuePriority = NSOperationQueuePriorityVeryLow;
//    __unsafe_unretained ASGalleryAssetBase* SELF = self;
//    loadImageOperation.imageFetchBlock = ^UIImage*(void){
//        
//        return [self fetchImage:_item];
//    };
//    
//    loadImageOperation.imageSetBlock = ^(UIImage* image){
//        self.actualImage = image;
//        [galleryImageView setImage:image];
//    };
//    
//    [[ASLoadImageQueue sharedInstance] addOperation:loadImageOperation];
//    return loadImageOperation;
    
    
    return nil;
  
}

-(void) loadImage:(id<ASGalleryImageView>)galleryImageView {
    self.imageView = galleryImageView;
    UIImage* image = self.actualImage;
    if (image){
        [galleryImageView setImage:image];
        
    } else {
        NSString*  folder =[Common makeFolderIfNotExist:_item.contactID];
        NSString *imagePath = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_image.png",_item.messageID]];
          NSURL  *imageUrl =[NSURL URLWithString:[imagePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            UIImage* im = [UIImage imageWithContentsOfFile:imagePath];
            if (im){

                self.actualImage=im;
                self.actualPath=imageUrl;

                [galleryImageView setImage:im];
                
            }
        } else {
            [self LoadImage];
 
        }
        

    }
}

-(void) updateMessageBox:(id<ASGalleryImageView>)galleryImageView {
    [galleryImageView updateMessageBox: self.item.stringMessageText];
}
-(NSURL*)url{
    NSString * sUrl =[_item.url stringByReplacingOccurrencesOfString:@"_t.png" withString:@".png"];
    return [NSURL URLWithString:sUrl];
}

@end
