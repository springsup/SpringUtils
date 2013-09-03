SpringUtils
===========

A collection of utility classes, categories and macros for iOS and OSX.

#Macros
##SUAssociatedObjects, SUAssociatedWeakObjects
Provides a set of macros for quickly implementing properties via Objective-C associated objects. Supports implementing strong or auto-zeroing weak references to object types, and also supports implementing scalar type properties.

For usage instructions, refer to the relevant header files.

##SUSystemVersion
Provides a set of macros for checking the version of the operating system at runtime, with definitions for major system versions. iOS only.

#Categories
##NSObject
Categories support:

* Updating keys (when manually invoking KVO)
* KVO observation callback blocks. These methods use tokens which release the observation when the token is deallocated, so keep the token around as long as you want the block to watch the key-path.

##NSSet
Categories support:

* Initialising sets as the intersection of a list of sets
* Initialising sets as the union of a list of sets

##NSDateComponents
Categories support:

* Subscripting using NSCalendarUnit, so you can get and set date component values using subscript syntax.
* Getting and setting values by NSCalendarUnit

#General
##SUComparatorTools
Provides a way to create an NSComparator block from an array of sort descriptors
