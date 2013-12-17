//
//  SUComparatorTools.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

/** Creates an NSComparator block whose comparison methodology is specified by the given sort descriptors. 
 *
 *  @param  sortDescriptors     An array of NSSortDescriptors describing the comparison methodology.
 *
 *  @returns an NSComparator block which performs the same comparison.
 */

NSComparator NSComparatorFromSortDescriptors( NSArray * sortDescriptors );