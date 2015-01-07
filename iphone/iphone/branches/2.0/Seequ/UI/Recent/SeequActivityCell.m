//
//  ActivityCell.m
//  ProTime
//
//  Created by Grigori Jlavyan on 2/19/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import "Common.h"
#import "SeequActivityCell.h"
@interface SeequActivityCell (){
    UIImageView *imageView;
    UIImageView *imageViewAccessory;
    UILabel *labelFisrtLastName;
    UILabel *labelDetail;
    UILabel *labeldate;
}
@end
@implementation SeequActivityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        imageView=[[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 55, 55)];
        [self addSubview:imageView];
        imageViewAccessory=[[UIImageView alloc] initWithFrame:CGRectMake(60, 30, 16, 16)];
        [self addSubview:imageViewAccessory];
        labelFisrtLastName=[[UILabel alloc] initWithFrame:CGRectMake(70, 0, 200, 30)];
        labelFisrtLastName.textColor=[UIColor blackColor];
        labelFisrtLastName.font=[UIFont boldSystemFontOfSize:18];
        labelFisrtLastName.backgroundColor=[UIColor clearColor];
        [self addSubview:labelFisrtLastName];
        labelDetail=[[UILabel alloc] initWithFrame:CGRectMake(70, 25, 240, 25)];
        labelDetail.textColor=[UIColor darkGrayColor];
        labelDetail.backgroundColor=[UIColor clearColor];
        [labelDetail setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:labelDetail];
        labeldate=[[UILabel alloc] initWithFrame:CGRectMake(220, 15, 70, 20)];
        labeldate.textColor=[UIColor redColor];
        labeldate.backgroundColor=[UIColor clearColor];
        [self addSubview:labeldate];
        self.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)updateCell:(ContactObject *)object{
    if (object.isRecent) {
        
        labelFisrtLastName.text = [NSString stringWithFormat:@"%@ %@", object.FirstName, object.LastName];
       switch (object.status) {
            case 1: { // Outgoing
                [imageViewAccessory setImage:[UIImage imageNamed:@"activityOutgoingCallLogo.png"]];
                if ((int)(object.stopTime - object.startTime) == 0) {
                    labelDetail.text = @"     No Answer";
                } else {
                    labelDetail.text = [Common ConvertDurationToString:(int)(object.stopTime - object.startTime)];
                }
            }
                break;
            case 2: { // Incoming
                [imageViewAccessory setImage:[UIImage imageNamed:@"activityIncomingCallLogo.png"]];
                labelDetail.text = [Common ConvertDurationToString:(int)(object.stopTime - object.startTime)];
            }
                break;
            case 0:
            case 3:
               { // Missed
                       if (object.status==0) {
                            [labelFisrtLastName setTextColor:[UIColor redColor]];
                       }else{
                            [labelFisrtLastName setTextColor:[UIColor blackColor]];
                       }
                       
                [imageViewAccessory setImage:[UIImage imageNamed:@"activityIncomingCallLogo.png"]];
                labelDetail.text = @"     Missed Call";
                
                [self LabelDateWithDate:object.startTime];
            
            }
                break;
            default:
                break;
        }
//        [cell addSubview:imageView];
    [self LabelDateWithDate:object.startTime];

    } else {
        labelFisrtLastName.text = [NSString stringWithFormat:@"%@ %@", object.FirstName, object.LastName];
        switch (object.requestStatus) {
            case Request_Status_Connection:
            case Request_Status_Recived_Connection_Accepted:
            case Request_Status_Recived_Connection_Declined: {
                labelDetail.text = @"wants to connect with you";
                if (object.requestStatus == Request_Status_Connection) {
                    [labelFisrtLastName setTextColor:[UIColor redColor]];
                    [self setBackgroundColor:[UIColor colorWithRed:240.0/255.0
                                                               green:240.0/255.0
                                                                blue:240.0/255.0
                                                               alpha:1.0]];
                }
            }
                break;
            case Request_Status_For_Connection: {
                labelDetail.text = @"Sent a request for connection";
            }
                break;
            case Request_Status_Connection_Accepted: {
                //                cell.accessoryType = UITableViewCellAccessoryNone;
                //                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                labelDetail.text = @"accepted your request to connect";
            }
                break;
            case Request_Status_Connection_Declined: {
                //                cell.accessoryType = UITableViewCellAccessoryNone;
                //                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                labelDetail.text = @"declined your request to connect";
            }
                break;
            case Request_Status_Ringback:
            case Request_Status_Recived_Ringback_Accepted:
            case Request_Status_Recived_Ringback_Declined: {
                labelDetail.text = @"    has requested a Ringback";
               
                [imageViewAccessory setImage:[UIImage imageNamed:@"activityRingbackCallLogo.png"]];
             
                if (object.requestStatus == Request_Status_Ringback) {
                    [labelFisrtLastName setTextColor:[UIColor redColor]];
                    [self setBackgroundColor:[UIColor colorWithRed:240.0/255.0
                                                               green:240.0/255.0
                                                                blue:240.0/255.0
                                                               alpha:1.0]];
                }
            }
                break;
            case Request_Status_For_Ringback: {
                labelDetail.text = @"    sent request for Ringback";
                
                [imageViewAccessory setImage:[UIImage imageNamed:@"activityRingbackCallLogo.png"]];
             
            }
                break;
            case Request_Status_Ringback_Accepted: {
                labelDetail.text = @"accepted your request to Ringback";
            }
                break;
            case Request_Status_Ringback_Declined: {
                labelDetail.text = @"declined your request to Ringback";
            }
                break;
            default:
                break;
        }
    [self LabelDateWithDate:object.startTime];
    }
    
    if (!object.imageExist) {
       [imageView setImage:[UIImage imageNamed:@"GenericContact.png"]];
    } else {
        if (object.image) {
            [imageView setImage:object.image];
        } else {
            [imageView setImage:[UIImage imageNamed:@"GenericContact.png"] ];
        }
    }
    
    
}
- (void) LabelDateWithDate:(NSTimeInterval)date {
    labeldate.backgroundColor = [UIColor clearColor];
    labeldate.font = [UIFont systemFontOfSize:11];
    labeldate.textAlignment = NSTextAlignmentRight;
    labeldate.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    labeldate.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    labeldate.lineBreakMode =NSLineBreakByWordWrapping;
    labeldate.textColor = [UIColor blueColor];
    labeldate.highlightedTextColor = [UIColor whiteColor];
    labeldate.text = [self ConvertDateToFriendlyString:date];
    
   
}
- (NSString *) ConvertDateToFriendlyString:(NSTimeInterval)time {
    NSString *retVal = @"";
    
    if (!time) {
        return retVal;
    }
    
    @try {
            NSDate *date=[NSDate dateWithTimeIntervalSince1970:time];

        NSDateFormatter *Shortday = [[NSDateFormatter alloc] init];
            Shortday.timeStyle = kCFDateFormatterShortStyle;
            Shortday.dateStyle = NSDateFormatterShortStyle;
            Shortday.doesRelativeDateFormatting = YES;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM dd, yyy"];
        NSDateFormatter *weekDay = [[NSDateFormatter alloc] init];
            [weekDay setDateFormat:@"EEE"];
            NSDateFormatter *hours=[[NSDateFormatter alloc] init];
            [hours setDateFormat:@"hh:mm"];
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        
        int event_day_count = time/86400;
        int now_day_count = now/86400;
        
        int call_day_diff = now_day_count - event_day_count;
        BOOL isWeekday = NO;
        
        switch (call_day_diff) {
            case 0: {
                isWeekday = YES;
                retVal = [Shortday stringFromDate:date];
            }
                break;
            case 1:
                {
                isWeekday = YES;
                retVal = [Shortday stringFromDate:date];
            }
                break;
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
            case 7: {
                isWeekday = YES;
                retVal =[NSString stringWithFormat:@"%@ %@",[weekDay stringFromDate:date],[hours stringFromDate:date]];
            }
                break;
        }
        
        if (!isWeekday) {
           retVal = [NSString stringWithFormat:@"%@",[formatter stringFromDate:date]];
        }
    } @catch (NSException * e) {
        return @"";
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

@end
