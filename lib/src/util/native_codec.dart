import 'package:sounds/src/plugins/sound_player_plugin.dart';
import 'package:sounds_common/sounds_common.dart';

import '../sound_player.dart';

class NativeCodec extends Codec {
  @override
  Future<Duration> duration(Track track) {
    return SoundPlayer.noUI().duration(track);
  }
}
