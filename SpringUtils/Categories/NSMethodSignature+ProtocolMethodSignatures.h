//
//  NSMethodSignature+ProtocolMethodSignatures.h
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

@interface NSMethodSignature (ProtocolMethodSignatures)

+ (NSMethodSignature *)signatureForInstanceMethodSelector: (SEL)aSelector inProtocol: (Protocol *)protocol isRequiredMethod: (BOOL)isRequired;

+ (NSMethodSignature *)signatureForClassMethodSelector: (SEL)aSelector inProtocol: (Protocol *)protocol isRequiredMethod: (BOOL)isRequired;

/** Returns the Objective-C encoded signature of the method. 
 *
 *  This method returns a newly-allocated C string which the caller is respondible for releasing using `free()`.
 */

- (const char *)getEncodedSignature;

@end
