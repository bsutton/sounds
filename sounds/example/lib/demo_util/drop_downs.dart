import 'package:flutter/material.dart';
import 'package:sounds/sounds.dart';
import 'package:sounds_common/sounds_common.dart';

import 'demo_active_codec.dart';
import 'demo_common.dart';
import 'demo_media_path.dart';

/// Widget containing the set of drop downs used in the UI
/// Media
/// MediaFormat
class Dropdowns extends StatefulWidget {
  final void Function(MediaFormat) _onMediaFormatChanged;

  /// ctor
  const Dropdowns({
    Key key,
    @required void Function(MediaFormat) onCodecChanged,
  })  : _onMediaFormatChanged = onCodecChanged,
        super(key: key);

  @override
  _DropdownsState createState() => _DropdownsState();
}

class _DropdownsState extends State<Dropdowns> {
  _DropdownsState();

  @override
  Widget build(BuildContext context) {
    final mediaDropdown = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Text('Record To:'),
        ),
        buildMediaDropdown(),
      ],
    );

    final codecDropdown = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Text('MediaFormat:'),
        ),
        buildCodecDropdown(),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          mediaDropdown,
          codecDropdown,
        ],
      ),
    );
  }

  DropdownButton<MediaFormat> buildCodecDropdown() {
    return DropdownButton<MediaFormat>(
      value: ActiveMediaFormat().mediaFormat,
      onChanged: (newCodec) {
        widget._onMediaFormatChanged(newCodec);

        /// this is hacky as we should be passing the actually
        /// useOSUI flag.
        ActiveMediaFormat()
            .setMediaFormat(withShadeUI: false, mediaFormat: newCodec);

        setState(() {
          getDuration(ActiveMediaFormat().mediaFormat);
        });
      },
      items: <DropdownMenuItem<MediaFormat>>[
        DropdownMenuItem<MediaFormat>(
          value: WellKnownMediaFormats.adtsAac,
          child: Text('AAC'),
        ),
        DropdownMenuItem<MediaFormat>(
          value: WellKnownMediaFormats.oggOpus,
          child: Text('OGG/Opus'),
        ),
        DropdownMenuItem<MediaFormat>(
          value: WellKnownMediaFormats.cafOpus,
          child: Text('CAF/Opus'),
        ),
        DropdownMenuItem<MediaFormat>(
          value: WellKnownMediaFormats.mp3,
          child: Text('MP3'),
        ),
        DropdownMenuItem<MediaFormat>(
          value: WellKnownMediaFormats.oggVorbis,
          child: Text('OGG/Vorbis'),
        ),
        DropdownMenuItem<MediaFormat>(
          value: WellKnownMediaFormats.pcm,
          child: Text('PCM'),
        ),
      ],
    );
  }

  DropdownButton<MediaStorage> buildMediaDropdown() {
    return DropdownButton<MediaStorage>(
      value: MediaPath().media,
      onChanged: (newMedia) {
        MediaPath().media = newMedia;

        setState(() {});
      },
      items: <DropdownMenuItem<MediaStorage>>[
        DropdownMenuItem<MediaStorage>(
          value: MediaStorage.file,
          child: Text('File'),
        ),
        DropdownMenuItem<MediaStorage>(
          value: MediaStorage.buffer,
          child: Text('Buffer'),
        ),
      ],
    );
  }
}
