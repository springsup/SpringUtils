//
//  NSCalendar+Utilities.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

@interface NSCalendar (Utilities)

/** Returns the instant when the calendar day which contains the given date starts.
 *
 *  @param  date    The date.
 *
 *  @returns        The instant when the calendar day which contains the given date starts.
 */

- (NSDate *)dateAtMidnight: (NSDate *)date;

@end
