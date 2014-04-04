//
//  SUTimeFrame.h
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#ifndef Sterling_SUTimeFrame_h
#define Sterling_SUTimeFrame_h

#import <Foundation/Foundation.h>
#import "SUBase.h"

typedef struct _SUTimeFrame {
    NSTimeInterval date;
    NSTimeInterval duration;
} SUTimeFrame;

static const SUTimeFrame SUTimeFrameNull = (SUTimeFrame){ .date = NAN, .duration = NAN };


//-----------------------------/
/**@name Creating a TimeFrame */
//-----------------------------/


/** Creates a new timeFrame representing the time between two dates.
 *
 *  @param  startDateInterval   The time-interval since the Foundation reference date at which the region of time begins.
 *  @param  endDateInterval     The time-interval since the Foundation reference date at which the region of time ends.
 *
 *  @returns                    A new timeFrame representing the specified region of time.
 */

SU_INLINE SUTimeFrame SUTimeFrameMakeFromDateIntervals( NSTimeInterval startDateInterval, NSTimeInterval endDateInterval ) {

    return (SUTimeFrame){ .date     = startDateInterval,
                          .duration = endDateInterval - startDateInterval };
}

/** Creates a new timeFrame representing the time between two dates.
 *
 *  @param  startDate   The date at which the region of time begins. If this parameter is Nil, an invalid timeFrame is returned.
 *  @param  endDate     The date at which the region of time ends. If this parameter is Nil, the timeFrame extends to infinity.
 *
 *  @returns            A new timeFrame representing the time from the startDate until the endDate, or SUTimeFrameNull if startDate is Nil.
 */

SU_INLINE SUTimeFrame SUTimeFrameMake( NSDate * startDate, NSDate * endDate ) {
    
    if( Nil != startDate )
    {
        if( Nil != endDate )
        {
            // Finite timeFrame
            
            if( startDate.timeIntervalSinceReferenceDate > endDate.timeIntervalSinceReferenceDate )
            {
                return SUTimeFrameMakeFromDateIntervals( endDate.timeIntervalSinceReferenceDate,
                                                         startDate.timeIntervalSinceReferenceDate );
            }
            else
            {
                return SUTimeFrameMakeFromDateIntervals( startDate.timeIntervalSinceReferenceDate,
                                                         endDate.timeIntervalSinceReferenceDate );
            }
        }
        else
        {
            // Infinite timeFrame
            
            return (SUTimeFrame){ .date = startDate.timeIntervalSinceReferenceDate, .duration = INFINITY };
        }
    }
    else
    {
        // Invalid timeFrame
        
        return SUTimeFrameNull;
    }
}

/** Creates a new timeFrame representing a given duration either side of a date interval
 *
 *  @param  centreDateInterval  The date at the centre of the region of time.
 *                              If this parameter is not finite, an invalid timeFrame is returned.
 *  @param  duration            The desired amount of time either side of the centreDate.
 *                              This parameter may not be less than zero.
 *
 *  @returns                    A new timeFrame representing the time with the given duration around the center date,
 *                              or SUTimeFrameNull if an invalid value is given.
 */

SU_INLINE SUTimeFrame SUTimeFrameWithDurationAroundCenterDateInterval( NSTimeInterval centreDateInterval, NSTimeInterval duration ) {
    
    if( isfinite( centreDateInterval ) && ( duration >= 0 ) )
    {
        return (SUTimeFrame){   .date     = centreDateInterval - ( duration/2 ),
                                .duration = duration };
    }
    else
    {
        return SUTimeFrameNull;
    }
}

/** Creates a new timeFrame representing a given duration either side of a date
 *
 *  @param  centreDate  The date at the centre of the region of time. If this parameter is Nil, an invalid timeFrame is returned.
 *  @param  duration    The desired amount of time either side of the centreDate. This parameter may not be less than zero.
 *
 *  @returns            A new timeFrame representing the time from the startDate until the endDate, or SUTimeFrameNull if startDate is Nil.
 */

