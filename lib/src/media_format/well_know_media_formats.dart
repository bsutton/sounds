import 'package:sounds_common/sounds_common.dart';

import 'adts_aac_media_format.dart';
import 'cap_opus_media_format.dart';
import 'mp3_media_format.dart';
import 'ogg_opus_media_format.dart';
import 'ogg_vorbis_media_format.dart';
import 'pcm_media_format.dart';

// ignore: avoid_classes_with_only_static_members
/// List of well known [MediaFormat]s
///
/// These are provided to act as keys in maps which can be useful sometimes
/// These are used in the example apps and I suspect that aren't actually useful
/// in a real program as you need to check if they are supported on the OS/SDK combo.
class WellKnownMediaFormats {
  /// Native MediaFormat for adts/aac
  static AdtsAacMediaFormat adtsAac = AdtsAacMediaFormat();

  /// MediaFormat for caf/opus
  static CafOpusMediaFormat opusCaf = CafOpusMediaFormat();

  /// MediaFormat pcm
  static PCMMediaFormat pcm = PCMMediaFormat();

  /// MediaFormat ogg/opus
  static OpusOggMediaFormat oggOpus = OpusOggMediaFormat();

  /// Native MediaFormat ogg/vorbis
  static VorbisOggMediaFormat oggVorbis = VorbisOggMediaFormat();

  /// Native MediaFormat mp3
  static MP3MediaFormat mp3 = MP3MediaFormat();
}
