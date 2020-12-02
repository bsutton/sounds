package com.bsutton.sounds;

import android.content.Context;
import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.os.Build;

import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * class that handles calls from flutter and dispatches the
 * calls into java.
 */

public class FromFlutterDispatcher implements SoundsPlatformApi.SoundsToPlatformApi {
    private Context context;

    /// Maps a proxie's uuid to the proxy.
    private final HashMap<String, SoundsProxy> soundsProxies = new HashMap<>();


    public FromFlutterDispatcher(Context context) {
        this.context = context;
    }

    void onDestroy()
    {

    }

    private SoundsPlatformApi.Response success()
    {
        SoundsPlatformApi.Response response = new SoundsPlatformApi.Response();
        response.setSuccess(true);
        return response;
    }



    private SoundsPlatformApi.BoolResponse boolResponse(boolean response)
    {
        SoundsPlatformApi.BoolResponse boolResponse;
        boolResponse = new SoundsPlatformApi.BoolResponse();
        boolResponse.setSuccess(true);
        boolResponse.setBoolResult(response);
        return boolResponse;
    }

    public void disposeAll() {
        for (SoundsProxy proxy : soundsProxies.values()) {
           proxy.dispose();
        }
        soundsProxies.clear();
    }

    /**
     * Get the SoundPlayer via its uuid
     */
    private SoundPlayer getPlayer(String uuid) throws SoundsException {
        SoundPlayer player =   (SoundPlayer) soundsProxies.get(uuid);

        if (player == null)
        {
            throw new SoundsException(ErrorCodes.errnoUnknownPlayer, "No SoundPlayer exists for  uuid=" + uuid );
        }
        return player;
    }

    private SoundRecorder getRecorder(String uuid) throws SoundsException {
        SoundRecorder recorder =   (SoundRecorder) soundsProxies.get(uuid);

        if (recorder == null)
        {
            throw new SoundsException(ErrorCodes.errnoUnknownRecorder, "No SoundRecorder exists for  uuid=" + uuid );
        }
        return recorder;
    }

    @Override
    public SoundsPlatformApi.Response initializePlayer(SoundsPlatformApi.InitializePlayer arg) {
        SoundsPlatformApi.SoundPlayerProxy proxy = arg.getPlayer();
        String uuid = arg.getPlayer().getUuid();
        boolean playInBackground = arg.getPlayInBackground();
        SoundPlayer player = new SoundPlayer();
        soundsProxies.put(uuid, player);
        player.initializeSoundPlayer(proxy, playInBackground);

        return success();
    }

    @Override
    public SoundsPlatformApi.Response initializePlayerWithShade(SoundsPlatformApi.InitializePlayerWithShade arg) {
        SoundsPlatformApi.SoundPlayerProxy proxy = arg.getPlayer();
        String uuid = arg.getPlayer().getUuid();
        boolean playInBackground = arg.getPlayInBackground();
        ShadePlayer player = new ShadePlayer();
        soundsProxies.put(uuid, player);

        boolean canPause = arg.getCanPause();
        boolean canSkipBackward = arg.getCanSkipBackward();
        boolean canSkipForward = arg.getCanSkipForward();

        try {
            player.initializeShadePlayer(proxy, playInBackground, canPause, canSkipBackward, canSkipForward);
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }

    }



    @Override
    public SoundsPlatformApi.Response releasePlayer(SoundsPlatformApi.SoundPlayerProxy arg) {
        try {
            String uuid = arg.getUuid();
            SoundPlayer player = getPlayer(uuid);
            player.releaseSoundPlayer();
            soundsProxies.remove(uuid);
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }
    }

    @Override
    public SoundsPlatformApi.Response  startPlayer(SoundsPlatformApi.StartPlayer arg) {
        String uuid = arg.getPlayer().getUuid();
        long startAt = arg.getStartAt();
        SoundsPlatformApi.TrackProxy track = arg.getTrack();

        try {
            SoundPlayer player = getPlayer(uuid);

            player.startPlayer(track,  Duration.ofMillis(startAt));
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }
    }