SU_INLINE SUTimeFrame SUTimeFrameWithDurationAroundCenterDate( NSDate * centreDate, NSTimeInterval duration ) {
    
    if( Nil != centreDate )
    {
        return SUTimeFrameWithDurationAroundCenterDateInterval( centreDate.timeIntervalSinceReferenceDate, duration );
    }
    else
    {
        return SUTimeFrameNull;
    }
}


//---------------------------------------/
/**@name Checking the Type of TimeFrame */
//---------------------------------------/


/** Returns YES if the timeFrame represents an empty timeFrame.
 *
 *  @param  timeFrame   The timeFrame.
 *
 *  @returns            YES if the timeFrame represents an empty timeFrame, NO otherwise.
 */

SU_INLINE BOOL SUTimeFrameIsNull ( SUTimeFrame timeFrame ) {
    return isnan( timeFrame.date );
}

/** Returns YES if the timeFrame represents a valid region of time with infinite duration.
 *
 *  @param  timeFrame   The timeFrame.
 *
 *  @returns            YES if the timeFrame has infinite duration, NO if it is finite or SUTimeFrameNull.
 */

SU_INLINE BOOL SUTimeFrameIsInfinite( SUTimeFrame timeFrame ) {
    return ( !SUTimeFrameIsNull( timeFrame ) ) && ( !isfinite( timeFrame.duration ) );
}

/** Returns YES if the timeFrame represents a valid region of time with finite duration.
 *
 *  @param  timeFrame   The timeFrame.
 *
 *  @returns            YES if the timeFrame has finite duration, NO if it is infinite or SUTimeFrameNull.
 */

SU_INLINE BOOL SUTimeFrameIsFinite( SUTimeFrame timeFrame ) {
    return isfinite( timeFrame.duration );
}


//-----------------------------------------/
/**@name Getting Dates from the TimeFrame */
//-----------------------------------------/


/** Returns the earliest date in the given timeFrame.
 *
 *  @param  timeFrame   The timeFrame.
 *
 *  @returns            The date-interval of the earliest date in the timeFrame.
 *                      Returns NAN if the timeFrame is SUTimeFrameNull.
 */

SU_INLINE NSTimeInterval SUTimeFrameGetStartDateInterval( SUTimeFrame timeFrame ) {
    
    if( timeFrame.duration >= 0 )
        return timeFrame.date;
    else
        return timeFrame.date - timeFrame.duration;
}

/** Returns the earliest date in the given timeFrame.
 *
 *  @param  timeFrame   The timeFrame.
 *
 *  @returns            The earliest date in the timeFrame.
 *                      Returns Nil if the timeFrame is SUTimeFrameNull.
 */

SU_INLINE NSDate * SUTimeFrameGetStartDate( SUTimeFrame timeFrame ) {
    
    const NSTimeInterval interval = SUTimeFrameGetStartDateInterval( timeFrame );
    
    if( isfinite( interval ) )
        return [NSDate dateWithTimeIntervalSinceReferenceDate: interval];
    else
        return Nil;
}

/** Returns the date at which the given timeFrame ends.
 *
 *  @param  timeFrame   The timeFrame.
 *
 *  @returns            The date-interval at which the timeFrame ends.
 *                      Returns INFINITY if the timeFrame is infinite, or
 *                      NAN if the timeFrame is SUTimeFrameNull.
 */

SU_INLINE NSTimeInterval SUTimeFrameGetEndDateInterval( SUTimeFrame timeFrame ) {

    if( timeFrame.duration >= 0 )
        return timeFrame.date + timeFrame.duration;
    else
        return timeFrame.date;
}

/** Returns the date at which the given timeFrame ends.
 *
 *  @param  timeFrame   The timeFrame.
 *
 *  @returns            The date at which the timeFrame ends.
 *                      Returns Nil if the timeFrame is infinite or SUTimeFrameNull.
 */

SU_INLINE NSDate * SUTimeFrameGetEndDate( SUTimeFrame timeFrame ) {
    
    const NSTimeInterval interval = SUTimeFrameGetEndDateInterval( timeFrame );

    if( isfinite( interval ) )
        return [NSDate dateWithTimeIntervalSinceReferenceDate: interval];
    else
        return Nil;
}

