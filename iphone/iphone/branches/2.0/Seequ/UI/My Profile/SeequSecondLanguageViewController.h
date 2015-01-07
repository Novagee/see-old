//
//  SeequSecondLanguageViewController.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 10/8/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SeequSecondLanguageViewControllerDelegate;

@interface SeequSecondLanguageViewController : UIViewController {
//    id<SeequSecondLanguageViewControllerDelegate> __weak _delegate;

    NSMutableArray *arrayCountrys;
    NSIndexPath *prevIndexPath;
    NSString *navigationTitle;
    
    int videoViewState;
    UIInterfaceOrientation Video_InterfaceOrientation;
}

@property (nonatomic, assign) int videoViewState;

@property (nonatomic, assign) id<SeequSecondLanguageViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITableView *MyTableView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *labelNavigationTitle;
@property (nonatomic, strong) NSString *navigationTitle;
@property (nonatomic, strong) NSString *selectedLanguage;
@property (nonatomic, assign) BOOL showNoneField;
@property (nonatomic, assign) int currentIndex;

- (void) setVideoViewState:(int)state Animated:(BOOL)animated;

- (IBAction)onButtonCancel:(id)sender;

@end

@protocol SeequSecondLanguageViewControllerDelegate <NSObject>

@optional

- (void) didChooseLanguage:(SeequSecondLanguageViewController*)secondLanguageViewController withLanguage:(NSString*)language;

@end