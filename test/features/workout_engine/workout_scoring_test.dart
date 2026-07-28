import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/motion/models/body_posture.dart';
import 'package:gerakin/features/motion/models/motion_analysis.dart';
import 'package:gerakin/features/motion/models/motion_validation.dart';
import 'package:gerakin/features/motion/models/movement_state.dart';
import 'package:gerakin/features/workout_engine/services/workout_scoring.dart';

void main() {
  group('WorkoutScoring Tests', () {
    late WorkoutScoring scoring;

    setUp(() {
      scoring = WorkoutScoring();
    });

    test('Inisialisasi skor awal 100', () {
      expect(scoring.currentScore, equals(100.0));
    });

    test('Frame sempurna memberikan skor 100', () {
      final analysis = _createAnalysis(
        status: MotionValidationStatus.valid,
        isSymmetric: true,
      );

      final score = scoring.processFrameScore(analysis);
      expect(score, equals(100.0));
    });

    test('Frame dengan kesalahan penalti mengurangi skor secara kumulatif', () {
      // Frame 1: Sempurna (100)
      scoring.processFrameScore(_createAnalysis(
        status: MotionValidationStatus.valid,
        isSymmetric: true,
      ));

      // Frame 2: Terlalu cepat (-15) + Asimetris (-10) = 75
      final score2 = scoring.processFrameScore(_createAnalysis(
        status: MotionValidationStatus.tooFast,
        isSymmetric: false,
      ));

      // Rata-rata: (100 + 75) / 2 = 87.5
      expect(score2, equals(87.5));
    });
  });
}

MotionAnalysis _createAnalysis({
  required MotionValidationStatus status,
  required bool isSymmetric,
}) {
  return MotionAnalysis(
    jointAngles: const {},
    posture: BodyPosture(
      shoulderSymmetryDiff: isSymmetric ? 0 : 12.0,
      isShoulderSymmetric: isSymmetric,
      torsoOrientation: TorsoOrientation.upright,
      armPosition: ArmPosition.lowered,
      leaningDirection: LeaningDirection.neutral,
    ),
    movementState: MovementState.movingUp,
    validationStatus: status,
    timestamp: DateTime.now(),
  );
}
