package com.bsutton.sounds;


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

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry.Registrar;


public class SoundsPlugin implements FlutterPlugin, ActivityAware {
    private static final String TAG = "SoundsPlugin";
    public static final boolean FULL_FLAVOR = true;
    static Context ctx;
    static Activity androidActivity;
    static FlutterState flutterState;

    static BinaryMessenger getBinaryMessenger() {
        return flutterState.getBinaryMessenger();
    }

	/**
	 * class that handles calls from flutter and dispatches the
	 * calls into java.
 	 */
    static private FromFlutterDispatcher dispatcher;

    /// latch to control access until we have been full initialised.
    /// This class supports v1 and v2 of the flutter embedding so there
    /// are two ways we can be initialised.
    /// Both paths drop the latch.
    static CountDownLatch initialised = new CountDownLatch(1);

    // Call this method to wait for the plugin to be fully initialised.
    // returns true if the plug succesfully initialised.
    // will return false
    public static boolean await()  {
        boolean success = false;
        try {
            success =  initialised.await(1, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            // NOOP. Will probably never happen and we can't re-throw it anyway
            Log.d(TAG, "Timeout occured waiting for SoundsPlugin to initialise.");
        }
        return  success;
    }


    /******************************************************************************************
     *
     *  Flutter v2 embedding.
     *
     * see:
     * https://flutter.dev/docs/development/packages-and-plugins/plugin-api-migration
     *
     ******************************************************************************************/

    @Override
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
        ctx = binding.getApplicationContext();

		flutterState =
				new FlutterState(
						binding.getApplicationContext(),
						binding.getBinaryMessenger()
				);

		dispatcher = new FromFlutterDispatcher(binding.getApplicationContext());
		flutterState.startListening(dispatcher);
    }


    /**
     * Activity started.
     *
     * @param binding
     */
    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        androidActivity = binding.getActivity();

        /// We are fully initialised for v2 embedding
        initialised.countDown();
    }


    @Override
    public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
        if (flutterState == null) {
            Log.wtf(TAG, "Detached from the engine before registering to it.");
        }

        dispatcher.disposeAll();
        flutterState.stopListening();
        flutterState = null;

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


	/******************************************************************************************
	 *
     *  Flutter v1 embedding.
     *
	 ******************************************************************************************/


	/**
	 * v1 Plugin Sounds.
     * <p>
     * Only called on older systems.
     */
    public static void registerWith(Registrar registrar) {
        ctx = registrar.context();
        androidActivity = registrar.activity();

        Log.d(TAG, "SoundsPlugin() for v1 embedding");
        flutterState =
                new FlutterState(
                        registrar.context(),
                        registrar.messenger()
                );

        dispatcher = new FromFlutterDispatcher(registrar.context());
        flutterState.startListening(dispatcher);

        registrar.addViewDestroyListener(
                view -> {
                    flutterState.stopListening();
                    flutterState = null;
                    return false; // We are not interested in assuming ownership of the NativeView.
                });

        /// We are fully initialised for v1 embedding
        initialised.countDown();
    }





	private static final class FlutterState {
        private final Context applicationContext;
        private final BinaryMessenger binaryMessenger;


        BinaryMessenger getBinaryMessenger() {
            return binaryMessenger;
        }

        FlutterState(
                Context applicationContext,
                BinaryMessenger messenger
                ) {
            this.applicationContext = applicationContext;
            this.binaryMessenger = messenger;
        }

        void startListening(FromFlutterDispatcher dispatcher) {
			SoundsPlatformApi.SoundsToPlatformApi.setup(binaryMessenger, dispatcher);
        }

        void stopListening() {
            dispatcher.onDestroy();
			SoundsPlatformApi.SoundsToPlatformApi.setup(binaryMessenger, null);
			dispatcher = null;
        }
    }
}

