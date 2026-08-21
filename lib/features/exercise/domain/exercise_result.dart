import 'exercise_type.dart';

/// Hasil kuantitatif dari satu repetisi yang telah diselesaikan.
class RepResult {
  const RepResult({
    required this.repIndex,
    required this.accuracyPercentage,
    required this.durationMs,
    required this.corrections,
  });

  final int repIndex;
  final double accuracyPercentage;
  final int durationMs;
  final List<String> corrections;
}

/// Ringkasan lengkap sesi latihan yang berhasil diselesaikan.
class ExerciseSessionSummary {
  const ExerciseSessionSummary({
    required this.exerciseType,
    required this.startedAt,
    required this.endedAt,
    required this.completedSets,
    required this.totalSets,
    required this.completedReps,
    required this.targetReps,
    required this.averageAccuracy,
    required this.durationInSeconds,
    required this.totalCorrectionsCount,
    required this.repDetails,
  });

  final ExerciseType exerciseType;
  final DateTime startedAt;
  final DateTime endedAt;
  final int completedSets;
  final int totalSets;
  final int completedReps;
  final int targetReps;
  final double averageAccuracy;
  final int durationInSeconds;
  final int totalCorrectionsCount;
  final List<RepResult> repDetails;

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseType.id,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'completedSets': completedSets,
      'totalSets': totalSets,
      'completedReps': completedReps,
      'targetReps': targetReps,
      'averageAccuracy': averageAccuracy,
      'durationInSeconds': durationInSeconds,
      'totalCorrectionsCount': totalCorrectionsCount,
    };
  }
}
