//
//  SUInterceptorTests.m
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <XCTest/XCTest.h>
#import "SUInterceptor.h"

#import <objc/message.h>
#import "NSMethodSignature+ProtocolMethodSignatures.h"

typedef struct {

    double field1;
    double field2;
    unsigned long long field3;
    unsigned long long field4;
    unsigned long long field5;

} MyTestStruct;

static BOOL MyTestStructEquals( MyTestStruct val1, MyTestStruct val2 )
{
    return  ( val1.field1 == val2.field1 ) && ( val1.field2 == val2.field2 ) &&
            ( val1.field3 == val2.field3 ) && ( val1.field4 == val2.field4 ) &&
            ( val1.field5 == val2.field5 );
}

static MyTestStruct RandomMyTestStruct()
{
    return (MyTestStruct){ arc4random()/M_PI, arc4random()/M_PI, arc4random(), arc4random(), arc4random() };
}

@interface MyTestClass : NSObject

- (MyTestStruct)structReturnMethod;

+ (BOOL)testStructField2IsPositive: (MyTestStruct)structure;

@end

@implementation MyTestClass

- (MyTestStruct)structReturnMethod {

    return (MyTestStruct){ 0, 1, 2, 3, 4 };
}

+ (BOOL)testStructField2IsPositive: (MyTestStruct)structure {

    return ( structure.field2 >= 0 );
}

@end


//=============


@interface SUInterceptorTests : XCTestCase

@end

@implementation SUInterceptorTests

#define STRINGIFY(x) STR(x)
#define STR(x) #x

#pragma mark -
#pragma mark Message Forwarding


#define TEST_MSGFWD1_SELECTOR   count   // A selector which the object responds to, returning an unsigned integer.

/** Tests that messages are forwarded by an SUInterceptor with no interception blocks. */

- (void)testMessageForwarding1 {

    // 1. Create an array with a random number of objects.

    NSMutableArray * object = [[NSMutableArray alloc] init];

    const NSUInteger numObjects = ( arc4random() % 20 ) + 1;
    for( int objIdx = 0; objIdx < numObjects; objIdx++ )
    {
        [object addObject: [NSNull null]];
    }

    // 2. Create an SUInterceptor which intercepts messages sent to the array.
    //    Do not add any interception blocks.

    id interceptor = [SUInterceptor interceptorWithTarget: object];

    // 3. Verify that values returned from the interceptor equal values returned from the object.

    const NSUInteger reportedCount = [interceptor TEST_MSGFWD1_SELECTOR];
    const NSUInteger actualCount   = [object      TEST_MSGFWD1_SELECTOR];

    XCTAssertEqual( actualCount, reportedCount, @"Value returned from interceptor does not match the value returned from the object" );
}


#define TEST_MSGFWD2_SELECTOR       count   // A selector which the object responds to, returning an unsigned integer.
#define TEST_MSGFWD2_SELECTOR_SIG   "I@:"   // The type-signature of the selector.

/** Tests that messages are forwarded by an SUInterceptor with an interception block which returns `YES`. */

- (void)testMessageForwarding2 {

    // 1. Create an array with a random number of objects.

    NSMutableArray * object = [[NSMutableArray alloc] init];

    const NSUInteger numObjects = ( arc4random() % 20 ) + 1;
    for( int objIdx = 0; objIdx < numObjects; objIdx++ )
    {
        [object addObject: [NSNull null]];
    }

    // 2. Create an SUInterceptor which intercepts messages sent to the array.

    id interceptor = [SUInterceptor interceptorWithTarget: object];

    // 3. Intercept a message with a block which does not alter the invocation and returns YES.

    __block BOOL blockWasInvoked = NO;

    [interceptor interceptSelector: @selector( TEST_MSGFWD2_SELECTOR )
                   methodSignature: [NSMethodSignature signatureWithObjCTypes: TEST_MSGFWD2_SELECTOR_SIG]
                         withBlock: ^BOOL(SUInterceptor *interceptor, NSInvocation *invocation) {

                             blockWasInvoked = YES;

                             return YES;
                         }];

    // 4. Verify that values returned from the interceptor for the selector equal values returned from the object.

    const NSUInteger reportedCount = [interceptor TEST_MSGFWD2_SELECTOR];
    const NSUInteger actualCount   = [object      TEST_MSGFWD2_SELECTOR];

    XCTAssertEqual( actualCount, reportedCount, @"Value returned from interceptor does not match the value returned from the object" );

    // 5. Verify that the interception block was invoked.

    XCTAssertTrue( blockWasInvoked, @"Interception block for '%s' was not invoked", STRINGIFY( TEST_MSGFWD2_SELECTOR ) );
}


#define TEST_MSGFWD3_SELECTOR       count   // A selector which the object responds to, returning and unsigned integer.
#define TEST_MSGFWD3_SELECTOR_SIG   "I@:"   // The type-signature of the selector.

/** Tests that messages are forwarded by an SUInterceptor with an interception block which invokes its invocation directly and returns `NO`. */

