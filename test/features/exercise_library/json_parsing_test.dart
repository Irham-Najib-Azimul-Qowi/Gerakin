import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerakin/features/exercise_library/models/full_exercise_definition.dart';
import 'package:gerakin/features/motion/models/joint_angle.dart';

void main() {
  group('ECMS JSON Parsing Tests', () {
    test('Mengurai JSON String menjadi FullExerciseDefinition secara presisi', () {
      const sampleJson = '''
      {
        "id": "arm_raise_rom",
        "name": "Arm Raise ROM",
        "category": "Range of Motion",
        "difficulty": 2,
        "description": "Mengangkat kedua lengan lurus ke atas.",
        "benefit": "Melatih mobilitas sendi bahu.",
        "targetMuscles": ["Deltoid", "Pectoralis"],
        "requiredEquipment": "Tanpa Alat",
        "movementPattern": "Elevasi Lengan",
        "startPose": "Lengan Di Samping Badan",
        "endPose": "Lengan Ke Atas",
        "targetAngles": {
          "primaryJoint": "leftShoulder",
          "startAngle": 25.0,
          "targetAngle": 160.0
        },
        "tolerance": 15.0,
        "tempo": "2-2-2",
        "holdDuration": 2,
        "repetitionTarget": 10,
        "setTarget": 3,
        "restDuration": 15,
        "estimatedCalories": 25.0,
        "voiceInstruction": "Angkat lengan tinggi-tinggi",
        "warning": "Jaga punggung tetap tegak",
        "contraindication": "Impingement bahu",
        "tags": ["rom", "shoulder"],
        "thumbnailAsset": "thumb.png",
        "animationAsset": "anim.json"
      }
      ''';

      final Map<String, dynamic> jsonMap = jsonDecode(sampleJson);
      final exercise = FullExerciseDefinition.fromJson(jsonMap);

      expect(exercise.id, equals('arm_raise_rom'));
      expect(exercise.difficulty, equals(2));
      expect(exercise.targetAngles.primaryJoint, equals(JointType.leftShoulder));
      expect(exercise.targetMuscles, contains('Deltoid'));

      final workoutDef = exercise.toWorkoutExerciseDefinition();
      expect(workoutDef.id, equals('arm_raise_rom'));
      expect(workoutDef.targetAngle, equals(160.0));
    });
  });
}
