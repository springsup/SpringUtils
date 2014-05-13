//
//  SUMethodSignatureBuilderTests.m
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <XCTest/XCTest.h>
#import "SUMethodSignatureBuilder.h"
#import <objc/runtime.h>

struct TestStruct {
    UInt64 field1;
    UInt64 field2;
    UInt16 field3;
    UInt8  field4;
};

union TestUnion {
    UInt32 wholeNum;
    struct {
        UInt16 top;
        UInt16 bottom;
    } splitNum;
};

struct TestLittleStruct {

    _Bool field1;
    _Bool field2;
    char  field3;
};

struct TestPackedStruct {
    UInt32 field1;
    UInt16 field2;
    UInt8  field3;
}__attribute__((packed));

struct TestBitField {
    UInt32 field1;
    unsigned int field2 : 1;
    unsigned int field3 : 6;
};

@interface TestMethodDeclaratations : NSObject
@end

@implementation TestMethodDeclaratations

- (void)noReturnNoArgs {}

// Argument types

- (void)noReturnCharArg:     (char)arg { }
- (void)noReturnIntArg:      (int)arg { }
- (void)noReturnShortArg:    (short)arg { }
- (void)noReturnLongArg:     (long)arg { }
- (void)noReturnLongLongArg: (long long)arg { }

- (void)noReturnUCharArg:     (unsigned char)arg { }
- (void)noReturnUIntArg:      (unsigned int)arg { }
- (void)noReturnUShortArg:    (unsigned short)arg { }
- (void)noReturnULongArg:     (unsigned long)arg { }
- (void)noReturnULongLongArg: (unsigned long long)arg { }

- (void)noReturnFloatArg:      (float)arg { }
- (void)noReturnDoubleArg:     (double)arg { }
- (void)noReturnLongDoubleArg: (long double)arg { }
- (void)noReturnBoolArg:       (_Bool)arg { }
- (void)noReturnCStrArg:       (char *)arg { }

- (void)noReturnObjArg:   (id)arg { }
- (void)noReturnClassArg: (Class)arg { }
- (void)noReturnSelArg:   (SEL)arg { }

- (void)noReturnArrayArg:  (int[])arg { }
- (void)noReturnStructArg: (struct TestStruct)arg { }
- (void)noReturnUnionArg:  (union TestUnion)arg { }

- (void)noReturnPointerArg:         (BOOL*)arg { }
- (void)noReturnFunctionPointerArg: (int(*)(BOOL,BOOL))arg { }
- (void)noReturnBlockArg:           (int(^)(BOOL,BOOL))arg { }

- (void)noReturnFixedSizeArrayArg: (int[50])arg { }
- (void)noReturnLittleStructArg:   (struct TestLittleStruct)arg { }
- (void)noReturnVarArgs:           (int)a,... { }

// Return Types

- (char)charReturnNoArgs          { return 'X'; }
- (int)intReturnNoArgs            { return 0; }
- (short)shortReturnNoArgs        { return 0; }
- (long)longReturnNoArgs          { return 0; }
- (long long)longLongReturnNoArgs { return 0; }

- (unsigned char)uCharReturnNoArgs          { return 0; }
- (unsigned int)uIntReturnNoArgs            { return 0; }
- (unsigned short)uShortReturnNoArgs        { return 0; }
- (unsigned long)uLongReturnNoArgs          { return 0; }
- (unsigned long long)uLongLongReturnNoArgs { return 0; }

- (float)floatReturnNoArgs            { return 0; }
- (double)doubleReturnNoArgs          { return 0; }
- (long double)longDoubleReturnNoArgs { return 0; }
- (_Bool)boolReturnNoArgs             { return 0; }
- (char *)cStrReturnNoArgs            { return "X"; }

- (id)objReturnNoArgs       { return self; }
- (Class)classReturnNoArgs  { return self.class;}
- (SEL)selReturnNoArgs      { return _cmd; }

- (struct TestStruct)structReturnNoArgs { struct TestStruct a; return a; }
- (union TestUnion)unionReturnNoArgs    { union TestUnion a; return a; }

- (long*)pointerReturnNoArgs                     { return NULL; }
- (int(*)(BOOL,BOOL))functionPointerReturnNoArgs { return NULL; }
- (int(^)(BOOL,BOOL))blockReturnNoArgs           { return NULL; }

