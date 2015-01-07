//
//  BufferUIActivity.h
//  BufferUIActivity
//
//  Created by Andrew Yates on 14/06/2012.
//  Copyright (c) 2012 Buffer Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequAddBookmarkViewController.h"


typedef enum Activity_Type {
	Activity_Type_NON,
    Activity_Type_Bookmark,
    Activity_Type_Message,
    Activity_Type_Forward
}
Activity_Type;


@protocol BookmarkUIActivityDelegate;

@interface BookmarkUIActivity : UIActivity <AddBookmarkDelegate> {
    id<BookmarkUIActivityDelegate> __weak __delegate;
    
    NSArray *activityItems;
}

@property (nonatomic, assign) id<BookmarkUIActivityDelegate> bookmarkDelegate;
@property (nonatomic) BOOL isfromSeequImagePicker;

- (id) initWithType:(Activity_Type)type_;

@end

@protocol BookmarkUIActivityDelegate <NSObject>

@optional

- (void) didClickBookmark:(BookmarkUIActivity*)bookmarkUIActivity Bookmark:(NSArray*)bookmark;

@end