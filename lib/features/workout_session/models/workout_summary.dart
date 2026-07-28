import 'workout_rep.dart';
import 'workout_score.dart';

/// Ringkasan lengkap performa latihan rehabilitasi medis setelah sesi selesai.
class WorkoutSummary {
  const WorkoutSummary({
    required this.sessionId,
    required this.exerciseId,
    required this.exerciseName,
    required this.totalDurationSeconds,
    required this.caloriesBurned,
    required this.totalRepsCompleted,
    required this.totalSetsCompleted,
    required this.averageAccuracy,
    required this.averageROM,
    required this.averageSpeedDegreesPerSec,
    required this.averageHoldSeconds,
    required this.movementStability,
    required this.score,
    required this.xpEarned,
    required this.achievements,
    required this.improvements,
    required this.timestamp,
    this.bestRep,
    this.worstRep,
  });

  final String sessionId;
  final String exerciseId;
  final String exerciseName;
  final int totalDurationSeconds;
  final double caloriesBurned;
  final int totalRepsCompleted;
  final int totalSetsCompleted;
  final double averageAccuracy;
  final double averageROM;
  final double averageSpeedDegreesPerSec;
  final double averageHoldSeconds;
  final double movementStability; // 0 - 100%
  final WorkoutScore score;
  final int xpEarned;
  final List<String> achievements;
  final List<String> improvements;
  final DateTime timestamp;
  final WorkoutRep? bestRep;
  final WorkoutRep? worstRep;

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'totalDurationSeconds': totalDurationSeconds,
      'caloriesBurned': caloriesBurned,
      'totalRepsCompleted': totalRepsCompleted,
      'totalSetsCompleted': totalSetsCompleted,
      'averageAccuracy': averageAccuracy,
      'averageROM': averageROM,
      'averageSpeedDegreesPerSec': averageSpeedDegreesPerSec,
      'averageHoldSeconds': averageHoldSeconds,
      'movementStability': movementStability,
      'score': score.toJson(),
      'xpEarned': xpEarned,
      'achievements': achievements,
      'improvements': improvements,
      'timestamp': timestamp.toIso8601String(),
      'bestRep': bestRep?.toJson(),
      'worstRep': worstRep?.toJson(),
    };
  }

  factory WorkoutSummary.fromJson(Map<String, dynamic> json) {
    return WorkoutSummary(
      sessionId: json['sessionId'] as String,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      totalDurationSeconds: (json['totalDurationSeconds'] as num).toInt(),
      caloriesBurned: (json['caloriesBurned'] as num).toDouble(),
      totalRepsCompleted: (json['totalRepsCompleted'] as num).toInt(),
      totalSetsCompleted: (json['totalSetsCompleted'] as num).toInt(),
      averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
      averageROM: (json['averageROM'] as num).toDouble(),
      averageSpeedDegreesPerSec: (json['averageSpeedDegreesPerSec'] as num).toDouble(),
      averageHoldSeconds: (json['averageHoldSeconds'] as num).toDouble(),
      movementStability: (json['movementStability'] as num).toDouble(),
      score: WorkoutScore.fromJson(json['score'] as Map<String, dynamic>),
      xpEarned: (json['xpEarned'] as num).toInt(),
      achievements: List<String>.from(json['achievements'] as List? ?? []),
      improvements: List<String>.from(json['improvements'] as List? ?? []),
      timestamp: DateTime.parse(json['timestamp'] as String),
      bestRep: json['bestRep'] != null
          ? WorkoutRep.fromJson(json['bestRep'] as Map<String, dynamic>)
          : null,
      worstRep: json['worstRep'] != null
          ? WorkoutRep.fromJson(json['worstRep'] as Map<String, dynamic>)
          : null,
    );
  }
}