- (void)testMessageForwarding3 {

    // 1. Create an array with a random number of objects.

    NSMutableArray * object = [[NSMutableArray alloc] init];

    const NSUInteger numObjects = ( arc4random() % 20 ) + 1;
    for( int objIdx = 0; objIdx < numObjects; objIdx++ )
    {
        [object addObject: [NSNull null]];
    }

    // 2. Create an SUInterceptor which intercepts messages sent to the array.

    id interceptor = [SUInterceptor interceptorWithTarget: object];

    // 3. Intercept a message with a block which invokes the invocation directly and returns NO.

    __block BOOL blockWasInvoked = NO;

    [interceptor interceptSelector: @selector( TEST_MSGFWD3_SELECTOR )
                   methodSignature: [NSMethodSignature signatureWithObjCTypes: TEST_MSGFWD3_SELECTOR_SIG]
                         withBlock: ^BOOL( SUInterceptor *interceptor, NSInvocation *invocation ) {

                             blockWasInvoked = YES;
                             [invocation invoke];

                             return NO;
                         }];

    // 4. Verify that values returned from the interceptor for the selector equal values returned from the object.

    const NSUInteger reportedCount = [interceptor TEST_MSGFWD3_SELECTOR];
    const NSUInteger actualCount   = [object      TEST_MSGFWD3_SELECTOR];

    XCTAssertEqual( actualCount, reportedCount, @"Value returned from interceptor does not match the value returned from the object" );

    // 5. Verify that the interception block was invoked.

    XCTAssertTrue( blockWasInvoked, @"Interception block for '%s' was not invoked", STRINGIFY( TEST_MSGFWD3_SELECTOR ) );
}


#define TEST_MSGFWD4_SELECTOR           count   // A selector which the object responds to, returning an unsigned integer.
#define TEST_MSGFWD4_OTHER_SELECTOR     class   // Some other selector. Object doesn't have to respond to it.
#define TEST_MSGFWD4_OTHER_SELECTOR_SIG "#@:"   // The type-signature of the other selector.

/** Tests that messages are forwarded by an SUInterceptor which does not intercept the called selector. */

- (void)testMessageForwarding4 {

    // 1. Create an array with a random number of objects.

    NSMutableArray * object = [[NSMutableArray alloc] init];

    const NSUInteger numObjects = ( arc4random() % 20 ) + 1;
    for( int objIdx = 0; objIdx < numObjects; objIdx++ )
    {
        [object addObject: [NSNull null]];
    }

    // 2. Create an SUInterceptor which intercepts messages sent to the array.

    id interceptor = [SUInterceptor interceptorWithTarget: object];

    // 3. Intercept a message with a block which invokes the invocation directly and returns NO.

    __block BOOL blockWasInvoked = NO;

    [interceptor interceptSelector: @selector( TEST_MSGFWD4_OTHER_SELECTOR )
                   methodSignature: [NSMethodSignature signatureWithObjCTypes: TEST_MSGFWD4_OTHER_SELECTOR_SIG]
                         withBlock: ^BOOL(SUInterceptor *interceptor, NSInvocation *invocation) {

                             blockWasInvoked = YES;

                             return NO;
                         }];

    // 4. Verify that values returned from the interceptor equal values returned from the object.

    const NSUInteger reportedCount = [interceptor TEST_MSGFWD4_SELECTOR];
    const NSUInteger actualCount   = [object      TEST_MSGFWD4_SELECTOR];

    XCTAssertEqual( actualCount, reportedCount, @"Value returned from interceptor does not match the value returned from the object" );

    // 5. Verify that the interception block was invoked.

    XCTAssertFalse( blockWasInvoked,
                    @"Interception block for '%s' was invoked when calling '%s'",
                    STRINGIFY( TEST_MSGFWD4_OTHER_SELECTOR ), STRINGIFY( TEST_MSGFWD4_SELECTOR ) );
}


#define TEST_MSGFWD5_SELECTOR           numberStyle // A selector which the object doesn't respond to.
#define TEST_MSGFWD5_SELECTOR_SIG       "I@:"       // The type-signature of the selector.
#define TEST_MSGFWD5_OTHER_SELECTOR     count       // Some other selector. Object doesn't have to respond to it.
#define TEST_MSGFWD5_OTHER_SELECTOR_SIG "I@:"       // The type-signature of the other selector.

/** Tests that unrecognized selectors continue to raise exceptions until an interception block is added for them.
 *  Tests that unrecognized selectors raise exceptions once again after their interception block has been removed.
 *  Tests that returning YES (implying forwarding) from such a block does not raise an exception.
 */

