import '../models/fatigue_status.dart';
import '../models/physical_profile.dart';

/// Perencana penyesuaian dinamis (Adaptive Workout Planner).
///
/// TANGGUNG JAWAB:
/// - **Dynamic Target Angle**: Menyesuaikan sudut target gerakan secara otomatis.
/// - **Adaptive Rest Time**: Menyesuaikan durasi istirahat antar set berdasarkan tingkat kelelahan.
class AdaptiveWorkoutPlanner {
  const AdaptiveWorkoutPlanner();

  /// Menghitung Sudut Target Dinamis (Dynamic Target Angle) untuk latihan.
  double computeDynamicTargetAngle({
    required double baseTargetAngle,
    required PhysicalProfile profile,
  }) {
    // Sudut target disesuaikan agar tidak melebihi kapasitas ROM fisik pengguna
    if (profile.shoulderRom < baseTargetAngle) {
      return (profile.shoulderRom * 0.95).clamp(90.0, 180.0);
    }

    // Faktor peningkatan berdasarkan level kesulitan 1–5
    final levelFactor = 1.0 + (profile.difficultyLevel - 1) * 0.02;
    return (baseTargetAngle * levelFactor).clamp(90.0, 180.0);
  }

  /// Menghitung Waktu Istirahat Adaptif (Adaptive Rest Time) dalam detik.
  int computeAdaptiveRestTime({
    required int baseRestSeconds,
    required FatigueStatus fatigue,
  }) {
    switch (fatigue.level) {
      case FatigueLevel.none:
        return baseRestSeconds;
      case FatigueLevel.mild:
        return baseRestSeconds + 5;
      case FatigueLevel.moderate:
        return baseRestSeconds + 15;
      case FatigueLevel.severe:
        return baseRestSeconds + 30;
    }
  }
}
