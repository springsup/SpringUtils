//
//  SUClassBuilder.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>
#import "SUMethodBuilder.h"

/** SUClassBuilder provides an interface for creating Objective-C classes at runtime. */

@interface SUClassBuilder : NSObject


/** @name Creating a new class */


/** Creates a new class.
 *
 *  Note: The created class is in an invalid state and may not be used until registered by calling the
 *  registerClass method on the SUClassBuilder instance returned by this method.
 *
 *  @param  className       The name of the new class to create. May not be `Nil`.
 *  @param  superClass      The class which the new class should inherit from. May not be `Nil`.
 *
 *  @return                 An SUClassBuilder instance which may be used to add methods and instance variables to the new class.
 *                          Returns Nil if the class could not be created - for example, if a class with the given name already exists.
 */

+ (instancetype)newClassNamed: (NSString *)className superClass: (Class)superClass;

/** Registers a newly-created class for use by the runtime.
 *
 *  You must call this method before instantiating or assigning the new class to any objects.
 *
 *  @returns                The newly-created class.
 */

- (Class)registerClass;


/** @name Adding instance variables */


/** Adds an instance variable to the class with the given name and type.
 *
 *  You must not add instance variables to a class once it has been registered.
 *  To do so is considered a programmer error and will raise an exception.
 *
 *  @param  ivarName        The name of the new instance variable. May not be `Nil`.
 *  @param  typeEncoding    The Objective-C type encoding of the instance variable's type. May not be `NULL`.
 *
 *  @returns                The receiver, allowing for calls to be chained.
 */

- (instancetype)addIvar: (NSString *)ivarName type: (const char *)typeEncoding;

/** Adds an object-type instance variable to the class.
 *
 *  You must not add instance variables to a class once it has been registered.
 *  To do so is considered a programmer error and will raise an exception.
 *
 *  @param  ivarName        The name of the new instance variable. May not be `Nil`.
 *
 *  @returns                The receiver, allowing for calls to be chained.
 */

- (instancetype)addObjectIvar: (NSString *)ivarName;


/** @name Adding instance methods */


/** Adds a new method to instances of the new class.
 *
 *  If the class already contains an instance method matching this method's selector (not including superclass methods),
 *  this method does not replace its implementation.
 *
 *  @param  methodBuilder   An SUMethodBuilder instance defining the method to add. May not be `Nil`.
 *
 *  @returns                The receiver, allowing for calls to be chained.
 */

- (instancetype)addInstanceMethod: (SUMethodBuilder *)methodBuilder;

/** Adds a new method to instances of the new class.
 *
 *  The block's signature should match the signature of the method,
 *  with an additional object-type argument as the first argument to the block, which is the `self` pointer.
 *
 *  If the class already contains an instance method matching this method's selector (not including superclass methods),
 *  this method does not replace its implementation.
 *
 *  @param  selector        The selector of the method to add. May not be `NULL`.
 *  @param  types           The Objective-C type encoding of the method. May not be `NULL`.
 *  @param  block           A block which provides the method's implementation. May not be `Nil`.
 *
 *  @returns                The receiver, allowing for calls to be chained.
 */

- (instancetype)addInstanceMethod: (SEL)selector types: (const char *)types block: (id)block;

/** Adds a new method to instances of the new class.
 *
 *  The function signature should match the signature of the method,
 *  with additional object-type and selector arguments as the first and second arguments, which are the `self` pointer
 *  and invoked selector, respectively.
 *
 *  If the class already contains an instance method matching this method's selector (not including superclass methods),
 *  this method does not replace its implementation.
 *
 *  @param  selector        The selector of the method to add. May not be `NULL`.
 *  @param  types           The Objective-C type encoding of the method. May not be `NULL`.
 *  @param  implementation  A function pointer which provides the method's implementation. May not be `NULL`.
 *
 *  @returns                The receiver, allowing for calls to be chained.
 */

- (instancetype)addInstanceMethod: (SEL)selector types: (const char *)types implementation: (IMP)implementation;


/** @name Adding class methods */


/** Adds a new method to the new class object itself.
 *
 *  If the class already contains a class method matching this method's selector (not including superclass methods),
 *  this method does not replace its implementation.
 *
 *  @param  methodBuilder   An SUMethodBuilder instance defining the method to add. May not be `Nil`.
 *
 *  @returns                The receiver, allowing for calls to be chained.
 */

- (instancetype)addClassMethod: (SUMethodBuilder *)methodBuilder;

/** Adds a new method to the new class object itself.
 *
 *  The block's signature should match the signature of the method,
 *  with an additional object-type argument as the first argument to the block, which is the `self` pointer.
 *
 *  For class methods, `self` points to the class object.
 *
 *  If the class already contains a class method matching this method's selector (not including superclass methods),
 *  this method does not replace its implementation.
 *
 *  @param  selector        The selector of the method to add. May not be `NULL`.
 *  @param  types           The Objective-C type encoding of the method. May not be `NULL`.
 *  @param  block           A block which provides the method's implementation. May not be `Nil`.
 *
 *  @returns                The receiver, allowing for calls to be chained.
 */

- (instancetype)addClassMethod: (SEL)selector types: (const char *)types block: (id)block;

/** Adds a new method to the new class object itself.
 *
 *  The function signature should match the signature of the method,
 *  with additional object-type and selector arguments as the first and second arguments, which are the `self` pointer
 *  and invoked selector, respectively.
 *
 *  For class methods, `self` points to the class object.
 *
 *  If the class already contains a class method matching this method's selector (not including superclass methods),
 *  this method does not replace its implementation.
 *
 *  @param  selector        The selector of the method to add. May not be `NULL`.
 *  @param  types           The Objective-C type encoding of the method. May not be `NULL`.
 *  @param  implementation  A function pointer which provides the method's implementation. May not be `NULL`.
 *
 *  @returns                The receiver, allowing for calls to be chained.
 */

- (instancetype)addClassMethod: (SEL)selector types: (const char *)types implementation: (IMP)implementation;

@end
