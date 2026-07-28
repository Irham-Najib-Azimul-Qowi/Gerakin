import '../models/full_exercise_definition.dart';

/// Service validasi skema JSON & integritas metadata latihan (Exercise Validator).
class ExerciseValidator {
  const ExerciseValidator();

  /// Memvalidasi satu objek Map JSON apakah memenuhi seluruh 24 bidang wajib skema ECMS.
  bool validateJsonMap(Map<String, dynamic> json) {
    const requiredKeys = [
      'id',
      'name',
      'category',
      'difficulty',
      'description',
      'benefit',
      'targetMuscles',
      'requiredEquipment',
      'movementPattern',
      'startPose',
      'endPose',
      'targetAngles',
      'tolerance',
      'tempo',
      'holdDuration',
      'repetitionTarget',
      'setTarget',
      'restDuration',
      'estimatedCalories',
      'voiceInstruction',
      'warning',
      'contraindication',
      'tags',
      'thumbnailAsset',
      'animationAsset',
    ];

    for (final key in requiredKeys) {
      if (!json.containsKey(key) || json[key] == null) {
        return false;
      }
    }

    if (json['targetAngles'] is! Map) return false;
    final targetAngles = json['targetAngles'] as Map;
    if (!targetAngles.containsKey('primaryJoint') ||
        !targetAngles.containsKey('startAngle') ||
        !targetAngles.containsKey('targetAngle')) {
      return false;
    }

    return true;
  }

  /// Memvalidasi objek [FullExerciseDefinition].
  bool validateDefinition(FullExerciseDefinition exercise) {
    if (exercise.id.isEmpty || exercise.name.isEmpty) return false;
    if (exercise.difficulty < 1 || exercise.difficulty > 5) return false;
    if (exercise.repetitionTarget <= 0 || exercise.setTarget <= 0) return false;
    if (exercise.targetMuscles.isEmpty) return false;

    return true;
  }
}
