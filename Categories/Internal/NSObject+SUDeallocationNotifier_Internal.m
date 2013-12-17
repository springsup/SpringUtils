//
//  NSObject+SUDeallocationNotifier_Internal.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#if __has_feature(objc_arc)
    #error This file requires ARC to be disabled (-fno-objc-arc)
#endif

#import "NSObject+SUDeallocationNotifier_Internal.h"
#import "SURuntimeAssertions.h"
#import "SUAssociatedObjects.h"
#import "SUClassBuilder.h"
#import <pthread.h>

@implementation NSObject( SUDeallocationNotifier_Internal )

IMPLEMENT_ASSOCIATED_PROPERTY( NSMutableDictionary*, deallocationCallbacks, setDeallocationCallbacks )
IMPLEMENT_ASSOCIATED_SCALAR_PROPERTY( pthread_mutex_t *, releaseLock, setReleaseLock )

+ (void)prepareObjectForDeallocationNotifications:    (NSObject *)object {
    
    // 1. Validate object class.
    
        // We cannot subclass Toll-Free-Bridged objects because
        // CoreFoundation looks for exact class equivalence via the isa pointer.
        
        if( [object _isBridgedObject] )
        {
            CFStringRef typeDescription = CFCopyTypeIDDescription( CFGetTypeID( object ) );
            
                _SU_THROW_WITH_REASON( @"Bridged types are not supported. Object class %@ is toll-free-bridged with type %@",
                                      NSStringFromClass( object.class ), typeDescription );
            
            CFRelease( typeDescription );
        }
    
    // 2. Check if the object is already subclassed.
    
    static SUMethodBuilder * checkingMethod;
    static dispatch_once_t   onceToken;
    dispatch_once(&onceToken, ^{
        checkingMethod = [SUMethodBuilder newMethodWithSelector: sel_registerName("__isSUDeallocNotifier")
                                                     returnType: @encode( BOOL )
                                                          block: ^{ return YES; }];
    });
    
    if( NO == [object respondsToSelector: checkingMethod.selector] )
    {
        // 3. Object hasn't been subclassed yet.
        //    Check if we already have a dealloc-notifying subclass for this type.
        
        Class originalClass     = object.class;
        NSString * subclassName = [NSString stringWithFormat: @"__SUDeallocNotifier_%@", NSStringFromClass( originalClass )];
        
        Class subclass = NSClassFromString( subclassName );
        
        if( Nil == subclass )
        {
            // 4. No subclass exists for this type.
            //    Construct a new dealloc-notifying subclass.
            
            SUClassBuilder * subclassBuilder = [SUClassBuilder newClassNamed: subclassName
                                                                  superClass: originalClass];
            
            // Add the checking method
            
            [subclassBuilder addInstanceMethod: checkingMethod];
            
            // Override -class to hide the fact that this subclass exists.
            
            [subclassBuilder addInstanceMethod: [SUMethodBuilder newMethodWithSelector: @selector( class )
                                                                            returnType: @encode( Class )
                                                                                 block: ^{ return originalClass; }]];
            
            // Override release.
            
            IMP default_Release = class_getMethodImplementation( originalClass, @selector( release ) );
            [subclassBuilder addInstanceMethod: [SUMethodBuilder newMethodWithSelector: @selector( release )
                                                                            returnType: @encode( void )
                                                                                 block: ^( NSObject * _self ){
                                                                                     
                                                                                     // We have to deal with:
                                                                                     // - Concurrent calls to release (recursive mutex)
                                                                                     // - Recursive calls to release  (recursive mutex)
                                                                                     // - Concurrent calls to retain (which we don't lock)

                                                                                     pthread_mutex_t * releaseLock = _self.releaseLock;
                                                                                     pthread_mutex_lock( releaseLock );

                                                                                         const BOOL expectToDeallocate = ( 1 == _self.retainCount );
                                                                                         if( expectToDeallocate )
                                                                                         {
                                                                                             // Receiver only has a +1 retain count;
                                                                                             // If we called default_Release now it would deallocate.
                                                                                             
                                                                                             // The receiver will be retained and released
                                                                                             // recursively by calling out here.

                                                                                             [_self _su_objectWillDeallocate];
                                                                                         }
                                                                                         
                                                                                         // Invoke default release.
                                                                                         
                                                                                         default_Release( _self, @selector( release ) );

                                                                                     pthread_mutex_unlock( releaseLock );
                                                                                     
                                                                                         // We have not been blocking retain since we last checked
                                                                                         // the retainCount. If the receiver was retained, it wouldn't
                                                                                         // have deallocated after all.
                                                                                     
                                                                                         const BOOL didDeallocate = ( Nil == objc_getAssociatedObject( _self, @selector(releaseLock) ) );

                                                                                         if( didDeallocate )
                                                                                         {
                                                                                             // The object has deallocated.
                                                                                             // There will be no more calls to release; any pending
                                                                                             // calls to retain will have no effect.
                                                                                             
                                                                                             // Destory the release lock.
                                                                                             
                                                                                             destroyReleaseLock( releaseLock );
                                                                                         }
                                                                                     

                                                                                     
                                                                                 }]];
            // Finish construction.
            
            subclass = [subclassBuilder registerClass];
            [subclassBuilder release];
        }
        
        // Set the class of the object.
        
        object_setClass( object, subclass );
        [object createReleaseLock];
    }
    else
    {
        // Object is already subclassed.
    }
}

+ (void)removeAllDeallocationNotificationsFromObject: (NSObject *)object {
    
    object.deallocationCallbacks = Nil;
}

#pragma mark -
#pragma mark Deallocation Notification

- (void)_su_objectWillDeallocate {
    
    // Ensure the deallocation callbacks are only ever invoked once
    
    NSArray * deallocationCallbacks = self.deallocationCallbacks.allValues;
    self.deallocationCallbacks      = Nil;
    
    [deallocationCallbacks makeObjectsPerformSelector: @selector( invoke )];
}

#pragma mark -
#pragma mark Workflow Methods

- (BOOL)_isBridgedObject {
    
    // From CFRuntime.c:
    // CF objects with a CFTypeID of NotAType (0) or CFType (1) have no bridged CFType.
    
    const CFTypeID bridgingType = CFGetTypeID( self );
    return ( bridgingType > 1 );
}

- (void)createReleaseLock   {
    
    // Initialise the static mutex attributes
    
    static pthread_mutexattr_t mutexAttributes;
    static dispatch_once_t     onceToken;
    dispatch_once( &onceToken, ^{
        pthread_mutexattr_init( &mutexAttributes );
        pthread_mutexattr_settype( &mutexAttributes, PTHREAD_MUTEX_RECURSIVE );
    });
    
// The Clang Static Analyzer doesn't like storing a malloced pointer in an associated NSValue wrapper.
// Reported: http://llvm.org/bugs/show_bug.cgi?id=18262
#ifndef __clang_analyzer__
    
    // Create the instance release mutex
    
    pthread_mutex_t *   releaseMutex = calloc( sizeof( pthread_mutex_t ), 1 );
    pthread_mutex_init( releaseMutex, &mutexAttributes );

    [self setReleaseLock: releaseMutex];
    
#endif
}

void destroyReleaseLock(pthread_mutex_t *releaseMutex)  {
    
    // Called post-dealloc to destroy mutex and free heap allocation
    
    if( NULL != releaseMutex )
    {
        pthread_mutex_destroy( releaseMutex );
        free( releaseMutex );
    }
}

@end