//
//  IncomingRequestView.h
//  ProTime
//
//  Created by Norayr on 02/07/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"

@protocol IncomingRequestViewDelegate;

typedef enum IncomingRequest_Type {
	IncomingRequest_Type_Message,
    IncomingRequest_Type_RingBack,
    IncomingRequest_Type_Review,
    IncomingRequest_Type_Connection
}
IncomingRequest_Type;

@interface IncomingRequestView : UIButton {
//    id<IncomingRequestViewDelegate> __weak _delegate;
    UILabel *labelMessage;
    
}

@property (nonatomic, assign) id<IncomingRequestViewDelegate> delegate;
@property (nonatomic, strong) ContactObject *contactObject;
@property (nonatomic, assign) IncomingRequest_Type incomingRequestType;

- (id) initWithContactObject:(ContactObject*)object Message:(NSString*)message Target:(id)target IncomingRequestType:(IncomingRequest_Type)type Small:(BOOL)small;
- (void) SelfClick;

@end

@protocol IncomingRequestViewDelegate <NSObject>

@optional

- (void) didClickOnIncomingRequestView:(IncomingRequestView*)requestView;

@end