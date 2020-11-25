import 'package:sounds/src/ios/frameworks/avfoundation/avaudioplayer.dart';
import "package:test/test.dart";

void main() { 
   // Define the test 
   test("Testing ffi implementation of AVAudioPlayer",(){  
      // Arrange 
      AVAudioPlayer player = new AVAudioPlayer(); 
      // Asset 
      expect(player.playing,false); 
   }); 
}