//
//  SeequContactConnectionsViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 9/28/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"

typedef enum Connection_Type {
	Connection_Type_All,
    Connection_Type_Common
}
Connection_Type;

@interface SeequContactConnectionsViewController : UIViewController {
    Connection_Type connectionType;

    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
    
    NSMutableArray *arrayContacts;
    NSMutableArray *sectionsArray;
}

@property (nonatomic, strong) ContactObject *contactObj;
@property (nonatomic, assign) int videoViewState;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollViewContent;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewSeequStatus;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelDisplayName;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelCompany;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelSpecialist;
@property (strong, nonatomic) IBOutlet UILabel *labelLocation;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonCommon;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonAll;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *MyTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *MySearchBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageViewContactOnlineStatus;
@property (strong, nonatomic) IBOutlet UIView *viewLoading;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *IndicatorView;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;
- (void) UpdateUI;
- (IBAction)onButtonFilter:(id)sender;
- (void) setRatingStars:(int)stars;
- (void) filterContactsWithSegment_Type:(Connection_Type)conn_Type;
- (void) GetContactConnections;
- (NSMutableArray*) configureSectionsWithArray:(NSArray*)array;
- (NSMutableArray*) CompareArraysWithArray:(NSMutableArray*)array;
- (void) ReplaceForMySeequContacts:(NSMutableArray*)array;
- (void) RefreshList;
- (NSMutableArray*) ArrayWithSearchText:(NSString*)text onArray:(NSArray*)base_array;

@end