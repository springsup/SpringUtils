//
//  NSObject+KVOBlocks.m
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "NSObject+KVOBlocks.h"

@interface KVOBlockHelper : NSObject

@property ( nonatomic, weak ) NSObject * observingObject;
@property ( nonatomic, getter = isAttachedToObservingObject ) BOOL attachedToObservingObject;

@property ( nonatomic, copy ) NSString * keyPath;

@property ( nonatomic, copy ) void(^block)( NSObject * object, NSString * keyPath, NSDictionary * change );

@end

@implementation NSObject (KVOBlocks)

- (id)addObserverBlock: (void (^)(NSObject *, NSString *, NSDictionary * ))observerBlock
            forKeyPath: (NSString *)keyPath
               options: (NSKeyValueObservingOptions)options {
    
    KVOBlockHelper * blockContainer;
    
    if( Nil != observerBlock )
    {
        // Create a new block container
        
        blockContainer                  = [[KVOBlockHelper alloc] init];
        blockContainer.observingObject  = self;
        blockContainer.keyPath          = keyPath;
        blockContainer.block            = observerBlock;
        
        // Have the block container start watching us
        
        [self addObserver: blockContainer
               forKeyPath: keyPath
                  options: options
                  context: Nil];
        
        blockContainer.attachedToObservingObject = YES;
    }
    
    // Return the block container.
    // Once this block container is deallocated, the observation is automatically released.
    
    return blockContainer;
}

+ (void)removeObserverBlock: (id)blockToken {

    // Do nothing (do not throw) if Nil token provided
    
    if( Nil == blockToken )
        return;

    NSString * exceptionString = Nil;
    
    // Check that the token is a valid token
    
    if( [blockToken isKindOfClass: KVOBlockHelper.class] )
    {
        KVOBlockHelper * blockContainer = (KVOBlockHelper *)blockToken;
        
        // Check that the token is attached
        
        if( blockContainer.isAttachedToObservingObject )
        {
            if( Nil != blockContainer.observingObject )
            {
                [blockContainer.observingObject removeObserver: blockContainer
                                                    forKeyPath: blockContainer.keyPath];
            }
            
            blockContainer.attachedToObservingObject = NO;
        }
        else
        {
            // Token has already been removed
            
            exceptionString = @"Block has already been removed";
        }
    }
    else
    {
        // Token is not a KVOBlockHelper
        
        exceptionString = [NSString stringWithFormat: @"Invalid block observer token [%@]", blockToken];
    }
    
    // Raise any exception conditions we encountered
    
    if( exceptionString )
    {
        [[NSException exceptionWithName: NSInvalidArgumentException
                                 reason: exceptionString
                               userInfo: Nil] raise];
    }
}

@end

@implementation KVOBlockHelper

- (void)observeValueForKeyPath: (NSString *)keyPath
                      ofObject: (id)object
                        change: (NSDictionary *)change
                       context: (void *)context {
    
    // Invoke the block
    
    self.block( object, keyPath, change );
}

- (void)dealloc {
    
    // Auto-remove when we are deallocated
    
    if( self.isAttachedToObservingObject )
    {
        [NSObject removeObserverBlock: self];
    }
}

@end