- (struct TestLittleStruct)littleStructReturnNoArgs { struct TestLittleStruct a; return a; }

// Assorted

- (char)charReturnCharArg: (char)arg  { return 'X'; }
- (char)charReturnBoolArg: (_Bool)arg { return 'X'; }

- (unsigned long long)ulonglongReturnCharArg:  (char)arg                              { return 1; }
- (unsigned long long)ulonglongReturnBlockArg: ( void(^)(int, id, void(^)(BOOL)) )arg { return 1; }

- (id)objectReturnObjectArg:       (id)arg                      { return Nil; }
- (id)objectReturnLittleStructArg: (struct TestLittleStruct)arg { return Nil; }

// Multiple Arguments

- (Class)classReturnConstCStrArg: (const char *)arg1
                       objectArg: (id)arg2 { return self.class; }

- (struct TestLittleStruct)littleStructReturnBoolArg: (_Bool)arg1
                                              SELArg: (SEL)arg2 { struct TestLittleStruct a; return a; }

- (union TestUnion)unionReturnCharArg: (char)arg1
                            uShortArg: (unsigned short)arg2
                            doubleArg: (double)arg3 { union TestUnion a; return a; }

- (void **)voidPtrPtrReturnFixedSizeArrayArg: (__strong id[10])arg1
                                    blockArg: (void(^)(BOOL)) arg2 { return NULL; }

- (id)objectReturnDoubleArg: (double)arg1 doubleArg: (double)arg2 boolArg: (_Bool)arg3 pointerArg: (int*)arg4
    { return Nil; }

- (void)noReturnDoubleArg: (double)arg1
                structArg: (struct TestStruct)arg2
              longLongArg: (long long)arg3
                 shortArg: (short)arg4
                structArg: (struct TestStruct)arg5
                objectArg: (id)arg6
                  boolArg: (_Bool)arg7
             constCStrArg: (const char *)arg8
                 unionArg: (union TestUnion)arg9
                 classArg: (Class)arg10 { }

// Packed Structures

- (void)noReturnPackedStructArg: (struct TestPackedStruct)arg { }

- (struct TestPackedStruct)packedStructReturnUCharArg: (unsigned char)arg
    { struct TestPackedStruct a; return a; }

- (const char *)constCStrReturnPackedStructArg: (struct TestPackedStruct)arg1 CStrArg: (char *)arg2
    { return "X"; }

// Bitfields

- (void)noReturnBitfieldArg: (struct TestBitField)arg { }

- (struct TestBitField)bitfieldReturnBitfieldArg: (struct TestBitField)arg { return arg; }

- (union TestUnion*)pointerReturnBitfieldArg: (struct TestBitField)arg1 fixedSizeArrayArg: (struct TestBitField[4])arg2  { return NULL; }

// Qualified Arguments (in, inout, out, byref, bycopy, oneway)

- (void)noReturnInPointerArg:                 (in void*)arg              { }
- (void)noReturnInObjectPointerArg:           (in id*)arg                { }
- (const char*)constCStrReturnInULongLongArg: (in unsigned long long)arg { return "X"; }

- (_Bool)boolReturnInOutPointerArg:                (inout struct TestStruct *)arg  { return YES; }
- (unsigned long)uLongReturnInOutObjectPointerArg: (inout id*) arg                 { return 0; }
- (void)noReturnInOutCStrArg:                      (inout char**)arg               { }

- (void)noReturnOutPointerArg:   (out _Bool*)arg       { }
- (void)noReturnOutConstCStrArg: (out const char**)arg { }
- (_Bool)boolReturnOutObjectArg: (out id*)arg          { return YES; }

- (void)noReturnIntArg:                                   (int)arg1 byCopyObjectArg: (bycopy id)arg2 { }
- (const char *)constCStrReturnByCopyOutObjectPointerArg: (bycopy out id*)arg                        { return "X"; }
- (bycopy id)byCopyObjectReturnNoArgs                                                                { return Nil; }

- (byref id)byRefObjectReturnNoArgs                                       { return Nil; }
- (void)noReturnByRefObjectArg: (byref id)arg                             { }
- (long)longReturnLongArg:      (long)arg1 byRefObjectArg: (byref id)arg2 { return 0; }

