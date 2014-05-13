//
//  NSMapTable+GenericPointerFunctions.h
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

/** Provides a set of convenience functions for adding, removing and retrieving arbitrary pointers from an NSMapTable without bridging casts. */

@interface NSMapTable (GenericPointerFunctions)


//------------------------/
/** @name Getting Values */
//------------------------/


- (void*)pointerForKey: (id)aKey;

- (id)objectForPointerKey: (const void*)aKey;

- (void*)pointerForPointerKey: (const void*)aKey;


//------------------------/
/** @name Setting Values */
//------------------------/


- (void)setPointer: (const void*)aPointer forKey: (id)aKey;

- (void)setObject: (id)anObject forPointerKey: (const void*)aKey;

- (void)setPointer: (const void *)aPointer forPointerKey: (const void*)aKey;


//-------------------------/
/** @name Removing Values */
//-------------------------/


- (void)removePointerForKey: (id)aKey;

- (void)removeObjectForPointerKey: (const void*)aKey;

- (void)removePointerForPointerKey: (const void*)aKey;


@end
