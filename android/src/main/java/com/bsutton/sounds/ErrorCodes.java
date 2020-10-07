package com.bsutton.sounds;

public class ErrorCodes {
    //// This list of error codes MUST match the list documented in pigeon/sounds_platform_api.dart

    /// The list of specific errors that can be passed from the platform to dart.
    static long errnoGeneral = 1;

    /// A timeout occured. The error message contains the reason
    static long errnoTimeout = 2;

    /// Indicates that Dart attempted to perform an action on a player
    /// which has either not been initialised or has been released.
    static long errnoUnknownPlayer = 3;

    /// Indicates that Sounds has attempted to start playing or
    /// resume playing audio on a [SoundPlayerProxy] when it's already
    /// playing.
    static long errnoAlreadyPlaying = 4;

    /// Indicates that Sounds attempted to stop playing or pause playing
    /// audio on a [SoundPlayerProxy] when the proxy was not currently playing.
    static long errnoNotPlaying = 5;

    /// Indicates that Sounds attempted to play audio in the background
    /// but the Platform does not support background audio.
    static long errnoBackgroudAudioNotSupported = 6;

    /// Indicates that Sounds attempted to start playing audio
    /// vai the startPlayerWithShade method and the Platform does not
    /// support a shade.
    static long errnoShadeNotSupported = 7;

    /// Indicates that a track contained audio using an unsupported
    /// media format. The error description should contain additional
    /// details which acuratly describes what aspect of the Media Format
    /// was not supported.
    static long errnoUnsupportedMediaFormat = 8;

    /// Malformed audio. The passed audio does not match the expected MediaFormat
    static long errnoMalformedMedia = 9;

    /// an IO error occured reading/writing to a file or
    /// network address.
    static long errnoIOError = 10;

    /// The platform audio service failed.
    static long errnoAudioServiceDied = 11;

    /// The api was passed an invalid argument. The description
    /// contains the details.
    static long errnoInvalidArgument = 12;

    /// The user doesn't given the app permission to access the AudioSource
    /// e.g. microphone. This error can occur when you try to start recording
    /// without seeking the users permission.
    static long errnoAudioSourcePermissionDenied = 13;

    /// A call was made to stop the recording when the recorder
    /// wasn't currently playing.
    static long errnoNotRecording = 14;


    /// A call with a uuid for which there was no active recorder.
    static long errnoUnknownRecorder = 15;

    /// A call was made that is not supported by the current
    /// platform. The description will contain further details.
    static long errnoNotSupported = 16;

}
