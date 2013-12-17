//
//  NSObject+SUDeallocationNotifier_Internal.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>
#import "SUDeallocationCallback.h"

@interface NSObject (SUDeallocationNotifier_Internal)

/** The deallocation callbacks scheduled on the receiver. */

@property ( nonatomic, strong ) NSMutableDictionary * deallocationCallbacks;

/** Ensures that the given object will invoke its scheduled deallocation callbacks.
 *
 *  @param  object  An object on which deallocation callbacks have been- or are to be scheduled.
 */

+ (void)prepareObjectForDeallocationNotifications: (NSObject *)object;

/** Removes all deallocation callbacks from the given object.
 *
 *  @param  object  An object which is having the all of its previously-scheduled deallocation callbacks removed.
 */

+ (void)removeAllDeallocationNotificationsFromObject: (NSObject *)object;

@end