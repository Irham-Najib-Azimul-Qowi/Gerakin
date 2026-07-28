import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/adaptive/services/safety_engine.dart';
import 'package:gerakin/features/motion/models/body_posture.dart';
import 'package:gerakin/features/motion/models/motion_analysis.dart';
import 'package:gerakin/features/motion/models/motion_validation.dart';
import 'package:gerakin/features/motion/models/movement_state.dart';

void main() {
  group('Safety Engine Tests', () {
    late SafetyEngine safetyEngine;

    setUp(() {
      safetyEngine = const SafetyEngine();
    });

    test('Skor keselamatan optimal 100% untuk gerakan valid', () {
      final motion = _createMotion(
        status: MotionValidationStatus.valid,
        isSymmetric: true,
      );

      final status = safetyEngine.evaluateSafety(motion);

      expect(status.safetyScore, equals(100.0));
      expect(status.isSafe, isTrue);
      expect(status.shouldStopWorkout, isFalse);
    });

    test('Skor keselamatan anjlok dan menghentikan latihan saat outOfRange', () {
      final motion = _createMotion(
        status: MotionValidationStatus.outOfRange,
        isSymmetric: false,
      );

      final status = safetyEngine.evaluateSafety(motion);

      expect(status.safetyScore, lessThan(60.0));
      expect(status.shouldStopWorkout, isTrue);
      expect(status.activeWarnings, isNotEmpty);
    });
  });
}

MotionAnalysis _createMotion({
  required MotionValidationStatus status,
  required bool isSymmetric,
}) {
  return MotionAnalysis(
    jointAngles: const {},
    posture: BodyPosture(
      shoulderSymmetryDiff: isSymmetric ? 0 : 25,
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
