import '../models/recovery_progress.dart';

/// Kalkulator untuk menganalisis tren pemulihan fisik pengguna.
class RecoveryTrendCalculator {
  /// Menghitung rata-rata skor pemulihan keseluruhan.
  double calculateAverageRecoveryScore(List<RecoveryProgress> records) {
    if (records.isEmpty) return 0.0;
    final total = records.fold(0, (sum, item) => sum + item.overallRecoveryScore);
    return total / records.length;
  }

  /// Menghasilkan tren skor pemulihan kronologis.
  List<double> calculateRecoveryScoreTrend(List<RecoveryProgress> records) {
    final sorted = List<RecoveryProgress>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));
    return sorted.map((r) => r.overallRecoveryScore.toDouble()).toList();
  }

  /// Menghasilkan tren tingkat rasa sakit (Pain Level) kronologis.
  List<double> calculatePainTrend(List<RecoveryProgress> records) {
    final sorted = List<RecoveryProgress>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));
    return sorted.map((r) => r.perceivedPainLevel.toDouble()).toList();
  }

  /// Menghasilkan tren tingkat kelelahan (Fatigue Level) kronologis.
  List<double> calculateFatigueTrend(List<RecoveryProgress> records) {
    final sorted = List<RecoveryProgress>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));
    return sorted.map((r) => r.fatigueLevel.toDouble()).toList();
  }
}
