//
//  NSObject+KVOSelectors.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

@interface NSObject (KVOSelectors)

/** Creates a new KVO observation calling a selector on a given target.
 *
 *  @param  keyPath     The key path, relative to the receiver, of the property to observe. This parameter must not be Nil.
 *  @param  target      The target object which should receive a message when the keyPath value changes.
 *  @param  selector    The selector of the message the target should receive. If this selector takes any arguments, the first argument
 *                      should be a pointer to this object.
 *
 *  @returns            An opaque token which represents the KVO observation. The observation is removed when this object is deallocated.
 */

- (id)observeKeyPath: (NSString *)keyPath withTarget: (__weak id)target selector: (SEL)selector;

/** Unregisters a KVO selector observation from receiving change notifications.
 *
 *  @param  observationToken    The observation token representing the KVO observation to be stopped.
 *                              The token may be disposed of once this message has returned.
 *
 */

- (void)stopObservingKeyPath: (id)observationToken;

@end
