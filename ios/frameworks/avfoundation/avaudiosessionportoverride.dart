import 'package:dart_native/dart_native.dart';

//TODO we need to figure out how this is handled in the obj C code
// we may need to manually convert the 'spkr' string to an int.
// ignore_for_file: public_member_api_docs
class AVAudioSessionPortOverride extends NSUInteger {
  final String value;
  const AVAudioSessionPortOverride({int intValue, this.value})
      : super(intValue);

  static AVAudioSessionPortOverride None =
      AVAudioSessionPortOverride(intValue: 0);

  static const AVAudioSessionPortOverride Speaker =
      AVAudioSessionPortOverride(value: 'spkr');
}
