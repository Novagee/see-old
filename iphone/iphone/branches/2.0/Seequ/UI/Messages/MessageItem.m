//
//  MessageItem.m
//  ProTime
//
//  Created by Karen on 10/25/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "MessageItem.h"
#import "idoubs2AppDelegate.h"
#import "Common.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CDMessageOwner.h"
#import "Common.h"


#define MESSAGE_IMAGE_HEIGHT 48
#define MESSAGE_FONT_SIZE 15

@interface MessageItem () {
    BOOL isAnimating;
}

- (int) TUMB_IMAGE_MAX_WIDTH_PORTRAIT;
- (int) TUMB_IMAGE_MAX_WIDTH_LANDSCAPE;
- (void) saveImageToFolder:(UIImage*)image;

@end

@implementation MessageItem

@synthesize delegate = _delegate;
@synthesize hasLink;
//@synthesize WebViewMessage;
//@synthesize labelMessage;
@synthesize date;
@synthesize stringMessageText;
@synthesize image;
@synthesize firstName;
@synthesize lastName;
@synthesize lastMessageText;
@synthesize contactID;
@synthesize messageID;
//@synthesize badge;
@synthesize imageExist;
@synthesize me;
@synthesize delivered;
@synthesize loading;
@synthesize needToLoading;
@synthesize type;
@synthesize url;
//@synthesize activityIndicatorView;
@synthesize messageImage;
@synthesize neetToDelete;
@synthesize responseDelivered;
@synthesize thumbnail=_thumbnail;


- (void) StartGetingFirstLastName {
    ContactObject *object = [Common getContactObjectWithSeequID:self.contactID];
    
    if (object) {
        self.firstName = object.FirstName;
        self.lastName = object.LastName;
        self.image = [object.image copy];
        
        if (!self.image) {
            NSData *imageData;
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
                //Retina display
                imageData = [Common GetLastCatchedImageWithSeequID:self.contactID Height:MESSAGE_IMAGE_HEIGHT*2];
            } else {
                imageData = [Common GetLastCatchedImageWithSeequID:self.contactID Height:MESSAGE_IMAGE_HEIGHT];
            }
            
            if (imageData) {
                self.image = [[UIImage alloc] initWithData:imageData];
            } else {
                self.image = [Common GetImageByPTID:self.contactID andHeight:MESSAGE_IMAGE_HEIGHT];
            }
        }
        
        if (!self.firstName || !self.lastName) {
            NSDictionary *dict = [Common GetLastCatchedInfoWithSeequID:self.contactID];
            [object SetUserInfoWithDictionary:dict];
            self.firstName = object.FirstName;
            self.lastName = object.LastName;
        }
        
        [Common postNotificationWithName:@"ContactObjectImageMessage" object:nil];
        return;
    }
    
    NSDictionary *dict = [Common GetLastCatchedInfoWithSeequID:self.contactID];
    if (dict) {
        [self SetUserInfoWithDictionary:dict];
    }
    [NSThread detachNewThreadSelector:@selector(StartGetingImage)
                             toTarget:self
                           withObject:nil];
}

- (void) StartGetingImage {
    NSData *imageData;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
        //Retina display
        imageData = [Common GetLastCatchedImageWithSeequID:self.contactID Height:MESSAGE_IMAGE_HEIGHT*2];
    } else {
        imageData = [Common GetLastCatchedImageWithSeequID:self.contactID Height:MESSAGE_IMAGE_HEIGHT];
    }
    
    if (imageData) {
        self.image = [[UIImage alloc] initWithData:imageData];
    } else {
        self.image = [Common GetImageByPTID:self.contactID andHeight:MESSAGE_IMAGE_HEIGHT];
    }
    
    [Common postNotificationWithName:@"ContactObjectImageMessage" object:nil];
}

