//
//  SeequSearchViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/2/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeequSortViewController.h"
#import "SeequBadgesViewController.h"


typedef enum Search_Type {
	Search_Type_People,
    Search_Type_Topics
}
Search_Type;

@interface SeequSearchViewController : UIViewController <SeequSortViewControllerDelegate, SeequBadgesViewControllerDelegate> {
    Search_Type searchType;
    
    NSMutableArray *arrayBadges;
    NSMutableArray *arraySelectedBadges;
    NSMutableArray *arrayBadgeItems;
    
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, assign) int videoViewState;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollViewContent;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonTopics;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *buttonPeople;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textFieldSearch;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelSortType;
@property (nonatomic, strong) NSString *searchTextDefault;


- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (IBAction)onButtonFilter:(id)sender;
- (IBAction)onButtonSearch:(id)sender;
- (IBAction)onButtonSort:(id)sender;
- (IBAction)onButtonSearchBadge:(id)sender;
- (IBAction)onButtonResetSearch:(id)sender;


@end