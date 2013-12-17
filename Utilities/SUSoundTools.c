//
//  SUSoundTools.c
//  SpringUtils
//
//  (c) 2013-present, SpringsUp
//
//  Licensed under the SpringUtils license, which may be obtained from:
//  https://raw.github.com/springsup/SpringUtils/master/LICENSE
//

#import "SUSoundTools.h"

#define CHECK_ERROR_AND_FREE_RETURN( err, freeCmd, retVal ) if( noErr != err ) { freeCmd; return retVal; }

SUSoundEffectData readAudioDataFromFile ( AudioFileID audioFile ) {
    
    // Verify the audio file
    
    if( NULL == audioFile )
        return NULL;
    
    SUSoundEffectData data = calloc( 1, sizeof( struct _SUSoundEffectData ) );
    
    OSStatus err;
    
    // ===================
    
    // 1. Read decoding information
    
    // ===================
    
    UInt32 propertySz;
    
    // Audio Data Format
    
    propertySz  = sizeof( data->dataFormat );
    err         = AudioFileGetProperty( audioFile, kAudioFilePropertyDataFormat, &propertySz, &data->dataFormat );
    CHECK_ERROR_AND_FREE_RETURN( err, freeAudioData(data), NULL )
    
    // Number of audio bytes
    
    UInt64 byte = 0;
    propertySz  = sizeof( byte );
    err         = AudioFileGetProperty( audioFile, kAudioFilePropertyAudioDataByteCount, &propertySz, &byte );
    CHECK_ERROR_AND_FREE_RETURN( err, freeAudioData(data), NULL )
    
    data->numberOfAudioDataBytes = byte;
    
    // Maximum packet size
    
    propertySz  = sizeof( data->maximumPacketSize );
    err         = AudioFileGetProperty( audioFile, kAudioFilePropertyPacketSizeUpperBound, &propertySz, &data->maximumPacketSize );
    CHECK_ERROR_AND_FREE_RETURN( err, freeAudioData(data), NULL )
    
    // Number of audio packets
    
    UInt64 pkts = 0;
    propertySz  = sizeof( pkts );
    err         = AudioFileGetProperty( audioFile, kAudioFilePropertyAudioDataPacketCount, &propertySz, &pkts );
    CHECK_ERROR_AND_FREE_RETURN( err, freeAudioData(data), NULL )
    
    data->numberOfPackets = pkts;
    
    // ===================
    
    // 2. Allocate memory for audio data
    
    // ===================
    
    data->audioData = malloc( data->numberOfAudioDataBytes );
    
    // If the audio format is variable bit-rate, we will need packet information,
    // so also allocate packet data
    
    if( 0 == data->dataFormat.mBytesPerPacket )
    {
        data->packetDescriptions = malloc( data->numberOfPackets * sizeof( AudioStreamPacketDescription ) );
    }
    
    // ===================
    
    // 3. Read audio/packet data
    
    // ===================
    
    err = AudioFileReadPacketData( audioFile,
                                   false,
                                   &data->numberOfAudioDataBytes,
                                   data->packetDescriptions,
                                   0,
                                   &data->numberOfPackets,
                                   data->audioData );
    
    CHECK_ERROR_AND_FREE_RETURN( err, freeAudioData(data), NULL )
    
    return data;
}

void freeAudioData ( SUSoundEffectData audioData ) {
    
    if( NULL != audioData )
    {
        if( NULL != audioData->audioData )
        {
            free( audioData->audioData );
        }
        
        if( NULL != audioData->packetDescriptions )
        {
            free( audioData->packetDescriptions );
        }
        
        free( audioData );
    }
}

#pragma mark -
#pragma mark Filling AudioQueue Buffers

OSStatus fillBufferFromAudioFile( AudioQueueBufferRef inBuffer,
                                  AudioFileID audioFile,
                                  SInt64 * ioPlaybackPosition ) {
    
    OSStatus err;
    
    // 1. Read the audio data
    
    inBuffer->mAudioDataByteSize      = inBuffer->mAudioDataBytesCapacity;
    inBuffer->mPacketDescriptionCount = inBuffer->mPacketDescriptionCapacity;
    
    if( inBuffer->mPacketDescriptionCapacity > 0 )
    {
        err = AudioFileReadPacketData( audioFile,
                                       true,
                                       &( inBuffer->mAudioDataByteSize ),
                                       inBuffer->mPacketDescriptions,
                                       *ioPlaybackPosition,
                                       &( inBuffer->mPacketDescriptionCount ),
                                       inBuffer->mAudioData );
    }
    else
    {
        err = AudioFileReadBytes( audioFile,
                                  true,
                                  *ioPlaybackPosition,
                                  &( inBuffer->mAudioDataByteSize ),
                                  inBuffer->mAudioData );
    }
    
    // 2. Advance the playback cursor
    
    if( inBuffer->mPacketDescriptionCapacity > 0 )
    {
        *ioPlaybackPosition += inBuffer->mPacketDescriptionCount;
    }
    else
    {
        *ioPlaybackPosition += inBuffer->mAudioDataByteSize;
    }
    
    return err;
}