/** Returns the date at the centre of the given timeFrame.
 *
 *  @param  timeFrame   The timeFrame.
 *
 *  @returns            The date-interval at the centre of the timeFrame.
 *                      Returns NAN if the timeFrame is infinite or SUTimeFrameNull.
 */

SU_INLINE NSTimeInterval SUTimeFrameGetCenterDateInterval( SUTimeFrame timeFrame ) {
    
    if( isfinite( timeFrame.duration ) )
    {
        return ( timeFrame.date + ( timeFrame.duration/2 ) );
    }
    return NAN;
}

/** Returns the date at the centre of the given timeFrame.
 *
 *  @param  timeFrame   The timeFrame.
 *
 *  @returns            The date at the centre of the timeFrame.
 *                      Returns Nil if the timeFrame is infinite or SUTimeFrameNull.
 */

SU_INLINE NSDate * SUTimeFrameGetCenterDate( SUTimeFrame timeFrame ) {
    
    const NSTimeInterval interval = SUTimeFrameGetCenterDateInterval( timeFrame );
    
    if( !isnan( interval ) )
    {
        return [NSDate dateWithTimeIntervalSinceReferenceDate: interval];
    }
    return Nil;
}

/** Retrieves the dates at which the given timeFrame starts and ends.
 *
 *  @param  timeFrame   The timeFrame.
 *  @param  oRangeStart On output, the data at which the timeFrame starts, or Nil if the timeFrame is SUTimeFrameNull.
 *  @param  oRangeEnd   On output, the data at which the timeFrame starts, or Nil if the timeFrame is infinite or SUTimeFrameNull.
 */

SU_INLINE void SUTimeFrameGetDateRange( SUTimeFrame timeFrame, NSDate ** oRangeStart, NSDate ** oRangeEnd ) {

    if( NULL != oRangeStart )
        *oRangeStart = SUTimeFrameGetStartDate( timeFrame );
    
    if( NULL != oRangeEnd )
        *oRangeEnd   = SUTimeFrameGetEndDate( timeFrame );
}


//-----------------------------------/
/**@name Testing TimeFrame Equality */
//-----------------------------------/


/** Determines whether two timeFrames represent equivalent regions of time.
 *
 *  @param  timeFrame1  A timeFrame.
 *  @param  timeFrame2  Another timeFrame to check for equivalence.
 *
 *  @returns            YES if the two timeFrames represent equivalent regions of time, otherwise NO.
 */

SU_INLINE BOOL SUTimeFramesEqual( SUTimeFrame timeFrame1, SUTimeFrame timeFrame2 ) {
    return ( SUTimeFrameGetStartDateInterval( timeFrame1 ) == SUTimeFrameGetStartDateInterval( timeFrame2 ) ) &&
           ( SUTimeFrameGetEndDateInterval  ( timeFrame1 ) == SUTimeFrameGetEndDateInterval  ( timeFrame2 ) );
}


//-----------------------------------------------------------/
/**@name Testing Dates for Containment within the TimeFrame */
//-----------------------------------------------------------/


/** Defines whether a given date occurs before, within or after a given timeFrame.
 *
 *  timeFrames are non-inclusive with respect to their end dates, which is to say that they extend
 *  from their start dates up _until_ their end dates. As such:
 *
 *  SUTimeFrameCompareToDateInterval( tf, SUTimeFrameGetEndDateInterval( tf ) )
 *
 *  will by definition return NSOrderedAscending.
 *
 *  @param  timeFrame   The timeFrame. If this parameter is SUTimeFrameNull, the result is undefined.
 *  @param  date        The date-interval. If this parameter is NAN, the result is undefined.
 *
 *  @returns            - NSOrderedDescending if the given date precedes the start of the timeFrame.
 *                      - NSOrderedSame if the given date is within the timeFrame.
 *                      - NSOrderedAscending if the given date is equal to, or succeeds the end of the timeFrame.
 */

SU_INLINE NSComparisonResult SUTimeFrameCompareToDateInterval( SUTimeFrame timeFrame, NSTimeInterval date ) {

    if( date < SUTimeFrameGetStartDateInterval( timeFrame ) )
    {
        return NSOrderedDescending; // Date precedes timeFrame
    }
    else
    {
        if( date >= SUTimeFrameGetEndDateInterval( timeFrame ) )
        {
            return NSOrderedAscending; // Date succeeds timeFrame;
        }
    }
    
    return NSOrderedSame; // Date is contained within timeFrame
}

