//
//  SUValueInterpolation.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#ifndef SpringUtils_SUValueInterpolation_h
#define SpringUtils_SUValueInterpolation_h

#import <CoreGraphics/CoreGraphics.h>

#pragma mark -
/**@name Interpolating C Types */


/** Returns the number at a given offset between two numbers.
 *
 *  @param  start   The start number. This is the value returned when the offset is 0.
 *  @param  end     The end number. This is the value returned when the offset is 1.
 *  @param  offset  The offset.
 *
 *  @returns        The value at distance `offset` in to a linear interpolation between `start` and `end`.
 */

extern float floatWithOffsetBetweenFloats( float start, float end, float offset );

/** Returns the number at a given offset between two numbers.
 *
 *  @param  start   The start number. This is the value returned when the offset is 0.
 *  @param  end     The end number. This is the value returned when the offset is 1.
 *  @param  offset  The offset.
 *
 *  @returns        The value at distance `offset` in to a linear interpolation between `start` and `end`.
 */

extern double doubleWithOffsetBetweenDoubles( double start, double end, float offset );

/** Returns the number at a given offset between two numbers.
 *
 *  @param  start   The start number. This is the value returned when the offset is 0.
 *  @param  end     The end number. This is the value returned when the offset is 1.
 *  @param  offset  The offset.
 *
 *  @returns        The value at distance `offset` in to a linear interpolation between `start` and `end`.
 */

extern unsigned long long unsignedIntegerWithOffsetBetweenIntegers( unsigned long long start, unsigned long long end, float offset );

/** Returns the number at a given offset between two numbers.
 *
 *  @param  start   The start number. This is the value returned when the offset is 0.
 *  @param  end     The end number. This is the value returned when the offset is 1.
 *  @param  offset  The offset.
 *
 *  @returns        The value at distance `offset` in to a linear interpolation between `start` and `end`.
 */

extern long long integerWithOffsetBetweenIntegers( long long start, long long end, float offset );


#pragma mark -
/**@name Interpolating CoreGraphics Types */


/** Returns the point at a given offset between two points.
 *
 *  @param  start   The start point. This is the point returned when the offset is 0.
 *  @param  end     The end point. This is the point returned when the offset is 1.
 *  @param  offset  The offset.
 *
 *  @returns        The point at distance `offset` in to a linear interpolation between `start` and `end`.
 */

extern CGPoint pointWithOffsetBetweenPoints( CGPoint start, CGPoint end, float offset );

/** Returns the size at a given offset between two sizes.
 *
 *  @param  start   The start size. This is the size returned when the offset is 0.
 *  @param  end     The end size. This is the size returned when the offset is 1.
 *  @param  offset  The offset.
 *
 *  @returns        The size at distance `offset` in to a linear interpolation between `start` and `end`.
 */

extern CGSize sizeWithOffsetBetweenSizes( CGSize start, CGSize end, float offset );

/** Returns the rectangle at a given offset in an interpolation between two rectangles.
 *
 *  @param  start   The start rectangle. This is the rectangle returned when the offset is 0.
 *  @param  end     The end rectangle. This is the rectangle returned when the offset is 1.
 *  @param  offset  The offset.
 *
 *  @returns        The rectangle at distance `offset` in to a linear interpolation between `start` and `end`.
 */

extern CGRect rectWithOffsetBetweenRects( CGRect start, CGRect end, float offset );

#endif
