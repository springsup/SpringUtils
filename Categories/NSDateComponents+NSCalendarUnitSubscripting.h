//
//  NSDateComponents+NSCalendarUnitSubscripting.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

/** Implements subscripting to read and manipulate an NSDateComponents instance.
 *
 *  Date components can now be set with code such as: `dateComponents[ NSDayCalendarUnit ] = 20`.
 */

@interface NSDateComponents (NSCalendarUnitSubscripting)

- (id)objectAtIndexedSubscript: (NSCalendarUnit)unit;

- (void)setObject: (id)value atIndexedSubscript: (NSCalendarUnit)unit;

@end

/** Implements getters and setters to read and manipulate an NSDateComponents instance by calendar unit.
 *
 *  Date components can now be set with code such as: `[dateComponents setValue: 6 forCalendarUnit: NSMonthCalendarUnit]`.
 *  Object-type calendar units (e.g. NSCalendarCalendarUnit, NSTimeZoneCalendarUnit) are not supported by these methods and return 0.
 */

@interface NSDateComponents (NSCalendarUnitGetnSet)

/** Returns the value held by the receiver for the given calendar unit.
 *
 *  Object-type calendar units (e.g. NSCalendarCalendarUnit, NSTimeZoneCalendarUnit) are not supported and return 0.
 *
 *  @param  calendarUnit    The calendar unit to read.
 *
 *  @returns    The value of the given calendar unit
 */

- (NSInteger)valueForCalendarUnit: (NSCalendarUnit)calendarUnit;

/** Sets the value held by the receiver for the given calendar unit.
 *
 *  Object-type calendar units (e.g. NSCalendarCalendarUnit, NSTimeZoneCalendarUnit) are not supported and are not set by this method.
 *
 *  @param  value           The value to set for the given calendar unit.
 *  @param  calendarUnit    The calendar unit to read.
 *
 *  @returns    The value of the given calendar unit
 */

- (void)setValue: (NSInteger)value forCalendarUnit: (NSCalendarUnit)calendarUnit;

@end