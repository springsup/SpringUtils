//
//  NSValue+SUInterpolable.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>
#import "SUInterpolable.h"

typedef NSValue * (*SUValueInterpolator)( NSValue* start, NSValue *end, SUInterpolationOffset offset );

@interface NSValue (SUInterpolable) <SUInterpolable>

+ (void)registerInterpolator: (SUValueInterpolator)interpolator forObjCType: (const char *)type;

@end

