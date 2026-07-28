import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/feedback/models/feedback_message.dart';
import 'package:gerakin/features/feedback/models/feedback_priority.dart';
import 'package:gerakin/features/feedback/models/feedback_rule.dart';
import 'package:gerakin/features/feedback/models/feedback_type.dart';
import 'package:gerakin/features/feedback/services/feedback_rule_engine.dart';
import 'package:gerakin/features/motion/models/body_posture.dart';
import 'package:gerakin/features/motion/models/motion_analysis.dart';
import 'package:gerakin/features/motion/models/motion_validation.dart';
import 'package:gerakin/features/motion/models/movement_state.dart';
import 'package:gerakin/features/workout_engine/data/exercise_library.dart';
import 'package:gerakin/features/workout_engine/models/workout_session.dart';

void main() {
  group('FeedbackRuleEngine Tests', () {
    late FeedbackRuleEngine ruleEngine;

    setUp(() {
      ruleEngine = FeedbackRuleEngine();
    });

    test('Memicu Out of Range Rule saat validationStatus outOfRange', () {
      final motion = _createMotion(status: MotionValidationStatus.outOfRange);
      final session = WorkoutSession.initial(ExerciseLibrary.armRaise);

      final messages = ruleEngine.evaluate(motion: motion, session: session);

      expect(messages, isNotEmpty);
      expect(messages.any((m) => m.id == 'out_of_range'), isTrue);
    });

    test('Dapat menyeleksi aturan kustom secara dinamis tanpa mengubah kode inti', () {
      ruleEngine.registerRule(
        FeedbackRule(
          id: 'custom_rule',
          priority: FeedbackPriority.critical,
          condition: (m, s) => true,
          builder: (m, s) => FeedbackMessage(
            id: 'custom_rule',
            type: FeedbackType.warning,
            priority: FeedbackPriority.critical,
            text: 'Custom Rule Triggered',
            timestamp: DateTime.now(),
          ),
        ),
      );

      final motion = _createMotion(status: MotionValidationStatus.valid);
      final session = WorkoutSession.initial(ExerciseLibrary.armRaise);

      final messages = ruleEngine.evaluate(motion: motion, session: session);

      expect(messages.any((m) => m.id == 'custom_rule'), isTrue);
    });
  });
}

MotionAnalysis _createMotion({required MotionValidationStatus status}) {
  return MotionAnalysis(
    jointAngles: const {},
    posture: const BodyPosture(
      shoulderSymmetryDiff: 0,
      isShoulderSymmetric: true,
      torsoOrientation: TorsoOrientation.upright,
      armPosition: ArmPosition.lowered,
      leaningDirection: LeaningDirection.neutral,
    ),
    movementState: MovementState.movingUp,
    validationStatus: status,
    timestamp: DateTime.now(),
  );
}
