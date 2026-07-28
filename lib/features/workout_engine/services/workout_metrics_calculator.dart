import '../models/exercise_definition.dart';
import '../models/workout_metrics.dart';

/// Service pengolah metrik realtime latihan (durasi, sisa reps, sisa sets, estimasi kalori).
class WorkoutMetricsCalculator {
  WorkoutMetricsCalculator({
    this.userWeightKg = 65.0,
    this.metValue = 4.0,
  });

  final double userWeightKg;
  final double metValue;

  /// Menghitung estimasi kalori terbakar berdasarkan durasi latihan dalam detik.
  double calculateCaloriesBurned(int durationSeconds) {
    if (durationSeconds <= 0) return 0.0;
    final minutes = durationSeconds / 60.0;
    // Formula MET: (MET * 3.5 * Weight / 200) * minutes
    final kcal = ((metValue * 3.5 * userWeightKg) / 200.0) * minutes;
    return double.parse(kcal.toStringAsFixed(1));
  }

  /// Membangun objek [WorkoutMetrics] terbarui.
  WorkoutMetrics computeMetrics({
    required ExerciseDefinition exercise,
    required int currentRep,
    required int currentSet,
    required int durationSeconds,
    required int holdSeconds,
    required int restSeconds,
    required double score,
    required String statusText,
  }) {
    final remainingRep = (exercise.repetitionTarget - currentRep).clamp(0, exercise.repetitionTarget);
    final remainingSet = (exercise.setTarget - currentSet).clamp(0, exercise.setTarget);
    final calories = calculateCaloriesBurned(durationSeconds);

    return WorkoutMetrics(
      currentRep: currentRep,
      currentSet: currentSet,
      remainingRep: remainingRep,
      remainingSet: remainingSet,
      workoutDurationSeconds: durationSeconds,
      holdDurationSeconds: holdSeconds,
      restDurationSeconds: restSeconds,
      caloriesEstimate: calories,
      workoutScore: score,
      exerciseStatus: statusText,
    );
  }
}
