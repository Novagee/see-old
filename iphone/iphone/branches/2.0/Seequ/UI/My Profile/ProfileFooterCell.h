//
//  ProfileFooterCell.h
//  ProTime
//
//  Created by Levon Nikoghosyan on 12/12/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileFooterInfo.h"

@protocol ProfileFooterCellDelegate <NSObject>

-(void) didDataChanged;

@end
@interface ProfileFooterCell : UITableViewCell

@property (nonatomic,retain) IBOutlet UILabel*  name;
@property (nonatomic,retain) IBOutlet UITextField*  value;
@property (nonatomic,retain) IBOutlet UIImageView* flag;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView* loadingIndicator;
@property (nonatomic,retain) ProfileFooterInfo*  data;
@property (nonatomic, assign) id<ProfileFooterCellDelegate> delegate;

@property (nonatomic, assign) BOOL withImage;
-(void) updateCell:(NSString*)name value:(NSString*) value withImage:(UIImage*) image;
-(void) startCountryUpdate;
-(void) startStateUpdate:(NSString*) state;
@end
