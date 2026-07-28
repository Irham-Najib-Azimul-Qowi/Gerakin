/// Engine penentu tingkat kesulitan adaptif (Level 1 s/d 5).
class AdaptiveDifficultyEngine {
  const AdaptiveDifficultyEngine();

  /// Menghitung level kesulitan (1 s/d 5) berdasarkan rentang gerak (ROM) dan kestabilan.
  int calculateDifficultyLevel({
    required double shoulderRom,
    required double elbowRom,
    required double stabilityScore,
  }) {
    // Level 1: Pemula (ROM terbatas < 125° atau Kestabilan < 60)
    if (shoulderRom < 125.0 || stabilityScore < 60.0) {
      return 1;
    }

    // Level 2: Novice (ROM 125° - 140°, Kestabilan 60 - 70)
    if (shoulderRom < 140.0 || stabilityScore < 70.0) {
      return 2;
    }

    // Level 3: Menengah / Intermediate (ROM 140° - 155°, Kestabilan 70 - 80)
    if (shoulderRom < 155.0 || stabilityScore < 80.0) {
      return 3;
    }

    // Level 4: Maju / Advanced (ROM 155° - 165°, Kestabilan 80 - 90)
    if (shoulderRom < 165.0 || stabilityScore < 90.0) {
      return 4;
    }

    // Level 5: Atletik / Elite (ROM >= 165° dan Kestabilan >= 90)
    return 5;
  }

  /// Label string deskriptif untuk setiap level.
  String getRatingForLevel(int level) {
    switch (level) {
      case 1:
        return 'Level 1 - Pemula / Mobilisasi Ringan';
      case 2:
        return 'Level 2 - Adaptif Dasar';
      case 3:
        return 'Level 3 - Menengah / Kebugaran Aktif';
      case 4:
        return 'Level 4 - Lanjutan / Performa Tinggi';
      case 5:
        return 'Level 5 - Atletik / Maksimal';
      default:
        return 'Level 1 - Pemula';
    }
  }
}
