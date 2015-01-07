//
//  SearchSuggestionTableView.m
//  ProTime
//
//  Created by Norayr on 03/22/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import "SearchSuggestionTableView.h"

@implementation SearchSuggestionTableView
@synthesize  arrayList = _arrayList;

@synthesize suggestionDelegate = __delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setDataSource:(id)self];
        [self setDelegate:(id)self];
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _arrayList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    NSString *text = [_arrayList objectAtIndex:indexPath.row];
    cell.textLabel.text = text;
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [_arrayList objectAtIndex:indexPath.row];
    [self setSearchText:text];
    
    if ([__delegate respondsToSelector:@selector(didSelectSearchString:Text:)]) {
        [__delegate didSelectSearchString:self Text:text];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView; {
    if ([__delegate respondsToSelector:@selector(didScrallTableView:UIInterfaceOrientation:)]) {
        [__delegate didScrallTableView:self UIInterfaceOrientation:UIDeviceOrientationUnknown];
    }
}

- (void) setSearchText:(NSString*)text {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(ApplySearchText:) withObject:text afterDelay:0.5];
}

- (void) ApplySearchText:(NSString*)text {
    NSLog(@"ApplySearchText");

    NSString *string_utl = [NSString stringWithFormat:@"http://api.bing.com/osjson.aspx?query=%@", text];
    string_utl = [string_utl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:string_utl]];
    NSString *alldata = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    NSLog(@"alldata == %@", alldata);
    
    NSArray *array = [self parseSuggestion:alldata];
    
    NSMutableArray *marray = [[NSMutableArray alloc] initWithArray:array];
    [marray removeObjectAtIndex:0];
    
    self.arrayList = marray;
    [self reloadData]; 
}

- (NSArray*) parseSuggestion:(NSString*)text {
    text = [text stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"]" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"[" withString:@""];
    
    return [text componentsSeparatedByString:@","];
}

- (NSMutableArray*) arrayList {
    
    return _arrayList;
}

@end