//
//  ZNAssetsManager.m
//  Seequ
//
//  Created by Levon Nikoghosyan on 5/30/13.
//  Copyright (c) 2013 Levon Nikoghosyan. All rights reserved.
//

#import "ZNAssetsManager.h"
#import <ImageIO/ImageIO.h>
#import "Common.h"


@interface ZNAssetsManager (){
}
@property (nonatomic, retain) NSMutableArray*  groupsArray;
@property (nonatomic, retain) NSMutableArray*  assets;


@end

@implementation ZNAssetsManager

@synthesize groupsArray;
@synthesize assets;
@synthesize library = _library;


+ (ZNAssetsManager *)sharedInstance {
    static dispatch_once_t pred = 0;
    static ZNAssetsManager *manager = nil;
    dispatch_once(&pred, ^{
        manager = [[ZNAssetsManager alloc] init];
    });
    return manager;
}

-(id) init {
    self =  [super init];
    if(self) {
        ///add  members  initialization
        _library = [[ALAssetsLibrary alloc] init];
    }
    return self;
}

-(void) getAssetsForGroupIndex:(int) index  success:(void (^)(NSArray* arr) )success {
    [self.assets removeAllObjects];
    ALAssetsGroup* group = [self.groupsArray objectAtIndex:index];
    [self getAssetsForGroup:group success:^(NSArray *arr) {
        success(arr);
    }];
    
}

-(BOOL) saveImage:(UIImage*) image{
    NSData *jpeg = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
    CFDictionaryRef dictRef =   CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    NSDictionary *metadata = (__bridge NSDictionary *)dictRef;
    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
    NSMutableDictionary *EXIFDictionary = [metadataAsMutable objectForKey:(__bridge NSString *)kCGImagePropertyExifDictionary];
    if(!EXIFDictionary) {
        EXIFDictionary = [NSMutableDictionary dictionary];
    }
    [EXIFDictionary setObject:@"Seequ" forKey:(__bridge NSString*)kCGImagePropertyExifLensMake];
    [EXIFDictionary setObject:@"Seequ" forKey:(__bridge NSString*)kCGImagePropertyExifUserComment];
    [metadataAsMutable setObject:EXIFDictionary forKey:(__bridge NSString*)kCGImagePropertyExifDictionary];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    [library writeImageDataToSavedPhotosAlbum:jpeg metadata:(NSDictionary*)metadataAsMutable completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            [Common postNotificationWithName:kPhotoSavedNotification object:nil];
        }
    }];
    CFRelease(source);
    CFRelease(dictRef);
    return YES;
}

-(void) getAssetsForGroup:(ALAssetsGroup*) group  success:(void (^)(NSArray* arr) )success {
    [self.assets removeAllObjects];
    
    ALAssetsGroupEnumerationResultsBlock assetEnumerator = ^(ALAsset *result, NSUInteger assiIndex, BOOL *stop) {
        if(result != NULL) {
            if( [[result valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]){
                //             NSURL* url = [[result defaultRepresentation]url];
                [self.assets addObject: result];
                         }
            
        } else {
            success(self.assets);
        }
        
    };
    
    [group enumerateAssetsUsingBlock:assetEnumerator];
    
}

+(UIImage*) getTumbImage:(ALAsset*) asset {
    return     [UIImage imageWithCGImage:asset.thumbnail];
}

+(UIImage*) getFullStreenImage:(ALAsset*) asset {
    ALAssetRepresentation* representation = [asset defaultRepresentation];
// JSC    NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
    return [UIImage imageWithCGImage:[representation fullScreenImage] scale:1 orientation:UIImageOrientationUp];
}

+(UIImage*) getImage:(ALAsset*) asset forSize:(CGSize) size {
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    UIImageOrientation orientation = UIImageOrientationUp;
    CGSize s = [representation dimensions];
    CGFloat scaleFactorW = size.width/s.width;
    CGFloat scaleFactorH = size.height/s.height;

    CGFloat scaleFactor = (scaleFactorW < scaleFactorH)? scaleFactorW:scaleFactorH;
    NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
    if (orientationValue != nil) {
        orientation = (UIImageOrientation)[orientationValue intValue];
    }
    return [UIImage imageWithCGImage:[representation fullScreenImage] scale:1/scaleFactor orientation:orientation];
}

+(void) getFullSizeImage:(ALAsset*) asset   success:(void (^)(UIImage* image) )success{
    @autoreleasepool {
   
        ALAssetRepresentation* representation = [asset defaultRepresentation];
        UIImageOrientation orientation = UIImageOrientationUp;
        NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
        if (orientationValue != nil) {
            orientation = (UIImageOrientation)[orientationValue intValue];
        }
        CGImageRef ref = [representation fullResolutionImage];
        success( [UIImage imageWithCGImage:ref scale:1 orientation:orientation]);

    }
}



+(BOOL) checkForProcessedImage:(ALAsset*) asset {
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    NSDictionary* dic  = representation.metadata;
    NSDictionary * exifDictionary = [dic valueForKey:@"{Exif}"];
    NSString* str = [exifDictionary valueForKey:@"UserComment"];
    return [str isEqualToString:@"Imagenomic Noisware"];
}


-(void)getAllPhotoLibraries:(void (^)(NSArray* arr) )success
{
    NSMutableArray* assetGroups = [[NSMutableArray alloc] init];
    self.groupsArray = assetGroups;
    NSMutableArray * ass =[[NSMutableArray alloc] init];
    self.assets = ass;
    [assetGroups release];
    [ass release];
    
 
    
    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            [self.groupsArray addObject:group];
        
        } else {
            *stop = YES;
            success(self.groupsArray);
        }
    };
    /*
     * ALAssetsGroupLibrary        = (1 << 0),         // The Library group that includes all assets.
     * ALAssetsGroupAlbum          = (1 << 1),         // All the albums synced from iTunes or created on the device.
     * ALAssetsGroupEvent          = (1 << 2),         // All the events synced from iTunes.
     * ALAssetsGroupFaces          = (1 << 3),         // All the faces albums synced from iTunes.
     * ALAssetsGroupSavedPhotos
     */
    [_library enumerateGroupsWithTypes:ALAssetsGroupPhotoStream|ALAssetsGroupSavedPhotos|ALAssetsGroupAlbum
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
     
}


-(void) getCameraRoll:(void (^)(ALAssetsGroup *))success {
    NSMutableArray* assetGroups = [[NSMutableArray alloc] init];
    self.groupsArray = assetGroups;
    NSMutableArray * ass =[[NSMutableArray alloc] init];
    self.assets = ass;
    [assetGroups release];
    [ass release];
    
    
    
    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        //       NSLog(@"stop = %d, group = %@ ", *stop, group);
        if ([[group valueForProperty:@"ALAssetsGroupPropertyType"] intValue] == ALAssetsGroupSavedPhotos)
        {
            success(group);
        }
    };
    /*
     * ALAssetsGroupLibrary        = (1 << 0),         // The Library group that includes all assets.
     * ALAssetsGroupAlbum          = (1 << 1),         // All the albums synced from iTunes or created on the device.
     * ALAssetsGroupEvent          = (1 << 2),         // All the events synced from iTunes.
     * ALAssetsGroupFaces          = (1 << 3),         // All the faces albums synced from iTunes.
     * ALAssetsGroupSavedPhotos
     */
    [_library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                            usingBlock:assetGroupEnumerator
                          failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
}


-(void)dealloc{
    [_library release];
    [super dealloc];
}

@end
