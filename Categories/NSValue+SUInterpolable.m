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

@implementation NSNumber (SUInterpolable)

+ (instancetype)interpolatedValueWithOffset:(double)offset betweenValue:(id)fromValue andValue:(id)toValue {
    
    // Verify that both values are NSNumbers
    
    NSString * exceptionString = Nil;
    
    if( ![fromValue isKindOfClass: self] )
    {
        exceptionString = [NSString stringWithFormat: @"%@ is not a type of %@", fromValue, NSStringFromClass( self )];
    }
    
    if( ![toValue isKindOfClass: self] )
    {
        exceptionString = [NSString stringWithFormat: @"%@ is not a type of %@", toValue, NSStringFromClass( self )];
    }
    
    if( Nil != exceptionString )
    {
        [[NSException exceptionWithName: NSInvalidArgumentException reason: exceptionString userInfo: Nil] raise];
    }

    // Fixed points
    
    if( 0 == offset ) return fromValue;
    if( 1 == offset ) return toValue;
    
    // Values are both NSNumbers
    
    NSNumber * fromNumber   = (NSNumber *)fromValue;
    NSNumber * toNumber     = (NSNumber *)toValue;
    
    // Flip BOOLs in the middle
    
    if( 0 == strcmp( fromNumber.objCType, @encode( BOOL ) ) ||
        0 == strcmp( toNumber.objCType,   @encode( BOOL ) )  )
    {
        if( offset < 0.5 ) return fromNumber;
        return toNumber;
    }

    // Interpolate everything else as a double
    
    return @( doubleWithOffsetBetweenDoubles( fromNumber.doubleValue, toNumber.doubleValue, offset ) );
}

@end

@implementation NSValue (Interpolation)

#define NSValueCanAccessCoreGraphicsStructures TARGET_OS_IPHONE

+ (instancetype)interpolatedValueWithOffset: (double)offset betweenValue: (id)fromValue andValue: (id)toValue {
    
    // Verify that both values are NSValues
    
    NSString * exceptionString = Nil;
    
    if( ![fromValue isKindOfClass: self] )
    {
        exceptionString = [NSString stringWithFormat: @"%@ is not a type of %@", fromValue, NSStringFromClass( self )];
    }
    
    if( ![toValue isKindOfClass: self] )
    {
        exceptionString = [NSString stringWithFormat: @"%@ is not a type of %@", toValue, NSStringFromClass( self )];
    }
    
    if( Nil != exceptionString )
    {
        [[NSException exceptionWithName: NSInvalidArgumentException reason: exceptionString userInfo: Nil] raise];
    }
    
    // Fixed points
    
    if( 0 == offset ) return fromValue;
    if( 1 == offset ) return toValue;

    // Values are both NSValues
    
    NSValue * nsFromValue   = (NSValue *)fromValue;
    NSValue * nsToValue     = (NSValue *)toValue;
    
    // --------------------
    // Scalar Interpolation
    // --------------------
    
    // Scalar value NSValues which aren't NSNumbers (e.g. an NSValue created with initWithBytes:objCType:) aren't supported.
    // Shouldn't matter: they aren't supported by Key-Value Coding anyway. Scalar values should be boxed in an NSNumber.

    // -----------------------
    // Structure Interpolation
    // -----------------------
    
    // For structures, ensure that both fromValue and toValue have the same type
    
    if( 0 != strcmp( nsFromValue.objCType, nsToValue.objCType ) )
    {
        [[NSException exceptionWithName: NSInvalidArgumentException
                                 reason: @"Unable to interpolate structures: from and to values are different types"
                               userInfo: Nil] raise];
    }
    
#if NSValueCanAccessCoreGraphicsStructures

        const char * valueType = [fromValue objCType];
        
        // CGPoint
        
        if( 0 == strcmp( valueType, @encode( CGPoint ) ) )
        {
            return [NSValue valueWithCGPoint: pointWithOffsetBetweenPoints( nsFromValue.CGPointValue, nsToValue.CGPointValue, offset ) ];
        }
        
        // CGSize
        
        if( 0 == strcmp( valueType, @encode( CGSize ) ) )
        {
            return [NSValue valueWithCGSize: sizeWithOffsetBetweenSizes( nsFromValue.CGSizeValue, nsToValue.CGSizeValue, offset )];
        }
        
        // CGRect
        
        if( 0 == strcmp( valueType, @encode( CGRect ) ) )
        {
            return [NSValue valueWithCGRect: rectWithOffsetBetweenRects( nsFromValue.CGRectValue, nsToValue.CGRectValue, offset )];
        }

        // TODO: CGAffineTransform, etc
    
#endif
    
    // Unknown value type
    
    return Nil;
}

@end

