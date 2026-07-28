import '../models/workout_session.dart';
import '../models/achievement.dart';

/// Engine evaluasi untuk menghitung dan membuka pencapaian pengguna.
class AchievementEngine {
  /// Mendefinisikan daftar pencapaian default (locked).
  List<Achievement> get defaultAchievements {
    return [
      Achievement(
        achievementId: 'first_step',
        title: 'Langkah Pertama',
        description: 'Menyelesaikan 1 sesi latihan pertama.',
        iconPath: 'assets/icons/first_step.svg',
        isUnlocked: false,
        progress: 0.0,
        targetValue: 1.0,
        currentValue: 0.0,
      ),
      Achievement(
        achievementId: 'perfect_accuracy',
        title: 'Akurasi Sempurna',
        description: 'Mencapai akurasi latihan minimal 90%.',
        iconPath: 'assets/icons/perfect_accuracy.svg',
        isUnlocked: false,
        progress: 0.0,
        targetValue: 90.0,
        currentValue: 0.0,
      ),
      Achievement(
        achievementId: 'consistent_athlete',
        title: 'Konsistensi Tinggi',
        description: 'Menyelesaikan total 5 sesi latihan.',
        iconPath: 'assets/icons/consistent.svg',
        isUnlocked: false,
        progress: 0.0,
        targetValue: 5.0,
        currentValue: 0.0,
      ),
      Achievement(
        achievementId: 'rom_master',
        title: 'Gerakan Maksimal',
        description: 'Mencapai sudut ROM rata-rata minimal 120 derajat.',
        iconPath: 'assets/icons/rom_master.svg',
        isUnlocked: false,
        progress: 0.0,
        targetValue: 120.0,
        currentValue: 0.0,
      ),
      Achievement(
        achievementId: 'calorie_burner',
        title: 'Pembakar Kalori',
        description: 'Membakar total 500 kkal dari seluruh latihan.',
        iconPath: 'assets/icons/calories.svg',
        isUnlocked: false,
        progress: 0.0,
        targetValue: 500.0,
        currentValue: 0.0,
      ),
    ];
  }

  /// Evaluasi dan update seluruh pencapaian berdasarkan riwayat sesi latihan.
  List<Achievement> evaluateAchievements({
    required List<WorkoutSession> sessions,
    required List<Achievement> currentAchievements,
  }) {
    final list = currentAchievements.isEmpty ? defaultAchievements : currentAchievements;
    final totalSessions = sessions.length;
    double totalCalories = 0.0;
    double maxAccuracy = 0.0;
    double maxRom = 0.0;

    for (final s in sessions) {
      totalCalories += s.caloriesBurned;
      if (s.accuracy > maxAccuracy) maxAccuracy = s.accuracy;
      if (s.averageRom > maxRom) maxRom = s.averageRom;
    }

    return list.map((achievement) {
      if (achievement.isUnlocked) return achievement;

      double curValue = 0.0;
      bool unlock = false;

      switch (achievement.achievementId) {
        case 'first_step':
          curValue = totalSessions.toDouble();
          unlock = totalSessions >= achievement.targetValue;
          break;
        case 'perfect_accuracy':
          curValue = maxAccuracy;
          unlock = maxAccuracy >= achievement.targetValue;
          break;
        case 'consistent_athlete':
          curValue = totalSessions.toDouble();
          unlock = totalSessions >= achievement.targetValue;
          break;
        case 'rom_master':
          curValue = maxRom;
          unlock = maxRom >= achievement.targetValue;
          break;
        case 'calorie_burner':
          curValue = totalCalories;
          unlock = totalCalories >= achievement.targetValue;
          break;
        default:
          return achievement;
      }

      // Hitung progress (max 1.0)
      final rawProgress = curValue / achievement.targetValue;
      final progress = rawProgress > 1.0 ? 1.0 : (rawProgress < 0.0 ? 0.0 : rawProgress);

      return achievement.copyWith(
        currentValue: curValue,
        progress: progress,
        isUnlocked: unlock,
        unlockedAt: unlock ? DateTime.now() : null,
      );
    }).toList();
  }
}
