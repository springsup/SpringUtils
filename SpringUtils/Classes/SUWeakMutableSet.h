//
//  SUWeakMutableSet.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

/** A set which does not hold strong references to its members and automatically removes them when they are deallocated.
 *
 *  Objects may be freely added or removed from the set from any queue. Objects which are added to the set may be freely
 *  retained or released from any queue.
 *
 *  To access the set contents, use the `set` property. This property returns a copy of the set which _will_ retain its members,
 *  ensuring that the set remains immutable and its members refrain from deallocating while it is in scope.
 *
 *  __Important:__ Toll-free-bridged types such as NSString, NSNumber, NSArray, NSDictionary and NSSet cannot be
 *  added to this set. An exception will be raised you attempt to insert a bridged object in to the set.
 */

@interface SUWeakMutableSet : NSObject

/** Returns an initialised weak mutable set with a given initial capacity.
 *
 *  Mutable sets allocate additional memory as needed, so `capacity` simply establishes the object’s initial capacity.
 *  This method is a designated initializer for SUMutableWeakSet.
 *
 *  @param  capacity    The initial capacity of the set.
 *
 *  @returns            An initialized mutable weak set with initial capacity to hold `capacity` members.
 *                      The returned set might be different than the original receiver.
 */

- (id)initWithCapacity: (NSUInteger)capacity;


/** @name Counting Entries  */


/** The number of members in the set. */

@property ( nonatomic ) NSUInteger count;


/** @name Accessing Members of the Set */

/** Returns the set of members in the receiver.
 *
 *  The returned object retains its members to ensure immutability from deallocations in other queues.
 */

@property ( nonatomic, copy, readonly ) NSSet * set;


- (void)accessSet: ( void(^)(NSSet * set) )accessBlock;


/** @name Adding and Removing Entries */


/** Adds a given object to the set, if it is not already a member.
 *
 *  @param  object      The object to add to the set.
 */

- (void)addObject: (id)object;

/** Removes a given object from the set.
 *
 *  @param  object      The object to remove from the set.
 */

- (void)removeObject: (id)object;

/** Empties the set of all its members. */

- (void)removeAllObjects;

@end