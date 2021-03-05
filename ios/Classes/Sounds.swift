//  Converted to Swift 5.2 by Swiftify v5.2.19227 - https://swiftify.com/
//
//  Sound.h
//  Pods
//
//  Created by larpoux on 24/03/2020.
//
//
//  Sounds.swift
//  flauto
//
//  Created by larpoux on 24/03/2020.
//
import AVFoundation
import Flutter
import Foundation

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


// this enum MUST be synchronized with lib/sounds.dart and sounds/AudioInterface.java
enum t_CODEC : Int {
    case `default`
    case codec_AAC
    case codec_OPUS
    case codec_CAF_OPUS // Apple encapsulates its bits in its own special envelope : .caf instead of a regular ogg/opus (.opus). This is completely stupid, this is Apple.
    case codec_MP3
    case codec_VORBIS
    case codec_PCM
}

enum t_SET_CATEGORY_DONE : Int {
    case not_SET
    case for_PLAYING // Sounds did it during startPlayer()
    case for_RECORDING // Sounds did it during startRecorder()
    case by_USER // The caller did it himself : Sounds must not change that)
}

class Sounds: NSObject, FlutterPlugin, AVAudioPlayerDelegate {
    class func register(with registrar: (NSObjectProtocol & FlutterPluginRegistrar)) {
        SoundPlayerReg(registrar)
        SoundRecorderReg(registrar)
        ShadePlayerReg(registrar)
    }
}

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
