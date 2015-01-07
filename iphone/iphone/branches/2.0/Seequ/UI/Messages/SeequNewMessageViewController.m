//
//  SeequNewMessageViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 12/4/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "SeequNewMessageViewController.h"
#import "idoubs2AppDelegate.h"


@interface SeequNewMessageViewController ()

@end

@implementation SeequNewMessageViewController


@synthesize seequNewMessageDelegate = _delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        selectedContactObject = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(TextFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:nil];
        
        UINavigationController *nav = [[idoubs2AppDelegate sharedInstance].tabBarController.viewControllers objectAtIndex:0];
        SeequContactsViewController *contactsViewController = (SeequContactsViewController*)[nav.viewControllers objectAtIndex:0];
        arrayContacts = [contactsViewController GetContactList];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.textFieldContact becomeFirstResponder];
    self.viewSendMessage.center = CGPointMake(160, self.view.frame.size.height - 240);
    
     [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setViewSendMessage:nil];
    [self setTextFieldSendMessage:nil];
    [self setTextFieldContact:nil];
    [self setMyTableView:nil];
    [self setButtonSendMessage:nil];
    [self setLabelContact:nil];
    [super viewDidUnload];
}
- (IBAction)onButtonCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onButtonAdd:(id)sender {
    SeequNewMessageContactsViewController *newMessageContactsViewController = [[SeequNewMessageContactsViewController alloc] initWithNibName:@"SeequNewMessageContactsViewController" bundle:nil];
    newMessageContactsViewController.seequContactsDelegate = self;
    [self presentViewController:newMessageContactsViewController animated:YES completion:nil];
}

- (IBAction)onButtonSend:(id)sender {
    if ([[idoubs2AppDelegate sharedInstance] checkNetworkStatus]) {
        if (selectedContactObject) {
            [self SendTextMessage:self.textFieldSendMessage.text];
            self.textFieldSendMessage.text = @"";
            
            if ([_delegate respondsToSelector:@selector(didSendMessage:Contact:)]) {
                [_delegate didSendMessage:self Contact:selectedContactObject];
            }
        } else {
            [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"You must choose seequ contact."];
        }
    } else {
        [[idoubs2AppDelegate sharedInstance] ShowDefaultMessageWithText:@"The network connection appears to be down. Try it after connection reset."];
    }
}

- (void) SendTextMessage:(NSString*)text {
    if(text.length > 0) {
        NSString *Message_ID = MESSAGE_ID;
        [[idoubs2AppDelegate getChatManager] SendTextMessage:text to:selectedContactObject.SeequID MessageID:Message_ID AddToResendList:YES];
        
//        NSTimeInterval date = [[NSDate date] timeIntervalSince1970];
//        
//        NSDictionary *dictHistory = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                     text,@"text",
//                                     @"me",@"from",
//                                     [NSNumber numberWithDouble:date], @"date",
//                                     Message_ID, @"Message_ID",
//                                     @"NO", @"delivered", nil];
        
//        [Common addChatOnThisContactHistory:dictHistory _userId:selectedContactObject.SeequID];
    }
}

#pragma mark UITextField Delegate

