import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/workout_engine/data/exercise_library.dart';
import 'package:gerakin/features/workout_engine/domain/workout_controller.dart';
import 'package:gerakin/features/workout_engine/models/workout_state.dart';

void main() {
  group('Workout Completion & Result Tests', () {
    late ProviderContainer container;
    late WorkoutController controller;

    setUp(() {
      container = ProviderContainer();
      controller = container.read(workoutControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('finishWorkout menghasilkan WorkoutResult yang valid dan state completed', () {
      controller.startWorkout(ExerciseLibrary.armRaise);

      final result = controller.finishWorkout();

      expect(controller.currentSession.currentState, equals(WorkoutState.completed));
      expect(result.exerciseId, equals('arm_raise'));
      expect(result.exerciseName, equals('Arm Raise'));
      expect(result.finalScore, isNotNull);
      expect(result.completedAt, isNotNull);
    });
  });
}
