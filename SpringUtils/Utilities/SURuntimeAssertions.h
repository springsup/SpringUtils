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

/**@name Generic Assertions */

/** Throws an exception with a given reason message if the condition is false. */

#define SU_ASSERT_MSG( condition, message... )           \
    do{                                                  \
        if( __builtin_expect( NO == ( condition ), 0 ) ) \
            _SU_THROW_WITH_REASON( message )             \
    }while(0);

/** Throws an exception with a given reason message if the condition is true. */

#define SU_ASSERT_FALSE_MSG( condition, message... )    \
    do{                                                 \
        if( __builtin_expect( condition, 0 ) )          \
            _SU_THROW_WITH_REASON( message )            \
    }while(0);

/** Throws an exception if the condition is false. */

#define SU_ASSERT( condition ) \
    SU_ASSERT_MSG( condition, @"%@ is false", @#condition )

/** Throws an exception if the condition is true. */

#define SU_ASSERT_FALSE( condition ) \
    SU_ASSERT_FALSE_MSG( condition, @"%@ is true", @#condition )



/**@name Equality Assertions */



/** Throws an exception with a given reason message if the object's isEqual: method returns YES when provided with invalid object value. */

#define SU_ASSERT_NOT_EQUAL_OBJ_MSG( object, invalidObjectValue, message... )   \
    SU_ASSERT_FALSE_MSG( [object isEqual: invalidObjectValue], message )

/** Throws an exception if the object's isEqual: method returns YES when provided with invalid object value. */

#define SU_ASSERT_NOT_EQUAL_OBJ( object, invalidObjectValue )   \
    SU_ASSERT_NOT_EQUAL_OBJ_MSG( @"%@ may not be equal to %@", @#object, invalidObjectValue )

/** Throws an exception with a given reason message if the parameter is equal (in a primitive sense) to the invalid value. */

#define SU_ASSERT_NOT_EQUAL_MSG( parameter, invalidValue, message... )  \
    SU_ASSERT_MSG( parameter != invalidValue, message )

/** Throws an exception if the parameter is equal (in a primitive sense) to the invalid value. */

#define SU_ASSERT_NOT_EQUAL( parameter, invalidValue )  \
    SU_ASSERT_NOT_EQUAL_MSG( parameter, invalidValue, @"%@ may not be %@", @#parameter, @#invalidValue )



/** @name Greater/Less Comparisons */



/** Throws an exception with a given reason message if the parameter is not less than the given value. */

#define SU_ASSERT_LESS_THAN_MSG( parameter, invalidValue, message... )  \
    SU_ASSERT_MSG( parameter < invalidValue, message )

/** Throws an exception if the parameter is not less than the given value. */

#define SU_ASSERT_LESS_THAN( parameter, invalidValue )  \
    SU_ASSERT_LESS_THAN_MSG( parameter, invalidValue, @"%@ must be less than %@", @#parameter, @#invalidValue )

/** Throws an exception with a given reason message if the parameter is not greater than the given value. */

#define SU_ASSERT_GREATER_THAN_MSG( parameter, invalidValue, message... )   \
    SU_ASSERT_MSG( parameter > invalidValue, message )

/** Throws an exception if the parameter is not greater than the given value. */

#define SU_ASSERT_GREATER_THAN( parameter, invalidValue )  \
    SU_ASSERT_GREATER_THAN_MSG( parameter, invalidValue, @"%@ must be greater than %@", @#parameter, @#invalidValue )

/** Throws an exception with a given reason message if the parameter is less than the given value. */

#define SU_ASSERT_GREATER_THAN_OR_EQUAL_MSG( parameter, minimumValue, message... )  \
    SU_ASSERT_MSG( parameter >= minimumValue, message )

/** Throws an exception if the parameter is less than the given value. */

#define SU_ASSERT_GREATER_THAN_OR_EQUAL( parameter, minimumValue )  \
    SU_ASSERT_GREATER_THAN_OR_EQUAL_MSG( parameter, minimumValue, @"%@ cannot be less than %@", @#parameter, @#minimumValue )


/** @name Special Assertions */


/** Throws an exception if the given object is Nil. */

#define SU_ASSERT_NOT_NIL( parameter ) \
        SU_ASSERT_NOT_EQUAL( parameter, Nil )

/** Throws an exception if the given NSString instance is Nil or empty. */

#define SU_ASSERT_NSSTRING( parameter )         \
        SU_ASSERT_NOT_EQUAL( parameter, Nil )   \
        SU_ASSERT_NOT_EQUAL_MSG( parameter.length, 0, @"%@ may not be empty", @#parameter )

#endif
