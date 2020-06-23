import '../../sounds_common.dart';

abstract class Codec {
  String get name;

  Future<Duration> duration(Track track);
}
