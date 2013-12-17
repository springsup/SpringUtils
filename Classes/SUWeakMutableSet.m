//
//  SUMutableWeakSet.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "SUWeakMutableSet.h"
#import "NSObject+SUDeallocationNotifier.h"
#import "SURuntimeAssertions.h"

@interface SUWeakMutableSet ()
{
    NSMutableSet * internalSet;
    NSValue      * deallocationObserverKey;
    
    dispatch_semaphore_t internalSetSema;
}
@end

@implementation SUWeakMutableSet

#pragma mark Initialisation

- (id)init {
    
    return [self initWithCapacity: 0];
}

- (id)initWithCapacity: (NSUInteger)capacity {
    
    self = [super init];
    if( self )
    {
        const CFSetCallBacks callbacks = { .version         = 0,
                                           .retain          = NULL, /* Do not retain values  */
                                           .release         = NULL, /* Do not release values */
                                           .copyDescription = CFCopyDescription,
                                           .equal           = CFEqual,
                                           .hash            = NULL  /* Use pointer as hash   */ };

        internalSet             = CFBridgingRelease( CFSetCreateMutable( NULL, capacity, &callbacks ) );
        internalSetSema         = dispatch_semaphore_create( 1 );
        deallocationObserverKey = [NSValue valueWithNonretainedObject: internalSet];
    }
    
    return self;
}

#pragma mark -
#pragma mark Reading fromt the set

- (NSUInteger)count {
    
    dispatch_semaphore_wait( internalSetSema, DISPATCH_TIME_FOREVER );
    
        const NSUInteger count = internalSet.count;
    
    dispatch_semaphore_signal( internalSetSema );
    
    return count;
}

- (NSSet *)set {
    
    dispatch_semaphore_wait( internalSetSema, DISPATCH_TIME_FOREVER );

        // To ensure all members are kept retained while the set is being used,
        // Create a new set which takes ownership of them.
    
        NSSet * retainedSet = [[NSSet alloc] initWithSet: internalSet];
    
    dispatch_semaphore_signal( internalSetSema );
    
    return retainedSet;
}

- (void)accessSet: (void (^)(NSSet *))accessBlock {
    
    SU_ASSERT_NOT_EQUAL( accessBlock, Nil );
    
    NSSet * retainedSet = self.set;
    accessBlock( retainedSet );
    retainedSet = Nil;
}

#pragma mark -
#pragma mark Mutating the set

- (void)addObject: (id)objectToAdd {
    
    dispatch_semaphore_wait( internalSetSema, DISPATCH_TIME_FOREVER );
    {
        // Add the object to the set.

        [internalSet addObject: objectToAdd];
        
        // Schedule automatic removal when the object is deallocated.
        
        [objectToAdd addDeallocationNotificationTarget: self
                                              selector: @selector( containedObjectWasDeallocated: )
                                                forKey: deallocationObserverKey];
    }
    dispatch_semaphore_signal( internalSetSema );
}

- (void)removeObject: (id)objectToRemove {
    
    dispatch_semaphore_wait( internalSetSema, DISPATCH_TIME_FOREVER );
    {
        // Remove the deallocation observer.
        
        [objectToRemove removeDeallocationNotificationForKey: deallocationObserverKey];
        
        // Remove the object from the set.
        
        [internalSet removeObject: objectToRemove];
    }
    dispatch_semaphore_signal( internalSetSema );
}

- (void)removeAllObjects {
    
    dispatch_semaphore_wait( internalSetSema, DISPATCH_TIME_FOREVER );
    {
        [internalSet makeObjectsPerformSelector: @selector( removeDeallocationNotificationForKey: )
                                     withObject: deallocationObserverKey];
        [internalSet removeAllObjects];
    }
    dispatch_semaphore_signal( internalSetSema );
}

#pragma mark Contained Object Deallocation

- (void)containedObjectWasDeallocated: (__unsafe_unretained id)deallocatedObject {

    // This callback will be invoked from whichever queue had the
    // last strong reference to the object.

    dispatch_semaphore_wait( internalSetSema, DISPATCH_TIME_FOREVER );
    {
        [internalSet removeObject: deallocatedObject];
    }
    dispatch_semaphore_signal( internalSetSema );
}

#pragma mark -
#pragma mark Additional Overrides

- (NSString *)description {
    
    return internalSet.description;
}

@end
