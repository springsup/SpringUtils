//
//  NSSet+Initialisers.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

@interface NSSet (Initialisers)

/** Creates a new set consisting of all the objects common to the specified list of sets.
 *
 *  @param  firstSet,...        A comma-separated list of sets, ending with Nil, to intersect.
 *
 *  @returns                    A newly allocated set which is the intersection of the sets specified in the parameter list.
 */

+ (NSSet *)newSetWithIntersectionOfSets: (NSSet *)firstSet, ... NS_REQUIRES_NIL_TERMINATION;

/** Creates a new set consisting of all the objects contained in the specified list of sets.
 *
 *  @param  firstSet,...        A comma-separated list of sets, ending with Nil, to union.
 *
 *  @returns                    A newly allocated set which is the union of the sets specified in the parameter list.
 */

+ (NSSet *)newSetWithUnionOfSets:        (NSSet *)firstSet, ... NS_REQUIRES_NIL_TERMINATION;

@end
