//
//  ContactCell.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 9/27/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//
#import "UserInfoCoreData.h"
#import "UserStatusCoreData.h"
#import "ContactCell.h"
#import "ChatManager.h"
#import "idoubs2AppDelegate.h"

#define RATING_STARS_VIEW_TAG 50
#define ACTIVITY_INDICATOR_TAG 2022


@implementation ContactCell

@synthesize contactObject = _contactObject;
@synthesize cellType = _cellType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        imageViewContactOnlineStatus = nil;
    }
    return self;
}

//-(void) setIsForGroup:(BOOL)isForGroup_ {
//    _isForGroup = isForGroup_;
//    imageViewContactOnlineStatus.hidden =_isForGroup;
//    if (_isForGroup) {
//        self.detailTextLabel.text = [self.detailTextLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    }
//}

- (void) setContactObject:(ContactObject*)object {
    _contactObject = nil;
    [self resetCell];

    _contactObject = object;
    if (object.contactType == Contact_Type_Address_Book) {
        [self.textLabel setTextColor:[UIColor grayColor]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 23)];
        [accessoryImageView setImage:[UIImage imageNamed:@"seequInviteFromAddressBook.png"]];
        self.accessoryView = accessoryImageView;
    }
    
    [self setDisplayName:object];

    if (object.specialist) {
        NSString *specialist = [@"   " stringByAppendingString:object.specialist];
        self.detailTextLabel.text = specialist;
    }
    self.tag = [object.SeequID intValue];
    [self setContactImage:object];
    
    if (object.contactType != Contact_Type_Address_Book) {
//        [self setMasterBadge:object.badgeStatus];
 //       [self setOnlineStatus:object.isOnline];
//        id<ChatManager> chatMng = [idoubs2AppDelegate getChatManager];
//        NSString *from = [NSString stringWithFormat:@"%@@im.protime.tv", object.SeequID];
//        [self setOnlineStatus:[chatMng GetUserOnLineStatus:from]];
//        [self setRatingStars:ceilf(object.ratingValue) InterfaceOrientation:UIInterfaceOrientationMaskPortrait];
    }
}
-(void) resetCell {
    _contactObject = nil;
    self.accessoryView = nil;
    self.detailTextLabel.text =nil;
    self.textLabel.text = nil;
    [imageViewContactOnlineStatus removeFromSuperview];
    [self.textLabel setTextColor:[UIColor blackColor]];
}

-(void)updateCell:(UserInfoCoreData *)obj{
    [self resetCell];
    self.textLabel.text=[NSString stringWithFormat:@"%@ %@",obj.firstName,obj.lastName];
        __block CGSize s = CGSizeMake(self.frame.size.height - 4, self.frame.size.height - 4);

        if(obj.userImage){
    //        dispatch_async(dispatch_get_main_queue(), ^{
                UIImage* im = [Common imageWithImage:[UIImage imageWithData:obj.userImage] scaledToSize:s];
                [self.imageView setImage:im];
                
   //         });

        } else {
            __block UIImage* profImage = [UIImage imageNamed:@"profile"];
            profImage = [Common imageWithImage:profImage scaledToSize:s];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageView setImage:profImage];

            });
//            UIActivityIndicatorView* activity =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//            activity.tag = ACTIVITY_INDICATOR_TAG;
//            [self.imageView addSubview:activity];
//            [activity startAnimating];
//            __weak ContactCell*  weakSelf = self;
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//       
//                [[ContactStorage sharedInstance] getImageBySeequId:obj.seeQuId success:^(UIImage *image) {
//                    [[ContactStorage sharedInstance] SetImageBySeequId:obj.seeQuId image:image];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        UIActivityIndicatorView* v = (UIActivityIndicatorView*)[weakSelf.imageView viewWithTag:ACTIVITY_INDICATOR_TAG];
//                        [v stopAnimating];
//                        [v removeFromSuperview];
//                        UIImage* im  = [Common imageWithImage:image scaledToSize:s];
//                        [weakSelf.imageView setImage:im];
//
//                    });
//
//                }];
//            });
//
            
        }
    
    if (self.cellType != CellType_Group) {
        [self setOnlineStatus:[obj.status.isOnline intValue]];
    }
    
    self.detailTextLabel.text=obj.title;
    self.tag=obj.seeQuId;
}

- (void) setDisplayName:(ContactObject*)object {
    self.textLabel.text = [object CompositeName];
}

