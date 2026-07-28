import '../models/workout_session.dart';
import '../models/weekly_summary.dart';

/// Service generator untuk membuat rangkuman aktivitas mingguan pengguna.
class WeeklySummaryGenerator {
  /// Menghasilkan [WeeklySummary] untuk minggu tertentu yang mencakup [targetDate].
  WeeklySummary generate(List<WorkoutSession> sessions, DateTime targetDate) {
    // Tentukan hari Senin dari minggu targetDate
    final startOfWeek = targetDate.subtract(Duration(days: targetDate.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    // Filter sesi yang berada dalam rentang tanggal minggu ini
    final weeklySessions = sessions.where((s) {
      return (s.startTime.isAtSameMomentAs(startDate) || s.startTime.isAfter(startDate)) &&
             s.startTime.isBefore(endDate);
    }).toList();

    if (weeklySessions.isEmpty) {
      return WeeklySummary.empty(startDate, endDate);
    }

    double totalDurationSeconds = 0;
    double totalCalories = 0.0;
    double totalAccuracySum = 0.0;
    double totalRomSum = 0.0;

    final dailySessionCounts = List.filled(7, 0);
    final dailyAccuracySums = List.filled(7, 0.0);
    final dailyRomSums = List.filled(7, 0.0);

    for (final session in weeklySessions) {
      totalDurationSeconds += session.durationInSeconds;
      totalCalories += session.caloriesBurned;
      totalAccuracySum += session.accuracy;
      totalRomSum += session.averageRom;

      // weekday: Senin = 1, Minggu = 7. Map ke index 0-6
      final index = session.startTime.weekday - 1;
      if (index >= 0 && index < 7) {
        dailySessionCounts[index]++;
        dailyAccuracySums[index] += session.accuracy;
        dailyRomSums[index] += session.averageRom;
      }
    }

    final dailyAccuracy = List.filled(7, 0.0);
    final dailyRom = List.filled(7, 0.0);

    for (int i = 0; i < 7; i++) {
      final count = dailySessionCounts[i];
      if (count > 0) {
        dailyAccuracy[i] = dailyAccuracySums[i] / count;
        dailyRom[i] = dailyRomSums[i] / count;
      }
    }

    final totalSessions = weeklySessions.length;
    final averageAccuracy = totalAccuracySum / totalSessions;
    final averageRom = totalRomSum / totalSessions;
    final totalDurationInMinutes = totalDurationSeconds / 60.0;

    return WeeklySummary(
      startDate: startDate,
      endDate: endDate,
      totalSessions: totalSessions,
      totalDurationInMinutes: totalDurationInMinutes,
      totalCalories: totalCalories,
      averageAccuracy: averageAccuracy,
      averageRom: averageRom,
      dailySessionCounts: dailySessionCounts,
      dailyAccuracy: dailyAccuracy,
      dailyRom: dailyRom,
    );
  }
}
