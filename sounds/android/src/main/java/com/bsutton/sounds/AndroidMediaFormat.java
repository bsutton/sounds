package com.bsutton.sounds;

import android.media.MediaRecorder;
import android.os.Build;

import java.util.ArrayList;
import java.util.List;

public class AndroidMediaFormat {
    String name;
    int encoder;
    int format;

    boolean canEncode;
    boolean canDecode;

    public AndroidMediaFormat(String name, int encoder, int format) {
        this.name = name;
        this.encoder = encoder;
        this.format = format;
    }

}
