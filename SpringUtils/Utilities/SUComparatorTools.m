//
//  SUComparatorTools.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "SUComparatorTools.h"

const NSComparator NSComparatorFromSortDescriptors( NSArray * array ) {
    
    NSArray * descriptors = [NSArray arrayWithArray: array];
    
    return ^NSComparisonResult( id obj1, id obj2 )
    {
        __block NSComparisonResult result = NSOrderedSame;
        
        [descriptors enumerateObjectsUsingBlock: ^( NSSortDescriptor * descriptor, NSUInteger idx, BOOL *stop ) {

            result = [descriptor compareObject: obj1 toObject: obj2];

            if( NSOrderedSame != result )
                *stop = YES;
        }];
        
        return result;
    };
}