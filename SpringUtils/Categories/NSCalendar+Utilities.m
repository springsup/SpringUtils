//
//  NSCalendar+Utilities.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "NSCalendar+Utilities.h"

@implementation NSCalendar (Utilities)

- (NSDate *)dateAtMidnight: (NSDate *)date {
    
    // Get all non-time components
    
    NSDateComponents * components = [self components:   NSCalendarUnitDay   |
                                                        NSCalendarUnitMonth |
                                                        NSCalendarUnitYear  |
                                                        NSCalendarUnitEra
                                            fromDate: date];

    // Return the date
    
    return [self dateFromComponents: components];
}

@end
