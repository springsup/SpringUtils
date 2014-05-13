//
//  SUInterceptor.m
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "SUInterceptor.h"
#import "../Utilities/SURuntimeAssertions.h"
#import "../Categories/NSMapTable+GenericPointerFunctions.h"

@interface SUInterceptorInterceptionData : NSObject
{
    @package
    SUInterceptionBlock interceptionBlock;
    NSMethodSignature * methodSignature;
}
@end

@implementation SUInterceptorInterceptionData
@end


//=====================


@implementation SUInterceptor
{
    NSMapTable * _interceptionBlocksBySelector;
}


#pragma mark -
#pragma mark Initialization


+ (instancetype)interceptorWithTarget: (id)target {

    return [[SUInterceptor alloc] initWithTarget: target];
}

- (instancetype)initWithTarget: (id)target {

    _interceptionTarget = target;
    _interceptionBlocksBySelector = [[NSMapTable alloc] initWithKeyOptions: NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality
                                                              valueOptions: NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality
                                                                  capacity: 16];

    return self;
}


#pragma mark -
#pragma mark Message Forwarding


- (BOOL)respondsToSelector: (SEL)aSelector {

    if( Nil != [self _interceptionDataForSelector: aSelector] )
        return YES;

    return [_interceptionTarget respondsToSelector: aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector: (SEL)aSelector {

    SUInterceptorInterceptionData * interceptionData = [self _interceptionDataForSelector: aSelector];

    if( Nil != interceptionData )
    {
        return interceptionData->methodSignature;
    }

    return [_interceptionTarget methodSignatureForSelector: aSelector];
}

- (void)forwardInvocation: (NSInvocation *)anInvocation {

    BOOL shouldForward  = YES;
    anInvocation.target = _interceptionTarget;

    // Invoke the interception block if there is one.

    SUInterceptorInterceptionData * interceptionData = [self _interceptionDataForSelector: anInvocation.selector];

    if( Nil != interceptionData )
    {
        shouldForward = interceptionData->interceptionBlock( self, anInvocation );
    }

    // Forward the invocation if the target responds to it.
    // Messages which we don't intercept will go through the fast-path anyway and raise an exception.

    if( shouldForward && [anInvocation.target respondsToSelector: anInvocation.selector] )
    {
        [anInvocation invoke];
    }
}

- (id)forwardingTargetForSelector: (SEL)aSelector {

    // Fast path: Building an NSInvocation is slow, so forwardInvocation:
    //            only gets called if we return Nil or self here.
    //
    //            Return the forwarding target and be transparent for all selectors we don't intercept.

    if( Nil != [self _interceptionDataForSelector: aSelector] )
    {
        return Nil;
    }

    return _interceptionTarget;
}


#pragma mark -
#pragma mark Interception Blocks


- (SUInterceptorInterceptionData *)_interceptionDataForSelector: (SEL)selector {

    SUInterceptorInterceptionData * interceptionData = [_interceptionBlocksBySelector objectForPointerKey: selector];

    return interceptionData;
}

- (void)interceptSelector: (SEL)selector methodSignature: (NSMethodSignature *)methodSignature withBlock: (SUInterceptionBlock)block {

    if( Nil == block )
    {
        [self removeInterceptionBlockForSelector: selector];
    }
    else
    {
        SU_ASSERT_NOT_EQUAL( selector, NULL );
        SU_ASSERT_NOT_NIL( methodSignature );

        SUInterceptorInterceptionData * interceptionData = [_interceptionBlocksBySelector objectForPointerKey: selector];

        if( Nil == interceptionData )
        {
            interceptionData = [[SUInterceptorInterceptionData alloc] init];
            [_interceptionBlocksBySelector setObject: interceptionData forPointerKey: selector];
        }

        interceptionData->methodSignature   = methodSignature;
        interceptionData->interceptionBlock = [block copy];
    }
}

- (void)removeInterceptionBlockForSelector: (SEL)selector {

    SU_ASSERT_NOT_EQUAL( selector, NULL );

    [_interceptionBlocksBySelector removeObjectForPointerKey: selector];
}


#pragma mark -
#pragma mark Description


- (NSString *)description {

    BOOL shouldForward = YES;

    SUInterceptorInterceptionData * interceptionData = [self _interceptionDataForSelector: _cmd];
    if( Nil != interceptionData )
    {
        NSInvocation * inv = [NSInvocation invocationWithMethodSignature: interceptionData->methodSignature];
        inv.selector       = _cmd;
        inv.target         = _interceptionTarget;
        shouldForward      = interceptionData->interceptionBlock( self, inv );

        if( NO == shouldForward )
        {
            __autoreleasing id retVal;
            [inv getReturnValue: &retVal];
            return retVal;
        }
    }

    if( shouldForward )
    {
        // We do not need to read arguments from the invocation because there are no arguments to this selector.

        return [_interceptionTarget description];
    }

    __builtin_unreachable();
}

- (NSString *)debugDescription {

    NSMutableString * mString = [[NSMutableString alloc] init];

    [mString appendFormat: @"%@ ", [super description]];

    if( _interceptionBlocksBySelector.count > 0 )
    {
        [mString appendString: @"Intercepting { "];

        for( id _interceptedSelector in _interceptionBlocksBySelector )
        {
            SEL interceptedSelector = (__bridge void*)_interceptedSelector;
            [mString appendFormat: @"%@, ", NSStringFromSelector( interceptedSelector )];
        }
        [mString deleteCharactersInRange: NSMakeRange( mString.length - 2, 2 )];

        [mString appendString: @" } "];
    }

    [mString appendFormat: @"=> %@", [_interceptionTarget debugDescription]];

    return mString;
}

@end
