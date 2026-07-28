/// Model data rekomendasi latihan adaptif terpersonalisasi.
class WorkoutRecommendation {
  const WorkoutRecommendation({
    required this.recommendedExerciseId,
    required this.recommendedExerciseName,
    required this.targetAngle,
    required this.targetReps,
    required this.restSeconds,
    required this.difficultyLevel,
    required this.reason,
  });

  final String recommendedExerciseId;
  final String recommendedExerciseName;
  final double targetAngle;
  final int targetReps;
  final int restSeconds;
  final int difficultyLevel;
  final String reason;

  factory WorkoutRecommendation.defaultRecommendation() {
    return const WorkoutRecommendation(
      recommendedExerciseId: 'arm_raise',
      recommendedExerciseName: 'Arm Raise Adaptif',
      targetAngle: 140.0,
      targetReps: 10,
      restSeconds: 15,
      difficultyLevel: 1,
      reason: 'Latihan dasar yang aman untuk mengukur rentang gerak bahu.',
    );
  }
}
