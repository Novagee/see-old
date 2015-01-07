//
//  SearchSuggestionTableView.h
//  ProTime
//
//  Created by Norayr on 03/22/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SuggestionTableViewDelegate;

@interface SearchSuggestionTableView : UITableView {
    id<SuggestionTableViewDelegate> __unsafe_unretained __delegate;

   
}

@property (nonatomic, assign) id<SuggestionTableViewDelegate> suggestionDelegate;
@property (nonatomic, retain) NSMutableArray *arrayList;

- (void) setSearchText:(NSString*)text;
- (void) ApplySearchText:(NSString*)text;
@end

@protocol SuggestionTableViewDelegate <NSObject>

@optional

- (void) didSelectSearchString:(SearchSuggestionTableView*)suggestionView Text:(NSString*)text;
- (void) didScrallTableView:(SearchSuggestionTableView*)suggestionView UIInterfaceOrientation:(UIInterfaceOrientation)orientation;
@end