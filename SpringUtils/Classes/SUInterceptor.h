//
//  SUInterceptor.h
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

@class SUInterceptor;

/** A block to invoke when intercepting messages.
 *
 *  Be sure to observe 
 *
 *  @param interceptor  The interceptor instance which has intercepted the message.
 *  @param invocation   An NSInvocation representing the intercepted message. 
 *                      The invocation target is the interceptor's `interceptionTarget`, so invoking this object from the block will forward the message.
 *                      You can use this instance to modify the message's target, selector, arguments or return value so long as any modifications
 *                      are compatible with the invocation's method signature.
 *
 *  @returns            A boolean which determines whether or not the invocation should subsequentally be forwarded to the invocation's target.
 */

typedef BOOL(^SUInterceptionBlock)( SUInterceptor * interceptor, NSInvocation * invocation );


/** SUInterceptor is a concrete proxy class which can intercept messages sent to a target with an interception block.
 *
 *  The interception block may change the target of a message, the message parameters or provide its own return value without
 *  forwarding the message to the target at all.
 */

@interface SUInterceptor : NSProxy


/** Constructs a new interceptor with the given target.
 *
 *  The interceptor holds a strong reference to its target.
 *
 *  @param  target  The target which the interceptor should pose as and forward messages to.
 *                  If this parameter is `Nil`, the constructed interceptor does not forward its messages.
 *
 *  @returns        A new interceptor instance which poses as- and forwards messages to the given target.
 */

+ (instancetype)interceptorWithTarget: (id)target;


//-----------------------------------------/
/** @name Getting the Interception Target */
//-----------------------------------------/


/** The target which the receiver forwards non-intercepted and post-intercepted messages to. */

@property ( nonatomic, readonly ) id interceptionTarget;


//-------------------------------------------------/
/** @name Adding and Removing Interception Blocks */
//-------------------------------------------------/


/** Instructs the receiver to intercept messages matching the given selector.
 *
 *  If the described message is already being intercepted, the interception block is replaced by the one
 *  provided.
 *
 *  @param  selector        The selector of the mesage to intercept.
 *  @param  methodSignature The method signature of the message to intercept.
 *  @param  block           A block to be invoked on receiving the described message.
 *                          This block may change the target, selector, return value or parameters of the message.
 *                          If the block returns `YES`, the edited invocation is forwarded to the target after the block returns.
 */

- (void)interceptSelector: (SEL)selector
          methodSignature: (NSMethodSignature *)methodSignature
                withBlock: (SUInterceptionBlock)block;

/** Instructs the receiver to stop intercepting messages matching the given selector.
 *
 *  @param  selector    The selector of the message which should no longer be intercepted.
 */

- (void)removeInterceptionBlockForSelector: (SEL)selector;


@end