- (NSString *) ConvertDateToFriendlyString:(NSTimeInterval)time {
    NSString *retVal = @"";
    
    if (!time) {
        return retVal;
    }
    
    NSDateComponents *event_components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit |
                                          NSMonthCalendarUnit |
                                          NSYearCalendarUnit |
                                          NSWeekCalendarUnit |
                                          NSWeekdayCalendarUnit |
                                          NSWeekdayOrdinalCalendarUnit
                                                                         fromDate:[NSDate dateWithTimeIntervalSince1970:time]];
    
    NSInteger event_day = [event_components day];
    NSInteger event_month = [event_components month];
    NSInteger event_year = [event_components year];
    NSInteger event_week = [event_components weekday];
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    int event_day_count = time/86400;
    int now_day_count = now/86400;
    
    int call_day_diff = now_day_count - event_day_count;
    BOOL isWeekday = NO;
    
    switch (call_day_diff) {
        case 0: {
            isWeekday = YES;
            NSDateFormatter* sChatDate = [[NSDateFormatter alloc] init];;
            [sChatDate setDateFormat:@"hh:mm a"];
            retVal = [sChatDate stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
        }
            break;
        case 1: {
            isWeekday = YES;
            retVal = @"Yesterday";
        }
            break;
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7: {
            isWeekday = YES;
            retVal = [self ConvertIntToWeekDay:event_week];
        }
            break;
    }
    
    if (!isWeekday) {
        retVal = [NSString stringWithFormat:@"%d/%d/%d", event_month, event_day, event_year];
    }
    return retVal;
}

- (NSString *) ConvertIntToWeekDay:(int)day {
    NSString *retVal = @"";
    if (!day || day > 7) {
        return retVal;
    }
    
    switch (day) {
        case 1:
            retVal = @"Sunday";
            break;
        case 2:
            retVal = @"Monday";
            break;
        case 3:
            retVal = @"Tuesday";
            break;
        case 4:
            retVal = @"Wednesday";
            break;
        case 5:
            retVal = @"Thursday";
            break;
        case 6:
            retVal = @"Friday";
            break;
        case 7:
            retVal = @"Saturday";
            break;
        default:
            break;
    }
    
    return  retVal;
}

- (void) SetUserInfoWithDictionary:(NSDictionary*)dict {
    self.firstName = [dict objectForKey:@"firstName"];
    self.lastName = [dict objectForKey:@"lastName"];
}


-(id) initWithType:(Message_Type)type_  image:(UIImage*) image_{
    self = [super init];
    if (self) {
        self.coreMessage = nil;
        self.contactID = nil;
        self.stringMessageText =@"";
        self.type = type_;
        date = 0;
        self.loading = NO;
        self.needToLoading = NO;
        me = nil;
        neetToDelete = NO;
        self.delivered = nil;
        self.messageID = nil;
        //   self.imageViewButton = nil;
        self.url = nil;
        self.loading = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFirstFrame:) name:@"FirstFrame Notif" object:nil];
        
        if (self.type == Message_Type_Video ||
            self.type== Message_Type_Video_Response ||
            self.type == Message_Type_Double_Take ||
            self.type == Message_Type_Image) {
            self.url = nil;
            UIImage *messageIm = nil;
            if (self.type == Message_Type_Image) {
                messageIm = image_;
                
            } else {
                //[self FirstFrameFromFile];
            }
            if (messageIm) {
                if (self.coreMessage &&[self.coreMessage.isSend boolValue] != YES) {
                    self.loading = YES;
                } else {
                    self.loading = NO;
                }
                
                int imageWeight = ((TUMB_IMAGE_HEIGHT/2)*messageIm.size.width)/messageIm.size.height;
                int imageHeight = 100;
                if (imageWeight > [self TUMB_IMAGE_MAX_WIDTH_PORTRAIT]) {
                    imageWeight = [self TUMB_IMAGE_MAX_WIDTH_PORTRAIT];
                    imageHeight = (imageWeight*messageIm.size.height)/messageIm.size.width;
                }
                self.messageImage =[self imageWithImage:messageIm scaledToSize:CGSizeMake(imageWeight, imageHeight)];
            } else {
               // self.needToLoading = YES;
            }
        }
        
    }
    return  self;
}

