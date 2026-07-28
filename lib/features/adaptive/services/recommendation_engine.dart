import '../models/fatigue_status.dart';
import '../models/physical_profile.dart';
import '../models/workout_recommendation.dart';

/// Engine pemberi rekomendasi latihan adaptif (Recommendation Engine).
class RecommendationEngine {
  const RecommendationEngine();

  /// Menghasilkan [WorkoutRecommendation] berdasarkan [profile] dan [fatigue].
  WorkoutRecommendation generateRecommendation({
    required PhysicalProfile profile,
    required FatigueStatus fatigue,
  }) {
    if (fatigue.level == FatigueLevel.severe) {
      return const WorkoutRecommendation(
        recommendedExerciseId: 'arm_raise',
        recommendedExerciseName: 'Arm Raise Ringan (Pemulihan)',
        targetAngle: 110.0,
        targetReps: 6,
        restSeconds: 30,
        difficultyLevel: 1,
        reason: 'Tingkat kelelahan tinggi. Disarankan latihan pemulihan ringan.',
      );
    }

    if (profile.difficultyLevel >= 4) {
      return WorkoutRecommendation(
        recommendedExerciseId: 'shoulder_press',
        recommendedExerciseName: 'Shoulder Press Lanjutan',
        targetAngle: profile.shoulderRom.clamp(140.0, 165.0),
        targetReps: 12,
        restSeconds: 20,
        difficultyLevel: profile.difficultyLevel,
        reason: 'Performa dan rentang gerak Anda sangat baik!',
      );
    }

    return WorkoutRecommendation(
      recommendedExerciseId: 'arm_raise',
      recommendedExerciseName: 'Arm Raise Adaptif',
      targetAngle: profile.shoulderRom.clamp(120.0, 150.0),
      targetReps: 10,
      restSeconds: 15,
      difficultyLevel: profile.difficultyLevel,
      reason: 'Sesuai dengan profil rentang gerak bahu Anda.',
    );
  }
}
