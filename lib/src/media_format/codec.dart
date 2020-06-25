class Codec {
  final String name;

  const Codec(this.name);

  static const AAC = Codec('aac');
  static const OGG = Codec('ogg');
  static const OPUS = Codec('opus');
  static const MP3 = Codec('mp3');
  static const PCM = Codec('pcm');
}