- (void)TextFieldDidChange:(NSNotification *)notification {
    if (notification.object == self.textFieldContact) {
        if (self.textFieldContact.hidden) {
            self.labelContact.hidden = YES;
            self.textFieldContact.hidden = NO;
            self.textFieldContact.text = [self.textFieldContact.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        selectedContactObject = nil;
        if (self.textFieldContact && self.textFieldContact.text && [self.textFieldContact.text length]) {
            arrayFinish = [self ArrayWithSearchText:self.textFieldContact.text];
            self.MyTableView.hidden = NO;
            self.viewSendMessage.hidden = YES;
        } else {
            arrayFinish = nil;
            self.MyTableView.hidden = YES;
            self.viewSendMessage.hidden = NO;
        }
        
        [self.MyTableView reloadData];
    } else {
        if (self.textFieldSendMessage.text.length) {
            [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSend.png"] forState:UIControlStateNormal];
        } else {
            [self.buttonSendMessage setBackgroundImage:[UIImage imageNamed:@"SeequButtonMessageSendInactive.png"] forState:UIControlStateNormal];
        }
    }
}

- (NSMutableArray*) ArrayWithSearchText:(NSString*)text {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (text && [text length]) {
        for (ContactObject *obj in arrayContacts) {
            NSString *displayName = [obj.displayName stringByReplacingOccurrencesOfString:@" " withString:@""];

            NSComparisonResult result = [displayName compare:text options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [text length])];
            if (result == NSOrderedSame) {
                [array addObject:obj];
                
                continue;
            }
            
            result = [obj.FirstName compare:text options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [text length])];
            if (result == NSOrderedSame) {
                [array addObject:obj];
                
                continue;
            }
            
            result = [obj.LastName compare:text options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [text length])];
            if (result == NSOrderedSame) {
                [array addObject:obj];
            }
        }
    }
    
    return array;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (arrayFinish) {
        return arrayFinish.count;
    }
    
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    //    ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //    if (cell == nil) {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //    }
    
    // Set up the cell...
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    ContactObject *contactObject = [arrayFinish objectAtIndex:indexPath.row];
    
    cell.textLabel.text = contactObject.displayName;
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:15]];
    cell.detailTextLabel.text = contactObject.specialist;
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:13]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactObject *contactObject = [arrayFinish objectAtIndex:indexPath.row];
    selectedContactObject = contactObject;
    tableView.hidden = YES;
    self.viewSendMessage.hidden = NO;
    [self.textFieldSendMessage becomeFirstResponder];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.labelContact.hidden = NO;
    self.labelContact.text = [NSString stringWithFormat:@"  %@  ", selectedContactObject.displayName];
    CGSize textSize = [self.labelContact.text sizeWithFont:self.labelContact.font
                          constrainedToSize:CGSizeMake(5000, FLT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
    self.labelContact.frame = CGRectMake(self.labelContact.frame.origin.x, self.labelContact.frame.origin.y, textSize.width, self.labelContact.frame.size.height);
    self.labelContact.layer.cornerRadius = 13;
    self.labelContact.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"seequNavigationDefaultBG.png"]];
    self.textFieldContact.hidden = YES;
    self.textFieldContact.text = @" ";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchedPoin = [[touches anyObject]  locationInView:self.view];
    
    if (CGRectContainsPoint(self.labelContact.frame, touchedPoin) && !self.labelContact.hidden) {
        self.labelContact.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"seequNavigationDefaultGreenBG.png"]];
        [self.textFieldContact becomeFirstResponder];
    }
}

#pragma mark SeequNewMessageContactsViewController Delegate

- (void) didSelectContact:(SeequNewMessageContactsViewController *)controller Contact:(ContactObject *)contactObject {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    selectedContactObject = contactObject;
    self.MyTableView.hidden = YES;
    self.viewSendMessage.hidden = NO;
    [self.textFieldSendMessage becomeFirstResponder];
    
    self.labelContact.hidden = NO;
    self.labelContact.text = [NSString stringWithFormat:@"  %@  ", selectedContactObject.displayName];
    CGSize textSize = [self.labelContact.text sizeWithFont:self.labelContact.font
                                         constrainedToSize:CGSizeMake(5000, FLT_MAX)
                                             lineBreakMode:NSLineBreakByWordWrapping];
    self.labelContact.frame = CGRectMake(self.labelContact.frame.origin.x, self.labelContact.frame.origin.y, textSize.width, self.labelContact.frame.size.height);
    self.labelContact.layer.cornerRadius = 13;
    self.labelContact.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"seequNavigationDefaultBG.png"]];
    self.textFieldContact.hidden = YES;
    self.textFieldContact.text = @" ";
}

@end