import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/motion/models/body_posture.dart';
import 'package:gerakin/features/motion/models/joint_angle.dart';
import 'package:gerakin/features/motion/models/motion_analysis.dart';
import 'package:gerakin/features/motion/models/motion_validation.dart';
import 'package:gerakin/features/motion/models/movement_state.dart';
import 'package:gerakin/features/workout_engine/data/exercise_library.dart';
import 'package:gerakin/features/workout_engine/domain/workout_controller.dart';
import 'package:gerakin/features/workout_engine/models/workout_state.dart';

void main() {
  group('Workout State Machine Tests', () {
    late ProviderContainer container;
    late WorkoutController controller;

    setUp(() {
      container = ProviderContainer();
      controller = container.read(workoutControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('Inisialisasi awal berada pada state idle', () {
      expect(controller.currentSession.currentState, equals(WorkoutState.idle));
    });

    test('startWorkout mengubah state menjadi ready', () {
      controller.startWorkout(ExerciseLibrary.armRaise);
      expect(controller.currentSession.currentState, equals(WorkoutState.ready));
    });

    test('Transisi ready -> moving saat posisi awal tercapai', () {
      controller.startWorkout(ExerciseLibrary.armRaise); // startAngle: 25.0

      final analysis = MotionAnalysis(
        jointAngles: const {
          JointType.leftShoulder: JointAngle(
            type: JointType.leftShoulder,
            angle: 25.0, // Tepat di startAngle
            confidence: 0.9,
          ),
        },
        posture: const BodyPosture(
          shoulderSymmetryDiff: 0,
          isShoulderSymmetric: true,
          torsoOrientation: TorsoOrientation.upright,
          armPosition: ArmPosition.lowered,
          leaningDirection: LeaningDirection.neutral,
        ),
        movementState: MovementState.static,
        validationStatus: MotionValidationStatus.valid,
        timestamp: DateTime.now(),
      );

      controller.processMotion(analysis);

      expect(controller.currentSession.currentState, equals(WorkoutState.moving));
    });

    test('Transisi moving -> hold saat puncak target angle (160°) tercapai', () {
      controller.startWorkout(ExerciseLibrary.armRaise);

      // Frame 1: Ready -> Moving
      controller.processMotion(_createAnalysis(25.0));
      expect(controller.currentSession.currentState, equals(WorkoutState.moving));

      // Frame 2: Reaches target 160°
      controller.processMotion(_createAnalysis(160.0));
      expect(controller.currentSession.currentState, equals(WorkoutState.hold));
    });
  });
}

MotionAnalysis _createAnalysis(double shoulderAngle) {
  return MotionAnalysis(
    jointAngles: {
      JointType.leftShoulder: JointAngle(
        type: JointType.leftShoulder,
        angle: shoulderAngle,
        confidence: 0.9,
      ),
    },
    posture: const BodyPosture(
      shoulderSymmetryDiff: 0,
      isShoulderSymmetric: true,
      torsoOrientation: TorsoOrientation.upright,
      armPosition: ArmPosition.lowered,
      leaningDirection: LeaningDirection.neutral,
    ),
    movementState: MovementState.movingUp,
    validationStatus: MotionValidationStatus.valid,
    timestamp: DateTime.now(),
  );
}
