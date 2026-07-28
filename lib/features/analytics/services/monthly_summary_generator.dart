import '../models/workout_session.dart';
import '../models/monthly_summary.dart';

/// Service generator untuk membuat rangkuman aktivitas bulanan pengguna.
class MonthlySummaryGenerator {
  /// Menghasilkan [MonthlySummary] untuk [year] dan [month] tertentu.
  MonthlySummary generate(List<WorkoutSession> sessions, int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 1).subtract(const Duration(milliseconds: 1));

    final monthlySessions = sessions.where((s) {
      return (s.startTime.isAtSameMomentAs(startOfMonth) || s.startTime.isAfter(startOfMonth)) &&
             s.startTime.isBefore(endOfMonth);
    }).toList();

    if (monthlySessions.isEmpty) {
      return MonthlySummary.empty(year, month);
    }

    double totalDurationSeconds = 0;
    double totalCalories = 0.0;
    double totalAccuracySum = 0.0;
    double totalRomSum = 0.0;

    // Bagi bulan menjadi 4 rentang minggu:
    // Minggu 1: tanggal 1 - 7
    // Minggu 2: tanggal 8 - 14
    // Minggu 3: tanggal 15 - 21
    // Minggu 4: tanggal 22 - akhir bulan
    final weeklyAccuracySums = List.filled(4, 0.0);
    final weeklyRomSums = List.filled(4, 0.0);
    final weeklySessionCounts = List.filled(4, 0);

    for (final session in monthlySessions) {
      totalDurationSeconds += session.durationInSeconds;
      totalCalories += session.caloriesBurned;
      totalAccuracySum += session.accuracy;
      totalRomSum += session.averageRom;

      final day = session.startTime.day;
      int weekIndex = 3; // Default ke minggu 4
      if (day <= 7) {
        weekIndex = 0;
      } else if (day <= 14) {
        weekIndex = 1;
      } else if (day <= 21) {
        weekIndex = 2;
      }

      weeklySessionCounts[weekIndex]++;
      weeklyAccuracySums[weekIndex] += session.accuracy;
      weeklyRomSums[weekIndex] += session.averageRom;
    }

    final weeklyAccuracy = List.filled(4, 0.0);
    final weeklyRom = List.filled(4, 0.0);

    for (int i = 0; i < 4; i++) {
      final count = weeklySessionCounts[i];
      if (count > 0) {
        weeklyAccuracy[i] = weeklyAccuracySums[i] / count;
        weeklyRom[i] = weeklyRomSums[i] / count;
      }
    }

    final totalSessions = monthlySessions.length;
    final averageAccuracy = totalAccuracySum / totalSessions;
    final averageRom = totalRomSum / totalSessions;
    final totalDurationInMinutes = totalDurationSeconds / 60.0;

    return MonthlySummary(
      year: year,
      month: month,
      totalSessions: totalSessions,
      totalDurationInMinutes: totalDurationInMinutes,
      totalCalories: totalCalories,
      averageAccuracy: averageAccuracy,
      averageRom: averageRom,
      weeklyAccuracy: weeklyAccuracy,
      weeklyRom: weeklyRom,
    );
  }
}
