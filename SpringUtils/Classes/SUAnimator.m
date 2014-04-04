//
//  SUAnimator.m
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "SUAnimator.h"

#import "../Utilities/SURuntimeAssertions.h"

#if TARGET_OS_IPHONE
#import <QuartzCore/QuartzCore.h>
#endif

//#define SUANIMATOR_USE_MEDIA_TIMING_API

const NSTimeInterval kSUDefaultAnimationDuration = 0.35;
const SUAnimationCurve SUAnimationCurveDefault   = SUAnimationCurveLinear;

@implementation SUAnimator
{
    
    CADisplayLink * timer;
    CFTimeInterval  startTimeStamp;
    BOOL            didCallComplete;

#ifdef SUANIMATOR_USE_MEDIA_TIMING_API
    CAMediaTimingFunction * timingFunction;
#endif
}

#pragma mark Initialisation

- (id)init {
    
    self = [super init];
    if( self )
    {
        startTimeStamp      = -1;
        _duration           = kSUDefaultAnimationDuration;
        self.animationCurve = SUAnimationCurveDefault;
    }
    
    return self;
}

- (id)copyWithZone: (NSZone *)zone {
    
    SUAnimator * copy       = [[[self class] allocWithZone: zone] init];

    copy->_delegate         = _delegate;
    copy->_duration         = _duration;
    copy->_startDelay       = _startDelay;
    copy->_userData         = [_userData copyWithZone: zone];
    copy.animationCurve     = _animationCurve;

    return copy;
}


#pragma mark Setters


- (void)setStartDelay: (NSTimeInterval)startDelay {
    
    SU_ASSERT_GREATER_THAN_OR_EQUAL( startDelay, 0 )
    _startDelay = startDelay;
}

- (void)setDuration: (NSTimeInterval)duration {
    
    SU_ASSERT_GREATER_THAN( duration, 0 )
    _duration = duration;
}


#pragma mark -
#pragma mark Animation Cycle


- (void)start {

    // Reset state.
    
    [timer invalidate];
    startTimeStamp  = -1;
    didCallComplete = NO;
    _lastAnimationOffset = 0;
    
    // Start the animation timer.
    
    timer = [CADisplayLink displayLinkWithTarget: self
                                        selector: @selector( animationTimerTick: )];
    
    [timer addToRunLoop: NSRunLoop.mainRunLoop
                forMode: NSRunLoopCommonModes];

    startTimeStamp = CACurrentMediaTime();

    // Call animation start event.
    
    [self animationDidStart];
}

- (void)cancel {
    
    if( startTimeStamp != -1 )
    {
        [self animationDidStop: NO];
    }
}


#pragma mark Animation Events


- (void)animationDidStart {
    
    // Inform the delegate that the animation has begun.
    
    if( [_delegate respondsToSelector: @selector( animatorDidStart: )])
        [_delegate animatorDidStart: self];
}

- (void)animationTimerTick: (CADisplayLink *)animationTimer {
    
    const CFTimeInterval timeSinceStart = ( timer.timestamp - startTimeStamp );
    
    if( timeSinceStart >= _startDelay )
    {
        const CFTimeInterval timeSinceAnimationStart = timeSinceStart - _startDelay;
        
        // Find our relative position in the animation.
        
        SUInterpolationOffset relativeTimeIntoAnimation = timeSinceAnimationStart / _duration;
        relativeTimeIntoAnimation                       = MIN( relativeTimeIntoAnimation, 1.0 );
        
        // Adjust our place in the animation using the animation curve (value may be > 1.0 if overshoot)
        // Call the animation delegate with that position.

        SUInterpolationOffset adjustedTimeIntoAnimation;

#ifdef SUANIMATOR_USE_MEDIA_TIMING_API
        if( _mayUseMediaTimingAPI )
        {
            // It is fine to use the static NSInvocation instance because
            // this method is only ever called from the main runloop.

            float mediaTimingValue = relativeTimeIntoAnimation;
            [_mediaTimingInvocation setArgument: &mediaTimingValue atIndex: 2];
            [_mediaTimingInvocation invokeWithTarget: timingFunction];

            [_mediaTimingInvocation getReturnValue: &mediaTimingValue];

            adjustedTimeIntoAnimation = mediaTimingValue;
        }
        else
#endif
        adjustedTimeIntoAnimation = valueForOffsetAlongCurve( relativeTimeIntoAnimation, _animationCurve );

        [_delegate animatorTick: self
           offsetAlongAnimation: adjustedTimeIntoAnimation];
        
        _lastAnimationOffset = adjustedTimeIntoAnimation;
        
        // If the duration has elapsed, finish the animation.
        
        if( relativeTimeIntoAnimation >= 1.0 )
        {
            [self animationDidStop: YES];
        }
    }
}

