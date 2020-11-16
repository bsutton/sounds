class MPNowPlayingInfoCenter {
  
  static MPNowPlayingInfoCenter defaultInstance(){
    return MPNowPlayingInfoCenter();
  }
  Map<String, dynamic> nowPlayingInfo;
  static String MPNowPlayingInfoPropertyElapsedPlaybackTime;
  static String MPNowPlayingInfoPropertyPlaybackRate;
}
