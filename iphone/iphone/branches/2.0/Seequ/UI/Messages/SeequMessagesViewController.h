//
//  SeequMessagesViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/19/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"
#import "SeequNewMessageViewController.h"
#import "SeequNewMessageContactsViewController.h"
#import "SeequSendMessageViewController.h"
#import "SearchBarWithCallButton.h"

@interface SeequMessagesViewController : UIViewController <ContactObjectDelegate, NewMessageDelegate, NewMessageContactsDelegate, SearchBarDelegate> {
    NSMutableArray *arrayContacts;
    NSMutableArray *arrayFinish;
    NSMutableArray *arraySearch;
    
    int videoViewState;
    int call_type;
    UIView *viewSuper;
    
    SearchBarWithCallButton *SearchBar;
}

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *MyTableView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonEdit;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewTitle;
@property (strong, nonatomic) IBOutlet UIButton *buttonNewMessage;


- (void) setVideoViewState:(int)state Animated:(BOOL)animated;
- (void) onCallStateChange:(NSNotification*)notification;

- (IBAction) onButtonEdit:(id)sender;
//- (IBAction) onButtonVideo:(id)sender;
- (void) onContactObjectImage:(NSNotification*)notification;
- (IBAction) onButtonNewMessage:(id)sender;
- (void) creatmessagesTable;
- (NSMutableArray*) ArrayWithSearchText:(NSString*)text;
- (void) UpdateEditButtonState:(id)sender;
- (void) UpdateInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end