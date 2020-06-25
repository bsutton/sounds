
import 'package:sounds_common/src/media_format/media_format.dart';
import 'package:sounds_common/src/util/log.dart';

import 'duration_provider.dart';

/// Provides a list of providers that can calculate the duration of an audio file
/// with a specific [MediaFormat].
/// Mulitple providers may be registered for a given [MediaFormat] in which case
/// the provider with the 'highest' priority number is selected.
class DurationProviders {
  static final _self = DurationProviders._internal();

  factory DurationProviders() => _self;

  DurationProviders._internal();

  /// Map of providers keyed by  [MediaFormat.name].
  var providers = <String, DurationProvider>{};

  void registerProvider(DurationProvider provider) {
    var existing = providers[provider.mediaFormat.name];

    if (existing != null) {
      if (provider.priority > existing.priority) {
        // new provider is a higher priority so replace the old one.
        providers.remove(existing);
        providers[provider.mediaFormat.name] = provider;
        Log.w(
            'DurationProvider ${provider.mediaFormat.name} from ${provider.package} replaced '
            ' provider from ${existing.package} as it has a higher.');
      } else {
        Log.w(
            'DurationProvider ${provider.mediaFormat.name} from ${provider.package} ignored '
            ' as an provider from ${existing.package} has a higher or equal priority.');
      }
    } else {
      providers[provider.mediaFormat.name] = provider;
    }
  }

  DurationProvider getProvider(MediaFormat mediaFormat) {
    return providers[mediaFormat.name];
  }
}
