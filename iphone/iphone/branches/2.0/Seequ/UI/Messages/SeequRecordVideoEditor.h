//
//  SeequRecordVideoEditor.h
//  ProTime
//
//  Created by Grigori Jlavyan on 4/25/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SeequRecordVideoEditorDelegate <NSObject>
-(void)videoEditorPressed;
@end
@interface SeequRecordVideoEditor : UIView
@property(nonatomic,weak)id<SeequRecordVideoEditorDelegate> delegate;
-(id)init;
-(void)videoImageWithURL:(NSURL*)videoURL;
-(void)removeVideoImage;
-(void)setPhotoImage:(UIImage*)image;
@end
