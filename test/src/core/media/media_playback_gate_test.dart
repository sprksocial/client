import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/media/media_playback_gate.dart';
import 'package:spark/src/core/media/media_playback_suspension_provider.dart';

void main() {
  testWidgets('combines active state, suspension, and app focus', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    Future<void> pumpGate({required bool isActive}) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaPlaybackGate(
              isActive: isActive,
              builder: (context, shouldPlay) {
                return Text(shouldPlay ? 'playing' : 'paused');
              },
            ),
          ),
        ),
      );
      await tester.pump();
    }

    await pumpGate(isActive: true);
    expect(find.text('playing'), findsOneWidget);

    final suspension = suspendMediaPlayback(container);
    await tester.pump();
    expect(find.text('paused'), findsOneWidget);

    suspension.release();
    await tester.pump();
    expect(find.text('playing'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(find.text('paused'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('playing'), findsOneWidget);

    await pumpGate(isActive: false);
    expect(find.text('paused'), findsOneWidget);
  });
}
