import 'dart:io';

import 'package:device_info/device_info.dart';

import 'package:sounds_common/sounds_common.dart';

import 'aac_adts_media_format.dart';
import 'mp3_media_format.dart';
import 'opus_caf_media_format.dart';
import 'opus_ogg_media_format.dart';
import 'pcm_media_format.dart';
import 'vorbis_ogg_media_format.dart';

/// Provides a means to determine the list of natively supported MediaFormats
/// on the current OS and sdk verison.
class NativeMediaFormats implements MediaProvider {
  static final _self = NativeMediaFormats._internal();

  /// Factory constructors
  factory NativeMediaFormats() => _self;

  NativeMediaFormats._internal();

  /// The set of decoders we support on this OS/SDK version
  /// for playback.
  @override
  Future<List<MediaFormat>> get decoders async {
    var supported = <MediaFormat>[];

    /// common formats
    supported.add(AACADTSMediaFormat());
    supported.add(MP3MediaFormat());
    supported.add(PCMMediaFormat());

    if (Platform.isIOS) {
      // ios specific formats
      supported.add(OpusCafMediaFormat());
    } else {
      // android
      var deviceInfo = DeviceInfoPlugin();
      var androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 23) {
        supported.add(OpusOggMediaFormat());
        supported.add(VorbisOggMediaFormat());
      }
    }
    return supported;
  }

  /// The set of encoders we support on this OS/SDK version
  /// for recording.
  @override
  Future<List<MediaFormat>> get encoders async {
    var supported = <MediaFormat>[];

    /// common formats
    supported.add(AACADTSMediaFormat());

    if (Platform.isIOS) {
      // ios specific formats
      supported.add(OpusCafMediaFormat());
      supported.add(PCMMediaFormat());
    } else {
      // android
      var deviceInfo = DeviceInfoPlugin();
      var androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 23) {
        supported.add(OpusOggMediaFormat());
        supported.add(VorbisOggMediaFormat());
      }
    }
    return supported;
  }

  /// list of known [MediaFormats]. Thes formats may not be natively supported on every platform.
  /// Use [encoders] and [decoders] to get a list of natively supported [MediaFormats].
  List<MediaFormat> get mediaFormats => [
        AACADTSMediaFormat(),
        OpusCafMediaFormat(),
        PCMMediaFormat(),
        OpusOggMediaFormat(),
        VorbisOggMediaFormat(),
        MP3MediaFormat(),
        PCMMediaFormat()
      ];

  /// Returns true if the [mediaFormat] is natively supported
  /// on the current OS and SDK version.
  Future<bool> isNativeDecoder(MediaFormat mediaFormat) async {
    for (var native in await decoders) {
      if (mediaFormat.name == native.name) {
        return true;
      }
    }
    return false;
  }

  /// Returns true if the [mediaFormat] is natively supported
  /// on the current OS and SDK version.
  Future<bool> isNativeEncoder(MediaFormat mediaFormat) async {
    for (var native in await encoders) {
      if (mediaFormat.name == native.name) {
        return true;
      }
    }
    return false;
  }
}
