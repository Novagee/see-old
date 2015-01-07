//
//  SeequNewMessageViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 12/4/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequNewMessageContactsViewController.h"


@protocol NewMessageDelegate;


@interface SeequNewMessageViewController : UIViewController <NewMessageContactsDelegate> {
    id<NewMessageDelegate> __unsafe_unretained _delegate;

    ContactObject *selectedContactObject;

    NSMutableArray *arrayContacts;
    NSMutableArray *arrayFinish;
}

@property (nonatomic, assign) id<NewMessageDelegate> seequNewMessageDelegate;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *viewSendMessage;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textFieldSendMessage;
@property (strong, nonatomic) IBOutlet UITextField *textFieldContact;
@property (strong, nonatomic) IBOutlet UILabel *labelContact;
@property (strong, nonatomic) IBOutlet UITableView *MyTableView;
@property (strong, nonatomic) IBOutlet UIButton *buttonSendMessage;


- (IBAction)onButtonCancel:(id)sender;
- (IBAction)onButtonAdd:(id)sender;
- (IBAction)onButtonSend:(id)sender;

- (NSMutableArray*) ArrayWithSearchText:(NSString*)text;

@end

@protocol NewMessageDelegate <NSObject>

- (void) didSendMessage:(SeequNewMessageViewController*)controller Contact:(ContactObject*)contactObject;

@end