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
#import "SUMethodBuilder_Private.h"
#import <objc/runtime.h>

@interface SUClassBuilder ()
{
    Class class;
    BOOL  classWasRegistered;

    NSMapTable * _blockBackedInstaceMethodIMPsBySelector;
    NSMapTable * _blockBasedClassMethodIMPsBySelector;
}
@end

@implementation SUClassBuilder


#pragma mark -
#pragma mark Initialization


+ (instancetype)newClassNamed: (NSString *)className superClass: (Class)superClass {
    
    // Validate parameters
    
    SU_ASSERT_NSSTRING( className );

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
        
        SUClassBuilder * newClassBuilder    = [[SUClassBuilder alloc] _init];
        newClassBuilder->class              = newClass;

        return newClassBuilder;
    }
}

- (id)init {

    _SU_THROW_WITH_REASON( @"Invalid Initializer. Use one of the dedicated initializer methods." )
    __builtin_unreachable();
}

- (id)_init __attribute__((objc_method_family(init))) {

    self = [super init];
    if( self )
    {
        _blockBackedInstaceMethodIMPsBySelector = [[NSMapTable alloc] initWithKeyOptions: NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality
                                                                            valueOptions: NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality
                                                                                capacity: 10];
        _blockBasedClassMethodIMPsBySelector    = [[NSMapTable alloc] initWithKeyOptions: NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality
                                                                            valueOptions: NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality
                                                                                capacity: 10];
    }

    return self;
}

- (void)dealloc {
    
    if( NO == classWasRegistered )
    {
        // The class has not been registed and is invalid for use.
        // Dispose of it.
        
        objc_disposeClassPair( class );

        // Release all block-backed IMPs.

        _releaseAllBlockBackedIMPs( _blockBackedInstaceMethodIMPsBySelector );
        _releaseAllBlockBackedIMPs( _blockBasedClassMethodIMPsBySelector );
    }
}


#pragma mark -
#pragma mark Class Registration


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


- (Ivar)addObjectIvar: (NSString *)ivarName {
    
    return [self addIvar: ivarName type: @encode( id )];
}

- (Ivar)addIvar: (NSString *)ivarName type: (const char *)typeEncoding {

    // Validate parameters
    
    SU_ASSERT_NSSTRING( ivarName );
    SU_ASSERT_NOT_EQUAL( typeEncoding, NULL );
    
    // Ensure class has not been registered already
    
    SU_ASSERT_NOT_EQUAL_MSG( classWasRegistered, YES, @"Instance variables cannot be added once a class has been registered" );
    
    // Add the iVar
    
    NSUInteger size, alignment;
    NSGetSizeAndAlignment( typeEncoding, &size, &alignment );

    if( class_addIvar( class, [ivarName UTF8String], size, alignment, typeEncoding ) )
    {
        return class_getInstanceVariable( class, [ivarName UTF8String] );
    }

    return Nil;
}


#pragma mark -
#pragma mark Adding Instance Methods


- (void)addInstanceMethod: (SUMethodBuilder *)methodBuilder {

    // Copy the method builder so that we create a new block-backed IMP for this instance method.

    if( methodBuilder->impCreatedWithBlock )
    {
        methodBuilder = [methodBuilder copy];
    }

    // Add the instance method.

    [self _addInstanceMethod: methodBuilder.selector
                       types: methodBuilder.encodedTypeSignature
              implementation: methodBuilder.implementation
                     isBlock: methodBuilder->impCreatedWithBlock];

    // Inform the method builder copy that we are now managing the IMP-block's lifetime.

    methodBuilder->impHasBeenConsumed = YES;
}

- (void)addInstanceMethod: (SEL)selector types: (const char *)types block: (id)block {

    [self _addInstanceMethod: selector
                       types: types
              implementation: imp_implementationWithBlock( block )
                     isBlock: YES];
}

- (void)addInstanceMethod: (SEL)selector types: (const char *)types implementation: (IMP)implementation {

    [self _addInstanceMethod: selector
                       types: types
              implementation: implementation
                     isBlock: NO];
}

