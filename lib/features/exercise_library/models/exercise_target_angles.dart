import '../../motion/models/joint_angle.dart';

/// Target sudut sendi untuk ExerciseDefinition.
class ExerciseTargetAngles {
  const ExerciseTargetAngles({
    required this.primaryJoint,
    required this.startAngle,
    required this.targetAngle,
  });

  final JointType primaryJoint;
  final double startAngle;
  final double targetAngle;

  Map<String, dynamic> toJson() {
    return {
      'primaryJoint': primaryJoint.name,
      'startAngle': startAngle,
      'targetAngle': targetAngle,
    };
  }

  factory ExerciseTargetAngles.fromJson(Map<String, dynamic> json) {
    final jointStr = json['primaryJoint'] as String;
    final joint = JointType.values.firstWhere(
      (e) => e.name == jointStr,
      orElse: () => JointType.leftShoulder,
    );

    return ExerciseTargetAngles(
      primaryJoint: joint,
      startAngle: (json['startAngle'] as num).toDouble(),
      targetAngle: (json['targetAngle'] as num).toDouble(),
    );
  }
}
