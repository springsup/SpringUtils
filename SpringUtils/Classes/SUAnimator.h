//
//  SUAnimator.h
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>
#import "SUAnimatorDelegate.h"

typedef NS_ENUM( NSUInteger, SUAnimationCurve ) {
    SUAnimationCurveEaseInEaseOut,
    SUAnimationCurveEaseIn,
    SUAnimationCurveEaseOut,
    SUAnimationCurveLinear
};

extern const SUAnimationCurve SUAnimationCurveDefault;
extern const NSTimeInterval   kSUDefaultAnimationDuration;

/** A general-purpose animator which follows a given animation curve, calling its delegate periodically. */

@interface SUAnimator : NSObject <NSCopying>

/** An object which will receive intermittent callbacks over the course of the animation. */

@property ( nonatomic, weak ) id<SUAnimatorDelegate> delegate;

/** An optional, arbitrary object which is associated with the receiver. */

@property ( nonatomic, strong ) id<NSCopying> userData;

/** The animation offset at which the receiver most recently called its delegate.
 *
 *  If accessed from within the receiver's delegate's tick callback,
 *  returns the animation offset from the previous tick callback (or 0 if accessed during the first tick callback).
 */

@property ( nonatomic, readonly ) SUInterpolationOffset lastAnimationOffset;


//--------------------------------------/
/** @name Setting Animation Parameters */
//--------------------------------------/


/** An animation curve which defines the relationship between the offset along the animation and the elapsed time. */

@property ( nonatomic ) SUAnimationCurve animationCurve;

/** The animation duration. Must be greater than 0. */

@property ( nonatomic ) NSTimeInterval duration;

/** An optional delay before the animation is started. Must not be less than 0. */

@property ( nonatomic ) NSTimeInterval startDelay;


//---------------------------------------------/
/** @name Starting and Stopping the Animation */
//---------------------------------------------/


/** Starts the animation. */

- (void)start;

/** Interrupts the animation if it has started. */

- (void)cancel;

@end