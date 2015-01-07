//
//  seequUIActivityItemProvider.m
//  ProTime
//
//  Created by Toros Torosyan on 3/10/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "seequUIActivityItemProvider.h"


@implementation seequUIActivityItemProvider
@synthesize url;
@synthesize text;
@synthesize bookmarkActivity;

- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    if ( [activityType isEqualToString:UIActivityTypeCopyToPasteboard] )
        return url ;
    if ( [activityType isEqualToString:UIActivityTypeMessage] ){
       
        return [NSString stringWithFormat:@"%@ %@", text, url];
    }
    if ( [activityType isEqualToString:UIActivityTypeMail] ){
        
        return [NSString stringWithFormat:@"%@ %@", text, url];
    }
    if ( [activityType isEqualToString:@"Bookmark"] ){
        return [NSArray arrayWithObjects:text,url, nil];
    }
    
    if ( [activityType isEqualToString:@"Message"] ){
        
        return [NSArray arrayWithObjects:text,url, nil];
    }
    return nil;
}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }
@end
