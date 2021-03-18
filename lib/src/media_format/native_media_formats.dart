import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:sounds_common/sounds_common.dart';

import 'adts_aac_media_format.dart';
import 'cap_opus_media_format.dart';
import 'mp3_media_format.dart';
import 'native_duration_provider.dart';
import 'native_media_format.dart';
import 'ogg_opus_media_format.dart';
import 'ogg_vorbis_media_format.dart';
import 'pcm_media_format.dart';

/// Provides a means to determine the list of natively supported MediaFormats
/// on the current OS and sdk verison.
///
/// Android:
/// For the list of supported encoders/decoders:
/// https://developer.android.com/guide/topics/media/media-formats
///
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
  Future<List<NativeMediaFormat>> get decoders async {
    final supported = <NativeMediaFormat>[];

    /// common formats
    supported.add(const AdtsAacMediaFormat());
    supported.add(MP3MediaFormat());
    supported.add(const PCMMediaFormat());

    if (Platform.isIOS) {
      // ios specific formats
      supported.add(const CafOpusMediaFormat());
    } else {
      // android
      supported.add(OggVorbisMediaFormat());

      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 21) {
        supported.add(const OggOpusMediaFormat());
      }
    }
    return supported;
  }

  /// The set of encoders we support on this OS/SDK version
  /// for recording.
  @override
  Future<List<NativeMediaFormat>> get encoders async {
    final supported = <NativeMediaFormat>[];

    /// common formats
    supported.add(const AdtsAacMediaFormat());

    if (Platform.isIOS) {
      // ios specific formats
      supported.add(const CafOpusMediaFormat());
      supported.add(const PCMMediaFormat());
    } else {
      // android
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 29) {
        supported.add(const OggOpusMediaFormat());
        supported.add(OggVorbisMediaFormat());
      }
    }
    return supported;
  }

  /// list of known [MediaFormat]s. Thes formats may not be natively
  /// supported on every platform.
  ///
  /// To determine if a [MediaFormat] is natively supported on your
  /// OS/SDK version call [MediaFormat.isNativeEncoder] or
  /// [MediaFormat.isNativeDecoder].
  ///
  /// Use [encoders] and [decoders] to get a list of natively
  /// supported [MediaFormat]s.
  List<MediaFormat> get mediaFormats => _mediaFormats;

  static List<MediaFormat> get _mediaFormats => [
        const AdtsAacMediaFormat(),
        const CafOpusMediaFormat(),
        const PCMMediaFormat(),
        const OggOpusMediaFormat(),
        OggVorbisMediaFormat(),
        MP3MediaFormat(),
        const PCMMediaFormat()
      ];

  /// Returns true if the [mediaFormat] is natively supported
  /// on the current OS and SDK version.
  Future<bool> isNativeDecoder(MediaFormat mediaFormat) async {
    for (final native in await decoders) {
      if (mediaFormat.name == native.name) {
        return true;
      }
    }
    return false;
  }

  /// Returns true if the [mediaFormat] is natively supported
  /// on the current OS and SDK version.
  Future<bool> isNativeEncoder(MediaFormat mediaFormat) async {
    for (final native in await encoders) {
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
    for (final mediaFormat in _mediaFormats) {
      MediaFormatManager().register(mediaFormat);
    }
  }
}