- (void)animationDidStop: (BOOL)didComplete {
    
    if( NO == didCallComplete )
    {
        // Flag didCallComplete,
        // ensuring that this method is only invoked once per animation run.
        
        didCallComplete = YES;
        startTimeStamp  = -1;
        
        // Invalidate the timer.
        
        [timer invalidate];
        
        // Inform the delegate.
        
        if( [_delegate respondsToSelector: @selector( animatorDidStop:didComplete: )] )
            [_delegate animatorDidStop: self didComplete: didComplete];
    }
}


#pragma mark -
#pragma mark Animation Curves


double valueForOffsetAlongCurve( double offset, SUAnimationCurve animationCurve ) {

    switch ( animationCurve )
    {
        case SUAnimationCurveEaseInEaseOut:
            return -0.5f * ( cosf( M_PI * offset ) - 1.f );
        case SUAnimationCurveEaseIn:
            return cosf( offset * ( M_PI_2 ) );
        case SUAnimationCurveEaseOut:
            return sinf( offset * ( M_PI_2 ) );
        default:
            return offset;
    }
}


#pragma mark Media Timing API
#ifdef SUANIMATOR_USE_MEDIA_TIMING_API

static BOOL           _mayUseMediaTimingAPI = NO;
static NSInvocation * _mediaTimingInvocation;

+ (void)load {

    const SEL mediaTimingSel = sel_registerName( "_solveForInput:" );
    _mayUseMediaTimingAPI     = [CAMediaTimingFunction instancesRespondToSelector: mediaTimingSel];

    if( _mayUseMediaTimingAPI )
    {
        NSMethodSignature * sig = [CAMediaTimingFunction instanceMethodSignatureForSelector: mediaTimingSel];

        // Verify that the method is what we expect; it's a private API after all

        const char * returnType = sig.methodReturnType;
        const char * argType    = [sig getArgumentTypeAtIndex: 2];

        if( ( 0 == strcmp( returnType, @encode( float ) ) ) &&
            ( 0 == strcmp( argType,    @encode( float ) ) ) )
        {
            _mediaTimingInvocation          = [NSInvocation invocationWithMethodSignature: sig];
            _mediaTimingInvocation.selector = mediaTimingSel;
        }
        else
        {
            _mayUseMediaTimingAPI = NO;
        }
    }
}

- (void)setAnimationCurve: (SUAnimationCurve)animationCurve {

    _animationCurve = animationCurve;

    NSString * mediaTimingName = Nil;

    switch ( _animationCurve )
    {
        case SUAnimationCurveEaseInEaseOut:
            mediaTimingName = kCAMediaTimingFunctionEaseInEaseOut;
            break;

        case SUAnimationCurveEaseIn:
            mediaTimingName = kCAMediaTimingFunctionEaseIn;
            break;

        case SUAnimationCurveEaseOut:
            mediaTimingName = kCAMediaTimingFunctionEaseOut;
            break;

        default:
            mediaTimingName = kCAMediaTimingFunctionLinear;
            break;
    }

    timingFunction = [CAMediaTimingFunction functionWithName: mediaTimingName];
}

#endif

@end
