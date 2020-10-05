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

import 'package:sounds_platform_interface/sounds_platform_interface.dart';

/// Used to control the audio quality.
///  Currently it only applies to iOS.
class Quality {
  final int _quality;
  const Quality._internal(this._quality);
  String toString() => '$_quality';

  /// returns the quality which is a bit mask
  /// mapped to a set of static consts (MIN, LOW, ...)
  int get quality => _quality;

  /// minimum quality
  static const min = Quality._internal(0);

  /// low quality
  static const low = Quality._internal(0x20);

  /// medium quality
  static const medium = Quality._internal(0x40);

  /// high quality
  static const high = Quality._internal(0x60);

  /// max available quality.
  static const max = Quality._internal(0x7F);
}

/// Used to generate a QualityProxy to pass
/// a Quality object down to the platform.
class QualityHelper {
  /// Generates a QualityProxy
  static QualityProxy generate(Quality quality) {
    var proxy = QualityProxy();
    proxy.quality = quality.quality;

    /// pass all of the constants down so we don't have
    /// to manually keep them in sync.
    proxy.min = Quality.min._quality;
    proxy.low = Quality.low._quality;
    proxy.medium = Quality.medium._quality;
    proxy.high = Quality.high._quality;
    proxy.max = Quality.max._quality;

    return proxy;
  }
}
