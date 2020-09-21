package com.bsutton.sounds;

import java.util.concurrent.CountDownLatch;

/*
 * This file is part of Sounds (Sounds).
 *
 *   Sounds (Sounds) is free software: you can redistribute it and/or modify
 *   it under the terms of the Lesser GNU General Public License
 *   version 3 (LGPL3) as published by the Free Software Foundation.
 *
 *   Sounds (Sounds) is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the Lesser GNU General Public License
 *   along with Sounds (Sounds).  If not, see <https://www.gnu.org/licenses/>.
 */

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry.Registrar;

// this enum MUST be synchronized with lib/sounds.dart and ios/Classes/SoundsPlugin.h
enum t_CODEC {
	DEFAULT, AAC, OPUS, CODEC_CAF_OPUS // Apple encapsulates its bits in its own special envelope : .caf instead of a
										// regular ogg/opus (.opus). This is completely stupid, this is Apple.
	, MP3, VORBIS, PCM
}

public class Sounds implements FlutterPlugin, ActivityAware {
	public static final boolean FULL_FLAVOR = true;

	private static Sounds instance;
	private Object initializationLock = new Object();

	private Context ctx;
	private Activity androidActivity;

	public static Sounds instance() {
		return instance;
	}

	public Context context() {
		return ctx;
	}

	public Activity androidActivity() {
		return androidActivity;
	}

	/// latch to control access until we have been full initialised.
	/// This class supports v1 and v2 of the flutter embedding so there
	/// are two ways we can be initialised.
	/// Both paths drop the latch.
	static CountDownLatch initialised = new CountDownLatch(1);

	/**
	 * v2 Plugin Sounds.
	 * 
	 * Only called on new systems
	 * 
	 * see:
	 * https://flutter.dev/docs/development/packages-and-plugins/plugin-api-migration
	 */
	@Override
	public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
		onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
	}

	public void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
		synchronized (initializationLock) {
			if (SoundPlayerPlugin.channel != null) {
				// already attached to a FlutterEngine
				return;
			}

			ctx = applicationContext;
			SoundPlayerPlugin.attachSoundPlayer(applicationContext, messenger);
			SoundRecorderPlugin.attachSoundRecorder(applicationContext, messenger);
			ShadePlayerPlugin.attachShadePlayer(applicationContext, messenger);
		}
	}

	/**
	 * v1 Plugin Sounds.
	 * 
	 * Only called on older systems.
	 */
	public static void registerWith(Registrar registrar) {
		if (instance == null) {
			instance = new Sounds();
		}
		instance.onAttachedToEngine(registrar.context(), registrar.messenger());
		/// We are fully initialised for v1 embedding
		initialised.countDown();

	}

	@Override
	public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
		SoundPlayerPlugin.detachSoundPlayer();
		SoundRecorderPlugin.detachSoundRecorder();
		ShadePlayerPlugin.detachShadePlayer();

		instance.ctx = null;
		instance.androidActivity = null;
		instance = null;
	}

	@Override
	public void onDetachedFromActivity() {
	}

	@Override
	public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

	}

	@Override
	public void onDetachedFromActivityForConfigChanges() {

	}

	@Override
	public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
		androidActivity = binding.getActivity();

		/// We are fully initialised for v2 embedding
		initialised.countDown();
	}
}
