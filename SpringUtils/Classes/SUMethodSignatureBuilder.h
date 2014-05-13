//
//  SUMethodSignatureBuilder.h
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS( NSUInteger, SUMethodParameterFlags ){

    /** Declares a method parameter or return type with no qualifiers. */

    SUMethodStandardParameter   = 0,

    /** Declares that the method only reads from (and doesn't write to) the parameter.
     *
     *  This flag only makes sense for pointer types. */

    SUMethodInParameter         = 1 << 0,

    /** Declares that the method only writes to (and doesn't read from) the parameter.
     *
     *  This flag only makes sense for pointer types. */

    SUMethodOutParameter        = 1 << 1,

    /** Declares that the method may both read from- and write to the parameter.
     *
     *  This flag only makes sense for pointer types. */

    SUMethodInOutParameter      = 1 << 2,

    /** Declares that the method should be invoked with a copy of the parameter's value.
     *
     *  If this flag is set on an out/inout parameter or the method's return type, 
     *  the emitted value is a copy of the value immediately after the method's invocation.
     *
     *  This flag only makes sense for Objective-C object types. */

    SUMethodByCopyParameter     = 1 << 3,

    /** Declares that the method should be invoked with a reference to the parameter's value.
     *
     *  This flag only makes sense for Objective-C object types. */

    SUMethodByRefParameter      = 1 << 4,

    /** Declares that remote callers of a method may proceed without blocking.
     *
     *  This flag only makes sense on a method's return type, and only if the return type is void. */

    SUMethodOneWayParameter     = 1 << 5
};


/** SUMethodSignatureBuilder provides an interface for building method signatures at runtime.
 *
 *  Parameter indexes referenced by this class do not include the implicit 'self' or '_cmd' method parameters. They refer
 *  to the position of the parameter within a method's selector.
 *
 *  SUMethodSignature allows you to explicitly set the size of parameter types when creating method signatures. The size
 *  refers to the argframe size of the parameter's type, which for some types is not the same as their actual memory size.
 *  This makes it important that you don't explicitly set the size of the parameter type unless it really is neccessary (i.e. bitfields and packed structs).
 *
 *  For bitfields and packed structs, the argFrame size actually *is* the memory size of the type;
 *  so provide the parameter type's size using sizeof( MyPackedStruct ) or sizeof( MyBitfield ).
 */

@interface SUMethodSignatureBuilder : NSObject< NSCopying >


//--------------------------------------/
/** @name Getting the Method Signature */
//--------------------------------------/


/** The method signature represented by the receiver. */

@property ( nonatomic, readonly ) NSMethodSignature * methodSignature;

/** The Objective-C type string of the method represented by the receiver. */

@property ( nonatomic, readonly ) const char * encodedTypeSignature;


//---------------------------------/
/** @name Setting the Return Type */
//---------------------------------/


/** The type encoding of the return type of the method signature being built by the receiver. */

@property ( nonatomic ) const char * returnType;

/** Sets the return type of the method signature being built by the receiver.
 *
 *  @param  encodedReturnType   The type encoding representing the return type of the method signature being built by the receiver.
 *  @param  returnTypeFlags     A mask of qualifiers for the return type.
 */

- (void)setReturnType: (const char *)encodedReturnType
                flags: (SUMethodParameterFlags)returnTypeFlags;


//---------------------------------------/
/** @name Getting Parameter Information */
//---------------------------------------/


/** The number of parameters which have been defined in the receiver. */

@property ( nonatomic, readonly ) NSUInteger numberOfParameters;

/** Returns the type encoding for the parameter at the given index.
 *
 *  @param  parameterIndex  The index of the parameter to get.
 *
 *  @returns                The type encoding of the parameter at the given index, 
 *                          or NULL if no type has been defined for the given index.
 */

- (const char *)typeOfParameterAtIndex: (NSUInteger)parameterIndex;


//---------------------------------/
/** @name Setting Parameter Types */
//---------------------------------/


/** Sets the type of the method parameter at the given position.
 *
 *  *Warning*:  Structs defined with __attribute__((packed)) and bitfields are not valid types for this method.
 *              Parameters with these data types must be set with an explicit size.
 *
 *  @param  encodedType     The type encoding of the parameter at the given index.
 *                          If NULL, the parameter at the given index will be removed from the method signature, if it exists.
 *  @param  parameterIndex  The position of the parameter within the receiver's selector.
 */

- (void)setType: (const char *)encodedType ofParameterAtIndex: (NSUInteger)parameterIndex;

/** Sets the type of the method parameter at the given position.
 *
 *  *Warning*:  Structs defined with __attribute__((packed)) and bitfields are not valid types for this method.
 *              Parameters with these data types must be set with an explicit size.
 *
 *  @param  encodedType     The type encoding of the parameter at the given index.
 *                          If NULL, the parameter at the given index will be removed from the method signature, if it exists.
 *  @param  flags           A mask of qualifiers for the parameter.
 *  @param  parameterIndex  The position of the parameter within the receiver's selector.
 */

- (void)setType: (const char *)encodedType flags: (SUMethodParameterFlags)parameterFlags ofParameterAtIndex: (NSUInteger)parameterIndex;

/** Sets the type of the method parameter at the given position.
 *
 *  @param  encodedType     The type encoding of the parameter at the given index.
 *                          If NULL, the parameter at the given index will be removed from the method signature, if it exists.
 *  @param  parameterSize   The frame size of the parameter.
 *  @param  parameterIndex  The position of the parameter within the receiver's selector.
 */

- (void)setType: (const char *)encodedType size: (NSUInteger)parameterSize ofParameterAtIndex: (NSUInteger)parameterIndex;

/** Sets the type of the method parameter at the given position.
 *
 *  @param  encodedType     The type encoding of the parameter at the given index.
 *                          If NULL, the parameter at the given index will be removed from the method signature, if it exists.
 *  @param  parameterSize   The frame size of the parameter.
 *  @param  flags           A mask of qualifiers for the parameter.
 *  @param  parameterIndex  The position of the parameter within the receiver's selector.
 */

- (void)setType: (const char *)encodedType size: (NSUInteger)parameterSize flags: (SUMethodParameterFlags)parameterFlags ofParameterAtIndex: (NSUInteger)parameterIndex;


//-----------------------------/
/** @name Removing Parameters */
//-----------------------------/


/** Removes the declared parameter at the given position.
 *
 *  @param  parameterIndex  The position of the parameter within the receiver's selector.
 */

- (void)removeParameterAtIndex: (NSUInteger)parameterIndex;

/** Removes all declared parameters from the receiver's method signature. */

- (void)removeAllParameters;


@end
