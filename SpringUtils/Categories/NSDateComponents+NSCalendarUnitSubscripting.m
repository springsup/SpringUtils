//
//  NSDateComponents+NSCalendarUnitSubscripting.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "NSDateComponents+NSCalendarUnitSubscripting.h"

@implementation NSDateComponents (NSCalendarUnitSubscripting)

- (id)objectAtIndexedSubscript: (NSCalendarUnit)calendarUnit {
    
    switch ( calendarUnit )
    {
        case NSCalendarUnitCalendar:
            return self.calendar;
        case NSCalendarUnitTimeZone:
            return self.timeZone;
        default:
            return @( [self valueForCalendarUnit: calendarUnit] );
    }
}

- (void)setObject: (id)object atIndexedSubscript: (NSCalendarUnit)calendarUnit {
    
    switch ( calendarUnit )
    {
        case NSCalendarUnitCalendar:
            self.calendar = object;
        case NSCalendarUnitTimeZone:
            self.timeZone = object;
        default:
            [self setValue: [object integerValue] forCalendarUnit: calendarUnit];
    }
}

@end

@implementation NSDateComponents (NSCalendarUnitGetnSet)

- (NSInteger)valueForCalendarUnit: (NSCalendarUnit)calendarUnit {
    
    switch ( calendarUnit )
    {
        case NSCalendarUnitDay:
            return self.day;

        case NSCalendarUnitMonth:
            return self.month;
            
        case NSCalendarUnitQuarter:
            return self.quarter;
            
        case NSCalendarUnitYear:
            return self.year;
            
        case NSCalendarUnitEra:
            return self.era;
            
        case NSCalendarUnitHour:
            return self.hour;
            
        case NSCalendarUnitMinute:
            return self.minute;
            
        case NSCalendarUnitSecond:
            return self.second;
            
        case NSCalendarUnitWeekday:
            return self.weekday;
            
        case NSCalendarUnitWeekdayOrdinal:
            return self.weekdayOrdinal;
            
        case NSCalendarUnitWeekOfMonth:
            return self.weekOfMonth;
            
        case NSCalendarUnitWeekOfYear:
            return self.weekOfYear;
            
        case NSCalendarUnitYearForWeekOfYear:
            return self.yearForWeekOfYear;

            /* Deprecated as of iOS7 */

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

        case NSWeekCalendarUnit:
            return self.week;

#pragma clang diagnostic pop

            /* Unimplemented (class types) */

            /* NSCalendarCalendarUnit */
            /* NSTimeZoneCalendarUnit */

        default:
            return 0;
    }
}

- (void)setValue: (NSInteger)value forCalendarUnit: (NSCalendarUnit)calendarUnit {
    
    switch ( calendarUnit )
    {
        case NSCalendarUnitDay:
            self.day  = value;
            break;
            
        case NSCalendarUnitMonth:
            self.month = value;
            break;
            
        case NSCalendarUnitQuarter:
            self.quarter = value;
            break;
            
        case NSCalendarUnitYear:
            self.year = value;
            break;
            
        case NSCalendarUnitEra:
            self.era = value;
            break;
            
        case NSCalendarUnitHour:
            self.hour = value;
            break;
            
        case NSCalendarUnitMinute:
            self.minute = value;
            break;
            
        case NSCalendarUnitSecond:
            self.second = value;
            break;
            
        case NSCalendarUnitWeekday:
            self.weekday = value;
            break;
            
        case NSCalendarUnitWeekdayOrdinal:
            self.weekdayOrdinal = value;
            break;
            
        case NSCalendarUnitWeekOfMonth:
            self.weekOfMonth = value;
            break;
            
        case NSCalendarUnitWeekOfYear:
            self.weekOfYear = value;
            break;
            
        case NSCalendarUnitYearForWeekOfYear:
            self.yearForWeekOfYear = value;
            break;

            /* Deprecated as of iOS7 */

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

        case NSWeekCalendarUnit:
            self.week = value;
            break;

#pragma clang diagnostic pop

            /* Unimplemented (class types) */

            /* NSCalendarCalendarUnit */
            /* NSTimeZoneCalendarUnit */

        default:
            break;
    }
}

@end
