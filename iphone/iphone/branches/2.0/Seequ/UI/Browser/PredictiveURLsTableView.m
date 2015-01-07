//
//  PredictiveURLsTableView.m
//  ProTime
//
//  Created by Norayr on 04/26/13.
//  Copyright (c) 2013 BeInteractive. All rights reserved.
//

#import "PredictiveURLsTableView.h"
#import "config.h"

@implementation PredictiveURLsTableView

@synthesize predictiveDelegate = __delegate;

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

- (NSMutableArray*) CreateHistoryArray {
    NSMutableArray *arrayUnsorted = [[NSMutableArray alloc] init];
    NSMutableDictionary *mDict = [[NSUserDefaults standardUserDefaults] objectForKey:HISTORY_KEY];
    
    for (NSString *key in mDict) {
        NSDictionary *dict = [mDict objectForKey:key];
        [arrayUnsorted addObject:dict];
    }
    
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    NSArray *arraySorted = [arrayUnsorted sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    NSMutableArray *arrayReturn = [[NSMutableArray alloc] init];
    NSMutableArray *arrayTmp;
    int prev_day = 0;
    int today = (int)[[NSDate date] timeIntervalSince1970]/86400;
    
    for (NSDictionary *dict in arraySorted) {
        NSTimeInterval time = [[dict objectForKey:@"time"] doubleValue];
        
        int day = (int)(time/86400);
        
        if (day == today) {
            [arrayReturn addObject:dict];
            prev_day = day;
            
            continue;
        }
        
        if (day != prev_day) {
            arrayTmp = [[NSMutableArray alloc] init];
            [arrayTmp addObject:dict];
            [arrayReturn addObject:arrayTmp];
            prev_day = day;
        } else {
            [arrayTmp addObject:dict];
        }
    }
    
    return arrayReturn;
}

-(void) setBeginOfURL:(NSString*)url {
    if (!arrayList) {
        arrayList = [[NSMutableArray alloc] init];
    } else {
        [arrayList removeAllObjects];
    }
    
    [self CheckURLinBookMarks:url];
    NSMutableArray * suggestionFromHistoryArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *mDict = [[NSUserDefaults standardUserDefaults] objectForKey:HISTORY_KEY];
    for (NSString *key in mDict) {
        NSDictionary *dict = [mDict objectForKey:key];
        NSString * title = [dict objectForKey:@"title"];
        NSRange range = [title rangeOfString:url];
        if (range.location != NSNotFound) {
            [suggestionFromHistoryArray addObject:dict];
            continue;
        }
        NSString * link = [dict objectForKey:@"link"];
        range = [[self reduceUrl:link] rangeOfString:[self reduceUrl:url]];
        if (range.location != NSNotFound) {
            [suggestionFromHistoryArray addObject:dict];
        }
    }
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    NSMutableArray * sortedArrayList = [NSMutableArray arrayWithArray:[suggestionFromHistoryArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]]];
    
    suggestionFromHistoryArray = sortedArrayList;
    NSMutableArray * keyForRemovelArray =[[NSMutableArray alloc] init];
    int k = 0;
    for(int i = 0; i < [suggestionFromHistoryArray count]; i++){
        for(int j = 0; j < [suggestionFromHistoryArray count]; j++){
            if([[self reduceUrl:[suggestionFromHistoryArray [i] objectForKey:@"link"] ] isEqualToString:[self reduceUrl:[suggestionFromHistoryArray [j] objectForKey:@"link"]]]){
                if([suggestionFromHistoryArray[i] objectForKey:@"time"] > [suggestionFromHistoryArray[j] objectForKey:@"time"]){
                    NSNumber * number = [NSNumber numberWithInt:j];
                    keyForRemovelArray[k] = number;
                    k++;
                }
            }
        }
    }

    NSMutableArray* removeArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < [keyForRemovelArray count]; i++){
        if( [suggestionFromHistoryArray count] - 1 >= [keyForRemovelArray[i]integerValue]){
          [removeArray addObject:suggestionFromHistoryArray[[keyForRemovelArray[i]integerValue]]];
        }
    }
    
    [suggestionFromHistoryArray removeObjectsInArray:removeArray];
    
    for(int i = 0; i < [suggestionFromHistoryArray count]; i++){
        BOOL isEqual = NO;
        for(int j = 0; j < [arrayList count]; j++){
            if([[self reduceUrl:[suggestionFromHistoryArray [i] objectForKey:@"link"]] isEqualToString:[self reduceUrl:[arrayList[j] objectForKey:@"url"] ]]){
                isEqual = YES;
                break;
            }
        }
        if(!isEqual){
            [arrayList addObject:suggestionFromHistoryArray[i]];
        }
    }
    
    
    [self reloadData];
}

