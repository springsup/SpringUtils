//
//  SUMethodBuilder.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "SUMethodBuilder.h"

#import "../Utilities/SURuntimeAssertions.h"
#import <objc/runtime.h>

@interface SUMethodBuilderArgument : NSObject
{
    @package
    NSString * typeString;
    NSUInteger size;
    NSUInteger alignment;
}
@end

@implementation SUMethodBuilderArgument
@end

@interface SUMethodBuilder ()
{
    NSString * returnTypeString;
    NSString * encodedTypesString;
    
    NSMutableArray * arguments;
    NSUInteger       numberOfArguments;
}
@end

@implementation SUMethodBuilder

#pragma mark -
#pragma mark Factory Methods

+ (instancetype)newMethodWithSelector: (SEL)selector returnType: (const char *)returnType block: (id)block {
    
    // Validate parameters

    SU_ASSERT_NOT_EQUAL( block, Nil );
    
    // Create the new MethodBuilder instance
    
    SUMethodBuilder * builder = [[SUMethodBuilder alloc] initWithSelector: selector returnType: returnType];
    builder->_implementation  = imp_implementationWithBlock( block );

    return builder;
}

+ (instancetype)newMethodWithSelector: (SEL)selector returnType: (const char *)returnType implementation: (IMP)implementation {

    // Validate parameters
    
    SU_ASSERT_NOT_EQUAL( implementation, NULL );
    
    // Create the new MethodBuilder instance
    
    SUMethodBuilder * builder = [[SUMethodBuilder alloc] initWithSelector: selector returnType: returnType];
    builder->_implementation  = implementation;
    
    return builder;
}

#pragma mark -
#pragma mark Initialisation

- (id)initWithSelector: (SEL)selector returnType: (const char *)returnType {

    // Validate parameters
    
    SU_ASSERT_NOT_EQUAL( selector, NULL );
    SU_ASSERT_NOT_EQUAL( returnType, NULL );
    
    // Initialise the object
    
    self = [super init];
    if( self )
    {
        _selector       = selector;
        returnTypeString   = [NSString stringWithUTF8String: returnType];
        
        // Count the number of arguments (i.e. number of colons) in the selector
        
        const char * selectorName = sel_getName(selector);
        for( numberOfArguments = 0;
             selectorName[numberOfArguments];
             selectorName[numberOfArguments] == ':' ? numberOfArguments++ : (uintptr_t)selectorName++ );

        arguments = [[NSMutableArray alloc] initWithCapacity: numberOfArguments];
    }
    
    return self;
}

#pragma mark -
#pragma mark Encoded type string

- (instancetype)setType: (const char *)encodedType forArgumentAtIndex: (NSUInteger)argumentIndex {

    // Validate parameters
    
    SU_ASSERT_NOT_EQUAL( encodedType, NULL );
    SU_ASSERT_LESS_THAN_MSG( argumentIndex, numberOfArguments, @"Invalid argument index %lu. Selector %@ contains %lu arguments.",
                             (unsigned long)argumentIndex, NSStringFromSelector( _selector ), (unsigned long)numberOfArguments );

    // Get the data for the argument type
    
    SUMethodBuilderArgument * argument  = [[SUMethodBuilderArgument alloc] init];
    argument->typeString                = [NSString stringWithUTF8String: encodedType];
    NSGetSizeAndAlignment( encodedType, &( argument->size ), &( argument->alignment ) );
    
    arguments[ argumentIndex ] = argument;
    
    // Invalidate the encoded type string
    
    encodedTypesString = Nil;
    
    return self;
}

- (const char *)encodedTypes {
    
    if( Nil == encodedTypesString )
    {
        // Build the type string if all arguments have been set.

        if( arguments.count == numberOfArguments )
        {
            // Encoding of type parameters follows the LLVM implementation
            // ASTContext::getObjCEncodingForMethodDecl
            // see: http://llvm.org/viewvc/llvm-project/cfe/trunk/lib/AST/ASTContext.cpp?view=markup
            
            NSUInteger pointerSize;
            NSGetSizeAndAlignment( @encode( void* ), &pointerSize, NULL );

            NSMutableString * encodedTypes = [[NSMutableString alloc] init];
            
            // Step 1:
            // Encode return type, total size of all arguments.
            
            [encodedTypes appendString: returnTypeString];
            
            NSUInteger totalSizeOfAllArguments = 2 * pointerSize;
            
            for( SUMethodBuilderArgument * argument in arguments )
            {
                totalSizeOfAllArguments += argument->size;
            }
            
            [encodedTypes appendFormat: @"%lu", (unsigned long)totalSizeOfAllArguments];
            
            // Step 2:
            // Encode built-in self, _cmd pointer arguments.
            
            NSUInteger argumentOffset = 0;
            
            argumentOffset = [SUMethodBuilder appendTypeString: @"@" toString: encodedTypes offset: argumentOffset];
            argumentOffset = [SUMethodBuilder appendTypeString: @":" toString: encodedTypes offset: argumentOffset];
            
            // Step 3:
            // Encode all other arguments.
            
            for( SUMethodBuilderArgument * argument in arguments )
            {
                argumentOffset = [SUMethodBuilder appendTypeString: argument->typeString
                                                              size: argument->size
                                                         alignment: argument->alignment
                                                          toString: encodedTypes
                                                            offset: argumentOffset];
            }

            encodedTypesString = encodedTypes;
        }
        else
        {
            // We don't have type information for all arguments.
            // Return NULL.
            
            return NULL;
        }
    }
    
    return [encodedTypesString UTF8String];
}

+ (NSUInteger)appendTypeString: (NSString *)typeString toString: (NSMutableString *)str offset: (NSUInteger)offset {
    
    NSUInteger size, alignment;
    NSGetSizeAndAlignment( typeString.UTF8String, &size, &alignment );
    
    return [SUMethodBuilder appendTypeString: typeString
                                        size: size
                                   alignment: alignment
                                    toString: str
                                      offset: offset];
}

+ (NSUInteger)appendTypeString: (NSString *)typeString
                          size: (NSUInteger)size
                     alignment: (NSUInteger)alignment
                      toString: (NSMutableString *)str
                        offset: (NSUInteger)offset {
 
    // Align the offset to the type's alignment value
    
    if( alignment != 0 )
    {
        alignment  -= 1;
        offset      = ( offset + alignment ) & ~alignment;
    }
    
    // Write the type string followed by its offset
    
    [str appendFormat: @"%@%lu", typeString, (long)offset];
 
    // Return the new offset
    
    return offset + size;
}

@end
