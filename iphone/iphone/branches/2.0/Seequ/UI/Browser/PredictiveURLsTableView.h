//
//  PredictiveURLsTableView.h
//  ProTime
//
//  Created by Norayr on 04/26/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PredictiveURLsTableViewDelegate;

@interface PredictiveURLsTableView : UITableView {
    id<PredictiveURLsTableViewDelegate> __unsafe_unretained __delegate;
    
    NSMutableArray *arrayList;
   
}

@property (nonatomic, assign) id<PredictiveURLsTableViewDelegate> predictiveDelegate;

- (void) setBeginOfURL:(NSString*)url;
- (void) CheckURLinBookMarks:(NSString*)url;
- (NSString*) reduceUrl:(NSString*)url;
@end

@protocol PredictiveURLsTableViewDelegate <NSObject>

@optional

- (void) didSelectPredictiveURL:(PredictiveURLsTableView*)predictiveURLsTableView URL:(NSString*)urlstring Title:(NSString*)title_;
- (void) didScrallTableView:(PredictiveURLsTableView*)predictiveURLsTableView UIInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end