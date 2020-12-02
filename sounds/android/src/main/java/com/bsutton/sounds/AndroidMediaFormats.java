package com.bsutton.sounds;

import android.media.MediaRecorder;
import android.os.Build;

import java.util.ArrayList;
import java.util.List;

public class AndroidMediaFormats {


    static AndroidMediaFormat generate(SoundsPlatformApi.MediaFormatProxy proxyMediaFormat) throws SoundsException {

        for (AndroidMediaFormat mediaFormat  : getEncoders())
        {
            if (mediaFormat.name.equals(proxyMediaFormat.getName()))
                return mediaFormat;

        }
        throw new SoundsException(ErrorCodes.errnoUnsupportedMediaFormat, "The MediaFormat " + proxyMediaFormat.getName() + " Is not supported");
    }

    public static ArrayList<String>  getNativeEncoderNames() {

        ArrayList<String> mediaNames = new ArrayList<>();

        for (AndroidMediaFormat mediaFormat : getEncoders())
        {
            mediaNames.add(mediaFormat.name);
        }
        return mediaNames;
    }


    public static ArrayList<String>  getNativeDecoderNames() {

        ArrayList<String> mediaNames = new ArrayList<>();

        for (AndroidMediaFormat mediaFormat : getDecoders())
        {
            mediaNames.add(mediaFormat.name);
        }
        return mediaNames;
    }

    static  List<AndroidMediaFormat> getEncoders()
    {
        List<AndroidMediaFormat> mediaFormats = new ArrayList<>();

        for (AndroidMediaFormat mediaFormat : getAllFormats())
        {
            if (mediaFormat.canEncode)
            {
                mediaFormats.add(mediaFormat);
            }
        }
        return mediaFormats;
    }

    static  List<AndroidMediaFormat> getDecoders()
    {
        List<AndroidMediaFormat> mediaFormats = new ArrayList<>();

        for (AndroidMediaFormat mediaFormat : getAllFormats())
        {
            if (mediaFormat.canDecode)
            {
                mediaFormats.add(mediaFormat);
            }
        }
        return mediaFormats;

    }

    static private List<AndroidMediaFormat> getAllFormats()
    {
        List<AndroidMediaFormat> mediaFormats = new ArrayList<>();

        AndroidMediaFormat aacAdts = new AndroidMediaFormat("adts/aac", MediaRecorder.AudioEncoder.AAC, MediaRecorder.OutputFormat.AAC_ADTS);
        aacAdts.canEncode = true;
        aacAdts.canDecode = true;
        mediaFormats.add(aacAdts);


        /// Mp3 decoder supported but not encoding (recorder).
        AndroidMediaFormat mp3 =new AndroidMediaFormat("mp3", -1, -1);
        mp3.canEncode = false;
        mp3.canDecode = true;
        mediaFormats.add(mp3);

        AndroidMediaFormat oggOpus  = new AndroidMediaFormat("ogg/opus", MediaRecorder.AudioEncoder.OPUS, MediaRecorder.OutputFormat.OGG);
        oggOpus.canEncode = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q;
        oggOpus.canDecode = Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP;
        mediaFormats.add(oggOpus);

        AndroidMediaFormat oggVorbis = new AndroidMediaFormat("ogg/vorbis", MediaRecorder.AudioEncoder.VORBIS, MediaRecorder.OutputFormat.OGG);
        oggVorbis.canEncode = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q;
        oggVorbis.canDecode = true;
        mediaFormats.add(oggVorbis);

        return mediaFormats;
    }

}
