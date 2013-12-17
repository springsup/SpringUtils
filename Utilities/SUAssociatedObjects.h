//
//  SUAssociatedObjects.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "objc/runtime.h"

/**@name Implementing object-type properties */


/** Implements standard getters and setters for an object-type property with the specified association policy.
 *
 *  An example of usage would be:
 *  `IMPLEMENT_ASSOCIATED_PROPERTY_ATOMIC( NSObject*, myObject, setMyObject, NO )`
 *
 *  @param  PROPERTY_TYPE   The type of the property, followed by a '*' if the type is not `id`.
 *  @param  PROPERTY_NAME   The name of the getter to be synthesized.
 *  @param  SETTER_NAME     The name of the setter to be synthesized.
 *  @param  ATOMIC          A Boolean value which determines whether the property is set atomically.
 */

#define IMPLEMENT_ASSOCIATED_PROPERTY_ATOMIC( PROPERTY_TYPE, PROPERTY_NAME, SETTER_NAME, ATOMIC ) \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
    return ( PROPERTY_TYPE )objc_getAssociatedObject( self, @selector( PROPERTY_NAME ) ); \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
    objc_AssociationPolicy policy = ATOMIC ? OBJC_ASSOCIATION_RETAIN : OBJC_ASSOCIATION_RETAIN_NONATOMIC; \
    objc_setAssociatedObject( self, @selector( PROPERTY_NAME ), PROPERTY_NAME, policy ); \
} \

/** Implements standard, non-atomic getters and setters for an object-type property.
 *
 *  An example of usage would be:
 *  `IMPLEMENT_ASSOCIATED_PROPERTY( NSObject*, myObject, setMyObject )`
 *
 *  @param  PROPERTY_TYPE   The type of the property, followed by a '*' if the type is not `id`.
 *  @param  PROPERTY_NAME   The name of the getter to be synthesized.
 *  @param  SETTER_NAME     The name of the setter to be synthesized.
 */

#define IMPLEMENT_ASSOCIATED_PROPERTY( PROPERTY_TYPE, PROPERTY_NAME, SETTER_NAME ) IMPLEMENT_ASSOCIATED_PROPERTY_ATOMIC( PROPERTY_TYPE, PROPERTY_NAME, SETTER_NAME, NO )


/**@name Implementing scalar-type properties */


/** Implements standard getters and setters for a scalar-type property with the specified association policy and default value.
 *
 *  If the property is read before it has been set, the specified default value is returned.
 *
 *  An example of usage would be:
 *  `IMPLEMENT_ASSOCIATED_SCALAR_PROPERTY_ATOMIC_DEFAULT( CGPoint, importantLocation, setImportantLocation, NO, CGPointZero )`
 *
 *  @param  PROPERTY_TYPE   The type of the property.
 *  @param  PROPERTY_NAME   The name of the getter to be synthesized.
 *  @param  SETTER_NAME     The name of the setter to be synthesized.
 *  @param  ATOMIC          A boolean value which determines whether the property is set atomically.
 *  @param  DEFAULT         The value to return if the property is read before it has been set.
 */

#define IMPLEMENT_ASSOCIATED_SCALAR_PROPERTY_ATOMIC_DEFAULT( PROPERTY_TYPE, PROPERTY_NAME, SETTER_NAME, ATOMIC, DEFAULT ) \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
NSValue *boxedVal = objc_getAssociatedObject( self, @selector( PROPERTY_NAME ) ); \
if( Nil == boxedVal ) return DEFAULT; \
PROPERTY_TYPE sVal; \
[boxedVal getValue: &sVal]; \
return sVal; \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
NSValue *boxedVal               = [NSValue value: &PROPERTY_NAME withObjCType: @encode( PROPERTY_TYPE )]; \
objc_AssociationPolicy policy   = ATOMIC ? OBJC_ASSOCIATION_RETAIN : OBJC_ASSOCIATION_RETAIN_NONATOMIC; \
objc_setAssociatedObject( self, @selector( PROPERTY_NAME ), boxedVal, policy ); \
} \

/** Implements standard getters and setters for a scalar-type property with the specified association policy.
 *
 *  If the property is read before it has been set, the returned value will be zero-initialised.
 *
 *  An example of usage would be:
 *  `IMPLEMENT_ASSOCIATED_SCALAR_PROPERTY_ATOMIC( CGPoint, importantLocation, setImportantLocation, NO )`
 *
 *  @param  PROPERTY_TYPE   The type of the property.
 *  @param  PROPERTY_NAME   The name of the getter to be synthesized.
 *  @param  SETTER_NAME     The name of the setter to be synthesized.
 *  @param  ATOMIC          A boolean value which determines whether the property is set atomically.
 */

#define IMPLEMENT_ASSOCIATED_SCALAR_PROPERTY_ATOMIC( PROPERTY_TYPE, PROPERTY_NAME, SETTER_NAME, ATOMIC ) \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
    NSValue *boxedVal = objc_getAssociatedObject( self, @selector( PROPERTY_NAME ) ); \
    PROPERTY_TYPE sVal; \
    if( Nil != boxedVal )   [boxedVal getValue: &sVal]; \
    else                    memset( &sVal, 0, sizeof(PROPERTY_TYPE) ); \
    return sVal; \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
    NSValue *boxedVal               = [NSValue value: &PROPERTY_NAME withObjCType: @encode( PROPERTY_TYPE )]; \
    objc_AssociationPolicy policy   = ATOMIC ? OBJC_ASSOCIATION_RETAIN : OBJC_ASSOCIATION_RETAIN_NONATOMIC; \
    objc_setAssociatedObject( self, @selector( PROPERTY_NAME ), boxedVal, policy ); \
} \

/** Implements standard, non-atomic getters and setters for a scalar-type property.
 *
 *  If the property is read before it has been set, the returned value will be zero-initialised.
 *
 *  An example of usage would be:
 *  `IMPLEMENT_ASSOCIATED_SCALAR_PROPERTY( CGPoint, importantLocation, setImportantLocation )`
 *
 *  @param  PROPERTY_TYPE   The type of the property.
 *  @param  PROPERTY_NAME   The name of the getter to be synthesized.
 *  @param  SETTER_NAME     The name of the setter to be synthesized.
 */

#define IMPLEMENT_ASSOCIATED_SCALAR_PROPERTY( PROPERTY_TYPE, PROPERTY_NAME, SETTER_NAME ) IMPLEMENT_ASSOCIATED_SCALAR_PROPERTY_ATOMIC( PROPERTY_TYPE, PROPERTY_NAME, SETTER_NAME, NO )
