//
//  ContactCell.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 9/27/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//
#import "UserInfoCoreData.h"
#import <UIKit/UIKit.h>
#import "ContactObject.h"

typedef enum CellType {
	CellType_Phone,
	CellType_Seequ,
    CellType_Group
} CellType;


@interface ContactCell : UITableViewCell {
    UIImageView *imageViewContactOnlineStatus;
    UIImageView *imageViewContactMasterBadge;
}

@property (nonatomic, strong) ContactObject *contactObject;
@property (nonatomic,assign) CellType cellType;
- (void) setContactObject:(ContactObject*)object;
- (void) setDisplayName:(ContactObject*)object;
- (void) setProfileImage:(ContactObject*)object;
- (void) setMasterBadge:(NSString*)masterBadgeType;
- (void) setOnlineStatus:(online_Status)online;
- (void) setInterfaceOrientation:(UIInterfaceOrientation)orientation Video:(BOOL)video;
- (void) updateCell:(UserInfoCoreData *)obj;
@end
