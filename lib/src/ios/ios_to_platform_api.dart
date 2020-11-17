// func SoundPlayerReg(_ registrar: (NSObjectProtocol
// & FlutterPluginRegistrar)) {
// }

// func SoundPlayerReg(_ registrar: (NSObjectProtocol
//  & FlutterPluginRegistrar)?) {
//     SoundPlayerManager.register(with: registrar as! FlutterPluginRegistrar)
// }

import 'dart:ffi';

import 'package:sounds/src/ios/frameworks/util/types.dart';
import 'package:sounds/src/ios/sound_player_ios.dart';
import 'package:sounds/src/ios/sound_recorder_ios.dart';
import 'package:sounds/src/platform/sounds_platform_api.dart';

import 'frameworks/audiofile/audiofile.dart';
import 'frameworks/audiofile/audiofileclose.dart';
import 'frameworks/audiofile/audiofilegetproperty.dart';
import 'frameworks/audiofile/audiofileopenurl.dart';
import 'frameworks/avfoundation/cfurl.dart';

class IOSToPlatformAPI extends SoundsToPlatformApi {
// Slots to track method calls from the dart into ios code.
// These slots are shared by the SoundPlayer and the ShadePlayer.
  /// private var _channel: FlutterMethodChannel?
  var playerSlots = <String, SoundPlayerIOS>{};

  var recorderSlots = <String, SoundRecorderIOS>{};

  ///
  static IOSToPlatformAPI soundPlayerManager =
      IOSToPlatformAPI._internal(); // Singleton
  // class func register(with registrar: FlutterPluginRegistrar) {
  //    var channel = FlutterMethodChannel(
  //      name: "com.bsutton.sounds.sound_player",
  //      binaryMessenger: registrar.messenger())
  //     assert(soundPlayerManager == null)
  //     soundPlayerManager = SoundPlayerManager()
  //     soundPlayerManager!.setChannel(channel: channel)
  //     registrar.addMethodCallDelegate(soundPlayerManager!, channel: channel)

  // }

  ///
  factory IOSToPlatformAPI() => soundPlayerManager;

  IOSToPlatformAPI._internal();

  SoundPlayerIOS _getPlayer(SoundPlayerProxy playerProxy) {
    var player = playerSlots[playerProxy.uuid];

    if (player == null) {
      var response = Response();
      response.success = false;
      response.errorCode = SoundsToPlatformApi.errnoUnknownPlayer;
      response.error = 'Now sound player exists for uuid=${playerProxy.uuid}';
      throw response;
    }

    return player;
  }

  SoundRecorderIOS _getRecorder(SoundRecorderProxy recorderProxy) {
    var recorder = recorderSlots[recorderProxy.uuid];

    if (recorder == null) {
      var response = Response();
      response.success = false;
      response.errorCode = SoundsToPlatformApi.errnoUnknownRecorder;
      response.error = 'No SoundRecorder exists for uuid=${recorderProxy.uuid}';
      throw response;
    }

    return recorder;
  }

  @override
  MediaFormatResponse getNativeDecoderFormats(MediaFormatProxy proxy) {
    // TODO: implement getNativeDecoderFormats
    throw UnimplementedError();
  }

  @override
  MediaFormatResponse getNativeEncoderFormats(MediaFormatProxy proxy) {
    // TODO: implement getNativeEncoderFormats
    throw UnimplementedError();
  }

  @override
  Response initializePlayer(InitializePlayer initializePlayer) {
    var response = Response();

    var uuid = initializePlayer.player.uuid;

    if (playerSlots.containsKey(uuid)) {
      response.success = false;
      response.errorCode = SoundsToPlatformApi.errnoGeneral;
      response.error = "SoundPlayer with $uuid already initialised";
    } else {
      /// TODO: pass play in background down.
      playerSlots[uuid] = SoundPlayerIOS();
      response.success = true;
    }
    return response;
  }

  @override
  Response initializePlayerWithShade(
      InitializePlayerWithShade initializePlayerWithShade) {
    // TODO: implement initializePlayerWithShade
    throw UnimplementedError();
  }

  @override
  Response initializeRecorder(SoundRecorderProxy recorder) {
    var response = Response();

    var uuid = recorder.uuid;

    if (recorderSlots.containsKey(uuid)) {
      response.success = false;
      response.errorCode = SoundsToPlatformApi.errnoGeneral;
      response.error = "SoundRecorder with $uuid already initialised";
    } else {
      recorderSlots[uuid] = SoundRecorderIOS();
      response.success = true;
    }
    return response;
  }

  @override
  BoolResponse isBackgroundPlaybackSupported() {
    // TODO: implement isBackgroundPlaybackSupported
    throw UnimplementedError();
  }

  @override
  BoolResponse isShadePauseSupported() {
    // TODO: implement isShadePauseSupported
    throw UnimplementedError();
  }

  @override
  BoolResponse isShadeSkipBackwardsSupported() {
    // TODO: implement isShadeSkipBackwardsSupported
    throw UnimplementedError();
  }

