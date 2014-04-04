//
//  NSDate+SUInterpolable.m
//  Sterling
//
//  Created by Karl Wagner on 12/01/2014.
//
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