- (void)testMessageForwarding5 {

    // 1. Create an object

    id object = [[NSSet alloc] init];

    // 2. Ensure the object does not respond to the test selector.
    
    XCTAssertThrowsSpecificNamed( [object TEST_MSGFWD5_SELECTOR], NSException, NSInvalidArgumentException,
                                  @"Object responds to '%s'", STRINGIFY( TEST_MSGFWD5_SELECTOR ) );

    // 3. Create an SUInterceptor which intercepts messages sent to the object.

    id interceptor = [SUInterceptor interceptorWithTarget: object];

    // 4. Ensure the interceptor does not respond to the test selector.

    XCTAssertThrowsSpecificNamed( [interceptor TEST_MSGFWD5_SELECTOR], NSException, NSInvalidArgumentException,
                                  @"Interceptor responds to '%s'", STRINGIFY( TEST_MSGFWD5_SELECTOR ) );

    // 5. Add an interception block intercepting some other selector.

    __block BOOL blockWasInvoked = NO;

    [interceptor interceptSelector: @selector( TEST_MSGFWD5_OTHER_SELECTOR )
                   methodSignature: [NSMethodSignature signatureWithObjCTypes: TEST_MSGFWD5_OTHER_SELECTOR_SIG]
                         withBlock: ^BOOL(SUInterceptor *interceptor, NSInvocation *invocation) {

                             blockWasInvoked = YES;

                             return YES;
                         }];

    // 6. Ensure the interceptor still does not respond to the test selector.

    XCTAssertThrowsSpecificNamed( [interceptor TEST_MSGFWD5_SELECTOR], NSException, NSInvalidArgumentException,
                                  @"Interceptor responds to '%s'", STRINGIFY( TEST_MSGFWD5_SELECTOR ) );

    XCTAssertFalse( blockWasInvoked,
                    @"Interceptor block for '%s' invoked on calling '%s'", STRINGIFY( TEST_MSGFWD5_OTHER_SELECTOR ), STRINGIFY( TEST_MSGFWD5_SELECTOR ) );

    // 7. Add an interception block for the unrecognized selector.

    [interceptor interceptSelector: @selector( TEST_MSGFWD5_SELECTOR )
                   methodSignature: [NSMethodSignature signatureWithObjCTypes: TEST_MSGFWD5_SELECTOR_SIG]
                         withBlock: ^BOOL(SUInterceptor *interceptor, NSInvocation *invocation) {

                             blockWasInvoked = YES;

                             // 7.a. Return YES (implying forwarding). No exception should be thrown.

                             return YES;
                         }];

    // 8. Ensure the interceptor now responds to the test selector

    XCTAssertNoThrowSpecificNamed( [interceptor TEST_MSGFWD5_SELECTOR], NSException, NSInvalidArgumentException,
                                   @"Interceptor does not respond to '%s' after adding, or message forwarded despite target not responding",
                                   STRINGIFY( TEST_MSGFWD5_SELECTOR ) );

    XCTAssertTrue( blockWasInvoked,
                   @"Interceptor block for '%s' not invoked after adding", STRINGIFY( TEST_MSGFWD5_SELECTOR ) );

    // 9. Remove the interception block for the selector.

    [interceptor removeInterceptionBlockForSelector: @selector( TEST_MSGFWD5_SELECTOR )];

    // 10. Ensure the interceptor now once again fails to recognize the selector.

    XCTAssertThrowsSpecificNamed( [interceptor TEST_MSGFWD5_SELECTOR], NSException, NSInvalidArgumentException,
                                  @"Interceptor continues to respond to %s after its interception block has been removed.", STRINGIFY( TEST_MSGFWD5_SELECTOR ) );
}


#pragma mark -
#pragma mark Message Return Value Substitution


/** Performs a message return value substitution test.
 *
 *  After invoking, the direct return value is stored in directValueName and the intercepted return value in interceptedValueName.
 *
 *  alternateValue may be an expression in terms of directValueName if invokeOriginal is YES.
 */

#define PERFORM_ALTERNATE_RETURN_VALUE_TEST( testObject, \
                                             returnType, interceptedSelector, signature, \
                                             alternateValue, directValueName, interceptedValueName, \
                                             invokeOriginal ) \
    _PERFORM_ALTERNATE_RETURN_VALUE_TEST_Q( testObject, \
                                            returnType, interceptedSelector, signature, \
                                            alternateValue, directValueName, interceptedValueName, \
                                            invokeOriginal, ) /* No storage qualifier */

/** Performs a message return value substitution test if the return value is an object.
 *
 *  After invoking, the direct return value is stored in directValueName and the intercepted return value in interceptedValueName.
 *
 *  alternateValue may be an expression in terms of directValueName if invokeOriginal is YES.
 */

#define PERFORM_ALTERNATE_OBJECT_RETURN_VALUE_TEST( testObject, \
                                                    returnType, interceptedSelector, signature, \
                                                    alternateValue, directValueName, interceptedValueName, \
                                                    invokeOriginal ) \
    _PERFORM_ALTERNATE_RETURN_VALUE_TEST_Q( testObject, \
                                            returnType, interceptedSelector, signature, \
                                            alternateValue, directValueName, interceptedValueName, \
                                            invokeOriginal, __autoreleasing ) /* __autoreleasing storage qualifier */

/** Performs a return-value substitution test.
 *
 *  After invoking, the direct value is stored in directValueName, the intercepted value in interceptedValueName.
 *
 *  alternateValue may be an expression in terms of directValueName if invokeOriginal is YES.
 *  storageQualifier is an optional storage qualifier for the intercepted return value (i.e. __autoreleasing for objects )
 */

