//
//  SUDeallocationCallback.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "SUDeallocationCallback.h"

@implementation SUDeallocationCallback

- (void)invoke {

    if( Nil != _block )
    {
        _block( _deallocatingObject );
    }
    
    if( ( Nil != _target ) && ( NULL != _selector ) )
    {
        NSMethodSignature * callbackSignature = [_target methodSignatureForSelector: _selector];
        NSInvocation      * callback          = [NSInvocation invocationWithMethodSignature: callbackSignature];
        
        callback.target   = _target;
        callback.selector = _selector;
        
        if( callbackSignature.numberOfArguments > 2 )
        {
            [callback setArgument: &_deallocatingObject
                          atIndex: 2];
        }
        
        [callback invoke];
    }
}

@end