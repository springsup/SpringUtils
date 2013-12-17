//
//  SUDeallocationCallback.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "NSObject+SUDeallocationNotifier.h"

/** SUDeallocationCallback holds the observer block and other data necessary to invoke a deallocation callback. */

__attribute(( visibility( "hidden" ) ))
@interface SUDeallocationCallback : NSObject

/** The object which this deallocation callback is about; the object which is about to be deallocated. */

@property ( nonatomic, unsafe_unretained ) id deallocatingObject;

/** A deallocation observer block to invoke. */

@property ( nonatomic, copy ) SUDeallocationObserver block;

/** A target object to receive the callback selector. */

@property ( nonatomic, weak ) id target;

/** A selector to invoke on the callback target. */

@property ( nonatomic ) SEL selector;

/** Invokes all deallocation callbacks on the receiver (block and target/selector). */

- (void)invoke;

@end