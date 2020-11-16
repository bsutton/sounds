import 'package:dart_native/dart_native.dart';

class MPMediaItemArtwork extends NSObject {
  
  MPMediaItemArtwork({CGSize boundsSize, Function requestHandler}) {
    MPMediaItemArtwork.init(
        boundsSize: boundsSize, requestHandler: requestHandler);
  }
  MPMediaItemArtwork.init({CGSize boundsSize, Function requestHandler}) {}
}
