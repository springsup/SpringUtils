//
//  SUMethodBuilder.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

/** SUMethodBuilder provides an interface for declaring Objective-C methods at runtime. */

@interface SUMethodBuilder : NSObject

/** @name Retrieving Method details */


/** The selector of the method represented by the receiver. */

@property ( nonatomic, readonly ) SEL selector;

/** The Objective-C encoded type string of the method represented by the receiver.
 *
 *  Unless type information has been set for all arguments in the method's selector, this
 *  property will return `NULL`.
 */

@property ( nonatomic, readonly ) const char * encodedTypes;

/** A function pointer to the implementation of the method represented by the receiver. */

@property ( nonatomic, readonly ) IMP implementation;


/** @name Creating a new Method builder */


/** Creates and returns a new SUMethodBuilder instance.
 *
 *  @param  selector        The selector of the method the new instance should represent. May not be `NULL`.
 *  @param  returnType      The Objective-C encoded type string of the method's return type. May not be `NULL`.
 *  @param  block           A block which provides the method's implementation. May not be `Nil`.
 *
 *  @returns                A new SUMethodBuilder instance representing the described method.
 */

+ (instancetype)newMethodWithSelector: (SEL)selector returnType: (const char *)returnType block: (id)block;

/** Creates and returns a new SUMethodBuilder instance.
 *
 *  @param  selector        The selector of the method the new instance should represent. May not be `NULL`.
 *  @param  returnType      The Objective-C encoded type string of the method's return type. May not be `NULL`.
 *  @param  implementation  A function pointer which provides the method's implementation. May not be `NULL`.
 *
 *  @returns                A new SUMethodBuilder instance representing the described method.
 */

+ (instancetype)newMethodWithSelector: (SEL)selector returnType: (const char *)returnType implementation: (IMP)implementation;


/** @name Setting the argument types */


/** Sets the type of the method argument at the given position.
 *
 *  @param  encodedType     The Objective-C encoded type string of the argument's type. May not be `NULL`.
 *  @param  argumentIndex   The position of the argument within the receiver's selector.
 *
 *  @returns                The receiver, allowing for calls to be chained.
 */

- (instancetype)setType: (const char *)encodedType forArgumentAtIndex: (NSUInteger)argumentIndex;

@end
