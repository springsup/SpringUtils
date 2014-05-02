//
//  SUMethodSignatureBuilder.m
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "SUMethodSignatureBuilder.h"

#import "../Utilities/SURuntimeAssertions.h"

@interface SUMethodSignatureParameter : NSObject
{
    @package
    NSString * encodedType;
    NSUInteger size;
}
@end

@implementation SUMethodSignatureParameter
@end


//=================================


@interface SUMethodSignatureBuilder ()
{
    NSPointerArray      * _parameters;
    NSMutableIndexSet   * _parameterIndexes;

    NSString            * _encodedReturnType;
    NSString            * _encodedTypesString;
}
@end

@implementation SUMethodSignatureBuilder

- (id)init {

    self = [super init];
    if( self )
    {
        _parameters        = [[NSPointerArray alloc] initWithOptions: NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality];
        _parameterIndexes  = [[NSMutableIndexSet alloc] init];
        _encodedReturnType = [NSString stringWithUTF8String: @encode( void )];
    }

    return self;
}

- (id)copyWithZone: (NSZone *)zone {

    SUMethodSignatureBuilder * copy = [[[self class] allocWithZone: zone] init];
    copy->_encodedReturnType        = [_encodedReturnType copyWithZone: zone];
    copy->_encodedTypesString       = [_encodedTypesString copyWithZone: zone];

    [_parameterIndexes enumerateIndexesUsingBlock: ^( NSUInteger idx, BOOL *stop ) {

        SUMethodSignatureParameter * parameter      = [_parameters pointerAtIndex: idx];
        SUMethodSignatureParameter * parameterCopy  = [[SUMethodSignatureParameter allocWithZone: zone] init];

        parameterCopy->encodedType  = [parameter->encodedType copy];
        parameterCopy->size         = parameter->size;

        [copy->_parameters insertPointer: (__bridge void*)parameterCopy atIndex: idx];
    }];

    [copy->_parameterIndexes addIndexes: _parameterIndexes];

    return copy;
}


#pragma mark -
#pragma mark Getting Method Signature Information


- (NSUInteger)numberOfParameters {

    return _parameterIndexes.count;
}

- (const char *)encodedTypeSignature {

    if( Nil == _encodedTypesString )
    {
        _encodedTypesString = [self buildEncodedMethodString];
    }

    return _encodedTypesString.UTF8String;
}

- (NSMethodSignature *)methodSignature {

    return [NSMethodSignature signatureWithObjCTypes: self.encodedTypeSignature];
}


#pragma mark -
#pragma mark Return Type Information


- (const char *)returnType {

    return _encodedReturnType.UTF8String;
}

- (void)setReturnType: (const char *)returnType {

    [self setReturnType: returnType flags: SUMethodStandardParameter];
}

- (void)setReturnType: (const char *)encodedReturnType flags: (SUMethodParameterFlags)returnTypeFlags {

    // Validate parameters.

    SU_ASSERT_NOT_EQUAL( encodedReturnType, NULL );

    // Set the return type.

    _encodedReturnType = GetEncodedType( encodedReturnType, returnTypeFlags );
}


#pragma mark -
#pragma mark Parameter Information


- (const char *)typeOfParameterAtIndex: (NSUInteger)parameterIndex {

    if( [_parameterIndexes containsIndex: parameterIndex] )
    {
        SUMethodSignatureParameter * parameter = [_parameters pointerAtIndex: parameterIndex];
        return parameter->encodedType.UTF8String;
    }

    return NULL;
}

- (void)setType: (const char *)encodedParameterType ofParameterAtIndex: (NSUInteger)parameterIndex {

    [self setType: encodedParameterType flags: SUMethodStandardParameter ofParameterAtIndex: parameterIndex];
}

- (void)setType: (const char *)encodedParameterType size: (NSUInteger)parameterSize ofParameterAtIndex: (NSUInteger)parameterIndex {

    [self setType: encodedParameterType size: parameterSize flags: SUMethodStandardParameter ofParameterAtIndex: parameterIndex];
}

