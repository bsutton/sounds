/*
 * This file is part of Sounds.
 *
 *   Sounds is free software: you can redistribute it and/or modify
 *   it under the terms of the Lesser GNU General Public License
 *   version 3 (LGPL3) as published by the Free Software Foundation.
 *
 *   Sounds is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the Lesser GNU General Public License
 *   along with Sounds.  If not, see <https://www.gnu.org/licenses/>.
 */

export 'package:sounds_common/sounds_common.dart'
    show
        MediaFormat,
        MediaFormatException,
        PlaybackDisposition,
        Track,
        FileUtil,
        Downloader,
        AdtsAacMediaFormat,
        CafOpusMediaFormat,
        MP3MediaFormat,
        NativeMediaFormats,
        OggOpusMediaFormat,
        OggVorbisMediaFormat,
        PCMMediaFormat,
        WellKnownMediaFormats;

export 'src/album.dart';
export 'src/audio_focus.dart';
export 'src/audio_source.dart' show AudioSource;
export 'src/quality.dart' show Quality;
export 'src/quick_play.dart' show QuickPlay;
export 'src/recording_disposition.dart' show RecordingDisposition;
export 'src/sound_player.dart'
    show SoundPlayer, PlayerInvalidStateException
    hide
        updateProgress,
        audioPlayerFinished,
        onSystemPaused,
        onSystemResumed,
        onSystemSkipForward,
        onSystemSkipBackward;
export 'src/sound_recorder.dart' show SoundRecorder, RecorderException, RecorderInvalidStateException;
export 'src/ui/recorder_playback_controller.dart' show RecorderPlaybackController;
export 'src/ui/sound_player_ui.dart' show SoundPlayerUI;
export 'src/ui/sound_recorder_ui.dart' show SoundRecorderUI;
