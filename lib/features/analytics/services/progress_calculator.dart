import '../models/workout_session.dart';
import '../models/workout_statistics.dart';

/// Kalkulator domain untuk menghitung metrik agregat performa latihan.
class ProgressCalculator {
  /// Menghitung [WorkoutStatistics] dari daftar sesi latihan.
  WorkoutStatistics calculateStatistics(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return WorkoutStatistics.empty();

    double totalDurationSeconds = 0;
    double totalCalories = 0.0;
    double totalAccuracySum = 0.0;
    double totalRomSum = 0.0;
    int completedSessions = 0;

    for (final session in sessions) {
      totalDurationSeconds += session.durationInSeconds;
      totalCalories += session.caloriesBurned;
      totalAccuracySum += session.accuracy;
      totalRomSum += session.averageRom;
      if (session.isCompleted) {
        completedSessions++;
      }
    }

    final totalSessions = sessions.length;
    final totalDurationInMinutes = totalDurationSeconds / 60.0;
    final averageAccuracy = totalAccuracySum / totalSessions;
    final averageRom = totalRomSum / totalSessions;
    final completionRate = (completedSessions / totalSessions) * 100.0;

    return WorkoutStatistics(
      totalSessions: totalSessions,
      totalDurationInMinutes: totalDurationInMinutes,
      totalCalories: totalCalories,
      averageAccuracy: averageAccuracy,
      averageRom: averageRom,
      completionRate: completionRate,
    );
  }

  /// Menghitung tren ROM rata-rata harian (urutan kronologis).
  List<double> calculateRomTrend(List<WorkoutSession> sessions) {
    final sorted = List<WorkoutSession>.from(sessions)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return sorted.map((s) => s.averageRom).toList();
  }

  /// Menghitung tren akurasi rata-rata harian (urutan kronologis).
  List<double> calculateAccuracyTrend(List<WorkoutSession> sessions) {
    final sorted = List<WorkoutSession>.from(sessions)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return sorted.map((s) => s.accuracy).toList();
  }
}
