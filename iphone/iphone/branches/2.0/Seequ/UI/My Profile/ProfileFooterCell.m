 //
//  ProfileFooterCell.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 12/12/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import "ProfileFooterCell.h"
#import "Common.h"
typedef enum  {
	STATE_TYPE,
	COUNTRY_TYPE,
	DEFAULT_TYPE
}
FOOTER_CELL_TYPE;

@interface ProfileFooterCell (){
    FOOTER_CELL_TYPE type;
}
@property (nonatomic,retain) UIImage* image;
@property (nonatomic,retain) NSArray* countryArray;
@property (nonatomic,retain) NSArray* stateArray;

@end

@implementation ProfileFooterCell
@synthesize name;
@synthesize value;
@synthesize withImage;
@synthesize flag;
@synthesize image;
@synthesize data;
@synthesize loadingIndicator;
@synthesize  delegate;
@synthesize countryArray;
@synthesize stateArray;



-(id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        type = DEFAULT_TYPE;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateStateList:) name:@"onUpdateStateList" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateCountryList:) name:@"onUpdateCountryList" object:nil];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) textFieldDidChange{
    data.value = value.text;
    [delegate didDataChanged];
}

-(void) updateCell:(NSString *)labelName value:(NSString *)labelValue withImage:(UIImage*)im{
    self.name.text = labelName;
    self.value.text = labelValue;
     self.withImage = (im != nil);
    self.image = im;
    if (image) {
        [flag setImage: self.image];
    }
    [value addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}

-(CGFloat) getScaleFactor{
  //  return (image.size.height  > 60)? (self.frame.size.width -10)/image.size.height :1;
    return 35/image.size.width;
}

-(void) layoutSubviews {
    [super layoutSubviews];
    if (withImage) {
        value.frame = CGRectMake(140, (self.frame.size.height - 42)/2, self.frame.size.width -155, 42);
        NSLog(@"%@",NSStringFromCGSize(image.size));
        CGFloat scaleFactor = [self getScaleFactor];
        flag.frame = CGRectMake(90, (self.frame.size.height - image.size.height*scaleFactor)/2, image.size.width*scaleFactor, image.size.height*scaleFactor);
        flag.hidden = NO;


    } else {
        value.frame = CGRectMake(120, (self.frame.size.height - 42)/2, self.frame.size.width -130, 42);
        flag.hidden = YES;
    }
    
    
}

-(void) onUpdateCountryList:(NSNotification*)notification {
    if (type != COUNTRY_TYPE) {
        return;
    }
    NSArray* arr = [notification object];
    self.countryArray = arr;
    self.userInteractionEnabled = YES;
    self.value.textColor = [UIColor blackColor];
    [self.loadingIndicator stopAnimating];
}

-(void) startCountryUpdate {

    [self.loadingIndicator startAnimating];
    self.userInteractionEnabled = NO;
    self.value.textColor = [UIColor grayColor];
    type = COUNTRY_TYPE;

//    [self performSelectorInBackground:@selector(GetAllCountries) withObject:nil];
}



-(void) onUpdateStateList:(NSNotification*)notification {
    if (type !=STATE_TYPE) {
        return;
    }
    NSArray* arr = [notification object];

    self.stateArray = arr;
    self.userInteractionEnabled = YES;
    self.value.textColor = [UIColor blackColor];
    [self.loadingIndicator stopAnimating];
    if (self.stateArray.count) {
        self.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
        self.value.enabled = NO;

    } else {
        self.accessoryType =UITableViewCellAccessoryNone;
        self.value.enabled = YES;
    }
}

-(void) startStateUpdate:(NSString*) stateID {
    NSLog(@"%@",stateID);

    [self.loadingIndicator startAnimating];
    self.userInteractionEnabled = NO;
    self.value.textColor = [UIColor grayColor];
    type = STATE_TYPE;
    
 //   [self performSelectorInBackground:@selector(getStateByID:) withObject:stateID];

}


@end