  @override
  BoolResponse isShadeSkipForwardSupported() {
    // TODO: implement isShadeSkipForwardSupported
    throw UnimplementedError();
  }

  @override
  BoolResponse isShadeSupported() {
    // TODO: implement isShadeSupported
    throw UnimplementedError();
  }

  @override
  Response pausePlayer(SoundPlayerProxy playerProxy) {
    try {
      var player = _getPlayer(playerProxy);

      return player.pausePlayer();
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response pauseRecording(SoundRecorderProxy recorderProxy) {
    try {
      var recorder = _getRecorder(recorderProxy);

      return recorder.pauseRecording(recorderProxy);
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response releaseAudioFocus(SoundPlayerProxy playerProxy) {
    try {
      var player = _getPlayer(playerProxy);

      return player.releaseAudioFocus();
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response releasePlayer(SoundPlayerProxy playerProxy) {
    try {
      var player = _getPlayer(playerProxy);

      return player.releasePlayer();
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response releaseRecorder(SoundRecorderProxy recorderProxy) {
    try {
      var recorder = _getRecorder(recorderProxy);

      return recorder.releaseRecorder(recorderProxy);
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response requestAudioFocus(RequestAudioFocus requestAudioFocus) {
    try {
      var player = _getPlayer(requestAudioFocus.player);
      return player.requestAudioFocus(requestAudioFocus.audioFocus);
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response resumePlayer(SoundPlayerProxy playerProxy) {
    try {
      var player = _getPlayer(playerProxy);

      return player.resumePlayer();
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response resumeRecording(SoundRecorderProxy recorderProxy) {
    try {
      var recorder = _getRecorder(recorderProxy);

      return recorder.resumeRecording(recorderProxy);
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response seekToPlayer(SeekToPlayer seekPlayer) {
    try {
      var player = _getPlayer(seekPlayer.player);

      return player
          .seekToPlayer(Duration(milliseconds: seekPlayer.milliseconds));
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response setPlaybackProgressInterval(
      SetPlaybackProgressInterval setPlaybackProgressInterval) {
    try {
      var player = _getPlayer(setPlaybackProgressInterval.player);

      return player.setPlaybackProgressInterval(
          Duration(milliseconds: setPlaybackProgressInterval.interval));
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response setRecordingProgressInterval(
      SetRecordingProgressInterval setRecordingProgressInterval) {
    try {
      var recorder = _getRecorder(setRecordingProgressInterval.recorder);

      return recorder
          .setRecordingProgressInterval(setRecordingProgressInterval);
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response setVolume(SetVolume setVolume) {
    try {
      var player = _getPlayer(setVolume.player);

      // TODO: adjust the volume range for ios.
      return player.setVolume(setVolume.volume);
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response startPlayer(StartPlayer startPlayer) {
    try {
      var player = _getPlayer(startPlayer.player);

      // TODO: adjust the volume range for ios.
      return player.startPlayer(
          startPlayer.track, Duration(milliseconds: startPlayer.startAt));
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response startRecording(StartRecording startRecording) {
    try {
      var recorder = _getRecorder(startRecording.recorder);

      return recorder.startRecording(startRecording);
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response stopPlayer(SoundPlayerProxy playerProxy) {
    try {
      var player = _getPlayer(playerProxy);

      // TODO: adjust the volume range for ios.
      return player.stopPlayer();
    } on Response catch (r) {
      return r;
    }
  }

  @override
  Response stopRecording(SoundRecorderProxy recorderProxy) {
    try {
      var recorder = _getRecorder(recorderProxy);

      return recorder.stopRecording(recorderProxy);
    } on Response catch (r) {
      return r;
    }
  }

  @override
  DurationResponse getDuration(GetDuration getDuration) {
    var response = DurationResponse();

    /// let the dart code resume whilst we calculate the duration.
    var path = getDuration.path;
    var afUrl = CFURL.fromfromFileSystemPathString(
        path, CFURLPathStyle.cfurlposixPathStyle);
    var fileID = AudioFileID();

    var status = AudioFileOpenURL(
        afUrl.addressOf as CFURLRef,
        AudioFilePermissions.kAudioFileReadPermission,
        AudioFileTypeID(0),
        fileID);

    var outDataSize = Uint32Arg(0);
    var thePropSize = VoidArg();

    /// this call was a 'let' which creates a wrapper for fileID.
    var wfileID = fileID;

    if (wfileID != null) {
      status = AudioFileGetProperty(
          wfileID,
          AudioFilePropertyID.kAudioFilePropertyEstimatedDuration,
          outDataSize.addressOfNative,
          thePropSize.addressOfNative);
          
      AudioFileClose(wfileID);
    }
    print("getDuration status $status");

//originally kAudioServicesNoError this is error code 0 from OSStatus
    if (status == 0) {
      var milliseconds = outDataSize.value * 1000;

      response.success = true;
      response.duration = milliseconds;
    } else {
      /// danger will robison, danger
      response.success = false;
      response.errorCode = SoundsToPlatformApi.errnoGeneral;
      response.error = 'Error calculating the duration';
    }
    return response;
  }
}
