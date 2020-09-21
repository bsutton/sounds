package com.bsutton.sounds;

import android.Manifest;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.media.AudioManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.RemoteException;
import android.os.SystemClock;
import android.support.v4.media.MediaBrowserCompat;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.MediaControllerCompat;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;
import android.util.Log;

import androidx.annotation.NonNull;
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
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.FlutterEngine;
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
import com.bsutton.sounds.SoundPlayer;
import com.bsutton.sounds.MediaBrowserHelper;
import com.bsutton.sounds.Track;

/**
 * Flutter plugin for the ShadePlayer. provides communication between dart and
 * java.
 */

class ShadePlayerPlugin extends SoundPlayerPlugin implements MethodCallHandler {
	public static MethodChannel channel;
	static Context androidContext;
	static ShadePlayerPlugin ShadePlayerPlugin; // singleton

	public static void attachShadePlayer(Context ctx, BinaryMessenger messenger) {
		assert (soundPlayerPlugin == null);

		ShadePlayerPlugin = new ShadePlayerPlugin();
		assert (slots == null);
		slots = new ArrayList<SoundPlayer>();
		channel = new MethodChannel(messenger, "com.bsutton.sounds.sounds_shade_player");
		channel.setMethodCallHandler(ShadePlayerPlugin);
		androidContext = ctx;

	}

	public static void detachShadePlayer() {
		channel.setMethodCallHandler(null);
		channel = null;
		slots = null;
		soundPlayerPlugin = null;
	}

	void invokeCallback(String methodName, Map dic) {
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
		int slotNo = call.argument("slotNo");
		Log.d(TAG, "onMethodCall called: " + call.method + " for slot: " + slotNo);

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

		ShadePlayer aPlayer = (ShadePlayer) slots.get(slotNo);
		switch (call.method) {
			case "initializeMediaPlayer": {
				assert (slots.get(slotNo) == null);
				aPlayer = new ShadePlayer(slotNo);
				slots.set(slotNo, aPlayer);
				aPlayer.initializeSoundPlayer(call, result);
				Log.d("ShadePlayer", "************* initialize called");
			}
				break;

			case "releaseMediaPlayer": {
				aPlayer.releaseSoundPlayer(call, result);
				Log.d("ShadePlayer", "************* release called");
			}
				break;

			case "startShadePlayer":
				aPlayer.startShadePlayer(call, result);
				break;

			case "stopPlayer":
				aPlayer.stopPlayer(call, result);
				break;
			case "pausePlayer":
				aPlayer.pausePlayer(call, result);
				break;
			case "resumePlayer":
				aPlayer.resumePlayer(call, result);
				break;
			case "seekToPlayer":
				aPlayer.seekToPlayer(call, result);
				break;
			case "setVolume":
				aPlayer.setVolume(call, result);
				break;
			case "setProgressInterval":
				if (call.argument("milli") == null) {
					return;
				}
				aPlayer.setProgressInterval(call, result);
				break;

			default:
				super.onMethodCall(call, result);
				break;
		}
	}

}
