//
//  NSValue+SUInterpolable.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "NSValue+SUInterpolable.h"

#import "../Utilities/SUValueInterpolation.h"
#import "../Utilities/SUAssociatedObjects.h"
#import "../Utilities/SURuntimeAssertions.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h> // NSValue CoreGraphics extensions
#endif

@implementation NSNumber (SUInterpolable)

+ (instancetype)interpolatedValueWithOffset: (SUInterpolationOffset)offset betweenValue: (NSNumber *)fromValue andValue: (NSNumber *)toValue {

    SU_ASSERT_MSG( fromValue.class == toValue.class,
                   @"Cannot interpolate; mismatched types: %@ and %@", fromValue, toValue )
    
    // Fixed points
    
    if( 0 == offset ) return fromValue;
    if( 1 == offset ) return toValue;
    
    // Flip BOOLs in the middle
    
    if( 0 == strcmp( fromValue.objCType, @encode( BOOL ) ) ||
        0 == strcmp( toValue.objCType,   @encode( BOOL ) )  )
    {
        if( offset < 0.5 ) return fromValue;
        return toValue;
    }

    // Interpolate everything else as a double
    
    return @( doubleWithOffsetBetweenDoubles( fromValue.doubleValue, toValue.doubleValue, offset ) );
}

@end

@implementation NSValue (Interpolation)

#define NSValueCanAccessCoreGraphicsStructures TARGET_OS_IPHONE

+ (instancetype)interpolatedValueWithOffset: (SUInterpolationOffset)offset betweenValue: (NSValue *)fromValue andValue: (NSValue *)toValue {
    
    SU_ASSERT_MSG( fromValue.class == toValue.class,
                  @"Cannot interpolate; mismatched types between:\n%@, and\n %@", fromValue, toValue )
    
    // Fixed points
    
    if( 0 == offset ) return fromValue;
    if( 1 == offset ) return toValue;
    
    // --------------------
    // Scalar Interpolation
    // --------------------
    
    // Scalar value NSValues which aren't NSNumbers (e.g. an NSValue created with initWithBytes:objCType:) aren't supported.
    // Shouldn't matter: they aren't supported by Key-Value Coding anyway. Scalar values should be boxed in an NSNumber.

    // -----------------------
    // Structure Interpolation
    // -----------------------

    const char * valueType = [fromValue objCType];
    
    // Ensure that both fromValue and toValue have the same underlying type
    
    SU_ASSERT_MSG( 0 == strcmp( valueType, toValue.objCType ),
                   @"Unable to interpolate structures: from and to values are different types" )
    
#if NSValueCanAccessCoreGraphicsStructures
    
        // CGPoint
        
        if( 0 == strcmp( valueType, @encode( CGPoint ) ) )
        {
            return [NSValue valueWithCGPoint: pointWithOffsetBetweenPoints( fromValue.CGPointValue, toValue.CGPointValue, offset ) ];
        }
        
        // CGSize
        
        if( 0 == strcmp( valueType, @encode( CGSize ) ) )
        {
            return [NSValue valueWithCGSize: sizeWithOffsetBetweenSizes( fromValue.CGSizeValue, toValue.CGSizeValue, offset )];
        }
        
        // CGRect
        
        if( 0 == strcmp( valueType, @encode( CGRect ) ) )
        {
            return [NSValue valueWithCGRect: rectWithOffsetBetweenRects( fromValue.CGRectValue, toValue.CGRectValue, offset )];
        }

        // TODO: CGAffineTransform, etc
    
#endif
    
    // Unknown value type.
    
    // Look for a custom interpolator.
    
    NSValue * customInterpolation = [NSValue customInterpolatedValueWithObjCType: valueType
                                                                        atOffset: offset
                                                                       fromValue: fromValue
                                                                         toValue: toValue];
    
    if( Nil != customInterpolation )
        return customInterpolation;
    
    // Unable to interpolate; just snap between fromValue and toValue.
    
    if( offset < 0.5 ) return fromValue;
    return toValue;
}

#pragma mark -
#pragma mark Custom Interpolators

static NSMutableDictionary* customInterpolators;

+ (void)registerInterpolator: (SUValueInterpolator)interpolator forObjCType: (const char *)type {
    
    SU_ASSERT_NOT_EQUAL( interpolator, NULL )
    SU_ASSERT_NOT_EQUAL( type, NULL )
    
    if( Nil == customInterpolators )
    {
        customInterpolators = [[NSMutableDictionary alloc] init];
    }
    
    NSString * typeString   = [NSString stringWithUTF8String: type];
    NSValue  * wrappedFunc  = [NSValue valueWithPointer: interpolator];
    
    customInterpolators[ typeString ] = wrappedFunc;
}

+ (NSValue *)customInterpolatedValueWithObjCType: (const char *)type
                                        atOffset: (double)offset
                                       fromValue: (NSValue *)startVal
                                         toValue: (NSValue *)endVal {
    
    NSString * typeString   = [NSString stringWithUTF8String: type];
    NSValue  * wrappedFunc  = customInterpolators[ typeString ];
    
    if( Nil != wrappedFunc )
    {
        return ((SUValueInterpolator)wrappedFunc.pointerValue)( startVal, endVal, offset );
    }
    
    return Nil;
}

@end

