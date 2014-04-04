//
//  SUClassBuilder.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "SUClassBuilder.h"

#import "../Utilities/SURuntimeAssertions.h"
#import <objc/runtime.h>

@interface SUClassBuilder ()
{
    Class class;
    BOOL  classWasRegistered;
}
@end

@implementation SUClassBuilder

+ (instancetype)newClassNamed: (NSString *)className superClass: (Class)superClass {
    
    // Validate parameters
    
    SU_ASSERT_NSSTRING( className );
    SU_ASSERT_NOT_EQUAL( superClass, Nil );
    
    // Try to create the new Class
    
    Class newClass = objc_allocateClassPair( superClass, [className UTF8String], 0 );
    
    if( Nil == newClass )
    {
        // Unable to create the class.
        // e.g. a class with the desired name already exists.
        
        return Nil;
    }
    else
    {
        // Class created successfully.
        // Return a class builder instance for the new class.
        
        SUClassBuilder * newClassBuilder    = [[SUClassBuilder alloc] init];
        newClassBuilder->class              = newClass;

        return newClassBuilder;
    }
}

- (void)dealloc {
    
    if( NO == classWasRegistered )
    {
        // The class has not been registed and is invalid for use.
        // Dispose of it.
        
        objc_disposeClassPair( class );
    }
}

- (Class)registerClass {
    
    if( NO == classWasRegistered )
    {
        objc_registerClassPair( class );
        classWasRegistered = YES;
    }

    return class;
}

#pragma mark -
#pragma mark Adding Instance Variables

- (instancetype)addObjectIvar: (NSString *)ivarName {
    
    return [self addIvar: ivarName type: @encode( id )];
}

- (instancetype)addIvar: (NSString *)ivarName type: (const char *)typeEncoding {

    // Validate parameters
    
    SU_ASSERT_NSSTRING( ivarName );
    SU_ASSERT_NOT_EQUAL( typeEncoding, NULL );
    
    // Ensure class has not been registered already
    
    SU_ASSERT_NOT_EQUAL_MSG( classWasRegistered, YES, @"Instance variables cannot be added once a class has been registered" );
    
    // Add the iVar
    
    NSUInteger size, alignment;
    NSGetSizeAndAlignment( typeEncoding, &size, &alignment );
    class_addIvar( class, [ivarName UTF8String], size, alignment, typeEncoding );
    
    return self;
}

#pragma mark -
#pragma mark Adding Instance Methods

- (instancetype)addInstanceMethod: (SUMethodBuilder *)methodBuilder {
    
    return [self addInstanceMethod: methodBuilder.selector
                             types: methodBuilder.encodedTypes
                    implementation: methodBuilder.implementation];
}

- (instancetype)addInstanceMethod: (SEL)selector types: (const char *)types block: (id)block {
 
    return [self addInstanceMethod: selector
                             types: types
                    implementation: imp_implementationWithBlock( block )];
}

- (instancetype)addInstanceMethod: (SEL)selector types: (const char *)types implementation: (IMP)implementation {
    
    // Validate parameters
    
    SU_ASSERT_NOT_EQUAL( selector, NULL );
    SU_ASSERT_NOT_EQUAL( types, NULL );
    SU_ASSERT_NOT_EQUAL( implementation, NULL );
    
    // Add the method
    
    class_addMethod( class, selector, implementation, types );
    return self;
}

#pragma mark -
#pragma mark Adding Class Methods

- (instancetype)addClassMethod: (SUMethodBuilder *)methodBuilder {
    
    return [self addClassMethod: methodBuilder.selector
                          types: methodBuilder.encodedTypes
                 implementation: methodBuilder.implementation];
}

- (instancetype)addClassMethod: (SEL)selector types: (const char *)types block: (id)block {

    return [self addClassMethod: selector
                          types: types
                 implementation: imp_implementationWithBlock( block )];
}

- (instancetype)addClassMethod: (SEL)selector types: (const char *)types implementation: (IMP)implementation {

    // Validate parameters
    
    SU_ASSERT_NOT_EQUAL( selector, NULL );
    SU_ASSERT_NOT_EQUAL( types, NULL );
    SU_ASSERT_NOT_EQUAL( implementation, NULL );
    
    // Add the method
    
    Class metaClass = object_getClass( class );
    class_addMethod( metaClass, selector, implementation, types );
    return self;
}

@end