-(id)initWithCDMessage:(CDMessage *)message {
     self = [super init];
    if (self) {
        self.coreMessage = message;
        interfaceOrientation = -1;
        isAnimating = NO;
        self.contactID = message.senderContact.seequId;
        self.stringMessageText = message.textMessage;
        self.type = [message.messageType integerValue];
        date = [message.date timeIntervalSince1970];
        self.loading = NO;
        self.needToLoading = NO;
        me = [message.isNative boolValue];
        neetToDelete = NO;
        self.delivered = [message.isDelivered boolValue];
        self.messageID = message.messageID;
        //   self.imageViewButton = nil;
        self.url = message.url;
        self.loading = ![[message isSend] boolValue];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFirstFrame:) name:@"FirstFrame Notif" object:nil];

        if ([message.messageType integerValue] == Message_Type_Video ||
            [message.messageType integerValue] == Message_Type_Video_Response ||
            [message.messageType integerValue] == Message_Type_Double_Take ||
            [message.messageType integerValue] == Message_Type_Image) {
            self.url = message.url;
            UIImage *messageIm = nil;
            if (self.type == Message_Type_Image) {
                messageIm = [Common imageFromSavedFileWithContact:self.contactID message:self.messageID];
                
            } else {
                [self FirstFrameFromFile];
            }
            if (messageIm) {
                if (self.coreMessage &&[self.coreMessage.isSend boolValue] != YES) {
                    self.loading = YES;
                } else {
                    self.loading = NO;
                }

                int imageWeight = ((TUMB_IMAGE_HEIGHT/2)*messageIm.size.width)/messageIm.size.height;
                int imageHeight = 100;
                if (imageWeight > [self TUMB_IMAGE_MAX_WIDTH_PORTRAIT]) {
                    imageWeight = [self TUMB_IMAGE_MAX_WIDTH_PORTRAIT];
                    imageHeight = (imageWeight*messageIm.size.height)/messageIm.size.width;
                }
                self.messageImage =[self imageWithImage:messageIm scaledToSize:CGSizeMake(imageWeight, imageHeight)];
            } else {
                self.needToLoading = YES;
            }
        }

    }
    return  self;
}
-(void) getFirstFrame:(NSNotification*) notification {
    if (![notification.object isKindOfClass:[MessageItem class]]) {
        return;
    }
    MessageItem* ob = (MessageItem*) notification.object;
    if ([ob isEqual: self]) {
        NSLog(@"5555555555");
        [Common postNotificationWithName:@"ImageLoadFinished" object:self];
    }
}

- (float)getStringHeight:(NSString*)string forWidth:(int)width {
// JSC
//    UIFont *font_ = [UIFont fontWithName:@"Helvetica" size:MESSAGE_FONT_SIZE];
//    CGSize textSize_ = [string sizeWithFont:font_
//                          constrainedToSize:CGSizeMake(width, FLT_MAX)
//                              lineBreakMode:NSLineBreakByWordWrapping];
    
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:string
     attributes:@
     {
        NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:MESSAGE_FONT_SIZE]
     }];
    
    CGRect textRect = [attributedText boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    return textRect.size.height;
}

#pragma mark -
#pragma mark UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if (_delegate && [_delegate respondsToSelector:@selector(didClickedOnLink:onItem:)])
        {
            [_delegate didClickedOnLink:request onItem:self];
        }
        
        return NO;
    }
    
    return YES;
}

