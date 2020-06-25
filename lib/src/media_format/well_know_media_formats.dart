
import 'package:sounds_common/sounds_common.dart';

import 'aac_adts_media_format.dart';
import 'mp3_media_format.dart';
import 'ogg_opus_media_format.dart';
import 'ogg_vorbis_media_format.dart';
import 'opus_caf_media_format.dart';
import 'pcm_media_format.dart';

/// List of well known [MediaFormat]s
///
/// These are provided to act as keys in maps which can be useful sometimes
/// These are used in the example apps and I suspect that aren't actually useful in
/// a real program as you need to check if they are supported on the OS/SDK combo.
class WellKnownMediaFormats {
  static var aacAdts = AACADTSMediaFormat();
  static var opusCaf = OpusCafMediaFormat();
  static var pcm = PCMMediaFormat();
  static var oggOpus = OGGOpusMediaFormat();
  static var oggVorbis = OGGVorbisMediaFormat();
  static var mp3 = MP3MediaFormat();
}
