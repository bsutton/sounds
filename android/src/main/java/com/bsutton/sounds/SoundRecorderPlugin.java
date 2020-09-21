package com.bsutton.sounds;

import android.content.Context;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.SystemClock;
import android.util.Log;

import androidx.annotation.UiThread;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

class SoundRecorderPlugin implements MethodCallHandler {
	public static final String CHANNEL_NAME = "com.bsutton.sounds.sound_recorder";
	private static MethodChannel channel;
	public static List<SoundRecorder> slots;

	static Context androidContext;
	static SoundRecorderPlugin soundRecorderPlugin; // singleton

	static final String TAG = "SoundRecorder";
	static final String ERR_UNKNOWN = "ERR_UNKNOWN";
	static final String ERR_RECORDER_IS_NULL = "ERR_RECORDER_IS_NULL";
	static final String ERR_RECORDER_IS_RECORDING = "ERR_RECORDER_IS_RECORDING";

	public static void attachSoundRecorder(Context ctx, BinaryMessenger messenger) {
		assert (soundRecorderPlugin == null);
		soundRecorderPlugin = new SoundRecorderPlugin();
		assert (slots == null);
		slots = new ArrayList<SoundRecorder>();
		channel = new MethodChannel(messenger, CHANNEL_NAME);
		channel.setMethodCallHandler(soundRecorderPlugin);
		Log.d(TAG, "Registering channel: " + CHANNEL_NAME);
		androidContext = ctx;
	}

	public static void detachSoundRecorder() {
		channel.setMethodCallHandler(null);
		channel = null;
		slots = null;
		soundRecorderPlugin = null;
	}

	void invokeCallback(String methodName, Map dic) {
		// Log.d(TAG, "calling dart " + methodName + dic.toString());
		channel.invokeMethod(methodName, dic);
		// Log.d(TAG, "invokeCallback succeeded");
	}

	void freeSlot(int slotNo) {
		slots.set(slotNo, null);
	}

	SoundRecorderPlugin getManager() {
		return soundRecorderPlugin;
	}

	@Override
	public void onMethodCall(final MethodCall call, final Result result) {
		int slotNo = call.argument("slotNo");

		// The dart code supports lazy initialization of the recorder.
		// This means that recorders can be registered (and slots allocated)
		// on the client side in a different order to which the recorders
		// are initialised.
		// As such we need to grow the slot array upto the
		// requested slot no. even if we haven't seen initialisation
		// for the lower numbered slots.
		while (slotNo >= slots.size()) {
			slots.add(null);
		}

		SoundRecorder aRecorder = slots.get(slotNo);
		switch (call.method) {
			case "initializeSoundRecorder": {
				assert (slots.get(slotNo) == null);
				aRecorder = new SoundRecorder(slotNo);
				slots.set(slotNo, aRecorder);
				aRecorder.initializeSoundRecorder(call, result);
			}
				break;

			case "releaseSoundRecorder": {
				aRecorder.releaseSoundRecorder(call, result);
				slots.set(slotNo, null);
			}
				break;

			case "startRecorder": {
				aRecorder.startRecorder(call, result);

			}
				break;

			case "stopRecorder": {
				aRecorder.stopRecorder(call, result);
			}
				break;

			case "setProgressInterval": {
				aRecorder.setProgressInterval(call, result);
			}
				break;

			case "pauseRecorder": {
				aRecorder.pauseRecorder(call, result);
			}
				break;

			case "resumeRecorder": {
				aRecorder.resumeRecorder(call, result);
			}
				break;

			default: {
				result.notImplemented();
			}
				break;
		}
	}

}