#define _PERFORM_ALTERNATE_RETURN_VALUE_TEST_Q(  testObject, \
                                                 returnType, interceptedSelector, signature, \
                                                 alternateValue, directValueName, interceptedValueName, \
                                                 invokeOriginal, storageQualifier ) \
\
    returnType directValueName; returnType interceptedValueName; \
\
    { \
        __block BOOL blockWasInvoked = NO; \
\
        /* 1. Create an object. */  \
\
        id _testObject = testObject;     \
\
        /* 2. Create an SUInterceptor which intercepts messages sent to the object. */ \
\
        id interceptor = [SUInterceptor interceptorWithTarget: _testObject]; \
\
        /* 3. Intercept a selector on the object and return a different value. */ \
\
        [interceptor interceptSelector: @selector( interceptedSelector ) \
                       methodSignature: [NSMethodSignature signatureWithObjCTypes: signature] \
                             withBlock: ^BOOL( SUInterceptor *interceptor, NSInvocation *invocation ) { \
\
            blockWasInvoked = YES; \
\
            returnType storageQualifier directValueName; \
\
            if( invokeOriginal ) \
            { \
                [invocation invoke]; \
                [invocation getReturnValue: &directValueName]; \
            } \
\
            returnType storageQualifier interceptedValueName = alternateValue; \
            [invocation setReturnValue: &interceptedValueName]; \
\
            return NO; \
        }]; \
\
        /* 4. Get the direct and intercepted values. */ \
\
        directValueName      = [_testObject  interceptedSelector]; \
        interceptedValueName = [interceptor  interceptedSelector]; \
\
        /* 5. Verify that the block was invoked. */ \
\
        XCTAssertTrue( blockWasInvoked , @"Interception block was not invoked" ); \
}


/** Tests that an interceptor may provide an alternate integral return value. */

- (void)testReturnValueInterception1 {

    const NSUInteger alternateReturnValue = arc4random();

    /* Perform the interception test and get the direct & intercepted values. */

    PERFORM_ALTERNATE_RETURN_VALUE_TEST( @"Test", NSUInteger, length, "I@:", alternateReturnValue, directValue, interceptedValue, NO )

    /* Verify that the intercepted value was what was expected, and that direct and intercepted values differ. */

    XCTAssertEqual   ( interceptedValue, alternateReturnValue, @"Interception block returned unexpected value" );

    XCTAssertNotEqual( directValue, interceptedValue, @"Intercepted return value equal to direct value" );
}

/** Tests that an interceptor may invoke and read the return value of a method returning an integral type and provide a modified version. */

- (void)testReturnValueInterception2 {

    const NSUInteger alternateValueDiff = arc4random();

    /* Perform the interception test and get the direct & intercepted values. */

    PERFORM_ALTERNATE_RETURN_VALUE_TEST( @"Test", NSUInteger, length, "I@:", directValue + alternateValueDiff, directValue, interceptedValue, YES )

    /* Verify that the intercepted value was what was expected, and that direct and intercepted values differ. */

    XCTAssertEqual   ( interceptedValue, directValue + alternateValueDiff, @"Interception block returned unexpected value" );
    XCTAssertNotEqual( directValue, interceptedValue, @"Intercepted return value equal to direct value" );
}

/** Tests that an interceptor may provide an alternate floating-point return value. */

- (void)testReturnValueInterception3 {

    const NSTimeInterval alternateReturnValue = arc4random() / M_PI;

    /* Perform the interception test and get the direct & intercepted values. */

    PERFORM_ALTERNATE_RETURN_VALUE_TEST( [NSDate date], NSTimeInterval, timeIntervalSinceReferenceDate, "d@:", alternateReturnValue, directValue, interceptedValue, NO )

    /* Verify that the intercepted value was what was expected, and that direct and intercepted values differ. */

    XCTAssertEqual   ( interceptedValue, alternateReturnValue, @"Interception block returned unexpected value" );
    XCTAssertNotEqual( directValue, interceptedValue, @"Intercepted return value equal to direct value" );
}

/** Tests that an interceptor may invoke and read the return value of a method returning a floating-point type and provide a modified version. */

- (void)testReturnValueInterception4 {

    const NSTimeInterval alternateValueDiff = arc4random() / M_PI;

    /* Perform the interception test and get the direct & intercepted values. */

    PERFORM_ALTERNATE_RETURN_VALUE_TEST( [NSDate date], NSTimeInterval, timeIntervalSinceReferenceDate, "d@:", directValue + alternateValueDiff, directValue, interceptedValue, YES )

    /* Verify that the intercepted value was what was expected, and that direct and intercepted values differ. */

    XCTAssertEqual   ( interceptedValue, directValue + alternateValueDiff, @"Interception block returned unexpected value" );
    XCTAssertNotEqual( directValue, interceptedValue, @"Intercepted return value equal to direct value" );
}

/** Tests that an interceptor may provide an alternate struct return value. */

