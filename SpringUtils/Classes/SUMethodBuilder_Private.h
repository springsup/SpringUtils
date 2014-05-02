//
//  SUMethodBuilder_Private.h
//  SpringUtils
//
//  (c) 2014-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "SUMethodBuilder.h"

@interface SUMethodBuilder ()
{
    @package
    BOOL impCreatedWithBlock; // If YES, the IMP is backed by a block (which must be released).
    BOOL impHasBeenConsumed;  // If YES, the block-backed IMP will be released by somebody else.

    @private
    NSUInteger _numberOfArgumentsInSelector;
}
@end
