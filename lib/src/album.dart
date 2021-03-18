import 'package:sounds_common/sounds_common.dart';

import 'sound_player.dart';

/// Used by onSkipForward and onSkipBackwards to provide information
/// about the current track.
typedef TrackChange = Track Function(int currentTrackIndex, Track? current);

/// An [Album] allows you to play a collection of [Track]s via
/// the OS's builtin audio UI.
///
class Album {
  /// Creates an album of tracks which will be played
  /// via the OS' built in player.
  /// The tracks will be played in order and the user
  /// has the ability to skip forward/backwards.
  /// By default the Album displays on the OS' audio player.
  /// To suppress the OS' audio player pass [SoundPlayer.noUI()]
  /// to [player].
  Album.fromTracks(this._tracks, SoundPlayer? player)
      : _virtualAlbum = false,
        onFirstTrack = _onFirstTrackNoOp,
        onSkipForward = _onSkipForwardNoOp,
        onSkipBackward = _onSkipBackwardNoOp {
    _internal(player);

    if (_tracks.isEmpty) {
      throw NoTracksAlbumException('You must pass at least one track');
    }
  }

  /// Creates a virtual album which will be played
  /// via the OS' built in player.
  /// Each time the album needs a new track the [onSkipForward]
  /// method is called and you need to return the track to be played.
  /// When you [play] an album [onSkipForward] is called immediately
  /// to get the first track.
  /// If the user clicks the skip back button on the OS UI then
  /// the [onSkipBackward] method is called and you need to supply
  /// the new track to play.
  /// The Album will not allow the user to skip back past the first
  /// track you supplied so there is no looping back over the start
  /// of an album.
  Album.virtual(SoundPlayer player)
      : _virtualAlbum = true,
        _tracks = <Track>[],
        onFirstTrack = _onFirstTrackNoOp,
        onSkipForward = _onSkipForwardNoOp,
        onSkipBackward = _onSkipBackwardNoOp {
    _internal(player);
  }

  late final SoundPlayer _player;

  final bool _virtualAlbum;

  final List<Track> _tracks;

  var _currentTrackIndex = 0;

  /// Returns the track that is currently selected.
  Track? _currentTrack;

  /// If you use the [Album.virtual] constructor then
  /// you must provide a handler for [onFirstTrack].
  /// This should return the first track of the album.
  /// This call may be made multiple times (each time
  /// the method [play] is called).
  Track Function() onFirstTrack;

  /// If you use the [Album.virtual] constructor then
  /// you need to provide a handlers for [onSkipForward]
  /// method.
  /// see [Album.virtual()] for details.
  TrackChange onSkipForward;

  /// If you use the [Album.virtual] constructor then
  /// you need to provide a handlers for [onSkipBackward]
  /// method.
  /// see [Album.virtual()] for details.
  TrackChange onSkipBackward;

  void _internal(SoundPlayer? player) {
    _player = player ?? SoundPlayer.withShadeUI();

    _player
      ..onSkipBackward = _skipBackward
      ..onSkipForward = _skipForward
      ..onStopped = _onStopped;
  }

  void _onStopped({required bool wasUser}) {}

  void _skipBackward() {
    if (_currentTrackIndex > 1) {
      /// TODO(bsutton): we should suppress onStopped events being
      /// generated form
      /// indirect actions like skip that causes a stop as a side effect.
      /// onStop should only be called if it is the 'end state'.
      stop(wasUser: true);

      _currentTrack = _previousTrack();

      /// TODO might be nice to have the concept of a transition
      /// when stoping one track and starting the next.
      /// This may require us to monitor the playback progression
      /// and start the transition before the playback completes (e.g. fadeout)
      if (_currentTrack != null) {
        play();
      }
    }
  }

  void _skipForward() {
    if (_tracks.isEmpty || _currentTrackIndex < _tracks.length - 1) {
      stop(wasUser: true);

      _currentTrack = _nextTrack();

      /// TODO might be nice to have the concept of a transition
      /// when stoping one track and starting the next.
      /// This may require us to monitor the playback progression
      /// and start the transition before the playback completes (e.g. fadeout)
      if (_currentTrack != null) {
        play();
      }
    }
  }

  /// finds the previous track.
  /// If the album is virtual it calls out
  /// to get the prior track.
  Track _previousTrack() {
    var previous = Track.end;
    final originalIndex = _currentTrackIndex;
    _currentTrackIndex--;
    if (_virtualAlbum) {
      previous = onSkipBackward(
        originalIndex,
        _currentTrack,
      );
    } else {
      previous = _tracks[_currentTrackIndex];
    }
    return previous;
  }

  /// finds the next track .
  /// If the album is virtual it calls out
  /// to get the next track.
  Track _nextTrack() {
    var next = Track.end;
    final originalIndex = _currentTrackIndex;
    _currentTrackIndex++;
    if (_virtualAlbum) {
      next = onSkipForward(
        originalIndex,
        _currentTrack,
      );
    } else {
      next = _tracks[_currentTrackIndex];
    }
    return next;
  }

  /// Start the album playing from the first track.
  void play() {
    _currentTrackIndex = 0;
    if (_virtualAlbum) {
      _currentTrack = onFirstTrack();
    } else {
      _currentTrack = _tracks[_currentTrackIndex];
    }
    if (_currentTrack != null) {
      _player.play(_currentTrack!);
    }
  }

  /// stop the album playing.
  void stop({required bool wasUser}) {
    _player.stop(wasUser: wasUser);
    if (_currentTrack != null) {
      trackRelease(_currentTrack!);
    }
  }

  /// pause the album playing
  void pause() {
    _player.pause();
  }

  /// resume the album playing.
  void resume() {
    _player.resume();
  }
}

/// throw if you try to create an album with no tracks.
class NoTracksAlbumException implements Exception {
  ///
  NoTracksAlbumException(this._message);

  final String _message;

  @override
  String toString() => _message;
}

Track _onFirstTrackNoOp() => Track.end;
Track _onSkipForwardNoOp(int index, Track? track) => Track.end;
Track _onSkipBackwardNoOp(int index, Track? track) => Track.end;
