//
//  NSString+FetchedGroupByString.m
//
//  Created by Grigori Jlavyan
//
@implementation NSString (FetchedGroupByString)

static NSMutableSet* alphabet;
- (NSString *)stringGroupByFirstInitial
{
    return [NSString getCapitalizeStartString:self];
}
- (NSString *)stringGroupForFavorite
{
    return [NSString getFavoriteSection:self];
}

- (NSString *)pathGroupBy
{
    NSArray *paths=[self pathComponents];
    NSString *path;
    
    if(paths.count>0)
        path=[paths objectAtIndex:0];
    return path;
}

#pragma mark - Private

+(NSString *)getFavoriteSection:(NSString *)string
{
    return @" ";
}

+(NSString *)getCapitalizeStartString:(NSString *)string
{
    if (!alphabet) {
        alphabet = [[NSMutableSet alloc] init];
        for (char a = 'A'; a <= 'Z'; a++)
        {
            [alphabet  addObject:[NSString stringWithFormat:@"%c", a]];
        }
    }
    //
    switch (string.length)
    {
        case 0:
            return @"";
            break;
        default:{
            if ([alphabet containsObject:[[string substringToIndex:1] uppercaseString]] ) {
                return [[string substringToIndex:1] uppercaseString];
            } else {
                return @" ";
            }
        }
            break;
    } 
}
@end
