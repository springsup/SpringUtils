//
//  SUSoundTools.h
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import <AudioToolbox/AudioToolbox.h>

typedef struct _SUSoundEffectData {
    
    AudioStreamBasicDescription dataFormat; /**< Audio data format description. */

    void * audioData;                       /**< Audio data bytes. */
    UInt32 numberOfAudioDataBytes;          /**< The length of audio data. */

    AudioStreamPacketDescription * packetDescriptions;  /**< Audio packet descriptions. NULL if the data format is CBR. */
    UInt32 numberOfPackets;                             /**< The number of audio packet descriptions. */
    UInt32 maximumPacketSize;                           /**< The maximum size (in bytes) of data represented by a single packet description. */
    
} *SUSoundEffectData;


/** @name   Reading audio data from a file. */


/** Reads the audio bytes and packet descriptions of the given file in to memory.
 *
 *  @param  audioFile   The file to read.
 *
 *  @returns            An SUSoundEffectData containing the audio data, or NULL if the file couldn't be read.
 *                      You must release this value by calling freeAudioData().
 */

SUSoundEffectData readAudioDataFromFile( AudioFileID audioFile );

/** Releases an SUSoundEffectData instance and its associated memory buffers.
 *
 *  @param  audioData   The SUSoundEffectData instance to release. After calling this function,
 *                      you should no longer use the SUSoundEffect instance.
 */

void freeAudioData( SUSoundEffectData audioData );


/** @name Filling AudioQueue Buffers */


/** Fills an AudioQueue buffer with data from the given audio file.
 *
 *  @param  inBuffer            The buffer to fill with audio data.
 *  @param  audioFile           The audio file to read data from.
 *  @param  ioPlaybackPosition  On input, the cursor position to fill from. On output, the new cursor position.
 *
 *  @returns                    A result code. See AudioFile Services documentation for values. The result code is
 *                              equal to kAudioFileEndOfFileError once the playback position has reached the end of the file.
 */

OSStatus fillBufferFromAudioFile( AudioQueueBufferRef inBuffer, AudioFileID audioFile, SInt64 * ioPlaybackPosition );

/** Fills an AudioQueue buffer with sound data.
 *
 *  @param  inBuffer            The buffer to fill with audio data.
 *  @param  audioData           The audio data to fill the buffer from.
 *  @param  ioPlaybackPosition  On input, the cursor position to fill from. On output, the new cursor position.
 *
 *  @returns                    A result code, which is equal to kAudioFileEndOfFileError once the playback position has
 *                              reached the end of the given data.
 */

OSStatus fillBufferFromAudioData( AudioQueueBufferRef inBuffer, SUSoundEffectData audioData, SInt64 * ioPlaybackPosition );