    @Override
    public SoundsPlatformApi.Response  stopPlayer(SoundsPlatformApi.SoundPlayerProxy arg) {
        String uuid = arg.getUuid();

        try {
            SoundPlayer player = getPlayer(uuid);
            player.stopPlayer();
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }
    }

    @Override
    public SoundsPlatformApi.Response  pausePlayer(SoundsPlatformApi.SoundPlayerProxy arg) {
        String uuid = arg.getUuid();

        try {
            SoundPlayer player = getPlayer(uuid);
            player.pausePlayer();
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }
    }

    @Override
    public SoundsPlatformApi.Response  resumePlayer(SoundsPlatformApi.SoundPlayerProxy arg) {
        String uuid = arg.getUuid();

        try {
            SoundPlayer player = getPlayer(uuid);
            player.resumePlayer();
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }

    }

    @Override
    public SoundsPlatformApi.Response  seekToPlayer(SoundsPlatformApi.SeekToPlayer arg) {
        String uuid = arg.getPlayer().getUuid();
        Duration seekTo = Duration.ofMillis(arg.getMilliseconds());
        try {
            SoundPlayer player = getPlayer(uuid);
            player.seekToPlayer(seekTo);
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }
    }

    @Override
    public SoundsPlatformApi.DurationResponse  getDuration(SoundsPlatformApi.GetDuration arg) {

        try {
            Uri uri = Uri.parse(arg.getPath());
            MediaMetadataRetriever mmr = new MediaMetadataRetriever();
            mmr.setDataSource(context, uri);
            String durationStr = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
            if (durationStr == null) {
                throw new SoundsException(ErrorCodes.errnoGeneral, "Unable to determine the duration. Reason unknown");
            }
            long milliSeconds =  Long.parseLong(durationStr);
            SoundsPlatformApi.DurationResponse response = new SoundsPlatformApi.DurationResponse();
            response.setSuccess(true);
            response.setDuration(milliSeconds);

            return response;
        }
        catch (SoundsException e)
        {
            SoundsPlatformApi.DurationResponse  response = new SoundsPlatformApi.DurationResponse();
            response.setSuccess(false);
            response.setErrorCode(e.errorCode);
            response.setError(e.error);
            return response;
        }
    }

    @Override
    public SoundsPlatformApi.Response  setVolume(SoundsPlatformApi.SetVolume arg) {
        String uuid = arg.getPlayer().getUuid();
        /// Sounds use a value between 0 and 100
        /// but android expects 0 -1.
        float volume = ((float)arg.getVolume()/ 100);

        try {
            SoundPlayer player = getPlayer(uuid);
            player.setVolume(volume);
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }
    }

    @Override
    public SoundsPlatformApi.Response  setPlaybackProgressInterval(SoundsPlatformApi.SetPlaybackProgressInterval arg) {
        String uuid = arg.getPlayer().getUuid();
        Duration interval = Duration.ofMillis(arg.getInterval());

        try {
            SoundPlayer player = getPlayer(uuid);
            player.setProgressInterval(interval);
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }
    }

    @Override
    public SoundsPlatformApi.Response  requestAudioFocus(SoundsPlatformApi.RequestAudioFocus arg) {
        String uuid = arg.getPlayer().getUuid();
        SoundsPlatformApi.AudioFocusProxy audioFocus = arg.getAudioFocus();

        try {
            SoundPlayer player = getPlayer(uuid);
            player.requestAudioFocus(audioFocus);
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }
    }

    @Override
    public SoundsPlatformApi.Response  releaseAudioFocus(SoundsPlatformApi.SoundPlayerProxy arg) {
        String uuid = arg.getUuid();

        try {
            SoundPlayer player = getPlayer(uuid);
            player.releaseAudioFocus();
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }
    }

    @Override
    public SoundsPlatformApi.BoolResponse  isShadeSupported() {
            return boolResponse(true);
    }

