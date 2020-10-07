package com.bsutton.sounds;

import android.os.Build;

public class AndroidMediaFormat {

    int encoder;
    int format;

    public AndroidMediaFormat(int encoder, int format) {
        this.encoder = encoder;
        this.format = format;
    }

    static AndroidMediaFormat generate(SoundsPlatformApi.MediaFormatProxy proxyMediaFormat) throws SoundsException {
        String name = proxyMediaFormat.getName();

        if (name == proxyMediaFormat.getAdtsAac()) {
            return new AndroidMediaFormat(3, 6);
        } else if (name == proxyMediaFormat.getOggOpus() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            return new AndroidMediaFormat(7, 11);
        }
        else if (name == proxyMediaFormat.getOggVorbis()) {
            return new AndroidMediaFormat(6, 11);
        }

        throw new SoundsException(ErrorCodes.errnoUnsupportedMediaFormat, "The MediaFormat " + name + " Is not supported");

    }
}
