import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/exercise_library/data/asset_exercise_repository_impl.dart';
import 'package:gerakin/features/exercise_library/models/full_exercise_definition.dart';
import 'package:gerakin/features/exercise_library/services/exercise_loader.dart';

void main() {
  group('AssetExerciseRepositoryImpl Tests', () {
    late AssetExerciseRepositoryImpl repository;

    setUp(() {
      repository = AssetExerciseRepositoryImpl(
        loader: const _MockExerciseLoader(),
      );
    });

    test('getAllExercises mengembalikan seluruh daftar latihan', () async {
      final list = await repository.getAllExercises();
      expect(list.length, equals(1));
      expect(list.first.id, equals('mock_ex'));
    });

    test('getExerciseById mengembalikan latihan yang tepat', () async {
      final item = await repository.getExerciseById('mock_ex');
      expect(item, isNotNull);
      expect(item!.name, equals('Mock Exercise'));
    });

    test('getWorkoutExerciseDefinition mengonversi ke ExerciseDefinition', () async {
      final workoutDef = await repository.getWorkoutExerciseDefinition('mock_ex');
      expect(workoutDef, isNotNull);
      expect(workoutDef!.targetAngle, equals(150.0));
    });
  });
}

class _MockExerciseLoader extends ExerciseLoader {
  const _MockExerciseLoader();

  @override
  Future<List<FullExerciseDefinition>> loadExercisesFromAsset({String assetPath = ''}) async {
    const jsonStr = '''
    [
      {
        "id": "mock_ex",
        "name": "Mock Exercise",
        "category": "Warm Up",
        "difficulty": 1,
        "description": "Deskripsi mock",
        "benefit": "Manfaat mock",
        "targetMuscles": ["Biceps"],
        "requiredEquipment": "Tanpa Alat",
        "movementPattern": "Pattern",
        "startPose": "Start",
        "endPose": "End",
        "targetAngles": {
          "primaryJoint": "leftElbow",
          "startAngle": 30.0,
          "targetAngle": 150.0
        },
        "tolerance": 10.0,
        "tempo": "2-1-2",
        "holdDuration": 1,
        "repetitionTarget": 10,
        "setTarget": 3,
        "restDuration": 15,
        "estimatedCalories": 20.0,
        "voiceInstruction": "Instruksi mock",
        "warning": "Warning mock",
        "contraindication": "None",
        "tags": ["warmup"],
        "thumbnailAsset": "thumb.png",
        "animationAsset": "anim.json"
      }
    ]
    ''';
    return parseExercisesFromJsonString(jsonStr);
  }
}
