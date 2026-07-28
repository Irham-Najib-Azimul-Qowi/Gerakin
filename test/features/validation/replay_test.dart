import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/validation/services/session_recorder.dart';
import 'package:gerakin/features/validation/services/session_replay.dart';

void main() {
  group('Session Recording & Replay Tests', () {
    late SessionRecorder recorder;
    late SessionReplay replay;

    setUp(() {
      recorder = SessionRecorder();
      replay = SessionReplay();
    });

    test('Merekam 2 frame, mengekspor JSON, dan memutar ulang (replay) tanpa kamera', () {
      recorder.startRecording('arm_raise');

      recorder.recordFrame(
        shoulderAngle: 25.0,
        elbowAngle: 90.0,
        confidence: 0.9,
        validationStatus: 'moving',
      );

      recorder.recordFrame(
        shoulderAngle: 160.0,
        elbowAngle: 170.0,
        confidence: 0.95,
        validationStatus: 'hold',
      );

      final session = recorder.stopRecording();

      expect(session, isNotNull);
      expect(session!.frames.length, equals(2));

      final jsonString = recorder.exportToJson(session);
      expect(jsonString, isNotEmpty);

      // Replay tanpa kamera
      replay.loadSessionFromJson(jsonString);
      replay.startReplay();

      final frame1 = replay.nextFrame();
      expect(frame1, isNotNull);
      expect(frame1!.shoulderAngle, equals(25.0));

      final frame2 = replay.nextFrame();
      expect(frame2, isNotNull);
      expect(frame2!.shoulderAngle, equals(160.0));

      final frameEnd = replay.nextFrame();
      expect(frameEnd, isNull);
    });
  });
}