- (oneway void)onewayNoReturn                    {}
- (oneway void)onewayNoReturnBoolArg: (_Bool)arg {}

@end


//=========================


@interface SUMethodSignatureBuilderTests : XCTestCase
{
    SUMethodSignatureBuilder * _signatureBuilder;
}
@end

@implementation SUMethodSignatureBuilderTests

- (void)setUp
{
    [super setUp];

    _signatureBuilder = [[SUMethodSignatureBuilder alloc] init];
}

- (void)tearDown
{
    _signatureBuilder = Nil;

    [super tearDown];
}

- (void)verifyTypeEncodingForTestMethodWithSelector: (SEL)testMethodSelector {

    const char * generatedTypeEncoding = _signatureBuilder.encodedTypeSignature;

    Method actualMethod            = class_getInstanceMethod( TestMethodDeclaratations.class, testMethodSelector );
    const char * actualSignature   = method_getTypeEncoding( actualMethod );

//    NSLog( @"***************   %s", generatedTypeEncoding );

    BOOL equalEncodings = ( 0 == strcmp( generatedTypeEncoding, actualSignature ) );
    XCTAssert( equalEncodings,
               @"Generated signature incorrect: expected \"%s\" - got \"%s\"", actualSignature, generatedTypeEncoding );
}

#define GENERATE_TEST_WITH_PARAMS( testName, signatureBuilder, selector, returnType, params... )   \
- (void)testName {                                                                  \
                                                                                    \
    const char* args[]  = { params };                                               \
    const int numParams = sizeof( args ) / sizeof ( const char * );                 \
    for( int paramIdx = 0; paramIdx < numParams; paramIdx++ ) {                     \
        [signatureBuilder setType: args[paramIdx] ofParameterAtIndex: paramIdx];    \
    }                                                                               \
                                                                                    \
    if( NULL != returnType )                                                        \
        [signatureBuilder setReturnType: returnType];                               \
                                                                                    \
    [self verifyTypeEncodingForTestMethodWithSelector: selector ];                  \
}


#pragma mark -
#pragma mark Argument Types


GENERATE_TEST_WITH_PARAMS( testNoReturn_NoArgs, _signatureBuilder, @selector( noReturnNoArgs  ), NULL )

