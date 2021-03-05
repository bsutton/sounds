# MediaFormat

## Overview

The `MediaFormat` class allows you to select the Codec and Container when recording and when doing audio conversions.

Both Android and iOS are able to automatically detect the format of an audio file when doing playback. You simply have make certain that your audio file is encoded using one of the supported MediaFormats.

If you need to do audio conversions the [sounds\_codec](https://github.com/bsutton/sounds_codec) project \(a work in progress\) is intended to provide conversions between MediaFormats.

The `NativeMediaFormat` serves as a base class for each of the well know MediaFormats which includes:

* AdtsAacMediaFormat
* CafOpusMediaFormat
* MP3MediaFormat
* OggOpusMediaFormat
* OggVorbisMediaFormat
* PCMMediaFormat

Before attempting to user a native `MediaFormat` you need to check that it is supported on the current OS/SDK version.

You can do this by calling the `isNativeEncoder` \(for recording\) and `isNativeDecoder` \(for playback\).

The media format `AdtsAacMediaFormat` is the safest as it is supported on both `iOS` and `Android` going back to fairly early versions of both OSs.

Sounds defines a set of WellKnowMediaFormats which collectively make up the full set of MediaFormats which are currently supported by at least one of the platforms.

### MediaFormat compatibility

The following codecs are supported by sounds:

|  | ADTS/AAC | Ogg/Opus | Caf/Opus | MP3 | OGG/Vorbis | PCM |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| iOS recording | Yes | Yes | Yes | No | No | Yes |
| iOS playback | Yes | Yes | Yes | Yes | No | Yes |
| Android recording | Yes | No | No | No | No | No |
| Android playback | Yes | Yes | No | Yes | Yes | Yes |

Note: what `MediaFormat` is actually supported on the running OS is often SDK dependent. Use MediaFormat.isNativeEncoder and MediaFormat.isNativeDecoder to confirm support.

This table will be updated as MediaFormats are added.



