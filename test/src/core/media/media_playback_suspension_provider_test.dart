import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/media/media_playback_suspension_provider.dart';

void main() {
  test('tracks nested media playback suspensions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(mediaPlaybackSuspendedProvider), isFalse);

    final firstSuspension = suspendMediaPlayback(container);
    expect(container.read(mediaPlaybackSuspendedProvider), isTrue);

    final secondSuspension = suspendMediaPlayback(container);
    firstSuspension.release();
    firstSuspension.release();
    expect(container.read(mediaPlaybackSuspendedProvider), isTrue);

    secondSuspension.release();
    expect(container.read(mediaPlaybackSuspendedProvider), isFalse);
  });

  test('release is idempotent', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final suspension = suspendMediaPlayback(container);
    suspension.release();
    suspension.release();

    expect(container.read(mediaPlaybackSuspendedProvider), isFalse);
  });
}
