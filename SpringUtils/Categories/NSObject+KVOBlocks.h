//
//  NSObject+KVOBlocks.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

@interface NSObject (KVOBlocks)

/** Registers observerBlock to receive KVO notifications for the specified key-path relative to the receiver.
 *
 *  @param  observerBlock   The block to invoke when the receiver notified of changes to value at the given key-path.
 *  @param  keyPath         The key path, relative to the receiver, of the property to observe. This parameter must not be Nil.
 *  @param  options         A combination of the NSKeyValueObservingOptions values that specifies what is included in observation
 *                          notifications.
 *
 *  @returns                An opaque token which represents the KVO observation. The observation is removed when this object is deallocated.
 */

- (id)addObserverBlock: (void(^)( NSObject * object, NSString * keyPath, NSDictionary * change ))observerBlock
            forKeyPath: (NSString *)keyPath
               options: (NSKeyValueObservingOptions)options NS_RETURNS_RETAINED;

/** Unregisters a KVO block observation from receiving change notifications.
 *
 *  @param  blockToken  The observation token representing the KVO observation to be stopped. 
 *                      The token may be disposed of once this message has returned.
 *
 */

+ (void)removeObserverBlock: (id)blockToken;

@end
