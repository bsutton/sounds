//
//  Sound.h
//  Pods
//
//  Created by larpoux on 24/03/2020.
//
/*
 * This file is part of Sounds .
 *
 *   Sounds  is free software: you can redistribute it and/or modify
 *   it under the terms of the Lesser GNU General Public License
 *   version 3 (LGPL3) as published by the Free Software Foundation.
 *
 *   Sounds  is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the Lesser GNU General Public License
 *   along with Sounds .  If not, see <https://www.gnu.org/licenses/>.
 */

#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>
#ifndef Sounds_h
#define Sounds_h


// this enum MUST be synchronized with lib/sounds.dart and sounds/AudioInterface.java
typedef enum
{
        DEFAULT,
        CODEC_AAC,
        CODEC_OPUS,
        CODEC_CAF_OPUS // Apple encapsulates its bits in its own special envelope : .caf instead of a regular ogg/opus (.opus). This is completely stupid, this is Apple.
        ,
        CODEC_MP3,
        CODEC_VORBIS,
        CODEC_PCM
} t_CODEC;

typedef enum
{
        NOT_SET,
        FOR_PLAYING,   // Sounds did it during startPlayer()
        FOR_RECORDING, // Sounds did it during startRecorder()
        BY_USER        // The caller did it himself : Sounds must not change that)
} t_SET_CATEGORY_DONE;



@interface Sounds : NSObject <FlutterPlugin, AVAudioPlayerDelegate>
{
}

@end

#endif /* Sounds_h */
