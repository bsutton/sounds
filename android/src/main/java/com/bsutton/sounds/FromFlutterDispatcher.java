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
    public void initializePlayer(SoundsPlatformApi.InitializePlayer arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        SoundsPlatformApi.SoundPlayerProxy proxy = arg.getPlayer();
        String uuid = arg.getPlayer().getUuid();
        boolean playInBackground = arg.getPlayInBackground();
        SoundPlayer player = new SoundPlayer();
        soundsProxies.put(uuid, player);
        player.initializeSoundPlayer(proxy, playInBackground);

        result.success(success());
    }

    @Override
    public void initializePlayerWithShade(SoundsPlatformApi.InitializePlayerWithShade arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
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
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }

    }

    @Override
    public void releasePlayer(SoundsPlatformApi.SoundPlayerProxy arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        try {
            String uuid = arg.getUuid();
            SoundPlayer player = getPlayer(uuid);
            player.releaseSoundPlayer();
            soundsProxies.remove(uuid);
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }
    }

    @Override
    public void startPlayer(SoundsPlatformApi.StartPlayer arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        String uuid = arg.getPlayer().getUuid();
        long startAt = arg.getStartAt();
        SoundsPlatformApi.TrackProxy track = arg.getTrack();

        try {
            SoundPlayer player = getPlayer(uuid);

            player.startPlayer(track,  Duration.ofMillis(startAt));
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }
    }

    @Override
    public void stopPlayer(SoundsPlatformApi.SoundPlayerProxy arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        String uuid = arg.getUuid();

        try {
            SoundPlayer player = getPlayer(uuid);
            player.stopPlayer();
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }
    }

    @Override
    public void pausePlayer(SoundsPlatformApi.SoundPlayerProxy arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        String uuid = arg.getUuid();

        try {
            SoundPlayer player = getPlayer(uuid);
            player.pausePlayer();
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }
    }

    @Override
    public void resumePlayer(SoundsPlatformApi.SoundPlayerProxy arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        String uuid = arg.getUuid();

        try {
            SoundPlayer player = getPlayer(uuid);
            player.resumePlayer();
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }

    }

    @Override
    public void seekToPlayer(SoundsPlatformApi.SeekToPlayer arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        String uuid = arg.getPlayer().getUuid();
        Duration seekTo = Duration.ofMillis(arg.getMilliseconds());
        try {
            SoundPlayer player = getPlayer(uuid);
            player.seekToPlayer(seekTo);
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }
    }

    @Override
    public void getDuration(SoundsPlatformApi.GetDuration arg, SoundsPlatformApi.Result<SoundsPlatformApi.DurationResponse> result) {

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

            result.success(response);
        }
        catch (SoundsException e)
        {
            SoundsPlatformApi.DurationResponse  response = new SoundsPlatformApi.DurationResponse();
            response.setSuccess(false);
            response.setErrorCode(e.errorCode);
            response.setError(e.error);
            result.success(response);
        }
    }

    @Override
    public void setVolume(SoundsPlatformApi.SetVolume arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        String uuid = arg.getPlayer().getUuid();
        /// Sounds use a value between 0 and 100
        /// but android expects 0 -1.
        float volume = ((float)arg.getVolume()/ 100);

        try {
            SoundPlayer player = getPlayer(uuid);
            player.setVolume(volume);
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }
    }

    @Override
    public void setPlaybackProgressInterval(SoundsPlatformApi.SetPlaybackProgressInterval arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        String uuid = arg.getPlayer().getUuid();
        Duration interval = Duration.ofMillis(arg.getInterval());

        try {
            SoundPlayer player = getPlayer(uuid);
            player.setProgressInterval(interval);
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }
    }

    @Override
    public void requestAudioFocus(SoundsPlatformApi.RequestAudioFocus arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        String uuid = arg.getPlayer().getUuid();
        SoundsPlatformApi.AudioFocusProxy audioFocus = arg.getAudioFocus();

        try {
            SoundPlayer player = getPlayer(uuid);
            player.requestAudioFocus(audioFocus);
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }
    }

    @Override
    public void releaseAudioFocus(SoundsPlatformApi.SoundPlayerProxy arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        String uuid = arg.getUuid();

        try {
            SoundPlayer player = getPlayer(uuid);
            player.releaseAudioFocus();
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }
    }

    @Override
    public void isShadeSupported(SoundsPlatformApi.Result<SoundsPlatformApi.BoolResponse> result) {
            result.success(boolResponse(true));
    }

    @Override
    public void isShadePauseSupported(SoundsPlatformApi.Result<SoundsPlatformApi.BoolResponse> result) {
        result.success(boolResponse(true));

    }

    @Override
    public void isShadeSkipForwardSupported(SoundsPlatformApi.Result<SoundsPlatformApi.BoolResponse> result) {
        result.success(boolResponse(true));

    }

    @Override
    public void isShadeSkipBackwardsSupported(SoundsPlatformApi.Result<SoundsPlatformApi.BoolResponse> result) {
        result.success(boolResponse(true));

    }

    @Override
    public void isBackgroundPlaybackSupported(SoundsPlatformApi.Result<SoundsPlatformApi.BoolResponse> result) {
        result.success(boolResponse(true));

    }


    /******************************************************************************
     *
     * SoundRecorder entry points
     *
     */

    @Override
    public void initializeRecorder(SoundsPlatformApi.SoundRecorderProxy arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        String uuid = arg.getUuid();

        SoundRecorder recorder = new SoundRecorder();
        soundsProxies.put(uuid, recorder);
        recorder.initializeSoundRecorder(arg);

        result.success(success());
    }

    @Override
    public void releaseRecorder(SoundsPlatformApi.SoundRecorderProxy arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        try {
            String uuid = arg.getUuid();
            SoundRecorder recorder = getRecorder(uuid);

            recorder.releaseSoundRecorder();
            soundsProxies.remove(uuid);
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }
    }

    @Override
    public void startRecording(SoundsPlatformApi.StartRecording arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        try {
            String uuid = arg.getRecorder().getUuid();
            SoundRecorder recorder = getRecorder(uuid);
            SoundsPlatformApi.TrackProxy track = arg.getTrack();
            SoundsPlatformApi.AudioSourceProxy audioSource = arg.getAudioSource();
            // we ignore quality on android.
            /// arg.getQuality();

            recorder.startRecorder(audioSource, track);
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }
    }

    @Override
    public void stopRecording(SoundsPlatformApi.SoundRecorderProxy arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        try {
            String uuid = arg.getUuid();
            SoundRecorder recorder = getRecorder(uuid);

            recorder.stopRecorder();
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }
    }

    @Override
    public void pauseRecording(SoundsPlatformApi.SoundRecorderProxy arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        try {
            String uuid = arg.getUuid();
            SoundRecorder recorder = getRecorder(uuid);

            recorder.pauseRecorder();
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }
    }

    @Override
    public void resumeRecording(SoundsPlatformApi.SoundRecorderProxy arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {
        try {
            String uuid = arg.getUuid();
            SoundRecorder recorder = getRecorder(uuid);

            recorder.resumeRecorder();
            result.success(success());
        }
        catch (SoundsException e)
        {
            result.success(e.getResponse());
        }
    }

    @Override
    public void getNativeEncoderFormats(SoundsPlatformApi.MediaFormatProxy arg, SoundsPlatformApi.Result<SoundsPlatformApi.MediaFormatResponse> result) {

        SoundsPlatformApi.MediaFormatResponse response = new SoundsPlatformApi.MediaFormatResponse();
        ArrayList<String> mediaFormatNames = new ArrayList<>();
        mediaFormatNames.add(arg.getAdtsAac());
        mediaFormatNames.add(arg.getMp3());
        mediaFormatNames.add(arg.getPcm());
        mediaFormatNames.add(arg.getOggVorbis());
        mediaFormatNames.add(arg.getOggOpus());

        response.setMediaFormats(mediaFormatNames);


        result.success(response);
    }

    @Override
    public void getNativeDecoderFormats(SoundsPlatformApi.MediaFormatProxy arg, SoundsPlatformApi.Result<SoundsPlatformApi.MediaFormatResponse> result) {
        SoundsPlatformApi.MediaFormatResponse response = new SoundsPlatformApi.MediaFormatResponse();
        ArrayList<String> mediaFormatNames = new ArrayList<>();

        mediaFormatNames.add(arg.getAdtsAac());

        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            mediaFormatNames.add(arg.getOggVorbis());
            mediaFormatNames.add(arg.getOggOpus());
        }

        response.setMediaFormats(mediaFormatNames);
        result.success(response);
    }


    @Override
    public void setRecordingProgressInterval(SoundsPlatformApi.SetRecordingProgressInterval arg, SoundsPlatformApi.Result<SoundsPlatformApi.Response> result) {

        try {
            String uuid = arg.getRecorder().getUuid();
            Duration interval = Duration.ofMillis(arg.getInterval());
            SoundRecorder recorder = getRecorder(uuid);
            recorder.setProgressInterval(interval);
            result.success(success());
        } catch (SoundsException e)
        {
            result.success(e.getResponse());
        }

    }
}
