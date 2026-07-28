import '../../workout_engine/models/exercise_definition.dart';
import 'exercise_target_angles.dart';

/// Model skema ECMS terkomprehensif untuk ExerciseDefinition.
class FullExerciseDefinition {
  const FullExerciseDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.description,
    required this.benefit,
    required this.targetMuscles,
    required this.requiredEquipment,
    required this.movementPattern,
    required this.startPose,
    required this.endPose,
    required this.targetAngles,
    required this.tolerance,
    required this.tempo,
    required this.holdDuration,
    required this.repetitionTarget,
    required this.setTarget,
    required this.restDuration,
    required this.estimatedCalories,
    required this.voiceInstruction,
    required this.warning,
    required this.contraindication,
    required this.tags,
    required this.thumbnailAsset,
    required this.animationAsset,
  });

  final String id;
  final String name;
  final String category;
  final int difficulty;
  final String description;
  final String benefit;
  final List<String> targetMuscles;
  final String requiredEquipment;
  final String movementPattern;
  final String startPose;
  final String endPose;
  final ExerciseTargetAngles targetAngles;
  final double tolerance;
  final String tempo;
  final int holdDuration;
  final int repetitionTarget;
  final int setTarget;
  final int restDuration;
  final double estimatedCalories;
  final String voiceInstruction;
  final String warning;
  final String contraindication;
  final List<String> tags;
  final String thumbnailAsset;
  final String animationAsset;

  /// Mengonversi ke [ExerciseDefinition] milik Workout Engine.
  ExerciseDefinition toWorkoutExerciseDefinition() {
    return ExerciseDefinition(
      id: id,
      name: name,
      category: category,
      difficulty: 'Level $difficulty',
      description: description,
      primaryJoint: targetAngles.primaryJoint,
      startAngle: targetAngles.startAngle,
      targetAngle: targetAngles.targetAngle,
      tolerance: tolerance,
      holdDuration: holdDuration,
      repetitionTarget: repetitionTarget,
      setTarget: setTarget,
      restDuration: restDuration,
      voiceCues: [voiceInstruction],
      warningMessages: [warning],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'difficulty': difficulty,
      'description': description,
      'benefit': benefit,
      'targetMuscles': targetMuscles,
      'requiredEquipment': requiredEquipment,
      'movementPattern': movementPattern,
      'startPose': startPose,
      'endPose': endPose,
      'targetAngles': targetAngles.toJson(),
      'tolerance': tolerance,
      'tempo': tempo,
      'holdDuration': holdDuration,
      'repetitionTarget': repetitionTarget,
      'setTarget': setTarget,
      'restDuration': restDuration,
      'estimatedCalories': estimatedCalories,
      'voiceInstruction': voiceInstruction,
      'warning': warning,
      'contraindication': contraindication,
      'tags': tags,
      'thumbnailAsset': thumbnailAsset,
      'animationAsset': animationAsset,
    };
  }

  factory FullExerciseDefinition.fromJson(Map<String, dynamic> json) {
    return FullExerciseDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      difficulty: (json['difficulty'] as num).toInt(),
      description: json['description'] as String,
      benefit: json['benefit'] as String,
      targetMuscles: List<String>.from(json['targetMuscles'] as List),
      requiredEquipment: json['requiredEquipment'] as String,
      movementPattern: json['movementPattern'] as String,
      startPose: json['startPose'] as String,
      endPose: json['endPose'] as String,
      targetAngles: ExerciseTargetAngles.fromJson(
        json['targetAngles'] as Map<String, dynamic>,
      ),
      tolerance: (json['tolerance'] as num).toDouble(),
      tempo: json['tempo'] as String,
      holdDuration: (json['holdDuration'] as num).toInt(),
      repetitionTarget: (json['repetitionTarget'] as num).toInt(),
      setTarget: (json['setTarget'] as num).toInt(),
      restDuration: (json['restDuration'] as num).toInt(),
      estimatedCalories: (json['estimatedCalories'] as num).toDouble(),
      voiceInstruction: json['voiceInstruction'] as String,
      warning: json['warning'] as String,
      contraindication: json['contraindication'] as String,
      tags: List<String>.from(json['tags'] as List),
      thumbnailAsset: json['thumbnailAsset'] as String,
      animationAsset: json['animationAsset'] as String,
    );
  }
}
