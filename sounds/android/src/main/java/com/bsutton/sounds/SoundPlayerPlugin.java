package com.bsutton.sounds;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.media.AudioManager;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.SystemClock;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.PlaybackStateCompat;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.UiThread;
import androidx.arch.core.util.Function;
import androidx.core.app.ActivityCompat;

import android.media.AudioFocusRequest;

import java.io.*;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.concurrent.Callable;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

class SoundPlayerPlugin implements MethodCallHandler {
	final static String TAG = "SoundPlayerPlugin";
	public static MethodChannel channel;
	public static List<SoundPlayer> slots;
	static Context androidContext;
	static SoundPlayerPlugin soundPlayerPlugin; // singleton

	public static void attachSoundPlayer(Context ctx, BinaryMessenger messenger) {
		assert (soundPlayerPlugin == null);
		soundPlayerPlugin = new SoundPlayerPlugin();
		assert (slots == null);
		slots = new ArrayList<SoundPlayer>();
		channel = new MethodChannel(messenger, "com.bsutton.sounds.sound_player");
		channel.setMethodCallHandler(soundPlayerPlugin);
		androidContext = ctx;

	}

	void invokeCallback(String methodName, Map dic) {
		Log.d(TAG, "SoundPlayer: invokeCallback " + methodName);
		channel.invokeMethod(methodName, dic);
	}

	void freeSlot(int slotNo) {
		slots.set(slotNo, null);
	}

	SoundPlayerPlugin getManager() {
		return soundPlayerPlugin;
	}

	@Override
	public void onMethodCall(final MethodCall call, final Result result) {
		try {
			int slotNo = call.argument("slotNo");

			// The dart code supports lazy initialization of players.
			// This means that players can be registered (and slots allocated)
			// on the client side in a different order to which the players
			// are initialised.
			// As such we need to grow the slot array upto the
			// requested slot no. even if we haven't seen initialisation
			// for the lower numbered slots.
			while (slotNo >= slots.size()) {
				slots.add(null);
			}

			SoundPlayer aPlayer = slots.get(slotNo);
			switch (call.method) {
				case "initializeMediaPlayer": {
					assert (slots.get(slotNo) == null);
					aPlayer = new SoundPlayer(slotNo);
					slots.set(slotNo, aPlayer);
					aPlayer.initializeSoundPlayer(call, result);

				}
					break;

				case "releaseMediaPlayer": {
					aPlayer.releaseSoundPlayer(call, result);
					Log.d("SoundPlayer", "************* release called");
					slots.set(slotNo, null);
				}
					break;

				case "getDuration":
					getDuration(slotNo, call, result);
					break;

				case "startPlayer": {
					aPlayer.startPlayer(call, result);
				}
					break;

				case "stopPlayer": {
					aPlayer.stopPlayer(call, result);
				}
					break;

				case "pausePlayer": {
					aPlayer.pausePlayer(call, result);
				}
					break;

				case "resumePlayer": {
					aPlayer.resumePlayer(call, result);
				}
					break;

				case "seekToPlayer": {
					aPlayer.seekToPlayer(call, result);
				}
					break;

				case "setVolume": {
					aPlayer.setVolume(call, result);
				}
					break;

				case "setProgressInterval": {
					aPlayer.setProgressInterval(call, result);
				}
					break;

				case "androidAudioFocusRequest": {
					aPlayer.androidAudioFocusRequest(call, result);
				}
					break;

				case "setActive": {
					aPlayer.setActive(call, result);
				}
					break;

				default: {
					result.notImplemented();
				}
					break;
			}
		} catch (Throwable e) {
			Log.e(TAG, "Error in onMethodCall " + call.method, e);
			throw e;
		}

	}

	void invokeCallbackWithString(int slotNo, String methodName, String arg) {
		Map<String, Object> dic = new HashMap<String, Object>();
		dic.put("slotNo", slotNo);
		dic.put("arg", arg);
		invokeCallback(methodName, dic);
	}

	void invokeCallbackWithDouble(int slotNo, String methodName, double arg) {
		Map<String, Object> dic = new HashMap<String, Object>();
		dic.put("slotNo", slotNo);
		dic.put("arg", arg);
		invokeCallback(methodName, dic);
	}

	void sendError(int slotNo, String description, int what, int extra, String callbackUuid) {
		try {
			JSONObject json = new JSONObject();
			json.put("description", description);
			json.put("android_what", what);
			json.put("android_extra", extra);
			if (callbackUuid != null) {
				json.put("callbackUuid", callbackUuid);
			}
			invokeCallbackWithString(slotNo, "onError", json.toString());
		} catch (JSONException e) {
			Log.e(TAG, "Error encoding json message for onError: what=" + what + " extra=" + extra);
		}
	}

	void getDuration(int slotNo, final MethodCall call, final Result result) {
		/// let the dart code resume whilst we get the results.
		result.success("queued");

		String callbackUuid = "Not supplied";
		try {
			final String path = call.argument("path");
			/// used so we can handle multiple calls in parallel.
			callbackUuid = call.argument("callbackUuid");

			Uri uri = Uri.parse(path);
			MediaMetadataRetriever mmr = new MediaMetadataRetriever();
			mmr.setDataSource(androidContext, uri);
			String durationStr = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
			int milliSeconds = Integer.parseInt(durationStr);

			Map<String, Object> args = new HashMap<String, Object>();
			args.put("callbackUuid", callbackUuid);
			args.put("milliseconds", milliSeconds);

			Map<String, Object> dic = new HashMap<String, Object>();
			dic.put("slotNo", slotNo);
			dic.put("arg", args);
			invokeCallback("durationResults", dic);
		} catch (Throwable e) {
			sendError(slotNo, e.getMessage(), 0, 0, callbackUuid);
		}

	}

}