- (void) setProfileImage:(ContactObject*)object {
    __weak ContactCell* weakSelf = self;
    if (!object.imageExist) {
        self.imageView.image = [UIImage imageNamed:@"GenericContact.png"];
    } else {
        if (object.image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imageView.image = object.image;
            });

            
        } else {
            weakSelf.imageView.image = [UIImage imageNamed:@"GenericContact.png"];
        }
    }
}

- (void) setContactImage:(ContactObject*)object {
 
    if (object.image) {
        CGSize s = CGSizeMake(self.frame.size.height - 4, self.frame.size.height - 4);
        UIImage* im = [Common imageWithImage:object.image scaledToSize:s];
        self.imageView.image = im;
    }
    
}

- (void) setMasterBadge:(NSString*)masterBadgeType {
    imageViewContactMasterBadge = [[UIImageView alloc] initWithFrame:CGRectMake(231, 15, 55, 15)];
    if (masterBadgeType) {
        NSString *imageName = [NSString stringWithFormat:@"ProfileBadgeStatus%@.png", masterBadgeType];
        [imageViewContactMasterBadge setImage:[UIImage imageNamed:imageName]];
    }
    
    [self addSubview:imageViewContactMasterBadge];
}

- (void) setOnlineStatus:(online_Status)online {
    
    if (!imageViewContactOnlineStatus) {
        imageViewContactOnlineStatus = [[UIImageView alloc] initWithFrame:CGRectMake(70, 38, 7, 6)];
    }

    switch (online) {
        case online_Status_Online: {
            [imageViewContactOnlineStatus setImage:[UIImage imageNamed:@"contactOnlineLabel.png"]];
        }
            break;
        case online_Status_Offline: {
            [imageViewContactOnlineStatus setImage:[UIImage imageNamed:@"contactOffLineLabel.png"]];
        }
            break;
        case online_Status_Away: {
            [imageViewContactOnlineStatus setImage:[UIImage imageNamed:@"contactAwayLabel.png"]];
        }
            break;
        default:
            break;
    }
    
    [self.contentView addSubview:imageViewContactOnlineStatus];
}


- (void) setInterfaceOrientation:(UIInterfaceOrientation)orientation Video:(BOOL)video {
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageViewContactMasterBadge.frame = CGRectMake(231, 15, 55, 15);
    } else {
        if (video) {
            imageViewContactMasterBadge.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height - 89 - 82*2, 15, 55, 15);
        } else {
            imageViewContactMasterBadge.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height - 89, 15, 55, 15);
        }
    }
    
//    [self setRatingStars:ceilf(self.contactObject.ratingValue) InterfaceOrientation:orientation];
}
-(void) setEditing:(BOOL)editing {
    [super setEditing:editing];
    NSLog(@"set editing");
}

-(void)layoutSubviews{
    [super layoutSubviews];
    switch (self.cellType) {
        case CellType_Phone:{
            self.imageView.frame = (_contactObject && _contactObject.image) ?
            CGRectMake(2, 2, self.frame.size.height - 4 , self.frame.size.height - 4  ):CGRectZero;
           }
            break;
        case CellType_Seequ: {
            self.imageView.frame = CGRectMake(2, 2, self.frame.size.height - 4 , self.frame.size.height - 4  );
        }
            break;
        case CellType_Group: {
            self.imageView.frame = CGRectMake(2, 2, self.frame.size.height - 4 , self.frame.size.height - 4  );
        }
            break;
        default:
            break;
    }
    if (!self.detailTextLabel.text || self.detailTextLabel.text.length == 0) {
        self.textLabel.frame = CGRectMake(self.imageView.frame.size.width + 40, self.textLabel.frame.origin.y,  self.textLabel.frame.size.width ,self.textLabel.frame.size.height);
    } else {
        self.textLabel.frame = CGRectMake(self.imageView.frame.size.width + 32, self.textLabel.frame.origin.y,  self.textLabel.frame.size.width ,self.textLabel.frame.size.height);

    }
    self.detailTextLabel.frame = CGRectMake(self.imageView.frame.size.width + 40, 30,  self.detailTextLabel.frame.size.width ,self.detailTextLabel.frame.size.height);

    imageViewContactOnlineStatus.frame  = CGRectMake(self.imageView.frame.size.width + 30, self.detailTextLabel.center.y - 3, 7, 6);
}

@end
