/*
 * This file is part of Sounds.
 *
 *   Sounds is free software: you can redistribute it and/or modify
 *   it under the terms of the Lesser GNU General Public License
 *   version 3 (LGPL3) as published by the Free Software Foundation.
 *
 *   Sounds is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the Lesser GNU General Public License
 *   along with Sounds.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/widgets.dart';
import 'package:sounds_common/sounds_common.dart';

/// provides a set of common methods used by
/// PluginInterfaces to talk to the underlying
/// Platform specific plugin.
///
/// Each derived Plugin is a singleton via which
/// Players and Recorders register to talk
/// to the OS dependant plugins.
// ignore: prefer_mixin
class AppLifeCycleObserver with WidgetsBindingObserver {
  ///
  AppLifeCycleObserver() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Must be called when no longer required.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onSystemAppResumed();
        break;
      case AppLifecycleState.inactive:
        Log.d('Ignoring: $state');
        break;
      case AppLifecycleState.paused:
        onSystemAppPaused();
        break;
      case AppLifecycleState.detached:
        Log.d('Ignoring: $state');
        break;
    }
  }

  /// Overload this method to receive notifications when the app is paused.
  Function onSystemAppPaused;

  /// Overload this method to receive notifications when the app is resumed.
  Function onSystemAppResumed;
}