- (void)setType: (const char *)encodedParameterType flags: (SUMethodParameterFlags)parameterFlags ofParameterAtIndex: (NSUInteger)parameterIndex {

    // Validate parameters.

    SU_ASSERT_NOT_EQUAL( encodedParameterType, NULL );

    // Get the frame size of the parameter's type.

    NSUInteger parameterSize = 0;

    if( isSmallIntegerType( encodedParameterType ) )
    {
        // Calling convention requires the frame size of all integral types smaller than int (incl. bool)
        // be rounded up to sizeof( int ).

        parameterSize = MAX( parameterSize, sizeof( int ) );
    }
    else if( isArrayType( encodedParameterType ) )
    {
        // The frame size of array types is the size of a pointer.

        parameterSize = sizeof( void* );
    }
    else
    {
        // For all other types:
        //
        // - Integer types >= int
        // - Floating-point types
        // - C Strings (char *)
        // - Non-packed Structs
        // - Unions
        // - Obj-C types (id, Class, SEL)
        // - Function pointers
        // - Blocks
        //
        // The frame size is equal to the actual size. Call NSGetSizeAndAlignment to get the size.

        NSGetSizeAndAlignment( encodedParameterType, &parameterSize, NULL );
    }

    // Set the parameter information.

    [self setType: encodedParameterType size: parameterSize flags: parameterFlags ofParameterAtIndex: parameterIndex];
}

- (void)setType: (const char *)encodedType size: (NSUInteger)size flags: (SUMethodParameterFlags)parameterFlags ofParameterAtIndex: (NSUInteger)parameterIndex {

    // Validate parameters.

    SU_ASSERT_NOT_EQUAL( encodedType, NULL );
    SU_ASSERT_LESS_THAN( parameterIndex, NSNotFound );

    // Get the parameter data.

    SUMethodSignatureParameter * argument = Nil;

    if( parameterIndex < _parameters.count )
    {
        argument = [_parameters pointerAtIndex: parameterIndex];
    }
    else
    {
        [_parameters setCount: ( parameterIndex + 1 )];
    }

    if( Nil == argument )
    {
        argument = [[SUMethodSignatureParameter alloc] init];

        [_parameters replacePointerAtIndex: parameterIndex withPointer: (__bridge void*)argument];
        [_parameterIndexes addIndex: parameterIndex];
    }

    // Update the parameter data.

    argument->encodedType   = GetEncodedType( encodedType, parameterFlags );
    argument->size          = size;

    // Invalidate the encoded type string

    _encodedTypesString = Nil;
}


#pragma mark -
#pragma mark Building the Encoded Method String


- (NSString *)buildEncodedMethodString {

    NSMutableString * mEncodedTypeString = [[NSMutableString alloc] init];

    // Encoding of type parameters follows the LLVM implementation
    //
    // See: ASTContext::getObjCEncodingForMethodDecl
    //      http://llvm.org/viewvc/llvm-project/cfe/trunk/lib/AST/ASTContext.cpp?view=markup


    NSUInteger pointerSize;
    NSGetSizeAndAlignment( @encode( void* ), &pointerSize, NULL );


    // Step 1:
    // Encode return type.


    if( 0 == _encodedReturnType.length )
    {
        [mEncodedTypeString appendFormat: @"%s", @encode( void )];
    }
    else
    {
        [mEncodedTypeString appendString: _encodedReturnType];
    }


    // Step 2:
    // Encode total size of all parameters


    __block NSUInteger totalParametersSize = 2 * pointerSize; // Implicit self, _cmd parameters

    [_parameterIndexes enumerateIndexesUsingBlock: ^( NSUInteger idx, BOOL *stop ) {

        SUMethodSignatureParameter * argument = (__bridge SUMethodSignatureParameter*)[_parameters pointerAtIndex: idx];
        totalParametersSize += argument->size;
    }];

    [mEncodedTypeString appendFormat: @"%lu", (unsigned long)totalParametersSize];


    // Step 3:
    // Encode built-in self, _cmd pointer parameters.


    __block NSUInteger parameterOffset = 0;

    parameterOffset = appendTypeToString( @encode( id  ), parameterOffset, mEncodedTypeString );
    parameterOffset = appendTypeToString( @encode( SEL ), parameterOffset, mEncodedTypeString );


    // Step 4:
    // Encode all other parameters.


    [_parameterIndexes enumerateIndexesUsingBlock: ^( NSUInteger idx, BOOL *stop ) {

        SUMethodSignatureParameter * argument = (__bridge SUMethodSignatureParameter*)[_parameters pointerAtIndex: idx];

        [mEncodedTypeString appendString: argument->encodedType];
        [mEncodedTypeString appendFormat: @"%lu", (long)parameterOffset];
        
        parameterOffset += argument->size;
    }];

    return mEncodedTypeString;
}

