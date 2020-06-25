import 'media_format.dart';

abstract class DurationProvider {
  /// The name of the package that is providing the DurationProvider.
  /// This value is only used for logging warnings/errors.
  String package;

  /// The priority of this provider compared to other providers for the
  /// same [MediaFormat].
  /// The provider with the highest [priority] no. will be used to determine
  /// the duration.
  /// Native providers have a priority of 100.
  /// Other prioviders should normally have a lower priority unless you think
  /// your provider can calculate the duration faster than the native OS can.
  int priority;

  /// The [MediaFormat] this provider calculates the duration for.
  MediaFormat mediaFormat;

  /// Calculates the duration of the an audio file located at [path].
  /// The audio file at [path] must have a [MediaFormat] which matches providers [mediaFormat].
  ///
  Future<Duration> getDuration(String path);
}
