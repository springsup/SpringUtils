//
//  NSObject+SUDeallocationNotifier.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

typedef void(^SUDeallocationObserver)( __unsafe_unretained id deallocatingObject );

@interface NSObject (SUDeallocationNotifier)


/** @name   Scheduling Deallocation Notifications  */


/** Schedules a block to be invoked just before the receiver is deallocated.
 *
 *  The block is invoked before the receiver starts to deallocate, so the deallocating object is
 *  guaranteed to be in an valid state.
 *
 *  If the receiver's lifetime depends on retains and releases from multiple threads, the block will be
 *  invoked from the thread on which the receiver is last released.
 *
 *  __Important:__ The scheduled block should observe [best practices relating to overriding dealloc][dealloc practices],
 *  and must not perform any unbalanced retains on the deallocating object and must not retain it from 
 *  a thread other than the which the block is invoked on.
 *
 *  Adding deallocation notifiers to toll-free-bridged classes is unsupported and raises an exception.
 *
 *  [dealloc practices]: https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmPractical.html#//apple_ref/doc/uid/TP40004447-SW13
 *
 *  @param  observer    The block to invoke. May not be Nil.
 *  @param  key         The key used to reference the scheduled block.
 *                      If this parameter is Nil, the block itself acts as the key.
 *
 **/

- (void)addDeallocationNotification: (SUDeallocationObserver)observer forKey: (id<NSCopying>)key;

/** Schedules a callback to be invoked just before the receiver is deallocated.
 *
 *  The callback is invoked before the receiver starts to deallocate, so the deallocating object is
 *  guaranteed to be in an valid state.
 *
 *  If the receiver's lifetime depends on retains and releases from multiple threads, the callback will be
 *  invoked from the thread on which the receiver is last released.
 *
 *  __Important:__ The callback method should observe [best practices relating to overriding dealloc][dealloc practices],
 *  and must not perform any unbalanced retains on the deallocating object and must not retain it from
 *  a thread other than the which the callback is invoked on.
 *
 *  Adding deallocation notifiers to toll-free-bridged classes is unsupported and raises an exception.
 *
 *  [dealloc practices]: https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmPractical.html#//apple_ref/doc/uid/TP40004447-SW13
 *
 *  @param  target      The target object. May not be Nil.
 *  @param  selector    The selector to invoke. May not be NULL. 
 *                      If the selector has arguments, the first argument is the deallocating object.
 *  @param  key         The key used to reference the scheduled target/selector. May not be Nil.
 *
 **/

- (void)addDeallocationNotificationTarget: (id)target selector: (SEL)selector forKey: (id<NSCopying>)key;


/** @name   Removing Deallocation Notifications  */


/** Removes a scheduled deallocation notification.
 *
 *  @param  key         The key used to reference the scheduled deallocation notification. May not be Nil.
 *
 **/

- (void)removeDeallocationNotificationForKey: (id<NSCopying>)key;

@end
