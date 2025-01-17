#import "XMPPDateTimeProfiles.h"

#if TARGET_OS_IPHONE
  #import "DDXML.h"
#endif

@interface XMPPDateTimeProfiles (PrivateAPI)
+ (NSDate *)parseDateTime:(NSString *)dateTimeStr withMandatoryTimeZone:(BOOL)mandatoryTZ;
@end


@implementation XMPPDateTimeProfiles

/**
 * The following acronyms and characters are used from XEP-0082 to represent time-related concepts:
 * 
 * CCYY	four-digit year portion of Date
 * MM	two-digit month portion of Date
 * DD	two-digit day portion of Date
 * -	ISO 8601 separator among Date portions
 * T	ISO 8601 separator between Date and Time
 * hh	two-digit hour portion of Time (00 through 23)
 * mm	two-digit minutes portion of Time (00 through 59)
 * ss	two-digit seconds portion of Time (00 through 59)
 * :	ISO 8601 separator among Time portions
 * .	ISO 8601 separator between seconds and milliseconds
 * sss	fractional second addendum to Time (MAY contain any number of digits)
 * TZD	Time Zone Definition (either "Z" for UTC or "(+|-)hh:mm" for a specific time zone)
 *
**/

+ (NSDate *)parseDate:(NSString *)dateStr
{
	if ([dateStr length] < 10) return nil;
	
	// The Date profile defines a date without including the time of day.
	// The lexical representation is as follows:
	// 
	// CCYY-MM-DD
	// 
	// Example:
	// 
	// 1776-07-04
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setFormatterBehavior:NSDateFormatterBehavior10_4]; // Use unicode patterns (as opposed to 10_3)
	[df setDateFormat:@"yyyy-MM-dd"];
	
	NSDate *result = [df dateFromString:dateStr];
	

	return result;
}

+ (NSDate *)parseTime:(NSString *)timeStr
{
	// The Time profile is used to specify an instant of time that recurs (e.g., every day).
	// The lexical representation is as follows:
	// 
	// hh:mm:ss[.sss][TZD]
	// 
	// The Time Zone Definition is optional; if included, it MUST be either UTC (denoted by addition
	// of the character 'Z' to the end of the string) or some offset from UTC (denoted by addition
	// of '[+|-]' and 'hh:mm' to the end of the string).
	// 
	// Examples:
	// 
	// 16:00:00
	// 16:00:00Z
	// 16:00:00+07:00
	// 16:00:00.123
	// 16:00:00.123Z
	// 16:00:00.123+07:00
	
	
	// Extract the current day so the result can be on the current day.
	// Why do we bother doing this?
	// 
	// First, it is rather intuitive.
	// Second, if we don't we risk being on a date with a conflicting DST (daylight saving time).
	// 
	// For example, -0800 instead of the current -0700.
	// This can be rather confusing when printing the result.
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setFormatterBehavior:NSDateFormatterBehavior10_4]; // Use unicode patterns (as opposed to 10_3)
	[df setDateFormat:@"yyyy-MM-dd"];
	
	NSString *today = [df stringFromDate:[NSDate date]];

    
	NSString *dateTimeStr = [NSString stringWithFormat:@"%@T%@", today, timeStr];
	
	return [self parseDateTime:dateTimeStr withMandatoryTimeZone:NO];
}

+ (NSDate *)parseDateTime:(NSString *)dateTimeStr
{
	// The DateTime profile is used to specify a non-recurring moment in time to an accuracy of seconds (or,
	// optionally, fractions of a second). The format is as follows:
	// 
	// CCYY-MM-DDThh:mm:ss[.sss]TZD
	// 
	// The Time Zone Definition is mandatory and MUST be either UTC (denoted by addition of the character 'Z'
	// to the end of the string) or some offset from UTC (denoted by addition of '[+|-]' and 'hh:mm' to the
	// end of the string).
	// 
	// Examples:
	// 
	// 1969-07-21T02:56:15Z
	// 1969-07-20T21:56:15-05:00
	// 1969-07-21T02:56:15.123Z
	// 1969-07-20T21:56:15.123-05:00
	
	return [self parseDateTime:dateTimeStr withMandatoryTimeZone:YES];
}

