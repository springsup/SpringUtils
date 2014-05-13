//
//  NSMapTable+GenericPointerFunctions.m
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "NSMapTable+GenericPointerFunctions.h"

@implementation NSMapTable (GenericPointerFunctions)

#pragma mark -
#pragma mark Getting Values


- (void *)pointerForKey: (id)aKey {

    return (__bridge void*)[self objectForKey: aKey];
}

- (id)objectForPointerKey: (const void *)aKey {

    return [self objectForKey: (__bridge id)aKey];
}

- (void *)pointerForPointerKey: (const void *)aKey {

    return (__bridge void*)[self objectForKey: (__bridge id)aKey];
}


#pragma mark -
#pragma mark Setting Values


- (void)setPointer: (const void *)aPointer forKey: (id)aKey {

    [self setObject: (__bridge id)aPointer forKey: aKey];
}

- (void)setObject: (id)anObject forPointerKey: (const void *)aKey {

    [self setObject: anObject forKey: (__bridge id)aKey];
}

- (void)setPointer: (const void *)aPointer forPointerKey: (const void *)aKey {

    [self setObject: (__bridge id)aPointer forKey: (__bridge id)aKey];
}


#pragma mark -
#pragma mark Removing Values


- (void)removePointerForKey:(id)aKey {

    [self removeObjectForKey: aKey];
}

- (void)removeObjectForPointerKey: (const void *)aKey {

    [self removeObjectForKey: (__bridge id)aKey];
}

- (void)removePointerForPointerKey: (const void *)aKey {

    [self removeObjectForKey: (__bridge id)aKey];
}

@end
