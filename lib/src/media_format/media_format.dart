import 'package:meta/meta.dart';

import 'duration_providers.dart';

abstract class MediaFormat {
  /// The [name] of the [MediaFormat].
  /// The [name] MUST be of the form container/codec (not all lower case)
  /// e.g.
  /// ogg/vorbis
  ///
  /// The [name] is used to compare [MediaFormats]
  ///
  /// For MediaFormats that don't have a container (e.g PCM) then
  /// the name should just be the codec
  /// e.g.
  /// pcm
  final String name;
  final int sampleRate;
  final int numChannels;
  final int bitRate;

  const MediaFormat.detail({
    @required this.name,
    this.sampleRate = 16000,
    this.numChannels = 1,
    this.bitRate = 16000,
  });

  /// Returns the commonly used file extension for this MediaFormat
  /// e.g. 'mp3'
  String get extension;

  /// Returns the duration of the audio file at the given [path].
  /// The audio file at the given path MUST be the of the same
  /// [MediaFormat] otherwise the result is undefined.
  Future<Duration> getDuration(String path) {
    return DurationProviders().getProvider(this).getDuration(path);
  }

  /// Only [MediaFormat]s that natively supported decoding (playback) by the current platform should return
  /// true.
  Future<bool> get isNativeDecoder;

  /// Only [MediaFormats] that natively supported encoding (recording) by the current platform should return
  /// true.
  Future<bool> get isNativeEncoder;

  @override
  bool operator ==(covariant MediaFormat other) {
    return (name == other.name &&
        sampleRate == other.sampleRate &&
        numChannels == other.numChannels &&
        bitRate == other.bitRate);
  }
}
