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
#import "SUMethodSignatureBuilder.h"


/** SUMethodBuilder provides an interface for declaring Objective-C methods at runtime. */

@interface SUMethodBuilder : SUMethodSignatureBuilder


//---------------------------------------/
/** @name Creating a new method builder */
//---------------------------------------/


/** Creates and returns a new SUMethodBuilder instance.
 *
 *  @param  selector        The selector of the method to build. May not be `NULL`.
 *  @param  block           A block which provides the method's implementation. May not be `Nil`.
 *
 *  @returns                A new SUMethodBuilder instance representing the described method.
 */

+ (instancetype)newMethodWithSelector: (SEL)selector block: (id)block;

/** Creates and returns a new SUMethodBuilder instance.
 *
 *  @param  selector        The selector of the method the new instance should represent. May not be `NULL`.
 *  @param  returnType      The type encoding of the new method's return type. May not be `NULL`.
 *  @param  block           A block which provides the method's implementation. May not be `Nil`.
 *
 *  @returns                A new SUMethodBuilder instance representing the described method.
 */

+ (instancetype)newMethodWithSelector: (SEL)selector returnType: (const char *)returnType block: (id)block;

/** Creates and returns a new SUMethodBuilder instance.
 *
 *  @param  selector        The selector of the method the new instance should represent. May not be `NULL`.
 *  @param  implementation  A function pointer which provides the method's implementation. May not be `NULL`.
 *
 *  @returns                A new SUMethodBuilder instance representing the described method.
 */

+ (instancetype)newMethodWithSelector: (SEL)selector implementation: (IMP)implementation;

/** Creates and returns a new SUMethodBuilder instance.
 *
 *  @param  selector        The selector of the method the new instance should represent. May not be `NULL`.
 *  @param  returnType      The type encoding of the new method's return type. May not be `NULL`.
 *  @param  implementation  A function pointer which provides the method's implementation. May not be `NULL`.
 *
 *  @returns                A new SUMethodBuilder instance representing the described method.
 */

+ (instancetype)newMethodWithSelector: (SEL)selector returnType: (const char *)returnType implementation: (IMP)implementation;


//--------------------------------/
/** @name Getting Method Details */
//--------------------------------/


/** The selector of the method represented by the receiver. */

@property ( nonatomic, readonly ) SEL selector;

/** A function pointer to the implementation of the method represented by the receiver. */

@property ( nonatomic, readonly ) IMP implementation;


//--------------------------------------/
/** @name Getting the Method Signature */
//--------------------------------------/


/** An encoded string of the return- and parameter types of the method represented by the receiver.
 *
 *  Unless type information has been set for all parameters in the method's selector, this
 *  property will return `NULL`.
 */

@property ( nonatomic, readonly ) const char * encodedTypeSignature;

/** The method signature of the method represented by the receiver.
 *
 *  Unless type information has been set for all parameters in the method's selector, this
 *  property will return `Nil`.
 */

@property ( nonatomic, readonly ) NSMethodSignature * methodSignature;

@end