- (void)testReturnValueInterception5 {

    const MyTestStruct alternateValue = RandomMyTestStruct();

    /* Perform the interception test and get the direct & intercepted values. */

    PERFORM_ALTERNATE_RETURN_VALUE_TEST( [MyTestClass new],
                                         MyTestStruct, structReturnMethod, "{MyTestStruct=ddQQQ}@:",
                                         alternateValue, directValue, interceptedValue, NO )

    /* Verify that the intercepted value was what was expected, and that direct and intercepted values differ. */

    XCTAssertTrue ( MyTestStructEquals( interceptedValue, alternateValue ), @"Interception block returned unexpected value" );
    XCTAssertFalse( MyTestStructEquals( directValue, interceptedValue ), @"Intercepted return value equal to direct value" );
}

/** Tests that an interceptor may invoke and read the return value of a method returning a struct and provide a modified version. */

- (void)testReturnValueInterception6 {

    const unsigned long long alternateField3Value = arc4random();

    /* Perform the interception test and get the direct & intercepted values. */

    PERFORM_ALTERNATE_RETURN_VALUE_TEST( [MyTestClass new],
                                         MyTestStruct, structReturnMethod, "{MyTestStruct=ddQQQ}@:",
                                         directValue; interceptedValue.field3 = alternateField3Value, directValue, interceptedValue, YES )

    /* Verify that the intercepted value was what was expected, and that direct and intercepted values differ. */

    XCTAssertTrue ( interceptedValue.field3 == alternateField3Value, @"Interception block returned unexpected value" );
    XCTAssertFalse( MyTestStructEquals( directValue, interceptedValue ), @"Intercepted return value equal to direct value" );

    interceptedValue.field3 = directValue.field3;
    XCTAssertTrue( MyTestStructEquals( directValue, interceptedValue ), @"Interception block returned unexpected value" );
}

/** Tests that an interceptor may provide an alternate object return value. */

- (void)testReturnValueInterception7 {

    NSArray  * testObject     = [NSArray arrayWithObjects: [NSObject new], [NSObject new], nil];
    NSObject * alternateValue = [NSNull null];

    /* Perform the interception test and get the direct & intercepted values. */

    PERFORM_ALTERNATE_OBJECT_RETURN_VALUE_TEST( testObject,
                                                NSObject *, lastObject, "@@:I",
                                                alternateValue, directValue, interceptedValue, NO )

    /* Verify that the intercepted value was what was expected, and that direct and intercepted values differ. */

    XCTAssertEqual   ( interceptedValue, alternateValue, @"Interception block returned unexpected value" );
    XCTAssertNotEqual( directValue, interceptedValue, @"Intercepted return value equal to direct value" );
}

/** Tests that an interceptor may invoke and read the return value of a method returning an object and provide a modified version. */

- (void)testReturnValueInterception8 {

    NSArray  * testObject         = [NSArray arrayWithObjects: [NSString stringWithFormat: @"%u", arc4random()], [NSString stringWithFormat: @"%u", arc4random()], nil];
    NSString * alternateValueDiff = [NSString stringWithFormat: @"-%u", arc4random()];

    /* Perform the interception test and get the direct & intercepted values. */

    PERFORM_ALTERNATE_OBJECT_RETURN_VALUE_TEST( testObject,
                                                NSString *, lastObject, "@@:",
                                                [directValue stringByAppendingString: alternateValueDiff], directValue, interceptedValue, YES )

    /* Verify that the intercepted value was what was expected, and that direct and intercepted values differ. */

    XCTAssertEqualObjects( [interceptedValue substringToIndex:   [[testObject lastObject] length]], directValue,      @"Interception block returned unexpected value" );
    XCTAssertEqualObjects( [interceptedValue substringFromIndex: [[testObject lastObject] length]], alternateValueDiff, @"Interception block returned unexpected value" );

    XCTAssertNotEqual    ( directValue, interceptedValue, @"Intercepted return value equal to direct value" );
}


#pragma mark -
#pragma mark Message Parameter Substitution


/** Performs a message parameter substitution test.
 *
 *  After invoking, the direct returnvalue is stored in directValueName and the intercepted return value in interceptedValueName.
 *
 *  substitutedValue may be an expression in terms of directValueName (this time referencing the direct parameter value).
 */

#define PERFORM_ARGUMENT_SUBSTITUTION_TEST( testObject, returnType, interceptedSelector, signature, \
                                            directValueName, interceptedValueName, \
                                            substitutedArgumentIndex, substitutedArgumentType, substitutedValue, \
                                            testInvocation ) \
_PERFORM_ARGUMENT_SUBSTITUTION_TEST( testObject, returnType, interceptedSelector, signature, \
                                     directValueName, interceptedValueName, \
                                     substitutedArgumentIndex, substitutedArgumentType, , substitutedValue, \
                                     testInvocation )

/** Performs a message object-parameter substitution test.
 *
 *  After invoking, the direct returnvalue is stored in directValueName and the intercepted return value in interceptedValueName.
 *
 *  substitutedValue may be an expression in terms of directValueName (this time referencing the direct parameter value).
 */

#define PERFORM_OBJECT_ARGUMENT_SUBSTITUTION_TEST( testObject, returnType, interceptedSelector, signature, \
                                                   directValueName, interceptedValueName, \
                                                   substitutedArgumentIndex, substitutedArgumentType, substitutedValue, \
                                                   testInvocation ) \
