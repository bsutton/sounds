package com.bsutton.sounds;

/**
 * base class for SoundPlayer, ShadePlayer and SoundRecorder
 * so we can store then in a map used by FromFlutterDispatcher
 * to dispatch calls.
 */
public class SoundProxy {
    String uuid;
}
