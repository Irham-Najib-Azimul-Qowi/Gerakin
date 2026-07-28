/// Model data profil fisik adaptif pengguna.
class PhysicalProfile {
  const PhysicalProfile({
    required this.shoulderRom,
    required this.elbowRom,
    required this.stabilityScore,
    required this.difficultyLevel,
    required this.fitnessRating,
    required this.lastUpdated,
  });

  /// Rentang gerak bahu (Shoulder ROM).
  final double shoulderRom;

  /// Rentang gerak siku (Elbow ROM).
  final double elbowRom;

  /// Kestabilan gerak (0.0 s/d 100.0).
  final double stabilityScore;

  /// Level kesulitan adaptif (1 s/d 5).
  final int difficultyLevel;

  /// Rating kebugaran fisik.
  final String fitnessRating;

  /// Waktu pembaruan terakhir.
  final DateTime lastUpdated;

  factory PhysicalProfile.defaultProfile() {
    return PhysicalProfile(
      shoulderRom: 140.0,
      elbowRom: 155.0,
      stabilityScore: 80.0,
      difficultyLevel: 1,
      fitnessRating: 'Pemula',
      lastUpdated: DateTime.now(),
    );
  }

  PhysicalProfile copyWith({
    double? shoulderRom,
    double? elbowRom,
    double? stabilityScore,
    int? difficultyLevel,
    String? fitnessRating,
    DateTime? lastUpdated,
  }) {
    return PhysicalProfile(
      shoulderRom: shoulderRom ?? this.shoulderRom,
      elbowRom: elbowRom ?? this.elbowRom,
      stabilityScore: stabilityScore ?? this.stabilityScore,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      fitnessRating: fitnessRating ?? this.fitnessRating,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
