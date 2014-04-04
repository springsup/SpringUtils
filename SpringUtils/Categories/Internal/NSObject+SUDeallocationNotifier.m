//
//  NSObject+SUDeallocationNotifier.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "NSObject+SUDeallocationNotifier.h"
#import "NSObject+SUDeallocationNotifier_Internal.h"
#import "SURuntimeAssertions.h"

@implementation NSObject (SUDeallocationNotifier)

- (SUDeallocationCallback *)deallocationCallbackForKey: (id<NSCopying>)key create: (BOOL)create remove: (BOOL)remove {
    
    // Get the deallocation callback instance for the given key.
    
    NSMutableDictionary     * deallocationCallbacks = self.deallocationCallbacks;
    SUDeallocationCallback  * callback              = deallocationCallbacks[ key ];
    
    if( create )
    {
        // Add a new deallocation callback if none was found.
        
        if( Nil == deallocationCallbacks )
        {
            deallocationCallbacks       = [[NSMutableDictionary alloc] init];
            self.deallocationCallbacks  = deallocationCallbacks;
        }
        
        if( Nil == callback )
        {
            callback                        = [[SUDeallocationCallback alloc] init];
            deallocationCallbacks[ key ]    = callback;
        }
    }
    else
    {
        if( remove )
        {
            // Remove the deallocation callback we just found
            
            if( Nil != callback )
            {
                [deallocationCallbacks removeObjectForKey: key];
            }
            
            if( 0 == deallocationCallbacks.count )
            {
                // All deallocation callbacks removed.
                // Revert any changes made to the object to enable callback invocation.
                
                [NSObject removeAllDeallocationNotificationsFromObject: self];
            }
        }
    }
    
    return callback;
}

- (void)addDeallocationNotification: (SUDeallocationObserver)observer forKey: (id<NSCopying>)key {

    // Observer may not be Nil.
    
    SU_ASSERT_NOT_EQUAL( observer, Nil );
    
    // If no key is provided, use the observer itself as the key.
    
    if( Nil == key )
    {
        key = observer;
    }

    // Ensure the receiver will invoke its dellocation callbacks.
    
    [NSObject prepareObjectForDeallocationNotifications: self];
    
    // Update the callback's block with the provided block
    
    SUDeallocationCallback * callback   = [self deallocationCallbackForKey: key create: YES remove: NO];
    callback.deallocatingObject         = self;
    callback.target                     = Nil;
    callback.block                      = observer;
}

- (void)addDeallocationNotificationTarget: (id)target selector: (SEL)selector forKey: (id<NSCopying>)key {

    // Target, Selector and Key may not be Nil.
    
    SU_ASSERT_NOT_EQUAL( target,   Nil  );
    SU_ASSERT_NOT_EQUAL( key,      Nil  );
    SU_ASSERT_NOT_EQUAL( selector, NULL );
    
    // Ensure the receiver will invoke its dellocation callbacks.
    
    [NSObject prepareObjectForDeallocationNotifications: self];
    
    // Update the callback's block with the provided block
    
    SUDeallocationCallback * callback   = [self deallocationCallbackForKey: key create: YES remove: NO];
    callback.deallocatingObject         = self;
    callback.block                      = Nil;
    callback.target                     = target;
    callback.selector                   = selector;
}

- (void)removeDeallocationNotificationForKey: (id<NSCopying>)key {
    
    // Key may not be Nil.
    
    SU_ASSERT_NOT_EQUAL( key, Nil );
    
    // Remove the callback for this key

    [self deallocationCallbackForKey: key create: NO remove: YES];
}

@end
