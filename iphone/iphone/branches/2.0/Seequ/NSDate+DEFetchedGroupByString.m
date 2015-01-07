//
//  NSString+FetchedGroupByString.m
//
//  Created by Grigori Jlavyan
//
@implementation NSDate (FetchedGroupByDate)


- (NSDate *)dateGroupBydays{
    
   return [NSDate getCapitalizeStartString:self];
}

+(NSDate *)getCapitalizeStartString:(NSDate *)date{

    // Specify which units we would like to use
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
//  2014-04-14 20:00:00 +0000
//  2014-04-16 06:14:33 +0000

    NSDateComponents *components = [calendar components:units fromDate:date];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *newDate = [calendar dateFromComponents: components];
    
    return newDate;
}

@end
