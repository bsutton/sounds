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
enum t_CODEC {
  // case `default`
  codec_AAC,
  codec_OPUS,
  codec_CAF_OPUS, // Apple encapsulates its bits in its own special envelope : .caf instead of a regular ogg/opus (.opus). This is completely stupid, this is Apple.
  codec_MP3,
  codec_VORBIS,
  codec_PCM,
}

enum t_SET_CATEGORY_DONE {
  not_SET,
  for_PLAYING, // Sounds did it during startPlayer()
  for_RECORDING, // Sounds did it during startRecorder()
  by_USER, // The caller did it himself : Sounds must not change that)
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
