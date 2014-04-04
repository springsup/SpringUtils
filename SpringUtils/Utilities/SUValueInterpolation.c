//
//  SUValueInterpolation.c
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "SUValueInterpolation.h"

#pragma mark -
#pragma mark C Types

inline float floatWithOffsetBetweenFloats( float start, float end, SUInterpolationOffset offset )
{
    return start + ( ( end - start ) * offset );
}

inline double doubleWithOffsetBetweenDoubles( double start, double end, SUInterpolationOffset offset )
{
    return start + ( ( end - start ) * offset );
}

inline unsigned long long unsignedIntegerWithOffsetBetweenIntegers( unsigned long long start, unsigned long long end, SUInterpolationOffset offset )
{
    return start + ( ( end - start ) * offset );
}

inline long long integerWithOffsetBetweenIntegers( long long start, long long end, SUInterpolationOffset offset )
{
    return start + ( ( end - start ) * offset );
}

#pragma mark -
#pragma mark CoreGraphics Types

CGPoint pointWithOffsetBetweenPoints( CGPoint start, CGPoint end, SUInterpolationOffset offset ) {
    
    return (CGPoint){   .x = floatWithOffsetBetweenFloats( start.x, end.x, offset ),
                        .y = floatWithOffsetBetweenFloats( start.y, end.y, offset ) };
}

CGSize sizeWithOffsetBetweenSizes( CGSize start, CGSize end, SUInterpolationOffset offset ) {
    
    return (CGSize){    .width  = floatWithOffsetBetweenFloats( start.width, end.width, offset ),
                        .height = floatWithOffsetBetweenFloats( start.height, end.height, offset )};
}

CGRect rectWithOffsetBetweenRects( CGRect start, CGRect end, SUInterpolationOffset offset ) {
    
    return (CGRect){    .origin = pointWithOffsetBetweenPoints( start.origin, end.origin, offset ),
                        .size   = sizeWithOffsetBetweenSizes( start.size, end.size, offset ) };
}
