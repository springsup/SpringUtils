//
//  SUInterpolable.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

/** Defines a standard interface for interpolating the state of an object. */

@protocol SUInterpolable <NSObject>

/** Returns an instance whose state is a superposition of two given states.
 *
 *  @param  offset      The progress of the interpolation.
 *  @param  fromValue   The initial state of the interpolation, when offset is defined as 0.0.
 *  @param  toValue     The final state of the interpolation, when offset is defined as 1.0.
 *
 *  @returns            An instance whose state is between those of the two given instances.
 */

+ (instancetype)interpolatedValueWithOffset: (double)offset betweenValue: (id)fromValue andValue: (id)toValue;

@end