/** Determines whether a timeFrame contains a given date.
 *
 *  @param  timeFrame   The timeFrame.
 *  @param  date        The date-interval to check. If this parameter is NAN, the result is undefined.
 *
 *  @returns            YES if the timeFrame contains the given date.
 *                      NO if the date lies outside the timeFrame, or if the timeFrame is SUTimeFrameNull.
 */

SU_INLINE BOOL SUTimeFrameContainsDateInterval( SUTimeFrame timeFrame, NSTimeInterval date ) {
    
    if( SUTimeFrameIsNull( timeFrame ) )
        return NO;
    
    return ( NSOrderedSame == SUTimeFrameCompareToDateInterval( timeFrame, date ) );
}

/** Determines whether a timeFrame contains a given date.
 *
 *  @param  timeFrame   The timeFrame.
 *  @param  date        The date to check.
 *
 *  @returns            YES if the timeFrame contains the given date.
 *                      NO if the date lies outside the timeFrame or if the timeFrame is SUTimeFrameNull.
 */

SU_INLINE BOOL SUTimeFrameContainsDate( SUTimeFrame timeFrame, NSDate * date ) {
    
    return SUTimeFrameContainsDateInterval( timeFrame, date.timeIntervalSinceReferenceDate );
}


//---------------------------------------------/
/**@name Testing whether TimeFrames Intersect */
//---------------------------------------------/


/** Determines whether a timeFrame contains a date which is also contained by another timeFrame.
 *
 *  timeFrames are non-inclusive with respect to their end dates, which is to say that they extend
 *  from their start dates up _until_ their end dates. 
 *  That is to say that a timeFrame (1 <-> 3) and another timeFrame (3 <-> 6) do not intersect (they would be _adjacent_).
 *
 *  @param  timeFrame1  A timeFrame.
 *  @param  timeFrame2  Another timeFrame.
 *
 *  @returns            YES if either timeFrame contains a date contained by the other timeFrame. 
 *                      NO if the timeFrames do not intersect, or if either timeFrame is SUTimeFrameNull.
 */

SU_INLINE BOOL SUTimeFramesIntersect( SUTimeFrame timeFrame1, SUTimeFrame timeFrame2 ) {
    
    if( SUTimeFrameIsNull( timeFrame1 ) || SUTimeFrameIsNull( timeFrame2 ) )
        return NO;
    
    return ( NSOrderedSame == SUTimeFrameCompareToDateInterval( timeFrame1, SUTimeFrameGetStartDateInterval( timeFrame2 ) ) ) ||
           ( NSOrderedSame == SUTimeFrameCompareToDateInterval( timeFrame2, SUTimeFrameGetStartDateInterval( timeFrame1 ) ) );
}


//--------------------------------/
/**@name Modifying the TimeFrame */
//--------------------------------/


/** Expands a timeFrame by a given amount of time around its center date.
 *
 *  @param  timeFrame   The timeFrame.
 *  @param  delta       The amount of time to expand the timeFrame by.
 *
 *  @returns            A timeFrame with the same center date as the given timeFrame,
 *                      but with a duration increased or decreased by delta.
 */

SU_INLINE SUTimeFrame SUTimeFrameExpand( SUTimeFrame timeFrame, NSTimeInterval delta ) {

    return (SUTimeFrame){   .date     = timeFrame.date     - (delta/2),
                            .duration = timeFrame.duration +  delta };
}

/** Shifts a timeFrame by a given amount of time.
 *
 *  @param  timeFrame   The timeFrame.
 *  @param  shift       The amount of time to shift the timeFrame by.
 *
 *  @returns            A timeFrame with the same duration as the given timeFrame,
 *                      but shifted by the given amount of time.
 */

SU_INLINE SUTimeFrame SUTimeFrameShift( SUTimeFrame timeFrame, NSTimeInterval shift ) {

    return (SUTimeFrame){ .date = timeFrame.date + shift, .duration = timeFrame.duration };
}


#endif
