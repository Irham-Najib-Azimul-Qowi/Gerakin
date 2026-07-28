import '../models/workout_session.dart';
import '../models/recovery_progress.dart';
import '../models/achievement.dart';
import '../models/workout_statistics.dart';
import '../models/weekly_summary.dart';
import '../models/monthly_summary.dart';
import 'progress_calculator.dart';
import 'weekly_summary_generator.dart';
import 'monthly_summary_generator.dart';
import 'recovery_trend_calculator.dart';
import 'achievement_engine.dart';

/// Service pusat (Fasad) untuk melakukan analisis seluruh data aktivitas pengguna.
class AnalyticsEngine {
  final ProgressCalculator _progressCalc = ProgressCalculator();
  final WeeklySummaryGenerator _weeklyGen = WeeklySummaryGenerator();
  final MonthlySummaryGenerator _monthlyGen = MonthlySummaryGenerator();
  final RecoveryTrendCalculator _recoveryCalc = RecoveryTrendCalculator();
  final AchievementEngine _achievementEngine = AchievementEngine();

  /// Menghitung statistik keseluruhan.
  WorkoutStatistics calculateOverallStats(List<WorkoutSession> sessions) {
    return _progressCalc.calculateStatistics(sessions);
  }

  /// Menghasilkan [WeeklySummary] untuk minggu target.
  WeeklySummary generateWeeklySummary(List<WorkoutSession> sessions, DateTime targetDate) {
    return _weeklyGen.generate(sessions, targetDate);
  }

  /// Menghasilkan [MonthlySummary] untuk bulan target.
  MonthlySummary generateMonthlySummary(List<WorkoutSession> sessions, int year, int month) {
    return _monthlyGen.generate(sessions, year, month);
  }

  /// Menghitung tren ROM rata-rata harian.
  List<double> getRomTrend(List<WorkoutSession> sessions) {
    return _progressCalc.calculateRomTrend(sessions);
  }

  /// Menghitung tren akurasi rata-rata harian.
  List<double> getAccuracyTrend(List<WorkoutSession> sessions) {
    return _progressCalc.calculateAccuracyTrend(sessions);
  }

  /// Menghitung rata-rata skor pemulihan.
  double getAverageRecovery(List<RecoveryProgress> records) {
    return _recoveryCalc.calculateAverageRecoveryScore(records);
  }

  /// Menghitung tren skor pemulihan.
  List<double> getRecoveryScoreTrend(List<RecoveryProgress> records) {
    return _recoveryCalc.calculateRecoveryScoreTrend(records);
  }

  /// Mengevaluasi pencapaian baru.
  List<Achievement> evaluateAchievements({
    required List<WorkoutSession> sessions,
    required List<Achievement> currentAchievements,
  }) {
    return _achievementEngine.evaluateAchievements(
      sessions: sessions,
      currentAchievements: currentAchievements,
    );
  }
}
