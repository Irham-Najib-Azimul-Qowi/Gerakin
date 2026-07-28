import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/exercise_library/models/exercise_target_angles.dart';
import 'package:gerakin/features/exercise_library/models/full_exercise_definition.dart';
import 'package:gerakin/features/exercise_library/services/exercise_filter.dart';
import 'package:gerakin/features/motion/models/joint_angle.dart';

void main() {
  group('ExerciseFilter Tests', () {
    late ExerciseFilter filterService;

    setUp(() {
      filterService = const ExerciseFilter();
    });

    test('Menyaring latihan berdasarkan kategori Warm Up dan level kesulitan 1', () {
      final list = [
        _createMockExercise('ex1', 'Warm Up', 1),
        _createMockExercise('ex2', 'Strength', 3),
      ];

      final filtered = filterService.filter(
        exercises: list,
        category: 'Warm Up',
        difficultyLevel: 1,
      );

      expect(filtered.length, equals(1));
      expect(filtered.first.id, equals('ex1'));
    });
  });
}

FullExerciseDefinition _createMockExercise(
    String id, String category, int difficulty) {
  return FullExerciseDefinition(
    id: id,
    name: 'Ex $id',
    category: category,
    difficulty: difficulty,
    description: 'Desc',
    benefit: 'Benefit',
    targetMuscles: ['Muscle'],
    requiredEquipment: 'None',
    movementPattern: 'Pattern',
    startPose: 'Start',
    endPose: 'End',
    targetAngles: const ExerciseTargetAngles(
      primaryJoint: JointType.leftShoulder,
      startAngle: 20.0,
      targetAngle: 150.0,
    ),
    tolerance: 10.0,
    tempo: '2-1-2',
    holdDuration: 1,
    repetitionTarget: 10,
    setTarget: 3,
    restDuration: 15,
    estimatedCalories: 20.0,
    voiceInstruction: 'Voice',
    warning: 'Warning',
    contraindication: 'None',
    tags: ['tag'],
    thumbnailAsset: 'thumb.png',
    animationAsset: 'anim.json',
  );
}
