//
//  SeequTimeZoneInfo.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 12/24/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import "SeequTimeZoneInfo.h"




/**
 "-12.0">(GMT -12:00) Eniwetok, Kwajalein</option>
 "-11.0">(GMT -11:00) Midway Island, Samoa</option>
 "-10.0">(GMT -10:00) Hawaii</option>
 "-9.0">(GMT -9:00) Alaska</option>
 "-8.0">(GMT -8:00) Pacific Time (US &amp; Canada)</option>
 "-7.0">(GMT -7:00) Mountain Time (US &amp; Canada)</option>
 "-6.0">(GMT -6:00) Central Time (US &amp; Canada), Mexico City</option>
 "-5.0">(GMT -5:00) Eastern Time (US &amp; Canada), Bogota, Lima</option>
 "-4.0">(GMT -4:00) Atlantic Time (Canada), Caracas, La Paz</option>
 "-3.5">(GMT -3:30) Newfoundland</option>
 "-3.0">(GMT -3:00) Brazil, Buenos Aires, Georgetown</option>
 "-2.0">(GMT -2:00) Mid-Atlantic</option>
 "-1.0">(GMT -1:00 hour) Azores, Cape Verde Islands</option>
 "0.0">(GMT) Western Europe Time, London, Lisbon, Casablanca</option>
 "1.0">(GMT +1:00 hour) Brussels, Copenhagen, Madrid, Paris</option>
 "2.0">(GMT +2:00) Kaliningrad, South Africa</option>
 "3.0">(GMT +3:00) Baghdad, Riyadh, Moscow, St. Petersburg</option>
 "3.5">(GMT +3:30) Tehran</option>
 "4.0">(GMT +4:00) Yerevan, Abu Dhabi, Muscat, Tbilisi</option>
 "4.5">(GMT +4:30) Kabul</option>
 "5.0">(GMT +5:00) Ekaterinburg, Islamabad, Karachi, Tashkent</option>
 "5.5">(GMT +5:30) Bombay, Calcutta, Madras, New Delhi</option>
 "5.75">(GMT +5:45) Kathmandu</option>
 "6.0">(GMT +6:00) Almaty, Dhaka, Colombo</option>
 "7.0">(GMT +7:00) Bangkok, Hanoi, Jakarta</option>
 "8.0">(GMT +8:00) Beijing, Perth, Singapore, Hong Kong</option>
 "9.0">(GMT +9:00) Tokyo, Seoul, Osaka, Sapporo, Yakutsk</option>
 "9.5">(GMT +9:30) Adelaide, Darwin</option>
 "10.0">(GMT +10:00) Eastern Australia, Guam, Vladivostok</option>
 "11.0">(GMT +11:00) Magadan, Solomon Islands, New Caledonia</option>
 "12.0">(GMT +12:00) Auckland, Wellington, Fiji, Kamchatka</option>
 */




static NSArray*  keys = nil;
static NSArray* values = nil;
static NSArray* cities = nil;
static NSMutableArray* timeZones = nil;

@implementation SeequTimeZoneInfo
@synthesize city,key,value;

+(NSArray*) getAllTimeZones {
    if(!keys)
        keys = [NSArray arrayWithObjects:@"-12.0",@"-11.0",@"-10.0",@"-9.0",@"-8.0",@"-7.0",
            @"-6.0",@"-5.0",@"-4.0",@"-3.5",@"-3.0",@"-2.0",@"-1.0",@"0.0",@"+1.0",@"+2.0",
            @"+3.0",@"+3.5",@"+4.0",@"+4.5",@"+5.0",@"+5.5",@"+5.75",@"+6.0",@"+7.0",@"+8.0",@"+9.0",@"+9.5",@"+10.0",
            @"+11.0",@"+12.0", nil];
     if(!values)
         values = [NSArray arrayWithObjects:@"GMT -12:00",@"GMT -11:00",@"GMT -10:00",@"GMT -9:00",@"GMT -8:00",@"GMT -7:00",
                       @"GMT -6:00",@"GMT -5:00",@"GMT -4:00",@"GMT -3:30",@"GMT -3:00",@"GMT -2:00",@"GMT -1:00",@"GMT",
                       @"GMT +1:00",@"GMT +2:00",@"GMT +3:00",@"GMT +3:30",@"GMT +4:00",@"GMT +4:30",@"GMT +5:00",
                       @"GMT +5:30",@"GMT +5:45",@"GMT +6:00",@"GMT +7:00",@"GMT +8:00",@"GMT +9:00",@"GMT +9:30",@"GMT +10:00",
                    @"GMT +11:00",@"GMT +12:00", nil];
    if (!cities)
        cities =  [NSArray arrayWithObjects:@"Eniwetok, Kwajalein",
                        @"Midway Island, Samoa",
                        @"Hawaii",
                        @"Alaska",
                        @"Pacific Time (US & Canada)",
                        @"Mountain Time (US & Canada))",
                        @"Central Time (US & Canada), Mexico City",
                        @"Eastern Time (US & Canada), Bogota, Lima",
                        @"Atlantic Time (Canada), Caracas, La Paz",
                        @"Newfoundland",@"Brazil, Buenos Aires, Georgetown",
                        @"Mid-Atlantic",
                        @"Azores, Cape Verde Islands",
                        @"Western Europe Time, London, Lisbon, Casablanca",
                        @"Brussels, Copenhagen, Madrid, Paris",
                        @"Kaliningrad, South Africa",
                        @"Baghdad, Yerevan, Moscow, St. Petersburg",
                        @"Tehran",
                        @"Abu Dhabi, Muscat, Tbilisi",
                        @"Kabul",
                        @"Ekaterinburg, Islamabad, Karachi, Tashkent",
                        @"Bombay, Calcutta, Madras, New Delhi",
                        @"Kathmandu",
                        @"Almaty, Dhaka, Colombo",
                        @"Bangkok, Hanoi, Jakarta",
                        @"Beijing, Perth, Singapore, Hong Kong",
                        @"Tokyo, Seoul, Osaka, Sapporo, Yakutsk",
                        @"Adelaide, Darwin",
                        @"Eastern Australia, Guam, Vladivostok",
                        @"Magadan, Solomon Islands, New Caledonia",
                        @"Auckland, Wellington, Fiji, Kamchatka", nil];
    if (!timeZones) {
        timeZones = [[NSMutableArray alloc] init];
        for (int i = 0; i < values.count ; i++) {
            SeequTimeZoneInfo* inf = [[SeequTimeZoneInfo alloc] init];
            inf.key = [keys objectAtIndex:i];
            inf.value = [values objectAtIndex:i];
            inf.city = [cities objectAtIndex:i];
            [timeZones addObject:inf];
        }

    }
    return  timeZones;

}

+(int) getTimeZoneNumber:(NSString *)value {
    if (!timeZones) {
        [SeequTimeZoneInfo getAllTimeZones];
    }

    for (int i = 0; i < timeZones.count; i++ ){
        SeequTimeZoneInfo* inf = [timeZones objectAtIndex:i];
        if ([inf.value isEqualToString:value]) {
            return i;
        }
    }
    return -1;
}

+(NSString*) getTimeZoneValue:(int)number {
    if (!timeZones) {
        [SeequTimeZoneInfo getAllTimeZones];
    }
 //   NSAssert((number >= 0 && number< timeZones.count), @"Out of range of time zones");
    if (number == -1) {
        number = 6;
    }
    return ((SeequTimeZoneInfo*)[timeZones objectAtIndex:number]).value;
}

@end
