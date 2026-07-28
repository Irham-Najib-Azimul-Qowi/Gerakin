import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/adaptive/models/fatigue_status.dart';
import 'package:gerakin/features/adaptive/services/fatigue_detection_engine.dart';
import 'package:gerakin/features/motion/models/body_posture.dart';
import 'package:gerakin/features/motion/models/motion_analysis.dart';
import 'package:gerakin/features/motion/models/motion_validation.dart';
import 'package:gerakin/features/motion/models/movement_state.dart';

void main() {
  group('Fatigue Detection Engine Tests', () {
    late FatigueDetectionEngine fatigueEngine;

    setUp(() {
      fatigueEngine = FatigueDetectionEngine();
    });

    test('Status awal terdeteksi fresh tanpa kelelahan', () {
      final status = FatigueStatus.fresh();

      expect(status.level, equals(FatigueLevel.none));
      expect(status.fatigueScore, equals(0.0));
      expect(status.recommendRest, isFalse);
    });

    test('Akumulasi frame lambat dan miring meningkatkan fatigueScore dan rekomendasi istirahat', () {
      final motionFault = MotionAnalysis(
        jointAngles: const {},
        posture: const BodyPosture(
          shoulderSymmetryDiff: 20,
          isShoulderSymmetric: false,
          torsoOrientation: TorsoOrientation.upright,
          armPosition: ArmPosition.lowered,
          leaningDirection: LeaningDirection.neutral,
        ),
        movementState: MovementState.movingUp,
        validationStatus: MotionValidationStatus.tooSlow,
        timestamp: DateTime.now(),
      );

      // Simulasikan 10 frame buruk beruntun
      late FatigueStatus status;
      for (int i = 0; i < 10; i++) {
        status = fatigueEngine.processFrame(analysis: motionFault);
      }

      expect(status.fatigueScore, greaterThan(50.0));
      expect(status.recommendRest, isTrue);
    });
  });
}
