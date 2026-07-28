/// Model status keselamatan fisik latihan.
class SafetyStatus {
  const SafetyStatus({
    required this.safetyScore,
    required this.isSafe,
    required this.activeWarnings,
    required this.shouldStopWorkout,
  });

  /// Skor keselamatan (0.0 s/d 100.0).
  final double safetyScore;

  /// Apakah latihan berada pada kondisi aman.
  final bool isSafe;

  /// Daftar pesan peringatan keselamatan aktif.
  final List<String> activeWarnings;

  /// Apakah latihan harus dihentikan secara otomatis demi keselamatan pengguna.
  final bool shouldStopWorkout;

  factory SafetyStatus.optimal() {
    return const SafetyStatus(
      safetyScore: 100.0,
      isSafe: true,
      activeWarnings: [],
      shouldStopWorkout: false,
    );
  }
}
