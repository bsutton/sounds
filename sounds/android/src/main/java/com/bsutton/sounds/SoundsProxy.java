package com.bsutton.sounds;

/**
 * base class for SoundPlayer and SoundRecorder
 * so we can store then in a map used by FromFlutterDispatcher
 * to dispatch calls.
 */
abstract public class SoundsProxy {
    String uuid;

    /** overload this method to clean up any resources
     * when the object is no longer required.
     */
    abstract public void dispose();

}