GENERATE_TEST_WITH_PARAMS( testNoReturn_CharArg,       _signatureBuilder, @selector( noReturnCharArg: ),       NULL, @encode( char ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_IntArg,        _signatureBuilder, @selector( noReturnIntArg:  ),       NULL, @encode( int ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_ShortArg,      _signatureBuilder, @selector( noReturnShortArg: ),      NULL, @encode( short ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_LongArg,       _signatureBuilder, @selector( noReturnLongArg: ),       NULL, @encode( long ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_LongLongArg,   _signatureBuilder, @selector( noReturnLongLongArg: ),   NULL, @encode( long long ) )

GENERATE_TEST_WITH_PARAMS( testNoReturn_UCharArg,      _signatureBuilder, @selector( noReturnUCharArg: ),      NULL, @encode( unsigned char ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_UIntArg,       _signatureBuilder, @selector( noReturnUIntArg: ),       NULL, @encode( unsigned int ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_UShortArg,     _signatureBuilder, @selector( noReturnUShortArg: ),     NULL, @encode( unsigned short ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_ULongArg,      _signatureBuilder, @selector( noReturnULongArg: ),      NULL, @encode( unsigned long ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_ULongLongArg,  _signatureBuilder, @selector( noReturnULongLongArg: ),  NULL, @encode( unsigned long long ) )

GENERATE_TEST_WITH_PARAMS( testNoReturn_FloatArg,      _signatureBuilder, @selector( noReturnFloatArg: ),      NULL, @encode( float ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_DoubleArg,     _signatureBuilder, @selector( noReturnDoubleArg: ),     NULL, @encode( double ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_LongDoubleArg, _signatureBuilder, @selector( noReturnLongDoubleArg: ), NULL, @encode( long double ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_BoolArg,       _signatureBuilder, @selector( noReturnBoolArg: ),       NULL, @encode( _Bool ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_CStrArg,       _signatureBuilder, @selector( noReturnCStrArg: ),       NULL, @encode( char * ) )

GENERATE_TEST_WITH_PARAMS( testNoReturn_ObjArg,        _signatureBuilder, @selector( noReturnObjArg: ),        NULL, @encode( id ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_ClassArg,      _signatureBuilder, @selector( noReturnClassArg: ),      NULL, @encode( Class ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_SelArg,        _signatureBuilder, @selector( noReturnSelArg: ),        NULL, @encode( SEL ) )

GENERATE_TEST_WITH_PARAMS( testNoReturn_ArrayArg,      _signatureBuilder, @selector( noReturnArrayArg: ),      NULL, @encode( int[] ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_StructArg,     _signatureBuilder, @selector( noReturnStructArg: ),     NULL, @encode( struct TestStruct ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_UnionArg,      _signatureBuilder, @selector( noReturnUnionArg: ),      NULL, @encode( union TestUnion   ) )

GENERATE_TEST_WITH_PARAMS( testNoReturn_PointerArg, _signatureBuilder, @selector( noReturnPointerArg: ),         NULL, @encode( BOOL* )             )
GENERATE_TEST_WITH_PARAMS( testNoReturn_FuncPtrArg, _signatureBuilder, @selector( noReturnFunctionPointerArg: ), NULL, @encode( int(*)(BOOL,BOOL) ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_BlockArg,   _signatureBuilder, @selector( noReturnBlockArg: ),           NULL, @encode( int(^)(BOOL,BOOL) ) )

GENERATE_TEST_WITH_PARAMS( testNoReturn_FixedSizeArrayArg, _signatureBuilder, @selector( noReturnFixedSizeArrayArg: ), NULL, @encode( int[50] ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_LittleStructArg,   _signatureBuilder, @selector( noReturnLittleStructArg: ),   NULL, @encode( struct TestLittleStruct ) )
GENERATE_TEST_WITH_PARAMS( testNoReturn_VarArgs,           _signatureBuilder, @selector( noReturnVarArgs: ),           NULL, @encode( int ) )


#pragma mark -
#pragma mark Return Types


GENERATE_TEST_WITH_PARAMS( testCharReturn_NoArgs,       _signatureBuilder, @selector( charReturnNoArgs ),       @encode( char ) )
GENERATE_TEST_WITH_PARAMS( testIntReturn_NoArgs,        _signatureBuilder, @selector( intReturnNoArgs  ),       @encode( int ) )
GENERATE_TEST_WITH_PARAMS( testShortReturn_NoArgs,      _signatureBuilder, @selector( shortReturnNoArgs ),      @encode( short ) )
GENERATE_TEST_WITH_PARAMS( testLongReturn_NoArgs,       _signatureBuilder, @selector( longReturnNoArgs ),       @encode( long ) )
GENERATE_TEST_WITH_PARAMS( testLongLongReturn_NoArgs,   _signatureBuilder, @selector( longLongReturnNoArgs ),   @encode( long long ) )

GENERATE_TEST_WITH_PARAMS( testUCharReturn_NoArgs,      _signatureBuilder, @selector( uCharReturnNoArgs ),      @encode( unsigned char ) )
GENERATE_TEST_WITH_PARAMS( testUIntReturn_NoArgs,       _signatureBuilder, @selector( uIntReturnNoArgs ),       @encode( unsigned int ) )
GENERATE_TEST_WITH_PARAMS( testUShortReturn_NoArgs,     _signatureBuilder, @selector( uShortReturnNoArgs ),     @encode( unsigned short ) )
GENERATE_TEST_WITH_PARAMS( testULongReturn_NoArgs,      _signatureBuilder, @selector( uLongReturnNoArgs ),      @encode( unsigned long ) )
GENERATE_TEST_WITH_PARAMS( testULongLongReturn_NoArgs,  _signatureBuilder, @selector( uLongLongReturnNoArgs ),  @encode( unsigned long long ) )

GENERATE_TEST_WITH_PARAMS( testFloatReturn_NoArgs,      _signatureBuilder, @selector( floatReturnNoArgs ),      @encode( float ) )
GENERATE_TEST_WITH_PARAMS( testDoubleReturn_NoArgs,     _signatureBuilder, @selector( doubleReturnNoArgs ),     @encode( double ) )
GENERATE_TEST_WITH_PARAMS( testLongDoubleReturn_NoArgs, _signatureBuilder, @selector( longDoubleReturnNoArgs ), @encode( long double ) )
GENERATE_TEST_WITH_PARAMS( testBoolReturn_NoArgs,       _signatureBuilder, @selector( boolReturnNoArgs ),       @encode( _Bool ) )
GENERATE_TEST_WITH_PARAMS( testCStrReturn_NoArgs,       _signatureBuilder, @selector( cStrReturnNoArgs ),       @encode( char * ) )

GENERATE_TEST_WITH_PARAMS( testObjReturn_NoArgs,        _signatureBuilder, @selector( objReturnNoArgs ),        @encode( id ) )
GENERATE_TEST_WITH_PARAMS( testClassReturn_NoArgs,      _signatureBuilder, @selector( classReturnNoArgs ),      @encode( Class ) )
GENERATE_TEST_WITH_PARAMS( testSelReturn_NoArgs,        _signatureBuilder, @selector( selReturnNoArgs ),        @encode( SEL ) )

GENERATE_TEST_WITH_PARAMS( testStructReturn_NoArgs,     _signatureBuilder, @selector( structReturnNoArgs ),     @encode( struct TestStruct ) )
GENERATE_TEST_WITH_PARAMS( testUnionReturn_NoArgs,      _signatureBuilder, @selector( unionReturnNoArgs ),      @encode( union TestUnion   ) )

GENERATE_TEST_WITH_PARAMS( testPointerReturn_NoArgs, _signatureBuilder, @selector( pointerReturnNoArgs ),         @encode( long* ) )
GENERATE_TEST_WITH_PARAMS( testFuncPtrReturn_NoArgs, _signatureBuilder, @selector( functionPointerReturnNoArgs ), @encode( int(*)(BOOL,BOOL) ) )
GENERATE_TEST_WITH_PARAMS( testBlockReturn_NoArgs,   _signatureBuilder, @selector( blockReturnNoArgs ),           @encode( int(^)(BOOL,BOOL) ) )

GENERATE_TEST_WITH_PARAMS( testLittleStructReturn_NoArgs,   _signatureBuilder, @selector( littleStructReturnNoArgs ), @encode( struct TestLittleStruct ) )


#pragma mark -
#pragma mark Assorted


GENERATE_TEST_WITH_PARAMS( testCharReturn_CharArg, _signatureBuilder, @selector( charReturnCharArg: ), @encode( char ), @encode( char ) )
GENERATE_TEST_WITH_PARAMS( testCharReturn_BoolArg, _signatureBuilder, @selector( charReturnBoolArg: ), @encode( char ), @encode( _Bool ) )

GENERATE_TEST_WITH_PARAMS( testULongLongReturn_CharArg,  _signatureBuilder, @selector( ulonglongReturnCharArg: ),  @encode( unsigned long long ), @encode( char ) )
GENERATE_TEST_WITH_PARAMS( testULongLongReturn_BlockArg, _signatureBuilder, @selector( ulonglongReturnBlockArg: ), @encode( unsigned long long ), @encode( void(^)(int, id, void(^)(BOOL)) ) )

GENERATE_TEST_WITH_PARAMS( testObjectReturn_ObjectArg,       _signatureBuilder, @selector( objectReturnObjectArg: ),       @encode( id ), @encode( id ) )
GENERATE_TEST_WITH_PARAMS( testObjectReturn_LittleStructArg, _signatureBuilder, @selector( objectReturnLittleStructArg: ), @encode( id ), @encode( struct TestLittleStruct ) )


#pragma mark -
#pragma mark Multiple Arguments


GENERATE_TEST_WITH_PARAMS( testClassReturn_ConstCStrArg_ObjArg,                    _signatureBuilder, @selector( classReturnConstCStrArg:objectArg: ),
                           @encode( Class ), @encode( const char *), @encode( id ) )
GENERATE_TEST_WITH_PARAMS( testLittleStructReturn_BoolArg_SELArg,                  _signatureBuilder, @selector( littleStructReturnBoolArg:SELArg: ),
                           @encode( struct TestLittleStruct ), @encode( _Bool ), @encode( SEL ) )
GENERATE_TEST_WITH_PARAMS( testUnionReturn_CharArg_UShortArg_DouleArg,              _signatureBuilder, @selector( unionReturnCharArg:uShortArg:doubleArg: ),
                           @encode( union TestUnion ), @encode( char ), @encode( unsigned short ), @encode( double ) )
GENERATE_TEST_WITH_PARAMS( testVoidPtrPtrReturn_FixedSizeArrayArg_BlockArg,        _signatureBuilder, @selector( voidPtrPtrReturnFixedSizeArrayArg:blockArg: ),
                           @encode( void** ), @encode( id[10] ), @encode( void(^)(BOOL) ) )
GENERATE_TEST_WITH_PARAMS( testObjectReturn_DoubleArg_DoubleArg_BoolArg_PoinerArg, _signatureBuilder, @selector( objectReturnDoubleArg:doubleArg:boolArg:pointerArg: ),
                           @encode( id ), @encode( double ), @encode( double ), @encode( _Bool ), @encode( int* ) )

GENERATE_TEST_WITH_PARAMS( testNoReturn_DoubleArg_StructArg_LongLongArg_ShortArg_StructArg_ObjectArg_BoolArg_ConstCStrArg_UnionArg_ClassArg,
                           _signatureBuilder,
                           @selector( noReturnDoubleArg:structArg:longLongArg:shortArg:structArg:objectArg:boolArg:constCStrArg:unionArg:classArg: ),
                           @encode( void ),
                           @encode( double ), @encode( struct TestStruct ), @encode( long long ), @encode( short ), @encode( struct TestStruct ), @encode( id ), @encode( _Bool ), @encode( const char* ), @encode( union TestUnion ), @encode( Class ) )

#pragma mark -
#pragma mark Packed Structures


- (void)testNoReturn_PackedStructArg {

    [_signatureBuilder setType: @encode( struct TestPackedStruct ) size: sizeof( struct TestPackedStruct ) ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( noReturnPackedStructArg: )];
}

- (void)testPackedStructReturn_UCharArg {

    [_signatureBuilder setReturnType: @encode( struct TestPackedStruct )];
    [_signatureBuilder setType: @encode( unsigned char ) ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( packedStructReturnUCharArg: )];
}

- (void)testConstCStrReturn_PackedStructArg_CStrArg {

    [_signatureBuilder setReturnType: @encode( const char * )];
    [_signatureBuilder setType: @encode( struct TestPackedStruct ) size: sizeof( struct TestPackedStruct ) ofParameterAtIndex: 0];
    [_signatureBuilder setType: @encode( char * ) ofParameterAtIndex: 1];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( constCStrReturnPackedStructArg:CStrArg: )];
}


#pragma mark -
#pragma mark Bitfields


- (void)testNoReturn_BitfieldArg {

    [_signatureBuilder setType: @encode( struct TestBitField ) size: sizeof( struct TestBitField ) ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( noReturnBitfieldArg: )];
}

- (void)testBitfieldReturn_BitfieldArg {

    [_signatureBuilder setReturnType: @encode( struct TestBitField )];
    [_signatureBuilder setType: @encode( struct TestBitField ) size: sizeof( struct TestBitField ) ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( bitfieldReturnBitfieldArg: )];
}

- (void)testPointerReturn_BitfieldArg_FixedSizeArrayArg {

    [_signatureBuilder setReturnType: @encode( union TestUnion *)];
    [_signatureBuilder setType: @encode( struct TestBitField ) size: sizeof( struct TestBitField ) ofParameterAtIndex: 0];
    [_signatureBuilder setType: @encode( struct TestBitField[4] ) ofParameterAtIndex: 1];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( pointerReturnBitfieldArg:fixedSizeArrayArg: )];
}


#pragma mark -
#pragma mark Qualified Arguments (in, inout, etc)

// In

- (void)testNoReturn_InPointerArg {

    [_signatureBuilder setType: @encode( void* ) flags: SUMethodInParameter ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( noReturnInPointerArg: )];
}

- (void)testNoReturn_InObjectPointerArg {

    [_signatureBuilder setType: @encode( __unsafe_unretained id* ) flags: SUMethodInParameter ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( noReturnInObjectPointerArg: )];
}

- (void)testConstCStrReturn_InULongLongArg {

    [_signatureBuilder setReturnType: @encode( const char * )];
    [_signatureBuilder setType: @encode( unsigned long long ) flags: SUMethodInParameter ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( constCStrReturnInULongLongArg: )];
}

// InOut

- (void)testNoReturn_InOutCStrArg {

    [_signatureBuilder setType: @encode( char** ) flags: SUMethodInOutParameter ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( noReturnInOutCStrArg: )];
}

- (void)testBoolReturn_InOutPointerArg {

    [_signatureBuilder setReturnType: @encode( _Bool )];
    [_signatureBuilder setType: @encode( struct TestStruct * ) flags: SUMethodInOutParameter ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( boolReturnInOutPointerArg: )];
}

- (void)testULongReturn_InOutObjectPointerArg {

    [_signatureBuilder setReturnType: @encode( unsigned long )];
    [_signatureBuilder setType: @encode( __unsafe_unretained id* ) flags: SUMethodInOutParameter ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( uLongReturnInOutObjectPointerArg: )];
}

// Out

- (void)testNoReturn_OutPointerArg {

    [_signatureBuilder setType: @encode( _Bool* ) flags: SUMethodOutParameter ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( noReturnOutPointerArg: )];
}

- (void)testNoReturn_OutConstCStrArg {

    [_signatureBuilder setType: @encode( const char ** ) flags: SUMethodOutParameter ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( noReturnOutConstCStrArg: )];
}

- (void)testBoolReturn_OutObjectArg {

    [_signatureBuilder setReturnType: @encode( _Bool )];
    [_signatureBuilder setType: @encode( __strong id* ) flags: SUMethodOutParameter ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( boolReturnOutObjectArg: )];
}

// ByCopy

- (void)testNoReturn_IntArg_ByCopyObjectArg {

    [_signatureBuilder setType: @encode( int ) flags: SUMethodStandardParameter ofParameterAtIndex: 0];
    [_signatureBuilder setType: @encode( id )  flags: SUMethodByCopyParameter   ofParameterAtIndex: 1];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( noReturnIntArg:byCopyObjectArg: )];
}

- (void)testConstCStrReturn_ByCopyOutObjectPointerArg {

    [_signatureBuilder setReturnType: @encode( const char * )];
    [_signatureBuilder setType: @encode( __weak id* ) flags: SUMethodOutParameter | SUMethodByCopyParameter ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( constCStrReturnByCopyOutObjectPointerArg: )];
}

- (void)testByCopyObjectReturn_NoArgs {

    [_signatureBuilder setReturnType: @encode( id ) flags: SUMethodByCopyParameter];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( byCopyObjectReturnNoArgs )];
}

// ByRef

- (void)testByRefObjectReturn_NoArgs {

    [_signatureBuilder setReturnType: @encode( id ) flags: SUMethodByRefParameter];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( byRefObjectReturnNoArgs )];
}

- (void)testNoReturn_ByRefObjectArg {

    [_signatureBuilder setType: @encode( id ) flags: SUMethodByRefParameter ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( noReturnByRefObjectArg: )];
}

- (void)testLongReturn_LongArg_ByRefObjectArg {

    [_signatureBuilder setReturnType: @encode( long )];
    [_signatureBuilder setType: @encode( long ) ofParameterAtIndex: 0];
    [_signatureBuilder setType: @encode( id ) flags: SUMethodByRefParameter ofParameterAtIndex: 1];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( longReturnLongArg:byRefObjectArg: )];
}

// OneWay

- (void)testOneWayNoReturn {

    [_signatureBuilder setReturnType: @encode( void ) flags: SUMethodOneWayParameter];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( onewayNoReturn )];
}

- (void)testOneWayNoReturn_BoolArg {

    [_signatureBuilder setReturnType: @encode( void ) flags: SUMethodOneWayParameter];
    [_signatureBuilder setType: @encode( _Bool ) ofParameterAtIndex: 0];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( onewayNoReturnBoolArg: )];
}


#pragma mark -
#pragma mark Setting Parameter Types out-of-order


- (void)testSettingParameterTypesOutOfOrder {

    [_signatureBuilder setType: @encode( _Bool  ) ofParameterAtIndex: 2];
    [_signatureBuilder setType: @encode( double ) ofParameterAtIndex: 1];
    [_signatureBuilder setType: @encode( int*   ) ofParameterAtIndex: 3];
    [_signatureBuilder setType: @encode( double ) ofParameterAtIndex: 0];

    [_signatureBuilder setReturnType: @encode( id )];

    [self verifyTypeEncodingForTestMethodWithSelector: @selector( objectReturnDoubleArg:doubleArg:boolArg:pointerArg: )];

}

@end