OSStatus fillBufferFromAudioData( AudioQueueBufferRef inBuffer,
                                  SUSoundEffectData audioData,
                                  SInt64 * ioPlaybackPosition ) {
    
    // 1. Reset the buffer
    
    inBuffer->mAudioDataByteSize      = 0;
    inBuffer->mPacketDescriptionCount = 0;
    
    // 2. Calculate the byte range to fill the buffer with
    
    CFRange audioDataBufferRange = CFRangeMake( 0, 0 );
    
    if( NULL != audioData->packetDescriptions )
    {
        // Read the packet-data in to the buffer,
        // and use it to calculate the buffer's byte range.
        
        UInt32 numberOfPacketsRead = 0;
        
        while( numberOfPacketsRead < inBuffer->mPacketDescriptionCapacity )
        {
            const UInt32 packetIndex = ( *ioPlaybackPosition + numberOfPacketsRead );

            // Stop buffering if we've already buffered all packets in the audio data
            
            if( packetIndex > audioData->numberOfPackets )
                break;
            
            AudioStreamPacketDescription * sourcePacket      = &( audioData->packetDescriptions[ packetIndex ] );
            AudioStreamPacketDescription * destinationPacket = &( inBuffer->mPacketDescriptions[ numberOfPacketsRead ] );
            
            if( ( audioDataBufferRange.length + sourcePacket->mDataByteSize ) <= inBuffer->mAudioDataBytesCapacity )
            {
                // The buffer has space for the data in this packet,
                // so copy the packet description in (rebasing the start offset).
                
                destinationPacket->mStartOffset             = audioDataBufferRange.length;
                destinationPacket->mDataByteSize            = sourcePacket->mDataByteSize;
                destinationPacket->mVariableFramesInPacket  = sourcePacket->mVariableFramesInPacket;
                
                // Expand the amount of data to copy to include this packet
                
                audioDataBufferRange.length += sourcePacket->mDataByteSize;
            }
            
            if( 0 == numberOfPacketsRead )
            {
                audioDataBufferRange.location = sourcePacket->mStartOffset;
            }
            
            numberOfPacketsRead++;
        }
        
        inBuffer->mPacketDescriptionCount = numberOfPacketsRead;
    }
    else
    {
        // Calculate this buffer's byte range
        
        const CFIndex remainingBytes = audioData->numberOfAudioDataBytes - *ioPlaybackPosition;
        const CFIndex bytesToRead    = ( inBuffer->mAudioDataBytesCapacity < remainingBytes ) ? inBuffer->mAudioDataBytesCapacity : remainingBytes;
        
        audioDataBufferRange         = CFRangeMake( *ioPlaybackPosition, bytesToRead );
    }
    
    // 3. Copy the audio data in to the buffer
    
    memcpy( inBuffer->mAudioData, audioData->audioData + audioDataBufferRange.location, audioDataBufferRange.length );
    inBuffer->mAudioDataByteSize = audioDataBufferRange.length;
    
    // 4. Advance the playback cursor,
    //    Set the error to kAudioFileEndOfFileError if the playback cursor has reached the end of the data
    
    OSStatus err = noErr;
    
    if( inBuffer->mPacketDescriptionCapacity > 0 )
    {
        *ioPlaybackPosition += inBuffer->mPacketDescriptionCount;
        
        if( *ioPlaybackPosition >= audioData->numberOfPackets )
        {
            err = kAudioFileEndOfFileError;
        }
    }
    else
    {
        *ioPlaybackPosition += inBuffer->mAudioDataByteSize;
        
        if( *ioPlaybackPosition >= audioData->numberOfAudioDataBytes )
        {
            err = kAudioFileEndOfFileError;
        }
    }
    
    return err;
}

