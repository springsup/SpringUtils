//
//  SURuntimeAssertions.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#ifndef Sterling_SURuntimeAssertions_h
#define Sterling_SURuntimeAssertions_h

#import <Foundation/Foundation.h>

// Defines runtime assertion macros which will raise an NSInvalidArgumentException



#define _SU_THROW_WITH_REASON( ... )                                            \
    [[NSException exceptionWithName: NSInvalidArgumentException                 \
                             reason: [NSString stringWithFormat: __VA_ARGS__]   \
                           userInfo: Nil] raise];

/** Throws an exception with a given reason message if the object's isEqual: method returns YES when provided with invalid object value. */

#define SU_ASSERT_NOT_EQUAL_OBJ_MSG( object, invalidObjectValue, message... )   \
    do {                                                                        \
        if( [object isEqual: invalidObjectValue] )                              \
            _SU_THROW_WITH_REASON( message )                                    \
    }while(0);

/** Throws an exception if the object's isEqual: method returns YES when provided with invalid object value. */

#define SU_ASSERT_NOT_EQUAL_OBJ( object, invalidObjectValue )   \
    SU_ASSERT_NOT_EQUAL_OBJ_MSG( @"%@ may not be equal to %@", @#object, invalidObjectValue )


/** Throws an exception with a given reason message if the parameter is equal (in a primitive sense) to the invalid value. */

#define SU_ASSERT_NOT_EQUAL_MSG( parameter, invalidValue, message... )  \
    do {                                                                \
        if( parameter == invalidValue )                                 \
            _SU_THROW_WITH_REASON( message )                            \
    }while(0);

/** Throws an exception if the parameter is equal (in a primitive sense) to the invalid value. */

#define SU_ASSERT_NOT_EQUAL( parameter, invalidValue )  \
    SU_ASSERT_NOT_EQUAL_MSG( parameter, invalidValue, @"%@ may not be %@", @#parameter, @#invalidValue )


/** Throws an exception with a given reason message if the parameter is not less than the given value. */

#define SU_ASSERT_LESS_THAN_MSG( parameter, invalidValue, message... )  \
    do{                                                                 \
        if( parameter >= invalidValue )                                 \
            _SU_THROW_WITH_REASON( message )                            \
    }while(0);

/** Throws an exception if the parameter is not less than the given value. */

#define SU_ASSERT_LESS_THAN( parameter, invalidValue )  \
    SU_ASSERT_LESS_THAN_MSG( @"%@ must be less than %@", @#parameter, @#invalidValue )

/** Throws an exception if the given NSString instance is Nil or empty. */

#define SU_ASSERT_NSSTRING( parameter )                                     \
    do{                                                                     \
        SU_ASSERT_NOT_EQUAL( parameter, Nil );                              \
        if( 0 == parameter.length )                                         \
            _SU_THROW_WITH_REASON( @"%@ may not be empty", @#parameter )    \
    }while(0);

#endif
