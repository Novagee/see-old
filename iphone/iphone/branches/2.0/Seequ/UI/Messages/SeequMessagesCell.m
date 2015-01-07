//
//  SeequMessagesCell.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 2/2/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import "idoubs2AppDelegate.h"
#import "SeequMessagesCell.h"
#import "Common.h"
#import "TBIDefaultBadgView.h"
#import "UserInfoCoreData.h"
#import "CDGroup.h"
@interface SeequMessagesCell (){
    UIImageView *imageViewImageRamka;
    UIImageView *imageViewUserImage;
    UILabel *labelFisrtLastName;
    UILabel *labelLastMessage;
    UILabel *labeldate;
    TBIDefaultBadgView *messageBadgView;
}

@property (nonatomic,retain) MessageItem*  messageItem;
@end


@implementation SeequMessagesCell
@synthesize messageItem;
@synthesize editable;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.editable = NO;
        self.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
        imageViewImageRamka = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 62)];
        [imageViewImageRamka setImage:[UIImage imageNamed:@"seequDefaultImageBG.png"]];
        [self addSubview:imageViewImageRamka];
        imageViewUserImage = [[UIImageView alloc] initWithFrame:CGRectMake(9, 6, 48, 48)];
        [imageViewImageRamka addSubview:imageViewUserImage];
        
        labelFisrtLastName = [[UILabel alloc] initWithFrame:CGRectMake(65, 5, 200, 20)];
        labelFisrtLastName.textColor = [UIColor blackColor];
        labelFisrtLastName.backgroundColor = [UIColor clearColor];
        labelFisrtLastName.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:labelFisrtLastName];
        
        labelLastMessage = [[UILabel alloc] initWithFrame:CGRectMake(65, 27, 200, 35)];
        labelLastMessage.textColor = [UIColor darkGrayColor];
        labelLastMessage.backgroundColor = [UIColor clearColor];
        labelLastMessage.font = [UIFont fontWithName:@"Helvetica" size:14];
        labelLastMessage.numberOfLines = 2;
        [self addSubview:labelLastMessage];
        labeldate = [[UILabel alloc] init];
        labeldate.textColor = [UIColor blueColor];
        labeldate.backgroundColor = [UIColor clearColor];
        labeldate.font = [UIFont fontWithName:@"Helvetica" size:12];
        [self addSubview:labeldate];
        messageBadgView = [[TBIDefaultBadgView alloc] init];
        messageBadgView.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
        [self addSubview:messageBadgView];
        messageBadgView.center = CGPointMake(48, 4);

    }
    return self;
}
-(void)willTransitionToState:(UITableViewCellStateMask)state{
    [super willTransitionToState:state];
    if (state != UITableViewCellStateDefaultMask && state != UITableViewCellStateShowingEditControlMask) {
        labeldate.hidden = YES;
        
    }
}
-(void)didTransitionToState:(UITableViewCellStateMask)state{
    [super didTransitionToState:state];
    if (state == UITableViewCellStateDefaultMask || state == UITableViewCellStateShowingEditControlMask) {
        labeldate.hidden = NO;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) layoutSubviews{
    [super layoutSubviews];
    labeldate.frame = CGRectMake(self.frame.size.width-90, 5, 80, 20);
    labelFisrtLastName.frame = CGRectMake(65, 5, self.frame.size.width -165, 20);
    labelLastMessage.frame = CGRectMake(65, 27, self.frame.size.width - 90, 35);
}

-(void) updateCellInfo:(CDMessageOwner *)item {
    UserInfoCoreData* userInfo = item.userInfo;
    labelFisrtLastName.text = item.name;
    labelLastMessage.text = item.lastMessage;
    labeldate.text = [Common ConvertNSDateToFriendlyString:item.lastDate]; ///@todo  change
    imageViewImageRamka.hidden = self.editable;

    if ([item.isGroup boolValue]) {
        ///@todo implement
         [imageViewUserImage setImage:[UIImage imageNamed:@"favicon"]];
    } else {
        if(userInfo.userImage){
            UIImage* image = [UIImage imageWithData:userInfo.userImage];
            [imageViewUserImage setImage:image];
        } else {
            
            ///@todo levon
//            image =[UIImage imageWithData:[NSData dataWithContentsOfFile:[[ContactStorage sharedInstance] getImagePathBySeequID:userInfo.seeQuId]]];
//            if (image) {
//                [[idoubs2AppDelegate sharedInstance].userPhotoDictionary setObject:image forKey:userInfo.seeQuId];
//            }
            [[ContactStorage sharedInstance] getImageBySeequId:userInfo.seeQuId success:^(UIImage *image) {
                [[ContactStorage sharedInstance] SetImageBySeequId:userInfo.seeQuId image:image];
                [imageViewUserImage setImage:image];
            }];
        }
          
    }
    
    int badge = [Common getCurrentUserBadgeValue:item.seequId];
    
    if (badge) {
        messageBadgView.hidden = NO;
        NSString *strBadge = [NSString stringWithFormat:@"%d", badge];
        [messageBadgView SetText:strBadge];
        CGRect frame = CGRectMake(73 - messageBadgView.frame.size.width, 4, messageBadgView.frame.size.width, messageBadgView.frame.size.height);
        messageBadgView.frame = frame;
    } else  {
        messageBadgView.hidden = YES;
    }


}













@end