- (void)_addInstanceMethod: (SEL)selector types: (const char*)types implementation: (IMP)implementation isBlock: (BOOL)isBlock {

    // Validate parameters

    SU_ASSERT_NOT_EQUAL( selector, NULL );
    SU_ASSERT_NOT_EQUAL( types, NULL );
    SU_ASSERT_NOT_EQUAL( implementation, NULL );

    // Add the method

    class_replaceMethod( class, selector, implementation, types );

    // If this instance method was previously mapped to a block-backed IMP, release the old block.

    _releaseBlockBackedIMPForSelector( _blockBackedInstaceMethodIMPsBySelector, selector );

    // If this instance method is mapped to a block-backed IMP, mark it so we can release the block later if neccessary.

    if( isBlock )
    {
        _markBlockBackedIMPForSelector( _blockBackedInstaceMethodIMPsBySelector, selector, implementation );
    }
}


#pragma mark -
#pragma mark Adding Class Methods


- (void)addClassMethod: (SUMethodBuilder *)methodBuilder {

    // Copy the method builder so that we create a new block-backed IMP for this instance method.

    if( methodBuilder->impCreatedWithBlock )
    {
        methodBuilder = [methodBuilder copy];
    }

    // Add the class method.

    [self _addClassMethod: methodBuilder.selector
                    types: methodBuilder.encodedTypeSignature
           implementation: methodBuilder.implementation
                  isBlock: methodBuilder->impCreatedWithBlock];

    // Inform the method builder copy that we are now managing the IMP-block's lifetime.

    methodBuilder->impHasBeenConsumed = YES;
}

- (void)addClassMethod: (SEL)selector types: (const char *)types block: (id)block {

    [self _addClassMethod: selector
                    types: types
           implementation: imp_implementationWithBlock( block )
                  isBlock: YES];
}

- (void)addClassMethod: (SEL)selector types: (const char *)types implementation: (IMP)implementation {

    [self _addClassMethod: selector
                    types: types
           implementation: implementation
                  isBlock: NO];
}

- (void)_addClassMethod: (SEL)selector types: (const char *)types implementation: (IMP)implementation isBlock: (BOOL)isBlock {

    // Validate parameters
    
    SU_ASSERT_NOT_EQUAL( selector, NULL );
    SU_ASSERT_NOT_EQUAL( types, NULL );
    SU_ASSERT_NOT_EQUAL( implementation, NULL );
    
    // Add the method
    
    Class metaClass = object_getClass( class );
    class_replaceMethod( metaClass, selector, implementation, types );

    // If this class method was previously mapped to a block-backed IMP, release the old block.

    _releaseBlockBackedIMPForSelector( _blockBasedClassMethodIMPsBySelector, selector );

    // If this class method is mapped to a block-backed IMP, mark it so we can release the block later if neccessary.

    if( isBlock )
    {
        _markBlockBackedIMPForSelector( _blockBasedClassMethodIMPsBySelector, selector, implementation );
    }
}


#pragma mark -
#pragma mark Block-backed IMP tables


static void _releaseBlockBackedIMPForSelector( NSMapTable * selectorImpMap, SEL selector ) {

    IMP blockBackedImp = NSMapGet( selectorImpMap, selector );
    if( NULL != blockBackedImp )
    {
        imp_removeBlock( blockBackedImp );
        NSMapRemove( selectorImpMap, selector );
    }
}

static void _markBlockBackedIMPForSelector( NSMapTable * selectorImpMap, SEL selector, IMP blockBackedImp ) {

    NSMapInsertKnownAbsent( selectorImpMap, selector, blockBackedImp );
}

static void _releaseAllBlockBackedIMPs( NSMapTable * selectorImpMap ) {

    NSMapEnumerator enumState = NSEnumerateMapTable( selectorImpMap );

    void * _blockBackedImp = NULL;
    while( NO != NSNextMapEnumeratorPair( &enumState, NULL, &_blockBackedImp ) )
    {
        imp_removeBlock( (IMP)_blockBackedImp );
    }

    NSResetMapTable( selectorImpMap );
}

@end
