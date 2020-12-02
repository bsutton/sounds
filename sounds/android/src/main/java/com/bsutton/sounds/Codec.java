package com.bsutton.sounds;

// this enum MUST be synchronized with lib/sounds.dart and ios/Classes/SoundsPlugin.h
public enum Codec {
    DEFAULT, AAC, OPUS, CODEC_CAF_OPUS // Apple encapsulates its bits in its own special envelope : .caf instead of a
    // regular ogg/opus (.opus). This is completely stupid, this is Apple.
    , MP3, VORBIS, PCM
}

