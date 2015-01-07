//
//  BufferUIActivity.m
//  BufferUIActivity
//
//  Created by Andrew Yates on 14/06/2012.
//  Copyright (c) 2012 Buffer Inc. All rights reserved.
//

#import "BookmarkUIActivity.h"
#import "idoubs2AppDelegate.h"
#import "SeequNewMessageContactsViewController.h"

@interface BookmarkUIActivity () <NewMessageContactsDelegate> {
    Activity_Type type;
}

@end

@implementation BookmarkUIActivity

@synthesize bookmarkDelegate = _delegate;

- (id) initWithType:(Activity_Type)type_ {
    self = [super init];
    
    if (self) {
        type = type_;
    }
    
    return self;
}

- (NSString *)activityType {
    switch (type) {
        case Activity_Type_Bookmark:
            return @"Bookmark";
            break;
        case Activity_Type_Message:
            return @"Message";
            break;
        case Activity_Type_Forward:
            return @"Forward";
        default:
            break;
    }
    
    return nil;
}

- (NSString *)activityTitle {
    switch (type) {
        case Activity_Type_Bookmark:
            return @"Bookmark";
            break;
        case Activity_Type_Message:
            return @"Message";
            break;
        case Activity_Type_Forward:
            return @"Forward";
        default:
            break;
    }
    
    return nil;
}

- (UIImage *)activityImage {
    switch (type) {
        case Activity_Type_Bookmark:
            return [UIImage imageNamed:@"seequActivitybookmark.png"];
            break;
        case Activity_Type_Message:
        case Activity_Type_Forward:
            return [UIImage imageNamed:@"ActivityIcon.png"];
            break;
        default:
            break;
    }
    
    return nil;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems_ {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems_ {
//    activityItems = activityItems_;    
    switch (type) {
        case Activity_Type_Bookmark:
        case Activity_Type_Message:
          activityItems = [activityItems_ objectAtIndex:0];
            break;
        case Activity_Type_Forward:
            activityItems = activityItems_;           
            break;
        default:
            break;
    }

}

- (UIViewController *)activityViewController {
    switch (type) {
        case Activity_Type_Bookmark: {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *defaultPath = [documentsDirectory stringByAppendingPathComponent:@"Bookmarks"];
            
            SeequAddBookmarkViewController *vc = [[idoubs2AppDelegate sharedInstance].seequAddBookmark.viewControllers objectAtIndex:0];
            vc.addBookmarkDelegate = self;
            vc.defaultPath = defaultPath;
            vc.selectedPath = defaultPath;
            vc.activityItems = activityItems;
            vc.arrayEditBookMark = nil;
            vc.navTitle = @"Add Bookmark";
            return [idoubs2AppDelegate sharedInstance].seequAddBookmark;
        }
            break;
        case Activity_Type_Message: {
            SeequNewMessageContactsViewController *viewController = [[SeequNewMessageContactsViewController alloc] initWithNibName:@"SeequNewMessageContactsViewController" bundle:nil];
            viewController.seequContactsDelegate = self;
            
            return viewController;
        }
            break;
        case Activity_Type_Forward: {
            SeequNewMessageContactsViewController *viewController = [[SeequNewMessageContactsViewController alloc] initWithNibName:@"SeequNewMessageContactsViewController" bundle:nil];
            viewController.seequContactsDelegate = self;
            viewController.isFromForwardCalled = YES;

            return viewController;
        }

        default:
            break;
    }
    
    return nil;
}

- (void) didSelectContact:(SeequNewMessageContactsViewController*)controller Contact:(ContactObject*)contactObject {
        if (self.isfromSeequImagePicker) {
             [[idoubs2AppDelegate sharedInstance].tabBarController dismissViewControllerAnimated:YES completion:nil];   
        }
        
    [self activityDidFinish:YES];

    switch (type) {
        case Activity_Type_Message:{

            NSString *text = [activityItems objectAtIndex:1];
             //NSString *text = [[activityItems objectAtIndex:0] objectAtIndex:1];
            if(text && text.length > 0) {
                [idoubs2AppDelegate sharedInstance].messageFromActivity = YES;
                [idoubs2AppDelegate sharedInstance].messageFromActivityTo = contactObject.SeequID;
                [idoubs2AppDelegate sharedInstance].messageFromActivityText = [NSString stringWithFormat:@"%@ ", text];
                [idoubs2AppDelegate sharedInstance].messageNavigationTitle = contactObject.displayName;
                
                [[idoubs2AppDelegate sharedInstance].messages popToRootViewControllerAnimated:NO];
                [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 1;
            }

        }
            
            break;
        case Activity_Type_Forward:{
            ///@todo Toros  MUST  fix the workaround
           // UIImage*  image = (UIImage*) activityItems;//[activityItems objectAtIndex:0];
             UIImage*  image = [activityItems objectAtIndex:0];
                [idoubs2AppDelegate sharedInstance].messageFromActivity = YES;
                [idoubs2AppDelegate sharedInstance].messageFromActivityImage = image;

                [idoubs2AppDelegate sharedInstance].messageFromActivityTo = contactObject.SeequID;
               // [idoubs2AppDelegate sharedInstance].messageFromActivityI = [NSString stringWithFormat:@"%@ ", text];
                [idoubs2AppDelegate sharedInstance].messageNavigationTitle = contactObject.displayName;
            [[idoubs2AppDelegate sharedInstance].messages popToRootViewControllerAnimated:NO];
            [idoubs2AppDelegate sharedInstance].tabBarController.selectedIndex = 1;


        }
            break;
            
        default:
            break;
    }
    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView removeFromSuperview];
        [[idoubs2AppDelegate sharedInstance].window addSubview:[idoubs2AppDelegate sharedInstance].videoService.showVideoView];
    }

    
}

- (void)didFinishSeequAddBookmarkViewController:(SeequAddBookmarkViewController*)viewController {
    [self activityDidFinish:NO];
    if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
        [[idoubs2AppDelegate sharedInstance].videoService.showVideoView removeFromSuperview];
        [[idoubs2AppDelegate sharedInstance].window addSubview:[idoubs2AppDelegate sharedInstance].videoService.showVideoView];
    }
    

}

@end