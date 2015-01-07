//
//  ZNAssetsManager.h
//  Zangi
//
//  Created by Levon Nikoghosyan on 5/30/13.
//  Copyright (c) 2013 Levon Nikoghosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AssetsLibrary/AssetsLibrary.h>

@interface ZNAssetsManager : NSObject


@property(nonatomic,retain) ALAssetsLibrary*  library;

+ (ZNAssetsManager *)sharedInstance;

+(UIImage*) getTumbImage:(ALAsset*) asset;
+(void) getFullSizeImage:(ALAsset*) asset   success:(void (^)(UIImage* image) )success;
+(UIImage*) getImage:(ALAsset*) asset forSize:(CGSize) size ;
+(UIImage*) getFullStreenImage:(ALAsset*) asset;
+(BOOL) checkForProcessedImage:(ALAsset*) asset;

-(void) getAssetsForGroupIndex:(int) index  success:(void (^)(NSArray* arr) )success;
-(void) getAllPhotoLibraries:(void (^)(NSArray* arr) )success;
-(void) getCameraRoll:(void (^)(ALAssetsGroup* cameraRoll)) success;
-(void) getAssetsForGroup:(ALAssetsGroup*) group  success:(void (^)(NSArray* arr) )success;
-(BOOL) saveImage:(UIImage*) image;
@end
