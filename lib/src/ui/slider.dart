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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sounds_common/sounds_common.dart';

///
class PlaybarSlider extends StatefulWidget {
  ///
  const PlaybarSlider(this.stream, this._seek, {Key? key}) : super(key: key);

  final void Function(Duration position) _seek;

  ///
  final Stream<PlaybackDisposition> stream;

  @override
  State<StatefulWidget> createState() => PlaybarSliderState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<Stream<PlaybackDisposition>>('stream', stream));
  }
}

///
class PlaybarSliderState extends State<PlaybarSlider> {
  @override
  Widget build(BuildContext context) => SliderTheme(
      data: SliderTheme.of(context).copyWith(
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          inactiveTrackColor: Colors.blueGrey),
      child: StreamBuilder<PlaybackDisposition>(
          stream: widget.stream,
          initialData: PlaybackDisposition.zero(),
          builder: (context, snapshot) {
            var duration = Duration.zero;
            var position = Duration.zero;
            if (snapshot.hasData) {
              final disposition = snapshot.data;
              duration = disposition!.duration;
              position = disposition.position;
            }
            return Slider(
              max: duration.inMilliseconds.toDouble(),
              value: position.inMilliseconds.toDouble(),
              onChanged: (value) =>
                  widget._seek(Duration(milliseconds: value.toInt())),
            );
          }));
}
