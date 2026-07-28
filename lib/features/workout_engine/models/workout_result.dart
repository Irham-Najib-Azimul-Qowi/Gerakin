/// Model data ringkasan hasil latihan yang telah selesai.
class WorkoutResult {
  const WorkoutResult({
    required this.exerciseId,
    required this.exerciseName,
    required this.totalCompletedReps,
    required this.totalTargetReps,
    required this.totalCompletedSets,
    required this.totalDurationSeconds,
    required this.caloriesBurned,
    required this.finalScore,
    required this.accuracyPercentage,
    required this.completedAt,
  });

  final String exerciseId;
  final String exerciseName;
  final int totalCompletedReps;
  final int totalTargetReps;
  final int totalCompletedSets;
  final int totalDurationSeconds;
  final double caloriesBurned;
  final double finalScore;
  final double accuracyPercentage;
  final DateTime completedAt;

  @override
  String toString() =>
      'WorkoutResult($exerciseName: $totalCompletedReps reps, duration: ${totalDurationSeconds}s, score: ${finalScore.toStringAsFixed(1)})';
}
