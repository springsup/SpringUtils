//
//  SUAnimatorDelegate.h
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>
#import "SUTypes.h"

@class    SUAnimator;
@protocol SUAnimatorDelegate <NSObject>

/** Informs the receiver that an animation (for which it is the delegate) has begun.
 *
 *  @param  animator    An SUAnimator representing the animation which has begun.
 */

@optional
- (void)animatorDidStart: (SUAnimator *)animator;

/** Informs the receiver that an animation (for which it is the delegate) has stopped.
 *
 *  @param  animator    An SUAnimator representing the animation which has stopped.
 *  @param  didComplete If YES, the animation is stopping because it ran to completion.
 *                      Otherwise the animation is stopping because it was interrupted.
 */

@optional
- (void)animatorDidStop: (SUAnimator *)animator didComplete: (BOOL)didComplete;

/** Informs the receiver that the animation represented by animator has advanced to the provided offset.
 *
 *  @param  animator    An SUAnimator representing the animation which has advanced.
 *  @param  offset      The new progress within the animation, between 0 and 1.
 */

- (void)animatorTick: (SUAnimator *)animator offsetAlongAnimation: (SUInterpolationOffset)offset;

@end