import '../models/workout_rep.dart';
import '../models/workout_set.dart';
import '../models/workout_summary.dart';
import '../models/recorded_frame.dart';
import 'workout_score_engine.dart';

/// Engine analisis untuk membuat [WorkoutSummary] setelah sesi selesai.
class WorkoutSummaryEngine {
  const WorkoutSummaryEngine();

  static WorkoutSummary generateSummary({
    required String sessionId,
    required String exerciseId,
    required String exerciseName,
    required int totalDurationSeconds,
    required double estimatedCaloriesPerMin,
    required List<WorkoutSet> completedSets,
    required List<RecordedFrame> frames,
    required double targetROM,
  }) {
    final allReps = <WorkoutRep>[];
    for (final s in completedSets) {
      allReps.addAll(s.reps);
    }

    final double caloriesBurned = (totalDurationSeconds / 60.0) * estimatedCaloriesPerMin;

    if (allReps.isEmpty) {
      final defaultScore = WorkoutScoreEngine.calculateScore(allReps: [], frames: [], targetROM: targetROM);
      return WorkoutSummary(
        sessionId: sessionId,
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        totalDurationSeconds: totalDurationSeconds,
        caloriesBurned: caloriesBurned,
        totalRepsCompleted: 0,
        totalSetsCompleted: completedSets.length,
        averageAccuracy: 0.0,
        averageROM: 0.0,
        averageSpeedDegreesPerSec: 0.0,
        averageHoldSeconds: 0.0,
        movementStability: 0.0,
        score: defaultScore,
        xpEarned: 10,
        achievements: ['Semangat Mencoba!'],
        improvements: ['Selesaikan set secara penuh pada latihan berikutnya.'],
        timestamp: DateTime.now(),
      );
    }

    // Best Rep & Worst Rep
    allReps.sort((a, b) => b.accuracyScore.compareTo(a.accuracyScore));
    final bestRep = allReps.first;
    final worstRep = allReps.last;

    final avgAccuracy = allReps.fold(0.0, (s, r) => s + r.accuracyScore) / allReps.length;
    final avgROM = allReps.fold(0.0, (s, r) => s + r.maxROM) / allReps.length;
    final avgDurationMs = allReps.fold(0.0, (s, r) => s + r.durationMs) / allReps.length;
    final avgSpeed = avgDurationMs > 0 ? (avgROM / (avgDurationMs / 1000.0)) : 30.0;

    final score = WorkoutScoreEngine.calculateScore(
      allReps: allReps,
      frames: frames,
      targetROM: targetROM,
    );

    // XP calculation: base 50 XP + 2 XP per rep + score multiplier
    final xpEarned = 50 + (allReps.length * 5) + (score.totalScore * 0.5).toInt();

    // Badges & Achievements
    final achievements = <String>[];
    if (score.totalScore >= 90) achievements.add('Master Rehabilitasi');
    if (score.romScore >= 95) achievements.add('ROM Maksimal');
    if (score.smoothnessScore >= 90) achievements.add('Gerakan Halus');
    if (completedSets.length >= 3) achievements.add('Disiplin Set');

    // Medical Improvement Advice
    final improvements = <String>[];
    if (score.romScore < 80) {
      improvements.add('Tingkatkan capaian sudut gerakan (ROM) perlahan tanpa memaksakan otot.');
    }
    if (score.smoothnessScore < 85) {
      improvements.add('Fokus kontrol tempo eksentrik saat menurunkan sendi.');
    }
    if (score.holdScore < 80) {
      improvements.add('Tahan posisi puncak minimal 2 detik untuk kontraksi isometrik maksimal.');
    }
    if (improvements.isEmpty) {
      improvements.add('Performa sangat konsisten! Pertahankan postur dan ritme latihan.');
    }

    return WorkoutSummary(
      sessionId: sessionId,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      totalDurationSeconds: totalDurationSeconds,
      caloriesBurned: caloriesBurned,
      totalRepsCompleted: allReps.length,
      totalSetsCompleted: completedSets.length,
      averageAccuracy: avgAccuracy,
      averageROM: avgROM,
      averageSpeedDegreesPerSec: avgSpeed,
      averageHoldSeconds: 2.0,
      movementStability: score.smoothnessScore,
      score: score,
      xpEarned: xpEarned,
      achievements: achievements,
      improvements: improvements,
      timestamp: DateTime.now(),
      bestRep: bestRep,
      worstRep: worstRep,
    );
  }
}