_PERFORM_ARGUMENT_SUBSTITUTION_TEST( testObject, returnType, interceptedSelector, signature, \
                                     directValueName, interceptedValueName, \
                                     substitutedArgumentIndex, substitutedArgumentType, __autoreleasing, substitutedValue, \
                                     testInvocation )


#define _PERFORM_ARGUMENT_SUBSTITUTION_TEST( testObject, returnType, interceptedSelector, signature, \
                                              directValueName, interceptedValueName, \
                                              substitutedArgumentIndex, substitutedArgumentType, storageQualifier, substitutedValue, \
                                              testInvocation ) \
\
    returnType directValueName; returnType interceptedValueName; \
    __block BOOL blockWasInvoked = NO; \
{ \
    /* 1. Create an object */ \
    id _testObject = testObject; \
\
    /* 2. Create an SUInterceptor which intercepts messages to the object. */ \
    id interceptor = [SUInterceptor interceptorWithTarget: _testObject]; \
\
    /* 3. Intercept a selector on the object and substitute a different argument value. */ \
    [interceptor interceptSelector: @selector( interceptedSelector ) \
                   methodSignature: [NSMethodSignature signatureWithObjCTypes: signature] \
                         withBlock: ^BOOL( SUInterceptor * interceptor, NSInvocation * invocation ) { \
\
        blockWasInvoked = YES; \
\
        /* Get the argument value in to directValueName */ \
        substitutedArgumentType storageQualifier directValueName; \
        [invocation getArgument: &directValueName atIndex: (substitutedArgumentIndex + 2)]; \
\
        /* Substitute the argument value. */ \
        substitutedArgumentType storageQualifier interceptedValueName = substitutedValue; \
        [invocation setArgument: &interceptedValueName atIndex: (substitutedArgumentIndex + 2)]; \
\
        /* Forward the invocation. */ \
        return YES; \
    }]; \
\
    /* 4. Get the direct and intercepted values. */ \
    directValueName      = [_testObject testInvocation]; \
    interceptedValueName = [interceptor testInvocation]; \
\
    /* 5. Verify that the block was invoked. */ \
    XCTAssertTrue( blockWasInvoked , @"Interception block was not invoked" ); \
}


/** Tests that an interceptor may substitute a primitive parameter in a simple (single-parameter) selector. */

- (void)testParameterSubstitution1 {

    const NSUInteger numObjs = ( arc4random()%20 ) + 2;
    NSMutableArray * object  = [[NSMutableArray alloc] init];

    for( NSUInteger i = 0; i < numObjs; i++ )
    {
        [object addObject: @( i )];
    }

    NSUInteger testObjIdx   = ( arc4random()%numObjs );
    testObjIdx              = MIN( testObjIdx, numObjs - 2 );

    /* Perform the substitution test and get the direct and intercepted return values. */

    PERFORM_ARGUMENT_SUBSTITUTION_TEST( object, id, objectAtIndex:, "@@:@",
                                        directValue, interceptedValue,
                                        0, NSUInteger, directValue + 1,
                                        objectAtIndex: testObjIdx )

    /* Verify that the intercepted value is what was expected, and that the direct and intercepted values differ. */

    XCTAssertNotEqualObjects( directValue, interceptedValue, @"Intercepted return value equal to direct value" );
    XCTAssertEqualObjects( [object objectAtIndex: testObjIdx + 1], interceptedValue, @"Interception block returned unexpected value" );
}

/** Tests than an interceptor may substitute a primitive parameter in a complex (multiple-parameter) selector. */

- (void)testParameterSubstitution2 {

    /* Generate the mantissa and exponent of a positive number. */

    unsigned long long mantissa = arc4random();
    short exponent = (arc4random() % 256)-128;

    /* Perform the substitution test and get the direct and intercepted return values. */

    PERFORM_ARGUMENT_SUBSTITUTION_TEST( [NSDecimalNumber class],
                                        NSDecimalNumber*, decimalNumberWithMantissa:exponent:isNegative:, "@@:QsC",
                                        directValue, interceptedValue,
                                        2, BOOL, YES,
                                        decimalNumberWithMantissa: mantissa exponent: exponent isNegative: NO )

    /* Verify that the intercepted value is what was expected, and that the direct and intercepted values differ. */

    XCTAssertNotEqualObjects( directValue, interceptedValue, @"Intercepted return value equal to direct value" );

    NSDecimalNumber * minusOne = [NSDecimalNumber decimalNumberWithString: @"-1"];
    XCTAssertEqual( [directValue compare: interceptedValue], NSOrderedDescending, @"Interception block returned unexpected value" );
    XCTAssertEqualObjects( directValue, [interceptedValue decimalNumberByMultiplyingBy: minusOne], @"Interception block returned unexpected value" );
}

/** Tests that an interceptor may substitute an object parameter in a simple (single-parameter) selector. */

