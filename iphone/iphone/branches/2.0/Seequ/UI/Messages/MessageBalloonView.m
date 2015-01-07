//
//  MessageBaloonView.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 11/1/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import "MessageBalloonView.h"
@interface MessageBalloonView()
@property (nonatomic,retain) UIImageView* imageView;
@property (nonatomic,retain) UILabel* label;
@end

@implementation MessageBalloonView
@synthesize imageView = _imageView;
@synthesize label = _label;
- (id)initWithText:(NSString*)message
{
    NSAssert(message, @"Message must be predefined!");
    CGRect rect = CGRectMake(0, 0, 261, 61);
    
    self = [super initWithFrame:rect];
    if (self) {
        // Initialization code
        self.text =  message;
        [self createImageView];
    }
    return self;
}


-(void) createImageView{
// JSC
//    CGSize textSize = [self.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:13]
//                                                       constrainedToSize:CGSizeMake(self.frame.size.width -10, 1000)
//                                                           lineBreakMode:NSLineBreakByWordWrapping];
    
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:self.text
     attributes:@
     {
     NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:13]
     }];
    
    CGRect textRect = [attributedText boundingRectWithSize:CGSizeMake(self.frame.size.width -10, 1000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    CGFloat height = (textRect.size.height > 166)?191:textRect.size.height +30 ; // 166 = 191 - 25  insets for height;
    height = height< 61 ? 61:height;
    UIImage *myResizableImage = [[UIImage imageNamed:@"seequIncomingRequestBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25.0, 35, 35)];
    self.bounds = CGRectMake(0, 0, self.bounds.size.width,height);
    _imageView = [[UIImageView alloc] initWithImage:myResizableImage];
    _label = [[UILabel alloc] initWithFrame: CGRectMake(10, 20, self.bounds.size.width - 20, self.bounds.size.height -30)];
    [self.imageView addSubview:_label];
    _label.backgroundColor = [UIColor clearColor];
    _label.text = self.text;
    

    _label.numberOfLines = 0;
    _label.font =[UIFont fontWithName:@"HelveticaNeue" size:13];
    _label.textColor = [UIColor whiteColor];
    _imageView.frame = self.bounds;
    [self addSubview:_imageView];
}


-(void) layoutSubviews {
    
    [super layoutSubviews];
    NSLog(@"--------------%@",NSStringFromCGRect(self.frame));
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
