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

#define CHECK_OSSTATUS_FREE_AND_RETURN( err, freeCmd, retVal ) if( __builtin_expect( noErr != err, 0 ) ) { freeCmd; return retVal; }

#pragma mark -
#pragma mark Reading Audio Date from a file

SUSoundEffectData readAudioDataFromFile ( AudioFileID audioFile ) {
    
    // Verify the audio file
    
    if( NULL == audioFile )
        return NULL;
    
    SUSoundEffectData data = calloc( 1, sizeof( struct _SUSoundEffectData ) );
    
    OSStatus err;


    // ===================
    //
    // 1. Read decoding information
    //
    // ===================


    UInt32 propertySz;
    
    // Audio Data Format
    
    propertySz  = sizeof( data->dataFormat );
    err         = AudioFileGetProperty( audioFile, kAudioFilePropertyDataFormat, &propertySz, &data->dataFormat );
    CHECK_OSSTATUS_FREE_AND_RETURN( err, freeAudioData(data); free( data ), NULL )
    
    // Number of audio bytes
    
    UInt64 byte = 0;
    propertySz  = sizeof( byte );
    err         = AudioFileGetProperty( audioFile, kAudioFilePropertyAudioDataByteCount, &propertySz, &byte );
    CHECK_OSSTATUS_FREE_AND_RETURN( err, freeAudioData(data); free( data ), NULL )

    data->numberOfAudioDataBytes = byte;
    
    // Maximum packet size
    
    propertySz  = sizeof( data->maximumPacketSize );
    err         = AudioFileGetProperty( audioFile, kAudioFilePropertyPacketSizeUpperBound, &propertySz, &data->maximumPacketSize );
    CHECK_OSSTATUS_FREE_AND_RETURN( err, freeAudioData(data); free( data ), NULL )

    // Number of audio packets
    
    UInt64 pkts = 0;
    propertySz  = sizeof( pkts );
    err         = AudioFileGetProperty( audioFile, kAudioFilePropertyAudioDataPacketCount, &propertySz, &pkts );
    CHECK_OSSTATUS_FREE_AND_RETURN( err, freeAudioData(data); free( data ), NULL )

    data->numberOfPackets = pkts;


    // ===================
    //
    // 2. Allocate memory for audio data
    //
    // ===================

    if( ( data->numberOfAudioDataBytes > SIZE_T_MAX ) || ( data->numberOfPackets > SIZE_T_MAX ) )
    {
        // Cannot read file - not enough memory.
        free( data );
        return NULL;
    }

    data->audioData = malloc( (size_t)data->numberOfAudioDataBytes );
    
    // If the audio format is variable bit-rate, we will need packet information,
    // so also allocate packet data
    
    if( 0 == data->dataFormat.mBytesPerPacket )
    {
        data->packetDescriptions = malloc( (size_t)data->numberOfPackets * sizeof( AudioStreamPacketDescription ) );
    }


    // ===================
    //
    // 3. Read audio/packet data
    //
    // ===================


    UInt64 totalBytesRead   = 0;
    UInt64 totalPacketsRead = 0;

    while( ( totalPacketsRead < data->numberOfPackets ) || ( totalBytesRead < data->numberOfAudioDataBytes ) )
    {
        UInt64 numberOfBytesToGo    = ( data->numberOfAudioDataBytes - totalBytesRead );
        UInt32 numberOfBytesToRead  = ( numberOfBytesToGo > UINT32_MAX ) ? UINT32_MAX : (UInt32)numberOfBytesToGo;

        UInt64 numberOfPacketsToGo   = ( data->numberOfPackets - totalPacketsRead );
        UInt32 numberOfPacketsToRead = ( numberOfPacketsToGo > UINT32_MAX ) ? UINT32_MAX : (UInt32)numberOfPacketsToGo;

        err = AudioFileReadPacketData( audioFile,
                                       false,
                                       &numberOfBytesToRead,
                                       data->packetDescriptions,
                                       totalPacketsRead,
                                       &numberOfPacketsToRead,
                                       data->audioData );

        if( noErr != err )
        {
            // Reading failed.
            break;
        }
        else
        {
            totalBytesRead   += numberOfBytesToRead;
            totalPacketsRead += numberOfPacketsToRead;
        }
    }

    // If reading failed, free resources and return NULL.
    
    CHECK_OSSTATUS_FREE_AND_RETURN( err, freeAudioData(data); free( data ), NULL )

    // Return the read audio data.

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
    
    SInt64 audioDataBufferLocation = 0;
    UInt32 audioDataBufferLength   = 0;
    
    if( NULL != audioData->packetDescriptions )
    {
        // Read the packet-data in to the buffer,
        // and use it to calculate the buffer's byte range.
        
        UInt32 numberOfPacketsRead = 0;
        
        while( numberOfPacketsRead < inBuffer->mPacketDescriptionCapacity )
        {
            const UInt64 packetIndex = ( *ioPlaybackPosition + numberOfPacketsRead );

            // Stop buffering if we've already buffered all packets in the audio data
            
            if( packetIndex > audioData->numberOfPackets )
                break;
            
            AudioStreamPacketDescription * sourcePacket      = &( audioData->packetDescriptions[ packetIndex ] );
            AudioStreamPacketDescription * destinationPacket = &( inBuffer->mPacketDescriptions[ numberOfPacketsRead ] );
            
            if( ( audioDataBufferLength + sourcePacket->mDataByteSize ) <= inBuffer->mAudioDataBytesCapacity )
            {
                // The buffer has space for the data in this packet,
                // so copy the packet description in (rebasing the start offset to this buffer rather than the file as a whole).
                
                destinationPacket->mStartOffset             = audioDataBufferLength;
                destinationPacket->mDataByteSize            = sourcePacket->mDataByteSize;
                destinationPacket->mVariableFramesInPacket  = sourcePacket->mVariableFramesInPacket;
                
                // Expand the amount of data to copy to include this packet
                
                audioDataBufferLength += sourcePacket->mDataByteSize;
            }

            // If reading in the first packet, set the buffer's audio data start location to the start offset of the source packet.

            if( 0 == numberOfPacketsRead )
            {
                audioDataBufferLocation = sourcePacket->mStartOffset;
            }

            // Increment number of packets read.

            numberOfPacketsRead++;
        }
        
        inBuffer->mPacketDescriptionCount = numberOfPacketsRead;
    }
    else
    {
        // Calculate this buffer's byte range
        
        const SInt64 remainingBytes = audioData->numberOfAudioDataBytes - *ioPlaybackPosition;
        const UInt32 bytesToRead    = ( inBuffer->mAudioDataBytesCapacity < remainingBytes ) ? inBuffer->mAudioDataBytesCapacity : (UInt32)remainingBytes;

        audioDataBufferLocation = *ioPlaybackPosition;
        audioDataBufferLength   = bytesToRead;
    }
    
    // 3. Copy the audio data in to the buffer

    memcpy( inBuffer->mAudioData, audioData->audioData + audioDataBufferLocation, audioDataBufferLength );
    inBuffer->mAudioDataByteSize = (UInt32)audioDataBufferLength;
    
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

