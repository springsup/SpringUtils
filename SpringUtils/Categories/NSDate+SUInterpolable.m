//
//  NSDate+SUInterpolable.m
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "NSDate+SUInterpolable.h"

#import "SUValueInterpolation.h"

@implementation NSDate (SUInterpolable)

+ (instancetype)interpolatedValueWithOffset: (SUInterpolationOffset)offset betweenValue: (NSDate *)fromValue andValue: (NSDate *)toValue {
    
    const NSTimeInterval interpolatedInterval = doubleWithOffsetBetweenDoubles( fromValue.timeIntervalSinceReferenceDate,
                                                                                toValue.timeIntervalSinceReferenceDate,
                                                                                offset );
    return [NSDate dateWithTimeIntervalSinceReferenceDate: interpolatedInterval];
}

@end
