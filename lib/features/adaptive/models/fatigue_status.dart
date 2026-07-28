/// Enum tingkat kelelahan fisik (Fatigue Level).
enum FatigueLevel {
  none,
  mild,
  moderate,
  severe,
}

/// Model status kelelahan otot real-time.
class FatigueStatus {
  const FatigueStatus({
    required this.level,
    required this.fatigueScore,
    required this.degradationPercentage,
    required this.recommendRest,
  });

  /// Tingkat kelelahan (none, mild, moderate, severe).
  final FatigueLevel level;

  /// Skor kelelahan (0.0 s/d 100.0).
  final double fatigueScore;

  /// Persentase penurunan performa gerak (degradation rate).
  final double degradationPercentage;

  /// Apakah disarankan untuk segera istirahat.
  final bool recommendRest;

  factory FatigueStatus.fresh() {
    return const FatigueStatus(
      level: FatigueLevel.none,
      fatigueScore: 0.0,
      degradationPercentage: 0.0,
      recommendRest: false,
    );
  }
}