- (void) sendImageFileThread:(UIImage*)imageForSend {
    @autoreleasepool {
        NSLog(@"imageForSend.size: %@", NSStringFromCGSize(imageForSend.size));
        
        NSString *image_Name = [NSString stringWithFormat:@"image_name_%@.png", self.messageID];
        
        NSString *url_image = [Common putImageToSeequID:self.contactID ImageData:UIImagePNGRepresentation(imageForSend) ImageName:image_Name];
        
        int imageWeight = (TUMB_IMAGE_HEIGHT*imageForSend.size.width)/imageForSend.size.height;
        CGSize imageSize=CGSizeMake(imageWeight, TUMB_IMAGE_HEIGHT);
        
        imageForSend=[self imageWithImage:imageForSend scaledToSize:imageSize];
        NSString *image_Name_t = [NSString stringWithFormat:@"image_name_%@_t.png", self.messageID];
        
        NSString *url_image_t = [Common putImageToSeequID:self.contactID ImageData:UIImagePNGRepresentation(imageForSend) ImageName:image_Name_t];
        
        if (!url_image || !url_image_t) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
//                                                            message:@"Error"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
            [self performSelectorOnMainThread:@selector(sendMessageOnMainThreadWithMessageItem:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(setActivityIndicatorHide) withObject:nil waitUntilDone:YES];
            return;
        } else {
            NSLog(@"%@",self.url);
         //   self.url = self.messageDetailsObject.url;
            [NSThread sleepForTimeInterval:2.0];
            
            [self performSelectorOnMainThread:@selector(enableImageViewButton)
                                   withObject:[NSNumber numberWithBool:YES]
                                waitUntilDone:YES];
            
            [self performSelectorOnMainThread:@selector(sendMessageOnMainThreadWithMessageItem:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
        }
        
        [self performSelectorOnMainThread:@selector(setActivityIndicatorHide) withObject:nil waitUntilDone:YES];
    }
}



- (void) sendVideoFileThread:(NSData*)videoData {
    @autoreleasepool {
        
        NSString *video_Name =[NSString stringWithFormat:@"video_name_%@.mp4", self.messageID];
        NSString *url_Video = [Common putVideoToSeequID:self.contactID videoData:videoData videoName:video_Name];
        
        CGSize size=CGSizeMake((TUMB_IMAGE_HEIGHT*_thumbnail.size.width)/_thumbnail.size.height, TUMB_IMAGE_HEIGHT);
        _thumbnail=[self imageWithImage:_thumbnail scaledToSize:size];
        
        NSString *video_Name_t=[NSString stringWithFormat:@"video_name_%@_t.png", self.messageID];
        NSString *url_video_t=[Common putImageToSeequID:self.contactID ImageData:UIImagePNGRepresentation(_thumbnail) ImageName:video_Name_t];
        
        if (!url_Video || !url_video_t) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Seequ"
//                                                            message:@"Error"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
            [self performSelectorOnMainThread:@selector(sendMessageOnMainThreadWithVideoMessageItem) withObject:nil waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(setActivityIndicatorHide) withObject:nil waitUntilDone:YES];
            return;
        }

        NSLog(@"%@",self.url);
        [self setImageToImageViewButton:_thumbnail];
 
        [self performSelectorOnMainThread:@selector(sendMessageOnMainThreadWithVideoMessageItem) withObject:nil waitUntilDone:YES];
        //        }
        
        [self performSelectorOnMainThread:@selector(setActivityIndicatorHide) withObject:nil waitUntilDone:YES];
    }
}



- (void) setImageToImageViewButton:(UIImage*)img {
    int imageWeight = ((TUMB_IMAGE_HEIGHT/2)*img.size.width)/img.size.height;
    int imageHeight = 100;
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        if (imageWeight > [self TUMB_IMAGE_MAX_WIDTH_PORTRAIT]) {
            imageWeight = [self TUMB_IMAGE_MAX_WIDTH_PORTRAIT];
            imageHeight = (imageWeight*img.size.height)/img.size.width;
        }
    } else {
        if (imageWeight > [self TUMB_IMAGE_MAX_WIDTH_LANDSCAPE]) {
            imageWeight = [self TUMB_IMAGE_MAX_WIDTH_LANDSCAPE];
            imageHeight = (imageWeight*img.size.height)/img.size.width;
        }
    }
    
    UIImage *newImage = [self imageWithImage:img scaledToSize:CGSizeMake(imageWeight, imageHeight)];
    self.messageImage = newImage;
    
    
    // [self setOrientation:orientation];
}

- (void) enableImageViewButton {
    // self.imageViewButton.enabled = YES;
}

- (void) setActivityIndicatorHide {
    
    self.loading = NO;
    [Common postNotificationWithName:@"ImageLoadFinished" object:self];
}

- (void) loadFile {
    self.needToLoading = NO;
    self.loading = YES;
    
    UIImage *messageIm = nil;
    if (self.type == Message_Type_Image) {
        messageIm = [Common imageFromSavedFileWithContact:self.contactID message:self.messageID];

    } else {
         [self FirstFrameFromFile];
 
    }
    
    if (messageIm) {
        if (self.coreMessage &&[self.coreMessage.isSend boolValue] == YES) {
            self.loading = YES;
        } else {
            self.loading = NO;
        }
        
        NSLog(@"DEBUG: [messages] loading thumbnail image from Cache");
        [self setImageToImageViewButton:messageIm];
    } else {
        NSLog(@"DEBUG: [messages] loading thumbnail image from Server");
        ///@todo send  notificationt  to start  activity indicator
        //    [self.activityIndicatorView startAnimating];
 //       [Common postNotificationWithName:@"ImageLoadStarted" object:self];
        //       [self.imageViewButton addSubview:self.activityIndicatorView];
        
        [NSThread detachNewThreadSelector:@selector(loadFileThread) toTarget:self withObject:nil];
    }
}

