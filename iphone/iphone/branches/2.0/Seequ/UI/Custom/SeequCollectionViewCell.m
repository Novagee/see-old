//
//  SeequCollectionViewCell.m
//  ProTime
//
//  Created by Grigori Jlavyan on 8/12/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequCollectionViewCell.h"
#define CELL_DURATION_LABLE_HEIGHT 20

@implementation SeequCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
            
            self.imageView=[[UIImageView alloc] initWithFrame:frame];
            self.imageView.userInteractionEnabled=YES;
            self.imageView.contentMode=UIViewContentModeScaleAspectFill;
            self.imageView.clipsToBounds=YES;
            UIImage *checkimage=[UIImage imageNamed:@"checButton"];
            self.duration=[[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height-CELL_DURATION_LABLE_HEIGHT,frame.size.width,CELL_DURATION_LABLE_HEIGHT)];
            [self.duration setBackgroundColor:[UIColor lightGrayColor]];
            [self.duration setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
            self.check=[[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-checkimage.size.width,frame.size.height-CELL_DURATION_LABLE_HEIGHT-checkimage.size.height,checkimage.size.width ,checkimage.size.height)];
            self.check.image=checkimage;
            self.check.clipsToBounds=YES;
            self.check.contentMode=UIViewContentModeScaleAspectFit;
            self.check.hidden=YES;
            [self.contentView addSubview:self.imageView];
            [self.contentView addSubview:self.duration];
            [self.contentView addSubview:self.check];
        // Initialization code
    }
    return self;
}
- (void)prepareForReuse
{
        [super prepareForReuse];
        
        // reset image property of imageView for reuse
        self.imageView.image = nil;
       
        // update frame position of subviews
        self.imageView.frame = self.contentView.bounds;
//        self.check=[[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-checkimage.size.width,frame.size.height-CELL_DURATION_LABLE_HEIGHT-checkimage.size.height,checkimage.size.width ,checkimage.size.height)];
}

@end
