//
//  SeequDoubleTakeSettingsCell.m
//  ProTime
//
//  Created by Grigori Jlavyan on 3/18/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//
#import "ContactStorage.h"
#import "SeequDoubleTakeSettingsCell.h"

@interface SeequDoubleTakeSettingsCell (){
    UIImageView *imageView;
    UILabel *labelFisrtLastName;
    UISwitch *needDoubleTakeSwitch;
}
@property(nonatomic,retain)ContactObject *contactObject;
@end

@implementation SeequDoubleTakeSettingsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        imageView=[[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 53, 53)];
        [self addSubview:imageView];
        labelFisrtLastName=[[UILabel alloc] initWithFrame:CGRectMake(70, 10, 200, 30)];
        labelFisrtLastName.textColor=[UIColor blackColor];
        labelFisrtLastName.backgroundColor=[UIColor clearColor];
        [self addSubview:labelFisrtLastName];
        needDoubleTakeSwitch=[[UISwitch alloc] init];
        [needDoubleTakeSwitch addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
        needDoubleTakeSwitch.center=CGPointMake(280, 25);
        [needDoubleTakeSwitch setOnTintColor:[UIColor colorWithRed:112.0/255.0 green:173.0/255.0 blue:192.0/255.0 alpha:1]];
        [self addSubview:needDoubleTakeSwitch];
    }
    return self;
}

-(void)updateCell:(ContactObject *)object needToDoubleTake:(BOOL)needDoubletake{
    self.contactObject=object;
         labelFisrtLastName.text = [NSString stringWithFormat:@"%@ %@", object.FirstName, object.LastName];
    if (!object.imageExist) {
        [imageView setImage:[UIImage imageNamed:@"GenericContact.png"]];
    } else {
        if (object.image) {
            [imageView setImage:object.image];
        } else {
            [imageView setImage:[UIImage imageNamed:@"GenericContact.png"] ];
        }
    }
    [needDoubleTakeSwitch setOn:needDoubletake];
}
- (void)updateCellForMutedMembers:(ContactObject*)object{
        self.contactObject=object;
        labelFisrtLastName.text = [NSString stringWithFormat:@"%@ %@", object.FirstName, object.LastName];
        if (!object.imageExist) {
                [imageView setImage:[UIImage imageNamed:@"GenericContact.png"]];
        } else {
                if (object.image) {
                        [imageView setImage:object.image];
                } else {
                        [imageView setImage:[UIImage imageNamed:@"GenericContact.png"] ];
                }
        }
        needDoubleTakeSwitch.hidden=YES;
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setState:(id)sender{
    
    BOOL state=[sender isOn];
        [[ContactStorage sharedInstance] setNeedToDoubleTake:self.contactObject.SeequID needToDoubleTake:state];
    
}
@end
