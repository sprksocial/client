import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/media_processing/video/pro_video_processing_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('pro_video_editor');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('extracts and merges normalized waveform channels', () async {
    MethodCall? receivedCall;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          receivedCall = call;
          return {
            'leftChannel': [0.2, -0.8, 0.4],
            'rightChannel': [-0.9, 0.1, 0.3, 0.6],
            'sampleRate': 48000,
            'duration': 1000,
            'samplesPerSecond': 50,
          };
        });

    final samples = await const ProVideoProcessingService()
        .extractWaveformFromPath('/tmp/test-audio.mp3');

    expect(receivedCall?.method, 'getWaveform');
    expect(
      receivedCall?.arguments,
      containsPair('inputPath', '/tmp/test-audio.mp3'),
    );
    expect(receivedCall?.arguments, containsPair('extension', 'mpeg'));
    expect(receivedCall?.arguments, containsPair('samplesPerSecond', 50));
    expect(samples, [
      1.0,
      closeTo(8 / 9, 0.0001),
      closeTo(4 / 9, 0.0001),
      closeTo(2 / 3, 0.0001),
    ]);
  });
}