+ (NSDate *)parseDateTime:(NSString *)dateTimeStr withMandatoryTimeZone:(BOOL)mandatoryTZ
{
	if ([dateTimeStr length] < 19) return nil;
	
	// The DateTime profile is used to specify a non-recurring moment in time to an accuracy of seconds (or,
	// optionally, fractions of a second). The format is as follows:
	// 
	// CCYY-MM-DDThh:mm:ss[.sss]{TZD}
	// 
	// Examples:
	// 
	// 1969-07-21T02:56:15
	// 1969-07-21T02:56:15Z
	// 1969-07-20T21:56:15-05:00
	// 1969-07-21T02:56:15.123
	// 1969-07-21T02:56:15.123Z
	// 1969-07-20T21:56:15.123-05:00
	
	BOOL hasMilliseconds = NO;
	BOOL hasTimeZoneInfo = NO;
	BOOL hasTimeZoneOffset = NO;
	
	if ([dateTimeStr length] > 19)
	{
		unichar c = [dateTimeStr characterAtIndex:19];
		
		// Check for optional milliseconds
		if (c == '.')
		{
			hasMilliseconds = YES;
			
			if ([dateTimeStr length] < 23) return nil;
			
			if ([dateTimeStr length] > 23)
			{
				c = [dateTimeStr characterAtIndex:23];
			}
		}
		
		// Check for optional time zone info
		if (c == 'Z')
		{
			hasTimeZoneInfo = YES;
			hasTimeZoneOffset = NO;
		}
		else if (c == '+' || c == '-')
		{
			hasTimeZoneInfo = YES;
			hasTimeZoneOffset = YES;
			
			if (hasMilliseconds)
			{
				if ([dateTimeStr length] < 29) return nil;
			}
			else
			{
				if ([dateTimeStr length] < 25) return nil;
			}
		}
	}
	
	if (mandatoryTZ && !hasTimeZoneInfo) return nil;
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setFormatterBehavior:NSDateFormatterBehavior10_4]; // Use unicode patterns (as opposed to 10_3)
	
	if (hasMilliseconds)
	{
		if (hasTimeZoneInfo)
		{
			if (hasTimeZoneOffset)
				[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"]; // Offset calculated separately
			else
				[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
		}
		else
		{
			[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
		}
	}
	else if (hasTimeZoneInfo)
	{
		if (hasTimeZoneOffset)
			[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"]; // Offset calculated separately
		else
			[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	}
	else
	{
		[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
	}
	
	NSDate *result;
	
	if (hasTimeZoneInfo && !hasTimeZoneOffset)
	{
		// The NSDateFormatter will return the proper date, but it will be in our own time zone.
		
		NSDate *utcDate = [df dateFromString:dateTimeStr];
		
		NSTimeInterval localTZO = [[NSTimeZone systemTimeZone] secondsFromGMT];
		
		result = [utcDate dateByAddingTimeInterval:localTZO];
	}
	else if (hasTimeZoneInfo && hasTimeZoneOffset)
	{
		NSString *subStr1;
		NSString *subStr2;
		
		if (hasMilliseconds)
		{
			subStr1 = [dateTimeStr substringToIndex:23];
			subStr2 = [dateTimeStr substringFromIndex:23];
		}
		else
		{
			subStr1 = [dateTimeStr substringToIndex:19];
			subStr2 = [dateTimeStr substringFromIndex:19];
		}
		
		NSDate *timeInLocalTZO = [df dateFromString:subStr1];
		
		NSTimeInterval remoteTZO = [self parseTimeZoneOffset:subStr2];
		NSTimeInterval localTZO  = [[NSTimeZone systemTimeZone] secondsFromGMT];
		
		NSTimeInterval tzoDiff = localTZO - remoteTZO;
		
		result = [timeInLocalTZO dateByAddingTimeInterval:tzoDiff];
	}
	else
	{
		result = [df dateFromString:dateTimeStr];
	}
	

	return result;
}

+ (NSTimeInterval)parseTimeZoneOffset:(NSString *)tzo
{
	NSDateFormatter *df= [[NSDateFormatter alloc] init];
	[df setFormatterBehavior:NSDateFormatterBehavior10_4]; // Use unicode patterns (as opposed to 10_3)
	[df setDateFormat:@"yyyy-MM-dd'T'HH:mm"];
	
	// The tzo value is supposed to start with '+' or '-'.
	// Spec says: (+-)HH:mm
	
	NSString *tzoSubStr = [tzo length] > 1 ? [tzo substringFromIndex:1] : nil;
	
	NSString *str1 = [NSString stringWithFormat:@"1982-05-20T00:00"];
	NSString *str2 = [NSString stringWithFormat:@"1982-05-20T%@", tzoSubStr];
	
	NSDate *date1 = [df dateFromString:str1];
	NSDate *date2 = [df dateFromString:str2];
	
	NSTimeInterval result = 0;
	
	if (date1 && date2)
	{
		result = [date2 timeIntervalSinceDate:date1];
	}
	
	if ([tzo hasPrefix:@"-"])
	{
		result = -1 * result;
	}
	

	return result;
}

@end
