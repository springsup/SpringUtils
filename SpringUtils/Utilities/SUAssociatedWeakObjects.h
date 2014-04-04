//
//  SUAssociatedWeakObjects.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface SUAssociatedWeakRefHolder : NSObject
{
    @package
    __weak id object;
}
@end

/** Implements non-retaining getters and setters for an object-type property with the specified association policy.
 *
 *  An example of usage would be:
 *  `IMPLEMENT_ASSOCIATED_WEAK_PROPERTY_ATOMIC( NSObject*, myObject, setMyObject, NO )`
 *
 *  @param  PROPERTY_TYPE   The type of the property, followed by a '*' if the type is not `id`.
 *  @param  PROPERTY_NAME   The name of the getter to be synthesized.
 *  @param  SETTER_NAME     The name of the setter to be synthesized.
 *  @param  ATOMIC          A Boolean value which determines whether the property is set atomically.
 */

#define IMPLEMENT_ASSOCIATED_WEAK_PROPERTY_ATOMIC( PROPERTY_TYPE, PROPERTY_NAME, SETTER_NAME, ATOMIC ) \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
    SUAssociatedWeakRefHolder *holder = objc_getAssociatedObject( self, @selector( PROPERTY_NAME ) ); \
    if( Nil != holder ) return ( PROPERTY_TYPE ) holder->object; \
    else                return Nil; \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
    objc_AssociationPolicy policy     = ATOMIC ? OBJC_ASSOCIATION_RETAIN : OBJC_ASSOCIATION_RETAIN_NONATOMIC; \
    SUAssociatedWeakRefHolder *holder = [[SUAssociatedWeakRefHolder alloc] init]; \
    holder->object = PROPERTY_NAME; \
    objc_setAssociatedObject(self, @selector( PROPERTY_NAME ), holder, policy ); \
} \

/** Implements non-retaining, non-atomic getters and setters for an object-type property.
 *
 *  An example of usage would be:
 *  `IMPLEMENT_ASSOCIATED_WEAK_PROPERTY( NSObject*, myObject, setMyObject )`
 *
 *  @param  PROPERTY_TYPE   The type of the property, followed by a '*' if the type is not `id`.
 *  @param  PROPERTY_NAME   The name of the getter to be synthesized.
 *  @param  SETTER_NAME     The name of the setter to be synthesized.
 */

#define IMPLEMENT_ASSOCIATED_WEAK_PROPERTY( PROPERTY_TYPE, PROPERTY_NAME, SETTER_NAME ) IMPLEMENT_ASSOCIATED_WEAK_PROPERTY_ATOMIC( PROPERTY_TYPE, PROPERTY_NAME, SETTER_NAME, NO )