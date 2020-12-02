# Platform Implementations

The Sounds project currently supports the IOS and Android Platforms.

Sounds aims to provide support on every Flutter supported platform.

More than 95% of the Sounds project code is written in Dart. 

{% hint style="info" %}
The IOS Platform implementation is around 1600 lines of code including comments and blank lines.
{% endhint %}

This means that each Platform implementation is small as it only needs to provide a core set of functions defined by the Sounds Platform API.

To support that aim the Sounds project is moving towards  [Dart's federated plugin model](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#federated-plugins).

The Sounds team is looking for contributes to pick and developed support for each one of the emerging Flutter target platforms including:

* Web
* Linux
* Macos
* Windows

And any other platform as the Flutter team offers support for them.

As the requirements of the Sounds Platform API are fairly simple a single developer should be able to managed each platform.

## Federated plugin model

As noted, Sounds is moving towards  Dart's federated plugin model.

The federated model allow Sounds to defined a Platform API which describes the set of calls that Sounds makes into the Platform and expects back from the Platform.

By implementing the Platform specific code in a separate package, each Platform implementation is small a fairly simple to write and maintain.

The Platform API is defined in a separate package referred to as the Platform Interface Package, for Sounds this package is called the \`sounds\_platform\_interface\`.

Within the sounds\_platform\_interface  the Dart library `sounds_platform_api.dart` defines the api.

The federated model allows third party developers to contribute a Platform specific implementation of the Sounds platform API independent of the main Sounds project.

## Pigeon

The [Pigeon](https://pub.dev/packages/pigeon) project is a new Dart project for building Platform APIs that work with the Federated plugin model.

The Pigeon project allows Sounds to define the Sounds Platform API in Dart and then have Pigeon generate the Platform specific communications layer. 

The main Sounds project includes a `pigeon` directory that contains the `sounds_platform_api.dart` library which defines the Sounds Platform API. 

Sounds uses the Dcli script pigeon/pigeon\_gen.dart to generate the platform specific code. 

Currently Pigeon supports Android and IOS but we expect to see support for each of the Flutter supported Platforms as the Pigeon project matures.

## Draft API

The following is a draft copy of the Platform API. The definitive version can be found in sounds\_platform\_interface project.

```dart
/// Defines the platform agnostic interface for calls from and to
/// flutter and the  underlying platform code.
///
import 'package:pigeon/pigeon.dart';

/// Defines the set of methods that the platform can used
/// to call into the dart code.
///

class SoundPlayerProxy {
  String uuid;

  SoundPlayerProxy(String uuid);
}

class SoundRecorderProxy {
  String uuid;

  SoundRecorderProxy(this.uuid);
}

class TrackProxy {
  final String uuid;

  TrackProxy(this.uuid);
}

class AudioFocusProxy {
  int audioFocusMode;
}

class Response {
  bool success;
  int errorCode;
  String error;
}

class DurationResponse extends Response {
  /// the duration of the track in milliseconds.
  int duration;
}

class BoolResponse extends Response {
  /// Used to indicate a true/false response.
  /// This value is separate from the [success] field
  /// in that [success] is used simply to indicate if
  /// the call completed without error.
  bool boolResult;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// HostApi - calls from flutter to the platform.
///
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// The collection of methods we use to call into the platform code.
@HostApi()
abstract class SoundsToPlatformApi {
  /// The list of specific errors that can be passed from the platform to dart.
  static const errnoGeneral = 1;

  /// Indicates that a track contained audio using an unsupported
  /// media format. The error description should contain additional
  /// details which acuratly describes what aspect of the Media Format
  /// was not supported.
  static const errnoUnsupportedMediaFormat = 2;

  /// Indicates that Dart attempted to perform an action on a player
  /// which has either not been initialised or has been released.
  static const errnoUnknownPlayer = 3;

  /// Indicates that Sounds has attempted to start playing or
  /// resume playing audio on a [SoundPlayerProxy] when it's already
  /// playing.
  static const errnoAlreadyPlaying = 4;

  /// Indicates that Sounds attempted to stop playing or pause playing
  /// audio on a [SoundPlayerProxy] when the proxy was not currently playing.
  static const errnoNotPlaying = 5;

  /// Indicates that Sounds attempted to play audio in the background
  /// but the Platform does not support background audio.
  static const errnoBackgroudAudioNotSupported = 6;

  /// Indicates that Sounds attempted to start playing audio
  /// vai the startPlayerWithShade method and the Platform does not
  /// support a shade.
  static const errnoShadeNotSupported = 7;

  /// Each [SoundPlayerProxy] MUST be initialized before
  /// any other calls can be made for the [SoundPlayerProxy].
  ///
  /// Once Sounds has finished with the [SoundPlayerProxy] it will call
  /// [releasePlayer].
  ///
  /// The [playInBackground] flag instructs the Platform to continue playing
  /// the audio even if the app becomes in-active.
  ///
  /// If the Platform does not support playing audio in the background
  /// then the Platform MUST return [errnoBackgroudAudioNotSupported].
  ///
  /// If the app becomes in-active then the app will call [release]
  /// unless the audio is currently playing and [startPlayer] was called
  /// with [playInBackground] = true.
  ///
  /// The platform MUST not return until the platform media player is
  /// fully initialised.
  @async
  Response initializePlayer(
    SoundPlayerProxy player,
    // ignore: avoid_positional_boolean_parameters
    bool playInBackground,
  );

  /// Once Sounds has finished with a [SoundPlayerProxy] it will call
  /// [releasePlayer] indicating that all resources associated with the
  /// player may be released.
  ///
  /// Any attempt by Sounds to reuse a player after [releasePlayer] has been
  /// called MUST result in the error [errnoUnknownPlayer].
  ///
  /// The platform MUST not return until all resources are released.
  @async
  Response releasePlayer(SoundPlayerProxy player);

  /// Instructs the Platform to start playing the [TrackProxy] on
  /// the given [SoundPlayerProxy].
  ///
  /// The Platform MUST only return once the media has successfully
  /// started playing.
  ///
  /// If the [SoundPlayerProxy] is already playing then the Platform
  /// MUST return an [errnoAlreadyPlaying] error.
  ///
  /// If an error occurs after this method returns then the
  /// Platform must stop the audio and the error MUST be
  /// passed back by calling [onStopped] with an appropriate error code.
  ///
  /// If a  [TrackProxy] with an unsupported media format is passed then an
  /// [errnoUnsupportedMediaFormat] error SHOULD be returned.
  ///
  @async
  Response startPlayer(
    SoundPlayerProxy player,
    TrackProxy track,
  );

  /// Instructs the Platform to start playing the [TrackProxy] on
  /// the given [SoundPlayerProxy] and display the [TrackProxy] details
  /// in the OS's shade (notification area).
  ///
  /// If the Platform does not support a shade then [errnoShadeNotSupported]
  /// error MUST be returned.
  ///
  /// The Platform MUST only return once the media has successfully
  /// started playing.
  ///
  /// If the [SoundPlayerProxy] is already playing then the Platform
  /// MUST return an [errnoAlreadyPlaying] error.
  ///
  /// If an error occurs after this method returns then the
  /// Platform must stop the audio and the error MUST be
  /// passed back by calling [onStopped] with an appropriate error code.
  ///
  /// If a  [TrackProxy] with an unsupported media format is passed then an
  /// [errnoUnsupportedMediaFormat] error SHOULD be returned.
  ///

  ///
  /// If [showShade] is true and the Platform chooses to display a shade
  /// then the arguments [canPause], [canSkipForward]
  ///     , [canSkipBackwards] control what buttons the shade may show.
  ///
  /// A Platform MAY choose to ignore button control options.
  /// If any of the options are set to true then the Platform SHOULD do its
  /// best to honour the settings.
  @async
  Response startPlayerWithShade(
      SoundPlayerProxy player,
      TrackProxy track,
      // ignore: avoid_positional_boolean_parameters
      bool canPause,
      bool canSkipForward,
      bool canSkipBackward);

  /// Instructs the Platform to stop the [SoundPlayerProxy] playing.
  ///
  /// The call MUST only return once the audio has stopped playing.
  ///
  /// If the [SoundPlayerProxy] is not currently playing then the Platform
  /// MUST return  [errnoNotPlaying].
  ///
  /// If an error is returned Sounds will assume that the audio has stopped
  /// as such the Platform should take all reasonable stepts to ensure the
  /// audio has stopped.
  ///
  @async
  Response stopPlayer(SoundPlayerProxy player);

  /// Instructs the Platform to pause the [SoundPlayerProxy].
  ///
  /// The Platform MUST not return until the audio has paused.
  ///
  /// If the [SoundPlayerProxy] is not currently playing then the Platform
  /// MUST return  [errnoNotPlaying].
  @async
  Response pausePlayer(SoundPlayerProxy player);

  /// Instructs the Platform to resume the [SoundPlayerProxy].
  ///
  /// The Platform MUST not return until the audio has resumed.
  @async
  Response resumePlayer(SoundPlayerProxy player);

  /// Instructs the Platform to update the current playback position for the
  /// [SoundPlayerProxy] to [milliseconds] from the start of the [TrackProxy]
  /// currently playing.
  ///
  /// If the [SoundPlayerProxy] is not currently playing then the Platform
  /// MUST return a [errnoNotPlaying].
  ///
  ///
  /// from the start.
  ///
  /// It is not valid to attempt to seek if the player is not currently
  /// playing.
  ///
  /// It is expect that we may see race conditions (as pause/seek overlapping)
  /// in which case the platform will return an error if the player
  /// isn't playing. It is up to the dart code to manage these race conditions.
  ///
  /// The call MUST return immediately and the platform must
  /// emit a call to [onSeekCompleted] once the player has actually stopped
  /// playing.
  @async
  Response seekToPlayer(SoundPlayerProxy player, int milliseconds);

  /// Get the duration of an audio file located at [path].
  ///
  /// Depending on the size of the file and the codec this may be a lengthy
  /// operation.
  ///
  /// The platform MUST return immediately  and MUST call
  /// [getDurationCompleted] once the duration is calculated or an error occurs.
  ///
  /// If the Track's codec is not supported then [getDurationCompleted]
  /// must return with [success] = false and an error of the form:
  /// 'The codec $codec is not supported'.
  @async
  DurationResponse getDuration(SoundPlayerProxy player, TrackProxy track);

  ///
  /// Sets the volume between 0 and 100.
  ///
  /// On android this will need to be scaled to a value between 0 and 1.
  @async
  Response setVolume(SoundPlayerProxy player, double volume);

  /// Sets the interval between progress messages being generated from
  /// the platform code when the passed player is playing.
  ///
  /// The [interval] is passed in milliseconds and must be a +ve no.
  ///
  /// If this method hasn't been called then the default interval is 100ms.
  ///
  /// If this method is called with an [interval] of 0 then progress
  /// messages should be suppressed.
  @async
  Response setPlaybackProgressInterval(SoundPlayerProxy player, int interval);

  /// Requests the audio focus setting the mode and gain.
  ///
  /// Was setActive(bool)
  /// - combines
  ///   ioSetCategory
  ///   androidAudioFocusRequest
  ///   setActive
  ///
  @async
  Response requestAudioFocus(SoundPlayerProxy player, AudioFocusProxy mode);

  /// Release the audio focus.
  /// The affect on other media players will a result of a prior
  /// call to [requestAudioFocus] and the [AudioFocus] mode that was passed.
  /// was setActive(false)
  @async
  Response releaseAudioFocus(SoundPlayerProxy player);

  /// Return true if the Platform supports a shade/notification area.
  @async
  Response isShadeSupported();

  /// Return true if the Platform supports a shade/notification area
  /// and is able to display a pause/resume button.
  @async
  Response isShadePauseSupported();

  /// Return true if the Platform supports a shade/notification area
  /// and is able to display a skip forward button.
  @async
  Response isShadeSkipForwardSupported();

  /// Return true if the Platform supports a shade/notification area
  /// and is able to display a skip backwards button.
  @async
  Response isShadeSkipBackwardsSupported();

  /// Return true if the Platform supports background playback.
  /// i.e. playback continues even when the app is no longer the
  /// active application.
  ///
  /// On desktop active means the app that has the mouse/keyboard focus.
  /// On mobile active is the foreground app.
  @async
  Response isBackgroundPlaybackSupported();

  //////////////////////////////////////////////////////////////////
  ///
  /// Recording methods
  ///
  /// /////////////////////////////////////////////////////////////

  @async
  Response initializeRecoder(SoundRecorderProxy recorder);

  @async
  Response releaseRecorder(SoundRecorderProxy recorder);

  @async
  Response startRecording(SoundRecorderProxy recorder, TrackProxy track);

  @async
  Response stopRecording(SoundRecorderProxy recorder);

  @async
  Response pauseRecording(SoundRecorderProxy recorder);

  @async
  Response resumeRecording(SoundRecorderProxy recorder);

  /// Sets the interval between progress messages being generated from
  /// the platform code when the passed recorder is recording.
  ///
  /// The [interval] is passed in milliseconds.
  ///
  /// If this method hasn't been called then the default interval is 100ms.
  ///
  /// If this method is called with an [interval] of 0 then progress
  /// messages should be suppressed.
  @async
  Response setRecordingProgressInterval(
      SoundRecorderProxy recorder, int interval);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// FlutterAPI - calls from the platform code back into flutter
///
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// The collection of method calls the platform can
/// use to call back into the dart code.
@FlutterApi()
abstract class SoundsFromPlatformApi {
  /// The platform MUST emit calls to this method whenever
  /// audio is playing and the progress interval is non-zero.
  ///
  /// The [duration] is the total duration of the track currently playing in
  /// milliseconds. This value may change if the audio is being streamed.
  ///
  /// The [position] is the current playback position measured as the no.
  /// of milliseconds from the start of the track. This value will change
  /// as playback occurs.
  ///
  /// The interval between calls to this method is set by a call to
  /// [setPlaybackProgressInterval]. If no call to [setPlaybackProgressInterval]
  /// has been made then the default interval MUST be 100ms.
  ///
  /// If the interval has been set to zero then no progress events
  /// should be emitted.
  @async
  void onPlaybackProgress(
      SoundPlayerProxy player, TrackProxy track, int duration, int position);

  /// The platform MUST emit calls to this method whenever audio is
  /// being recorded.
  ///
  /// The interval between calls to this method is set by a call to
  /// [setRecordingProgressInterval]. If no call to
  /// [setRecordingProgressInterval] has been made then the default interval
  /// MUST be 100ms.
  ///
  /// If the interval has been set to zero then no progress events
  /// should be emitted.
  @async
  void onRecordingProgress(SoundRecorderProxy recorder, TrackProxy track,
      double decibels, int duration);

  /// The platform MUST emit this method whenever audio stops playing
  /// (for any reason) and is non resumable .
  ///
  /// e.g. a call to [pause] would not  result in this method being
  /// called.
  ///
  ///  - the audio naturally completes to the end.
  ///  - seekToPlayer is called positioning the playback at the end of
  ///     the audio.
  ///  - an error occurs, causing the playback to stop.
  ///
  ///
  ///
  ///
  /// This method should NOT be called as a result of:
  ///
  ///  - A call to [stopPlayer]
  ///  - The app is paused or stopped.
  ///  - The user skips to another track using the shade.
  ///
  /// If the audio stoped for a non-error then [errorCode] should be
  /// 0. In this case the value of [error] will be ignored but must
  /// be an empty string (null is not permitted).
  ///
  /// If the audio stopped because of an error then you MUST
  /// set [errorCode] to a non-zero value and SHOULD populate the [error]
  /// argument with an helpful error message.
  ///
  /// The following circumstances are noted but may not be exhaustive.
  ///  - [onStopped] was called.
  ///  - the audio played to completion.
  ///  - the user skipped to another track.
  ///  - the sound player is released.
  ///  - an error occurs that causes the track to stop playing.
  ///  - playback was stopped due to the app being sent to the background.
  ///  - playback was stopped (as apposed to paused) via the shade
  @async
  void onPlaybackStopped(
      SoundPlayerProxy player, TrackProxy track, int errorCode, String error);

  /// The platform MUST emit this method when the OS Media Player
  /// is used to skip forward to the next track.
  ///
  /// [track] represents the current track that was playing when the
  /// user initiated the skip.
  @async
  void onShadeSkipForward(SoundPlayerProxy player, TrackProxy track);

  /// The platform MUST emit this method when the OS Media Player
  /// is used to skip backward to the next track.
  ///
  /// [track] represents the current track that was playing when the
  /// user initiated the skip.
  @async
  void onShadeSkipBackward(SoundPlayerProxy player, TrackProxy track);

  /// The platform MUST emit this method when the OS Media Player
  /// is used to pause playback
  ///
  /// [track] represents the current track that was playing when the
  /// user initiated the pause.
  @async
  void onShadePaused(SoundPlayerProxy player, TrackProxy track);

  /// The platform MUST emit this method when the OS Media Player
  /// is used to resume playback.
  ///
  /// [track] represents the current track that was playing when the
  /// user initialied the skip.
  @async
  void onShadeResumed(SoundPlayerProxy player, TrackProxy track);
}

void configurePigeon(PigeonOptions opts) {
  opts.dartOut =
      '../sounds_platform_interface/lib/sounds_platform_interface.dart';
  opts.objcHeaderOut = 'ios/Classes/sounds_platform_api.h';
  opts.objcSourceOut = 'ios/Classes/sounds_platform_api.m';
  opts.objcOptions.prefix = 'FLT';
  opts.javaOut =
      'android/src/main/java/com/bsutton/sounds/SoundsPlatformApi.java';
  opts.javaOptions.package = 'com.bsutton.sounds';
}

```

