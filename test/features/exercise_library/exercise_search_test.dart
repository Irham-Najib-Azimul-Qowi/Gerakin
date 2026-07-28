import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/exercise_library/models/exercise_target_angles.dart';
import 'package:gerakin/features/exercise_library/models/full_exercise_definition.dart';
import 'package:gerakin/features/exercise_library/services/exercise_search.dart';
import 'package:gerakin/features/motion/models/joint_angle.dart';

void main() {
  group('ExerciseSearch Tests', () {
    late ExerciseSearch searchService;

    setUp(() {
      searchService = const ExerciseSearch();
    });

    test('Mencari latihan berdasarkan kata kunci nama atau tag', () {
      final list = [
        _createMockExercise('arm_raise', 'Arm Raise', ['shoulder']),
        _createMockExercise('bicep_curl', 'Bicep Curl', ['arm', 'biceps']),
      ];

      final result = searchService.search(exercises: list, query: 'bicep');

      expect(result.length, equals(1));
      expect(result.first.id, equals('bicep_curl'));
    });
  });
}

FullExerciseDefinition _createMockExercise(
    String id, String name, List<String> tags) {
  return FullExerciseDefinition(
    id: id,
    name: name,
    category: 'Strength',
    difficulty: 2,
    description: 'Desc $name',
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
    tags: tags,
    thumbnailAsset: 'thumb.png',
    animationAsset: 'anim.json',
  );
}
