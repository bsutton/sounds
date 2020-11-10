// ignore_for_file: public_member_api_docs
//ignore_for_file: constant_identifier_names
typedef AVAudioSessionPort = Function();

typedef AVAudioSessionMode = Function();

class AVAudioSessionCategoryOptions {
  static const MixWithOthers = 0x1;
  static const DuckOthers = 0x2;
  static const AllowBluetooth = 0x4;
  static const DefaultToSpeaker = 0x8;
  static const InterruptSpokenAudioAndMixWithOthers = 0x11;
  static const AllowBluetoothA2DP = 0x20;
  static const AllowAirPlay = 0x40;
}
