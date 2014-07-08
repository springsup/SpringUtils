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
        case NSCalendarCalendarUnit:
            return self.calendar;
        case NSTimeZoneCalendarUnit:
            return self.timeZone;
        default:
            return @( [self valueForCalendarUnit: calendarUnit] );
    }
}

- (void)setObject: (id)object atIndexedSubscript: (NSCalendarUnit)calendarUnit {
    
    switch ( calendarUnit )
    {
        case NSCalendarCalendarUnit:
            self.calendar = object;
        case NSTimeZoneCalendarUnit:
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
        case NSDayCalendarUnit:
            return self.day;

        case NSMonthCalendarUnit:
            return self.month;
            
        case NSQuarterCalendarUnit:
            return self.quarter;
            
        case NSYearCalendarUnit:
            return self.year;
            
        case NSEraCalendarUnit:
            return self.era;
            
        case NSHourCalendarUnit:
            return self.hour;
            
        case NSMinuteCalendarUnit:
            return self.minute;
            
        case NSSecondCalendarUnit:
            return self.second;
            
        case NSWeekdayCalendarUnit:
            return self.weekday;
            
        case NSWeekdayOrdinalCalendarUnit:
            return self.weekdayOrdinal;
            
        case NSWeekOfMonthCalendarUnit:
            return self.weekOfMonth;
            
        case NSWeekOfYearCalendarUnit:
            return self.weekOfYear;
            
        case NSYearForWeekOfYearCalendarUnit:
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
        case NSDayCalendarUnit:
            self.day  = value;
            break;
            
        case NSMonthCalendarUnit:
            self.month = value;
            break;
            
        case NSQuarterCalendarUnit:
            self.quarter = value;
            break;
            
        case NSYearCalendarUnit:
            self.year = value;
            break;
            
        case NSEraCalendarUnit:
            self.era = value;
            break;
            
        case NSHourCalendarUnit:
            self.hour = value;
            break;
            
        case NSMinuteCalendarUnit:
            self.minute = value;
            break;
            
        case NSSecondCalendarUnit:
            self.second = value;
            break;
            
        case NSWeekdayCalendarUnit:
            self.weekday = value;
            break;
            
        case NSWeekdayOrdinalCalendarUnit:
            self.weekdayOrdinal = value;
            break;
            
        case NSWeekOfMonthCalendarUnit:
            self.weekOfMonth = value;
            break;
            
        case NSWeekOfYearCalendarUnit:
            self.weekOfYear = value;
            break;
            
        case NSYearForWeekOfYearCalendarUnit:
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