- (void) CheckURLinBookMarks:(NSString*)url {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *bookMarkPath = [documentsDirectory stringByAppendingPathComponent:@"Bookmarks"];
    
    NSMutableDictionary *mDictAllBookmarks = [[NSMutableDictionary alloc] init];
    NSFileManager *fM = [NSFileManager defaultManager];
    NSArray *folderList = [fM subpathsOfDirectoryAtPath:bookMarkPath  error:nil];
    for (NSString *folder in folderList) {
        NSString *path_ = [bookMarkPath stringByAppendingPathComponent:folder];
        BOOL isDir = NO;
        [fM fileExistsAtPath:path_ isDirectory:(&isDir)];
        if (!isDir) {
            NSArray *arrayOfPathComponents = [folder componentsSeparatedByString:@"/"];
            if ([[arrayOfPathComponents lastObject] isEqualToString:@"bookmarks.plist"]) {
                NSArray *array = [[NSArray alloc] initWithContentsOfFile:path_];
                NSMutableArray *arrayOfBookMarks = [[NSMutableArray alloc] initWithArray:array];
                
                for (NSDictionary *dict in arrayOfBookMarks) {
                    NSString *key = [NSString stringWithFormat:@"%@%@", [dict objectForKey:@"title"], [dict objectForKey:@"url"]];
                    [mDictAllBookmarks setObject:dict forKey:key];
                }
            }
        }
    }
   
    NSMutableArray* arrayForBookmarks = [[NSMutableArray alloc]init];
    for (NSString *key in mDictAllBookmarks) {
        NSDictionary *dict = [mDictAllBookmarks objectForKey:key];
        NSString *title = [dict objectForKey:@"title"];
        
        NSRange range = [title rangeOfString:url];
        if (range.location != NSNotFound) {
            [arrayForBookmarks addObject:dict];
            continue;
        }
        
        NSString *link = [dict objectForKey:@"url"];
       
        range = [[self reduceUrl:link] rangeOfString:[self reduceUrl:url]];
        if (range.location != NSNotFound) {
            [arrayForBookmarks addObject:dict];
            
        }
    }
    
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"url" ascending:YES];
    NSMutableArray* sortedArrayList = [NSMutableArray arrayWithArray:[arrayForBookmarks sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]]];
    [arrayList addObjectsFromArray: sortedArrayList];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return arrayList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifier%d", indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell...
    
    cell.imageView.image = nil;
    NSDictionary *dict = [arrayList objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"title"];
    
    NSString *link = [dict objectForKey:@"link"];
    
    if (!link) {
        link = [dict objectForKey:@"url"];
        cell.imageView.image = [UIImage imageNamed:@"bookmark.png"];
    }
    
    NSURL* url = [NSURL URLWithString:link];
    NSString* reducedUrl = nil;
    if(url.host){
        
        if([url.host rangeOfString:@"www."].location == NSNotFound){
            reducedUrl = [NSString stringWithFormat:@"%@%@", @"www.",[NSString stringWithFormat:@"%@", url.host]];
        }else{
            reducedUrl =  url.host;
        }
    }else{
        NSArray* splitedStringArray = [link componentsSeparatedByString: @"/"];
        if([splitedStringArray count] >= 1){
            reducedUrl = splitedStringArray[0];
        }else{
            reducedUrl = link;
        }
    }
       cell.detailTextLabel.text = reducedUrl;

    return cell;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [arrayList objectAtIndex:indexPath.row];
    NSString *title = [dict objectForKey:@"title"];
    NSString *link = [dict objectForKey:@"link"];
    if (!link) {
        link = [dict objectForKey:@"url"];
    }
    
    if ([__delegate respondsToSelector:@selector(didSelectPredictiveURL:URL:Title:)]) {
        [__delegate didSelectPredictiveURL:self URL:link Title:title];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self removeFromSuperview];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView; {
    if ([__delegate respondsToSelector:@selector(didScrallTableView:UIInterfaceOrientation:)]) {
        [__delegate didScrallTableView:self UIInterfaceOrientation:UIDeviceOrientationUnknown];
    }
}
- (NSString*)reduceUrl:(NSString*)url
{
    NSString* reducedUrlWithoutHttp;
    NSArray* reducedUrlWithoutHttpArray;
    NSString* reducedUrlWithoutWww;
    NSArray* reducedUrlWithoutWwwArray;
    reducedUrlWithoutHttpArray = [url componentsSeparatedByString:@"://"];
    if([reducedUrlWithoutHttpArray count] >= 2){
        reducedUrlWithoutHttp = reducedUrlWithoutHttpArray[1];
    }else{
        reducedUrlWithoutHttp = url;
    }
    if([reducedUrlWithoutHttp rangeOfString:@"www."].location != NSNotFound){
        reducedUrlWithoutWwwArray = [reducedUrlWithoutHttp componentsSeparatedByString:@"www."];
        if([reducedUrlWithoutWwwArray count] >= 2){
            reducedUrlWithoutWww = reducedUrlWithoutWwwArray[1];
        }
    }else {
        reducedUrlWithoutWww = reducedUrlWithoutHttp;
    }
    return reducedUrlWithoutWww;
    
}
@end