    @Override
    public SoundsPlatformApi.BoolResponse isShadePauseSupported() {
        return boolResponse(true);

    }

    @Override
    public SoundsPlatformApi.BoolResponse isShadeSkipForwardSupported() {
        return boolResponse(true);

    }

    @Override
    public SoundsPlatformApi.BoolResponse isShadeSkipBackwardsSupported() {
        return boolResponse(true);

    }

    @Override
    public SoundsPlatformApi.BoolResponse isBackgroundPlaybackSupported() {
        return boolResponse(true);

    }


    /******************************************************************************
     *
     * SoundRecorder entry points
     *
     */

    @Override
    public SoundsPlatformApi.Response initializeRecorder(SoundsPlatformApi.SoundRecorderProxy arg) {
        String uuid = arg.getUuid();

        SoundRecorder recorder = new SoundRecorder();
        soundsProxies.put(uuid, recorder);
        recorder.initializeSoundRecorder(arg);

        return success();
    }

    @Override
    public SoundsPlatformApi.Response releaseRecorder(SoundsPlatformApi.SoundRecorderProxy arg) {
        try {
            String uuid = arg.getUuid();
            SoundRecorder recorder = getRecorder(uuid);

            recorder.releaseSoundRecorder();
            soundsProxies.remove(uuid);
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }
    }

    @Override
    public SoundsPlatformApi.Response startRecording(SoundsPlatformApi.StartRecording arg) {
        try {
            String uuid = arg.getRecorder().getUuid();
            SoundRecorder recorder = getRecorder(uuid);
            SoundsPlatformApi.TrackProxy track = arg.getTrack();
            SoundsPlatformApi.AudioSourceProxy audioSource = arg.getAudioSource();
            // we ignore quality on android.
            /// arg.getQuality();

            recorder.startRecorder(audioSource, track);
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }
    }

    @Override
    public SoundsPlatformApi.Response stopRecording(SoundsPlatformApi.SoundRecorderProxy arg) {
        try {
            String uuid = arg.getUuid();
            SoundRecorder recorder = getRecorder(uuid);

            recorder.stopRecorder();
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }
    }

    @Override
    public SoundsPlatformApi.Response pauseRecording(SoundsPlatformApi.SoundRecorderProxy arg) {
        try {
            String uuid = arg.getUuid();
            SoundRecorder recorder = getRecorder(uuid);

            recorder.pauseRecorder();
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }
    }

    @Override
    public SoundsPlatformApi.Response resumeRecording(SoundsPlatformApi.SoundRecorderProxy arg) {
        try {
            String uuid = arg.getUuid();
            SoundRecorder recorder = getRecorder(uuid);

            recorder.resumeRecorder();
            return success();
        }
        catch (SoundsException e)
        {
            return e.getResponse();
        }
    }

    @Override
    public SoundsPlatformApi.MediaFormatResponse getNativeEncoderFormats(SoundsPlatformApi.MediaFormatProxy arg) {

        SoundsPlatformApi.MediaFormatResponse response = new SoundsPlatformApi.MediaFormatResponse();
        response.setMediaFormats(AndroidMediaFormats.getNativeEncoderNames());
        return response;
    }

    @Override
    public SoundsPlatformApi.MediaFormatResponse getNativeDecoderFormats(SoundsPlatformApi.MediaFormatProxy arg) {

        SoundsPlatformApi.MediaFormatResponse response = new SoundsPlatformApi.MediaFormatResponse();
        response.setMediaFormats(AndroidMediaFormats.getNativeDecoderNames());
        return response;
    }


    @Override
    public SoundsPlatformApi.Response setRecordingProgressInterval(SoundsPlatformApi.SetRecordingProgressInterval arg) {

        try {
            String uuid = arg.getRecorder().getUuid();
            Duration interval = Duration.ofMillis(arg.getInterval());
            SoundRecorder recorder = getRecorder(uuid);
            recorder.setProgressInterval(interval);
            return success();
        } catch (SoundsException e)
        {
            return e.getResponse();
        }

    }
}
