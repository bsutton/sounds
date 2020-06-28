import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:sounds_common/sounds_common.dart';

import 'adts_aac_media_format.dart';
import 'cap_opus_media_format.dart';
import 'mp3_media_format.dart';
import 'native_duration_provider.dart';
import 'ogg_opus_media_format.dart';
import 'ogg_vorbis_media_format.dart';
import 'pcm_media_format.dart';

/// Provides a means to determine the list of natively supported MediaFormats
/// on the current OS and sdk verison.
class NativeMediaFormats implements MediaProvider {
  static final _self = NativeMediaFormats._internal();

  /// Factory constructors
  factory NativeMediaFormats() => _self;

  NativeMediaFormats._internal() {
    _register();
  }

  /// The set of decoders we support on this OS/SDK version
  /// for playback.
  @override
  Future<List<MediaFormat>> get decoders async {
    var supported = <MediaFormat>[];

    /// common formats
    supported.add(AdtsAacMediaFormat());
    supported.add(MP3MediaFormat());
    supported.add(PCMMediaFormat());

    if (Platform.isIOS) {
      // ios specific formats
      supported.add(CafOpusMediaFormat());
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
    supported.add(AdtsAacMediaFormat());

    if (Platform.isIOS) {
      // ios specific formats
      supported.add(CafOpusMediaFormat());
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

  /// list of known [MediaFormats]. Thes formats may not be natively
  /// supported on every platform.
  ///
  /// To determine if a [MediaFormat] is natively supported on your
  /// OS/SDK version call [MediaFormat.isNativeEncoder] or
  /// [MediaFormat.isNativeDecoder].
  ///
  /// Use [encoders] and [decoders] to get a list of natively
  /// supported [MediaFormats].
  List<MediaFormat> get mediaFormats => _mediaFormats;

  static List<MediaFormat> get _mediaFormats => [
        AdtsAacMediaFormat(),
        CafOpusMediaFormat(),
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

  /// This method registers the set of native media formats
  /// to the [MediaFormatManager].
  ///
  /// This method also registered the [NativeDurationProvider].
  void _register() {
    /// add the set of native codecs.
    for (var mediaFormat in _mediaFormats) {
      MediaFormatManager().register(mediaFormat);
    }
  }
}
