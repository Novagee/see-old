//
//  SeequDropboxActivity.m
//  ProTime
//
//  Created by Grigori Jlavyan on 7/28/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequDropboxActivity.h"
#import "idoubs2AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>

@interface SeequDropboxActivity()
@end

@implementation SeequDropboxActivity


- (NSString *)activityType {
        return @"Forward";
}
- (NSString *)activityTitle {
        return @"Dropbox";
}
- (UIImage *)activityImage {
        return [UIImage imageNamed:@"SeequDropboxActivityIcon.png"];
        
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
        return YES;
};
//- (void)prepareWithActivityItems:(NSArray *)activityItems {
//        NSMutableArray *urlItems = [NSMutableArray arrayWithCapacity:[activityItems count]];
//        for (id object in activityItems) {
//                if ([object isKindOfClass:[NSURL class]]) {
//                        [urlItems addObject:object];
//                }
//        }
//        self.activityItems = activityItems;
//}
- (UIViewController *)activityViewController {
        SeequDropboxViewController *dropBoxViewController=[[SeequDropboxViewController alloc]init];
        dropBoxViewController.delegate=self;
        dropBoxViewController.activityArray=self.activityItems;
        dropBoxViewController.isfromSeequImagePicker=self.isfromSeequImagePicker;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dropBoxViewController];

        return navigationController;
}
#pragma mark - SeequDropboxViewController delegate methods

-(void)dropboxViewControllerDidCancel:(SeequDropboxViewController *)viewController{
        self.activityItems = nil;
        [self activityDidFinish:NO];
}

@end
