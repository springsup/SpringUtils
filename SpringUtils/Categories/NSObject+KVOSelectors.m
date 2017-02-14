//
//  NSObject+KVOSelectors.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "NSObject+KVOSelectors.h"

#import "NSObject+KVOBlocks.h"

@implementation NSObject (KVOSelectors)

- (id)observeKeyPath: (NSString *)keyPath withTarget: (__weak id)target selector: (SEL)selector {
    
    // Verify the parameters
    
    if( Nil == target )
    {
        [[NSException exceptionWithName: NSInvalidArgumentException
                                 reason: @"Invalid target: Target may not be Nil"
                               userInfo: Nil] raise];
    }
    
    if( 0 == selector )
    {
        [[NSException exceptionWithName: NSInvalidArgumentException
                                 reason: @"Invalid selector: Selector may not be Nil"
                               userInfo: Nil] raise];
    }

    // Create an invocation instance
    
    NSMethodSignature * method   = [target methodSignatureForSelector: selector];
    NSInvocation * invocation    = [NSInvocation invocationWithMethodSignature: method];
    invocation.selector          = selector;
    
    // Obj-C runtime arguments self (i.e. target) and __cmd.
    const NSUInteger argumentsOffset = 2;
    
    // Set the first argument to this instance
    
    if( method.numberOfArguments > argumentsOffset )
    {
        [invocation setArgument: (__bridge void *)self atIndex: argumentsOffset];
    }
    
    // Add an observer block which invokes the target
    
    id observationToken = [self addObserverBlock:
                           
                           ^( NSObject *object, NSString *keyPath, NSDictionary *change ) {
        
                               if( Nil != target )
                               {
                                   [invocation invokeWithTarget: target];
                               }
                               //else
                                   // Target was deallocated
                           }
                                      forKeyPath: keyPath
                                         options: 0];
    return observationToken;
}

- (void)stopObservingKeyPath:(id)observationToken {
    
    [NSObject removeObserverBlock: observationToken];
}

@end
