import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/core/theme/app_colors.dart';
import 'package:gerakin/features/feedback/domain/feedback_engine.dart';
import 'package:gerakin/features/motion/models/body_posture.dart';
import 'package:gerakin/features/motion/models/motion_analysis.dart';
import 'package:gerakin/features/motion/models/motion_validation.dart';
import 'package:gerakin/features/motion/models/movement_state.dart';
import 'package:gerakin/features/workout_engine/data/exercise_library.dart';
import 'package:gerakin/features/workout_engine/models/workout_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feedback Generation Pipeline Tests', () {
    late ProviderContainer container;
    late FeedbackEngine feedbackEngine;

    setUp(() {
      container = ProviderContainer();
      feedbackEngine = container.read(feedbackEngineProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('Memproses frame outOfRange menghasilkan warna skeleton error', () async {
      final motion = MotionAnalysis(
        jointAngles: const {},
        posture: const BodyPosture(
          shoulderSymmetryDiff: 0,
          isShoulderSymmetric: true,
          torsoOrientation: TorsoOrientation.upright,
          armPosition: ArmPosition.lowered,
          leaningDirection: LeaningDirection.neutral,
        ),
        movementState: MovementState.static,
        validationStatus: MotionValidationStatus.outOfRange,
        timestamp: DateTime.now(),
      );

      final session = WorkoutSession.initial(ExerciseLibrary.armRaise);

      final result = await feedbackEngine.processFrame(
        motion: motion,
        session: session,
      );

      expect(result.skeletonColor, equals(AppColors.error));
      expect(result.primaryMessage, isNotNull);
      expect(result.primaryMessage!.id, equals('out_of_range'));
    });
  });
}
