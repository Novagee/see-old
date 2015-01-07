//
//  MyApplication.m
//  ProTime
//
//  Created by Grigori Jlavyan on 2/13/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "MyApplication.h"
#import "idoubs2AppDelegate.h"
@implementation MyApplication
-(BOOL)openURL:(NSURL *)url
{
    NSURLRequest *request;
    NSString* scheme = [url.scheme lowercaseString];
    if([scheme compare:@"http"] == NSOrderedSame
       || [scheme compare:@"https"] == NSOrderedSame)
    {
        request=[[NSURLRequest alloc] initWithURL:url];
        [idoubs2AppDelegate sharedInstance].urlReq = request;
        [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex=2;
       
    }else{
        return [super openURL:url];
    }
    return NO;
    
}@end
