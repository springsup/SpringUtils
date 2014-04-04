//
//  NSSet+Initialisers.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "NSSet+Initialisers.h"

@implementation NSSet (Initialisers)

+ (instancetype)newSetWithIntersectionOfSets: (NSSet *)firstSet, ... {
    
    va_list   sets;
    va_start( sets, firstSet );
    
    NSMutableSet * totalSet = [[NSMutableSet alloc] initWithCapacity: firstSet.count];
    
    // Seed the total set with data from one set
    
    [totalSet unionSet: firstSet];
    
    // Intersect subsequent sets
    
    NSSet * argSet = Nil;
    while (( argSet = va_arg( sets, NSSet* ) ))
    {
        [totalSet intersectSet: argSet];
    }
    
    va_end( sets );
    return totalSet;
}

+ (instancetype)newSetWithUnionOfSets: (NSSet *)firstSet, ... {

    va_list   sets;
    va_start( sets, firstSet );
    
    NSMutableSet * totalSet = [[NSMutableSet alloc] init];
    
    // Union all sets in to the total set
    
    for ( NSSet * arg = firstSet; Nil != arg; arg = va_arg( sets, NSSet* ) )
    {
        [totalSet unionSet: arg];
    }
    
    va_end  ( sets );
    
    return totalSet;
}

@end
