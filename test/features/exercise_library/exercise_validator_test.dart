import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/exercise_library/services/exercise_validator.dart';

void main() {
  group('ExerciseValidator Tests', () {
    late ExerciseValidator validator;

    setUp(() {
      validator = const ExerciseValidator();
    });

    test('Memvalidasi JSON Map lengkap (24 field wajib) -> True', () {
      final validMap = {
        'id': 'ex_1',
        'name': 'Name',
        'category': 'Category',
        'difficulty': 1,
        'description': 'Desc',
        'benefit': 'Benefit',
        'targetMuscles': ['Muscle'],
        'requiredEquipment': 'Equipment',
        'movementPattern': 'Pattern',
        'startPose': 'Start',
        'endPose': 'End',
        'targetAngles': {
          'primaryJoint': 'leftShoulder',
          'startAngle': 10.0,
          'targetAngle': 140.0,
        },
        'tolerance': 10.0,
        'tempo': '2-1-2',
        'holdDuration': 1,
        'repetitionTarget': 10,
        'setTarget': 3,
        'restDuration': 15,
        'estimatedCalories': 20.0,
        'voiceInstruction': 'Voice',
        'warning': 'Warning',
        'contraindication': 'None',
        'tags': ['tag'],
        'thumbnailAsset': 'thumb.png',
        'animationAsset': 'anim.json',
      };

      expect(validator.validateJsonMap(validMap), isTrue);
    });

    test('Menolak JSON Map yang kehilangan field wajib -> False', () {
      final invalidMap = {
        'id': 'ex_1',
        'name': 'Name',
        // Kategori dan field lainnya sengaja dihilangkan
      };

      expect(validator.validateJsonMap(invalidMap), isFalse);
    });
  });
}
