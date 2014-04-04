//
//  NSObject+Helpers.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "NSObject+KVOHelpers.h"

@implementation NSObject (Helpers)

- (void) updateKey: (NSString *)key
         withBlock: (void(^)(void))keyMutationBlock {

    NSAssert( Nil != key, @"Invalid key: key cannot be Nil" );
    
    [self willChangeValueForKey: key];
    
    if( keyMutationBlock )
    {
        keyMutationBlock();
    }
    
    [self didChangeValueForKey: key];
}

@end
