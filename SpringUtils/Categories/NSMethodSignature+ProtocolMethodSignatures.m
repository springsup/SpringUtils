//
//  NSMethodSignature+ProtocolMethodSignatures.m
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "NSMethodSignature+ProtocolMethodSignatures.h"
#import "../Utilities/SURuntimeAssertions.h"
#import <objc/runtime.h>

@implementation NSMethodSignature (ProtocolMethodSignatures)

+ (NSMethodSignature *)signatureForInstanceMethodSelector: (SEL)aSelector inProtocol: (Protocol *)protocol isRequiredMethod: (BOOL)isRequired {

    SU_ASSERT_NOT_EQUAL( aSelector, NULL );
    SU_ASSERT_NOT_NIL( protocol );

    struct objc_method_description method = protocol_getMethodDescription( protocol, aSelector, isRequired, YES /* Instance Method */ );

    if( NULL != method.types )
    {
        return [NSMethodSignature signatureWithObjCTypes: method.types];
    }

    return Nil;
}

+ (NSMethodSignature *)signatureForClassMethodSelector: (SEL)aSelector inProtocol: (Protocol *)protocol isRequiredMethod: (BOOL)isRequired {

    SU_ASSERT_NOT_EQUAL( aSelector, NULL );
    SU_ASSERT_NOT_NIL( protocol );

    struct objc_method_description method = protocol_getMethodDescription( protocol, aSelector, isRequired, NO /* Class Method */ );

    if( NULL != method.types )
    {
        return [NSMethodSignature signatureWithObjCTypes: method.types];
    }

    return Nil;
}

- (const char *)getEncodedSignature {

    NSMutableString * str = [[NSMutableString alloc] init];

    // Encode the return type.

    [str appendFormat: @"%s", self.methodReturnType];

    // Encode the parameter types.

    for( NSUInteger paramIdx = 0; paramIdx < self.numberOfArguments; paramIdx++ )
    {
        [str appendFormat: @"%s", [self getArgumentTypeAtIndex: paramIdx]];
    }

    // Return a newly-allocated string which the caller owns.

    const char * cStr    = [str cStringUsingEncoding: NSUTF8StringEncoding];
    const char * newcStr = strdup( cStr );

    return newcStr;
}

@end