- (void)testParameterSubstitution3 {

    NSObject * anObject = [[NSObject alloc] init];
    NSSet    * object   = [NSSet setWithObjects: anObject, [NSObject new], nil];

    /* Perform the substitution test and get the direct and intercepted return values. */

    PERFORM_OBJECT_ARGUMENT_SUBSTITUTION_TEST( object,
                                               BOOL, containsObject:, "c@:@",
                                               directValue, interceptedValue,
                                               0, id, [NSObject new],
                                               containsObject: anObject )

    /* Verify that the intercepted value is what was expected, and that the direct and intercepted values differ. */

    XCTAssertNotEqual( directValue, interceptedValue, @"Intercepted return value equal to direct value" );
    XCTAssertTrue ( directValue, @"Unexpected direct return value" );
    XCTAssertFalse( interceptedValue, @"Interception block returned unexpected value" );
}

/** Tests than an interceptor may substitute an object parameter in a complex (multiple-parameter) selector. */

- (void)testParameterSubstitution4 {

    const NSUInteger specialKey  = arc4random() % 20;
    NSMutableDictionary * object = [NSMutableDictionary dictionary];

    for( NSUInteger i = 0; i < 20; i++ )
    {
        if( specialKey == i )
        {
            [object setObject: [NSNull null] forKey: @( i )];
        }
        else
        {
            [object setObject: [NSObject new] forKey: @( i )];
        }
    }

    /* Perform the substitution test and get the direct and intercepted return values. */

    PERFORM_OBJECT_ARGUMENT_SUBSTITUTION_TEST( object,
                                               NSSet*, keysOfEntriesWithOptions:passingTest:, "@@:I@?",
                                               directValue, interceptedValue,
                                               1, id, ^BOOL(id key, id obj, BOOL*stop){ return ( NSNull.class == [obj class] ); },
                                               keysOfEntriesWithOptions: NSEnumerationConcurrent passingTest: ^BOOL(id key, id obj, BOOL *stop) {
                                                   return ( NSNull.class != [obj class] );
                                               } )

    /* Verify that the intercepted value is what was expected, and that the direct and intercepted values differ. */

    XCTAssertNotEqualObjects( directValue, interceptedValue, @"Intercepted return value equal to direct value" );

    XCTAssertEqual( directValue.count     , 19, @"Unexpected direct return value" );
    XCTAssertFalse( [directValue containsObject: @( specialKey )], @"Unexpected direct return value" );

    XCTAssertEqual( interceptedValue.count,  1, @"Interception block returned unexpected value");
    XCTAssertEqualObjects( @( specialKey ), [interceptedValue anyObject], @"Interception block returned unexpected value" );
}

/** Tests that an interceptor may substitute a struct parameter in a simple (single-parameter) selector. */

- (void)testParameterSubstitution5 {

    /* Create a test structure with non-zero value of field 2. */

    MyTestStruct testStruct = RandomMyTestStruct();

    while( 0 == testStruct.field2 )
    {
        testStruct.field2 = arc4random()/M_PI;
    }

    /* Perform the substitution test and get the direct and intercepted return values. */

    const char * encodedSig = [[MyTestClass methodSignatureForSelector: @selector( testStructField2IsPositive: )] getEncodedSignature];

    PERFORM_ARGUMENT_SUBSTITUTION_TEST( [MyTestClass class],
                                        BOOL, testStructField2IsPositive:, encodedSig,
                                        directValue, interceptedValue,
                                        0, MyTestStruct, testStruct; interceptedValue.field2 *= -1,
                                        testStructField2IsPositive: testStruct )

    free( (void*)encodedSig );
    encodedSig = NULL;

    /* Verify that the intercepted value is what was expected, and that the direct and intercepted values differ. */

    XCTAssertNotEqual( directValue, interceptedValue, @"Intercepted return value equal to direct value" );

    XCTAssertEqual( directValue, [MyTestClass testStructField2IsPositive: testStruct], @"Unexpected direct return value" );
}

/** Tests that an interceptor may substitute a struct parameter in a complex (multiple-parameter) selector. */

- (void)testParameterSubstitution6 {

    NSString * object            = [NSString stringWithFormat: @"%u", arc4random()];
    NSString * interceptedString = [NSString stringWithFormat: @"%u", arc4random()];

    /* Perform the substitution test and get the direct and intercepted return values. */

    const char * encodedSignature = [[NSString instanceMethodSignatureForSelector: @selector( stringByReplacingCharactersInRange:withString: )] getEncodedSignature];

    PERFORM_ARGUMENT_SUBSTITUTION_TEST( object,
                                        NSString *, stringByReplacingCharactersInRange:withString:, encodedSignature,
                                        directValue, interceptedValue,
                                        0, NSRange, NSMakeRange( 0, [object length] ),
                                        stringByReplacingCharactersInRange: NSMakeRange( 0, 0 ) withString: interceptedString )

    free( (void*)encodedSignature );
    encodedSignature = NULL;

    /* Verify that the intercepted value is what was expected, and that the direct and intercepted values differ. */

    XCTAssertNotEqualObjects( directValue, interceptedValue, @"Intercepted return value equal to direct value" );

    XCTAssertEqualObjects( directValue, [interceptedString stringByAppendingString: object], @"Unexpected direct return value" );
    XCTAssertEqualObjects( interceptedValue, interceptedString, @"Interception block returned unexpected value" );
}


