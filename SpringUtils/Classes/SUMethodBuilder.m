//
//  SUMethodBuilder.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "SUMethodBuilder_Private.h"

#import "../Utilities/SURuntimeAssertions.h"
#import <objc/runtime.h>


@implementation SUMethodBuilder


#pragma mark -
#pragma mark Factory Methods


+ (instancetype)newMethodWithSelector: (SEL)selector block: (id)block {
    
    // Validate parameters.

    SU_ASSERT_NOT_EQUAL( block, Nil );
    
    // Create the new MethodBuilder instance.
    
    SUMethodBuilder * builder    = [[SUMethodBuilder alloc] initWithSelector: selector];
    builder->_implementation     = imp_implementationWithBlock( block );
    builder->impCreatedWithBlock = YES;

    return builder;
}

+ (instancetype)newMethodWithSelector: (SEL)selector returnType: (const char *)returnType block: (id)block {

    // Validate parameters.

    SU_ASSERT_NOT_EQUAL( returnType, NULL );

    // Create the new MethodBuilder instance.

    SUMethodBuilder * builder = [SUMethodBuilder newMethodWithSelector: selector block: block];
    builder.returnType        = returnType;

    return builder;
}

+ (instancetype)newMethodWithSelector: (SEL)selector implementation: (IMP)implementation {

    // Validate parameters.
    
    SU_ASSERT_NOT_EQUAL( implementation, NULL );
    
    // Create the new MethodBuilder instance.
    
    SUMethodBuilder * builder = [[SUMethodBuilder alloc] initWithSelector: selector];
    builder->_implementation  = implementation;
    
    return builder;
}

+ (instancetype)newMethodWithSelector: (SEL)selector returnType: (const char *)returnType implementation: (IMP)implementation {

    // Validate parameters.

    SU_ASSERT_NOT_EQUAL( returnType, NULL );

    // Create the new MethodBuilder instance.

    SUMethodBuilder * builder = [SUMethodBuilder newMethodWithSelector: selector implementation: implementation];
    builder.returnType        = returnType;

    return builder;
}


#pragma mark -
#pragma mark Initialization


- (id)initWithSelector: (SEL)selector {

    // Validate parameters
    
    SU_ASSERT_NOT_EQUAL( selector, NULL );

    // Initialise the object
    
    self = [super init];
    if( self )
    {
        _selector = selector;

        // Count the number of arguments (i.e. number of colons) in the selector
        
        const char * selectorName = sel_getName(selector);
        for( _numberOfArgumentsInSelector = 0;
             selectorName[_numberOfArgumentsInSelector];
             selectorName[_numberOfArgumentsInSelector] == ':' ? _numberOfArgumentsInSelector++ : (uintptr_t)selectorName++ );
    }
    
    return self;
}

- (void)dealloc {

    // Release the implementation block if it has not been consumed by an SUClassBuilder.

    if( impCreatedWithBlock && ( NO == impHasBeenConsumed ) )
    {
        imp_removeBlock( _implementation );
    }
}


#pragma mark -
#pragma mark NSCopying


- (id)copyWithZone: (NSZone *)zone {

    SUMethodBuilder * copy              = [super copyWithZone: zone];
    copy->_selector                     = _selector;
    copy->_numberOfArgumentsInSelector  = _numberOfArgumentsInSelector;

    if( impCreatedWithBlock )
    {
        id block                    = imp_getBlock( _implementation );
        copy->_implementation       = imp_implementationWithBlock( block );
        copy->impCreatedWithBlock   = YES;
        copy->impHasBeenConsumed    = NO;
    }
    else
    {
        copy->_implementation       = _implementation;
        copy->impCreatedWithBlock   = NO;
        copy->impHasBeenConsumed    = NO;
    }

    return copy;
}


#pragma mark -
#pragma mark Method Signature


- (const char *)encodedTypeSignature {

    if( self.numberOfParameters < _numberOfArgumentsInSelector )
    {
        return NULL;
    }
    else
    {
        return super.encodedTypeSignature;
    }
}

- (NSMethodSignature *)methodSignature {

    if( self.numberOfParameters < _numberOfArgumentsInSelector )
    {
        return Nil;
    }
    else
    {
        return super.methodSignature;
    }
}


#pragma mark -
#pragma mark Parameter Types


- (void)setType: (const char *)encodedType ofParameterAtIndex: (NSUInteger)parameterIndex {

    // Validate parameters.

    SU_ASSERT_LESS_THAN_MSG( parameterIndex, _numberOfArgumentsInSelector, @"Invalid parameter index %lu. Selector %@ contains %lu parameter.",
                             (unsigned long)parameterIndex, NSStringFromSelector( _selector ), (unsigned long)_numberOfArgumentsInSelector );

    // Set the parameter type.

    [super setType: encodedType ofParameterAtIndex: parameterIndex];
}

- (void)setType: (const char *)encodedType size: (NSUInteger)size ofParameterAtIndex: (NSUInteger)parameterIndex {

    // Validate parameters.

    SU_ASSERT_LESS_THAN_MSG( parameterIndex, _numberOfArgumentsInSelector, @"Invalid parameter index %lu. Selector %@ contains %lu parameter.",
                             (unsigned long)parameterIndex, NSStringFromSelector( _selector ), (unsigned long)_numberOfArgumentsInSelector );

    // Set the parameter type.

    [super setType: encodedType size: size ofParameterAtIndex: parameterIndex];
}

- (void)setType: (const char *)encodedType flags: (SUMethodParameterFlags)parameterFlags ofParameterAtIndex: (NSUInteger)parameterIndex {

    // Validate parameters.

    SU_ASSERT_LESS_THAN_MSG( parameterIndex, _numberOfArgumentsInSelector, @"Invalid parameter index %lu. Selector %@ contains %lu parameter.",
                             (unsigned long)parameterIndex, NSStringFromSelector( _selector ), (unsigned long)_numberOfArgumentsInSelector );

    // Set the parameter type.

    [super setType: encodedType flags: parameterFlags ofParameterAtIndex: parameterIndex];
}

- (void)setType: (const char *)encodedType size: (NSUInteger)size flags: (SUMethodParameterFlags)parameterFlags ofParameterAtIndex: (NSUInteger)parameterIndex {

    // Validate parameters.

    SU_ASSERT_LESS_THAN_MSG( parameterIndex, _numberOfArgumentsInSelector, @"Invalid parameter index %lu. Selector %@ contains %lu parameter.",
                             (unsigned long)parameterIndex, NSStringFromSelector( _selector ), (unsigned long)_numberOfArgumentsInSelector );

    // Set the parameter type.

    [super setType: encodedType size: size flags: parameterFlags ofParameterAtIndex: parameterIndex];
}


@end
