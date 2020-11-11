import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

//ignore_for_file: public_member_api_docs
//ignore_for_file: non_constant_identifier_names
class AVAudioSessionCategory extends NSString {
  AVAudioSessionCategory(String value) : super(value);

  AVAudioSessionCategory.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr);

  static var NotSet = AVAudioSessionCategory('NotSet');
  static var Ambient = AVAudioSessionCategory('AVAudioSessionCategoryAmbient');
  static var SoloAmbient =
      AVAudioSessionCategory('AVAudioSessionCategorySoloAmbient');
  static var Playback =
      AVAudioSessionCategory('AVAudioSessionCategoryPlayback');
  static var Record = AVAudioSessionCategory('AVAudioSessionCategoryRecord');
  static var PlayAndRecord =
      AVAudioSessionCategory('AVAudioSessionCategoryPlayAndRecord');
  static var AudioProcessing =
      AVAudioSessionCategory('AVAudioSessionCategoryAudioProcessing');
}