#pragma mark -
#pragma mark Changing the Message Target


/** Tests that an interceptor may redirect messages sent to an object. */

- (void)testInvocationRedirection1 {

    __block BOOL blockWasInvoked = NO;

    // 1. Create a pair of NSArrays containing different objects.
    //    arrayOne should be larger than arrayTwo.

    const NSUInteger arrayTwoSize = ( arc4random() % 20 ) + 1;
    const NSUInteger arrayOneSize = ( arc4random() % 20 ) + arrayTwoSize;

    NSMutableArray * arrayOne = [[NSMutableArray alloc] init];
    NSMutableArray * arrayTwo = [[NSMutableArray alloc] init];

    for( NSUInteger i = 0; i < arrayOneSize; i++ )
    {
        [arrayOne addObject: [NSObject new]];

        if( i < arrayTwoSize )
        {
            [arrayTwo addObject: [NSNull null]];
        }
    }

    // 2. Create an interceptor which forwards all messages to arrayOne,
    //    except objectAtIndex:, which it forwards to arrayTwo.

    id interceptor = [SUInterceptor interceptorWithTarget: arrayOne];

    [interceptor interceptSelector: @selector( objectAtIndex: )
                   methodSignature: [NSArray instanceMethodSignatureForSelector: @selector( objectAtIndex: )]
                         withBlock: ^BOOL( SUInterceptor *interceptor, NSInvocation * invocation ) {

                             blockWasInvoked = YES;

                             invocation.target = arrayTwo;

                             return YES;
                         }];

    /* Verify that the intercepted messages are forwarded to arrayTwo and non-intercepted messages to arrayOne. */

    XCTAssertEqual( [interceptor count], arrayOneSize, @"Unexpected value returned from interceptor" );
    XCTAssertEqual( [interceptor objectAtIndex: 0], [arrayTwo objectAtIndex: 0], @"Unexpected value returned from interceptor" );

    XCTAssertTrue( blockWasInvoked, @"Interceptor block was not invoked" );

    BOOL didRaise = NO;

    for( NSUInteger i = 0; i < [interceptor count]; i++ )
    {
        if( i < [arrayTwo count] )
        {
            XCTAssertNoThrow( [interceptor objectAtIndex: i],
                              @"Interceptor failed to correcly redirect message: unexpected exception raised" );
        }
        else
        {
            XCTAssertThrowsSpecificNamed( [interceptor objectAtIndex: i], NSException, NSRangeException,
                                          @"Interceptor failed to correctly redirect message: expected exception" );
            didRaise = YES;
        }
    }

    XCTAssertTrue( didRaise, @"Interceptor reported wrong number of objects, or arrayOne not larger than arrayTwo" );
}

/** Tests that an interceptor may intercept a message sent to an object and invoke a different message,
 *  storing the compatible return value in the intercepted invocation.
 */

- (void)testInvocationRedirection2 {

    // 1. Create an NSMutableDictionary with boxed integers as keys.

    NSMutableDictionary * object = [[NSMutableDictionary alloc] init];

    const NSUInteger numMembers  = ( arc4random() % 30 ) + 1;
    for ( NSUInteger i = 0; i < numMembers; i++ )
    {
        [object setObject: [NSObject new] forKey: [NSNumber numberWithUnsignedInteger: i]];
    }

    // 2. Create an SUInterceptor which converts objectAtIndex: calls to objectForKey: calls.

    __block BOOL blockWasInvoked = NO;

    id interceptor = [SUInterceptor interceptorWithTarget: object];

    [interceptor interceptSelector: @selector( objectAtIndex: )
                   methodSignature: [NSArray instanceMethodSignatureForSelector: @selector( objectAtIndex: )]
                         withBlock: ^BOOL(SUInterceptor *interceptor, NSInvocation * invocation) {

                             blockWasInvoked = YES;

                             // Get the argument.

                             NSUInteger index;
                             [invocation getArgument: &index atIndex: 2];

                             // Query the target directly using a boxed key.

                             NSNumber * boxedIndex     = [NSNumber numberWithUnsignedInteger: index];
                             id __autoreleasing retVal = [invocation.target objectForKey: boxedIndex];

                             // Set the return value.

                             [invocation setReturnValue: &retVal];

                             // Do not invoke objectAtIndex: on the dictionary.

                             return NO;
                         }];

    // 3. Query the dictionary's objects using unboxed keys

    for( NSUInteger i = 0; i < numMembers; i++ )
    {
        id directValue      = [object objectForKey: [NSNumber numberWithUnsignedInteger: i]];
        id interceptedValue = [interceptor objectAtIndex: i];

        XCTAssertEqual( directValue, interceptedValue, @"Interceptor returned unexpected value" );
    }

    XCTAssertTrue( blockWasInvoked, @"Interceptor block was not invoked" );

    // 4. Ensure that accesses beyond the dictionary's capacity yield NULL (as objectForKey: does for undefined keys)

    XCTAssertEqualObjects( [interceptor objectAtIndex: numMembers], NULL, @"Interceptor returned unexpected value" );
}


@end
