import 'dart:async';

import 'package:completer_ex/completer_ex.dart';
import 'package:sounds/sounds.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:e2e/e2e.dart';

void main() {
  // E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can get battery level', (tester) async {
    final player = SoundPlayer.noUI();
    expect(player, equals(isNotNull));

    var released = false;
    final finished = CompleterEx<bool>();

    player.onStopped = ({wasUser = false}) => finished.complete(true);
    Future.delayed(const Duration(seconds: 10), () => finished.complete(false));

    await player.play(Track.fromFile('assets/sample.acc',
        mediaFormat: WellKnownMediaFormats.adtsAac));

    await finished.future.then<bool>((release) => released = release);

    await finished.future;

    expect(released, true);
  });
}