- (void) loadFileThread {
    @autoreleasepool {
        NSString *srtingURL=self.url;
        if (self.type==Message_Type_Video||self.type==Message_Type_Video_Response||self.type==Message_Type_Double_Take) {
            srtingURL=[srtingURL stringByReplacingOccurrencesOfString:@".mp4" withString:@"_t.png"];
        }
        int retryCount = 30;
        
        while (retryCount > 0) {
            retryCount--;
            NSData *data = [Common getMediaDataWithURLString:srtingURL];
            if (data) {
                UIImage *image_ = [UIImage imageWithData:data];
                
                if (!image_) {
                    image_=nil;
                }
                [self saveImageToFolder:image_];
                [self setImageToImageViewButton:image_ ];
                break;
                
                
            }
            
            [NSThread sleepForTimeInterval:0.5];
        }
        
        [self performSelectorOnMainThread:@selector(setActivityIndicatorHide) withObject:nil waitUntilDone:YES];
    }
}

- (UIImage *)imageWithImage:(UIImage *)image_ scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image_ drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (int) TUMB_IMAGE_MAX_WIDTH_PORTRAIT {
    return [[UIScreen mainScreen] bounds].size.width - 105;
}

- (int) TUMB_IMAGE_MAX_WIDTH_LANDSCAPE {
    return [[UIScreen mainScreen] bounds].size.height - 105;
}

- (void) saveImageToFolder:(UIImage*)image_ {
    NSString *imageToSaveFolder = [Common makeFolderIfNotExist:self.contactID];
    
    if (!imageToSaveFolder) {
        return;
    }
    
    NSString *imagePath = [imageToSaveFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_image.png", self.messageID]];
    
    NSData *imageData = UIImagePNGRepresentation(image_);
    [imageData writeToFile:imagePath options:NSAtomicWrite error:nil];
    NSLog(@"DEBUG: [messages] image thumbnail Cached - %@", imagePath);
}


-(void) prepareImage:(UIImage*) originIm {
    int imageWeight = ((TUMB_IMAGE_HEIGHT/2)*originIm.size.width)/originIm.size.height;
    int imageHeight = 100;
    if (imageWeight > [self TUMB_IMAGE_MAX_WIDTH_PORTRAIT]) {
        imageWeight = [self TUMB_IMAGE_MAX_WIDTH_PORTRAIT];
        imageHeight = (imageWeight*originIm.size.height)/originIm.size.width;
    }
    self.messageImage =[self imageWithImage:originIm scaledToSize:CGSizeMake(imageWeight, imageHeight)];
}


- (void) FirstFrameFromFile {
    __weak MessageItem* weakSelf = self;
    dispatch_queue_t myQueue = dispatch_queue_create("First Frame Que",NULL);
    dispatch_async(myQueue, ^{
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [documentPaths objectAtIndex:0];
        NSString *imageToSaveFolder =  [documentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_IMAGES", weakSelf.contactID]];
        NSString *imageFileName = [NSString stringWithFormat:@"%@_image.png", weakSelf.messageID];
        NSString *videoFileName = [NSString stringWithFormat:@"%@_video.mp4", weakSelf.messageID];
        BOOL isDir ;
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imageToSaveFolder isDirectory:&isDir];
        if (!fileExists) {
            return ;
        }
        NSString *imageFilePath = [imageToSaveFolder stringByAppendingPathComponent:imageFileName];
        NSString *videoFilePath = [imageToSaveFolder stringByAppendingPathComponent:videoFileName];
   
        if( [[NSFileManager defaultManager] fileExistsAtPath:imageFilePath isDirectory:&isDir]) {

            [weakSelf prepareImage:[UIImage imageWithContentsOfFile:imageFilePath]];

    //        [Common postNotificationWithName:@"FirstFrame Notif" object:self];

            return ;
        } else if([[NSFileManager defaultManager] fileExistsAtPath:videoFilePath isDirectory:&isDir]){
            AVURLAsset* asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoFilePath] options:nil];
            AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
            imageGenerator.appliesPreferredTrackTransform = YES;
            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil];
            UIImage* im = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            [weakSelf prepareImage:im];
            //   block(im);

  //          [Common postNotificationWithName:@"FirstFrame Notif" object:self];
            return;
            
        }
    });

}


@end