static inline NSUInteger appendTypeToString( const char * encodedTypeString, NSUInteger argumentOffset, NSMutableString * mEncodedTypeString ) {

    NSUInteger size;
    NSGetSizeAndAlignment( encodedTypeString, &size, NULL );

    // Write the type string followed by its offset

    [mEncodedTypeString appendFormat: @"%s%lu", encodedTypeString, (long)argumentOffset];

    // Return the new offset

    return argumentOffset + size;
}

static void writeParameterFlagsToString( SUMethodParameterFlags flags, NSMutableString * mEncodedTypeString ) {

    // Write parameter flags in the same order that Clang does so that unit testing can do a straight comparison.
    // The order is unlikely to be important to the runtime.
    //
    // See: ASTContext::getObjCEncodingForTypeQualifier

    if( flags & SUMethodInParameter )
    {
        [mEncodedTypeString appendString: @"n"];
    }

    if( flags & SUMethodInOutParameter )
    {
        [mEncodedTypeString appendString: @"N"];
    }

    if( flags & SUMethodOutParameter )
    {
        [mEncodedTypeString appendString: @"o"];
    }

    if( flags & SUMethodByCopyParameter )
    {
        [mEncodedTypeString appendString: @"O"];
    }

    if( flags & SUMethodByRefParameter )
    {
        [mEncodedTypeString appendString: @"R"];
    }

    if( flags & SUMethodOneWayParameter )
    {
        [mEncodedTypeString appendString: @"V"];
    }
}

static inline NSString * GetEncodedType( const char * encodedTypeString, SUMethodParameterFlags flags ) {

    NSMutableString * str = [[NSMutableString alloc] init];
    writeParameterFlagsToString( flags, str );
    [str appendFormat: @"%s", encodedTypeString];

    return str;
}


#pragma mark -
#pragma mark Type Checking


static inline BOOL isPrimitiveType( const char * encodedTypeString ) {

    static const char * nonPrimitiveTypeCharacters  = "{([^@#])}";

    return ( NULL == strpbrk( encodedTypeString, nonPrimitiveTypeCharacters ) );
}

static inline BOOL isSmallIntegerType( const char * encodedTypeString ) {

    // Small integer types:
    //
    // Bool   - 'B'
    // Char   - 'c'
    // Short  - 's'
    // UChar  - 'C'
    // UShort - 'S'

    static const char * smallIntegerTypes = "BcCsS";

    if( isPrimitiveType( encodedTypeString ) )
    {
        return ( NULL != strpbrk( encodedTypeString, smallIntegerTypes ) );
    }

    return NO;
}

static inline BOOL isArrayType( const char * encodedTypeString ) {

    // Check for presence of square brackets denoting an array type.

    return ( ( NULL != strchr( encodedTypeString, '[' ) ) &&
             ( NULL != strchr( encodedTypeString, ']' ) )  );
}

@end
