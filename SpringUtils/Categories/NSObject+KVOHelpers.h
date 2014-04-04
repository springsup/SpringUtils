//
//  NSObject+Helpers.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

@interface NSObject (Helpers)

/** Invokes the given block, notifying the receiver's observers of changes to the specified key.
 *
 *  You should invoke this method when implementing key-value observer compliance manually.
 *  The change type of this method is NSKeyValueChangeSetting.
 *
 *  @param  key                 The name of the property that will change. This parameter may not be Nil.
 *  @param  keyMutationBlock    A block whose effect is to change the value represented by `key`.
 */

- (void) updateKey: (NSString *)key
         withBlock: (void(^)(void))keyMutationBlock;

@end
