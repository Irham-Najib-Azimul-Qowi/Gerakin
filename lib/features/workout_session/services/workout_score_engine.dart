import '../models/workout_rep.dart';
import '../models/workout_score.dart';
import '../models/recorded_frame.dart';

/// Engine penilaian multi-dimensi medis untuk sesi latihan.
class WorkoutScoreEngine {
  const WorkoutScoreEngine();

  /// Menghitung [WorkoutScore] terperinci berdasarkan data repetisi & telemetri frame.
  static WorkoutScore calculateScore({
    required List<WorkoutRep> allReps,
    required List<RecordedFrame> frames,
    required double targetROM,
  }) {
    if (allReps.isEmpty) {
      return const WorkoutScore(
        accuracyScore: 0.0,
        romScore: 0.0,
        smoothnessScore: 0.0,
        confidenceScore: 0.0,
        consistencyScore: 0.0,
        holdScore: 0.0,
        speedScore: 0.0,
        safetyScore: 0.0,
        totalScore: 0.0,
      );
    }

    // 1. Accuracy Score
    final avgAccuracy = allReps.fold(0.0, (s, r) => s + r.accuracyScore) / allReps.length;

    // 2. ROM Score
    final avgMaxROM = allReps.fold(0.0, (s, r) => s + r.maxROM) / allReps.length;
    final romScore = targetROM > 0 ? (avgMaxROM / targetROM * 100.0).clamp(0.0, 100.0) : 85.0;

    // 3. Smoothness Score (Berdasarkan perbedaan delta sudut antar frame)
    double smoothnessScore = 90.0;
    if (frames.length > 2) {
      double totalJerk = 0.0;
      for (int i = 1; i < frames.length; i++) {
        final deltaAngle = (frames[i].currentAngle - frames[i - 1].currentAngle).abs();
        if (deltaAngle > 15.0) {
          totalJerk += (deltaAngle - 15.0);
        }
      }
      smoothnessScore = (100.0 - (totalJerk / frames.length * 5.0)).clamp(40.0, 100.0);
    }

    // 4. Pose Confidence Score
    final confidenceScore = frames.isNotEmpty
        ? (frames.fold(0.0, (s, f) => s + f.confidence) / frames.length * 100.0).clamp(0.0, 100.0)
        : 90.0;

    // 5. Consistency Score (Variansi durasi antar rep)
    double consistencyScore = 85.0;
    if (allReps.length > 1) {
      final avgDuration = allReps.fold(0.0, (s, r) => s + r.durationMs) / allReps.length;
      double variance = 0.0;
      for (final r in allReps) {
        variance += (r.durationMs - avgDuration).abs();
      }
      final avgDiff = variance / allReps.length;
      consistencyScore = (100.0 - (avgDiff / avgDuration * 100.0)).clamp(50.0, 100.0);
    }

    // 6. Hold Score
    final holdAchievedCount = allReps.where((r) => r.holdsAchieved).length;
    final holdScore = (holdAchievedCount / allReps.length * 100.0).clamp(0.0, 100.0);

    // 7. Speed Score (Repetisi tidak boleh terlalu cepat < 1.5 detik)
    final fastRepCount = allReps.where((r) => r.durationMs < 1500).length;
    final speedScore = (100.0 - (fastRepCount / allReps.length * 40.0)).clamp(60.0, 100.0);

    // 8. Safety Score (Tidak ada kompensasi tubuh berlebih)
    final safetyScore = (smoothnessScore * 0.5 + confidenceScore * 0.5).clamp(0.0, 100.0);

    // Hitung Total Score Berbobot
    // Weights: Accuracy (20%), ROM (20%), Smoothness (15%), Confidence (10%), Consistency (10%), Hold (15%), Speed (5%), Safety (5%)
    final totalScore = (avgAccuracy * 0.20) +
        (romScore * 0.20) +
        (smoothnessScore * 0.15) +
        (confidenceScore * 0.10) +
        (consistencyScore * 0.10) +
        (holdScore * 0.15) +
        (speedScore * 0.05) +
        (safetyScore * 0.05);

    return WorkoutScore(
      accuracyScore: avgAccuracy.clamp(0.0, 100.0),
      romScore: romScore.clamp(0.0, 100.0),
      smoothnessScore: smoothnessScore.clamp(0.0, 100.0),
      confidenceScore: confidenceScore.clamp(0.0, 100.0),
      consistencyScore: consistencyScore.clamp(0.0, 100.0),
      holdScore: holdScore.clamp(0.0, 100.0),
      speedScore: speedScore.clamp(0.0, 100.0),
      safetyScore: safetyScore.clamp(0.0, 100.0),
      totalScore: totalScore.clamp(0.0, 100.0),
    );
  }
}
