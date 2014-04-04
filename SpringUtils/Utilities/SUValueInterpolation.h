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

#import <CoreGraphics/CoreGraphics.h> // Interpolation of CG types
#import "SUBase.h"
#import "SUTypes.h"


//------------------------------/
/**@name Interpolating C Types */
//------------------------------/


/** Returns the number at a given offset between two numbers.
 *
 *  @param  start   The start number. This is the value returned when the offset is 0.
 *  @param  end     The final number. This is the value returned when the offset is 1.
 *  @param  offset  The offset.
 *
 *  @returns        The value at distance `offset` in to a linear interpolation between `start` and `end`.
 */

SU_EXTERN float floatWithOffsetBetweenFloats( float start, float end, SUInterpolationOffset offset );

/** Returns the number at a given offset between two numbers.
 *
 *  @param  start   The start number. This is the value returned when the offset is 0.
 *  @param  end     The final number. This is the value returned when the offset is 1.
 *  @param  offset  The offset.
 *
 *  @returns        The value at distance `offset` in to a linear interpolation between `start` and `end`.
 */

SU_EXTERN double doubleWithOffsetBetweenDoubles( double start, double end, SUInterpolationOffset offset );

/** Returns the number at a given offset between two numbers.
 *
 *  @param  start   The start number. This is the value returned when the offset is 0.
 *  @param  end     The final number. This is the value returned when the offset is 1.
 *  @param  offset  The offset.
 *
 *  @returns        The value at distance `offset` in to a linear interpolation between `start` and `end`.
 */

SU_EXTERN unsigned long long unsignedIntegerWithOffsetBetweenIntegers( unsigned long long start, unsigned long long end, SUInterpolationOffset offset );

/** Returns the number at a given offset between two numbers.
 *
 *  @param  start   The start number. This is the value returned when the offset is 0.
 *  @param  end     The final number. This is the value returned when the offset is 1.
 *  @param  offset  The offset.
 *
 *  @returns        The value at distance `offset` in to a linear interpolation between `start` and `end`.
 */

SU_EXTERN long long integerWithOffsetBetweenIntegers( long long start, long long end, SUInterpolationOffset offset );


//-----------------------------------------/
/**@name Interpolating CoreGraphics Types */
//-----------------------------------------/


/** Returns the point at a given offset between two points.
 *
 *  @param  start   The start point. This is the point returned when the offset is 0.
 *  @param  end     The final point. This is the point returned when the offset is 1.
 *  @param  offset  The offset.
 *
 *  @returns        The point at distance `offset` in to a linear interpolation between `start` and `end`.
 */

SU_EXTERN CGPoint pointWithOffsetBetweenPoints( CGPoint start, CGPoint end, SUInterpolationOffset offset );

/** Returns the size at a given offset between two sizes.
 *
 *  @param  start   The start size. This is the size returned when the offset is 0.
 *  @param  end     The final size. This is the size returned when the offset is 1.
 *  @param  offset  The offset.
 *
 *  @returns        The size at distance `offset` in to a linear interpolation between `start` and `end`.
 */

SU_EXTERN CGSize sizeWithOffsetBetweenSizes( CGSize start, CGSize end, SUInterpolationOffset offset );

/** Returns the rectangle at a given offset in an interpolation between two rectangles.
 *
 *  @param  start   The start rectangle. This is the rectangle returned when the offset is 0.
 *  @param  end     The final rectangle. This is the rectangle returned when the offset is 1.
 *  @param  offset  The offset.
 *
 *  @returns        The rectangle at distance `offset` in to a linear interpolation between `start` and `end`.
 */

SU_EXTERN CGRect rectWithOffsetBetweenRects( CGRect start, CGRect end, SUInterpolationOffset offset );


#endif
